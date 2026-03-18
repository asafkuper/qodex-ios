//
//  QXPremiumAnimations.swift
//  QodeX Premium Animation System
//  Reference: Apple Design Awards 2024, iOS 18 HIG
//

import SwiftUI

// MARK: - Premium Spring Library
/// Custom-tuned springs that feel uniquely QodeX
public enum QXPremiumSpring {
    /// "Hero Reveal" - For number reveals (Life Path, etc.)
    /// Reference: Things 3 task completion animation
    public static let heroReveal = Animation.spring(
        response: 0.45,
        dampingFraction: 0.65,
        blendDuration: 0.1
    )
    
    /// "Elastic Bounce" - For celebratory moments
    /// Reference: Duolingo streak celebrations
    public static let elasticBounce = Animation.spring(
        response: 0.6,
        dampingFraction: 0.5,
        blendDuration: 0.15
    )
    
    /// "Silky Smooth" - For scroll-driven animations
    /// Reference: Apple Photos year view transitions
    public static let silky = Animation.spring(
        response: 0.35,
        dampingFraction: 0.88,
        blendDuration: 0.05
    )
    
    /// "Snap" - For toggle switches and quick state changes
    /// Reference: iOS Control Center toggles
    public static let snap = Animation.spring(
        response: 0.25,
        dampingFraction: 0.95,
        blendDuration: 0.0
    )
    
    /// "Float" - For ambient/drift animations
    /// Reference: Headspace meditation timer
    public static let float = Animation.easeInOut(duration: 3.0)
    
    /// Returns accessible version of animation
    public static var accessible: Animation {
        UIAccessibility.isReduceMotionEnabled 
            ? .easeInOut(duration: 0.1)
            : .spring(response: 0.3, dampingFraction: 0.8)
    }
}

// MARK: - Staggered Entrance Modifier
public struct StaggeredEntranceModifier: ViewModifier {
    let index: Int
    let animationType: EntranceType
    let baseDelay: Double
    @State private var isVisible = false
    
    public enum EntranceType {
        case fadeUp      // Fade + slide up
        case scale       // Scale from 0.8 to 1.0
        case slideLeft   // Slide from right
        case slideRight  // Slide from left
        case flip        // 3D flip entrance
        case elastic     // Bouncy scale
    }
    
    public init(index: Int, animationType: EntranceType = .fadeUp, baseDelay: Double = 0.1) {
        self.index = index
        self.animationType = animationType
        self.baseDelay = baseDelay
    }
    
    public func body(content: Content) -> some View {
        let delay = baseDelay + (Double(index) * 0.08)
        
        return Group {
            switch animationType {
            case .fadeUp:
                content
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
            case .scale:
                content
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1.0 : 0.8)
            case .slideLeft:
                content
                    .opacity(isVisible ? 1 : 0)
                    .offset(x: isVisible ? 0 : 50)
            case .slideRight:
                content
                    .opacity(isVisible ? 1 : 0)
                    .offset(x: isVisible ? 0 : -50)
            case .flip:
                content
                    .opacity(isVisible ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isVisible ? 0 : 90),
                        axis: (x: 0, y: 1, z: 0)
                    )
            case .elastic:
                content
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1.0 : 0.5)
            }
        }
        .onAppear {
            withAnimation(QXPremiumSpring.accessible.delay(delay)) {
                isVisible = true
            }
        }
    }
}

public extension View {
    func staggeredEntrance(
        index: Int,
        type: StaggeredEntranceModifier.EntranceType = .fadeUp,
        baseDelay: Double = 0.1
    ) -> some View {
        modifier(StaggeredEntranceModifier(index: index, animationType: type, baseDelay: baseDelay))
    }
}

// MARK: - Premium Button Style
public struct PremiumButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    let haptic: QXHaptic.FeedbackType
    
    public enum ButtonVariant {
        case primary      // Gold gradient
        case secondary    // Bordered
        case ghost        // Text only
        case glass        // Glass morphism
    }
    
    public init(variant: ButtonVariant = .primary, haptic: QXHaptic.FeedbackType = .medium) {
        self.variant = variant
        self.haptic = haptic
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(QXPremiumSpring.snap, value: configuration.isPressed)
            .background(backgroundView(isPressed: configuration.isPressed))
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    QXHaptic.trigger(haptic)
                }
            }
    }
    
    @ViewBuilder
    private func backgroundView(isPressed: Bool) -> some View {
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
                    color: QXColor.gold.opacity(isPressed ? 0.1 : 0.3),
                    radius: isPressed ? 5 : 15,
                    x: 0,
                    y: isPressed ? 2 : 8
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
        }
    }
}

// MARK: - Glow Effect Modifier
public struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double
    @State private var pulse = false
    
    public init(color: Color = QXColor.gold, radius: CGFloat = 10, intensity: Double = 0.5) {
        self.color = color
        self.radius = radius
        self.intensity = intensity
    }
    
    public func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(intensity * (pulse ? 0.8 : 0.4)),
                radius: radius * (pulse ? 1.2 : 1.0),
                x: 0,
                y: 0
            )
            .onAppear {
                guard !UIAccessibility.isReduceMotionEnabled else { return }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulse.toggle()
                }
            }
    }
}

