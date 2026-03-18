//
//  ChartView.swift
//  Premium Chart Screen - Production SwiftUI
//

import SwiftUI

struct ChartView: View {
    @State private var selectedNumber: Int? = nil
    
    let coreNumbers = [
        CoreNumber(value: 7, type: .lifePath, title: "The Seeker", subtitle: "Spiritual • Analytical • Wise", color: .goldPrimary),
        CoreNumber(value: 3, type: .expression, title: "Creative", subtitle: "Artist • Communicator", color: .goldPrimary),
        CoreNumber(value: 6, type: .soulUrge, title: "Nurturing", subtitle: "Harmony • Compassion", color: .purple),
        CoreNumber(value: 9, type: .personality, title: "Humanitarian", subtitle: "Universal • Completion", color: .blue),
        CoreNumber(value: 15, type: .birthday, title: "Leadership", subtitle: "Independence • Vision", color: Color(hex: "2ECC71"))
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Your Chart")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                            .accessibilityLabel("Your Chart")
                            .accessibilityHint("Your personal numerology chart")
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.starlightTertiary)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Opens app settings")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    // Hero Card - Life Path
                    HeroCard(number: coreNumbers[0])
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    
                    // Grid of Numbers
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(coreNumbers.dropFirst()) { number in
                            NumberGridCard(number: number, isSelected: selectedNumber == number.value)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedNumber = selectedNumber == number.value ? nil : number.value
                                    }
                                }
                                .accessibilityLabel("\(number.type.rawValue) Number \(number.value), \(number.title)")
                                .accessibilityHint("Double tap to view details about your \(number.type.rawValue) number")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Unlock Banner
                    UnlockBanner()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Core Number Model
struct CoreNumber: Identifiable {
    let id = UUID()
    let value: Int
    let type: NumberType
    let title: String
    let subtitle: String
    let color: Color
}

enum NumberType: String {
    case lifePath = "Life Path"
    case expression = "Expression"
    case soulUrge = "Soul Urge"
    case personality = "Personality"
    case birthday = "Birthday"
}

// MARK: - Hero Card
struct HeroCard: View {
    let number: CoreNumber
    
    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.goldPrimary.opacity(0.15),
                            Color.goldPrimary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Glow orb
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.goldPrimary.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -80)
            
            // Border
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                Text(number.type.rawValue + " Number")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "B8954C"))
                    .textCase(.uppercase)
                    .tracking(1)
                    .padding(.bottom, 16)
                    .accessibilityLabel("\(number.type.rawValue) Number")
                
                HStack(spacing: 20) {
                    Text("\(number.value)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.goldBright, .goldPrimary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .accessibilityLabel("\(number.value)")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(number.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.starlight)
                            .accessibilityLabel(number.title)
                        
                        Text(number.subtitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                            .accessibilityLabel(number.subtitle)
                    }
                    
                    Spacer()
                }
            }
            .padding(28)
        }
        .frame(height: 160)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(number.type.rawValue) Number \(number.value), \(number.title), \(number.subtitle)")
        .accessibilityHint("Your primary \(number.type.rawValue) number representing \(number.subtitle)")
    }
}

// MARK: - Number Grid Card
struct NumberGridCard: View {
    let number: CoreNumber
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "12121A").opacity(0.6))
            
            // Top highlight
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
            
            // Selection glow
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(number.color.opacity(0.5), lineWidth: 2)
                    .shadow(color: number.color.opacity(0.3), radius: 10, x: 0, y: 0)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                Text(number.type.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.starlightTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.bottom, 12)
                
                Text("\(number.value)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(number.color)
                    .padding(.bottom, 4)
                
                Text(number.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.starlightSecondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 140)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Unlock Banner
struct UnlockBanner: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.goldPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text("✦")
                        .font(.system(size: 24))
                        .foregroundColor(.goldPrimary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock 5 More Numbers")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                    
                    Text("See your complete blueprint")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                // Arrow
                Text("→")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.goldPrimary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(0.1),
                                Color.goldPrimary.opacity(0.02)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [6, 4]
                        )
                    )
                    .foregroundColor(Color.goldPrimary.opacity(0.3))
            )
        }
        .accessibilityLabel("Unlock 5 More Numbers")
        .accessibilityHint("Tap to upgrade and see your complete numerology blueprint")
    }
}

// MARK: - Preview
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .preferredColorScheme(.dark)
    }
}
