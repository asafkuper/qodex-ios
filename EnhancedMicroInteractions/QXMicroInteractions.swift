//
//  QXMicroInteractions.swift
//  QodeX Premium Micro-Interactions System
//  Reference: Apple Design Awards 2024, iOS 18 HIG
//

import SwiftUI

// MARK: - Button Press States
/// Comprehensive button press states with haptic feedback
public struct QXPressableButton<Content: View>: View {
    let content: Content
    let hapticStyle: QXHaptic.FeedbackType
    let scale: CGFloat
    let brightness: Double
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        hapticStyle: QXHaptic.FeedbackType = .medium,
        scale: CGFloat = 0.95,
        brightness: Double = -0.05,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.hapticStyle = hapticStyle
        self.scale = scale
        self.brightness = brightness
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .brightness(isPressed ? brightness : 0)
            .animation(QXPremiumSpring.snap, value: isPressed)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = pressing
                    }
                    if pressing {
                        QXHaptic.trigger(hapticStyle)
                    }
                },
                perform: {}
            )
            .onTapGesture {
                action()
            }
    }
}

// MARK: - Premium Button Styles with Micro-interactions
public struct QXMicroButtonStyle: ButtonStyle {
    public enum Variant {
        case primary
        case secondary
        case glass
        case ghost
        case danger
    }
    
    let variant: Variant
    let haptic: QXHaptic.FeedbackType
    
    public init(variant: Variant = .primary, haptic: QXHaptic.FeedbackType = .medium) {
        self.variant = variant
        self.haptic = haptic
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(QXPremiumSpring.snap, value: configuration.isPressed)
            .background(backgroundView)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    QXHaptic.trigger(haptic)
                }
            }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: QXColor.gold.opacity(0.3),
                    radius: 15,
                    x: 0,
                    y: 8
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(QXColor.starlight.opacity(0.2), lineWidth: 1)
                )
        case .glass:
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        case .ghost:
            EmptyView()
        case .danger:
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.error.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(QXColor.error.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Card Selection States
public struct QXSelectableCard<Content: View>: View {
    let content: Content
    let isSelected: Bool
    let selectionColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        isSelected: Bool,
        selectionColor: Color = QXColor.gold,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.selectionColor = selectionColor
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? selectionColor.opacity(0.15) : QXColor.deepVoid)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? selectionColor : QXColor.starlight.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? selectionColor.opacity(0.2) : .clear,
                        radius: 15,
                        x: 0,
                        y: 5
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(QXPremiumSpring.snap, value: isPressed)
            .animation(QXPremiumSpring.silky, value: isSelected)
            .onTapGesture {
                QXHaptic.cardSelection()
                action()
            }
            .pressGesture { pressing in
                isPressed = pressing
            }
    }
}

// MARK: - Hover/Press Gesture
struct PressGestureModifier: ViewModifier {
    let onPressingChanged: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    onPressingChanged(pressing)
                },
                perform: {}
            )
    }
}

public extension View {
    func pressGesture(onPressingChanged: @escaping (Bool) -> Void) -> some View {
        modifier(PressGestureModifier(onPressingChanged: onPressingChanged))
    }
}

// MARK: - Shake Effect for Errors
public struct ShakeEffect: ViewModifier {
    @State private var shakes = 0
    @Binding var trigger: Bool
    
    public init(trigger: Binding<Bool>) {
        self._trigger = trigger
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(shakes) * 3)
            .onChange(of: trigger) { _, shouldShake in
                if shouldShake {
                    QXHaptic.error()
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                        shakes = 5
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            shakes = 0
                        }
                        trigger = false
                    }
                }
            }
    }
}

public extension View {
    func shake(trigger: Binding<Bool>) -> some View {
        modifier(ShakeEffect(trigger: trigger))
    }
}

// MARK: - Ripple Effect
public struct RippleEffect: ViewModifier {
    @State private var ripples: [Ripple] = []
    let color: Color
    
    struct Ripple: Identifiable {
        let id = UUID()
        var scale: CGFloat = 0.5
        var opacity: Double = 0.6
    }
    
    public init(color: Color = QXColor.gold) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(color.opacity(ripple.opacity), lineWidth: 2)
                    .scaleEffect(ripple.scale)
            }
        }
        .onTapGesture {
            createRipple()
        }
    }
    
    private func createRipple() {
        var ripple = Ripple()
        ripples.append(ripple)
        
        withAnimation(.easeOut(duration: 0.6)) {
            ripple.scale = 2.5
            ripple.opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

// MARK: - Magnetic Button Effect
public struct MagneticButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    let strength: CGFloat
    
    @State private var offset: CGSize = .zero
    @State private var isPressed = false
    
    public init(strength: CGFloat = 15, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.strength = strength
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        content
            .offset(offset)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let limitedX = min(max(value.translation.width / 3, -strength), strength)
                        let limitedY = min(max(value.translation.height / 3, -strength), strength)
                        offset = CGSize(width: limitedX, height: limitedY)
                    }
                    .onEnded { _ in
                        withAnimation(QXPremiumSpring.elasticBounce) {
                            offset = .zero
                        }
                    }
            )
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                    if pressing {
                        QXHaptic.lightImpact()
                    }
                },
                perform: {}
            )
            .onTapGesture {
                action()
            }
    }
}

// MARK: - Bouncy Button
public struct QXBouncyButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            // Bounce animation
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                scale = 0.8
                rotation = -5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.0
                    rotation = 0
                }
            }
            
            QXHaptic.mediumImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [QXColor.gold, QXColor.goldGlow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .shadow(
                color: QXColor.gold.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Interactive Card Stack
public struct QXCardStack<Content: View>: View {
    let cards: [Content]
    @State private var offsets: [CGSize]
    @State private var rotations: [Double]
    
    public init(cards: [Content]) {
        self.cards = cards
        _offsets = State(initialValue: Array(repeating: .zero, count: cards.count))
        _rotations = State(initialValue: Array(repeating: 0, count: cards.count))
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<cards.count, id: \.self) { index in
                cards[index]
                    .offset(offsets[index])
                    .rotationEffect(.degrees(rotations[index]))
                    .zIndex(Double(cards.count - index))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard index == 0 else { return }
                                offsets[index] = value.translation
                                rotations[index] = Double(value.translation.width / 20)
                            }
                            .onEnded { value in
                                guard index == 0 else { return }
                                let threshold: CGFloat = 100
                                
                                if abs(value.translation.width) > threshold {
                                    // Swipe away
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        offsets[index].width = value.translation.width > 0 ? 500 : -500
                                    }
                                    QXHaptic.swipeSuccess()
                                } else {
                                    // Return to center
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        offsets[index] = .zero
                                        rotations[index] = 0
                                    }
                                }
                            }
                    )
            }
        }
    }
}

// MARK: - Preview
#Preview("Micro-Interactions") {
    VStack(spacing: 24) {
        // Pressable button
        QXPressableButton(hapticStyle: .medium) {
            print("Pressed")
        } content: {
            Text("Press Me")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        
        // Bouncy button
        QXBouncyButton(title: "Bounce", icon: "star.fill") {
            print("Bounced")
        }
        
        // Selectable card
        QXSelectableCard(isSelected: true, action: {}) {
            VStack(alignment: .leading) {
                Text("Selected Card")
                    .font(.headline)
                Text("Tap to toggle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        // Magnetic button
        MagneticButton(strength: 20) {
            print("Magnetic")
        } content: {
            Text("Magnetic")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
        }
    }
    .padding()
    .background(QXColor.cosmicBlack)
}
