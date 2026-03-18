//
//  ErrorStateView.swift
//  QodeX Premium Error States
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Error Types

enum QXError: LocalizedError, Equatable {
    case networkError
    case serverError
    case authenticationError
    case notFound
    case rateLimit
    case offline
    case validationError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Connection Issue"
        case .serverError:
            return "Server Error"
        case .authenticationError:
            return "Authentication Required"
        case .notFound:
            return "Not Found"
        case .rateLimit:
            return "Too Many Requests"
        case .offline:
            return "You're Offline"
        case .validationError:
            return "Validation Error"
        case .unknown:
            return "Something Went Wrong"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "Our servers are experiencing issues. Please try again in a moment."
        case .authenticationError:
            return "Please sign in again to continue."
        case .notFound:
            return "The content you're looking for doesn't exist or has been removed."
        case .rateLimit:
            return "You've made too many requests. Please wait a moment before trying again."
        case .offline:
            return "Check your connection and try again. Your cosmic insights are waiting."
        case .validationError(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
    
    var icon: String {
        switch self {
        case .networkError, .offline:
            return "wifi.slash"
        case .serverError:
            return "server.rack"
        case .authenticationError:
            return "lock.shield"
        case .notFound:
            return "magnifyingglass"
        case .rateLimit:
            return "hourglass"
        case .validationError:
            return "exclamationmark.circle"
        case .unknown:
            return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .networkError, .offline:
            return QXColor.gold
        case .serverError:
            return QXColor.cosmicTeal
        case .authenticationError:
            return QXColor.mysticPurple
        case .notFound:
            return QXColor.starlight
        case .rateLimit:
            return QXColor.goldMuted
        case .validationError:
            return .orange
        case .unknown:
            return .red
        }
    }
}

// MARK: - Premium Error State View

struct PremiumErrorStateView: View {
    let error: Error
    let retry: (() -> Void)?
    let dismiss: (() -> Void)?
    
    @State private var isAnimating = false
    @State private var showDetails = false
    
    init(error: Error, retry: (() -> Void)? = nil, dismiss: (() -> Void)? = nil) {
        self.error = error
        self.retry = retry
        self.dismiss = dismiss
    }
    
