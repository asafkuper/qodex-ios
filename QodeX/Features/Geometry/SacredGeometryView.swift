//
//  SacredGeometryView.swift
//  QodeX
//
//  Sacred Geometry - Phi, Pi, Fibonacci & Divine Patterns
//  Glassmorphism aesthetic with gold accents (#E5C158)
//

import SwiftUI
import SceneKit
import Combine

// MARK: - Sacred Geometry View
struct SacredGeometryView: View {
    @State private var selectedTab: GeometryTab = .goldenRatio
    @State private var showExportSheet = false
    @State private var exportImage: UIImage?
    
    enum GeometryTab: String, CaseIterable {
        case goldenRatio = "Phi"
        case fibonacci = "Fibonacci"
        case flowerOfLife = "Flower"
        case metatron = "Metatron"
        case pi = "Pi"
        case platonic = "Solids"
        calculator = "Calculator"
        case nature = "Nature"
        case draw = "Draw"
    }
    
    var body: some View {
        ZStack {
            // Deep cosmic background
            CosmicBackground()
            
            VStack(spacing: 0) {
                // Header
                GeometryHeader()
                
                // Tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(GeometryTab.allCases, id: \.self) { tab in
                            TabButton(tab: tab, isSelected: selectedTab == tab) {
                                withAnimation(.spring()) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Content area
                TabView(selection: $selectedTab) {
                    GoldenRatioView()
                        .tag(GeometryTab.goldenRatio)
                    
                    FibonacciSpiralView()
                        .tag(GeometryTab.fibonacci)
                    
                    FlowerOfLifeView()
                        .tag(GeometryTab.flowerOfLife)
                    
                    MetatronCubeView()
                        .tag(GeometryTab.metatron)
                    
                    PiVisualizationView()
                        .tag(GeometryTab.pi)
                    
                    PlatonicSolidsView()
                        .tag(GeometryTab.platonic)
                    
                    GoldenCalculatorView()
                        .tag(GeometryTab.calculator)
                    
                    NatureProportionsView()
                        .tag(GeometryTab.nature)
                    
                    InteractiveDrawingView()
                        .tag(GeometryTab.draw)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(image: exportImage)
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            // Deep space gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.08),
                    Color(red: 0.08, green: 0.03, blue: 0.12),
                    Color(red: 0.02, green: 0.01, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated starfield
            GeometryReader { geo in
                ForEach(0..<50) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .opacity(animateStars ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                            value: animateStars
                        )
                }
            }
            .onAppear { animateStars = true }
            
            // Sacred geometry overlay
            SacredOverlay()
        }
    }
}

struct SacredOverlay: View {
    var body: some View {
        Canvas { context, size in
            // Subtle grid pattern
            let gridSpacing: CGFloat = 40
            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.goldAccent.opacity(0.03)), lineWidth: 0.5)
            }
            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.goldAccent.opacity(0.03)), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Header
struct GeometryHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sacred Geometry")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.goldAccent)
                
                Text("Φ = 1.618... | π = 3.14159...")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.goldAccent.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.goldAccent)
                    .padding(12)
                    .glassmorphic()
            }
            .accessibilityLabel("Share geometry")
            .accessibilityHint("Double tap to share or export the current geometry")
        }
        .padding()
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: SacredGeometryView.GeometryTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tab.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .black : .goldAccent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.goldAccent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.goldAccent.opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .accessibilityLabel("\(tab.rawValue) tab")
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to view \(tab.rawValue) geometry")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Golden Ratio View
struct GoldenRatioView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var showSpiral = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Phi visualization
                ZStack {
                    // Glass container
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 350)
                    
                    // Golden rectangles
                    Canvas { context, size in
                        let phi: CGFloat = 1.618033988749895
                        let maxSize = min(size.width, size.height) * 0.8
                        
                        var rect = CGRect(
                            x: (size.width - maxSize) / 2,
                            y: (size.height - maxSize) / 2,
                            width: maxSize,
                            height: maxSize / phi
                        )
                        
                        let colors: [Color] = [
                            Color.goldAccent.opacity(0.9),
                            Color.goldAccent.opacity(0.7),
                            Color.goldAccent.opacity(0.5),
                            Color.goldAccent.opacity(0.4),
                            Color.goldAccent.opacity(0.3)
                        ]
                        
                        for (index, color) in colors.enumerated() {
                            let rectPath = Path(roundedRect: rect, cornerRadius: 2)
                            context.stroke(rectPath, with: .color(color), lineWidth: 2)
                            context.fill(rectPath, with: .color(color.opacity(0.1)))
                            
                            // Quarter circle for spiral
                            if showSpiral {
                                var spiralPath = Path()
                                let center: CGPoint
                                let radius = min(rect.width, rect.height)
                                let startAngle: Double
                                let endAngle: Double
                                
                                switch index % 4 {
                                case 0:
                                    center = CGPoint(x: rect.maxX, y: rect.maxY)
                                    startAngle = 180
                                    endAngle = 270
                                case 1:
                                    center = CGPoint(x: rect.minX, y: rect.maxY)
                                    startAngle = 270
                                    endAngle = 360
                                case 2:
                                    center = CGPoint(x: rect.minX, y: rect.minY)
                                    startAngle = 0
                                    endAngle = 90
                                default:
                                    center = CGPoint(x: rect.maxX, y: rect.minY)
                                    startAngle = 90
                                    endAngle = 180
                                }
                                
                                spiralPath.addArc(
                                    center: center,
                                    radius: radius,
                                    startAngle: .degrees(startAngle),
                                    endAngle: .degrees(endAngle),
                                    clockwise: false
                                )
                                context.stroke(spiralPath, with: .color(.goldAccent), lineWidth: 2)
                            }
                            
                            // Calculate next rectangle
                            let newWidth = rect.height
                            let newHeight = rect.width - rect.height
                            
                            switch index % 4 {
                            case 0:
                                rect = CGRect(x: rect.minX, y: rect.minY, width: newWidth, height: newHeight)
                            case 1:
                                rect = CGRect(x: rect.minX, y: rect.minY, width: newWidth, height: newHeight)
                            case 2:
                                rect = CGRect(x: rect.maxX - newWidth, y: rect.minY, width: newWidth, height: newHeight)
                            default:
                                rect = CGRect(x: rect.maxX - newWidth, y: rect.maxY - newHeight, width: newWidth, height: newHeight)
                            }
                        }
                    }
                    .frame(height: 320)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scale)
                    .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: rotation)
                }
                .padding(.horizontal)
                
                // Controls
                HStack(spacing: 16) {
                    Toggle("Show Spiral", isOn: $showSpiral)
                        .tint(.goldAccent)
                        .foregroundColor(.goldAccent)
                        .accessibilityLabel("Show spiral toggle")
                        .accessibilityHint("Double tap to toggle the golden spiral overlay")
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Phi information
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Golden Ratio")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.goldAccent)
                    
                    Text("φ = (1 + √5) / 2 ≈ 1.618033988749895...")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.goldAccent.opacity(0.8))
                    
                    Text("The golden ratio appears when a line is divided into two parts such that the whole length divided by the long part is equal to the long part divided by the short part.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            scale = 1.02
            rotation = 360
        }
    }
}

