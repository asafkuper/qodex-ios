//
//  QXPremiumBackgrounds.swift
//  QodeX Premium Background Effects
//  Reference: iOS 18 Mesh Gradients, Sacred Geometry
//

import SwiftUI

// MARK: - Animated Mesh Gradient (iOS 18+)
@available(iOS 18.0, *)
public struct AnimatedMeshGradient: View {
    @State private var phase: Float = 0
    
    public init() {}
    
    public var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5 + sin(phase) * 0.1, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5 + sin(phase) * 0.2, 0.5 + cos(phase) * 0.1], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0 + cos(phase) * 0.1], [1.0, 1.0]
            ],
            colors: [
                QXColor.cosmicBlack,
                QXColor.deepVoid,
                QXColor.cosmicBlack,
                QXColor.mysticPurple.opacity(0.3),
                QXColor.gold.opacity(0.2),
                QXColor.cosmicTeal.opacity(0.2),
                QXColor.cosmicBlack,
                QXColor.deepVoid,
                QXColor.cosmicBlack
            ]
        )
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Fallback Mesh Simulation (Pre-iOS 18)
public struct MeshGradientFallback: View {
    @State private var animate = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base
                QXColor.cosmicBlack.ignoresSafeArea()
                
                // Animated gradient blobs
                MeshBlob(color: QXColor.mysticPurple, startPosition: .topLeading, endPosition: .center, animate: animate)
                MeshBlob(color: QXColor.gold, startPosition: .topTrailing, endPosition: .trailing, animate: animate)
                MeshBlob(color: QXColor.cosmicTeal, startPosition: .bottomLeading, endPosition: .bottom, animate: animate)
                MeshBlob(color: QXColor.goldGlow.opacity(0.5), startPosition: .bottomTrailing, endPosition: .center, animate: animate)
            }
        }
        .blur(radius: 80)
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Mesh Blob
struct MeshBlob: View {
    let color: Color
    let startPosition: UnitPoint
    let endPosition: UnitPoint
    let animate: Bool
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 400, height: 400)
            .position(
                x: animate 
                    ? (endPosition.x > 0.5 ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.3)
                    : (startPosition.x > 0.5 ? UIScreen.main.bounds.width * 0.8 : UIScreen.main.bounds.width * 0.2),
                y: animate
                    ? (endPosition.y > 0.5 ? UIScreen.main.bounds.height * 0.7 : UIScreen.main.bounds.height * 0.3)
                    : (startPosition.y > 0.5 ? UIScreen.main.bounds.height * 0.8 : UIScreen.main.bounds.height * 0.2)
            )
            .opacity(0.25)
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
    }
}

// MARK: - Universal Mesh Gradient
public struct UniversalMeshGradient: View {
    public init() {}
    
    public var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                AnimatedMeshGradient()
            } else {
                MeshGradientFallback()
            }
        }
    }
}

