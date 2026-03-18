//
//  MicroInteractions.swift
//  Polished micro-interactions for QodeX
//

import SwiftUI

// MARK: - Button Interactions
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    var opacity: Double = 0.8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Haptic Feedback System
enum HapticStyle {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    
    func trigger() {
        let generator: UIFeedbackGenerator
        
        switch self {
        case .light:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        case .success:
            generator = UINotificationFeedbackGenerator()
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.success)
            return
        case .warning:
            generator = UINotificationFeedbackGenerator()
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.warning)
            return
        case .error:
            generator = UINotificationFeedbackGenerator()
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.error)
            return
        case .selection:
            generator = UISelectionFeedbackGenerator()
        }
        
        generator.prepare()
        if let impact = generator as? UIImpactFeedbackGenerator {
            impact.impactOccurred()
        } else if let selection = generator as? UISelectionFeedbackGenerator {
            selection.selectionChanged()
        }
    }
}

// MARK: - Card Interactions
struct HoverScaleModifier: ViewModifier {
    @State private var isHovered = false
    var scale: CGFloat = 1.02
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct LiftEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isPressed ? 2 : 0)
            .shadow(
                color: Color.black.opacity(isPressed ? 0.1 : 0.2),
                radius: isPressed ? 2 : 8,
                x: 0,
                y: isPressed ? 1 : 4
            )
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Number Counter Animation
struct AnimatedNumberCounter: View {
    let number: Int
    @State private var displayNumber: Int = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Text("\(displayNumber)")
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .foregroundColor(.gold)
            .scaleEffect(scale)
            .onAppear {
                animateNumber()
            }
            .onChange(of: number) { _ in
                animateNumber()
            }
    }
    
    private func animateNumber() {
        // Count up animation
        let steps = 20
        let stepDuration = 0.02
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * stepDuration)) {
                displayNumber = (number * i) / steps
                
                // Pulse effect at end
                if i == steps {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            scale = 1.0
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Staggered List Animation
struct StaggeredList<Content: View>: View {
    let content: Content
    let staggerDelay: Double
    
    init(staggerDelay: Double = 0.05, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.staggerDelay = staggerDelay
    }
    
    var body: some View {
        content
            .modifier(StaggeredAnimationModifier(delay: staggerDelay))
    }
}

struct StaggeredAnimationModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Success Checkmark Animation
struct SuccessCheckmark: View {
    @State private var drawProgress: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gold, lineWidth: 3)
                .frame(width: 60, height: 60)
            
            CheckmarkShape()
                .trim(from: 0, to: drawProgress)
                .stroke(Color.gold, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: 30, height: 30)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                drawProgress = 1.0
            }
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.25))
        
        return path
    }
}

// MARK: - View Extensions
extension View {
    func pressable(scale: CGFloat = 0.95) -> some View {
        buttonStyle(PressableButtonStyle(scale: scale))
    }
    
    func springPress() -> some View {
        buttonStyle(SpringButtonStyle())
    }
    
    func hoverScale(_ scale: CGFloat = 1.02) -> some View {
        modifier(HoverScaleModifier(scale: scale))
    }
    
    func liftEffect() -> some View {
        modifier(LiftEffect())
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