// MARK: - Fibonacci Spiral View
struct FibonacciSpiralView: View {
    @State private var animationProgress: CGFloat = 0
    @State private var showNumbers = true
    
    let fibonacciNumbers = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Animated Fibonacci spiral
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 400)
                    
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let scale: CGFloat = 3
                        
                        var currentX = center.x
                        var currentY = center.y
                        var currentSize: CGFloat = 1 * scale
                        var direction = 0 // 0: right, 1: up, 2: left, 3: down
                        
                        for (index, fib) in fibonacciNumbers.enumerated() {
                            guard CGFloat(index) < animationProgress * CGFloat(fibonacciNumbers.count) else { break }
                            
                            let size = CGFloat(fib) * scale
                            var rect: CGRect
                            
                            switch direction {
                            case 0: // right
                                rect = CGRect(x: currentX, y: currentY - size, width: size, height: size)
                                currentX += size
                                currentY -= size
                            case 1: // up
                                rect = CGRect(x: currentX - size, y: currentY - size, width: size, height: size)
                                currentX -= size
                            case 2: // left
                                rect = CGRect(x: currentX - size, y: currentY, width: size, height: size)
                                currentX -= size
                                currentY += size
                            default: // down
                                rect = CGRect(x: currentX, y: currentY, width: size, height: size)
                                currentY += size
                                currentX += size
                            }
                            
                            // Draw square
                            let squarePath = Path(rect)
                            let opacity = 0.3 + (0.6 * (1.0 - Double(index) / Double(fibonacciNumbers.count)))
                            context.stroke(squarePath, with: .color(Color.goldAccent.opacity(opacity)), lineWidth: 2)
                            
                            // Draw quarter circle
                            var arcPath = Path()
                            let arcCenter: CGPoint
                            let startAngle: Double
                            let endAngle: Double
                            
                            switch direction {
                            case 0:
                                arcCenter = CGPoint(x: rect.minX, y: rect.minY)
                                startAngle = 90
                                endAngle = 0
                            case 1:
                                arcCenter = CGPoint(x: rect.minX, y: rect.maxY)
                                startAngle = 0
                                endAngle = -90
                            case 2:
                                arcCenter = CGPoint(x: rect.maxX, y: rect.maxY)
                                startAngle = -90
                                endAngle = -180
                            default:
                                arcCenter = CGPoint(x: rect.maxX, y: rect.minY)
                                startAngle = 180
                                endAngle = 90
                            }
                            
                            arcPath.addArc(
                                center: arcCenter,
                                radius: size,
                                startAngle: .degrees(startAngle),
                                endAngle: .degrees(endAngle),
                                clockwise: true
                            )
                            context.stroke(arcPath, with: .color(.goldAccent), lineWidth: 3)
                            
                            // Draw number
                            if showNumbers {
                                let text = Text("\(fib)")
                                    .font(.system(size: max(8, size / 4), weight: .bold, design: .rounded))
                                    .foregroundColor(.goldAccent)
                                
                                context.draw(
                                    text,
                                    at: CGPoint(x: rect.midX, y: rect.midY)
                                )
                            }
                            
                            direction = (direction + 1) % 4
                        }
                    }
                    .frame(height: 380)
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 16) {
                    Slider(value: $animationProgress, in: 0...1)
                        .tint(.goldAccent)
                    
                    HStack {
                        Toggle("Show Numbers", isOn: $showNumbers)
                            .tint(.goldAccent)
                            .foregroundColor(.goldAccent)
                        
                        Spacer()
                        
                        Button("Animate") {
                            withAnimation(.easeInOut(duration: 3)) {
                                animationProgress = animationProgress < 1 ? 1 : 0
                            }
                        }
                        .foregroundColor(.goldAccent)
                    }
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Sequence display
                FlowLayout(spacing: 8) {
                    ForEach(fibonacciNumbers, id: \.self) { num in
                        Text("\(num)")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.goldAccent)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.goldAccent.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.goldAccent.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fibonacci Sequence")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.goldAccent)
                    
                    Text("Each number is the sum of the two preceding ones. As the sequence progresses, the ratio between consecutive numbers approaches φ (the golden ratio).")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animationProgress = 1
            }
        }
    }
}

