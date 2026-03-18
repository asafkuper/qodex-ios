//
//  SacredGeometryBackground.swift
//  QodeX Design System - Background Component
//

import SwiftUI

// MARK: - Sacred Geometry Background
public struct SacredGeometryBackground: View {
    @State private var rotation: Double = 0
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                QXColor.cosmicBlack
                    .ignoresSafeArea()
                
                // Animated sacred geometry pattern - respects Reduce Motion
                if UIAccessibility.isReduceMotionEnabled {
                    // Static version for accessibility
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = min(size.width, size.height) * 0.4
                        
                        // Draw static flower of life pattern
                        for i in 0..<6 {
                            let angle = Double(i) * .pi / 3
                            let x = center.x + cos(angle) * radius * 0.5
                            let y = center.y + sin(angle) * radius * 0.5
                            
                            let path = Path { p in
                                p.addEllipse(in: CGRect(
                                    x: x - radius * 0.3,
                                    y: y - radius * 0.3,
                                    width: radius * 0.6,
                                    height: radius * 0.6
                                ))
                            }
                            context.stroke(path, with: .color(QXColor.gold.opacity(0.1)), lineWidth: 1)
                        }
                        
                        // Center circle
                        let centerPath = Path { p in
                            p.addEllipse(in: CGRect(
                                x: center.x - radius * 0.3,
                                y: center.y - radius * 0.3,
                                width: radius * 0.6,
                                height: radius * 0.6
                            ))
                        }
                        context.stroke(centerPath, with: .color(QXColor.gold.opacity(0.15)), lineWidth: 1.5)
                    }
                    .blur(radius: 0.5)
                    .accessibilityHidden(true) // Decorative element
                } else {
                    // Animated version
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = min(size.width, size.height) * 0.4
                        
                        // Draw flower of life pattern
                        for i in 0..<6 {
                            let angle = Double(i) * .pi / 3 + rotation * .pi / 180
                            let x = center.x + cos(angle) * radius * 0.5
                            let y = center.y + sin(angle) * radius * 0.5
                            
                            let path = Path { p in
                                p.addEllipse(in: CGRect(
                                    x: x - radius * 0.3,
                                    y: y - radius * 0.3,
                                    width: radius * 0.6,
                                    height: radius * 0.6
                                ))
                            }
                            context.stroke(path, with: .color(QXColor.gold.opacity(0.1)), lineWidth: 1)
                        }
                        
                        // Center circle
                        let centerPath = Path { p in
                            p.addEllipse(in: CGRect(
                                x: center.x - radius * 0.3,
                                y: center.y - radius * 0.3,
                                width: radius * 0.6,
                                height: radius * 0.6
                            ))
                        }
                        context.stroke(centerPath, with: .color(QXColor.gold.opacity(0.15)), lineWidth: 1.5)
                    }
                    .blur(radius: 0.5)
                    .accessibilityHidden(true) // Decorative element
                    .onAppear {
                        withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("SacredGeometryBackground") {
    SacredGeometryBackground()
}
