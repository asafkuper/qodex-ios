//
//  ErrorHandler.swift
//  Global error handling and presentation - Updated for comprehensive error system
//

import SwiftUI
import Combine

// MARK: - Global Error Handler
@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showError = false
    @Published var isRecovering = false
    
    private init() {}
    
    // MARK: - Error Handling
    func handle(_ error: Error, context: ErrorContext = .general) {
        let appError = AppError(from: error)
        
        // Log the error
        logError(appError, context: context)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentError = appError
            self?.showError = true
        }
        
        // Attempt recovery if possible
        if appError.isRecoverable {
            attemptRecovery(for: appError, context: context)
        }
    }
    
    func handleWithRetry(
        _ error: Error,
        context: ErrorContext = .general,
        retryAction: @escaping () async -> Void
    ) {
        let appError = AppError(from: error)
        
        logError(appError, context: context)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentError = appError
            self?.showError = true
        }
        
        // Auto-retry for recoverable errors
        if appError.isRecoverable {
            Task {
                await attemptRecoveryWithRetry(for: appError, retryAction: retryAction)
            }
        }
    }
    
    func clear() {
        currentError = nil
        showError = false
        isRecovering = false
    }
    
    // MARK: - Error Logging
    private func logError(_ error: AppError, context: ErrorContext) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let message = "[\(timestamp)] \(context.logPrefix) \(error.title): \(error.errorDescription ?? "Unknown error")"
        
        // Console logging
        print(message)
        
        // Analytics logging for critical errors
        if case .firebase = error {
            AnalyticsManager.shared.logError(error, context: context.logPrefix)
        }
    }
    
    // MARK: - Recovery
    private func attemptRecovery(for error: AppError, context: ErrorContext) {
        guard let recoveryAction = ErrorRecoveryManager.shared.getRecoveryAction(for: error) else {
            return
        }
        
        switch recoveryAction {
        case .checkConnection:
            // Network recovery handled by NetworkMonitor
            break
        case .signIn:
            // Auth recovery handled by auth coordinator
            break
        default:
            break
        }
    }
    
    private func attemptRecoveryWithRetry(
        for error: AppError,
        retryAction: () async -> Void
    ) async {
        isRecovering = true
        defer { isRecovering = false }
        
        // Wait a moment before retry
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await retryAction()
    }
    
    // MARK: - User Feedback
    func getErrorDisplayInfo() -> ErrorDisplayInfo? {
        guard let error = currentError else { return nil }
        return ErrorRecoveryManager.shared.getUserFriendlyMessage(for: error)
    }
}

// MARK: - Legacy App Error (for backwards compatibility)
struct LegacyAppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let context: LegacyErrorContext
    let isRecoverable: Bool
    let retryAction: (() -> Void)?
    
    init(from error: Error, context: LegacyErrorContext, retryAction: (() -> Void)? = nil) {
        self.context = context
        self.retryAction = retryAction
        
        // Convert to new AppError for consistent messaging
        let appError = AppError(from: error)
        self.title = appError.title
        self.message = appError.errorDescription ?? "An unexpected error occurred"
        self.isRecoverable = appError.isRecoverable
    }
    
    var fullMessage: String {
        if let suggestion = AppError(from: LegacyError()).recoverySuggestion {
            return "\(message)\n\n\(suggestion)"
        }
        return message
    }
}

// Legacy placeholder
struct LegacyError: Error {}

enum LegacyErrorContext {
    case network
    case auth
    case firebase
    case purchase
    case general
}

// MARK: - Error Alert View Modifier (Updated)
struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler = ErrorHandler.shared
    var onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.title ?? "Error",
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { error in
                if error.isRecoverable {
                    Button("Try Again") {
                        onRetry?()
                        errorHandler.clear()
                    }
                }
                
                if let action = ErrorRecoveryManager.shared.getRecoveryAction(for: error) {
                    Button(recoveryActionTitle(for: action)) {
                        handleRecoveryAction(action)
                    }
                }
                
                Button("OK", role: .cancel) {
                    errorHandler.clear()
                }
            } message: { error in
                Text(error.fullMessage)
            }
    }
    
    private func recoveryActionTitle(for action: RecoveryAction) -> String {
        switch action {
        case .signIn:
            return "Sign In"
        case .checkConnection:
            return "Check Connection"
        case .updateApp:
            return "Update App"
        case .contactSupport:
            return "Contact Support"
        case .dismiss:
            return "Dismiss"
        }
    }
    
    private func handleRecoveryAction(_ action: RecoveryAction) {
        switch action {
        case .signIn:
            // Trigger sign-in flow
            NotificationCenter.default.post(name: .init("ShowSignIn"), object: nil)
        case .checkConnection:
            // Network check handled automatically
            break
        case .updateApp:
            if let url = URL(string: "https://apps.apple.com/app/qodex") {
                UIApplication.shared.open(url)
            }
        case .contactSupport:
            if let url = URL(string: "mailto:support@qodex.app") {
                UIApplication.shared.open(url)
            }
        case .dismiss:
            errorHandler.clear()
        }
    }
}

// MARK: - Network Monitor (Updated)
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else {
                    self?.connectionType = .unknown
                }
                
                // Trigger recovery if connection restored
                if !wasConnected && (self?.isConnected ?? false) {
                    NotificationCenter.default.post(name: .networkRestored, object: nil)
                }
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Offline Banner (Updated)
struct OfflineBanner: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @State private var showRetry = false
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                
                Text("No internet connection")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showRetry {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .transition(.move(edge: .top))
            .accessibilityLabel("No internet connection")
            .accessibilityHint("Some features may not work without internet")
            .onAppear {
                showRetry = true
                // Auto-hide retry after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showRetry = false
                }
            }
        }
    }
}

// MARK: - Result Extension
extension Result {
    func handleError(context: ErrorContext, retry: (() -> Void)? = nil) {
        if case .failure(let error) = self {
            ErrorHandler.shared.handle(error, context: context)
        }
    }
}

// MARK: - Async Error Handling
func withErrorHandling(
    context: ErrorContext,
    retry: (() -> Void)? = nil,
    action: @escaping () async throws -> Void
) async {
    do {
        try await action()
    } catch {
        await MainActor.run {
            ErrorHandler.shared.handle(error, context: context)
        }
    }
}

// MARK: - View Extensions
extension View {
    func withErrorHandling(onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlert(onRetry: onRetry))
    }
    
    func withOfflineBanner() -> some View {
        self.overlay(alignment: .top) {
            OfflineBanner()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let networkRestored = Notification.Name("NetworkRestored")
    static let shouldShowSignIn = Notification.Name("ShouldShowSignIn")
}
