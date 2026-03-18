//
//  ProfileView.swift
//  QodeX - Premium Profile Screen
//  Inspired by: Instagram, Strava, Clubhouse
//  Design Language: Cosmic Glassmorphism with Sacred Geometry
//

import SwiftUI

// MARK: - Main Profile View
struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var selectedTab: ProfileTab = .activity
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    enum ProfileTab: String, CaseIterable {
        case activity = "Activity"
        case saved = "Saved"
        case achievements = "Badges"
    }
    
    // Mock data - replace with actual data model
    let user = ProfileUser(
        id: "1",
        fullName: "Alexandra Moon",
        username: "@alex_cosmic",
        bio: "✨ Seeker of truth • Life Path 7 • Starseed • Daily rituals & cosmic wisdom 🌙",
        avatar: "A",
        lifePathNumber: 7,
        membershipTier: .elite,
        stats: ProfileStats(readings: 156, streak: 42, followers: 2847, following: 342),
        joinDate: Date().addingTimeInterval(-86400 * 180)
    )
    
    let activities: [UserActivity] = [
        UserActivity(type: .reading, title: "Daily Numerology Reading", subtitle: "Life Path 7 - Day of Reflection", time: "2 hours ago", icon: "sparkles"),
        UserActivity(type: .session, title: "Joined Live Session", subtitle: "New Moon Manifestation Circle", time: "Yesterday", icon: "video.fill"),
        UserActivity(type: .milestone, title: "30-Day Streak!", subtitle: "Completed 30 days of daily insights", time: "2 days ago", icon: "flame.fill"),
        UserActivity(type: .achievement, title: "Earned Star Seeker Badge", subtitle: "Completed 100 readings", time: "3 days ago", icon: "star.fill"),
        UserActivity(type: .journal, title: "New Journal Entry", subtitle: "Full Moon Reflections", time: "4 days ago", icon: "book.fill")
    ]
    
    let achievements: [Achievement] = [
        Achievement(id: "1", name: "Star Seeker", description: "Complete 100 readings", icon: "star.fill", color: .gold, isUnlocked: true, progress: 1.0),
        Achievement(id: "2", name: "Fire Keeper", description: "Maintain 30-day streak", icon: "flame.fill", color: .orange, isUnlocked: true, progress: 1.0),
        Achievement(id: "3", name: "Wisdom Keeper", description: "Save 50 teachings", icon: "bookmark.fill", color: .mysticPurple, isUnlocked: true, progress: 1.0),
        Achievement(id: "4", name: "Community Guide", description: "Help 10 members", icon: "hands.sparkles.fill", color: .cosmicTeal, isUnlocked: false, progress: 0.7),
        Achievement(id: "5", name: "Master Mystic", description: "Attend 50 sessions", icon: "eye.fill", color: .nebulaBlue, isUnlocked: false, progress: 0.4)
    ]
    
    var body: some View {
        ZStack {
            // Background
            QXColor.cosmicBlack.ignoresSafeArea()
            
            // Animated mesh gradient background
            MeshGradientBackground()
                .ignoresSafeArea()
                .opacity(0.6)
            
            // Main scroll content
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with parallax effect
                        ParallaxHeader(
                            user: user,
                            scrollOffset: scrollOffset,
                            headerHeight: $headerHeight
                        )
                        
                        // Tab selector
                        TabSelector(selectedTab: $selectedTab)
                            .padding(.top, 16)
                            .padding(.horizontal, 20)
                        
                        // Content based on tab
                        switch selectedTab {
                        case .activity:
                            ActivitySection(activities: activities)
                        case .saved:
                            SavedContentSection()
                        case .achievements:
                            AchievementsSection(achievements: achievements)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                scrollOffset = -geo.frame(in: .named("scroll")).origin.y
                            }
                            return Color.clear
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
            }
            
            // Fixed navigation bar
            NavigationBar(scrollOffset: scrollOffset, user: user) {
                showSettings = true
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(user: user)
        }
    }
}

