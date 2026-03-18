//
//  AccessibleMotion.swift
//  QodeX - Reduce Motion Support
//  Respects system accessibility settings for motion sensitivity
//

import SwiftUI

// MARK: - Reduce Motion Preference Key
/// Environment key for reduce motion preference
private struct ReduceMotionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var prefersReduceMotion: Bool {
        get { self[ReduceMotionKey.self] }
        set { self[ReduceMotionKey.self] = newValue }
    }
}

// MARK: - Motion Safe View
/// A view that conditionally applies animations based on Reduce Motion setting
public struct MotionSafeView<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let content: Content
    let animation: Animation?
    let value: Equatable
    
    public init(
        animation: Animation? = nil,
        value: some Equatable,
        @ViewBuilder content: () -> Content
    ) {
        self.animation = animation
        self.value = value
        self.content = content()
    }
    
    public var body: some View {
        if reduceMotion {
            content
        } else {
            content
                .animation(animation, value: value)
        }
    }
}

// MARK: - Static Number Reveal
/// A number reveal that respects Reduce Motion - shows instantly when enabled
public struct AccessibleNumberReveal: View {
    let number: Int
    let title: String
    let color: Color
    let duration: Double
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayNumber: Int = 0
    @State private var isRevealed = false
    
    public init(
        number: Int,
        title: String,
        color: Color = QXColor.gold,
        duration: Double = 1.5
    ) {
        self.number = number
        self.title = title
        self.color = color
        self.duration = duration
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("\(displayNumber)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .onAppear {
                    if reduceMotion {
                        // Instant reveal for reduce motion
                        displayNumber = number
                        isRevealed = true
                        // Announce to VoiceOver
                        VoiceOver.announce("Your \(title) is \(number)")
                    } else {
                        // Animated reveal
                        animateNumber()
                    }
                }
            
            Text(title)
                .font(.headline)
                .foregroundColor(QXColor.starlight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) Number \(number)")
    }
    
    private func animateNumber() {
        let steps = 20
        let stepDuration = duration / Double(steps)
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            
            if currentStep >= steps {
                displayNumber = number
                timer.invalidate()
                isRevealed = true
                VoiceOver.announce("Your \(title) is \(number)")
            } else {
                displayNumber = Int.random(in: 1...33)
            }
        }
    }
}

// MARK: - Static Breathing Glow
/// A breathing glow effect that becomes static when Reduce Motion is enabled
public struct AccessibleBreathingGlow: View {
    let color: Color
    let intensity: Double
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3
    
    public init(
        color: Color = QXColor.gold,
        intensity: Double = 0.5
    ) {
        self.color = color
        self.intensity = intensity
    }
    
    public var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(reduceMotion ? intensity : opacity),
                        color.opacity(0),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 140
                )
            )
            .frame(width: 280, height: 280)
            .blur(radius: 20)
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .onAppear {
                guard !reduceMotion else { return }
                
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    scale = 1.15
                    opacity = intensity
                }
            }
    }
}

// MARK: - Static Parallax
/// A parallax effect that becomes static when Reduce Motion is enabled
public struct AccessibleParallax<Content: View>: View {
    let scrollOffset: CGFloat
    let factor: CGFloat
    @ViewBuilder let content: Content
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        scrollOffset: CGFloat,
        factor: CGFloat = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.scrollOffset = scrollOffset
        self.factor = factor
        self.content = content()
    }
    
    public var body: some View {
        content
            .offset(y: reduceMotion ? 0 : scrollOffset * factor)
    }
}

// MARK: - Instant Transition
/// A transition that becomes instant when Reduce Motion is enabled
public struct AccessibleTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let transition: AnyTransition
    let animation: Animation?
    
    public func body(content: Content) -> some View {
        content
            .transition(reduceMotion ? .opacity : transition)
            .animation(reduceMotion ? nil : animation)
    }
}

// MARK: - Reduced Motion Stagger
/// A stagger animation that applies instantly when Reduce Motion is enabled
public struct AccessibleStagger: ViewModifier {
    let index: Int
    let delay: Double
    let show: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: reduceMotion || show ? 0 : 20)
            .animation(
                reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * delay),
                value: show
            )
    }
}

// MARK: - View Extensions for Reduce Motion
extension View {
    /// Applies animation only when Reduce Motion is disabled
    public func animationIfNotReduced(_ animation: Animation?, value: some Equatable) -> some View {
        self.modifier(MotionSafeAnimationModifier(animation: animation, value: value))
    }
    
    /// Applies transition only when Reduce Motion is disabled
    public func transitionIfNotReduced(_ transition: AnyTransition) -> some View {
        self.modifier(MotionSafeTransitionModifier(transition: transition))
    }
}

struct MotionSafeAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation?
    let value: Equatable
    
    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.animation(animation, value: value)
        }
    }
}

struct MotionSafeTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let transition: AnyTransition
    
    func body(content: Content) -> some View {
        content.transition(reduceMotion ? .opacity : transition)
    }
}

