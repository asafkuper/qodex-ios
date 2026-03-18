import Foundation
import OSLog

// MARK: - QodeX Error Domain

/// Comprehensive error types for the QodeX application
/// All errors are categorized by domain for better error handling and analytics
public enum QodeXError: Error, LocalizedError, Equatable {
    
    // MARK: - Network Errors
    
    case network(NetworkError)
    case authentication(AuthError)
    case validation(ValidationError)
    case calculation(CalculationError)
    case data(DataError)
    case storage(StorageError)
    case subscription(SubscriptionError)
    case unknown(String)
    
    // MARK: - Network Error Details
    
    public enum NetworkError: Equatable {
        case noConnection
        case timeout
        case serverError(Int)
        case invalidResponse
        case decodingFailed(String)
        case requestFailed(String)
        
        public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
            switch (lhs, rhs) {
            case (.noConnection, .noConnection),
                 (.timeout, .timeout),
                 (.invalidResponse, .invalidResponse):
                return true
            case let (.serverError(lhsCode), .serverError(rhsCode)):
                return lhsCode == rhsCode
            case let (.decodingFailed(lhsMsg), .decodingFailed(rhsMsg)):
                return lhsMsg == rhsMsg
            case let (.requestFailed(lhsMsg), .requestFailed(rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }
    
    // MARK: - Authentication Error Details
    
    public enum AuthError: Equatable {
        case invalidCredentials
        case sessionExpired
        case userNotFound
        case emailAlreadyInUse
        case weakPassword
        case tooManyRequests
        case notAuthenticated
        case biometryFailed(String)
        
        public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidCredentials, .invalidCredentials),
                 (.sessionExpired, .sessionExpired),
                 (.userNotFound, .userNotFound),
                 (.emailAlreadyInUse, .emailAlreadyInUse),
                 (.weakPassword, .weakPassword),
                 (.tooManyRequests, .tooManyRequests),
                 (.notAuthenticated, .notAuthenticated):
                return true
            case let (.biometryFailed(lhsMsg), .biometryFailed(rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }
    
    // MARK: - Validation Error Details
    
    public enum ValidationError: Equatable {
        case invalidName
        case invalidDate
        case invalidEmail
        case emptyField(String)
        case tooLong(String, Int)
        case tooShort(String, Int)
        case invalidFormat(String)
        
        public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidName, .invalidName),
                 (.invalidDate, .invalidDate),
                 (.invalidEmail, .invalidEmail):
                return true
            case let (.emptyField(lhsField), .emptyField(rhsField)):
                return lhsField == rhsField
            case let (.tooLong(lhsField, lhsLen), .tooLong(rhsField, rhsLen)):
                return lhsField == rhsField && lhsLen == rhsLen
            case let (.tooShort(lhsField, lhsLen), .tooShort(rhsField, rhsLen)):
                return lhsField == rhsField && lhsLen == rhsLen
            case let (.invalidFormat(lhsField), .invalidFormat(rhsField)):
                return lhsField == rhsField
            default:
                return false
            }
        }
    }
    
    // MARK: - Calculation Error Details
    
    public enum CalculationError: Equatable {
        case invalidBirthDate
        case invalidNameCharacters
        case calculationOverflow
        case unsupportedCalculation(String)
        
