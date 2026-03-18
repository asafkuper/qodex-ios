//
//  QXCelebrationEffects.swift
//  QodeX Celebration & Particle Effects
//  Reference: Duolingo, Robinhood celebration effects
//

import SwiftUI

// MARK: - Confetti View
public struct ConfettiView: View {
    let trigger: Bool
    @State private var particles: [ConfettiParticle] = []
    
    public struct ConfettiParticle: Identifiable {
        public let id = UUID()
        public var position: CGPoint
        public var color: Color
        public var size: CGFloat
        public var rotation: Double
        public var velocity: CGVector
        public var angularVelocity: Double
        public var opacity: Double = 1.0
    }
    
    private let colors: [Color] = [
        QXColor.gold,
        QXColor.goldGlow,
        QXColor.cosmicTeal,
        QXColor.mysticPurple,
        .white,
        QXColor.nebulaBlue
    ]
    
    public init(trigger: Bool) {
        self.trigger = trigger
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { _ in
            Canvas { context, _ in
                for particle in particles {
                    var path = Path()
                    
                    // Draw confetti shape (rectangle or circle based on random)
                    let rect = CGRect(
                        x: particle.position.x - particle.size/2,
                        y: particle.position.y - particle.size/2,
                        width: particle.size,
                        height: particle.size * 0.6
                    )
                    path.addRect(rect)
                    
                    // Apply rotation
                    context.translateBy(x: particle.position.x, y: particle.position.y)
                    context.rotate(by: .degrees(particle.rotation))
                    context.translateBy(x: -particle.position.x, y: -particle.position.y)
                    
                    context.fill(path, with: .color(particle.color.opacity(particle.opacity)))
                }
            }
        }
        .onChange(of: trigger) { _, shouldTrigger in
            if shouldTrigger {
                createExplosion()
            }
        }
    }
    
    private func createExplosion() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        // Create particles in an explosion pattern
        for i in 0..<80 {
            let angle = Double(i) * (360.0 / 80.0) + Double.random(in: -10...10)
            let speed = Double.random(in: 5...20)
            
            let particle = ConfettiParticle(
                position: center,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...14),
                rotation: Double.random(in: 0...360),
                velocity: CGVector(
                    dx: cos(angle * .pi / 180) * speed,
                    dy: sin(angle * .pi / 180) * speed - Double.random(in: 5...15) // Initial upward boost
                ),
                angularVelocity: Double.random(in: -15...15)
            )
            particles.append(particle)
        }
        
        // Trigger haptic
        QXHaptic.premiumUnlock()
        
        // Animate particles
        animateParticles()
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            for i in particles.indices {
                // Update position
                particles[i].position.x += particles[i].velocity.dx
                particles[i].position.y += particles[i].velocity.dy
                
                // Apply gravity
                particles[i].velocity.dy += 0.4
                
                // Apply air resistance
                particles[i].velocity.dx *= 0.99
                particles[i].velocity.dy *= 0.99
                
                // Update rotation
                particles[i].rotation += particles[i].angularVelocity
                particles[i].angularVelocity *= 0.98
                
                // Fade out
                particles[i].opacity -= 0.008
            }
            
            // Remove invisible particles
            particles.removeAll { $0.opacity <= 0 }
            
            // Stop animation when all particles are gone
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Sparkle Burst
public struct SparkleBurst: View {
    let trigger: Bool
    let color: Color
    @State private var sparkles: [Sparkle] = []
    
    public struct Sparkle: Identifiable {
        public let id = UUID()
        public var position: CGPoint
        public var scale: CGFloat
        public var opacity: Double
        public let angle: Double
        public let speed: Double
        public let delay: Double
    }
    
