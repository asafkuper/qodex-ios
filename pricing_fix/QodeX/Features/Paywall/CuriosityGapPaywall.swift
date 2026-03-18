//
//  CuriosityGapPaywall.swift
//  Contextual paywall with blurred teasers
//

import SwiftUI

struct CuriosityGapPaywall: View {
    let feature: PremiumFeature
    let userLifePath: Int
    let onUnlock: () -> Void
    let onDismiss: () -> Void
    
    @State private var showAnimation = false
    @State private var blurAmount: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Teaser content (blurred)
                TeaserContent(feature: feature, lifePath: userLifePath)
                    .blur(radius: blurAmount)
                    .opacity(0.7)
                    .overlay(
                        VStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gold)
                            
                            Text("Hidden Insight")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    )
                
                // The Hook
                VStack(spacing: 12) {
                    Text("Your \(feature.rawValue) is Ready")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(getCuriosityHook(for: feature, lifePath: userLifePath))
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Social Proof
                HStack(spacing: 8) {
                    HStack(spacing: -8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(["S", "M", "J"][i])
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    
                    Text("2,847 users unlocked this today")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // CTA Button
                Button(action: {
                    withAnimation(.spring()) {
                        showAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onUnlock()
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Unlock for $\(feature.price)")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.gold, .gold.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .scaleEffect(showAnimation ? 0.95 : 1.0)
                
                // Alternative
                Button("Maybe Later", action: onDismiss)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(24)
        }
    }
    
    private func getCuriosityHook(for feature: PremiumFeature, lifePath: Int) -> String {
        let hooks: [PremiumFeature: [Int: String]] = [
            .soulUrge: [
                1: "Discover what truly drives your leadership...",
                2: "The hidden desire behind your diplomacy revealed...",
                7: "Your soul's deepest question about existence..."
            ],
            .destiny: [
                8: "The career path that unlocks your abundance...",
                3: "Your creative calling that's been suppressed...",
                9: "The humanitarian mission encoded in your name..."
            ],
            .compatibility: [
                0: "Why certain people drain you while others energize you..."
            ]
        ]
        
        return hooks[feature]?[lifePath] ?? hooks[feature]?[0] ?? "Unlock premium insights personalized for you."
    }
}

struct TeaserContent: View {
    let feature: PremiumFeature
    let lifePath: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Mock content that looks real but is blurred
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

enum PremiumFeature: String, CaseIterable {
    case soulUrge = "Soul Urge Reading"
    case destiny = "Destiny Path"
    case compatibility = "Compatibility Matrix"
    case yearlyForecast = "2026 Forecast"
    case dailyExtended = "Extended Daily"
    
    var price: String {
        switch self {
        case .soulUrge, .destiny: return "4.99"
        case .compatibility: return "9.99"
        case .yearlyForecast: return "19.99"
        case .dailyExtended: return "2.99"
        }
    }
    
    var icon: String {
        switch self {
        case .soulUrge: return "heart.fill"
        case .destiny: return "arrow.forward.circle.fill"
        case .compatibility: return "person.2.fill"
        case .yearlyForecast: return "calendar"
        case .dailyExtended: return "sun.max.fill"
        }
    }
    
    /// Returns the minimum tier required to access this feature
    var requiredTier: MembershipTier {
        switch self {
        case .dailyExtended:
            return .seeker
        case .soulUrge, .destiny, .compatibility:
            return .seeker
        case .yearlyForecast:
            return .initiate
        }
    }
}