        public static func == (lhs: CalculationError, rhs: CalculationError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidBirthDate, .invalidBirthDate),
                 (.invalidNameCharacters, .invalidNameCharacters),
                 (.calculationOverflow, .calculationOverflow):
                return true
            case let (.unsupportedCalculation(lhsType), .unsupportedCalculation(rhsType)):
                return lhsType == rhsType
            default:
                return false
            }
        }
    }
    
    // MARK: - Data Error Details
    
    public enum DataError: Equatable {
        case notFound(String)
        case corrupted(String)
        case syncFailed(String)
        case invalidType(String)
        
        public static func == (lhs: DataError, rhs: DataError) -> Bool {
            switch (lhs, rhs) {
            case let (.notFound(lhsMsg), .notFound(rhsMsg)),
                 let (.corrupted(lhsMsg), .corrupted(rhsMsg)),
                 let (.syncFailed(lhsMsg), .syncFailed(rhsMsg)),
                 let (.invalidType(lhsMsg), .invalidType(rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }
    
    // MARK: - Storage Error Details
    
    public enum StorageError: Equatable {
        case saveFailed(String)
        case loadFailed(String)
        case deleteFailed(String)
        case insufficientSpace
        
        public static func == (lhs: StorageError, rhs: StorageError) -> Bool {
            switch (lhs, rhs) {
            case let (.saveFailed(lhsMsg), .saveFailed(rhsMsg)),
                 let (.loadFailed(lhsMsg), .loadFailed(rhsMsg)),
                 let (.deleteFailed(lhsMsg), .deleteFailed(rhsMsg)):
                return lhsMsg == rhsMsg
            case (.insufficientSpace, .insufficientSpace):
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Subscription Error Details
    
    public enum SubscriptionError: Equatable {
        case purchaseFailed(String)
        case restoreFailed(String)
        case productNotFound(String)
        case alreadySubscribed
        case receiptInvalid
        case userCancelled
        case paymentPending
        
        public static func == (lhs: SubscriptionError, rhs: SubscriptionError) -> Bool {
            switch (lhs, rhs) {
            case let (.purchaseFailed(lhsMsg), .purchaseFailed(rhsMsg)),
                 let (.restoreFailed(lhsMsg), .restoreFailed(rhsMsg)),
                 let (.productNotFound(lhsMsg), .productNotFound(rhsMsg)):
                return lhsMsg == rhsMsg
            case (.alreadySubscribed, .alreadySubscribed),
                 (.receiptInvalid, .receiptInvalid),
                 (.userCancelled, .userCancelled),
                 (.paymentPending, .paymentPending):
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .authentication(let error):
            return error.localizedDescription
        case .validation(let error):
            return error.localizedDescription
        case .calculation(let error):
            return error.localizedDescription
        case .data(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .subscription(let error):
            return error.localizedDescription
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .network(.noConnection):
            return "No internet connection available"
        case .network(.timeout):
            return "The request timed out"
        case .network(.serverError(let code)):
            return "Server returned error code \(code)"
        case .authentication(.sessionExpired):
            return "Your session has expired"
        case .validation(.invalidDate):
            return "The provided date is invalid"
        case .calculation(.invalidBirthDate):
            return "Birth date is outside valid range"
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .network(.noConnection):
            return "Please check your internet connection and try again"
        case .network(.timeout):
            return "Please try again when the network is more stable"
        case .authentication(.sessionExpired):
            return "Please sign in again to continue"
        case .validation(.invalidDate):
            return "Please enter a valid date between 1900 and today"
        case .subscription(.userCancelled):
            return "You can restart the purchase anytime"
        default:
            return "If the problem persists, please contact support"
        }
    }
}

// MARK: - Error Domain Localized Descriptions

extension QodeXError.NetworkError {
    var localizedDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error \(code)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed:
            return "Failed to process server data"
        case .requestFailed:
            return "Request failed"
        }
    }
}

extension QodeXError.AuthError {
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .sessionExpired:
            return "Session expired"
        case .userNotFound:
            return "Account not found"
        case .emailAlreadyInUse:
            return "Email already registered"
        case .weakPassword:
            return "Password is too weak"
        case .tooManyRequests:
            return "Too many attempts. Please try again later"
        case .notAuthenticated:
            return "Not signed in"
        case .biometryFailed:
            return "Biometric authentication failed"
        }
    }
}

extension QodeXError.ValidationError {
    var localizedDescription: String {
        switch self {
        case .invalidName:
            return "Invalid name format"
        case .invalidDate:
            return "Invalid date"
        case .invalidEmail:
            return "Invalid email address"
        case .emptyField(let field):
            return "\(field) cannot be empty"
        case .tooLong(let field, let max):
            return "\(field) must be less than \(max) characters"
        case .tooShort(let field, let min):
            return "\(field) must be at least \(min) characters"
        case .invalidFormat(let field):
            return "\(field) format is invalid"
        }
    }
}

extension QodeXError.CalculationError {
    var localizedDescription: String {
        switch self {
        case .invalidBirthDate:
            return "Invalid birth date"
        case .invalidNameCharacters:
            return "Name contains invalid characters"
        case .calculationOverflow:
            return "Calculation resulted in overflow"
        case .unsupportedCalculation(let type):
            return "Calculation type '\(type)' is not supported"
        }
    }
}

extension QodeXError.DataError {
    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Data not found"
        case .corrupted:
            return "Data is corrupted"
        case .syncFailed:
            return "Sync failed"
        case .invalidType:
            return "Invalid data type"
        }
    }
}

extension QodeXError.StorageError {
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .loadFailed:
            return "Failed to load data"
        case .deleteFailed:
            return "Failed to delete data"
        case .insufficientSpace:
            return "Insufficient storage space"
        }
    }
}

extension QodeXError.SubscriptionError {
    var localizedDescription: String {
        switch self {
        case .purchaseFailed:
            return "Purchase failed"
        case .restoreFailed:
            return "Failed to restore purchases"
        case .productNotFound:
            return "Product not available"
        case .alreadySubscribed:
            return "Already subscribed"
        case .receiptInvalid:
            return "Invalid purchase receipt"
        case .userCancelled:
            return "Purchase cancelled"
        case .paymentPending:
            return "Payment is pending approval"
        }
    }
}

// MARK: - Result Extensions

public extension Result where Failure == QodeXError {
    /// Returns true if the result is a success
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    /// Returns true if the result is a failure
    var isFailure: Bool {
        !isSuccess
    }
    
    /// Returns the success value if available
    var value: Success? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    /// Returns the error if available
    var error: QodeXError? {
        if case .failure(let error) = self { return error }
        return nil
    }
    
    /// Maps a Result with QodeXError to a different success type
    func map<T>(_ transform: (Success) -> T) -> Result<T, QodeXError> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Flat maps a Result with QodeXError
    func flatMap<T>(_ transform: (Success) -> Result<T, QodeXError>) -> Result<T, QodeXError> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Async Result Helpers

public extension Task where Failure == QodeXError {
    /// Converts a throwing Task to a Result
    static func result(operation: @escaping () async throws -> Success) async -> Result<Success, QodeXError> {
        do {
            let value = try await operation()
            return .success(value)
        } catch let error as QodeXError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
}

// MARK: - Error Mapping

public extension Error {
    /// Converts any Error to QodeXError
    func toQodeXError() -> QodeXError {
        if let qodeXError = self as? QodeXError {
            return qodeXError
        }
        return .unknown(self.localizedDescription)
    }
}