// MARK: - Parallax Header
struct ParallaxHeader: View {
    let user: ProfileUser
    let scrollOffset: CGFloat
    @Binding var headerHeight: CGFloat
    @State private var avatarScale: CGFloat = 1.0
    
    var parallaxOffset: CGFloat {
        let offset = min(scrollOffset, 200)
        return -offset * 0.5
    }
    
    var headerOpacity: Double {
        let opacity = 1 - (scrollOffset / 150)
        return max(0, min(1, opacity))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Header background with gradient
            LinearGradient(
                colors: [
                    QXColor.deepVoid.opacity(0.8),
                    QXColor.cosmicBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 420)
            .overlay(
                // Decorative sacred geometry
                ZStack {
                    // Rotating outer ring
                    Circle()
                        .stroke(QXColor.gold.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [8, 8]))
                        .frame(width: 350, height: 350)
                        .offset(y: -50)
                    
                    // Inner solid ring
                    Circle()
                        .stroke(QXColor.gold.opacity(0.15), lineWidth: 1)
                        .frame(width: 280, height: 280)
                        .offset(y: -50)
                }
            )
            .offset(y: parallaxOffset)
            
            // Content
            VStack(spacing: 20) {
                // Large Avatar with Life Path badge
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [QXColor.gold.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 60,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                    
                    // Avatar container
                    ZStack {
                        // Background circle with gradient
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [QXColor.mysticPurple, QXColor.gold, QXColor.cosmicTeal, QXColor.mysticPurple],
                                    center: .center
                                )
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 8)
                        
                        // Main avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [QXColor.deepVoid, QXColor.starlight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 130, height: 130)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [QXColor.gold, QXColor.goldGlow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        // Initial
                        Text(user.avatar)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [QXColor.gold, QXColor.goldGlow],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    // Life Path Badge - positioned bottom right
                    LifePathBadge(number: user.lifePathNumber)
                        .offset(x: 50, y: 45)
                }
                .scaleEffect(avatarScale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        avatarScale = 1.0
                    }
                }
                
                // Name and bio section
                VStack(spacing: 8) {
                    Text(user.fullName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(user.username)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(QXColor.stardust)
                    
                    // Bio
                    Text(user.bio)
                        .font(.system(size: 14))
                        .foregroundColor(QXColor.moonlight)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                }
                
                // Membership tier pill
                MembershipTierPill(tier: user.membershipTier)
                
                // Stats row (Instagram-style)
                HStack(spacing: 0) {
                    StatItem(value: "\(user.stats.readings)", label: "Readings")
                    Divider()
                        .background(QXColor.stardust.opacity(0.3))
                        .frame(height: 30)
                    StatItem(value: "\(user.stats.streak)", label: "Day Streak")
                    Divider()
                        .background(QXColor.stardust.opacity(0.3))
                        .frame(height: 30)
                    StatItem(value: formatNumber(user.stats.followers), label: "Followers")
                    Divider()
                        .background(QXColor.stardust.opacity(0.3))
                        .frame(height: 30)
                    StatItem(value: "\(user.stats.following)", label: "Following")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.bottom, 24)
            .opacity(headerOpacity)
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    headerHeight = geo.size.height
                }
            }
        )
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }
}

// MARK: - Life Path Badge
struct LifePathBadge: View {
    let number: Int
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(QXColor.gold.opacity(pulse ? 0.4 : 0.2))
                .frame(width: 44, height: 44)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            
            // Badge background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .shadow(color: QXColor.gold.opacity(0.5), radius: 8, x: 0, y: 0)
            
            // Number
            Text("\(number)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(QXColor.cosmicBlack)
        }
        .overlay(
            Circle()
                .stroke(QXColor.cosmicBlack, lineWidth: 2)
        )
        .onAppear { pulse = true }
    }
}