    private var qxError: QXError {
        if let error = error as? QXError {
            return error
        }
        // Convert generic errors
        let nsError = error as NSError
        switch nsError.code {
        case -1009, -1001:
            return .offline
        case 401:
            return .authenticationError
        case 404:
            return .notFound
        case 429:
            return .rateLimit
        case 500...599:
            return .serverError
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated illustration
            errorIllustration
                .padding(.bottom, 8)
            
            // Error title
            Text(qxError.errorDescription ?? "Error")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(QXColor.starlight)
            
            // Recovery suggestion
            Text(qxError.recoverySuggestion ?? "An unexpected error occurred.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(QXColor.starlight.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            // Error details (expandable)
            if showDetails {
                Text(error.localizedDescription)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(QXColor.starlight.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Action buttons
            VStack(spacing: 12) {
                if let retry = retry {
                    Button(action: {
                        QXHaptic.mediumImpact()
                        retry()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(QXColor.cosmicBlack)
                        .frame(width: 220, height: 52)
                        .background(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(26)
                    }
                    .pressAnimation()
                }
                
                if let dismiss = dismiss {
                    Button(action: {
                        QXHaptic.lightImpact()
                        dismiss()
                    }) {
                        Text("Dismiss")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(QXColor.starlight.opacity(0.8))
                            .frame(width: 220, height: 48)
                    }
                }
                
                // Show details button
                Button(action: {
                    withAnimation(.spring()) {
                        showDetails.toggle()
                    }
                }) {
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                }
                .padding(.top, 8)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QXColor.cosmicBlack.ignoresSafeArea())
        .onAppear {
            isAnimating = true
            QXHaptic.error()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(qxError.errorDescription ?? ""). \(qxError.recoverySuggestion ?? "")")
    }
    
    // MARK: - Error Illustration
    
    @ViewBuilder
    private var errorIllustration: some View {
        ZStack {
            // Background pulse
            Circle()
                .fill(qxError.color.opacity(0.1))
                .frame(width: 140, height: 140)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .opacity(isAnimating ? 0.5 : 0.3)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            // Secondary pulse
            Circle()
                .fill(qxError.color.opacity(0.15))
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .opacity(isAnimating ? 0.4 : 0.2)
                .animation(.easeInOut(duration: 2).delay(0.3).repeatForever(autoreverses: true), value: isAnimating)
            
            // Icon
            ZStack {
                Circle()
                    .fill(QXColor.deepVoid)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(qxError.color.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: qxError.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(qxError.color)
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            // Decorative elements
            ForEach(0..<3) { i in
                Circle()
                    .fill(qxError.color.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .offset(
                        x: cos(Double(i) * .pi * 2 / 3) * 60,
                        y: sin(Double(i) * .pi * 2 / 3) * 60
                    )
                    .scaleEffect(isAnimating ? [1.2, 0.8, 1.0][i] : [0.8, 1.2, 0.9][i])
                    .opacity(isAnimating ? [0.6, 0.3, 0.5][i] : [0.3, 0.6, 0.4][i])
                    .animation(
                        .easeInOut(duration: 1.5)
                            .delay(Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
}

// MARK: - Inline Error View

struct InlineErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(QXColor.starlight)
                
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(QXColor.starlight.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            if let onRetry = onRetry {
                Button(action: {
                    QXHaptic.lightImpact()
                    onRetry()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(QXColor.gold)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -10)
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
        }
    }
}

// MARK: - Toast Error

struct ErrorToast: View {
    let message: String
    let onDismiss: (() -> Void)?
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.red)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(QXColor.starlight)
            
            Spacer()
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.red.opacity(0.1), radius: 10, x: 0, y: 4)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring()) {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss?()
                }
            }
        }
    }
}

// MARK: - Error Boundary View

struct ErrorBoundaryView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @State private var caughtError: Error?
    
    var body: some View {
        ZStack {
            content()
            
            if let error = caughtError {
                PremiumErrorStateView(
                    error: error,
                    retry: {
                        caughtError = nil
                    },
                    dismiss: {
                        caughtError = nil
                    }
                )
                .transition(.blurFade)
            }
        }
    }
    
    func catchError(_ error: Error) {
        caughtError = error
    }
}

// MARK: - View Extensions

extension View {
    /// Shows error state when condition is true
    func errorState(_ error: Binding<Error?>, onRetry: @escaping () -> Void) -> some View {
        self.modifier(ErrorStateModifier(error: error, onRetry: onRetry))
    }
    
    /// Shows inline error when condition is true
    func inlineError(_ message: String?, onRetry: (() -> Void)? = nil) -> some View {
        self.overlay(
            Group {
                if let message = message {
                    VStack {
                        InlineErrorView(message: message, onRetry: onRetry)
                            .padding()
                        Spacer()
                    }
                }
            }
        )
    }
}

struct ErrorStateModifier: ViewModifier {
    @Binding var error: Error?
    let onRetry: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let error = error {
                PremiumErrorStateView(
                    error: error,
                    retry: {
                        self.error = nil
                        onRetry()
                    },
                    dismiss: {
                        self.error = nil
                    }
                )
                .transition(.blurFade)
            }
        }
    }
}

// MARK: - Preview

#Preview("Error States") {
    TabView {
        PremiumErrorStateView(error: QXError.networkError, retry: {}, dismiss: {})
            .tabItem { Text("Network") }
        
        PremiumErrorStateView(error: QXError.offline, retry: {}, dismiss: {})
            .tabItem { Text("Offline") }
        
        PremiumErrorStateView(error: QXError.serverError, retry: {}, dismiss: {})
            .tabItem { Text("Server") }
        
        PremiumErrorStateView(error: QXError.authenticationError, retry: {}, dismiss: {})
            .tabItem { Text("Auth") }
        
        PremiumErrorStateView(error: QXError.unknown("Something unexpected happened"), retry: {}, dismiss: {})
            .tabItem { Text("Unknown") }
    }
    .preferredColorScheme(.dark)
}

#Preview("Inline Error") {
    VStack {
        InlineErrorView(message: "Failed to load content. Please check your connection.", onRetry: {})
            .padding()
        
        ErrorToast(message: "Network error occurred", onDismiss: {})
            .padding()
        
        Spacer()
    }
    .background(QXColor.cosmicBlack)
}
