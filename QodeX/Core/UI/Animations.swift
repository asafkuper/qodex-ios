//
//  Animations.swift
//  QodeX Animation System - Premium Animation Presets
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Animation Presets
/// Consistent animation presets for the entire app
/// Following iOS 18 HIG: Use spring animations for natural, physical feel
enum QXAnimation {
    // MARK: - Standard Animations
    
    /// Quick spring for button presses and small interactions
    /// Response: 0.3s, Damping: 0.8 (snappy but smooth)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    
    /// Smooth ease in/out for state changes
    /// Duration: 0.2s (perceptible but not sluggish)
    static let easeInOut = Animation.easeInOut(duration: 0.2)
    
    /// Emphasis spring for important transitions
    /// Response: 0.4s, Damping: 0.7 (more bounce)
    static let emphasis = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    /// Zoom animation for focus transitions
    static let zoom = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    // MARK: - Specialized Animations
    
    /// Card entrance animation with stagger
    static let cardEntrance = Animation.spring(response: 0.5, dampingFraction: 0.75)
    
    /// Page transition animation
    static let pageTransition = Animation.spring(response: 0.4, dampingFraction: 0.85)
    
    /// Micro-interaction for toggles and switches
    static let micro = Animation.spring(response: 0.2, dampingFraction: 0.9)
    
    /// Slow reveal for content loading
    static let reveal = Animation.easeOut(duration: 0.5)
    
    /// Bounce for celebratory moments
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.5)
    
    /// Smooth scroll animation
    static let scroll = Animation.easeInOut(duration: 0.3)
    
    // MARK: - Accessibility Support
    
    /// Returns the appropriate animation based on accessibility settings
    static var accessible: Animation {
        // Check for reduced motion preference
        if UIAccessibility.isReduceMotionEnabled {
            return .easeInOut(duration: 0.1)
        }
        return spring
    }
    
    /// Wraps an animation with reduced motion support
    static func withAccessibility(_ animation: Animation) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? .easeInOut(duration: 0.1) : animation
    }
}

// MARK: - Animation Modifiers

extension View {
    /// Applies standard spring animation with accessibility support
    func animatedSpring() -> some View {
        self.animation(QXAnimation.spring, value: UUID())
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
    
    /// Press animation for buttons
    func pressAnimation() -> some View {
        self.modifier(PressModifier())
    }
    
    /// Bounce animation for attention
    func bounceAttention() -> some View {
        self.modifier(BounceAttentionModifier())
    }
    
    /// Pulse animation for live indicators
    func pulseAnimation() -> some View {
        self.modifier(PulseModifier())
    }
}

// MARK: - Animation Modifiers Implementation

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

struct PressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(QXAnimation.micro, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

struct BounceAttentionModifier: ViewModifier {
    @State private var bounce = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(bounce ? 1.05 : 1.0)
            .onAppear {
                withAnimation(QXAnimation.bounce.repeatCount(3, autoreverses: true)) {
                    bounce = true
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var pulse = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.1 : 1.0)
            .opacity(pulse ? 0.7 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

// MARK: - View Animation State Helpers

/// Tracks animation state for complex sequences
@MainActor
class AnimationState: ObservableObject {
    @Published var phase: AnimationPhase = .idle
    
    enum AnimationPhase: Equatable {
        case idle
        case entering
        case active
        case exiting
        case custom(String)
    }
    
    func transition(to newPhase: AnimationPhase, with animation: Animation = QXAnimation.spring) {
        withAnimation(animation) {
            phase = newPhase
        }
    }
}

// MARK: - Matched Geometry Effect Helpers

extension Namespace {
    /// Creates a consistent namespace for matched geometry effects
    static var shared = Namespace().wrappedValue
}

// MARK: - Preview

#Preview("Animation Examples") {
    VStack(spacing: 20) {
        Text("Fade In")
            .fadeIn(delay: 0)
        
        Text("Scale In")
            .scaleIn(delay: 0.1)
        
        Text("Slide Up")
            .slideUp(delay: 0.2)
        
        Button("Press Animation") {}
            .pressAnimation()
        
        Circle()
            .fill(Color.gold)
            .frame(width: 50, height: 50)
            .bounceAttention()
        
        Circle()
            .fill(Color.red)
            .frame(width: 20, height: 20)
            .pulseAnimation()
    }
    .padding()
    .background(Color.cosmicBlack)
}
