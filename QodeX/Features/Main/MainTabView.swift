//
//  MainTabView.swift
//  Main app navigation with standard iOS TabView pattern
//  Reference: iOS 18 Human Interface Guidelines - Tab Bars
//

import SwiftUI

// MARK: - Main Tab View (Standard iOS Pattern)

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Today Tab - Daily insights and personal qode
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)
                .accessibilityLabel("Today tab")
                .accessibilityHint("View daily insights and your personal qode")
            
            // Blueprint Tab - Personal blueprint/chart
            BlueprintView()
                .tabItem {
                    Label("Blueprint", systemImage: "person.fill")
                }
                .tag(1)
                .accessibilityLabel("Blueprint tab")
                .accessibilityHint("View your personal numerology blueprint")
            
            // Explore Tab - Content discovery
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "square.grid.2x2")
                }
                .tag(2)
                .accessibilityLabel("Explore tab")
                .accessibilityHint("Discover wisdom systems and content")
            
            // Practice Tab - Exercises and challenges
            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "sparkles")
                }
                .tag(3)
                .accessibilityLabel("Practice tab")
                .accessibilityHint("Access daily exercises and spiritual practices")
            
            // Profile Tab - Settings and account
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "gearshape.fill")
                }
                .tag(4)
                .accessibilityLabel("Profile tab")
                .accessibilityHint("Manage your account and settings")
        }
        .tint(QXColor.gold)
        .onAppear {
            // Configure tab bar appearance for dark theme
            configureTabBarAppearance()
            
            // Announce initial tab for VoiceOver
            VoiceOver.announce("QodeX app. Today tab selected. Swipe up to explore options.")
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            let tabNames = ["Today", "Blueprint", "Explore", "Practice", "Profile"]
            VoiceOver.announce("\(tabNames[newValue]) tab")
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(QXColor.deepVoid)
        
        // Unselected item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(QXColor.starlight.opacity(0.5))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(QXColor.starlight.opacity(0.5))
        ]
        
        // Selected item color (gold)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(QXColor.gold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(QXColor.gold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Today View

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showStreakCelebration = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Streak Header
                StreakHeader(streak: viewModel.currentStreak)
                    .onTapGesture {
                        if viewModel.isStreakMilestone {
                            showStreakCelebration = true
                        }
                    }
                
                // Today's Qode Card
                TodayQodeCard(dailyQode: viewModel.dailyQode)
                
                // Quick Actions
                QuickActionsSection()
                
                // Daily Insight
                DailyInsightCard(insight: viewModel.dailyInsight)
                
                // Reading Streak Progress
                ReadingStreakProgress(
                    currentStreak: viewModel.readingStreak,
                    longestStreak: viewModel.longestReadingStreak
                )
            }
            .padding(.vertical, 20)
        }
        .background(QXColor.cosmicBlack.ignoresSafeArea())
        .sheet(isPresented: $showStreakCelebration) {
            StreakCelebrationView(streak: viewModel.currentStreak)
        }
        .onAppear {
            viewModel.recordTodayVisit()
        }
    }
}

// MARK: - Streak Header

struct StreakHeader: View {
    let streak: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(QXFont.largeTitle)
                    .foregroundStyle(QXColor.starlight)
                    .accessibilityAddTraits(.isHeader)
                