// MARK: - VoiceOver Helper
public enum VoiceOver {
    /// Announces a message through VoiceOver
    public static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Posts a layout changed notification
    public static func layoutChanged(element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
    
    /// Posts a screen changed notification
    public static func screenChanged(element: Any? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: element)
    }
    
    /// Returns whether VoiceOver is running
    public static var isRunning: Bool {
        return UIAccessibility.isVoiceOverRunning
    }
}

// MARK: - High Contrast Support
/// View modifier for high contrast mode support
public struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    let baseBackground: Color
    let baseForeground: Color
    let isButton: Bool
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(enhancedForeground)
            .background(isButton && showButtonShapes ? enhancedBackground : baseBackground)
            .overlay(
                Group {
                    if showButtonShapes && isButton {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(enhancedForeground, lineWidth: 2)
                    }
                }
            )
    }
    
    private var enhancedForeground: Color {
        if colorSchemeContrast == .increased {
            return baseForeground.opacity(1.0)
        }
        return baseForeground
    }
    
    private var enhancedBackground: Color {
        if colorSchemeContrast == .increased {
            return baseBackground.opacity(1.0)
        }
        return baseBackground
    }
}

extension View {
    /// Applies high contrast enhancements
    public func highContrastSupport(
        background: Color = .clear,
        foreground: Color = .primary,
        isButton: Bool = false
    ) -> some View {
        self.modifier(HighContrastModifier(
            baseBackground: background,
            baseForeground: foreground,
            isButton: isButton
        ))
    }
}

// MARK: - Color Blind Friendly Palette
/// Color definitions that work for various color vision deficiencies
public enum AccessibleColor {
    /// Gold that remains distinguishable for most color blind users
    public static let gold = Color(hex: "D4AF37") // Distinct yellow-gold
    
    /// Purple that works for protanopia/deuteranopia
    public static let purple = Color(hex: "6B4EE6") // Blue-purple
    
    /// Blue that is distinct from purple
    public static let blue = Color(hex: "2E7DE8") // Clear blue
    
    /// Green with good contrast
    public static let green = Color(hex: "2E7D32") // Dark green
    
    /// Red-orange for warnings (distinct from green)
    public static let warning = Color(hex: "E65100") // Orange-red
    
    /// Error red with distinct hue
    public static let error = Color(hex: "C62828") // Deep red
    
    /// Success green with icon pattern
    public static let success = Color(hex: "1B5E20") // Dark green
    
    /// Neutral gray
    public static let neutral = Color(hex: "757575")
    
    /// High contrast black
    public static let highContrastDark = Color(hex: "000000")
    
    /// High contrast white
    public static let highContrastLight = Color(hex: "FFFFFF")
}

// MARK: - Color Blind Friendly Indicators
/// Use icons + colors instead of colors alone
public struct AccessibleIndicator: View {
    public enum IndicatorType {
        case success
        case warning
        case error
        case info
        case neutral
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            case .info: return "info.circle.fill"
            case .neutral: return "circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return AccessibleColor.success
            case .warning: return AccessibleColor.warning
            case .error: return AccessibleColor.error
            case .info: return AccessibleColor.blue
            case .neutral: return AccessibleColor.neutral
            }
        }
        
        var label: String {
            switch self {
            case .success: return "Success"
            case .warning: return "Warning"
            case .error: return "Error"
            case .info: return "Information"
            case .neutral: return "Neutral"
            }
        }
    }
    
    let type: IndicatorType
    let size: CGFloat
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(type: IndicatorType, size: CGFloat = 20) {
        self.type = type
        self.size = size
    }
    
    public var body: some View {
        Image(systemName: type.icon)
            .font(.system(size: size * dynamicTypeSize.scale))
            .foregroundColor(type.color)
            .accessibilityLabel(type.label)
    }
}

// MARK: - Pattern Overlay for Charts
/// Pattern overlays to distinguish data series without relying solely on color
public struct AccessiblePattern: View {
    public enum PatternType {
        case solid
        case striped
        case dotted
        case checkered
        case diagonal
        
        var pattern: Image {
            switch self {
            case .solid: return Image(systemName: "square.fill")
            case .striped: return Image(systemName: "line.horizontal.3")
            case .dotted: return Image(systemName: "circle.fill")
            case .checkered: return Image(systemName: "grid")
            case .diagonal: return Image(systemName: "line.diagonal")
            }
        }
    }
    
    let pattern: PatternType
    let color: Color
    
    public var body: some View {
        pattern.pattern
            .foregroundColor(color)
    }
}

// MARK: - Preview
#Preview("Accessible Motion") {
    VStack(spacing: 30) {
        AccessibleNumberReveal(
            number: 7,
            title: "Life Path",
            color: QXColor.gold
        )
        
        AccessibleBreathingGlow(color: QXColor.gold, intensity: 0.5)
            .frame(height: 100)
        
        HStack(spacing: 20) {
            AccessibleIndicator(type: .success, size: 30)
            AccessibleIndicator(type: .warning, size: 30)
            AccessibleIndicator(type: .error, size: 30)
            AccessibleIndicator(type: .info, size: 30)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