// MARK: - Flower of Life View
struct FlowerOfLifeView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var layers = 3
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 400)
                    
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius: CGFloat = 35
                        
                        // Draw center circle
                        drawCircle(context: context, center: center, radius: radius, alpha: 1.0)
                        
                        // Draw surrounding circles
                        for layer in 1...layers {
                            let circlesInLayer = layer * 6
                            for i in 0..<circlesInLayer {
                                let angle = (Double(i) / Double(circlesInLayer)) * 2 * .pi
                                let distance = CGFloat(layer) * radius * 1.732 // √3 for perfect packing
                                
                                let x = center.x + cos(angle) * distance
                                let y = center.y + sin(angle) * distance
                                
                                let alpha = 1.0 - (Double(layer) * 0.15)
                                drawCircle(context: context, center: CGPoint(x: x, y: y), radius: radius, alpha: alpha)
                            }
                        }
                        
                        // Draw seed of life (center + 6)
                        if layers >= 1 {
                            for i in 0..<6 {
                                let angle = (Double(i) / 6.0) * 2 * .pi
                                let x = center.x + cos(angle) * radius
                                let y = center.y + sin(angle) * radius
                                drawCircle(context: context, center: CGPoint(x: x, y: y), radius: radius, alpha: 0.9, highlighted: true)
                            }
                        }
                    }
                    .frame(height: 380)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .animation(.linear(duration: 120).repeatForever(autoreverses: false), value: rotation)
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 16) {
                    HStack {
                        Text("Layers: \(layers)")
                            .foregroundColor(.goldAccent)
                        
                        Slider(value: .init(
                            get: { Double(layers) },
                            set: { layers = Int($0) }
                        ), in: 1...5, step: 1)
                        .tint(.goldAccent)
                    }
                    
                    Button("Pulse") {
                        withAnimation(.easeInOut(duration: 2).repeatCount(3, autoreverses: true)) {
                            scale = scale == 1.0 ? 1.1 : 1.0
                        }
                    }
                    .foregroundColor(.goldAccent)
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Flower of Life")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.goldAccent)
                    
                    Text("An ancient geometric pattern consisting of overlapping circles arranged in a hexagonal symmetry. It contains the Seed of Life and the Egg of Life within its structure.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                        .background(Color.goldAccent.opacity(0.3))
                    
                    Text("Found in: Egyptian temples, Chinese art, Phoenician art, and across many ancient civilizations.")
                        .font(.system(size: 12))
                        .foregroundColor(.goldAccent.opacity(0.7))
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            rotation = 360
        }
    }
    
    func drawCircle(context: GraphicsContext, center: CGPoint, radius: CGFloat, alpha: Double, highlighted: Bool = false) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let path = Path(ellipseIn: rect)
        
        context.stroke(path, with: .color(Color.goldAccent.opacity(alpha * (highlighted ? 1 : 0.6))), lineWidth: highlighted ? 2.5 : 1.5)
        
        if highlighted {
            context.fill(path, with: .color(Color.goldAccent.opacity(0.1)))
        }
    }
}

// MARK: - Metatron's Cube View
struct MetatronCubeView: View {
    @State private var rotation: Double = 0
    @State private var showPlatonic = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 400)
                    
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius: CGFloat = 120
                        
                        // 13 circles of Metatron's Cube
                        var circleCenters: [CGPoint] = [center]
                        
                        // Inner ring of 6
                        for i in 0..<6 {
                            let angle = (Double(i) / 6.0) * 2 * .pi - .pi / 2
                            let x = center.x + cos(angle) * radius * 0.5
                            let y = center.y + sin(angle) * radius * 0.5
                            circleCenters.append(CGPoint(x: x, y: y))
                        }
                        
                        // Outer ring of 6
                        for i in 0..<6 {
                            let angle = (Double(i) / 6.0) * 2 * .pi - .pi / 2
                            let x = center.x + cos(angle) * radius
                            let y = center.y + sin(angle) * radius
                            circleCenters.append(CGPoint(x: x, y: y))
                        }
                        
                        // Draw all circles
                        for (index, pt) in circleCenters.enumerated() {
                            let r: CGFloat = index == 0 ? radius * 0.35 : radius * 0.25
                            let rect = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                            let path = Path(ellipseIn: rect)
                            context.stroke(path, with: .color(Color.goldAccent.opacity(0.8)), lineWidth: 2)
                            context.fill(path, with: .color(Color.goldAccent.opacity(0.05)))
                        }
                        
                        // Draw lines connecting all circles
                        for i in 0..<circleCenters.count {
                            for j in (i+1)..<circleCenters.count {
                                var line = Path()
                                line.move(to: circleCenters[i])
                                line.addLine(to: circleCenters[j])
                                context.stroke(line, with: .color(Color.goldAccent.opacity(0.4)), lineWidth: 1)
                            }
                        }
                        
                        // Draw platonic solids outlines if enabled
                        if showPlatonic {
                            // Tetrahedron (using 4 points)
                            drawPlatonicSolid(context: context, centers: Array(circleCenters[0...3]), color: .red.opacity(0.6))
                        }
                    }
                    .frame(height: 380)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: 180).repeatForever(autoreverses: false), value: rotation)
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 16) {
                    Toggle("Show Platonic Solids", isOn: $showPlatonic)
                        .tint(.goldAccent)
                        .foregroundColor(.goldAccent)
                    
                    Button("Reset Rotation") {
                        withAnimation {
                            rotation = 0
                        }
                    }
                    .foregroundColor(.goldAccent)
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Metatron's Cube")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.goldAccent)
                    
                    Text("A sacred geometric symbol derived from the Flower of Life. Contains all 5 Platonic solids within its structure, representing the building blocks of the universe.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                        .background(Color.goldAccent.opacity(0.3))
                    
                    Text("Named after the archangel Metatron, who guards the Tree of Life in Jewish mysticism.")
                        .font(.system(size: 12))
                        .foregroundColor(.goldAccent.opacity(0.7))
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            rotation = 360
        }
    }
    
    func drawPlatonicSolid(context: GraphicsContext, centers: [CGPoint], color: Color) {
        // Connect all points to form the solid
        for i in 0..<centers.count {
            for j in (i+1)..<centers.count {
                var line = Path()
                line.move(to: centers[i])
                line.addLine(to: centers[j])
                context.stroke(line, with: .color(color), lineWidth: 2)
            }
        }
    }
}

// MARK: - Pi Visualization View
struct PiVisualizationView: View {
    @State private var digits = "3.14159265358979323846264338327950288419716939937510"
    @State private var currentDigit = 0
    @State private var visualizationMode: PiMode = .circle
    
    enum PiMode: String, CaseIterable {
        case circle = "Circle"
        case spiral = "Spiral"
        case bars = "Bars"
        case mandala = "Mandala"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Pi display
                Text("π")
                    .font(.system(size: 80, weight: .thin, design: .serif))
                    .foregroundColor(.goldAccent)
                
