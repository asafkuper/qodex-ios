//
//  ARChartVisualization.swift
//  Augmented Reality birth chart display
//

import SwiftUI
import ARKit
import RealityKit

@available(iOS 17.0, *)
struct ARChartView: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if viewModel.shouldPlaceChart {
            placeChart(in: uiView)
            viewModel.shouldPlaceChart = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func placeChart(in arView: ARView) {
        // Create anchor
        let anchor = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: [0.5, 0.5])
        
        // Create 3D chart visualization
        let chartEntity = create3DChart()
        anchor.addChild(chartEntity)
        
        arView.scene.addAnchor(anchor)
        
        // Animate entry
        chartEntity.transform.scale = [0.001, 0.001, 0.001]
        chartEntity.move(to: Transform(scale: [1, 1, 1]), relativeTo: chartEntity, duration: 1.0, timingFunction: .easeOut)
    }
    
    private func create3DChart() -> Entity {
        let rootEntity = Entity()
        
        // Central sphere (Life Path)
        let lifePathSphere = createSphere(radius: 0.15, color: .gold)
        lifePathSphere.position = [0, 0.15, 0]
        rootEntity.addChild(lifePathSphere)
        
        // Orbiting numbers
        let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        for (index, number) in numbers.enumerated() {
            let angle = Float(index) * (2 * .pi / Float(numbers.count))
            let radius: Float = 0.5
            
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            
            let numberEntity = createNumberEntity(number: number)
            numberEntity.position = [x, 0.1, z]
            rootEntity.addChild(numberEntity)
            
            // Animate orbit
            var orbit = Transform()
            orbit.rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
            
            // Add continuous rotation
            numberEntity.move(to: Transform(rotation: simd_quatf(angle: angle + 2 * .pi, axis: [0, 1, 0])), relativeTo: rootEntity, duration: 60, timingFunction: .linear)
        }
        
        // Sacred geometry overlay
        let flowerOfLife = createFlowerOfLife()
        flowerOfLife.position = [0, 0.01, 0]
        rootEntity.addChild(flowerOfLife)
        
        return rootEntity
    }
    
    private func createSphere(radius: Float, color: UIColor) -> Entity {
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    private func createNumberEntity(number: Int) -> Entity {
        let sphere = createSphere(radius: 0.05, color: .systemPurple)
        
        // Add text label
        // In RealityKit 2.0+, we can use TextEntity
        // For now, we'll use a simple visual indicator
        
        return sphere
    }
    
    private func createFlowerOfLife() -> Entity {
        // Create overlapping circles pattern
        let root = Entity()
        
        let centerCircle = createCircle(radius: 0.3)
        root.addChild(centerCircle)
        
        // Six surrounding circles
        for i in 0..<6 {
            let angle = Float(i) * (.pi / 3)
            let x = 0.3 * cos(angle)
            let z = 0.3 * sin(angle)
            
            let circle = createCircle(radius: 0.3)
            circle.position = [x, 0, z]
            root.addChild(circle)
        }
        
        return root
    }
    
    private func createCircle(radius: Float) -> Entity {
        let torus = MeshResource.generateTorus(ringRadius: radius, pipeRadius: 0.01)
        let material = SimpleMaterial(color: .gold, isMetallic: false)
        let entity = ModelEntity(mesh: torus, materials: [material])
        entity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        return entity
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARChartView
        
        init(_ parent: ARChartView) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // Handle plane detection
        }
    }
}

@available(iOS 17.0, *)
class ARViewModel: ObservableObject {
    @Published var shouldPlaceChart = false
    @Published var isScanning = true
    @Published var detectedPlanes = 0
    
    func placeChart() {
        shouldPlaceChart = true
    }
}

@available(iOS 17.0, *)
struct ARChartContainer: View {
    @StateObject private var viewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARChartView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if viewModel.isScanning {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Scanning for surfaces...")
                            .font(.headline)
                        
                        Text("Point your camera at a flat surface")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                
                Button("Place Chart") {
                    viewModel.placeChart()
                }
                .buttonStyle(QXPrimaryButtonStyle())
                .padding()
            }
        }
    }
}