                Text(formattedDate())
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.6))
            }
            
            Spacer()
            
            // Streak Badge
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(QXColor.gold)
                    .applyIf(!UIAccessibility.isReduceMotionEnabled) {
                        $0.scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    .accessibilityHidden(true) // Decorative
                
                Text("\(streak)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(QXColor.gold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(QXColor.gold.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                    )
            )
            .accessibilityLabel("\(streak) day streak")
            .accessibilityHint("Double tap to view streak details")
        }
        .padding(.horizontal, 20)
        .onAppear { 
            if !UIAccessibility.isReduceMotionEnabled {
                isAnimating = true 
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Today Qode Card

struct TodayQodeCard: View {
    let dailyQode: DailyQode
    @State private var isFlipped = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.gold)
                    
                    Text("Today's Qode")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                Text("#\(dailyQode.number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(QXColor.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(QXColor.gold.opacity(0.15))
                    )
            }
            
            Divider()
                .background(QXColor.gold.opacity(0.2))
            
            Text(dailyQode.message)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.9))
                .lineSpacing(6)
            
            HStack {
                Label("3 min read", systemImage: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        isFlipped.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isFlipped ? "Hide" : "Explore")
                            .font(QXFont.caption)
                        Image(systemName: isFlipped ? "chevron.up" : "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(QXColor.gold)
                }
            }
            
            if isFlipped {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Deep Dive")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.gold)
                    
                    Text(dailyQode.extendedMessage)
                        .font(QXFont.subheadline)
                        .foregroundStyle(QXColor.starlight.opacity(0.7))
                        .lineSpacing(4)
                }
                .padding(.top, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "number.circle",
                        title: "Calculate",
                        subtitle: "New Qode",
                        color: QXColor.cosmicPurple
                    )
                    
                    QuickActionButton(
                        icon: "book.closed",
                        title: "Library",
                        subtitle: "Teachings",
                        color: QXColor.nebulaBlue
                    )
                    
                    QuickActionButton(
                        icon: "person.3",
                        title: "Community",
                        subtitle: "Circle",
                        color: QXColor.goldMuted
                    )
                    
                    QuickActionButton(
                        icon: "video.fill",
                        title: "Live",
                        subtitle: "Sessions",
                        color: QXColor.cosmicTeal
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                    .accessibilityHidden(true) // Decorative icon
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QXColor.starlight)
                    
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
            .frame(width: 100, height: 100)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibleButton(label: "\(title), \(subtitle)", hint: "Double tap to open \(title)")
        .minimumTouchTarget()
    }
}

// MARK: - Daily Insight Card

struct DailyInsightCard: View {
    let insight: DailyInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.cosmicTeal)
                    
                    Text("Daily Insight")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                if insight.isNew {
                    Text("NEW")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(QXColor.cosmicBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(QXColor.gold)
                        .cornerRadius(4)
                }
            }
            
            Text(insight.title)
                .font(QXFont.title3)
                .foregroundStyle(QXColor.starlight)
            
            Text(insight.description)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Reading Streak Progress

struct ReadingStreakProgress: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reading Streak")
                    .font(QXFont.headline)
                    .foregroundStyle(QXColor.starlight)
                
                Spacer()
                
                Text("\(currentStreak) days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QXColor.gold)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(QXColor.sacredGeometry)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(CGFloat(currentStreak) / 30.0, 1.0), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Goal: 30 days")
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                Spacer()
                
                if longestStreak > 0 {
                    Text("Best: \(longestStreak)")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Blueprint View

struct BlueprintView: View {
    @StateObject private var viewModel = BlueprintViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Personal Chart Header
                BlueprintHeader()
                
                // Life Path Card
                LifePathCard(lifePath: viewModel.lifePath)
                
                // Core Numbers Grid
                CoreNumbersGrid(numbers: viewModel.coreNumbers)
                
                // Personal Year
                PersonalYearCard(year: viewModel.personalYear)
            }
            .padding(.vertical, 20)
        }
        .background(QXColor.cosmicBlack.ignoresSafeArea())
    }
}

struct BlueprintHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Blueprint")
                .font(QXFont.largeTitle)
                .foregroundStyle(QXColor.starlight)
            
            Text("The energetic map of who you are")
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

struct LifePathCard: View {
    let lifePath: LifePathInfo
    