// MARK: - Sacred Geometry Background (Enhanced)
public struct SacredGeometryBackgroundV2: View {
    @State private var phase: Double = 0
    @State private var pulse = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base cosmic gradient
                LinearGradient(
                    colors: [
                        QXColor.cosmicBlack,
                        QXColor.deepVoid,
                        QXColor.cosmicBlack
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Flower of Life pattern
                FlowerOfLifePattern(phase: phase, size: geo.size)
                    .opacity(0.08)
                    .blur(radius: 0.5)
                
                // Rotating rings
                SacredRings(phase: phase, center: CGPoint(x: geo.size.width/2, y: geo.size.height/3))
                
                // Floating particles
                SacredParticles(phase: phase, size: geo.size)
                
                // Golden ratio spiral (subtle)
                GoldenSpiral(phase: phase, center: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                    .opacity(0.05)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                phase = 360
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}

// MARK: - Flower of Life Pattern
struct FlowerOfLifePattern: View {
    let phase: Double
    let size: CGSize
    
    var body: some View {
        Canvas { context, _ in
            let center = CGPoint(x: size.width/2, y: size.height/3)
            let radius: CGFloat = 50
            
            // Draw 19 circles in Flower of Life pattern
            let positions = flowerOfLifePositions(center: center, radius: radius)
            
            for (index, pos) in positions.enumerated() {
                let rotation = phase * 0.05 + Double(index) * 5
                
                var path = Path()
                path.addEllipse(in: CGRect(
                    x: pos.x - radius,
                    y: pos.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                
                // Pulsing opacity
                let opacity = 0.15 + 0.1 * sin((phase + Double(index) * 10) * .pi / 180)
                
                context.stroke(
                    path,
                    with: .color(QXColor.gold.opacity(opacity)),
                    lineWidth: 0.5
                )
            }
        }
    }
    
    private func flowerOfLifePositions(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        var positions: [CGPoint] = [center] // Center circle
        
        // First ring (6 circles)
        for i in 0..<6 {
            let angle = Double(i) * 60.0 * .pi / 180
            positions.append(CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ))
        }
        
        // Second ring (12 circles)
        for i in 0..<12 {
            let angle = Double(i) * 30.0 * .pi / 180
            positions.append(CGPoint(
                x: center.x + cos(angle) * radius * 1.8,
                y: center.y + sin(angle) * radius * 1.8
            ))
        }
        
        return positions
    }
}

// MARK: - Sacred Rings
struct SacredRings: View {
    let phase: Double
    let center: CGPoint
    
    var body: some View {
        ZStack {
            // Outer ring with dashes
            Circle()
                .stroke(
                    QXColor.gold.opacity(0.1),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                )
                .frame(width: 380, height: 380)
                .position(center)
                .rotationEffect(.degrees(phase))
            
            // Middle solid ring
            Circle()
                .stroke(QXColor.gold.opacity(0.08), lineWidth: 1)
                .frame(width: 300, height: 300)
                .position(center)
                .rotationEffect(.degrees(-phase * 0.5))
            
            // Inner dotted ring
            Circle()
                .stroke(
                    QXColor.gold.opacity(0.12),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 8])
                )
                .frame(width: 240, height: 240)
                .position(center)
                .rotationEffect(.degrees(phase * 0.3))
            
            // Innermost solid ring
            Circle()
                .stroke(QXColor.gold.opacity(0.15), lineWidth: 1)
                .frame(width: 180, height: 180)
                .position(center)
                .rotationEffect(.degrees(-phase * 0.2))
        }
    }
}

// MARK: - Golden Ratio Spiral
struct GoldenSpiral: View {
    let phase: Double
    let center: CGPoint
    
    private let goldenRatio: CGFloat = 1.618033988749895
    
    var body: some View {
        Canvas { context, _ in
            var path = Path()
            var currentPoint = center
            var angle: Double = 0
            var radius: CGFloat = 10
            
            path.move(to: currentPoint)
            
            for i in 0..<100 {
                angle += 0.1
                radius *= 1.005
                
                let x = center.x + cos(angle + phase * 0.01) * radius
                let y = center.y + sin(angle + phase * 0.01) * radius
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            context.stroke(
                path,
                with: .color(QXColor.gold.opacity(0.1)),
                lineWidth: 1
            )
        }
    }
}

// MARK: - Sacred Particles
struct SacredParticles: View {
    let phase: Double
    let size: CGSize
    @State private var particles: [SacredParticle] = []
    
    struct SacredParticle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let phaseOffset: Double
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { _ in
            Canvas { context, _ in
                for particle in particles {
                    let pulse = 0.5 + 0.5 * sin((phase + particle.phaseOffset) * .pi / 180)
                    let opacity = 0.2 * pulse
                    
                    let rect = CGRect(
                        x: particle.x - particle.size/2,
                        y: particle.y - particle.size/2,
                        width: particle.size * pulse,
                        height: particle.size * pulse
                    )
                    
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(QXColor.gold.opacity(opacity))
                    )
                }
            }
        }
        .onAppear {
            // Generate particles
            for _ in 0..<30 {
                particles.append(SacredParticle(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height),
                    size: CGFloat.random(in: 2...6),
                    phaseOffset: Double.random(in: 0...360)
                ))
            }
        }
    }
}