public extension View {
    func glow(color: Color = QXColor.gold, radius: CGFloat = 10, intensity: Double = 0.5) -> some View {
        modifier(GlowEffect(color: color, radius: radius, intensity: intensity))
    }
}

// MARK: - Shimmer Effect
public struct EnhancedShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    private let shimmerColors = [
        Color.white.opacity(0),
        Color.white.opacity(0.1),
        Color.white.opacity(0.2),
        Color.white.opacity(0.1),
        Color.white.opacity(0)
    ]
    
    public init(isActive: Bool) {
        self.isActive = isActive
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isActive {
                        LinearGradient(
                            gradient: Gradient(colors: shimmerColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 3)
                        .offset(x: -geo.size.width * 2 + (geo.size.width * 3 * phase))
                        .rotationEffect(.degrees(15))
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

public extension View {
    func shimmering(active: Bool) -> some View {
        modifier(EnhancedShimmerModifier(isActive: active))
    }
}

// MARK: - 3D Tilt Card
public struct TiltCard<Content: View>: View {
    let content: Content
    @State private var tilt = CGSize.zero
    @State private var isPressed = false
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .rotation3DEffect(
                .degrees(tilt.height * 0.5),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(-tilt.width * 0.5),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: isPressed ? 10 : 20,
                x: tilt.width * 0.3,
                y: tilt.height * 0.3 + (isPressed ? 5 : 10)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let tiltX = (value.location.x - 150) / 10
                        let tiltY = (value.location.y - 100) / 10
                        tilt = CGSize(width: tiltX, height: tiltY)
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            tilt = .zero
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        isPressed = true
                        QXHaptic.lightImpact()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                                isPressed = false
                            }
                        }
                    }
            )
    }
}

// MARK: - Flip Card
public struct FlipCard<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    
    public init(@ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.front = front()
        self.back = back()
    }
    
    public var body: some View {
        ZStack {
            front
                .opacity(rotation < 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            back
                .opacity(rotation >= 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation - 180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .onTapGesture {
            withAnimation(QXPremiumSpring.heroReveal) {
                rotation = isFlipped ? 0 : 180
                isFlipped.toggle()
            }
            QXHaptic.mediumImpact()
        }
    }
}

// MARK: - Premium Glass Card
public struct PremiumGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    @State private var hoverOffset: CGSize = .zero
    @State private var isPressed = false
    
    public init(cornerRadius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        content
            .padding(24)
            .background(
                ZStack {
                    // Base glass
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Gradient overlay for depth
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Inner glow on top edge
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    QXColor.gold.opacity(0.3),
                                    QXColor.gold.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: Color.black.opacity(0.2),
                radius: isPressed ? 10 : 20,
                x: hoverOffset.width * 0.5,
                y: isPressed ? 5 : 10 + hoverOffset.height * 0.5
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(QXPremiumSpring.silky, value: isPressed)
    }
}

// MARK: - Gradient Text with Shimmer
public struct GradientText: View {
    let text: String
    let font: Font
    let gradient: LinearGradient
    @State private var shimmerPhase: CGFloat = 0
    
    public init(
        text: String,
        font: Font = .system(size: 32, weight: .bold, design: .rounded),
        gradient: LinearGradient = LinearGradient(
            colors: [QXColor.gold, QXColor.goldGlow],
            startPoint: .leading,
            endPoint: .trailing
        )
    ) {
        self.text = text
        self.font = font
        self.gradient = gradient
    }
    
    public var body: some View {
        Text(text)
            .font(font)
            .overlay(
                GeometryReader { geo in
                    gradient
                        .mask(
                            Text(text)
                                .font(font)
                                .frame(width: geo.size.width, height: geo.size.height)
                        )
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: -geo.size.width + (geo.size.width * 2 * shimmerPhase))
                            .mask(
                                Text(text)
                                    .font(font)
                            )
                        )
                }
            )
            .onAppear {
                guard !UIAccessibility.isReduceMotionEnabled else { return }
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1
                }
            }
    }
}

// MARK: - Animated Number Counter
public struct AnimatedNumberCounter: View {
    let targetNumber: Int
    let duration: Double
    @State private var displayNumber: Int = 0
    
    public init(targetNumber: Int, duration: Double = 1.5) {
        self.targetNumber = targetNumber
        self.duration = duration
    }
    
    public var body: some View {
        Text("\(displayNumber)")
            .font(.system(size: 140, weight: .thin, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [QXColor.gold, QXColor.goldGlow],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                animateNumber()
            }
            .onChange(of: targetNumber) { _ in
                animateNumber()
            }
    }
    
    private func animateNumber() {
        displayNumber = 0
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let increment = Double(targetNumber) / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(step) * stepDuration)) {
                withAnimation(.easeOut(duration: stepDuration)) {
                    if step == steps {
                        displayNumber = targetNumber
                        QXHaptic.premiumUnlock()
                    } else {
                        displayNumber = Int(Double(step) * increment)
                    }
                }
            }
        }
    }
}