                // Digits display
                Text(String(digits.prefix(currentDigit + 2)))
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.goldAccent)
                    .minimumScaleFactor(0.5)
                    .padding()
                    .glassmorphic()
                    .padding(.horizontal)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            if currentDigit < digits.count - 2 {
                                currentDigit += 1
                            } else {
                                timer.invalidate()
                            }
                        }
                    }
                
                // Visualization
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 350)
                    
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        
                        switch visualizationMode {
                        case .circle:
                            drawPiCircle(context: context, center: center, size: size)
                        case .spiral:
                            drawPiSpiral(context: context, center: center)
                        case .bars:
                            drawPiBars(context: context, center: center, size: size)
                        case .mandala:
                            drawPiMandala(context: context, center: center)
                        }
                    }
                    .frame(height: 330)
                }
                .padding(.horizontal)
                
                // Mode selector
                Picker("Mode", selection: $visualizationMode) {
                    ForEach(PiMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Pi facts
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Circle Constant")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.goldAccent)
                    
                    Text("π = Circumference / Diameter")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.goldAccent.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FactRow(icon: "infinity", text: "Irrational - never repeats or terminates")
                        FactRow(icon: "function", text: "Transcendental - not a root of any polynomial")
                        FactRow(icon: "cpu", text: "Computed to 100 trillion digits (2024)")
                    }
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    func drawPiCircle(context: GraphicsContext, center: CGPoint, size: CGSize) {
        let radius = min(size.width, size.height) * 0.35
        
        // Outer circle (circumference)
        var circle = Path()
        circle.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        context.stroke(circle, with: .color(.goldAccent), lineWidth: 3)
        
        // Diameter line
        var diameter = Path()
        diameter.move(to: CGPoint(x: center.x - radius, y: center.y))
        diameter.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        context.stroke(diameter, with: .color(.goldAccent.opacity(0.7)), lineWidth: 2)
        
        // Labels
        let circumferenceText = Text("C = πd")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.goldAccent)
        context.draw(circumferenceText, at: CGPoint(x: center.x, y: center.y - radius - 20))
        
        let diameterText = Text("d")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.goldAccent.opacity(0.8))
        context.draw(diameterText, at: CGPoint(x: center.x, y: center.y + 15))
    }
    
    func drawPiSpiral(context: GraphicsContext, center: CGPoint) {
        let digitValues = digits.compactMap { Int(String($0)) }.filter { $0 >= 0 }
        var spiral = Path()
        var currentPoint = center
        var angle: Double = 0
        
        spiral.move(to: currentPoint)
        
        for (index, digit) in digitValues.enumerated() {
            guard index < 20 else { break }
            let stepSize = CGFloat(digit + 1) * 3
            angle += Double(digit) * 0.3
            
            let newX = currentPoint.x + cos(angle) * stepSize
            let newY = currentPoint.y + sin(angle) * stepSize
            
            spiral.addLine(to: CGPoint(x: newX, y: newY))
            currentPoint = CGPoint(x: newX, y: newY)
            
            // Draw digit at point
            let digitText = Text("\(digit)")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color.goldAccent.opacity(0.7))
            context.draw(digitText, at: currentPoint)
        }
        
        context.stroke(spiral, with: .color(.goldAccent), lineWidth: 2)
    }
    
    func drawPiBars(context: GraphicsContext, center: CGPoint, size: CGSize) {
        let digitValues = digits.compactMap { Int(String($0)) }
        let barWidth: CGFloat = 12
        let spacing: CGFloat = 4
        let startX = center.x - (CGFloat(min(digitValues.count, 20)) * (barWidth + spacing)) / 2
        
        for (index, digit) in digitValues.enumerated() {
            guard index < 20 else { break }
            let barHeight = CGFloat(digit) * 15
            let x = startX + CGFloat(index) * (barWidth + spacing)
            let rect = CGRect(x: x, y: center.y - barHeight/2, width: barWidth, height: barHeight)
            
            let barPath = Path(rect)
            let opacity = 0.3 + (0.7 * Double(digit) / 9.0)
            context.fill(barPath, with: .color(Color.goldAccent.opacity(opacity)))
            context.stroke(barPath, with: .color(.goldAccent), lineWidth: 1)
        }
    }
    
    func drawPiMandala(context: GraphicsContext, center: CGPoint) {
        let digitValues = digits.compactMap { Int(String($0)) }
        
        for (index, digit) in digitValues.enumerated() {
            guard index < 15 else { break }
            let angle = (Double(index) / 15.0) * 2 * .pi
            let distance = 50 + CGFloat(digit) * 8
            
            let x = center.x + cos(angle) * distance
            let y = center.y + sin(angle) * distance
            
            let radius = CGFloat(digit + 2) * 2
            let circlePath = Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
            context.fill(circlePath, with: .color(Color.goldAccent.opacity(0.3 + Double(digit) * 0.07)))
            context.stroke(circlePath, with: .color(.goldAccent), lineWidth: 1)
            
            // Connect to center
            var line = Path()
            line.move(to: center)
            line.addLine(to: CGPoint(x: x, y: y))
            context.stroke(line, with: .color(Color.goldAccent.opacity(0.3)), lineWidth: 0.5)
        }
    }
}

struct FactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.goldAccent)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
    }
}

// MARK: - Platonic Solids View
struct PlatonicSolidsView: View {
    @State private var selectedSolid: PlatonicSolid = .tetrahedron
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var autoRotate = true
    
    enum PlatonicSolid: String, CaseIterable {
        case tetrahedron = "Tetrahedron"
        case cube = "Cube"
        case octahedron = "Octahedron"
        case dodecahedron = "Dodecahedron"
        case icosahedron = "Icosahedron"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 3D Scene
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 400)
                    
