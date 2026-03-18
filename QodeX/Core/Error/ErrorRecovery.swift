//
//  ErrorRecovery.swift
//  Error recovery strategies with retry, fallback, and user guidance
//

import Foundation
import Combine

// MARK: - Error Recovery Protocol
protocol ErrorRecoverable {
    func attemptRecovery(from error: AppError, attempt: Int) async -> ErrorRecoveryResult
    func recoverySuggestion(for error: AppError) -> String?
}

// MARK: - Recovery Result
enum ErrorRecoveryResult {
    case success
    case retrySuggested(delay: TimeInterval)
    case fallbackAvailable(() async throws -> Void)
    case failed(reason: String)
    case requiresUserAction(action: RecoveryAction)
}

// MARK: - Recovery Action
enum RecoveryAction {
    case signIn
    case checkConnection
    case updateApp
    case contactSupport
    case dismiss
}

// MARK: - Error Recovery Manager
@MainActor
class ErrorRecoveryManager: ObservableObject {
    static let shared = ErrorRecoveryManager()
    
    @Published var isRecovering = false
    @Published var lastRecoveryResult: ErrorRecoveryResult?
    
    private var retryAttempts: [String: Int] = [:]
    private var lastRetryTime: [String: Date] = [:]
    private let maxRetries = 3
    
    private init() {}
    
    // MARK: - Retry with Exponential Backoff
    func attemptWithRetry<T>(
        operation: @escaping () async throws -> T,
        errorHandler: ((AppError) -> Void)? = nil,
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0
    ) async -> Result<T, AppError> {
        var lastError: AppError?
        
        for attempt in 0..<maxAttempts {
            do {
                let result = try await operation()
                return .success(result)
            } catch {
                let appError = AppError(from: error)
                lastError = appError
                
                // Check if we should retry
                guard shouldRetry(error: appError, attempt: attempt) else {
                    errorHandler?(appError)
                    return .failure(appError)
                }
                
                // Calculate delay with exponential backoff and jitter
                let delay = calculateDelay(attempt: attempt, baseDelay: baseDelay)
                
                print("[RETRY] Attempt \(attempt + 1)/\(maxAttempts) failed. Retrying in \(String(format: "%.2f", delay))s...")
                
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        if let error = lastError {
            errorHandler?(error)
            return .failure(error)
        }
        
        return .failure(.unknown(NSError(domain: "ErrorRecovery", code: -1)))
    }
    
    // MARK: - Conditional Retry
    private func shouldRetry(error: AppError, attempt: Int) -> Bool {
        guard attempt < maxRetries - 1 else { return false }
        
        switch error {
        case .network(let networkError):
            // Retry network errors except cancellation
            switch networkError {
            case .cancelled:
                return false
            default:
                return true
            }
            
        case .firebase(let firebaseError):
            // Retry certain Firebase errors
            switch firebaseError {
            case .offline, .writeFailed, .transactionFailed:
                return true
            default:
                return false
            }
            
        case .authentication(let authError):
            // Don't retry auth errors
            switch authError {
            case .tooManyRequests, .rateLimited:
                // Wait before retrying rate limits
                return attempt == 0
            default:
                return false
            }
            
        case .subscription:
            // Don't retry subscription errors
            return false
            
        case .cache:
            // Cache errors can retry (will fetch from network)
            return true
            
        case .validation, .permission:
            // User needs to fix these
            return false
            
        case .unknown:
            // Unknown errors - retry once
            return attempt == 0
        }
    }
    
    // MARK: - Exponential Backoff with Jitter
    private func calculateDelay(attempt: Int, baseDelay: TimeInterval) -> TimeInterval {
        // Exponential backoff: base * 2^attempt
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        
        // Add jitter (±25%) to prevent thundering herd
        let jitter = Double.random(in: 0.75...1.25)
        
        return min(exponentialDelay * jitter, 30.0) // Cap at 30 seconds
    }
    
    // MARK: - Fallback Strategies
    func attemptWithFallback<T>(
        primary: @escaping () async throws -> T,
        fallback: @escaping () async throws -> T
    ) async -> Result<T, AppError> {
        do {
            let result = try await primary()
            return .success(result)
        } catch {
            let primaryError = AppError(from: error)
            print("[FALLBACK] Primary operation failed: \(primaryError.errorDescription ?? ""), attempting fallback...")
            
            do {
                let fallbackResult = try await fallback()
                return .success(fallbackResult)
            } catch {
                return .failure(AppError(from: error))
            }
        }
    }
    
    // MARK: - Cache Fallback
    func fetchWithCacheFallback<T: Codable>(
        fetchFromNetwork: @escaping () async throws -> T,
        fetchFromCache: @escaping () async -> T?,
        saveToCache: @escaping (T) async -> Void
    ) async -> Result<T, AppError> {
        // Try network first
        do {
            let result = try await fetchFromNetwork()
            // Save to cache for next time
            await saveToCache(result)
            return .success(result)
        } catch {
            let networkError = AppError(from: error)
            print("[CACHE FALLBACK] Network failed: \(networkError.title), checking cache...")
            
            // Fallback to cache
            if let cached = await fetchFromCache() {
                print("[CACHE FALLBACK] Using cached data")
                return .success(cached)
            }
            
            return .failure(networkError)
        }
    }
    
    // MARK: - Error Recovery Action
    func getRecoveryAction(for error: AppError) -> RecoveryAction? {
        switch error {
        case .authentication(.sessionExpired), .authentication(.notAuthenticated):
            return .signIn
        case .network:
            return .checkConnection
        case .firebase(.quotaExceeded), .firebase(.permissionDenied):
            return .contactSupport
        case .subscription(.invalidReceipt), .subscription(.serverVerificationFailed):
            return .contactSupport
        default:
            if !error.isRecoverable {
                return .dismiss
            }
            return nil
        }
    }
    
    // MARK: - User-Friendly Error Message
    func getUserFriendlyMessage(for error: AppError) -> ErrorDisplayInfo {
        return ErrorDisplayInfo(
            title: error.title,
            message: error.errorDescription ?? "An unexpected error occurred.",
            suggestion: error.recoverySuggestion,
            isRecoverable: error.isRecoverable,
            action: getRecoveryAction(for: error)
        )
    }
    
    // MARK: - Track Retry
    func trackRetry(for key: String) {
        retryAttempts[key, default: 0] += 1
        lastRetryTime[key] = Date()
    }
    
    func shouldAllowRetry(for key: String, cooldown: TimeInterval = 60) -> Bool {
        let attempts = retryAttempts[key, default: 0]
        
        // Check if max retries exceeded
        guard attempts < maxRetries else {
            // Reset if cooldown has passed
            if let lastRetry = lastRetryTime[key],
               Date().timeIntervalSince(lastRetry) > cooldown {
                retryAttempts[key] = 0
                return true
            }
            return false
        }
        
        // Check cooldown between retries
        if let lastRetry = lastRetryTime[key] {
            let timeSinceLastRetry = Date().timeIntervalSince(lastRetry)
            return timeSinceLastRetry > min(cooldown / 3, 5) // At least 5 seconds between retries
        }
        
        return true
    }
    
    func resetRetry(for key: String) {
        retryAttempts[key] = 0
        lastRetryTime[key] = nil
    }
    
    func resetAllRetries() {
        retryAttempts.removeAll()
        lastRetryTime.removeAll()
    }
}

// MARK: - Error Display Info
struct ErrorDisplayInfo {
    let title: String
    let message: String
    let suggestion: String?
    let isRecoverable: Bool
    let action: RecoveryAction?
    
    var fullMessage: String {
        if let suggestion = suggestion {
            return "\(message)\n\n\(suggestion)"
        }
        return message
    }
}

// MARK: - Recovery Strategies
enum RecoveryStrategy {
    case retry(maxAttempts: Int)
    case fallback
    case cache
    case offline
    case userAction
    
    func execute<T>(
        operation: @escaping () async throws -> T,
        fallback: (() async throws -> T)? = nil
    ) async -> Result<T, AppError> {
        switch self {
        case .retry(let maxAttempts):
            return await ErrorRecoveryManager.shared.attemptWithRetry(
                operation: operation,
                maxAttempts: maxAttempts
            )
            
        case .fallback:
            guard let fallback = fallback else {
                return .failure(.unknown(NSError(domain: "Recovery", code: -1)))
            }
            return await ErrorRecoveryManager.shared.attemptWithFallback(
                primary: operation,
                fallback: fallback
            )
            
        case .cache, .offline, .userAction:
            // These require specific context - execute operation directly
            do {
                let result = try await operation()
                return .success(result)
            } catch {
                return .failure(AppError(from: error))
            }
        }
    }
}

// MARK: - View Model Recovery Extension
extension ObservableObject {
    func handleErrorWithRecovery(
        _ error: Error,
        context: String,
        onRecover: (() -> Void)? = nil,
        onFail: (() -> Void)? = nil
    ) {
        let appError = AppError(from: error)
        appError.log(context: context)
        
        // Notify UI
        ErrorHandler.shared.handle(appError, context: ErrorContext.general)
        
        // Attempt recovery if possible
        if appError.isRecoverable {
            onRecover?()
        } else {
            onFail?()
        }
    }
}

// MARK: - Result Extension for Recovery
extension Result {
    func recover(with fallback: Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return fallback
        }
    }
    
    func recoverWithAction(_ action: () -> Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return action()
        }
    }
}

