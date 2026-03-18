//
//  DashboardView.swift
//  QodeX Premium Dashboard
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showDailyInsight = false
    @State private var isRefreshing = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showStaggered = false
    
    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)
            
            VStack(spacing: QXSpacing.xl) {
                // Header
                DashboardHeader()
                    .padding(.horizontal)
                    .staggered(index: 0, baseDelay: 0.05)
                
                // Daily Insight Card
                DailyInsightCardPremium()
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation(QXAnimation.spring) {
                            showDailyInsight.toggle()
                        }
                        QXHaptic.mediumImpact()
                    }
                    .staggered(index: 1, baseDelay: 0.05)
                
                // Quick Actions
                QuickActionsGridPremium()
                    .padding(.horizontal)
                    .staggered(index: 2, baseDelay: 0.05)
                
                // Recent Teachings
                RecentTeachingsSectionPremium()
                    .padding(.horizontal)
                    .staggered(index: 3, baseDelay: 0.05)
                
                // Next Live Session
                NextLiveSessionCardPremium()
                    .padding(.horizontal)
                    .staggered(index: 4, baseDelay: 0.05)
                
                Spacer(minLength: QXSpacing.xxl)
            }
            .padding(.top)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .background(
            SacredGeometryBackgroundPremium()
                .parallax(scrollOffset: scrollOffset, factor: 0.3)
        )
        .refreshable {
            await performRefresh()
        }
        .onAppear {
            showStaggered = true
        }
    }
    
    private func performRefresh() async {
        QXHaptic.mediumImpact()
        
        // Simulate data refresh
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            QXHaptic.success()
        }
    }
}

// MARK: - Scroll Offset Helper

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Dashboard Header

struct DashboardHeader: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        HStack(spacing: QXSpacing.md) {
            VStack(alignment: .leading, spacing: QXSpacing.xs) {
                Text("Welcome,")
                    .font(QXFont.body)
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                
                Text(authManager.currentUser?.name ?? "Seeker")
                    .font(QXFont.displayMedium)
                    .foregroundColor(QXColor.starlight)
            }
            
            Spacer()
            
            // Membership Badge
            MembershipBadgePremium(tier: authManager.currentUser?.membershipTier ?? .free)
            
            // Profile Avatar
            Button(action: {
                QXHaptic.lightImpact()
            }) {
                ZStack {
                    Circle()
                        .fill(QXColor.deepVoid)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(QXColor.starlight.opacity(0.2), lineWidth: 1)
                        )
                    
                    Text(String((authManager.currentUser?.name ?? "S").prefix(1).uppercased()))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(QXColor.gold)
                }
            }
            .pressAnimation()
        }
    }
}

// MARK: - Membership Badge

struct MembershipBadgePremium: View {
    let tier: MembershipTier
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: QXSpacing.xs) {
            Image(systemName: tier == .innerCircle ? "crown.fill" : "person.fill")
                .font(.system(size: 12))
            
            Text(tier == .innerCircle ? "Inner Circle" : tier.rawValue.capitalized)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, QXSpacing.md)
        .padding(.vertical, QXSpacing.xs)
        .background(
            Capsule()
                .fill(tier == .innerCircle ? QXColor.gold.opacity(0.2) : QXColor.sacredGeometry)
        )
        .foregroundColor(tier == .innerCircle ? QXColor.gold : QXColor.starlight.opacity(0.7))
        .overlay(
            Capsule()
                .stroke(tier == .innerCircle ? QXColor.gold.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}

// MARK: - Daily Insight Card

struct DailyInsightCardPremium: View {
    @State private var isAnimating = false
    
    var body: some View {
        PremiumGlassCard {
            VStack(alignment: .leading, spacing: QXSpacing.md) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(QXColor.gold)
                        
                        Text("Today's Qode")
                            .font(QXFont.headline)
                            .foregroundColor(QXColor.starlight)
                    }
                    
                    Spacer()
                    
                    Text(formattedDate())
                        .font(QXFont.caption)
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                }
                
                Divider()
                    .background(QXColor.gold.opacity(0.2))
                
                Text("The number 8 carries the vibration of abundance and power. Today, notice where you hold yourself back from receiving.")
                    .font(QXFont.body)
                    .foregroundColor(QXColor.starlight.opacity(0.9))
                    .lineSpacing(6)
                
                HStack {
                    Label("3 min read", systemImage: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                    
                    Spacer()
                    
                    Button(action: {
                        QXHaptic.lightImpact()
                    }) {
                        HStack(spacing: 4) {
                            Text("Explore")
                                .font(QXFont.caption)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(QXColor.gold)
                    }
                    .pressAnimation()
                }
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGridPremium: View {
    let actions = [
        ("Calculate", "number.circle", "Your Qode", QXColor.cosmicPurple),
        ("Library", "books.vertical", "Teachings", QXColor.nebulaBlue),
        ("Community", "person.3", "Circle", QXColor.goldMuted),
        ("Sessions", "video.fill", "Live", QXColor.cosmicPurple)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: QXSpacing.md) {
            ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                PremiumQuickActionButton(
                    title: action.0,
                    icon: action.1,
                    subtitle: action.2,
                    color: action.3
                )
                .staggered(index: index, baseDelay: 0.03)
            }
        }
    }
}

struct PremiumQuickActionButton: View {
    let title: String
    let icon: String
    let subtitle: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            QXHaptic.mediumImpact()
        }) {
            VStack(alignment: .leading, spacing: QXSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(QXFont.headline)
                        .foregroundColor(QXColor.starlight)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(QXColor.deepVoid.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressSensoryFeedback()
    }
}

// MARK: - Recent Teachings Section

struct RecentTeachingsSectionPremium: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QXSpacing.md) {
            HStack {
                Text("Continue Learning")
                    .font(QXFont.headline)
                    .foregroundColor(QXColor.starlight)
                
                Spacer()
                
                Button(action: {
                    QXHaptic.lightImpact()
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(QXFont.caption)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(QXColor.gold)
                }
                .pressAnimation()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: QXSpacing.md) {
                    ForEach(Array(teachings.enumerated()), id: \.offset) { index, teaching in
                        PremiumTeachingCard(
                            title: teaching.title,
                            progress: teaching.progress,
                            duration: teaching.duration,
                            image: teaching.image
                        )
                        .staggered(index: index, baseDelay: 0.05)
                    }
                }
            }
        }
    }
    
    private var teachings: [(title: String, progress: Double, duration: String, image: String)] {
        [
            ("The Life Path Numbers", 0.7, "45 min", "path"),
            ("Master Numbers 11, 22, 33", 0.3, "60 min", "master"),
            ("Timing Cycles", 0.0, "30 min", "timing"),
            ("Personal Year Insights", 0.0, "25 min", "year")
        ]
    }
}

