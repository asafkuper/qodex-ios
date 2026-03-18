//
//  QXToastNotifications.swift
//  QodeX Toast Notification System
//  Reference: iOS 18 Design, Things 3, Bear App
//

import SwiftUI
import Combine

// MARK: - Toast Types
public enum QXToastType {
    case success
    case error
    case warning
    case info
    case loading
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .loading: return "arrow.clockwise"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return QXColor.success
        case .error: return QXColor.error
        case .warning: return QXColor.warning
        case .info: return QXColor.nebulaBlue
        case .loading: return QXColor.gold
        }
    }
    
    var haptic: QXHaptic.FeedbackType {
        switch self {
        case .success: return .success
        case .error: return .error
        case .warning: return .warning
        case .info: return .light
        case .loading: return .light
        }
    }
}

// MARK: - Toast Model
public struct QXToast: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let type: QXToastType
    public let duration: TimeInterval
    public let action: (() -> Void)?
    public let actionTitle: String?
    
    public init(
        title: String,
        message: String? = nil,
        type: QXToastType = .info,
        duration: TimeInterval = 3.0,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.duration = duration
        self.action = action
        self.actionTitle = actionTitle
    }
    
    public static func == (lhs: QXToast, rhs: QXToast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Manager
@MainActor
public class QXToastManager: ObservableObject {
    public static let shared = QXToastManager()
    
    @Published public var toasts: [QXToast] = []
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {}
    
    public func show(
        title: String,
        message: String? = nil,
        type: QXToastType = .info,
        duration: TimeInterval = 3.0,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        let toast = QXToast(
            title: title,
            message: message,
            type: type,
            duration: duration,
            action: action,
            actionTitle: actionTitle
        )
        
        QXHaptic.trigger(type.haptic)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toasts.append(toast)
        }
        
        // Auto dismiss
        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.dismiss(toast)
            }
        }
    }
    
    public func dismiss(_ toast: QXToast) {
        guard let index = toasts.firstIndex(where: { $0.id == toast.id }) else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toasts.remove(at: index)
        }
    }
    
    // Convenience methods
    public func success(_ title: String, message: String? = nil) {
        show(title: title, message: message, type: .success)
    }
    
    public func error(_ title: String, message: String? = nil) {
        show(title: title, message: message, type: .error)
    }
    
    public func warning(_ title: String, message: String? = nil) {
        show(title: title, message: message, type: .warning)
    }
    
    public func info(_ title: String, message: String? = nil) {
        show(title: title, message: message, type: .info)
    }
    
    public func loading(_ title: String) -> QXToast {
        let toast = QXToast(title: title, type: .loading, duration: 0)
        show(toast: toast)
        return toast
    }
    
    private func show(toast: QXToast) {
        QXHaptic.trigger(toast.type.haptic)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toasts.append(toast)
        }
    }
}

// MARK: - Toast View
public struct QXToastView: View {
    let toast: QXToast
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0
    @State private var progress: CGFloat = 1.0
    @State private var isPaused = false
    
    private let toastHeight: CGFloat = 64
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(toast.type.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: toast.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(toast.type.color)
                    .rotationEffect(.degrees(toast.type == .loading ? 360 : 0))
                    .animation(
                        toast.type == .loading 
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: toast.type == .loading
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                if let message = toast.message {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Action button
            if let actionTitle = toast.actionTitle, let action = toast.action {
                Button(actionTitle) {
                    action()
                    onDismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(toast.type.color)
            }
            
            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                toast.type.color.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                // Progress bar (for timed toasts)
                if toast.duration > 0 {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(toast.type.color.opacity(0.5))
                            .frame(width: geo.size.width * progress, height: 3)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        )
        .shadow(
            color: toast.type.color.opacity(0.2),
            radius: 20,
            x: 0,
            y: 10
        )
        .offset(y: isVisible ? 0 : -100)
        .offset(x: dragOffset)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.9)
        .rotationEffect(.degrees(Double(dragOffset) / 20))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                    isPaused = true
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    if abs(value.translation.width) > threshold {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = value.translation.width > 0 ? 500 : -500
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                        isPaused = false
                    }
                }
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isVisible = true
            }
            
            // Start progress animation
            if toast.duration > 0 {
                animateProgress()
            }
        }
    }
    
    private func animateProgress() {
        guard !isPaused else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateProgress()
            }
            return
        }
        
        withAnimation(.linear(duration: 0.05)) {
            progress -= 0.05 / toast.duration
        }
        
        if progress > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animateProgress()
            }
        }
    }
}

// MARK: - Toast Container
public struct QXToastContainer: View {
    @StateObject private var manager = QXToastManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack {
            ForEach(manager.toasts) { toast in
                QXToastView(toast: toast) {
                    manager.dismiss(toast)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.toasts)
        .allowsHitTesting(!manager.toasts.isEmpty)
    }
}

// MARK: - Toast View Modifier
public struct ToastModifier: ViewModifier {
    @StateObject private var manager = QXToastManager.shared
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                ForEach(manager.toasts) { toast in
                    QXToastView(toast: toast) {
                        manager.dismiss(toast)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.toasts)
        }
    }
}

public extension View {
    func withToasts() -> some View {
        modifier(ToastModifier())
    }
}

// MARK: - Banner Toast (for top of screen)
public struct QXBannerToast: View {
    let title: String
    let message: String?
    let type: QXToastType
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: type.icon)
                .font(.system(size: 24))
                .foregroundColor(type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                if let message = message {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(QXColor.deepVoid)
                .overlay(
                    Rectangle()
                        .fill(type.color)
                        .frame(height: 3),
                    alignment: .top
                )
        )
        .offset(y: isVisible ? 0 : -200)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Preview
#Preview("Toast Notifications") {
    VStack(spacing: 20) {
        Button("Show Success") {
            QXToastManager.shared.success("Saved Successfully", message: "Your changes have been saved")
        }
        
        Button("Show Error") {
            QXToastManager.shared.error("Connection Failed", message: "Please check your internet connection")
        }
        
        Button("Show Warning") {
            QXToastManager.shared.warning("Storage Almost Full", message: "You have 500MB remaining")
        }
        
        Button("Show Info") {
            QXToastManager.shared.info("New Update Available", message: "Version 2.0 is ready to download")
        }
        
        Button("Show Custom") {
            QXToastManager.shared.show(
                title: "Custom Action",
                message: "This toast has an action button",
                type: .info,
                action: { print("Action tapped") },
                actionTitle: "Undo"
            )
        }
    }
    .padding()
    .background(QXColor.cosmicBlack)
    .withToasts()
}
