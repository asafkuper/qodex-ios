//
//  AnimationTokens.swift
//  Comprehensive animation design system for QodeX
//  References: Apple Motion Guidelines, Material Design Motion
//

import SwiftUI

// MARK: - Animation Curves
enum QXAnimationCurve {
    // Sacred/Esoteric timing (Fibonacci-based)
    case sacredEase      // Custom bezier with golden ratio influence
    case cosmicBounce    // Elastic with spiritual feel
    case celestialFloat  // Smooth floating motion
    case mysticalReveal  // Dramatic entrance
    case quantumSnap     // Quick snap with anticipation
    
    var timing: Animation {
        switch self {
        case .sacredEase:
            return .timingCurve(0.618, 0, 0.236, 1, duration: 0.6)
        case .cosmicBounce:
            return .interpolatingSpring(stiffness: 100, damping: 8)
        case .celestialFloat:
            return .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        case .mysticalReveal:
            return .timingCurve(0.16, 1, 0.3, 1, duration: 0.8)
        case .quantumSnap:
            return .timingCurve(0.68, -0.55, 0.265, 1.55, duration: 0.4)
        }
    }
}

// MARK: - Animation Durations
enum QXDuration {
    static let instant: Double = 0.1      // Micro-interactions
    static let quick: Double = 0.2        // Button taps, toggles
    static let standard: Double = 0.3     // Transitions, reveals
    static let emphasis: Double = 0.5     // Important changes
    static let dramatic: Double = 0.8     // Onboarding, celebrations
    static let ambient: Double = 3.0      // Background animations
    static let eternal: Double = 8.0      // Meditation, cosmic cycles
}

// MARK: - Animation Modifiers
struct AnimatedNumberModifier: ViewModifier {
    let value: Int
    @State private var displayValue: Int = 0
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        Text("\(displayValue)")
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .scaleEffect(scale)
            .onAppear {
                animateNumber()
            }
            .onChange(of: value) { _ in
                animateNumber()
            }
    }
    
    private func animateNumber() {
        // Count up animation
        let steps = min(value, 30) // Max 30 steps for performance
        let stepDuration = QXDuration.standard / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                let progress = Double(i) / Double(steps)
                displayValue = Int(Double(value) * progress)
                
                // Pulse on significant numbers
                if i == steps || displayValue == 7 || displayValue == 11 {
                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 10)) {
                        scale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scale = 1.0
                    }
                }
            }
        }
    }
}

struct GlowPulseModifier: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? intensity : intensity * 0.3),
                radius: isGlowing ? 20 : 10,
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

struct MagneticButtonModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Magnetic attraction to center
                        let translation = value.translation
                        let distance = sqrt(translation.width * translation.width + translation.height * translation.height)
                        let maxDistance: CGFloat = 30
                        
                        if distance > 0 {
                            let scale = min(distance, maxDistance) / distance
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = CGSize(
                                    width: translation.width * scale * 0.3,
                                    height: translation.height * scale * 0.3
                                )
                            }
                        }
                        isPressed = true
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            offset = .zero
                            isPressed = false
                        }
                    }
            )
    }
}

struct StaggeredRevealModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                let delay = baseDelay + Double(index) * 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(QXAnimationCurve.mysticalReveal.timing) {
                        isVisible = true
                    }
                }
            }
    }
}

struct BreathingModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let duration: Double
    let minScale: CGFloat
    let maxScale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    scale = maxScale
                }
            }
            .onDisappear {
                scale = minScale
            }
    }
}

// MARK: - View Extensions
extension View {
    func animatedNumber(_ value: Int) -> some View {
        modifier(AnimatedNumberModifier(value: value))
    }
    
    func glowPulse(color: Color = .gold, intensity: Double = 0.8) -> some View {
        modifier(GlowPulseModifier(color: color, intensity: intensity))
    }
    
    func magnetic() -> some View {
        modifier(MagneticButtonModifier())
    }
    