// MARK: - Living Background
public struct LivingBackground: View {
    let style: BackgroundStyle
    @State private var phase: Double = 0
    
    public enum BackgroundStyle {
        case cosmic
        case sacredGeometry
        case aurora
    }
    
    public init(style: BackgroundStyle = .cosmic) {
        self.style = style
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base
                QXColor.cosmicBlack.ignoresSafeArea()
                
                switch style {
                case .cosmic:
                    CosmicBackground(phase: phase, size: geo.size)
                case .sacredGeometry:
                    SacredGeometryBackgroundV2()
                case .aurora:
                    AuroraBackground(phase: phase, size: geo.size)
                }
            }
        }
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    let phase: Double
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Twinkling stars
            ForEach(0..<50) { i in
                StarView(index: i, phase: phase, size: size)
            }
            
            // Nebula clouds
            NebulaCloud(phase: phase, color: QXColor.mysticPurple)
                .offset(x: sin(phase * 0.01) * 100, y: cos(phase * 0.01) * 50)
            
            NebulaCloud(phase: phase + 120, color: QXColor.gold.opacity(0.3))
                .offset(x: cos(phase * 0.008) * 80, y: sin(phase * 0.008) * 100)
                
            NebulaCloud(phase: phase + 240, color: QXColor.cosmicTeal.opacity(0.2))
                .offset(x: sin(phase * 0.012) * 120, y: cos(phase * 0.012) * 80)
        }
    }
}

// MARK: - Star View
struct StarView: View {
    let index: Int
    let phase: Double
    let size: CGSize
    
    var body: some View {
        let x = CGFloat.random(in: 0...1) * size.width
        let y = CGFloat.random(in: 0...1) * size.height
        let twinkleOffset = Double(index) * 0.5
        let opacity = 0.2 + 0.8 * abs(sin((phase + twinkleOffset) * 0.1))
        let scale = 0.5 + 0.5 * abs(sin((phase + twinkleOffset) * 0.05))
        
        Circle()
            .fill(Color.white)
            .frame(width: 2 * scale, height: 2 * scale)
            .position(x: x, y: y)
            .opacity(opacity)
            .blur(radius: 0.5)
    }
}

// MARK: - Nebula Cloud
struct NebulaCloud: View {
    let phase: Double
    let color: Color
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.25), color.opacity(0.1), .clear],
                    center: .center,
                    startRadius: 50,
                    endRadius: 250
                )
            )
            .frame(width: 500, height: 500)
            .blur(radius: 60)
    }
}

// MARK: - Aurora Background
struct AuroraBackground: View {
    let phase: Double
    let size: CGSize
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { _ in
            Canvas { context, _ in
                // Draw aurora waves
                for wave in 0..<3 {
                    var path = Path()
                    let wavePhase = phase + Double(wave) * 120
                    let baseY = size.height * (0.3 + CGFloat(wave) * 0.2)
                    
                    path.move(to: CGPoint(x: 0, y: baseY))
                    
                    for x in stride(from: 0, to: size.width, by: 10) {
                        let y = baseY + sin((Double(x) + wavePhase) * 0.01) * 50 + 
                                sin((Double(x) + wavePhase * 0.5) * 0.005) * 30
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                    
                    let colors = [QXColor.mysticPurple, QXColor.cosmicTeal, QXColor.gold]
                    context.fill(path, with: .color(colors[wave].opacity(0.15)))
                }
            }
        }
        .blur(radius: 30)
    }
}