                    PlatonicSolidScene(solid: selectedSolid, rotationX: rotationX, rotationY: rotationY)
                        .frame(height: 380)
                }
                .padding(.horizontal)
                
                // Solid selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PlatonicSolid.allCases, id: \.self) { solid in
                            Button(action: { selectedSolid = solid }) {
                                VStack(spacing: 8) {
                                    Text(solidIcon(solid))
                                        .font(.system(size: 32))
                                    Text(solid.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(selectedSolid == solid ? .black : .goldAccent)
                                .frame(width: 100, height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedSolid == solid ? Color.goldAccent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.goldAccent.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Controls
                VStack(spacing: 16) {
                    Toggle("Auto Rotate", isOn: $autoRotate)
                        .tint(.goldAccent)
                        .foregroundColor(.goldAccent)
                    
                    if !autoRotate {
                        VStack(spacing: 8) {
                            HStack {
                                Text("X Rotation")
                                    .foregroundColor(.goldAccent)
                                    .font(.caption)
                                Spacer()
                            }
                            Slider(value: $rotationX, in: 0...360)
                                .tint(.goldAccent)
                            
                            HStack {
                                Text("Y Rotation")
                                    .foregroundColor(.goldAccent)
                                    .font(.caption)
                                Spacer()
                            }
                            Slider(value: $rotationY, in: 0...360)
                                .tint(.goldAccent)
                        }
                    }
                }
                .padding()
                .glassmorphic()
                .padding(.horizontal)
                
                // Solid information
                SolidInfoCard(solid: selectedSolid)
                    .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            if autoRotate {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotationX = 360
                    rotationY = 360
                }
            }
        }
        .onChange(of: autoRotate) { newValue in
            if newValue {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotationX += 360
                    rotationY += 360
                }
            }
        }
    }
    
    func solidIcon(_ solid: PlatonicSolid) -> String {
        switch solid {
        case .tetrahedron: return "△"
        case .cube: return "⬜"
        case .octahedron: return "◆"
        case .dodecahedron: return "⬠"
        case .icosahedron: return "◉"
        }
    }
}

struct PlatonicSolidScene: UIViewRepresentable {
    let solid: PlatonicSolidsView.PlatonicSolid
    let rotationX: Double
    let rotationY: Double
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        updateScene(sceneView)
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        updateScene(uiView)
    }
    
    func updateScene(_ sceneView: SCNView) {
        sceneView.scene?.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        let geometry: SCNGeometry
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.898, green: 0.757, blue: 0.345, alpha: 0.6)
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.transparency = 0.7
        
        switch solid {
        case .tetrahedron:
            geometry = SCNTetrahedron(radius: 1.5)
        case .cube:
            geometry = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.1)
        case .octahedron:
            geometry = SCNOctahedron(radius: 1.5)
        case .dodecahedron:
            geometry = SCNDodecahedron(radius: 1.5)
        case .icosahedron:
            geometry = SCNIcosahedron(radius: 1.5)
        }
        
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.eulerAngles = SCNVector3(Float(rotationX * .pi / 180), Float(rotationY * .pi / 180), 0)
        
        // Add wireframe overlay
        let wireMaterial = SCNMaterial()
        wireMaterial.diffuse.contents = UIColor.clear
        wireMaterial.emission.contents = UIColor(red: 0.898, green: 0.757, blue: 0.345, alpha: 1.0)
        
        let wireGeometry = geometry.copy() as! SCNGeometry
        wireGeometry.materials = [wireMaterial]
        let wireNode = SCNNode(geometry: wireGeometry)
        wireNode.scale = SCNVector3(1.01, 1.01, 1.01)
        
        node.addChildNode(wireNode)
        sceneView.scene?.rootNode.addChildNode(node)
        
        // Add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 6)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        // Add lights
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(5, 5, 5)
        sceneView.scene?.rootNode.addChildNode(lightNode)
    }
}

// MARK: - Platonic Solid Geometry Extensions
class SCNTetrahedron: SCNGeometry {
    convenience init(radius: CGFloat) {
        let vertices: [SCNVector3] = [
            SCNVector3(1, 1, 1), SCNVector3(-1, -1, 1),
            SCNVector3(-1, 1, -1), SCNVector3(1, -1, -1)
        ].map { SCNVector3($0.x * Float(radius) / sqrt(3), $0.y * Float(radius) / sqrt(3), $0.z * Float(radius) / sqrt(3)) }
        
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2]
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        self.init(sources: [source], elements: [element])
    }
}

class SCNOctahedron: SCNGeometry {
    convenience init(radius: CGFloat) {
        let vertices: [SCNVector3] = [
            SCNVector3(1, 0, 0), SCNVector3(-1, 0, 0),
            SCNVector3(0, 1, 0), SCNVector3(0, -1, 0),
            SCNVector3(0, 0, 1), SCNVector3(0, 0, -1)
        ].map { SCNVector3($0.x * Float(radius), $0.y * Float(radius), $0.z * Float(radius)) }
        
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [
            0, 2, 4, 2, 1, 4, 1, 3, 4, 3, 0, 4,
            2, 0, 5, 1, 2, 5, 3, 1, 5, 0, 3, 5
        ]
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        self.init(sources: [source], elements: [element])
    }
}

class SCNDodecahedron: SCNGeometry {
    convenience init(radius: CGFloat) {
        let phi = Float(1.618033988749895)
        let invPhi = 1 / phi
        
        let vertices: [SCNVector3] = [
            SCNVector3(1, 1, 1), SCNVector3(1, 1, -1), SCNVector3(1, -1, 1), SCNVector3(1, -1, -1),
            SCNVector3(-1, 1, 1), SCNVector3(-1, 1, -1), SCNVector3(-1, -1, 1), SCNVector3(-1, -1, -1),
            SCNVector3(0, invPhi, phi), SCNVector3(0, invPhi, -phi), SCNVector3(0, -invPhi, phi), SCNVector3(0, -invPhi, -phi),
            SCNVector3(invPhi, phi, 0), SCNVector3(invPhi, -phi, 0), SCNVector3(-invPhi, phi, 0), SCNVector3(-invPhi, -phi, 0),
            SCNVector3(phi, 0, invPhi), SCNVector3(phi, 0, -invPhi), SCNVector3(-phi, 0, invPhi), SCNVector3(-phi, 0, -invPhi)
        ].map { SCNVector3($0.x * Float(radius) / sqrt(3), $0.y * Float(radius) / sqrt(3), $0.z * Float(radius) / sqrt(3)) }
        
        let source = SCNGeometrySource(vertices: vertices)
        // Simplified faces
        let indices: [Int32] = Array(0..<60)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        self.init(sources: [source], elements: [element])
    }
}

