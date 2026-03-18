//
//  BiometricAuth.swift
//  Biometric authentication for sensitive operations
//

import LocalAuthentication
import Foundation

/// Biometric authentication manager for secure operations
enum BiometricAuth {
    
    // MARK: - Authentication Types
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            }
        }
    }
    
    // MARK: - Authentication Results
    
    enum AuthenticationResult {
        case success
        case failure(Error)
        case cancelled
        
        var isSuccess: Bool {
            if case .success = self { return true }
            return false
        }
    }
    
    // MARK: - Check Availability
    
    /// Check if biometric authentication is available on this device
    static var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Get the type of biometric authentication available
    static var availableType: BiometricType {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    /// Check if passcode fallback is available
    static var isPasscodeAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    // MARK: - Authentication
    
    /// Authenticate using biometrics with optional passcode fallback
    /// - Parameters:
    ///   - reason: Localized reason for authentication
    ///   - fallbackToPasscode: Whether to allow device passcode as fallback
    /// - Returns: True if authentication succeeded
    static func authenticate(reason: String, fallbackToPasscode: Bool = true) async throws -> Bool {
        let context = LAContext()
        
        // Configure authentication
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = fallbackToPasscode ? "Use Passcode" : nil
        
        let policy: LAPolicy = fallbackToPasscode
            ? .deviceOwnerAuthentication
            : .deviceOwnerAuthenticationWithBiometrics
        
        var error: NSError?
        guard context.canEvaluatePolicy(policy, error: &error) else {
            if let laError = error as? LAError {
                throw mapLAError(laError)
            }
            throw AuthError.biometricUnavailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                policy,
                localizedReason: reason
            )
            return success
        } catch let laError as LAError {
            throw mapLAError(laError)
        } catch {
            throw AuthError.biometricFailed
        }
    }
    
    /// Authenticate for a specific sensitive operation
    static func authenticateForOperation(_ operation: SensitiveOperation) async throws -> Bool {
        return try await authenticate(
            reason: operation.localizedReason,
            fallbackToPasscode: operation.allowPasscodeFallback
        )
    }
    
    // MARK: - Error Mapping
    
    private static func mapLAError(_ error: LAError) -> AuthError {
        switch error.code {
        case .authenticationFailed:
            return .biometricFailed
        case .userCancel, .systemCancel:
            return .userCancelled
        case .biometryNotAvailable:
            return .biometricUnavailable
        case .biometryNotEnrolled:
            return .biometricUnavailable
        case .biometryLockout:
            return .tooManyRequests
        case .passcodeNotSet:
            return .biometricUnavailable
        case .invalidContext:
            return .unknown(error)
        case .notInteractive:
            return .unknown(error)
        @unknown default:
            return .unknown(error)
        }
    }
}

// MARK: - Sensitive Operations

enum SensitiveOperation {
    case viewPrivateKey
    case exportData
    case deleteAccount
    case changePassword
    case authorizePayment
    case accessPremiumFeatures
    case viewPersonalBlueprint
    
    var localizedReason: String {
        switch self {
        case .viewPrivateKey:
            return "Authenticate to view your private key"
        case .exportData:
            return "Authenticate to export your personal data"
        case .deleteAccount:
            return "Authenticate to permanently delete your account"
        case .changePassword:
            return "Authenticate to change your password"
        case .authorizePayment:
            return "Authenticate to authorize this payment"
        case .accessPremiumFeatures:
            return "Authenticate to access premium features"
        case .viewPersonalBlueprint:
            return "Authenticate to view your personal blueprint"
        }
    }
    
    var allowPasscodeFallback: Bool {
        switch self {
        case .viewPrivateKey, .deleteAccount:
            return false // Require biometrics for high-security operations
        default:
            return true
        }
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

/// View modifier for biometric-protected content
struct BiometricProtectedViewModifier: ViewModifier {
    let operation: SensitiveOperation
    let onAuthenticated: () -> Void
    
    @State private var showAuthentication = false
    @State private var errorMessage: String?
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                showAuthentication = true
            }
            .sheet(isPresented: $showAuthentication) {
                BiometricAuthView(operation: operation) { result in
                    switch result {
                    case .success:
                        onAuthenticated()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    case .cancelled:
                        break
                    }
                    showAuthentication = false
                }
            }
    }
}

/// Biometric authentication overlay view
struct BiometricAuthView: View {
    let operation: SensitiveOperation
    let onComplete: (BiometricAuth.AuthenticationResult) -> Void
    
    @State private var isAuthenticating = false
    @State private var error: Error?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Biometric icon
            Image(systemName: biometricIcon)
                .font(.system(size: 80))
                .foregroundColor(.gold)
            
            VStack(spacing: 16) {
                Text("Authentication Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(operation.localizedReason)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: authenticate) {
                    HStack {
                        Image(systemName: biometricIcon)
                        Text("Authenticate with \(BiometricAuth.availableType.displayName)")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gold)
                    .cornerRadius(12)
                }
                .disabled(isAuthenticating)
                
                if operation.allowPasscodeFallback {
                    Button("Use Passcode") {
                        authenticateWithPasscode()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Button("Cancel") {
                    onComplete(.cancelled)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 34)
        }
        .onAppear {
            // Auto-authenticate on appear
            authenticate()
        }
    }
    
    private var biometricIcon: String {
        switch BiometricAuth.availableType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "lock.fill"
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        error = nil
        
        Task {
            do {
                let success = try await BiometricAuth.authenticateForOperation(operation)
                await MainActor.run {
                    isAuthenticating = false
                    if success {
                        onComplete(.success)
                    } else {
                        onComplete(.failure(AuthError.biometricFailed))
                    }
                }
            } catch {
                await MainActor.run {
                    isAuthenticating = false
                    self.error = error
                }
            }
        }
    }
    
    private func authenticateWithPasscode() {
        Task {
            do {
                let success = try await BiometricAuth.authenticate(
                    reason: operation.localizedReason,
                    fallbackToPasscode: true
                )
                await MainActor.run {
                    if success {
                        onComplete(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Protect this view with biometric authentication
    func biometricProtected(
        for operation: SensitiveOperation,
        onAuthenticated: @escaping () -> Void
    ) -> some View {
        modifier(BiometricProtectedViewModifier(
            operation: operation,
            onAuthenticated: onAuthenticated
        ))
    }
}

// MARK: - Secure Action Wrapper

/// Wrapper for actions that require biometric authentication
struct SecureAction {
    let operation: SensitiveOperation
    let action: () -> Void
    
    func execute() async {
        do {
            let authenticated = try await BiometricAuth.authenticateForOperation(operation)
            if authenticated {
                await MainActor.run {
                    action()
                }
            }
        } catch {
            print("Authentication failed: \(error)")
        }
    }
}
