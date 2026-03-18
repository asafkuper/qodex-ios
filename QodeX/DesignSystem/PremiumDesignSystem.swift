//
//  PremiumDesignSystem.swift
//  World-class design system inspired by Linear, Craft, Arc
//

import SwiftUI

// MARK: - Premium Colors
extension Color {
    // Cosmic palette with depth
    static let cosmicBlack = Color(hex: "0A0A0F")
    static let cosmicBlackElevated = Color(hex: "12121A")
    static let cosmicBlackFloating = Color(hex: "1A1A24")
    
    // Gold with warmth and sophistication
    static let goldPrimary = Color(hex: "E5C158")
    static let goldBright = Color(hex: "F4D03F")
    static let goldMuted = Color(hex: "B8954C")
    static let goldGlow = Color(hex: "E5C158").opacity(0.3)
    
    // Starlight with depth
    static let starlightPrimary = Color(hex: "FAFAFA")
    static let starlightSecondary = Color(hex: "E5E5E5")
    static let starlightTertiary = Color(hex: "A1A1AA")
    static let starlightQuaternary = Color(hex: "71717A")
    
    // Accent colors for energy states
    static let energyHigh = Color(hex: "FF6B6B")
    static let energyMedium = Color(hex: "4ECDC4")
    static let energyCalm = Color(hex: "96CEB4")
    static let energyPower = Color(hex: "FFE66D")
}

// MARK: - Glassmorphism
struct GlassModifier: ViewModifier {
    var intensity: Double = 0.1
    var blur: Double = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.cosmicBlackElevated.opacity(intensity)
                    
                    // Gradient overlay for depth
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .cornerRadius(20)
    }
}

extension View {
    func glass(intensity: Double = 0.1) -> some View {
        modifier(GlassModifier(intensity: intensity))
    }
}

// MARK: - Premium Typography
struct PremiumFont {
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    static let headline = Font.system(size: 20, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 17, weight: .medium, design: .default)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let overline = Font.system(size: 11, weight: .semibold, design: .default).smallCaps()
}

// MARK: - Premium Shadows
struct PremiumShadow: ViewModifier {
    var color: Color = .goldPrimary
    var radius: CGFloat = 20
    var x: CGFloat = 0
    var y: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
            .shadow(color: color.opacity(0.1), radius: radius * 2, x: x, y: y * 2)
    }
}

extension View {
    func premiumShadow(color: Color = .goldPrimary) -> some View {
        modifier(PremiumShadow(color: color))
    }
}

// MARK: - Animated Number Display
struct AnimatedNumberDisplay: View {
    let number: Int
    @State private var displayNumber: Int = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Text("\(displayNumber)")
            .font(.system(size: 120, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.goldBright, .goldPrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(scale)
            .shadow(color: .goldPrimary.opacity(0.5), radius: 30, x: 0, y: 0)
            .onAppear {
                animateNumber()
            }
            .onChange(of: number) { _ in
                animateNumber()
            }
    }
    
    private func animateNumber() {
        // Count up animation
        let duration = 0.8
        let steps = 20
        let stepDuration = duration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * stepDuration)) {
                displayNumber = (number * i) / steps
            }
        }
        
        // Pulse effect at end
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Premium Button
struct PremiumButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.cosmicBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.goldBright, .goldPrimary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .shadow(color: .goldPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Premium Card
struct PremiumCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(24)
            .glass(intensity: 0.15)
    }
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Shimmer Loading
struct PremiumShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.15),
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

extension View {
    func premiumShimmer() -> some View {
        modifier(PremiumShimmer())
    }
}