// MARK: - Membership Tier Pill
struct MembershipTierPill: View {
    let tier: MembershipTier
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tier.icon)
                .font(.system(size: 12, weight: .semibold))
            
            Text(tier.displayName)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(tier.textColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(tier.backgroundColor)
        )
        .overlay(
            Capsule()
                .stroke(tier.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Stat Item (Instagram-style)
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(QXColor.stardust)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tab Selector
struct TabSelector: View {
    @Binding var selectedTab: ProfileView.ProfileTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ProfileView.ProfileTab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
        )
    }
}

struct TabButton: View {
    let tab: ProfileView.ProfileTab
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tab.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? QXColor.cosmicBlack : QXColor.moonlight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [QXColor.gold, QXColor.goldGlow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .matchedGeometryEffect(id: "tab", in: namespace)
                        }
                    }
                )
        }
        .accessibilityLabel("\(tab.rawValue) tab")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to switch to \(tab.rawValue)")
        .accessibilityValue(isSelected ? "Selected" : "")
    }
}

// MARK: - Activity Section
struct ActivitySection: View {
    let activities: [UserActivity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recent Activity header
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {}
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(QXColor.gold)
            }
            .padding(.horizontal, 20)
            
            // Activity list with glass cards
            LazyVStack(spacing: 12) {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
}

struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(activity.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 18))
                    .foregroundColor(activity.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(activity.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(QXColor.stardust)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Time
            Text(activity.time)
                .font(.system(size: 12))
                .foregroundColor(QXColor.stardust)
        }
        .padding(16)
        .background(
            GlassCardBackground()
        )
    }
}

// MARK: - Saved Content Section
struct SavedContentSection: View {
    var body: some View {
        VStack(spacing: 20) {
            // Saved categories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                SavedCategoryCard(
                    title: "Teachings",
                    count: 24,
                    icon: "bookmark.fill",
                    color: QXColor.gold
                )
                SavedCategoryCard(
                    title: "Readings",
                    count: 156,
                    icon: "sparkles",
                    color: QXColor.mysticPurple
                )
                SavedCategoryCard(
                    title: "Journal",
                    count: 42,
                    icon: "book.fill",
                    color: QXColor.cosmicTeal
                )
                SavedCategoryCard(
                    title: "Sessions",
                    count: 18,
                    icon: "video.fill",
                    color: QXColor.nebulaBlue
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
}

struct SavedCategoryCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(QXColor.moonlight)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            GlassCardBackground()
        )
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Progress summary
            AchievementProgressSummary(achievements: achievements)
                .padding(.horizontal, 20)
            
            // Achievements grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
}

struct AchievementProgressSummary: View {
    let achievements: [Achievement]
    
    var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }
    
    var progress: Double {
        Double(unlockedCount) / Double(achievements.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Journey")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(unlockedCount) of \(achievements.count) badges earned")
                        .font(.system(size: 14))
                        .foregroundColor(QXColor.stardust)
                }
                
                Spacer()
                
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(QXColor.starlight.opacity(0.2), lineWidth: 6)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(QXColor.gold)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(QXColor.starlight.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            GlassCardBackground()
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var shimmer = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow effect
            ZStack {
                if achievement.isUnlocked {
                    Circle()
                        .fill(achievement.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .blur(radius: 8)
                }
                
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.15) : QXColor.starlight.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                achievement.isUnlocked ? achievement.color.opacity(0.4) : QXColor.stardust.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? achievement.color : QXColor.stardust)
                    .symbolEffect(.bounce, options: .repeat(1), value: shimmer)
            }
            
            // Name and description
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : QXColor.stardust)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundColor(QXColor.stardust)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Progress indicator
            if !achievement.isUnlocked {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(QXColor.starlight.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(achievement.color.opacity(0.6))
                            .frame(width: geo.size.width * achievement.progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                Text("\(Int(achievement.progress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(achievement.color)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                    Text("Earned")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(achievement.color)
            }
        }
        .padding(16)
        .background(
            GlassCardBackground()
        )
        .onAppear {
            if achievement.isUnlocked {
                shimmer = true
            }
        }
    }
}

