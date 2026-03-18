//
//  StreaksView.swift
//  QodeX - Premium Streak Tracking
//  Inspired by Duolingo, Snapchat
//

import SwiftUI

struct StreaksView: View {
    @State private var currentStreak: Int = 42
    @State private var longestStreak: Int = 67
    @State private var selectedWeek: Int = 0
    
    var body: some View {
        ZStack {
            // Animated flame background
            FlameBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Streaks")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 22))
                                .foregroundColor(.starlightTertiary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Current Streak Card
                    CurrentStreakCard(streak: currentStreak)
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    
                    // Stats Row
                    StreakStatsRow(current: currentStreak, longest: longestStreak)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Calendar Heatmap
                    CalendarHeatmap()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Milestones
                    MilestonesSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Streak Freeze
                    StreakFreezeCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Flame Background
struct FlameBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "1a0f0f")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated glow orbs
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: geometry.size.width / 2 - 200, y: -100)
                    .opacity(animate ? 0.6 : 0.3)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Current Streak Card
struct CurrentStreakCard: View {
    let streak: Int
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.3),
                            Color.red.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
            
            VStack(spacing: 8) {
                // Flame icon
                Text("🔥")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: scale)
                
                // Number
                Text("\(streak)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Day Streak")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Text("Keep it going!")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
        }
        .frame(height: 280)
        .onAppear { scale = 1.1 }
    }
}

// MARK: - Streak Stats Row
struct StreakStatsRow: View {
    let current: Int
    let longest: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatBox(
                value: "\(current)",
                label: "Current",
                icon: "🔥",
                color: .orange
            )
            
            StatBox(
                value: "\(longest)",
                label: "Longest",
                icon: "🏆",
                color: .goldPrimary
            )
            
            StatBox(
                value: "12",
                label: "Perfect Weeks",
                icon: "⭐",
                color: .yellow
            )
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Calendar Heatmap
struct CalendarHeatmap: View {
    let weeks = 12
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("Less")
                        .font(.system(size: 12))
                        .foregroundColor(.starlightTertiary)
                    
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(heatmapColor(for: i))
                            .frame(width: 12, height: 12)
                    }
                    
                    Text("More")
                        .font(.system(size: 12))
                        .foregroundColor(.starlightTertiary)
                }
            }
            
            // Day labels
            HStack(spacing: 4) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.starlightTertiary)
                        .frame(width: 24)
                }
            }
            
            // Heatmap grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<(weeks * 7), id: \.self) { index in
                    let intensity = Int.random(in: 0...4)
                    HeatmapCell(intensity: intensity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    func heatmapColor(for intensity: Int) -> Color {
        switch intensity {
        case 0: return Color.white.opacity(0.05)
        case 1: return Color.orange.opacity(0.2)
        case 2: return Color.orange.opacity(0.4)
        case 3: return Color.orange.opacity(0.6)
        default: return Color.orange.opacity(0.8)
        }
    }
}

struct HeatmapCell: View {
    let intensity: Int
    
    var color: Color {
        switch intensity {
        case 0: return Color.white.opacity(0.05)
        case 1: return Color.orange.opacity(0.2)
        case 2: return Color.orange.opacity(0.4)
        case 3: return Color.orange.opacity(0.6)
        default: return Color.orange
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(height: 24)
    }
}

// MARK: - Milestones Section
struct MilestonesSection: View {
    let milestones = [
        (days: 7, title: "Week Warrior", isEarned: true),
        (days: 30, title: "Monthly Master", isEarned: true),
        (days: 50, title: "Half Century", isEarned: false),
        (days: 100, title: "Centurion", isEarned: false),
        (days: 365, title: "Year Legend", isEarned: false)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(milestones, id: \.days) { milestone in
                        MilestoneCard(
                            days: milestone.days,
                            title: milestone.title,
                            isEarned: milestone.isEarned
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct MilestoneCard: View {
    let days: Int
    let title: String
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color.orange.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 72, height: 72)
                
                if isEarned {
                    Text("🔥")
                        .font(.system(size: 36))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.starlightTertiary)
                }
            }
            
            VStack(spacing: 2) {
                Text("\(days)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isEarned ? .orange : .starlightTertiary)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isEarned ? .starlight : .starlightQuaternary)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEarned ? Color(hex: "12121A") : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isEarned ? Color.orange.opacity(0.3) : Color.white.opacity(0.03), lineWidth: isEarned ? 2 : 1)
        )
        .opacity(isEarned ? 1 : 0.6)
    }
}

// MARK: - Streak Freeze Card
struct StreakFreezeCard: View {
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Text("❄️")
                        .font(.system(size: 28))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak Freeze Available")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    Text("Missed a day? Use your streak freeze to keep your progress.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text("2")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
        }
    }
}

// MARK: - Preview
struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
            .preferredColorScheme(.dark)
    }
}