class SCNIcosahedron: SCNGeometry {
    convenience init(radius: CGFloat) {
        let phi = Float(1.618033988749895)
        
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, phi), SCNVector3(0, 1, -phi), SCNVector3(0, -1, phi), SCNVector3(0, -1, -phi),
            SCNVector3(1, phi, 0), SCNVector3(1, -phi, 0), SCNVector3(-1, phi, 0), SCNVector3(-1, -phi, 0),
            SCNVector3(phi, 0, 1), SCNVector3(phi, 0, -1), SCNVector3(-phi, 0, 1), SCNVector3(-phi, 0, -1)
        ].map { SCNVector3($0.x * Float(radius) / sqrt(1 + phi*phi), $0.y * Float(radius) / sqrt(1 + phi*phi), $0.z * Float(radius) / sqrt(1 + phi*phi)) }
        
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [
            0, 4, 6, 0, 6, 10, 0, 10, 2, 0, 2, 8, 0, 8, 4,
            3, 1, 7, 3, 7, 11, 3, 11, 9, 3, 9, 5, 3, 5, 1,
            1, 4, 9, 9, 4, 8, 9, 8, 5, 5, 8, 2, 5, 2, 7,
            7, 2, 10, 7, 10, 11, 11, 10, 6, 11, 6, 1, 1, 6, 4
        ]
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        self.init(sources: [source], elements: [element])
    }
}

struct SolidInfoCard: View {
    let solid: PlatonicSolidsView.PlatonicSolid
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(solid.rawValue)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(.goldAccent)
            
            HStack(spacing: 20) {
                InfoItem(label: "Faces", value: faceCount)
                InfoItem(label: "Edges", value: edgeCount)
                InfoItem(label: "Vertices", value: vertexCount)
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            if let element = elementAssociation {
                Text("Element: \(element)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.goldAccent.opacity(0.8))
            }
        }
        .padding()
        .glassmorphic()
    }
    
    var faceCount: String {
        switch solid {
        case .tetrahedron: return "4"
        case .cube: return "6"
        case .octahedron: return "8"
        case .dodecahedron: return "12"
        case .icosahedron: return "20"
        }
    }
    
    var edgeCount: String {
        switch solid {
        case .tetrahedron: return "6"
        case .cube: return "12"
        case .octahedron: return "12"
        case .dodecahedron: return "30"
        case .icosahedron: return "30"
        }
    }
    
    var vertexCount: String {
        switch solid {
        case .tetrahedron: return "4"
        case .cube: return "8"
        case .octahedron: return "6"
        case .dodecahedron: return "20"
        case .icosahedron: return "12"
        }
    }
    
    var description: String {
        switch solid {
        case .tetrahedron:
            return "The simplest Platonic solid, representing the element of Fire. All four faces are equilateral triangles."
        case .cube:
            return "Also known as the hexahedron, representing Earth. All six faces are squares."
        case .octahedron:
            return "Representing Air, with eight equilateral triangular faces. It is the dual of the cube."
        case .dodecahedron:
            return "Representing the Universe or Aether, with twelve regular pentagonal faces."
        case .icosahedron:
            return "Representing Water, with twenty equilateral triangular faces. It has the most faces of any Platonic solid."
        }
    }
    
    var elementAssociation: String? {
        switch solid {
        case .tetrahedron: return "🔥 Fire"
        case .cube: return "🌍 Earth"
        case .octahedron: return "💨 Air"
        case .dodecahedron: return "✨ Aether/Spirit"
        case .icosahedron: return "💧 Water"
        }
    }
}

struct InfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.goldAccent)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(minWidth: 50)
    }
}

// MARK: - Golden Calculator View
struct GoldenCalculatorView: View {
    @State private var inputValue: String = "100"
    @State private var calculationMode: CalcMode = .goldenSection
    
    enum CalcMode: String, CaseIterable {
        case goldenSection = "Golden Section"
        case goldenRectangle = "Golden Rectangle"
        case fibonacciApprox = "Fibonacci Approx"
        case proportion = "Proportion"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Input
                VStack(spacing: 16) {
                    TextField("Enter value", text: $inputValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                        .foregroundColor(.goldAccent)
                        .multilineTextAlignment(.center)
                        .padding()
                        .glassmorphic()
                    
                    Picker("Mode", selection: $calculationMode) {
                        ForEach(CalcMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorMultiply(.goldAccent)
                }
                .padding(.horizontal)
                
                // Results
                VStack(spacing: 16) {
                    switch calculationMode {
                    case .goldenSection:
                        GoldenSectionResults(value: inputValue)
                    case .goldenRectangle:
                        GoldenRectangleResults(value: inputValue)
                    case .fibonacciApprox:
                        FibonacciApproxResults(value: inputValue)
                    case .proportion:
                        ProportionResults(value: inputValue)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct GoldenSectionResults: View {
    let value: String
    let phi = 1.618033988749895
    
    var numericValue: Double {
        Double(value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ResultCard(
                title: "Longer Section (a)",
                formula: "a = total / φ",
                result: numericValue / phi
            )
            
            ResultCard(
                title: "Shorter Section (b)",
                formula: "b = a / φ",
                result: numericValue / phi / phi
            )
            
            ResultCard(
                title: "Product (× φ)",
                formula: "x × φ",
                result: numericValue * phi
            )
            
            ResultCard(
                title: "Quotient (÷ φ)",
                formula: "x ÷ φ",
                result: numericValue / phi
            )
            
            // Visual representation
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.goldAccent.opacity(0.2))
                    .frame(height: 60)
                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.goldAccent.opacity(0.6))
                        .frame(width: UIScreen.main.bounds.width * 0.5 * (1/phi) * 0.8)
                    
                    Rectangle()
                        .fill(Color.goldAccent.opacity(0.3))
                        .frame(width: UIScreen.main.bounds.width * 0.5 * (1/phi/phi) * 0.8)
                }
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            
            HStack {
                Label("Longer (a)", color: Color.goldAccent.opacity(0.6))
                Label("Shorter (b)", color: Color.goldAccent.opacity(0.3))
            }
            .font(.caption)
        }
    }
    
    struct Label: View {
        let text: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(text)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let formula: String
    let result: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.goldAccent)
                Text(formula)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text(String(format: "%.6f", result))
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.goldAccent)
        }
        .padding()
        .glassmorphic()
    }
}

struct GoldenRectangleResults: View {
    let value: String
    let phi = 1.618033988749895
    