// MARK: - Enhanced Onboarding Background
public struct EnhancedOnboardingBackground: View {
    @State private var phase: Double = 0
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base
                LinearGradient(
                    colors: [QXColor.cosmicBlack, QXColor.deepVoid, QXColor.cosmicBlack],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Sacred geometry rings
                ZStack {
                    // Large outer ring
                    Circle()
                        .stroke(QXColor.gold.opacity(0.05), lineWidth: 1)
                        .frame(width: geo.size.width * 1.5, height: geo.size.width * 1.5)
                        .position(x: geo.size.width/2, y: geo.size.height/3)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    
                    // Medium ring
                    Circle()
                        .stroke(QXColor.gold.opacity(0.08), lineWidth: 1)
                        .frame(width: geo.size.width, height: geo.size.width)
                        .position(x: geo.size.width/2, y: geo.size.height/3)
                        .rotationEffect(.degrees(isAnimating ? -360 : 0))
                    
                    // Inner dashed ring
                    Circle()
                        .stroke(QXColor.gold.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [10, 10]))
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                        .position(x: geo.size.width/2, y: geo.size.height/3)
                        .rotationEffect(.degrees(isAnimating ? 180 : 0))
                }
                
                // Floating orbs
                FloatingOrb(
                    color: QXColor.mysticPurple,
                    size: 200,
                    center: CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.3),
                    phase: phase
                )
                
                FloatingOrb(
                    color: QXColor.gold.opacity(0.5),
                    size: 150,
                    center: CGPoint(x: geo.size.width * 0.8, y: geo.size.height * 0.4),
                    phase: phase + 120
                )
                
                FloatingOrb(
                    color: QXColor.cosmicTeal.opacity(0.3),
                    size: 180,
                    center: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.7),
                    phase: phase + 240
                )
            }
        }
        .blur(radius: 20)
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

// MARK: - Floating Orb
struct FloatingOrb: View {
    let color: Color
    let size: CGFloat
    let center: CGPoint
    let phase: Double
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.3), color.opacity(0.1), .clear],
                    center: .center,
                    startRadius: size * 0.2,
                    endRadius: size * 0.8
                )
            )
            .frame(width: size, height: size)
            .position(
                x: center.x + sin(phase * .pi / 180) * 30,
                y: center.y + cos(phase * .pi / 180) * 20
            )
    }
}

// MARK: - Paywall Mesh Background
public struct PaywallMeshBackground: View {
    @State private var phase: Double = 0
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base dark gradient
                LinearGradient(
                    colors: [
                        QXColor.cosmicBlack,
                        QXColor.deepVoid,
                        QXColor.cosmicBlack
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Animated mesh-like gradient overlay
                ZStack {
                    // Top right glow
                    RadialGradient(
                        colors: [QXColor.mysticPurple.opacity(0.2), .clear],
                        center: .topTrailing,
                        startRadius: 50,
                        endRadius: 350
                    )
                    .offset(x: sin(phase * 0.01) * 30, y: cos(phase * 0.01) * 20)
                    
                    // Bottom left glow
                    RadialGradient(
                        colors: [QXColor.gold.opacity(0.15), .clear],
                        center: .bottomLeading,
                        startRadius: 50,
                        endRadius: 300
                    )
                    .offset(x: cos(phase * 0.008) * 25, y: sin(phase * 0.008) * 30)
                    
                    // Center accent
                    RadialGradient(
                        colors: [QXColor.cosmicTeal.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 100,
                        endRadius: 450
                    )
                    .scaleEffect(1.0 + sin(phase * 0.005) * 0.1)
                }
            }
        }
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase = 360
            }
        }
    }
}

// MARK: - Preview
#Preview("Premium Backgrounds") {
    TabView {
        SacredGeometryBackgroundV2()
            .tabItem { Label("Sacred", systemImage: "hexagon.fill") }
        
        LivingBackground(style: .cosmic)
            .tabItem { Label("Cosmic", systemImage: "star.fill") }
        
        LivingBackground(style: .aurora)
            .tabItem { Label("Aurora", systemImage: "waveform") }
        
        EnhancedOnboardingBackground()
            .tabItem { Label("Onboarding", systemImage: "sparkles") }
        
        PaywallMeshBackground()
            .tabItem { Label("Paywall", systemImage: "crown.fill") }
        
        if #available(iOS 18.0, *) {
            AnimatedMeshGradient()
                .tabItem { Label("Mesh", systemImage: "gradientshape") }
        }
    }
    .preferredColorScheme(.dark)
}
