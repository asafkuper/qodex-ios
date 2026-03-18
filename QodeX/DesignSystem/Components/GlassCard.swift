//
//  GlassCard.swift
//  QodeX Design System - Glass Card Component
//

import SwiftUI

// MARK: - Glass Card
public struct GlassCard<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(QXSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Preview
#Preview("GlassCard") {
    ZStack {
        QXColor.cosmicBlack.ignoresSafeArea()
        
        GlassCard {
            VStack(spacing: 16) {
                Text("Glass Card Content")
                    .font(QXFont.headline)
                    .foregroundColor(QXColor.starlight)
                
                Text("This is a reusable glass card component")
                    .font(QXFont.body)
                    .foregroundColor(QXColor.starlight.opacity(0.7))
            }
        }
        .padding()
    }
}
