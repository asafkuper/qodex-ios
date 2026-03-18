//
//  CommunityChallengesView.swift
//  Gamified numerology challenges and rituals
//

import SwiftUI

struct CommunityChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    challengesHeader
                    
                    // Active challenges
                    if !viewModel.activeChallenges.isEmpty {
                        activeChallengesSection
                    }
                    
                    // Daily ritual
                    dailyRitualSection
                    
                    // Leaderboard
                    leaderboardSection
                    
                    // Upcoming challenges
                    upcomingChallengesSection
                    
                    // Completed challenges
                    if !viewModel.completedChallenges.isEmpty {
                        completedChallengesSection
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Challenges")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var challengesHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Community Challenges")
                    .font(QodeXTypography.title)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text("Grow together through numerology")
                    .font(QodeXTypography.body)
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            // User stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(QodeXColors.gold)
                    Text("\(viewModel.userStreak)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(QodeXColors.pureWhite)
                }
                
                Text("day streak")
                    .font(.system(size: 11))
                    .foregroundStyle(QodeXColors.stardust)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Now")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            ForEach(viewModel.activeChallenges) { challenge in
                ActiveChallengeCard(challenge: challenge)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var dailyRitualSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Ritual")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                if viewModel.dailyRitual.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(QodeXColors.cosmicTeal)
                }
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Ritual card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(QodeXColors.mysticPurple.opacity(0.2))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: viewModel.dailyRitual.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(QodeXColors.mysticPurple)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.dailyRitual.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(QodeXColors.pureWhite)
                            
                            Text(viewModel.dailyRitual.duration)
                                .font(.system(size: 12))
                                .foregroundStyle(QodeXColors.stardust)
                        }
                        
                        Spacer()
                        
                        if !viewModel.dailyRitual.isCompleted {
                            Button(action: { viewModel.startRitual() }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(QodeXColors.cosmicBlack)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(QodeXColors.gold)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    
                    Text(viewModel.dailyRitual.description)
                        .font(.system(size: 14))
                        .foregroundStyle(QodeXColors.moonlight)
                        .lineLimit(2)
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.dailyRitual.steps.indices, id: \.self) { index in
                            let step = viewModel.dailyRitual.steps[index]
                            HStack(spacing: 12) {
                                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(step.isCompleted ? QodeXColors.cosmicTeal : QodeXColors.stardust)
                                
                                Text(step.description)
                                    .font(.system(size: 13))
                                    .foregroundStyle(step.isCompleted ? QodeXColors.stardust : QodeXColors.pureWhite)
                                    .strikethrough(step.isCompleted)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(16)
                .background(QodeXColors.deepVoid)
                .cornerRadius(16)
                
                // Participants
                HStack {
                    HStack(spacing: -8) {
                        ForEach(0..<min(viewModel.dailyRitual.participantCount, 5), id: \.self) { _ in
                            Circle()
                                .fill(QodeXColors.starlight)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(QodeXColors.cosmicBlack, lineWidth: 2)
                                )
                        }
                    }
                    
                    Text("\(viewModel.dailyRitual.participantCount) members joined today")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.stardust)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week's Leaders")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Button("View All") {}
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.gold)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                ForEach(viewModel.leaderboard.prefix(5)) { entry in
                    LeaderboardRow(entry: entry, rank: viewModel.leaderboard.firstIndex(where: { $0.id == entry.id })! + 1)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var upcomingChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coming Soon")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.upcomingChallenges) { challenge in
                        UpcomingChallengeCard(challenge: challenge)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var completedChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Achievements")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.completedChallenges) { challenge in
                    AchievementBadge(challenge: challenge)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Supporting Views

struct ActiveChallengeCard: View {
    let challenge: CommunityChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(challenge.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: challenge.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(challenge.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Text("\(challenge.daysRemaining) days remaining")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.stardust)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(challenge.progress)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(challenge.color)
                    
                    Text("complete")
                        .font(.system(size: 10))
                        .foregroundStyle(QodeXColors.stardust)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(QodeXColors.starlight)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(challenge.color)
                        .frame(width: geo.size.width * Double(challenge.progress) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 12))
                    Text("\(challenge.participantCount)")
                        .font(.system(size: 12))
                }
                .foregroundStyle(QodeXColors.stardust)
                
                Spacer()
                
                Text("Reward: \(challenge.reward)")
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.gold)
            }
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rank == 1 ? QodeXColors.gold : (rank == 2 ? Color.gray : Color.orange))
                        .frame(width: 32, height: 32)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QodeXColors.stardust)
                        .frame(width: 32)
                }
                
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.cosmicBlack)
                }
            }
            
            // Avatar
            Circle()
                .fill(QodeXColors.starlight)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(entry.initials)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QodeXColors.pureWhite)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text(entry.tier)
                    .font(.system(size: 11))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            // Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.gold)
                Text("\(entry.points)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
            }
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