    var numericValue: Double {
        Double(value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ResultCard(
                title: "Width (shorter side)",
                formula: "w = h / φ",
                result: numericValue / phi
            )
            
            ResultCard(
                title: "Height (longer side)",
                formula: "h = w × φ",
                result: numericValue * phi
            )
            
            ResultCard(
                title: "Diagonal",
                formula: "d = √(w² + h²)",
                result: sqrt(pow(numericValue, 2) + pow(numericValue * phi, 2))
            )
            
            ResultCard(
                title: "Aspect Ratio",
                formula: "w:h = 1:φ",
                result: phi
            )
        }
    }
}

struct FibonacciApproxResults: View {
    let value: String
    let phi = 1.618033988749895
    
    var numericValue: Double {
        Double(value) ?? 0
    }
    
    var body: some View {
        let ratio = numericValue > 0 ? calculateFibonacciRatio(n: Int(numericValue)) : 0
        
        VStack(spacing: 16) {
            ResultCard(
                title: "Fibonacci Ratio",
                formula: "F(n+1) / F(n)",
                result: ratio
            )
            
            ResultCard(
                title: "Difference from φ",
                formula: "|ratio - φ|",
                result: abs(ratio - phi)
            )
            
            ResultCard(
                title: "Percentage of φ",
                formula: "(ratio / φ) × 100",
                result: (ratio / phi) * 100
            )
            
            // Fibonacci sequence display
            VStack(alignment: .leading, spacing: 8) {
                Text("Sequence")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.goldAccent)
                
                Text(fibonacciSequence(upTo: min(Int(numericValue), 15)))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .glassmorphic()
        }
    }
    
    func calculateFibonacciRatio(n: Int) -> Double {
        if n <= 0 { return 0 }
        let fibN = fibonacci(n)
        let fibN1 = fibonacci(n + 1)
        return Double(fibN1) / Double(fibN)
    }
    
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        var a = 0, b = 1
        for _ in 2...n {
            let temp = a + b
            a = b
            b = temp
        }
        return b
    }
    
    func fibonacciSequence(upTo n: Int) -> String {
        let sequence = (0...n).map { fibonacci($0) }
        return sequence.map { String($0) }.joined(separator: ", ")
    }
}

struct ProportionResults: View {
    let value: String
    let phi = 1.618033988749895
    
    var numericValue: Double {
        Double(value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ResultCard(
                title: "φ² (Phi Squared)",
                formula: "φ × φ",
                result: phi * phi
            )
            
            ResultCard(
                title: "1/φ (Golden Ratio Conjugate)",
                formula: "1 / φ",
                result: 1 / phi
            )
            
            ResultCard(
                title: "φ³",
                formula: "φ × φ × φ",
                result: phi * phi * phi
            )
            
            ResultCard(
                title: "Your Value × φ²",
                formula: "x × φ²",
                result: numericValue * phi * phi
            )
            
            ResultCard(
                title: "Your Value / φ²",
                formula: "x / φ²",
                result: numericValue / phi / phi
            )
        }
    }
}