    func staggeredReveal(index: Int, baseDelay: Double = 0) -> some View {
        modifier(StaggeredRevealModifier(index: index, baseDelay: baseDelay))
    }
    
    func breathing(duration: Double = 4.0, minScale: CGFloat = 1.0, maxScale: CGFloat = 1.05) -> some View {
        modifier(BreathingModifier(duration: duration, minScale: minScale, maxScale: maxScale))
    }
    
    func sacredTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .scale(scale: 0.8, anchor: .center)
                    .combined(with: .opacity)
                    .animation(QXAnimationCurve.mysticalReveal.timing),
                removal: .scale(scale: 1.1)
                    .combined(with: .opacity)
                    .animation(.easeOut(duration: 0.2))
            )
        )
    }
}

// MARK: - Advanced Button Styles
struct SacredButtonStyle: ButtonStyle {
    let color: Color
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Ripple effect
            Circle()
                .fill(color.opacity(rippleOpacity))
                .scaleEffect(rippleScale)
                .frame(width: 20, height: 20)
            
            // Button content
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .shadow(
                            color: color.opacity(isPressed ? 0.2 : 0.4),
                            radius: isPressed ? 4 : 8,
                            x: 0,
                            y: isPressed ? 2 : 4
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .onChange(of: configuration.isPressed) { pressed in
                    if pressed {
                        triggerRipple()
                    }
                }
        }
    }
    
    private func triggerRipple() {
        withAnimation(.easeOut(duration: 0.4)) {
            rippleScale = 4
            rippleOpacity = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.2)) {
                rippleOpacity = 0
            }
            rippleScale = 0
        }
    }
}

struct CrystalButtonStyle: ButtonStyle {
    let gradient: Gradient
    @State private var rotation: Double = 0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Animated gradient border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            AngularGradient(
                                gradient: gradient,
                                center: .center,
                                angle: .degrees(rotation)
                            ),
                            lineWidth: 2
                        )
                    
                    // Glass fill
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Loading Animations
struct SacredGeometryLoader: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Outer hexagon
            Hexagon()
                .stroke(Color.gold.opacity(0.6), lineWidth: 2)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))
            
            // Inner hexagon
            Hexagon()
                .stroke(Color.gold, lineWidth: 2)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-rotation * 0.5))
            
            // Center dot
            Circle()
                .fill(Color.gold)
                .frame(width: 8, height: 8)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.5
            }
        }
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 2
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview("Animation Tokens") {
    ScrollView {
        VStack(spacing: 40) {
            // Animated Number
            Text("Animated Number")
                .font(.headline)
            Text("7")
                .animatedNumber(7)
            
            // Glow Pulse
            Text("Glow Pulse")
                .font(.headline)
            Circle()
                .fill(Color.gold)
                .frame(width: 50, height: 50)
                .glowPulse()
            
            // Magnetic Button
            Text("Magnetic Button")
                .font(.headline)
            Button("Tap Me") {}
                .buttonStyle(SacredButtonStyle(color: .gold))
                .magnetic()
            
            // Crystal Button
            Text("Crystal Button")
                .font(.headline)
            Button("Enter") {}
                .buttonStyle(CrystalButtonStyle(gradient: Gradient(colors: [.gold, .purple, .blue])))
            
            // Staggered Items
            Text("Staggered Reveal")
                .font(.headline)
            VStack(spacing: 8) {
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gold.opacity(0.3))
                        .frame(height: 40)
                        .staggeredReveal(index: i)
                }
            }
            
            // Breathing
            Text("Breathing")
                .font(.headline)
            Circle()
                .fill(Color.purple.opacity(0.5))
                .frame(width: 80, height: 80)
                .breathing(duration: 4, minScale: 1.0, maxScale: 1.2)
            
            // Loader
            Text("Sacred Loader")
                .font(.headline)
            SacredGeometryLoader()
        }
        .padding()
    }
}