struct PremiumTeachingCard: View {
    let title: String
    let progress: Double
    let duration: String
    let image: String
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            QXHaptic.mediumImpact()
        }) {
            VStack(alignment: .leading, spacing: QXSpacing.sm) {
                // Thumbnail with overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(QXColor.sacredGeometry)
                        .frame(width: 200, height: 120)
                    
                    // Play button
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(QXColor.gold.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.spring(), value: isHovered)
                    
                    // Duration badge
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text(duration)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                        }
                    }
                    .padding(8)
                }
                .frame(width: 200, height: 120)
                
                // Title
                Text(title)
                    .font(QXFont.headline)
                    .foregroundColor(QXColor.starlight)
                    .lineLimit(2)
                    .frame(width: 200, alignment: .leading)
                
                // Progress
                if progress > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(QXColor.sacredGeometry)
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [QXColor.gold, QXColor.goldGlow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(progress * 100))% complete")
                        .font(.system(size: 11))
                        .foregroundColor(QXColor.gold)
                }
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Next Live Session Card

struct NextLiveSessionCardPremium: View {
    @State private var isAnimating = false
    
    var body: some View {
        PremiumGlassCard {
            VStack(alignment: .leading, spacing: QXSpacing.md) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        
                        Text("Next Live Session")
                            .font(QXFont.headline)
                            .foregroundColor(QXColor.starlight)
                    }
                    
                    Spacer()
                    
                    // Live badge
                    HStack(spacing: QXSpacing.xs) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 1 : 0.5)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, QXSpacing.sm)
                    .padding(.vertical, QXSpacing.xs)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Text("Monthly Q&A: Understanding Your Personal Year")
                    .font(QXFont.title)
                    .foregroundColor(QXColor.starlight)
                
                HStack(spacing: QXSpacing.lg) {
                    Label("Today, 8:00 PM", systemImage: "calendar")
                    Label("Shani", systemImage: "person")
                }
                .font(QXFont.caption)
                .foregroundColor(QXColor.starlight.opacity(0.6))
                
                PremiumSecondaryButton(title: "Set Reminder", icon: "bell.fill") {
                    QXHaptic.success()
                }
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Premium Glass Card

struct PremiumGlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(QXSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.4))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        QXColor.starlight.opacity(0.2),
                                        QXColor.gold.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Secondary Button

struct PremiumSecondaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            QXHaptic.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(QXColor.starlight)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(QXColor.starlight.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(QXColor.starlight.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .pressAnimation()
    }
}

// MARK: - Sacred Geometry Background

struct SacredGeometryBackgroundPremium: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base color
                QXColor.cosmicBlack
                
                // Animated geometric patterns
                ZStack {
                    // Large outer circle
                    Circle()
                        .stroke(QXColor.gold.opacity(0.03), lineWidth: 1)
                        .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.3)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 120).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Middle circle with dashes
                    Circle()
                        .stroke(QXColor.gold.opacity(0.05), style: StrokeStyle(lineWidth: 1, dash: [20, 20]))
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.3)
                        .rotationEffect(.degrees(isAnimating ? -360 : 0))
                        .animation(.linear(duration: 90).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Decorative dots
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(QXColor.gold.opacity(0.1))
                            .frame(width: 4, height: 4)
                            .position(
                                x: geo.size.width / 2 + cos(Double(i) * .pi / 4) * geo.size.width * 0.4,
                                y: geo.size.height * 0.3 + sin(Double(i) * .pi / 4) * geo.size.width * 0.4
                            )
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { isAnimating = true }
    }
}

// MARK: - Press Sensory Feedback

extension View {
    func pressSensoryFeedback() -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
        )
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DashboardView()
        .preferredColorScheme(.dark)
}
