//
//  MetalSacredBackground.swift
//  GPU-accelerated sacred geometry backgrounds
//

import SwiftUI
import MetalKit

// MARK: - Metal View Representable
struct MetalSacredBackground: UIViewRepresentable {
    let pattern: SacredPattern
    let color1: Color
    let color2: Color
    let animationSpeed: Double
    
    enum SacredPattern: Int {
        case flowerOfLife = 0
        case metatronsCube = 1
        case cosmicParticles = 2
    }
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.delegate = context.coordinator
        metalView.framebufferOnly = false
        metalView.clearColor = MTLClearColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1.0)
        metalView.colorPixelFormat = .bgra8Unorm
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.pattern = pattern
        context.coordinator.color1 = color1
        context.coordinator.color2 = color2
        context.coordinator.animationSpeed = Float(animationSpeed)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalSacredBackground
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var time: Float = 0
        var pattern: SacredPattern = .flowerOfLife
        var color1: Color = .gold
        var color2: Color = .purple
        var animationSpeed: Float = 1.0
        
        init(_ parent: MetalSacredBackground) {
            self.parent = parent
            super.init()
            setupMetal()
        }
        
        func setupMetal() {
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            
            // Load shader
            guard let library = try? device.makeDefaultLibrary(bundle: Bundle.main),
                  let vertexFunction = library.makeFunction(name: "sacredGeometryVertex"),
                  let fragmentFunction = library.makeFunction(name: "sacredGeometryFragment") else {
                return
            }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create pipeline state: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let pipelineState = pipelineState,
                  let commandQueue = commandQueue else { return }
            
            time += 0.016 * animationSpeed // ~60fps
            
            let commandBuffer = commandQueue.makeCommandBuffer()
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            guard let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }
            
            renderEncoder.setRenderPipelineState(pipelineState)
            
            // Set time uniform
            var timeUniform = time
            renderEncoder.setVertexBytes(&timeUniform, length: MemoryLayout<Float>.size, index: 0)
            
            // Set color uniforms
            let color1Components = color1.cgColor?.components ?? [1, 0.9, 0.35, 1]
            let color2Components = color2.cgColor?.components ?? [0.6, 0.2, 0.8, 1]
            
            var color1Uniform = SIMD4<Float>(
                Float(color1Components[0]),
                Float(color1Components[1]),
                Float(color1Components[2]),
                Float(color1Components[3])
            )
            var color2Uniform = SIMD4<Float>(
                Float(color2Components[0]),
                Float(color2Components[1]),
                Float(color2Components[2]),
                Float(color2Components[3])
            )
            
            renderEncoder.setFragmentBytes(&color1Uniform, length: MemoryLayout<SIMD4<Float>>.size, index: 0)
            renderEncoder.setFragmentBytes(&color2Uniform, length: MemoryLayout<SIMD4<Float>>.size, index: 1)
            
            // Set pattern type
            var patternType = pattern.rawValue
            renderEncoder.setFragmentBytes(&patternType, length: MemoryLayout<Int>.size, index: 2)
            
            // Draw fullscreen quad
            let vertices: [Float] = [
                -1, -1, 0, 0,
                 1, -1, 1, 0,
                -1,  1, 0, 1,
                 1,  1, 1, 1
            ]
            renderEncoder.setVertexBytes(vertices, length: vertices.count * MemoryLayout<Float>.size, index: 0)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            
            renderEncoder.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

// MARK: - Fallback for Simulator
struct SacredGeometryFallback: View {
    let pattern: MetalSacredBackground.SacredPattern
    let color1: Color
    let color2: Color
    
    @State private var rotation: Double = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                // Draw sacred geometry pattern using Canvas API
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) * 0.3
                
                // Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color(hex: "0A0A0F"))
                )
                
                // Draw pattern based on type
                switch pattern {
                case .flowerOfLife:
                    drawFlowerOfLife(context: context, center: center, radius: radius, rotation: rotation)
                case .metatronsCube:
                    drawMetatronsCube(context: context, center: center, radius: radius, rotation: rotation)
                case .cosmicParticles:
                    drawParticles(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                }
                
                // Update rotation
                DispatchQueue.main.async {
                    rotation += 0.5
                }
            }
        }
    }
    
    private func drawFlowerOfLife(context: GraphicsContext, center: CGPoint, radius: CGFloat, rotation: Double) {
        // Central circle
        drawCircle(context: context, center: center, radius: radius, color: color1)
        
        // Surrounding circles
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 + rotation * .pi / 180
            let offset = CGPoint(
                x: center.x + cos(angle) * radius * 0.5,
                y: center.y + sin(angle) * radius * 0.5
            )
            drawCircle(context: context, center: offset, radius: radius * 0.5, color: color2.opacity(0.5))
        }
    }
    
    private func drawMetatronsCube(context: GraphicsContext, center: CGPoint, radius: CGFloat, rotation: Double) {
        // Draw hexagon
        var path = Path()
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 + rotation * .pi / 180
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        context.stroke(path, with: .color(color1), lineWidth: 1)
    }
    
    private func drawParticles(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        for i in 0..<50 {
            let fi = Double(i)
            let x = modf(fi * 0.789 + time * 0.1).1 * size.width
            let y = modf(fi * 0.321 - time * 0.05).1 * size.height
            let particleRadius = 2.0 + modf(fi * 0.456).1 * 3.0
            
            let rect = CGRect(
                x: x - particleRadius,
                y: y - particleRadius,
                width: particleRadius * 2,
                height: particleRadius * 2
            )
            
            context.fill(
                Path(ellipseIn: rect),
                with: .color(color1.opacity(0.6))
            )
        }
    }
    
    private func drawCircle(context: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        context.stroke(
            Path(ellipseIn: rect),
            with: .color(color),
            lineWidth: 1
        )
    }
}

// MARK: - Unified Sacred Background View
struct NextLevelSacredBackground: View {
    let pattern: MetalSacredBackground.SacredPattern
    let color1: Color
    let color2: Color
    let animationSpeed: Double
    
    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            SacredGeometryFallback(
                pattern: pattern,
                color1: color1,
                color2: color2
            )
            #else
            if MTLCreateSystemDefaultDevice() != nil {
                MetalSacredBackground(
                    pattern: pattern,
                    color1: color1,
                    color2: color2,
                    animationSpeed: animationSpeed
                )
            } else {
                SacredGeometryFallback(
                    pattern: pattern,
                    color1: color1,
                    color2: color2
                )
            }
            #endif
        }
    }
}

// MARK: - Preview
#Preview("Metal Sacred Backgrounds") {
    TabView {
        NextLevelSacredBackground(
            pattern: .flowerOfLife,
            color1: .gold,
            color2: .purple,
            animationSpeed: 1.0
        )
        .tabItem { Label("Flower", systemImage: "flower") }
        
        NextLevelSacredBackground(
            pattern: .metatronsCube,
            color1: .cyan,
            color2: .pink,
            animationSpeed: 0.5
        )
        .tabItem { Label("Metatron", systemImage: "hexagon.fill") }
        
        NextLevelSacredBackground(
            pattern: .cosmicParticles,
            color1: .gold,
            color2: .blue,
            animationSpeed: 2.0
        )
        .tabItem { Label("Particles", systemImage: "sparkles") }
    }
}