    var body: some View {
        VStack(spacing: 20) {
            // Number display
            ZStack {
                Circle()
                    .fill(QXColor.gold.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(QXColor.gold.opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)
                
                Text("\(lifePath.number)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(QXColor.gold)
            }
            
            VStack(spacing: 8) {
                Text(lifePath.title)
                    .font(QXFont.title2)
                    .foregroundStyle(QXColor.starlight)
                
                Text(lifePath.description)
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct CoreNumbersGrid: View {
    let numbers: [CoreNumber]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Core Numbers")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(numbers) { number in
                    CoreNumberCard(number: number)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CoreNumberCard: View {
    let number: CoreNumber
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(number.value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(QXColor.gold)
            
            Text(number.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(QXColor.starlight)
            
            Text(number.meaning)
                .font(.system(size: 11))
                .foregroundStyle(QXColor.starlight.opacity(0.5))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
    }
}

struct PersonalYearCard: View {
    let year: PersonalYearInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.cosmicTeal)
                    
                    Text("Personal Year")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                Text("\(year.number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(QXColor.cosmicTeal)
            }
            
            Text(year.theme)
                .font(QXFont.title3)
                .foregroundStyle(QXColor.starlight)
            
            Text(year.description)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.cosmicTeal.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Explore View

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                ExploreHeader()
                
                // Discovery Progress
                DiscoveryProgressCard(progress: viewModel.discoveryProgress)
                
                // Categories Grid
                CategoriesGrid(categories: viewModel.categories)
                
                // Featured Content
                FeaturedSection(featured: viewModel.featuredContent)
                
                // Recently Unlocked
                if !viewModel.recentlyUnlocked.isEmpty {
                    RecentlyUnlockedSection(items: viewModel.recentlyUnlocked)
                }
            }
            .padding(.vertical, 20)
        }
        .background(QXColor.cosmicBlack.ignoresSafeArea())
    }
}

struct ExploreHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explore")
                .font(QXFont.largeTitle)
                .foregroundStyle(QXColor.starlight)
            
            Text("Discover the systems of wisdom")
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

struct DiscoveryProgressCard: View {
    let progress: DiscoveryProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discovery Progress")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                    
                    Text("\(progress.completedSystems) of \(progress.totalSystems) systems explored")
                        .font(.system(size: 13))
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                }
                
                Spacer()
                
                Text("\(Int(progress.percentage))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(QXColor.gold)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(QXColor.sacredGeometry)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress.percentage / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // Next unlock hint
            if let nextUnlock = progress.nextUnlock {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                    
                    Text("Next: \(nextUnlock)")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct CategoriesGrid: View {
    let categories: [ExploreCategory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wisdom Systems")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(categories) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CategoryCard: View {
    let category: ExploreCategory
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(category.color)
                    
                    Spacer()
                    
                    if category.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(QXColor.starlight.opacity(0.3))
                    } else if category.isNew {
                        Text("NEW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(QXColor.cosmicBlack)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(QXColor.gold)
                            .cornerRadius(4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(category.isLocked ? QXColor.starlight.opacity(0.4) : QXColor.starlight)
                    
                    Text(category.description)
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(category.isLocked ? 0.3 : 0.5))
                        .lineLimit(2)
                }
                
                if !category.isLocked, let progress = category.progress {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(QXColor.sacredGeometry)
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(category.color)
                                .frame(width: geo.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(16)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid.opacity(category.isLocked ? 0.3 : 0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                category.isLocked ? QXColor.starlight.opacity(0.1) : category.color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .overlay(
                Group {
                    if category.isLocked {
                        Color.black.opacity(0.3)
                            .blur(radius: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(category.isLocked)
    }
}

struct FeaturedSection: View {
    let featured: [FeaturedContent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featured) { item in
                        FeaturedContentCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct FeaturedContentCard: View {
    let item: FeaturedContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(item.color.opacity(0.2))
                    .frame(width: 260, height: 140)
                
                Image(systemName: item.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(item.color)
                
                if item.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(QXColor.gold)
                                .padding(8)
                                .background(QXColor.cosmicBlack.opacity(0.7))
                                .clipShape(Circle())
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                
                Text(item.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .frame(width: 260)
    }
}

struct RecentlyUnlockedSection: View {
    let items: [UnlockedItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recently Unlocked")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        UnlockedItemCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct UnlockedItemCard: View {
    let item: UnlockedItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundStyle(QXColor.gold)
                .frame(width: 48, height: 48)
                .background(QXColor.gold.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QXColor.starlight)
                
                Text(item.unlockDate)
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
    }
}

// MARK: - Practice View

struct PracticeView: View {
    @StateObject private var viewModel = PracticeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PracticeHeader()
                
                // Daily Challenge
                DailyChallengeCard(challenge: viewModel.dailyChallenge)
                
                // Meditation Section
                MeditationSection(meditations: viewModel.meditations)
                
                // Exercises
                ExercisesSection(exercises: viewModel.exercises)
                
                // Journal Entry
                JournalPromptCard(prompt: viewModel.journalPrompt)
            }
            .padding(.vertical, 20)
        }
        .background(QXColor.cosmicBlack.ignoresSafeArea())
    }
}

struct PracticeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Practice")
                .font(QXFont.largeTitle)
                .foregroundStyle(QXColor.starlight)
            
            Text("Daily exercises for spiritual growth")
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

struct DailyChallengeCard: View {
    let challenge: DailyChallenge
    @State private var isCompleted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.gold)
                    
                    Text("Daily Challenge")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(QXColor.success)
                }
            }
            
            Text(challenge.title)
                .font(QXFont.title3)
                .foregroundStyle(QXColor.starlight)
            
            Text(challenge.description)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.7))
                .lineSpacing(4)
            
            Button(action: {
                withAnimation {
                    isCompleted = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isCompleted ? "checkmark" : "play.fill")
                    Text(isCompleted ? "Completed" : "Start Challenge")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isCompleted ? QXColor.success : QXColor.cosmicBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isCompleted ? QXColor.success.opacity(0.2) : QXColor.gold)
                .cornerRadius(12)
            }
            .disabled(isCompleted)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct MeditationSection: View {
    let meditations: [Meditation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meditations")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(meditations) { meditation in
                        MeditationCard(meditation: meditation)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct MeditationCard: View {
    let meditation: Meditation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(meditation.color.opacity(0.2))
                    .frame(width: 160, height: 120)
                
                Image(systemName: meditation.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(meditation.color)
                
                // Play button overlay
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meditation.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(QXColor.starlight)
                
                Text(meditation.duration)
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .frame(width: 160)
    }
}

struct ExercisesSection: View {
    let exercises: [Exercise]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercises")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(exercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: exercise.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(exercise.color)
                    .frame(width: 48, height: 48)
                    .background(exercise.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(QXColor.starlight)
                    
                    Text(exercise.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(QXColor.starlight.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid.opacity(0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalPromptCard: View {
    let prompt: JournalPrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.mysticPurple)
                    
                    Text("Journal Prompt")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                Text("Today")
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
            
            Text(prompt.text)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.9))
                .lineSpacing(6)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                    Text("Write Entry")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(QXColor.mysticPurple)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(QXColor.mysticPurple.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.mysticPurple.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Supporting Models

struct DailyQode {
    let number: Int
    let message: String
    let extendedMessage: String
}

struct DailyInsight {
    let title: String
    let description: String
    let isNew: Bool
}

struct LifePathInfo {
    let number: Int
    let title: String
    let description: String
}

struct CoreNumber: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let meaning: String
}

struct PersonalYearInfo {
    let number: Int
    let theme: String
    let description: String
}

struct DiscoveryProgress {
    let completedSystems: Int
    let totalSystems: Int
    let nextUnlock: String?
    
    var percentage: Double {
        Double(completedSystems) / Double(totalSystems) * 100
    }
}

struct ExploreCategory: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let isLocked: Bool
    let isNew: Bool
    let progress: Double?
}

struct FeaturedContent: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isPremium: Bool
}

struct UnlockedItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let unlockDate: String
}

struct DailyChallenge {
    let title: String
    let description: String
}

struct Meditation: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let icon: String
    let color: Color
}

struct Exercise: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct JournalPrompt {
    let text: String
}

// MARK: - Preview

#Preview("MainTabView") {
    MainTabView()
        .environmentObject(AuthManager.shared)
        .preferredColorScheme(.dark)
}