// MARK: - Particle Burst Effect
public struct ParticleBurst: View {
    let color: Color
    @State private var particles: [BurstParticle] = []
    @State private var animationTimer: Timer?
    
    public struct BurstParticle: Identifiable {
        public let id = UUID()
        public var position: CGPoint
        public var scale: CGFloat
        public var opacity: Double
        public let velocity: CGVector
        public let rotationSpeed: Double
        public var rotation: Double = 0
    }
    
    public init(color: Color = QXColor.gold) {
        self.color = color
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { _ in
            Canvas { context, _ in
                for particle in particles {
                    var path = Path()
                    let size: CGFloat = 8 * particle.scale
                    let rect = CGRect(
                        x: particle.position.x - size/2,
                        y: particle.position.y - size/2,
                        width: size,
                        height: size
                    )
                    path.addRect(rect)
                    
                    context.translateBy(x: particle.position.x, y: particle.position.y)
                    context.rotate(by: .degrees(particle.rotation))
                    context.translateBy(x: -particle.position.x, y: -particle.position.y)
                    
                    context.fill(path, with: .color(color.opacity(particle.opacity)))
                }
            }
        }
        .onAppear {
            createBurst()
            animateParticles()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
    
    private func createBurst() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)
        
        for _ in 0..<30 {
            let angle = Double.random(in: 0...360)
            let speed = Double.random(in: 8...20)
            let particle = BurstParticle(
                position: center,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1.0,
                velocity: CGVector(
                    dx: cos(angle * .pi / 180) * speed,
                    dy: sin(angle * .pi / 180) * speed
                ),
                rotationSpeed: Double.random(in: -10...10)
            )
            particles.append(particle)
        }
    }
    
    private func animateParticles() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.dx
                particles[i].position.y += particles[i].velocity.dy
                particles[i].velocity.dy += 0.3 // Gravity
                particles[i].rotation += particles[i].rotationSpeed
                particles[i].scale *= 0.98
                particles[i].opacity -= 0.02
            }
            
            particles.removeAll { $0.opacity <= 0 }
            
            if particles.isEmpty {
                timer.invalidate()
                animationTimer = nil
            }
        }
    }
}

// MARK: - Typewriter Text
public struct TypewriterText: View {
    let fullText: String
    let typingSpeed: Double
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var cursorVisible = true
    
    public init(text: String, typingSpeed: Double = 0.03) {
        self.fullText = text
        self.typingSpeed = typingSpeed
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Text(displayedText)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight)
            
            // Blinking cursor
            Rectangle()
                .fill(QXColor.gold)
                .frame(width: 2, height: 20)
                .opacity(cursorVisible && currentIndex < fullText.count ? 1 : 0)
        }
        .onAppear {
            startTyping()
            startCursorBlink()
        }
        .onChange(of: fullText) { _, _ in
            displayedText = ""
            currentIndex = 0
            startTyping()
        }
    }
    
    private func startTyping() {
        guard currentIndex < fullText.count else { return }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        displayedText.append(fullText[index])
        currentIndex += 1
        
        // Randomize typing speed slightly for realism
        let randomDelay = typingSpeed * Double.random(in: 0.8...1.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            startTyping()
        }
    }
    
    private func startCursorBlink() {
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            cursorVisible.toggle()
        }
    }
}

// MARK: - Preview
#Preview("Premium Animations") {
    ScrollView {
        VStack(spacing: 32) {
            // Gradient Text
            GradientText(text: "Welcome to QodeX")
            
            // Staggered buttons
            VStack(spacing: 12) {
                ForEach(0..<3) { i in
                    Button("Button \(i + 1)") {}
                        .buttonStyle(PremiumButtonStyle(variant: i == 0 ? .primary : .secondary))
                        .staggeredEntrance(index: i, type: .scale)
                }
            }
            
            // Tilt Card
            TiltCard {
                Text("3D Tilt Card")
                    .frame(width: 200, height: 120)
                    .background(QXColor.deepVoid)
                    .cornerRadius(16)
            }
            
            // Flip Card
            FlipCard(
                front: {
                    Text("Front")
                        .frame(width: 150, height: 150)
                        .background(QXColor.gold)
                        .cornerRadius(16)
                },
                back: {
                    Text("Back")
                        .frame(width: 150, height: 150)
                        .background(QXColor.cosmicTeal)
                        .cornerRadius(16)
                }
            )
            
            // Number Counter
            AnimatedNumberCounter(targetNumber: 8, duration: 2.0)
            
            // Typewriter
            TypewriterText(text: "Your journey begins here...")
        }
        .padding()
    }
    .background(QXColor.cosmicBlack)
}
