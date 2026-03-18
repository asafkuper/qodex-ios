//
//  PaywallView.swift
//  QodeX Premium Paywall
//  Reference: iOS 18 Human Interface Guidelines - Mesh Gradients
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedTier: MembershipTier = .seeker
    @State private var isAnnual = true
    @State private var showTerms = false
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Mesh gradient background (iOS 18 style)
            MeshGradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Toggle with premium animation
                    billingToggle
                    
                    // Tier Cards with staggered animation
                    tierCards
                    
                    // Features comparison
                    featuresSection
                    
                    // CTA
                    subscribeButton
                    
                    // Terms
                    termsSection
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Sacred geometry icon with animation
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [QXColor.gold.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating)
                
                Circle()
                    .stroke(QXColor.gold.opacity(0.5), lineWidth: 1)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnimating ? -360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text("Unlock Your Full Potential")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(QXColor.starlight)
                    .multilineTextAlignment(.center)
                
                Text("Join the Inner Circle and access Shani's complete teachings")
                    .font(.system(size: 17))
                    .foregroundStyle(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Billing Toggle
    
    private var billingToggle: some View {
        HStack(spacing: 4) {
            PremiumToggleButton(
                title: "Monthly",
                isSelected: !isAnnual,
                badge: nil
            ) {
                withAnimation(QXAnimation.spring) {
                    isAnnual = false
                }
                QXHaptic.selection()
            }
            
            PremiumToggleButton(
                title: "Annual",
                isSelected: isAnnual,
                badge: "SAVE 50%"
            ) {
                withAnimation(QXAnimation.spring) {
                    isAnnual = true
                }
                QXHaptic.selection()
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(QXColor.starlight.opacity(0.2))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Tier Cards
    
    private var tierCards: some View {
        VStack(spacing: 12) {
            ForEach(Array([MembershipTier.seeker, .initiate, .master].enumerated()), id: \.element.id) { index, tier in
                PremiumTierCard(
                    tier: tier,
                    isSelected: selectedTier == tier,
                    isAnnual: isAnnual,
                    onTap: {
                        withAnimation(QXAnimation.spring) {
                            selectedTier = tier
                        }
                        QXHaptic.mediumImpact()
                    }
                )
                .staggered(index: index, baseDelay: 0.05)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's Included")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(selectedTier.features) { feature in
                    PremiumFeatureRow(feature: feature)
                    
                    if feature.id != selectedTier.features.last?.id {
                        Divider()
                            .background(QXColor.starlight.opacity(0.1))
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(QXColor.starlight.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 32)
        .fadeIn(delay: 0.3)
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button(action: {
            QXHaptic.premiumUnlock()
            Task {
                await subscriptionManager.purchase(tier: selectedTier, isAnnual: isAnnual)
            }
        }) {
            HStack(spacing: 8) {
                if subscriptionManager.isLoading {
                    ProgressView()
                        .tint(QXColor.cosmicBlack)
                } else {
                    Text("Start Your Journey")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundStyle(QXColor.cosmicBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [QXColor.gold, QXColor.goldGlow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: QXColor.gold.opacity(0.3),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .disabled(subscriptionManager.isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .pressAnimation()
        .fadeIn(delay: 0.4)
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 12))
                Text("7-day free trial • Cancel anytime")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(QXColor.starlight.opacity(0.6))
            
            Button("Terms of Service & Privacy Policy") {
                QXHaptic.lightImpact()
                showTerms = true
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(QXColor.gold.opacity(0.8))
        }
        .padding(.top, 20)
        .fadeIn(delay: 0.5)
    }
}

// MARK: - Mesh Gradient Background

struct MeshGradientBackground: View {
    @State private var isAnimating = false
    
    var body: some View {
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
                .ignoresSafeArea()
                
                // Animated mesh-like gradient overlay (simulated with radial gradients)
                ZStack {
                    // Top right glow
                    RadialGradient(
                        colors: [QXColor.mysticPurple.opacity(0.15), .clear],
                        center: .topTrailing,
                        startRadius: 50,
                        endRadius: 300
                    )
                    .offset(x: isAnimating ? 20 : -20, y: isAnimating ? -20 : 20)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Bottom left glow
                    RadialGradient(
                        colors: [QXColor.gold.opacity(0.1), .clear],
                        center: .bottomLeading,
                        startRadius: 50,
                        endRadius: 250
                    )
                    .offset(x: isAnimating ? -30 : 30, y: isAnimating ? 30 : -30)
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Center accent
                    RadialGradient(
                        colors: [QXColor.cosmicTeal.opacity(0.05), .clear],
                        center: .center,
                        startRadius: 100,
                        endRadius: 400
                    )
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                // Noise texture overlay (subtle)
                Color.white.opacity(0.02)
                    .blendMode(.overlay)
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Premium Toggle Button

struct PremiumToggleButton: View {
    let title: String
    let isSelected: Bool
    let badge: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                
                if let badge = badge, isSelected {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(QXColor.cosmicBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(QXColor.gold)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(isSelected ? QXColor.starlight : QXColor.starlight.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? QXColor.starlight.opacity(0.3) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? QXColor.gold.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(QXAnimation.micro, value: isSelected)
    }
}

// MARK: - Premium Tier Card

struct PremiumTierCard: View {
    let tier: MembershipTier
    let isSelected: Bool
    let isAnnual: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator with animation
                ZStack {
                    Circle()
                        .stroke(isSelected ? QXColor.gold : QXColor.starlight.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(QXColor.gold)
                            .frame(width: 14, height: 14)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(QXAnimation.micro, value: isSelected)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(tier.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(QXColor.starlight)
                        
                        if tier.isPopular {
                            Text("POPULAR")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(QXColor.cosmicBlack)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(QXColor.gold)
                                )
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Text(tier.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if tier == .master {
                        Text(tier.annualPrice)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(isSelected ? QXColor.gold : QXColor.starlight)
                    } else {
                        Text(isAnnual ? tier.annualPrice : tier.price)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(isSelected ? QXColor.gold : QXColor.starlight)
                        
                        Text(isAnnual ? "per year" : "per month")
                            .font(.system(size: 12))
                            .foregroundStyle(QXColor.starlight.opacity(0.5))
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(QXColor.deepVoid.opacity(isSelected ? 0.8 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected ? QXColor.gold.opacity(0.5) : QXColor.starlight.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? QXColor.gold.opacity(0.1) : .clear,
                radius: 10,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(QXAnimation.spring, value: isSelected)
    }
}

// MARK: - Premium Feature Row

struct PremiumFeatureRow: View {
    let feature: TierFeature
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.isIncluded ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(feature.isIncluded ? QXColor.gold : QXColor.starlight.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(feature.isIncluded ? QXColor.starlight : QXColor.starlight.opacity(0.4))
                
                Text(feature.description)
                    .font(.system(size: 13))
                    .foregroundStyle(QXColor.starlight.opacity(feature.isIncluded ? 0.5 : 0.3))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Terms View

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Section {
                        Text("Terms of Service")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("By subscribing to QodeX Inner Circle, you agree to our terms of service. Your subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.")
                            .font(.system(size: 15))
                            .foregroundStyle(QXColor.starlight.opacity(0.7))
                            .lineSpacing(6)
                    }
                    
                    Section {
                        Text("Privacy Policy")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("We respect your privacy and protect your personal data. All information is encrypted and stored securely. We never share your personal information with third parties without your consent.")
                            .font(.system(size: 15))
                            .foregroundStyle(QXColor.starlight.opacity(0.7))
                            .lineSpacing(6)
                    }
                    
                    Section {
                        Text("Refund Policy")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("We offer a 7-day free trial for all new subscribers. If you're not satisfied, you can cancel anytime during the trial period. Subscriptions can be managed through your Apple ID settings.")
                            .font(.system(size: 15))
                            .foregroundStyle(QXColor.starlight.opacity(0.7))
                            .lineSpacing(6)
                    }
                }
                .padding()
            }
            .background(QXColor.cosmicBlack.ignoresSafeArea())
            .navigationTitle("Legal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { 
                        QXHaptic.lightImpact()
                        dismiss() 
                    }
                    .foregroundStyle(QXColor.gold)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView()
        .environmentObject(SubscriptionManager.shared)
        .preferredColorScheme(.dark)
}
