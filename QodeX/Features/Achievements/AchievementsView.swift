//
//  AchievementsView.swift
//  QodeX - Premium Achievements & Gamification
//  Inspired by Duolingo, Strava, Apple Fitness
//

import SwiftUI

struct AchievementsView: View {
    @State private var selectedFilter: Filter = .all
    
    enum Filter: String, CaseIterable {
        case all = "All"
        case earned = "Earned"
        case locked = "Locked"
    }
    
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
                        Text("Achievements")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("12")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.goldPrimary)
                            
                            Text("/ 25")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.starlightTertiary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Progress Card
                    ProgressCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Stats Row
                    StatsRow()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Filter Pills
                    FilterPills(selected: $selectedFilter)
                        .padding(.top, 24)
                    
                    // Achievement Grid
                    AchievementGrid()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    var body: some View {
        GlassCard {
            HStack(spacing: 20) {
                // Trophy
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [.goldPrimary, .goldBright, .goldPrimary]),
                                center: .center
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🏆")
                        .font(.system(size: 40))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievement Hunter")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.starlight)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.goldBright, .goldPrimary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.48, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("48% Complete")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.goldPrimary)
                        
                        Spacer()
                        
                        Text("13 more to unlock")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Stats Row
struct StatsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            StatCard(value: "12", label: "Earned", icon: "checkmark.circle.fill", color: .green)
            StatCard(value: "8", label: "In Progress", icon: "clock.fill", color: .blue)
            StatCard(value: "5", label: "Locked", icon: "lock.fill", color: .gray)
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.starlight)
            }
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Filter Pills
struct FilterPills: View {
    @Binding var selected: AchievementsView.Filter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AchievementsView.Filter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.rawValue,
                        isSelected: selected == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .cosmicBlack : .starlight)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.goldPrimary : Color.white.opacity(0.05))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Achievement Grid
struct AchievementGrid: View {
    let achievements = [
        Achievement(name: "First Reading", description: "Complete your first daily reading", icon: "📖", color: .blue, progress: 1.0, isEarned: true),
        Achievement(name: "7-Day Streak", description: "Read for 7 consecutive days", icon: "🔥", color: .orange, progress: 1.0, isEarned: true),
        Achievement(name: "30-Day Streak", description: "Read for 30 consecutive days", icon: "🌟", color: .goldPrimary, progress: 0.8, isEarned: false),
        Achievement(name: "Chart Explorer", description: "View all 5 core numbers", icon: "🔮", color: .purple, progress: 1.0, isEarned: true),
        Achievement(name: "Social Butterfly", description: "Follow 10 people", icon: "🦋", color: .pink, progress: 0.6, isEarned: false),
        Achievement(name: "Early Bird", description: "Check reading before 7 AM", icon: "🐦", color: .green, progress: 1.0, isEarned: true),
        Achievement(name: "Night Owl", description: "Check reading after 10 PM", icon: "🦉", color: .indigo, progress: 0.4, isEarned: false),
        Achievement(name: "Compatibility Pro", description: "Compare with 5 friends", icon: "❤️", color: .red, progress: 1.0, isEarned: true),
        Achievement(name: "Knowledge Seeker", description: "Read 10 articles", icon: "📚", color: .cyan, progress: 0.7, isEarned: false),
        Achievement(name: "Master Number", description: "Discover you have a Master Number", icon: "✨", color: .goldPrimary, progress: 1.0, isEarned: true),
        Achievement(name: "Journal Keeper", description: "Write 20 journal entries", icon: "📝", color: .brown, progress: 0.3, isEarned: false),
        Achievement(name: "Meditator", description: "Complete 10 meditations", icon: "🧘", color: .teal, progress: 0.5, isEarned: false)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
            ForEach(achievements) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let progress: Double
    let isEarned: Bool
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                ZStack {
                    if achievement.isEarned {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(achievement.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 48, height: 48)
                    }
                    
                    Text(achievement.icon)
                        .font(.system(size: 24))
                        .opacity(achievement.isEarned ? 1 : 0.5)
                }
                
                Spacer()
                
                if achievement.isEarned {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else {
                    Text("\(Int(achievement.progress * 100))%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.starlightTertiary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(achievement.isEarned ? .starlight : .starlightTertiary)
                
                Text(achievement.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                    .lineLimit(2)
            }
            
            if !achievement.isEarned {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(achievement.color)
                            .frame(width: geometry.size.width * achievement.progress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isEarned ? Color(hex: "12121A").opacity(0.6) : Color(hex: "0A0A0F"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isEarned ? achievement.color.opacity(0.3) : Color.white.opacity(0.03), lineWidth: achievement.isEarned ? 2 : 1)
        )
        .opacity(achievement.isEarned ? 1 : 0.7)
    }
}

// MARK: - Preview
struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .preferredColorScheme(.dark)
    }
}
