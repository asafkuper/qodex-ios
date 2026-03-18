//
//  View+Extensions.swift
//  QodeX SwiftUI View Extensions - Premium Edition
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Layout Constants

enum Layout {
    static let padding: CGFloat = 16
    static let paddingLarge: CGFloat = 20
    static let paddingSmall: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 8
    static let spacing: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let spacingSmall: CGFloat = 8
    static let iconSize: CGFloat = 24
    static let iconSizeLarge: CGFloat = 32
    static let avatarSize: CGFloat = 40
    static let avatarSizeLarge: CGFloat = 60
}

// MARK: - View Extensions

extension View {
    /// Applies standard card styling with glass effect
    func cardStyle() -> some View {
        self
            .padding(Layout.padding)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                    .fill(QXColor.deepVoid.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                            .stroke(QXColor.starlight.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    /// Applies gold border for featured/premium content
    func goldBorder() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                    .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
            )
    }
    
    /// Standard button press effect with haptic
    func pressable() -> some View {
        self
            .scaleEffect(1.0)
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    QXHaptic.lightImpact()
                }
            )
    }
    
    /// Fade in animation with configurable delay
    func fadeIn(delay: Double = 0, duration: Double = 0.3) -> some View {
        self.modifier(FadeInModifier(delay: delay, duration: duration))
    }
    
    /// Scale entrance animation
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }
    
    /// Slide up entrance animation
    func slideUp(delay: Double = 0) -> some View {
        self.modifier(SlideUpModifier(delay: delay))
    }
    
    /// Staggered animation for lists
    func staggered(index: Int, baseDelay: Double = 0.05) -> some View {
        self.modifier(StaggeredModifier(index: index, baseDelay: baseDelay))
    }
    
    /// Applies modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies modifier based on optional value
    @ViewBuilder
    func ifLet<Value, Transform: View>(
        _ value: Value?,
        transform: (Self, Value) -> Transform
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    /// Applies a modifier with an optional value using a closure
    func applyIf<T>(
        _ value: T?,
        _ closure: (Self, T) -> some View
    ) -> some View {
        if let value = value {
            return AnyView(closure(self, value))
        }
        return AnyView(self)
    }
}

// MARK: - Animation Modifiers

struct FadeInModifier: ViewModifier {
    let delay: Double
    let duration: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(QXAnimation.withAccessibility(.easeOut(duration: duration)).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(QXAnimation.withAccessibility(.spring(response: 0.4, dampingFraction: 0.7)).delay(delay)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

struct SlideUpModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 30
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(QXAnimation.withAccessibility(.spring(response: 0.4, dampingFraction: 0.8)).delay(delay)) {
                    offset = 0
                    opacity = 1.0
                }
            }
    }
}

struct StaggeredModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(QXAnimation.withAccessibility(.spring(response: 0.4, dampingFraction: 0.8)).delay(Double(index) * baseDelay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if active {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                Color.white.opacity(0.15),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                phase = 1
                            }
                        }
                    }
                }
                .mask(content)
            )
    }
}

extension View {
    func shimmering(active: Bool) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(QXColor.cosmicBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [QXColor.gold, QXColor.goldGlow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Layout.cornerRadiusLarge)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(QXColor.starlight)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                    .fill(QXColor.deepVoid)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                            .stroke(QXColor.starlight.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(QXColor.gold)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(QXColor.gold.opacity(configuration.isPressed ? 0.2 : 0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
}

// MARK: - Text Styles

extension Text {
    func titleStyle() -> some View {
        self
            .font(QXFont.title1)
            .foregroundStyle(QXColor.starlight)
    }
    
    func headlineStyle() -> some View {
        self
            .font(QXFont.headline)
            .foregroundStyle(QXColor.starlight)
    }
    
    func bodyStyle() -> some View {
        self
            .font(QXFont.body)
            .foregroundStyle(QXColor.stardust)
    }
    
    func captionStyle() -> some View {
        self
            .font(QXFont.caption1)
            .foregroundStyle(QXColor.stardust)
    }
}

// MARK: - Device Utilities

enum Device {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }
    
    static var isSmallDevice: Bool {
        UIScreen.main.bounds.height <= 667 // iPhone SE, 8, etc.
    }
}

// MARK: - Keyboard Handling

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func keyboardAdaptive() -> some View {
        self
            .padding(.bottom, KeyboardObserver.shared.keyboardHeight)
            .animation(.easeOut(duration: 0.16), value: KeyboardObserver.shared.keyboardHeight)
    }
}

@MainActor
class KeyboardObserver: ObservableObject {
    static let shared = KeyboardObserver()
    
    @Published var keyboardHeight: CGFloat = 0
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
    }
}

// MARK: - Safe Area

extension View {
    /// Ignores safe area on all edges
    func fullScreen() -> some View {
        self.ignoresSafeArea(.all)
    }
    
    /// Adds safe area padding
    func safeAreaPadding() -> some View {
        self.padding(.top, Device.hasNotch ? 44 : 20)
            .padding(.bottom, Device.hasNotch ? 34 : 20)
    }
}

// MARK: - Preview Helpers

struct PreviewContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview("View Extensions") {
    VStack(spacing: 20) {
        Text("Card Style")
            .cardStyle()
        
        Button("Primary Button") {}
            .buttonStyle(.primary)
        
        Button("Secondary Button") {}
            .buttonStyle(.secondary)
        
        Button("Ghost Button") {}
            .buttonStyle(.ghost)
        
        Text("Fade In")
            .fadeIn(delay: 0)
        
        Text("Scale In")
            .scaleIn(delay: 0.1)
        
        Text("Slide Up")
            .slideUp(delay: 0.2)
    }
    .padding()
    .background(QXColor.cosmicBlack)
}