    public init(trigger: Bool, color: Color = QXColor.gold) {
        self.trigger = trigger
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Image(systemName: "sparkle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(color)
                    .scaleEffect(sparkle.scale)
                    .opacity(sparkle.opacity)
                    .position(sparkle.position)
            }
        }
        .onChange(of: trigger) { _, shouldTrigger in
            if shouldTrigger {
                createBurst()
            }
        }
    }
    
    private func createBurst() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        for i in 0..<20 {
            let angle = Double(i) * (360.0 / 20.0)
            let sparkle = Sparkle(
                position: center,
                scale: 0,
                opacity: 0,
                angle: angle,
                speed: Double.random(in: 2...5),
                delay: Double.random(in: 0...0.3)
            )
            sparkles.append(sparkle)
            
            // Animate individual sparkle
            animateSparkle(sparkle, center: center)
        }
    }
    
    private func animateSparkle(_ sparkle: Sparkle, center: CGPoint) {
        DispatchQueue.main.asyncAfter(deadline: .now() + sparkle.delay) {
            guard let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) else { return }
            
            // Expand
            withAnimation(.easeOut(duration: 0.3)) {
                sparkles[index].scale = CGFloat.random(in: 0.8...1.5)
                sparkles[index].opacity = 1.0
            }
            
            // Move outward
            withAnimation(.easeOut(duration: 0.6)) {
                let distance = sparkle.speed * 40
                sparkles[index].position = CGPoint(
                    x: center.x + cos(sparkle.angle * .pi / 180) * distance,
                    y: center.y + sin(sparkle.angle * .pi / 180) * distance
                )
            }
            
            // Fade out and remove
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeIn(duration: 0.3)) {
                    if let idx = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                        sparkles[idx].opacity = 0
                        sparkles[idx].scale = 0.5
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    sparkles.removeAll { $0.id == sparkle.id }
                }
            }
        }
    }
}

// MARK: - Streak Fire Animation
public struct StreakFireAnimation: View {
    let streak: Int
    @State private var flames: [FlameParticle] = []
    @State private var isAnimating = false
    @State private var baseScale: CGFloat = 1.0
    @State private var flameTimer: Timer?
    
    public struct FlameParticle: Identifiable {
        public let id = UUID()
        public var offset: CGFloat
        public var scale: CGFloat
        public var opacity: Double
        public let side: FlameSide
        
        public enum FlameSide {
            case left, right, center
        }
    }
    
    public init(streak: Int) {
        self.streak = streak
    }
    
    public var body: some View {
        ZStack {
            // Base flame glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.4),
                            Color.red.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 50, height: 50)
                .scaleEffect(baseScale)
            
            // Base flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            QXColor.goldGlow,
                            Color.orange,
                            Color.red.opacity(0.8)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .scaleEffect(baseScale)
                .shadow(
                    color: Color.orange.opacity(0.5),
                    radius: isAnimating ? 15 : 10,
                    x: 0,
                    y: 0
                )
            
            // Rising sparks
            ForEach(flames) { flame in
                FlameSpark(particle: flame)
            }
            
            // Streak number
            Text("\(streak)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
                .offset(x: 22, y: -5)
        }
        .frame(width: 60, height: 50)
        .onAppear {
            isAnimating = true
            startFlameAnimation()
        }
        .onDisappear {
            isAnimating = false
            flameTimer?.invalidate()
            flameTimer = nil
        }
    }
    
    private func startFlameAnimation() {
        // Pulsing base animation
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            baseScale = 1.1
        }
        
        // Spawn flame particles - store timer reference
        flameTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            guard isAnimating else {
                flameTimer?.invalidate()
                flameTimer = nil
                return
            }
            
            let sides: [FlameParticle.FlameSide] = [.left, .center, .right]
            let flame = FlameParticle(
                offset: 0,
                scale: CGFloat.random(in: 0.5...1.2),
                opacity: 1.0,
                side: sides.randomElement()!
            )
            flames.append(flame)
            
            animateFlameParticle(flame)
        }
    }
    
    private func animateFlameParticle(_ flame: FlameParticle) {
        guard let index = flames.firstIndex(where: { $0.id == flame.id }) else { return }
        
        // Rise and fade animation
        withAnimation(.easeOut(duration: 0.8)) {
            flames[index].offset = -35
            flames[index].opacity = 0
            flames[index].scale *= 0.5
        }
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            flames.removeAll { $0.id == flame.id }
        }
    }
}

// MARK: - Flame Spark View
struct FlameSpark: View {
    let particle: StreakFireAnimation.FlameParticle
    
    var body: some View {
        let xOffset: CGFloat = {
            switch particle.side {
            case .left: return -8
            case .center: return 0
            case .right: return 8
            }
        }()
        
        Circle()
            .fill(
                LinearGradient(
                    colors: [QXColor.goldGlow, .orange],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 4 * particle.scale, height: 4 * particle.scale)
            .offset(x: xOffset, y: particle.offset)
            .opacity(particle.opacity)
            .blur(radius: 1)
    }
}

// MARK: - Number Reveal with Particles
public struct NumberRevealView: View {
    let number: Int
    @State private var showParticles = false
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0
    
