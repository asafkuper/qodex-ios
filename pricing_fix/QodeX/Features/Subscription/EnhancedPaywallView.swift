//
//  PaywallView.swift
//  QodeX Premium Paywall - Enhanced Value Demonstration
//  Reference: iOS 18 Human Interface Guidelines - Value First Design
//

import SwiftUI

// MARK: - Enhanced Paywall View

struct EnhancedPaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedTier: MembershipTier = .seeker
    @State private var isAnnual = true
    @State private var showTerms = false
    @State private var isAnimating = false
    @State private var showConfetti = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Mesh gradient background
            MeshGradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with social proof
                    headerSection
                    
                    // Preview of locked content (blurred)
                    lockedContentPreview
                    
                    // What You Get section
                    whatYouGetSection
                    
                    // Feature comparison table
                    featureComparisonSection
                    
                    // Social proof stats
                    socialProofSection
                    
                    // Billing Toggle
                    billingToggle
                    
                    // Tier Cards
                    tierCards
                    
                    // CTA
                    subscribeButton
                    
                    // Trust indicators
                    trustIndicatorsSection
                    
                    // Terms
                    termsSection
                }
                .padding(.bottom, 40)
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("paywallScroll")).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .coordinateSpace(name: "paywallScroll")
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Header Section with Social Proof
    
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
            
            // Quick social proof badge
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(QXColor.gold)
                    }
                }
                
                Text("4.9/5 from 2,800+ reviews")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(QXColor.starlight.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(QXColor.gold.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Locked Content Preview (Blurred)
    
    private var lockedContentPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("What You're Missing")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(QXColor.starlight)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                    Text("Unlock")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(QXColor.gold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(QXColor.gold.opacity(0.15))
                )
            }
            .padding(.horizontal, 20)
            
            // Blurred preview cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    LockedContentCard(
                        icon: "play.circle.fill",
                        title: "Life Path Masterclass",
                        subtitle: "3 hours • Premium",
                        gradient: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]
                    )
                    
                    LockedContentCard(
                        icon: "book.closed.fill",
                        title: "Advanced Numerology",
                        subtitle: "12 lessons • Premium",
                        gradient: [Color.orange.opacity(0.6), Color.red.opacity(0.6)]
                    )
                    
                    LockedContentCard(
                        icon: "person.2.fill",
                        title: "Monthly Q&A Sessions",
                        subtitle: "Live • Premium",
                        gradient: [Color.green.opacity(0.6), Color.teal.opacity(0.6)]
                    )
                    
                    LockedContentCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Personal Forecasts",
                        subtitle: "Weekly • Premium",
                        gradient: [Color.pink.opacity(0.6), Color.purple.opacity(0.6)]
                    )
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - What You Get Section
    
    private var whatYouGetSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What You Get")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                WhatYouGetRow(
                    icon: "video.fill",
                    title: "200+ Hours of Content",
                    description: "Complete access to all teachings, masterclasses, and guided journeys"
                )
                
                WhatYouGetRow(
                    icon: "person.2.fill",
                    title: "Live Monthly Sessions",
                    description: "Join Shani live for exclusive Q&A and monthly forecasts"
                )
                
                WhatYouGetRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Personal Insights",
                    description: "Weekly forecasts tailored to your personal numerology chart"
                )
                
                WhatYouGetRow(
                    icon: "book.closed.fill",
                    title: "Digital Workbooks",
                    description: "Downloadable exercises, templates, and reference guides"
                )
                
                WhatYouGetRow(
                    icon: "headphones",
                    title: "Audio Meditations",
                    description: "50+ guided meditations for centering and manifestation"
                )
                
                WhatYouGetRow(
                    icon: "sparkles",
                    title: "Exclusive Tools",
                    description: "Advanced calculators and personal blueprint analyzer"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Feature Comparison Section
    
    private var featureComparisonSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Compare Plans")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Features")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                        .frame(width: 140, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Free")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                        .frame(width: 60)
                    
                    Text("Premium")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QXColor.gold)
                        .frame(width: 60)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(QXColor.deepVoid.opacity(0.3))
                
                Divider()
                    .background(QXColor.starlight.opacity(0.1))
                
                // Feature rows
                FeatureComparisonRow(
                    feature: "Daily Qode",
                    freeValue: "Limited",
                    premiumValue: "Full Access",
                    isCheckmark: false
                )
                
                FeatureComparisonRow(
                    feature: "Life Path Reading",
                    freeValue: true,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Masterclasses",
                    freeValue: false,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Live Sessions",
                    freeValue: false,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Personal Forecasts",
                    freeValue: false,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Community Access",
                    freeValue: "Read Only",
                    premiumValue: "Full",
                    isCheckmark: false
                )
                
                FeatureComparisonRow(
                    feature: "Meditation Library",
                    freeValue: "3",
                    premiumValue: "50+",
                    isCheckmark: false
                )
                
                FeatureComparisonRow(
                    feature: "Blueprint Analysis",
                    freeValue: false,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Download Content",
                    freeValue: false,
                    premiumValue: true
                )
                
                FeatureComparisonRow(
                    feature: "Priority Support",
                    freeValue: false,
                    premiumValue: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(QXColor.starlight.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Social Proof Section
    
    private var socialProofSection: some View {
        VStack(spacing: 24) {
            // Stats row
            HStack(spacing: 0) {
                StatColumn(value: "50K+", label: "Active Members")
                
                Divider()
                    .background(QXColor.starlight.opacity(0.2))
                    .frame(height: 40)
                
                StatColumn(value: "4.9", label: "App Store Rating")
                
                Divider()
                    .background(QXColor.starlight.opacity(0.2))
                    .frame(height: 40)
                
                StatColumn(value: "200+", label: "Hours of Content")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            
            // Testimonial
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(QXColor.gold)
                    }
                }
                
                Text("\"This app has completely transformed my understanding of myself. The daily insights are eerily accurate and the community is so supportive. Worth every penny!\"")
                    .font(.system(size: 15))
                    .foregroundStyle(QXColor.starlight.opacity(0.9))
                    .lineSpacing(4)
                    .italic()
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(QXColor.gold.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("SM")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(QXColor.gold)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sarah M.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("Inner Circle Member")
                            .font(.system(size: 13))
                            .foregroundStyle(QXColor.starlight.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    VerifiedBadge()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid.opacity(0.4))
            )
            .padding(.horizontal, 20)
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
                PremiumTierCardEnhanced(
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
    
    // MARK: - Trust Indicators Section
    
    private var trustIndicatorsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 12))
                Text("7-day free trial • Cancel anytime")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(QXColor.starlight.opacity(0.6))
            
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                    Text("Secure")
                        .font(.system(size: 11))
                }
                .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 10))
                    Text("Easy Cancel")
                        .font(.system(size: 11))
                }
                .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                    Text("Verified")
                        .font(.system(size: 11))
                }
                .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .padding(.top, 20)
        .fadeIn(delay: 0.5)
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        Button("Terms of Service & Privacy Policy") {
            QXHaptic.lightImpact()
            showTerms = true
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(QXColor.gold.opacity(0.8))
        .padding(.top, 12)
    }
}