// MARK: - Async Recovery Helpers
enum RecoveryHelpers {
    /// Retry an async operation with exponential backoff
    static func retryWithBackoff<T>(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                let isLastAttempt = attempt == maxAttempts - 1
                if isLastAttempt {
                    throw error
                }
                
                let delay = baseDelay * pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw lastError ?? NSError(domain: "Recovery", code: -1)
    }
    
    /// Execute with timeout
    static func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Add main operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NetworkError.timeout
            }
            
            // Return first completed (success or failure)
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    /// Circuit breaker pattern
    actor CircuitBreaker {
        private var failures = 0
        private var lastFailure: Date?
        private let threshold: Int
        private let resetTimeout: TimeInterval
        
        init(threshold: Int = 5, resetTimeout: TimeInterval = 60) {
            self.threshold = threshold
            self.resetTimeout = resetTimeout
        }
        
        func execute<T>(_ operation: () async throws -> T) async throws -> T {
            // Check if circuit is open
            if failures >= threshold {
                if let last = lastFailure,
                   Date().timeIntervalSince(last) < resetTimeout {
                    throw NetworkError.serverError(statusCode: 503)
                }
                // Reset after timeout
                failures = 0
            }
            
            do {
                let result = try await operation()
                failures = 0 // Reset on success
                return result
            } catch {
                failures += 1
                lastFailure = Date()
                throw error
            }
        }
    }
}
