//
//  ErrorView.swift
//  Reusable error UI components for QodeX
//

import SwiftUI

// MARK: - Error View
struct ErrorView: View {
    let error: AppError
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onAction: ((RecoveryAction) -> Void)?
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            errorIcon
                .font(.system(size: 60))
                .foregroundColor(errorColor)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            
            // Title
            Text(error.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Message
            Text(error.errorDescription ?? "An unexpected error occurred.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Recovery suggestion
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action buttons
            actionButtons
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Error Icon
    @ViewBuilder
    private var errorIcon: some View {
        switch error {
        case .network:
            Image(systemName: "wifi.slash")
        case .authentication:
            Image(systemName: "lock.shield")
        case .firebase:
            Image(systemName: "server.rack")
        case .validation:
            Image(systemName: "exclamationmark.triangle")
        case .subscription:
            Image(systemName: "creditcard")
        case .cache:
            Image(systemName: "archivebox")
        case .permission:
            Image(systemName: "hand.raised")
        case .unknown:
            Image(systemName: "exclamationmark.circle")
        }
    }
    
    // MARK: - Error Color
    private var errorColor: Color {
        switch error {
        case .network:
            return .orange
        case .authentication:
            return .red
        case .firebase:
            return .purple
        case .validation:
            return .yellow
        case .subscription:
            return .blue
        case .cache:
            return .gray
        case .permission:
            return .orange
        case .unknown:
            return .red
        }
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary action (retry if recoverable)
            if error.isRecoverable, let onRetry = onRetry {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(errorColor)
                    .cornerRadius(12)
                }
            }
            
            // Recovery action button
            if let action = ErrorRecoveryManager.shared.getRecoveryAction(for: error) {
                Button(action: { onAction?(action) }) {
                    HStack {
                        Image(systemName: actionIcon(for: action))
                        Text(actionTitle(for: action))
                    }
                    .font(.subheadline)
                    .foregroundColor(errorColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(errorColor.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Dismiss button
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Action Helpers
    private func actionIcon(for action: RecoveryAction) -> String {
        switch action {
        case .signIn:
            return "person.fill"
        case .checkConnection:
            return "wifi"
        case .updateApp:
            return "arrow.down.app"
        case .contactSupport:
            return "envelope.fill"
        case .dismiss:
            return "xmark"
        }
    }
    
    private func actionTitle(for action: RecoveryAction) -> String {
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
}

// MARK: - Inline Error View
struct InlineErrorView: View {
    let message: String
    var onRetry: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String
    let type: BannerType
    var onDismiss: (() -> Void)?
    var onAction: (() -> Void)?
    var actionTitle: String?
    
    @State private var isVisible = false
    
    enum BannerType {
        case error
        case warning
        case info
        case success
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            case .success: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "exclamationmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(type.color)
                }
            }
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(type.color.opacity(0.1))
        .cornerRadius(12)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.3)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Full Screen Error
struct FullScreenErrorView: View {
    let error: AppError
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ErrorView(
                error: error,
                onRetry: onRetry,
                onDismiss: onDismiss
            )
        }
    }
}

// MARK: - Empty State with Error
struct EmptyStateErrorView: View {
    let title: String
    let message: String
    var icon: String = "exclamationmark.triangle"
    var onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Error View Modifier
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                error?.title ?? "Error",
                isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                ),
                presenting: error
            ) { error in
                if error.isRecoverable {
                    Button("Try Again") {
                        onRetry?()
                    }
                }
                
                if let action = ErrorRecoveryManager.shared.getRecoveryAction(for: error) {
                    Button(actionTitle(for: action)) {
                        // Handle action
                    }
                }
                
                Button("OK", role: .cancel) {
                    error = nil
                    onDismiss?()
                }
            } message: { error in
                Text(error.fullMessage)
            }
    }
    
    private func actionTitle(for action: RecoveryAction) -> String {
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
}

// MARK: - Loading Error State
struct LoadingErrorStateView: View {
    let error: AppError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ErrorView(
                error: error,
                onRetry: onRetry
            )
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - View Extensions
extension View {
    func errorAlert(error: Binding<AppError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(error: error, onRetry: onRetry))
    }
    
    func withErrorBanner(message: Binding<String?>, type: ErrorBanner.BannerType = .error) -> some View {
        self.overlay(alignment: .top) {
            if let msg = message.wrappedValue {
                ErrorBanner(
                    message: msg,
                    type: type,
                    onDismiss: { message.wrappedValue = nil }
                )
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Error Preview
#Preview {
    Group {
        // Network error
        ErrorView(
            error: .network(.noConnection),
            onRetry: {},
            onDismiss: {}
        )
        
        // Auth error
        ErrorView(
            error: .authentication(.invalidCredentials),
            onRetry: {},
            onDismiss: {}
        )
        
        // Inline error
        InlineErrorView(
            message: "Failed to load data. Please try again.",
            onRetry: {}
        )
        .padding()
        
        // Error banner
        ErrorBanner(
            message: "No internet connection",
            type: .error,
            onDismiss: {},
            onAction: {},
            actionTitle: "Retry"
        )
        .padding()
        
        // Empty state
        EmptyStateErrorView(
            title: "Something went wrong",
            message: "We couldn't load your data. Please check your connection and try again.",
            onRetry: {}
        )
    }
}