// MARK: - Navigation Bar
struct NavigationBar: View {
    let scrollOffset: CGFloat
    let user: ProfileUser
    let onSettings: () -> Void
    
    var showBackground: Bool {
        scrollOffset > 250
    }
    
    var titleOpacity: Double {
        let opacity = (scrollOffset - 200) / 100
        return max(0, min(1, opacity))
    }
    
    var body: some View {
        VStack {
            HStack {
                // Back button placeholder (for navigation)
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(QXColor.deepVoid.opacity(0.6))
                        )
                }
                .opacity(showBackground ? 1 : 0)
                .accessibilityLabel("Back")
                .accessibilityHint("Go back to previous screen")
                
                Spacer()
                
                // Title that appears on scroll
                VStack(spacing: 2) {
                    Text(user.fullName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(user.username)
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.stardust)
                }
                .opacity(titleOpacity)
                
                Spacer()
                
                // Settings button
                Button(action: onSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(showBackground ? QXColor.deepVoid.opacity(0.6) : QXColor.deepVoid.opacity(0.4))
                        )
                        .overlay(
                            Circle()
                                .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                        )
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("Open profile settings")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Spacer()
        }
        .frame(height: 100)
        .background(
            LinearGradient(
                colors: [
                    QXColor.cosmicBlack.opacity(showBackground ? 0.95 : 0),
                    QXColor.cosmicBlack.opacity(showBackground ? 0.9 : 0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .animation(.easeInOut(duration: 0.2), value: showBackground)
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let settingsItems: [SettingsSection] = [
        SettingsSection(title: "Account", items: [
            SettingsItem(icon: "person.fill", title: "Edit Profile", color: QXColor.gold),
            SettingsItem(icon: "creditcard.fill", title: "Subscription", color: QXColor.gold),
            SettingsItem(icon: "bell.fill", title: "Notifications", color: QXColor.mysticPurple)
        ]),
        SettingsSection(title: "Preferences", items: [
            SettingsItem(icon: "moon.fill", title: "Appearance", color: QXColor.cosmicTeal),
            SettingsItem(icon: "lock.fill", title: "Privacy", color: QXColor.nebulaBlue),
            SettingsItem(icon: "globe", title: "Language", color: QXColor.goldMuted)
        ]),
        SettingsSection(title: "Support", items: [
            SettingsItem(icon: "questionmark.circle.fill", title: "Help Center", color: QXColor.stardust),
            SettingsItem(icon: "envelope.fill", title: "Contact Us", color: QXColor.stardust),
            SettingsItem(icon: "star.fill", title: "Rate QodeX", color: QXColor.gold)
        ])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                QXColor.cosmicBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(settingsItems) { section in
                            SettingsSectionView(section: section)
                        }
                        
                        // Sign out button
                        Button(action: {
                            _ = AuthManager.shared.signOut()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left.square")
                                    .font(.system(size: 18))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Version
                        Text("QodeX v2.0.1")
                            .font(.system(size: 12))
                            .foregroundColor(QXColor.stardust)
                            .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(QXColor.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsSectionView: View {
    let section: SettingsSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(QXColor.stardust)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)
            
            VStack(spacing: 1) {
                ForEach(section.items) { item in
                    SettingsRow(item: item)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(QXColor.deepVoid.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsRow: View {
    let item: SettingsItem
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(item.color)
                    .frame(width: 28)
                
                Text(item.title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(QXColor.stardust)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    let user: ProfileUser
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                QXColor.cosmicBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar editor
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [QXColor.mysticPurple.opacity(0.3), QXColor.gold.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(user.avatar)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Edit button
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(QXColor.gold)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(QXColor.cosmicBlack)
                                        )
                                }
                            }
                            .frame(width: 120, height: 120)
                        }
                        
                        // Form fields
                        VStack(spacing: 16) {
                            EditField(title: "Full Name", text: .constant(user.fullName), icon: "person")
                            EditField(title: "Username", text: .constant(user.username), icon: "at")
                            EditField(title: "Bio", text: .constant(user.bio), icon: "text.quote", isMultiline: true)
                            EditField(title: "Email", text: .constant("alex@example.com"), icon: "envelope")
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(QXColor.stardust)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .foregroundColor(QXColor.gold)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct EditField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(QXColor.stardust)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(QXColor.gold)
                
                if isMultiline {
                    TextEditor(text: $text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(height: 80)
                } else {
                    TextField("", text: $text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, isMultiline ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(QXColor.deepVoid.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Glass Card Background
struct GlassCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(QXColor.deepVoid.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [QXColor.gold.opacity(0.15), QXColor.mysticPurple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
    }
}

// MARK: - Mesh Gradient Background
struct MeshGradientBackground: View {
    @State private var phase: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base gradient
                QXColor.cosmicBlack
                
                // Animated orbs
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [QXColor.mysticPurple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(
                        x: sin(phase * 0.01) * 50,
                        y: cos(phase * 0.01) * 30
                    )
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [QXColor.gold.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(
                        x: cos(phase * 0.008) * 60 + geo.size.width * 0.3,
                        y: sin(phase * 0.008) * 40 - geo.size.height * 0.2
                    )
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [QXColor.cosmicTeal.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(
                        x: sin(phase * 0.012) * 40 - geo.size.width * 0.2,
                        y: cos(phase * 0.012) * 50 + geo.size.height * 0.3
                    )
            }
        }
        .blur(radius: 60)
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

// MARK: - Data Models

struct ProfileUser {
    let id: String
    let fullName: String
    let username: String
    let bio: String
    let avatar: String
    let lifePathNumber: Int
    let membershipTier: MembershipTier
    let stats: ProfileStats
    let joinDate: Date
}

struct ProfileStats {
    let readings: Int
    let streak: Int
    let followers: Int
    let following: Int
}

enum MembershipTier: String {
    case free = "Free"
    case pro = "Pro"
    case elite = "Elite"
    
    var displayName: String {
        switch self {
        case .free: return "Free Seeker"
        case .pro: return "Pro Member"
        case .elite: return "Elite Cosmic"
        }
    }
    
    var icon: String {
        switch self {
        case .free: return "sparkle"
        case .pro: return "star.fill"
        case .elite: return "crown.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .free: return QXColor.starlight.opacity(0.15)
        case .pro: return QXColor.mysticPurple.opacity(0.25)
        case .elite: return QXColor.gold.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch self {
        case .free: return QXColor.moonlight
        case .pro: return QXColor.mysticPurple
        case .elite: return QXColor.gold
        }
    }
    
    var borderColor: Color {
        switch self {
        case .free: return QXColor.stardust.opacity(0.2)
        case .pro: return QXColor.mysticPurple.opacity(0.4)
        case .elite: return QXColor.gold.opacity(0.4)
        }
    }
}

struct UserActivity: Identifiable {
    let id = UUID()
    let type: ActivityType
    let title: String
    let subtitle: String
    let time: String
    let icon: String
}

enum ActivityType {
    case reading, session, milestone, achievement, journal
    
    var color: Color {
        switch self {
        case .reading: return QXColor.mysticPurple
        case .session: return QXColor.cosmicTeal
        case .milestone: return QXColor.gold
        case .achievement: return QXColor.goldGlow
        case .journal: return QXColor.nebulaBlue
        }
    }
}

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let progress: Double
}

struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

// MARK: - Color Extensions
extension Color {
    static var gold: Color { QXColor.gold }
    static var goldGlow: Color { QXColor.goldGlow }
    static var mysticPurple: Color { QXColor.mysticPurple }
    static var cosmicTeal: Color { QXColor.cosmicTeal }
    static var nebulaBlue: Color { QXColor.nebulaBlue }
}

// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
        .preferredColorScheme(.dark)
}