// MARK: - Nature Proportions View
struct NatureProportionsView: View {
    let examples: [NatureExample] = [
        NatureExample(
            name: "Nautilus Shell",
            description: "The spiral of a nautilus shell grows at a rate close to the golden ratio.",
            ratio: 1.618,
            image: "🐚"
        ),
        NatureExample(
            name: "Sunflower Seeds",
            description: "Seeds are arranged in Fibonacci spirals for optimal packing.",
            ratio: 1.618,
            image: "🌻"
        ),
        NatureExample(
            name: "Human Body",
            description: "The ratio of forearm to hand, and many other proportions approximate φ.",
            ratio: 1.618,
            image: "🧍"
        ),
        NatureExample(
            name: "Pinecone",
            description: "Spirals follow Fibonacci numbers (8 and 13, or 5 and 8).",
            ratio: 1.625,
            image: "🌲"
        ),
        NatureExample(
            name: "Hurricane",
            description: "The spiral pattern of hurricanes often follows the golden spiral.",
            ratio: 1.618,
            image: "🌀"
        ),
        NatureExample(
            name: "DNA",
            description: "The double helix measures 34 angstroms by 21 angstroms (Fibonacci numbers).",
            ratio: 1.619,
            image: "🧬"
        ),
        NatureExample(
            name: "Galaxy",
            description: "Spiral galaxies often exhibit golden spiral patterns.",
            ratio: 1.618,
            image: "🌌"
        ),
        NatureExample(
            name: "Flower Petals",
            description: "Most flowers have petal counts that are Fibonacci numbers.",
            ratio: 1.618,
            image: "🌸"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Sacred proportions appear throughout nature, from the microscopic to the cosmic.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding()
                
                ForEach(examples) { example in
                    NatureExampleCard(example: example)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct NatureExample: Identifiable {
    let id = UUID()
    let name: String
       let description: String
    let ratio: Double
    let image: String
}

struct NatureExampleCard: View {
    let example: NatureExample
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Text(example.image)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(example.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.goldAccent)
                    
                    Text("Ratio: \(String(format: "%.3f", example.ratio))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.goldAccent.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.goldAccent)
            }
            
            if isExpanded {
                Text(example.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .transition(.opacity)
            }
        }
        .padding()
        .glassmorphic()
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Interactive Drawing View
struct InteractiveDrawingView: View {
    @State private var lines: [Line] = []
    @State private var currentLine: Line?
    @State private var selectedTool: DrawingTool = .pen
    @State private var strokeColor: Color = .goldAccent
    @State private var lineWidth: CGFloat = 2
    @State private var showGrid = true
    @State private var snapToGeometry = false
    
    enum DrawingTool: String, CaseIterable {
        case pen = "Pen"
        case line = "Line"
        case circle = "Circle"
        case golden = "Golden"
        case flower = "Flower"
        case clear = "Clear"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                    )
                
                if showGrid {
                    DrawingGrid()
                }
                
                Canvas { context, size in
                    // Draw existing lines
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.width)
                    }
                    
                    // Draw current line
                    if let currentLine = currentLine {
                        var path = Path()
                        path.addLines(currentLine.points)
                        context.stroke(path, with: .color(currentLine.color), lineWidth: currentLine.width)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { value in
                            handleDragEnded(value)
                        }
                )
            }
            .padding()
            
            // Toolbar
            VStack(spacing: 12) {
                // Tool selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DrawingTool.allCases, id: \.self) { tool in
                            Button(action: {
                                if tool == .clear {
                                    lines = []
                                } else {
                                    selectedTool = tool
                                    if tool == .golden || tool == .flower {
                                        addGeometricPattern(tool)
                                    }
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: toolIcon(tool))
                                        .font(.system(size: 20))
                                    Text(tool.rawValue)
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(selectedTool == tool && tool != .clear ? .black : .goldAccent)
                                .frame(width: 60, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedTool == tool && tool != .clear ? Color.goldAccent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.goldAccent.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Settings
                HStack(spacing: 16) {
                    Toggle("Grid", isOn: $showGrid)
                        .tint(.goldAccent)
                        .foregroundColor(.goldAccent)
                    
                    Toggle("Snap", isOn: $snapToGeometry)
                        .tint(.goldAccent)
                        .foregroundColor(.goldAccent)
                    
                    Spacer()
                    
                    // Color picker
                    HStack(spacing: 8) {
                        ForEach([Color.goldAccent, .white, .cyan, .magenta, .green], id: \.self) { color in
                            Button(action: { strokeColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: strokeColor == color ? 2 : 0)
                                    )
                            }
                        }
                    }
                }
                .font(.caption)
                .padding(.horizontal)
                
                // Line width
                HStack {
                    Text("Width")
                        .foregroundColor(.goldAccent)
                        .font(.caption)
                    Slider(value: $lineWidth, in: 1...10)
                        .tint(.goldAccent)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .glassmorphic()
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    func toolIcon(_ tool: DrawingTool) -> String {
        switch tool {
        case .pen: return "pencil"
        case .line: return "line.diagonal"
        case .circle: return "circle"
        case .golden: return "rectangle.split.2x1"
        case .flower: return "circle.hexagongrid"
        case .clear: return "trash"
        }
    }
    
    func handleDragChanged(_ value: DragGesture.Value) {
        let point = value.location
        
        if currentLine == nil {
            currentLine = Line(
                points: [point],
                color: strokeColor,
                width: lineWidth
            )
        } else {
            var points = currentLine?.points ?? []
            
            // Snap to grid if enabled
            var finalPoint = point
            if snapToGeometry {
                let gridSize: CGFloat = 40
                finalPoint.x = round(point.x / gridSize) * gridSize
                finalPoint.y = round(point.y / gridSize) * gridSize
            }
            
            if selectedTool == .line && points.count >= 2 {
                points = [points.first!, finalPoint]
            } else {
                points.append(finalPoint)
            }
            
            currentLine?.points = points
        }
    }
    
    func handleDragEnded(_ value: DragGesture.Value) {
        if let line = currentLine {
            if selectedTool == .circle {
                // Convert to circle
                if let first = line.points.first, let last = line.points.last {
                    let radius = hypot(last.x - first.x, last.y - first.y)
                    var circleLine = line
                    circleLine.points = circlePoints(center: first, radius: radius)
                    lines.append(circleLine)
                }
            } else {
                lines.append(line)
            }
        }
        currentLine = nil
    }
    
    func circlePoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        for i in 0...36 {
            let angle = Double(i) * 2 * .pi / 36
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    func addGeometricPattern(_ tool: DrawingTool) {
        let center = CGPoint(x: 200, y: 300)
        
        if tool == .golden {
            // Add golden spiral
            var goldenLine = Line(points: [], color: strokeColor, width: lineWidth)
            let phi: CGFloat = 1.618
            var currentRadius: CGFloat = 10
            var currentAngle: Double = 0
            
            for i in 0...100 {
                let angle = Double(i) * 0.1
                currentRadius = 10 * pow(phi, angle / (.pi / 2))
                let x = center.x + cos(angle) * currentRadius
                let y = center.y + sin(angle) * currentRadius
                goldenLine.points.append(CGPoint(x: x, y: y))
            }
            lines.append(goldenLine)
        } else if tool == .flower {
            // Add flower of life pattern
            let radius: CGFloat = 30
            
            // Center circle
            lines.append(Line(points: circlePoints(center: center, radius: radius), color: strokeColor, width: lineWidth))
            
            // Surrounding circles
            for i in 0..<6 {
                let angle = (Double(i) / 6.0) * 2 * .pi
                let x = center.x + cos(angle) * radius
                let y = center.y + sin(angle) * radius
                lines.append(Line(points: circlePoints(center: CGPoint(x: x, y: y), radius: radius), color: strokeColor, width: lineWidth))
            }
        }
    }
}

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    let color: Color
    let width: CGFloat
}

struct DrawingGrid: View {
    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 40
            
            for x in stride(from: 0, to: size.width, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.goldAccent.opacity(0.1)), lineWidth: 0.5)
            }
            
            for y in stride(from: 0, to: size.height, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.goldAccent.opacity(0.1)), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - Export Sheet
struct ExportSheet: View {
    let image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Text("No image to export")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button("Save to Photos") {
                    if let image = image {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.goldAccent)
                .padding()
            }
            .navigationTitle("Export Pattern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX, y: result.positions[index].y + bounds.minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Glassmorphism Modifier
struct GlassmorphicModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.goldAccent.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassmorphic() -> some View {
        modifier(GlassmorphicModifier())
    }
}

// MARK: - Color Extensions
extension Color {
    static let goldAccent = Color(hex: "#E5C158")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct SacredGeometryView_Previews: PreviewProvider {
    static var previews: some View {
        SacredGeometryView()
            .preferredColorScheme(.dark)
    }
}