//
//  PaywallView.swift
//  QodeX - Premium Paywall
//  Inspired by Headspace, Calm, Fitness+
//

import SwiftUI

struct PaywallView: View {
    @State private var selectedTier: MembershipTier = .seeker
    @State private var isAnnual: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    /// Calculates savings percentage for annual plans
    private func savingsPercentage(for tier: MembershipTier) -> String? {
        switch tier {
        case .free:
            return nil
        case .seeker:
            return "Save 50%"
        case .initiate:
            return "Save 50%"
        case .master:
            return "Best Value"
        }
    }
    
    let features = [
        "Complete numerology chart (15+ numbers)",
        "Daily personalized readings",
        "Compatibility analysis",
        "Power hour notifications",
        "Unlimited journal entries",
        "Ad-free experience",
        "Priority support"
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
            
            // Floating glow
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: geometry.size.width / 2 - 200, y: -100)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.starlightTertiary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                        .accessibilityLabel("Close")
                        .accessibilityHint("Dismiss paywall screen")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Crown icon
                    ZStack {
                        Circle()
                            .fill(Color.goldPrimary.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Text("👑")
                            .font(.system(size: 48))
                    }
                    .padding(.top, 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Unlock Your Full Potential")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                            .multilineTextAlignment(.center)
                        
                        Text("Join 50,000+ members who discovered their true numbers")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 24)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.goldPrimary)
                                
                                Text(feature)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.starlightSecondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "12121A").opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    
                    // Billing Toggle (Monthly/Annual)
                    HStack(spacing: 4) {
                        billingToggleButton(title: "Monthly", isSelected: !isAnnual) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAnnual = false
                            }
                        }
                        
                        billingToggleButton(title: "Annual", isSelected: isAnnual, badge: "SAVE 50%") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAnnual = true
                            }
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Pricing tiers
                    VStack(spacing: 12) {
                        ForEach([MembershipTier.seeker, .initiate, .master], id: \.id) { tier in
                            TierCard(
                                tier: tier,
                                isSelected: selectedTier == tier,
                                isAnnual: isAnnual,
                                savingsText: savingsPercentage(for: tier)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTier = tier
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // CTA
                    VStack(spacing: 16) {
                        PremiumButton(title: selectedTier == .master ? "Unlock Lifetime" : "Start Free Trial", icon: "sparkles") {
                            // Purchase
                        }
                        .accessibilityLabel(selectedTier == .master ? "Unlock Lifetime" : "Start Free Trial")
                        .accessibilityHint(getAccessibilityHint())
                        
                        Text(getPriceDescription())
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                        
                        Button("Restore Purchases") {
                            // Restore
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.goldPrimary)
                        .accessibilityLabel("Restore Purchases")
                        .accessibilityHint("Restore previously purchased subscriptions")
                        
                        HStack(spacing: 20) {
                            Button("Terms") {}
                                .font(.system(size: 12))
                                .foregroundColor(.starlightQuaternary)
                            
                            Text("•")
                                .foregroundColor(.starlightQuaternary)
                            
                            Button("Privacy") {}
                                .font(.system(size: 12))
                                .foregroundColor(.starlightQuaternary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

    // MARK: - Helper Functions
    
    private func getPriceDescription() -> String {
        switch selectedTier {
        case .free:
            return "Free plan"
        case .master:
            return "One-time payment of \(selectedTier.annualPrice)"
        case .seeker, .initiate:
            if isAnnual {
                return "7 days free, then \(selectedTier.annualPrice) • Save 50%"
            } else {
                return "7 days free, then \(selectedTier.price)"
            }
        }
    }
    
    private func getAccessibilityHint() -> String {
        switch selectedTier {
        case .free:
            return "Select free plan"
        case .master:
            return "Unlock Master tier with one-time payment of \(selectedTier.annualPrice)"
        case .seeker, .initiate:
            if isAnnual {
                return "Begin 7 day free trial, then \(selectedTier.annualPrice) per year"
            } else {
                return "Begin 7 day free trial, then \(selectedTier.price) per month"
            }
        }
    }
    
    private func billingToggleButton(title: String, isSelected: Bool, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                
                if let badge = badge, isSelected {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.goldPrimary)
                        )
                }
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tier Card
struct TierCard: View {
    let tier: MembershipTier
    let isSelected: Bool
    let isAnnual: Bool
    let savingsText: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.goldPrimary : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.goldPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Tier info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(tier.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.starlight)
                        
                        if let savings = savingsText {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cosmicBlack)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.goldPrimary)
                                )
                        }
                    }
                    
                    Text(tier.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                // Price display
                VStack(alignment: .trailing, spacing: 2) {
                    if tier == .master {
                        Text(tier.annualPrice)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isSelected ? Color.goldPrimary : .starlight)
                    } else {
                        Text(isAnnual ? tier.annualPrice : tier.price)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isSelected ? Color.goldPrimary : .starlight)
                        
                        Text(isAnnual ? "per year" : "per month")
                            .font(.system(size: 12))
                            .foregroundColor(.starlightTertiary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.goldPrimary.opacity(0.1) : Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.goldPrimary.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(tier.displayName) plan, \(isAnnual && tier != .master ? tier.annualPrice : tier.price)")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to select \(tier.displayName) plan")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .preferredColorScheme(.dark)
    }
}