// MARK: - Locked Content Card

struct LockedContentCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 100)
                
                // Blur overlay
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 100)
                
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(QXColor.starlight)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .frame(width: 140)
    }
}

// MARK: - What You Get Row

struct WhatYouGetRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(QXColor.gold)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(QXColor.starlight.opacity(0.6))
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(QXColor.gold)
        }
    }
}

// MARK: - Feature Comparison Row

struct FeatureComparisonRow: View {
    let feature: String
    let freeValue: Any
    let premiumValue: Any
    var isCheckmark: Bool = true
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.system(size: 15))
                .foregroundStyle(QXColor.starlight)
                .frame(width: 140, alignment: .leading)
            
            Spacer()
            
            // Free column
            comparisonValue(value: freeValue, isPremium: false)
                .frame(width: 60)
            
            // Premium column
            comparisonValue(value: premiumValue, isPremium: true)
                .frame(width: 60)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Group {
                if feature == "Blueprint Analysis" {
                    QXColor.gold.opacity(0.1)
                } else {
                    Color.clear
                }
            }
        )
    }
    
    @ViewBuilder
    private func comparisonValue(value: Any, isPremium: Bool) -> some View {
        if isCheckmark {
            if let boolValue = value as? Bool {
                Image(systemName: boolValue ? "checkmark" : "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(boolValue ? (isPremium ? QXColor.gold : QXColor.starlight.opacity(0.6)) : QXColor.starlight.opacity(0.2))
            } else {
                Text("–")
                    .font(.system(size: 14))
                    .foregroundStyle(QXColor.starlight.opacity(0.2))
            }
        } else {
            if let stringValue = value as? String {
                Text(stringValue)
                    .font(.system(size: 13, weight: isPremium ? .semibold : .regular))
                    .foregroundStyle(isPremium ? QXColor.gold : QXColor.starlight.opacity(0.6))
            } else if let boolValue = value as? Bool {
                Image(systemName: boolValue ? "checkmark" : "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(boolValue ? (isPremium ? QXColor.gold : QXColor.starlight.opacity(0.6)) : QXColor.starlight.opacity(0.2))
            }
        }
    }
}

// MARK: - Stat Column

struct StatColumn: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(QXColor.gold)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(QXColor.starlight.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Verified Badge

struct VerifiedBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
            Text("Verified")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(QXColor.gold)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(QXColor.gold.opacity(0.15))
        )
    }
}

// MARK: - Premium Tier Card (Enhanced)

struct PremiumTierCardEnhanced: View {
    let tier: MembershipTier
    let isSelected: Bool
    let isAnnual: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
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

// MARK: - Supporting Types

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview("Enhanced Paywall") {
    EnhancedPaywallView()
        .environmentObject(SubscriptionManager.shared)
        .preferredColorScheme(.dark)
}
