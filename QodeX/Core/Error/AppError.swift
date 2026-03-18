//
//  AppError.swift
//  Comprehensive error types for QodeX
//

import Foundation

// MARK: - Main App Error Type
enum AppError: Error, LocalizedError, Equatable {
    case authentication(AuthError)
    case network(NetworkError)
    case firebase(FirebaseError)
    case validation(ValidationError)
    case subscription(SubscriptionError)
    case cache(CacheError)
    case permission(PermissionError)
    case unknown(Error)
    
    // MARK: - LocalizedError
    var errorDescription: String? {
        switch self {
        case .authentication(let error):
            return error.localizedDescription
        case .network(let error):
            return error.localizedDescription
        case .firebase(let error):
            return error.localizedDescription
        case .validation(let error):
            return error.localizedDescription
        case .subscription(let error):
            return error.localizedDescription
        case .cache(let error):
            return error.localizedDescription
        case .permission(let error):
            return error.localizedDescription
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User-Friendly Title
    var title: String {
        switch self {
        case .authentication:
            return "Authentication Error"
        case .network:
            return "Connection Issue"
        case .firebase:
            return "Server Error"
        case .validation:
            return "Invalid Input"
        case .subscription:
            return "Subscription Issue"
        case .cache:
            return "Data Issue"
        case .permission:
            return "Permission Required"
        case .unknown:
            return "Something Went Wrong"
        }
    }
    
    // MARK: - Recovery Suggestion
    var recoverySuggestion: String? {
        switch self {
        case .authentication(let error):
            return error.recoverySuggestion
        case .network(let error):
            return error.recoverySuggestion
        case .firebase(let error):
            return error.recoverySuggestion
        case .validation(let error):
            return error.recoverySuggestion
        case .subscription(let error):
            return error.recoverySuggestion
        case .cache(let error):
            return error.recoverySuggestion
        case .permission(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Please try again. If the problem persists, contact support."
        }
    }
    
    // MARK: - Is Recoverable
    var isRecoverable: Bool {
        switch self {
        case .authentication(let error):
            return error.isRecoverable
        case .network(let error):
            return error.isRecoverable
        case .firebase(let error):
            return error.isRecoverable
        case .validation:
            return true
        case .subscription(let error):
            return error.isRecoverable
        case .cache:
            return true
        case .permission:
            return true
        case .unknown:
            return false
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.authentication(let l), .authentication(let r)):
            return l == r
        case (.network(let l), .network(let r)):
            return l == r
        case (.firebase(let l), .firebase(let r)):
            return l == r
        case (.validation(let l), .validation(let r)):
            return l == r
        case (.subscription(let l), .subscription(let r)):
            return l == r
        case (.cache(let l), .cache(let r)):
            return l == r
        case (.permission(let l), .permission(let r)):
            return l == r
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError, Equatable {
    case invalidCredentials
    case sessionExpired
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case tooManyRequests
    case networkError
    case userCancelled
    case noRootViewController
    case noIdToken
    case invalidCredential
    case rateLimited
    case notAuthenticated
    case biometricFailed
    case biometricUnavailable
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .userNotFound:
            return "We couldn't find an account with that email."
        case .emailAlreadyInUse:
            return "An account already exists with this email."
        case .weakPassword:
            return "This password is too weak. Please use at least 8 characters with uppercase, lowercase, and numbers."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .networkError:
            return "Network error. Please check your connection."
        case .userCancelled:
            return "Sign in was cancelled."
        case .noRootViewController:
            return "Unable to present sign in screen."
        case .noIdToken:
            return "Unable to get authentication token."
        case .invalidCredential:
            return "Invalid authentication credentials."
        case .rateLimited:
            return "Too many attempts. Please wait a moment."
        case .notAuthenticated:
            return "You need to be signed in to access this feature."
        case .biometricFailed:
            return "Biometric authentication failed."
        case .biometricUnavailable:
            return "Biometric authentication is not available on this device."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Double-check your email and password, or reset your password if you've forgotten it."
        case .sessionExpired:
            return "Please sign in again to continue."
        case .userNotFound:
            return "Check your email address or create a new account."
        case .emailAlreadyInUse:
            return "Try signing in instead, or use a different email address."
        case .weakPassword:
            return "Add more variety to your password with special characters and numbers."
        case .invalidEmail:
            return "Check for typos in your email address."
        case .tooManyRequests, .rateLimited:
            return "Wait a few minutes before trying again."
        case .networkError:
            return "Check your internet connection and try again."
        case .userCancelled:
            return nil
        case .noRootViewController, .noIdToken, .invalidCredential:
            return "Please restart the app and try again."
        case .notAuthenticated:
            return "Sign in to your account to access this feature."
        case .biometricFailed:
            return "You can use your password instead."
        case .biometricUnavailable:
            return "Set up Face ID or Touch ID in Settings to use biometric authentication."
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .userCancelled:
            return false
        default:
            return true
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError, Equatable {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidURL
    case invalidResponse
    case decodingFailed
    case cancelled
    
    var localizedDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "The request timed out. Please try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Received invalid data from the server."
        case .decodingFailed:
            return "Failed to process server response."
        case .cancelled:
            return "Request was cancelled."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Check your Wi-Fi or cellular data connection and try again."
        case .timeout:
            return "Try again when you have a stronger connection."
        case .serverError:
            return "Our servers are experiencing issues. Please try again in a few minutes."
        case .invalidURL, .invalidResponse, .decodingFailed:
            return "Please try again. If the problem persists, update to the latest app version."
        case .cancelled:
            return nil
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .cancelled, .invalidURL:
            return false
        default:
            return true
        }
    }
}

// MARK: - Firebase Errors
enum FirebaseError: Error, LocalizedError, Equatable {
    case documentNotFound
    case invalidData
    case notAuthenticated
    case permissionDenied
    case quotaExceeded
    case offline
    case writeFailed
    case batchFailed
    case transactionFailed
    
    var localizedDescription: String {
        switch self {
        case .documentNotFound:
            return "The requested data could not be found."
        case .invalidData:
            return "The data format is invalid."
        case .notAuthenticated:
            return "You need to be signed in to access this data."
        case .permissionDenied:
            return "You don't have permission to access this."
        case .quotaExceeded:
            return "Usage limit exceeded. Please try again later."
        case .offline:
            return "You're offline. Some features may be limited."
        case .writeFailed:
            return "Failed to save your changes."
        case .batchFailed:
            return "Failed to process multiple items."
        case .transactionFailed:
            return "Transaction failed. Please try again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .documentNotFound:
            return "The item may have been deleted. Try refreshing the page."
        case .invalidData:
            return "Please restart the app and try again."
        case .notAuthenticated:
            return "Sign in to access this feature."
        case .permissionDenied:
            return "Contact support if you believe this is an error."
        case .quotaExceeded:
            return "Wait a few minutes and try again."
        case .offline:
            return "Connect to the internet to access all features."
        case .writeFailed, .batchFailed, .transactionFailed:
            return "Try again. If the problem persists, restart the app."
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .permissionDenied, .invalidData:
            return false
        default:
            return true
        }
    }
}

// MARK: - Validation Errors
enum ValidationError: Error, LocalizedError, Equatable {
    case emptyField(fieldName: String)
    case invalidEmail
    case invalidPassword
    case invalidDate
    case futureDate
    case tooOld
    case invalidName
    case invalidCharacter
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case invalidFormat
    case required
    case passwordsDontMatch
    case invalidPhoneNumber
    
    var localizedDescription: String {
        switch self {
        case .emptyField(let field):
            return "\(field) cannot be empty."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and number."
        case .invalidDate:
            return "Please enter a valid date."
        case .futureDate:
            return "Date cannot be in the future."
        case .tooOld:
            return "Please enter a more recent date."
        case .invalidName:
            return "Name can only contain letters and spaces."
        case .invalidCharacter:
            return "Contains invalid characters."
        case .tooShort(let min):
            return "Must be at least \(min) characters."
        case .tooLong(let max):
            return "Must be no more than \(max) characters."
        case .invalidFormat:
            return "Invalid format."
        case .required:
            return "This field is required."
        case .passwordsDontMatch:
            return "Passwords do not match."
        case .invalidPhoneNumber:
            return "Please enter a valid phone number."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyField:
            return "Please fill in this field."
        case .invalidEmail:
            return "Check for typos and make sure it includes @ and a domain."
        case .invalidPassword:
            return "Use a mix of uppercase, lowercase, numbers, and special characters."
        case .invalidDate, .futureDate, .tooOld:
            return "Enter a valid date in the past."
        case .invalidName:
            return "Use only letters, spaces, hyphens, and apostrophes."
        case .invalidCharacter:
            return "Remove any special characters."
        case .tooShort(let min):
            return "Add at least \(min) characters."
        case .tooLong(let max):
            return "Shorten your input to \(max) characters or less."
        case .invalidFormat:
            return "Check the required format and try again."
        case .required:
            return "Complete this field to continue."
        case .passwordsDontMatch:
            return "Make sure both password fields are identical."
        case .invalidPhoneNumber:
            return "Enter a valid phone number with country code."
        }
    }
    
    var isRecoverable: Bool {
        return true
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: Error, LocalizedError, Equatable {
    case purchaseFailed
    case restoreFailed
    case productNotFound
    case alreadyPurchased
    case paymentCancelled
    case paymentPending
    case invalidReceipt
    case serverVerificationFailed
    case userNotEligible
    case priceChangeDeclined
    case subscriptionExpired
    
    var localizedDescription: String {
        switch self {
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .restoreFailed:
            return "Failed to restore purchases."
        case .productNotFound:
            return "Subscription option not available."
        case .alreadyPurchased:
            return "You already have an active subscription."
        case .paymentCancelled:
            return "Purchase was cancelled."
        case .paymentPending:
            return "Payment is pending approval."
        case .invalidReceipt:
            return "Invalid purchase receipt."
        case .serverVerificationFailed:
            return "Failed to verify purchase with server."
        case .userNotEligible:
            return "You're not eligible for this offer."
        case .priceChangeDeclined:
            return "Price change was declined."
        case .subscriptionExpired:
            return "Your subscription has expired."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .purchaseFailed:
            return "Check your payment method and try again."
        case .restoreFailed:
            return "Make sure you're signed in with the same Apple ID used for purchase."
        case .productNotFound:
            return "This subscription tier may no longer be available."
        case .alreadyPurchased:
            return "Your subscription is already active."
        case .paymentCancelled:
            return nil
        case .paymentPending:
            return "Your payment is being processed. This may take a few minutes."
        case .invalidReceipt:
            return "Please try restoring purchases again."
        case .serverVerificationFailed:
            return "Try again in a few minutes. If the problem persists, contact support."
        case .userNotEligible:
            return "Check if you meet the requirements for this offer."
        case .priceChangeDeclined:
            return "Your subscription will remain at the current price."
        case .subscriptionExpired:
            return "Renew your subscription to continue accessing premium features."
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .paymentCancelled, .alreadyPurchased:
            return false
        default:
            return true
        }
    }
}

// MARK: - Cache Errors
enum CacheError: Error, LocalizedError, Equatable {
    case notFound
    case expired
    case writeFailed
    case readFailed
    case corrupted
    case storageFull
    
    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Cached data not found."
        case .expired:
            return "Cached data has expired."
        case .writeFailed:
            return "Failed to save data locally."
        case .readFailed:
            return "Failed to read cached data."
        case .corrupted:
            return "Cached data is corrupted."
        case .storageFull:
            return "Device storage is full."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notFound, .expired:
            return "Data will be fetched from the server."
        case .writeFailed:
            return "Check your device storage and try again."
        case .readFailed, .corrupted:
            return "Data will be refreshed from the server."
        case .storageFull:
            return "Free up some space on your device and try again."
        }
    }
    
    var isRecoverable: Bool {
        return true
    }
}

// MARK: - Permission Errors
enum PermissionError: Error, LocalizedError, Equatable {
    case notificationsDenied
    case cameraDenied
    case photosDenied
    case locationDenied
    case microphoneDenied
    case contactsDenied
    
    var localizedDescription: String {
        switch self {
        case .notificationsDenied:
            return "Notifications permission denied."
        case .cameraDenied:
            return "Camera permission denied."
        case .photosDenied:
            return "Photo library permission denied."
        case .locationDenied:
            return "Location permission denied."
        case .microphoneDenied:
            return "Microphone permission denied."
        case .contactsDenied:
            return "Contacts permission denied."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notificationsDenied:
            return "Enable notifications in Settings to receive reminders."
        case .cameraDenied:
            return "Enable camera access in Settings to take photos."
        case .photosDenied:
            return "Enable photo access in Settings to save images."
        case .locationDenied:
            return "Enable location in Settings for personalized features."
        case .microphoneDenied:
            return "Enable microphone access in Settings."
        case .contactsDenied:
            return "Enable contacts access in Settings to find friends."
        }
    }
    
    var isRecoverable: Bool {
        return true
    }
}

// MARK: - Error Context
enum ErrorContext {
    case authentication
    case network
    case firebase
    case validation
    case subscription
    case cache
    case permission
    case general
    
    var logPrefix: String {
        switch self {
        case .authentication: return "[AUTH]"
        case .network: return "[NETWORK]"
        case .firebase: return "[FIREBASE]"
        case .validation: return "[VALIDATION]"
        case .subscription: return "[SUBSCRIPTION]"
        case .cache: return "[CACHE]"
        case .permission: return "[PERMISSION]"
        case .general: return "[GENERAL]"
        }
    }
}

// MARK: - Error Conversion Extensions
extension AppError {
    init(from error: Error, context: ErrorContext = .general) {
        if let appError = error as? AppError {
            self = appError
        } else if let authError = error as? AuthError {
            self = .authentication(authError)
        } else if let networkError = error as? NetworkError {
            self = .network(networkError)
        } else if let firebaseError = error as? FirebaseError {
            self = .firebase(firebaseError)
        } else if let validationError = error as? ValidationError {
            self = .validation(validationError)
        } else if let subscriptionError = error as? SubscriptionError {
            self = .subscription(subscriptionError)
        } else {
            self = .unknown(error)
        }
    }
}

// MARK: - Firebase Auth Error Mapping
import FirebaseAuth

extension AuthError {
    static func from(_ error: NSError) -> AuthError {
        if let code = AuthErrorCode.Code(rawValue: error.code) {
            switch code {
            case .invalidEmail:
                return .invalidEmail
            case .wrongPassword:
                return .invalidCredentials
            case .userNotFound:
                return .userNotFound
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .weakPassword:
                return .weakPassword
            case .networkError:
                return .networkError
            case .tooManyRequests:
                return .tooManyRequests
            case .requiresRecentLogin:
                return .sessionExpired
            default:
                return .invalidCredentials
            }
        }
        return .invalidCredentials
    }
}

// MARK: - Error Logging
extension AppError {
    func log(context: String? = nil) {
        var message = "\(self.title): \(self.errorDescription ?? "Unknown error")"
        if let context = context {
            message = "[\(context)] \(message)"
        }
        print(message)
    }
}