struct UpcomingChallengeCard: View {
    let challenge: CommunityChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(challenge.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: challenge.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(challenge.color)
            }
            
            Text(challenge.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QodeXColors.pureWhite)
                .lineLimit(2)
            
            Text("Starts \(challenge.startDate, style: .relative)")
                .font(.system(size: 11))
                .foregroundStyle(QodeXColors.stardust)
        }
        .frame(width: 140)
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

struct AchievementBadge: View {
    let challenge: CommunityChallenge
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(challenge.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: challenge.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(challenge.color)
                
                // Completion check
                Circle()
                    .fill(QodeXColors.cosmicTeal)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(QodeXColors.cosmicBlack)
                    )
                    .offset(x: 20, y: 20)
            }
            
            Text(challenge.title)
                .font(.system(size: 11))
                .foregroundStyle(QodeXColors.stardust)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - View Model

class ChallengesViewModel: ObservableObject {
    @Published var userStreak = 12
    @Published var activeChallenges: [CommunityChallenge] = []
    @Published var dailyRitual: DailyRitual = .mock
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var upcomingChallenges: [CommunityChallenge] = []
    @Published var completedChallenges: [CommunityChallenge] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        activeChallenges = [
            CommunityChallenge(
                id: "1",
                title: "7-Day Meditation Journey",
                description: "Meditate daily aligned with your Personal Day number",
                icon: "moon.fill",
                color: QodeXColors.mysticPurple,
                progress: 65,
                daysRemaining: 3,
                participantCount: 284,
                reward: "Master Meditator Badge"
            ),
            CommunityChallenge(
                id: "2",
                title: "Number Synchronicity Hunt",
                description: "Document 11:11 and other master number sightings",
                icon: "number",
                color: QodeXColors.gold,
                progress: 40,
                daysRemaining: 5,
                participantCount: 156,
                reward: "50 Points"
            )
        ]
        
        leaderboard = [
            LeaderboardEntry(name: "Sarah M.", initials: "SM", tier: "Qode Master", points: 2840),
            LeaderboardEntry(name: "David K.", initials: "DK", tier: "Initiate", points: 2650),
            LeaderboardEntry(name: "Emma L.", initials: "EL", tier: "Inner Circle", points: 2430),
            LeaderboardEntry(name: "James R.", initials: "JR", tier: "Inner Circle", points: 2180),
            LeaderboardEntry(name: "You", initials: "YO", tier: "Initiate", points: 1950)
        ]
        
        upcomingChallenges = [
            CommunityChallenge(id: "3", title: "Full Moon Ritual", description: "", icon: "moon.stars.fill", color: QodeXColors.cosmicTeal, progress: 0, daysRemaining: 0, participantCount: 0, reward: ""),
            CommunityChallenge(id: "4", title: "Life Path Deep Dive", description: "", icon: "arrow.forward.circle.fill", color: QodeXColors.mysticPurple, progress: 0, daysRemaining: 0, participantCount: 0, reward: ""),
            CommunityChallenge(id: "5", title: "Compatibility Marathon", description: "", icon: "heart.circle.fill", color: .red, progress: 0, daysRemaining: 0, participantCount: 0, reward: "")
        ]
        
        completedChallenges = [
            CommunityChallenge(id: "6", title: "21-Day Journal", description: "", icon: "book.closed.fill", color: QodeXColors.gold, progress: 100, daysRemaining: 0, participantCount: 0, reward: ""),
            CommunityChallenge(id: "7", title: "Gratitude Practice", description: "", icon: "hands.sparkles.fill", color: QodeXColors.cosmicTeal, progress: 100, daysRemaining: 0, participantCount: 0, reward: "")
        ]
    }
    
    func startRitual() {
        // Start ritual timer/flow
    }
}

// MARK: - Models

struct CommunityChallenge: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let progress: Int
    let daysRemaining: Int
    let participantCount: Int
    let reward: String
    var startDate: Date = Date()
}

struct DailyRitual {
    let title: String
    let description: String
    let duration: String
    let icon: String
    let steps: [RitualStep]
    let participantCount: Int
    var isCompleted: Bool
}

struct RitualStep {
    let description: String
    var isCompleted: Bool
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let tier: String
    let points: Int
}

extension DailyRitual {
    static var mock: DailyRitual {
        DailyRitual(
            title: "Morning Intention Setting",
            description: "Start your day aligned with your Personal Day number energy",
            duration: "5 minutes",
            icon: "sunrise.fill",
            steps: [
                RitualStep(description: "Check your Personal Day number", isCompleted: true),
                RitualStep(description: "Write one intention", isCompleted: false),
                RitualStep(description: "Take 3 deep breaths", isCompleted: false)
            ],
            participantCount: 423,
            isCompleted: false
        )
    }
}

// MARK: - Preview

#Preview {
    CommunityChallengesView()
}