    public init(number: Int) {
        self.number = number
    }
    
    public var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [QXColor.gold.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(scale)
                .opacity(glowOpacity)
            
            // Particle burst behind number
            if showParticles {
                ParticleBurst(color: QXColor.gold)
            }
            
            // Decorative rings
            Circle()
                .stroke(QXColor.gold.opacity(0.2 * opacity), lineWidth: 1)
                .frame(width: 220, height: 220)
                .scaleEffect(0.8 + 0.2 * scale)
            
            // Number with spring animation
            Text("\(number)")
                .font(.system(size: 160, weight: .thin, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
                .shadow(
                    color: QXColor.gold.opacity(0.5),
                    radius: 30,
                    x: 0,
                    y: 0
                )
        }
        .frame(height: 280)
        .onAppear {
            // Staggered animation sequence
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1
            }
            
            withAnimation(QXPremiumSpring.heroReveal) {
                scale = 1.0
                rotation = 0
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                glowOpacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showParticles = true
                QXHaptic.premiumUnlock()
            }
        }
    }
}

// MARK: - Checkmark Draw Animation
public struct CheckmarkDrawAnimation: View {
    @State private var trimEnd: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var checkScale: CGFloat = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Success circle background
            Circle()
                .fill(QXColor.success)
                .frame(width: 60, height: 60)
                .scaleEffect(circleScale)
            
            // Checkmark
            CheckmarkShape()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 30, height: 30)
                .scaleEffect(checkScale)
        }
        .onAppear {
            // Circle pop
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                circleScale = 1.0
            }
            
            // Check draw
            withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
                trimEnd = 1.0
                checkScale = 1.0
            }
            
            // Haptic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                QXHaptic.success()
            }
        }
    }
}

// MARK: - Checkmark Shape
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

// MARK: - Milestone Badge Animation
public struct MilestoneBadgeAnimation: View {
    let milestone: Int
    @State private var showBadge = false
    @State private var badgeScale: CGFloat = 0
    @State private var rotation: Double = 0
    
    public init(milestone: Int) {
        self.milestone = milestone
    }
    
    public var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [QXColor.gold, QXColor.goldGlow, QXColor.gold],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(rotation))
            
            // Badge background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [QXColor.deepVoid, QXColor.cosmicBlack],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(
                    color: QXColor.gold.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 0
                )
            
            // Content
            VStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 24))
                    .foregroundColor(QXColor.gold)
                
                Text("\(milestone)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("DAY STREAK")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.1)
                    .foregroundColor(QXColor.starlight.opacity(0.7))
            }
            .scaleEffect(badgeScale)
        }
        .opacity(showBadge ? 1 : 0)
        .onAppear {
            // Spinning ring
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Badge entrance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                showBadge = true
                badgeScale = 1.0
            }
            
            QXHaptic.premiumUnlock()
        }
    }
}

// MARK: - Premium Unlock Celebration
public struct PremiumUnlockCelebration: View {
    @State private var showConfetti = false
    @State private var showText = false
    @State private var textScale: CGFloat = 0.5
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Confetti
            ConfettiView(trigger: showConfetti)
            
            // Crown icon
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: QXColor.gold.opacity(0.5), radius: 30)
                .opacity(showText ? 1 : 0)
                .scaleEffect(textScale)
            
            // Text
            VStack(spacing: 12) {
                Text("Welcome to the")
                    .font(.system(size: 20))
                    .foregroundColor(QXColor.starlight.opacity(0.7))
                
                Text("Inner Circle")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Your journey to mastery begins now")
                    .font(.system(size: 16))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 200)
            .opacity(showText ? 1 : 0)
            .offset(y: showText ? 0 : 30)
        }
        .onAppear {
            // Trigger confetti
            showConfetti = true
            
            // Show text
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                showText = true
                textScale = 1.0
            }
            
            QXHaptic.premiumUnlock()
        }
    }
}

// MARK: - Preview
#Preview("Celebration Effects") {
    VStack(spacing: 40) {
        // Streak fire
        StreakFireAnimation(streak: 30)
        
        // Number reveal
        NumberRevealView(number: 8)
            .frame(height: 150)
        
        // Checkmark
        CheckmarkDrawAnimation()
        
        // Milestone badge
        MilestoneBadgeAnimation(milestone: 30)
    }
    .padding()
    .background(QXColor.cosmicBlack)
}
