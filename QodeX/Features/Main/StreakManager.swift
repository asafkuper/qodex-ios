//
//  StreakManager.swift
//  QodeX Engagement System
//  Manages daily streaks and milestone celebrations
//

import SwiftUI
import Combine

// MARK: - Streak Manager

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActiveDate: Date?
    @Published var showCelebration: Bool = false
    @Published var milestoneToCelebrate: StreakMilestone?
    
    private let userDefaults = UserDefaults.standard
    private let calendar = Calendar.current
    
    private enum Keys {
        static let currentStreak = "streak_current"
        static let longestStreak = "streak_longest"
        static let lastActiveDate = "streak_last_active"
        static let celebratedMilestones = "streak_celebrated_milestones"
    }
    
    private init() {
        loadStreakData()
    }
    
    // MARK: - Public Methods
    
    /// Records user activity and updates streak
    func recordActivity() {
        let today = calendar.startOfDay(for: Date())
        
        guard let lastActive = lastActiveDate else {
            // First activity ever
            updateStreak(to: 1, lastActive: today)
            return
        }
        
        let lastActiveDay = calendar.startOfDay(for: lastActive)
        
        if calendar.isDate(today, inSameDayAs: lastActiveDay) {
            // Already recorded today, do nothing
            return
        }
        
        if calendar.isDate(today, equalTo: calendar.date(byAdding: .day, value: 1, to: lastActiveDay)!, toGranularity: .day) {
            // Consecutive day - increment streak
            let newStreak = currentStreak + 1
            updateStreak(to: newStreak, lastActive: today)
            checkForMilestone(newStreak)
        } else if today > lastActiveDay {
            // Streak broken - start over
            updateStreak(to: 1, lastActive: today)
        }
    }
    
    /// Checks if today has been recorded
    var hasRecordedToday: Bool {
        guard let lastActive = lastActiveDate else { return false }
        return calendar.isDate(Date(), inSameDayAs: lastActive)
    }
    
    /// Returns the next milestone
    var nextMilestone: StreakMilestone? {
        return StreakMilestone.allCases.first { $0.days > currentStreak }
    }
    
    /// Days until next milestone
    var daysUntilNextMilestone: Int {
        guard let next = nextMilestone else { return 0 }
        return next.days - currentStreak
    }
    
    // MARK: - Private Methods
    
    private func loadStreakData() {
        currentStreak = userDefaults.integer(forKey: Keys.currentStreak)
        longestStreak = userDefaults.integer(forKey: Keys.longestStreak)
        lastActiveDate = userDefaults.object(forKey: Keys.lastActiveDate) as? Date
    }
    
    private func updateStreak(to value: Int, lastActive: Date) {
        currentStreak = value
        lastActiveDate = lastActive
        
        if value > longestStreak {
            longestStreak = value
            userDefaults.set(longestStreak, forKey: Keys.longestStreak)
        }
        
        userDefaults.set(currentStreak, forKey: Keys.currentStreak)
        userDefaults.set(lastActive, forKey: Keys.lastActiveDate)
    }
    
    private func checkForMilestone(_ streak: Int) {
        guard let milestone = StreakMilestone(rawValue: streak) else { return }
        
        let celebrated = userDefaults.array(forKey: Keys.celebratedMilestones) as? [Int] ?? []
        
        if !celebrated.contains(streak) {
            // New milestone reached!
            milestoneToCelebrate = milestone
            showCelebration = true
            
            var updatedCelebrated = celebrated
            updatedCelebrated.append(streak)
            userDefaults.set(updatedCelebrated, forKey: Keys.celebratedMilestones)
        }
    }
    
    /// Reset for testing purposes
    func reset() {
        currentStreak = 0
        longestStreak = 0
        lastActiveDate = nil
        userDefaults.removeObject(forKey: Keys.currentStreak)
        userDefaults.removeObject(forKey: Keys.longestStreak)
        userDefaults.removeObject(forKey: Keys.lastActiveDate)
        userDefaults.removeObject(forKey: Keys.celebratedMilestones)
    }
}

// MARK: - Streak Milestone

enum StreakMilestone: Int, CaseIterable {
    case threeDays = 3
    case sevenDays = 7
    case thirtyDays = 30
    case oneHundredDays = 100
    
    var days: Int { rawValue }
    
    var title: String {
        switch self {
        case .threeDays:
            return "3-Day Streak!"
        case .sevenDays:
            return "Week Warrior!"
        case .thirtyDays:
            return "Monthly Master!"
        case .oneHundredDays:
            return "Century Champion!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .threeDays:
            return "You're building momentum!"
        case .sevenDays:
            return "A full week of growth!"
        case .thirtyDays:
            return "A month of dedication!"
        case .oneHundredDays:
            return "100 days of transformation!"
        }
    }
    
    var message: String {
        switch self {
        case .threeDays:
            return "Three days in a row! You're establishing a powerful new habit."
        case .sevenDays:
            return "A complete week! Your commitment to self-discovery is inspiring."
        case .thirtyDays:
            return "A whole month of daily practice! You've created real change in your life."
        case .oneHundredDays:
            return "100 days of showing up for yourself! You are truly transformed."
        }
    }
    
    var icon: String {
        switch self {
        case .threeDays:
            return "flame.fill"
        case .sevenDays:
            return "star.circle.fill"
        case .thirtyDays:
            return "crown.fill"
        case .oneHundredDays:
            return "trophy.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .threeDays:
            return QXColor.gold
        case .sevenDays:
            return QXColor.cosmicPurple
        case .thirtyDays:
            return QXColor.cosmicTeal
        case .oneHundredDays:
            return QXColor.gold
        }
    }
    
    var animationType: CelebrationAnimation {
        switch self {
        case .threeDays:
            return .sparkle
        case .sevenDays:
            return .burst
        case .thirtyDays:
            return .fireworks
        case .oneHundredDays:
            return .grandFinale
        }
    }
}

enum CelebrationAnimation {
    case sparkle
    case burst
    case fireworks
    case grandFinale
}

// MARK: - Streak Celebration View

struct StreakCelebrationView: View {
    let streak: Int
    @Environment(\.dismiss) var dismiss
    @State private var animationPhase = 0
    @State private var showConfetti = false
    
    private var milestone: StreakMilestone? {
        StreakMilestone(rawValue: streak)
    }
    
    var body: some View {
        ZStack {
            // Background
            QXColor.cosmicBlack.ignoresSafeArea()
            
            // Animated background effects
            CelebrationBackground(animationPhase: animationPhase)
            
            // Confetti effect
            if showConfetti {
                ConfettiView()
            }
            
            // Main content
            VStack(spacing: 32) {
                Spacer()
                
                // Icon with animation
                CelebrationIcon(milestone: milestone, phase: animationPhase)
                    .scaleEffect(animationPhase >= 1 ? 1.0 : 0.3)
                    .opacity(animationPhase >= 1 ? 1.0 : 0)
                
                // Text content
                VStack(spacing: 16) {
                    Text(milestone?.title ?? "\(streak)-Day Streak!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(QXColor.gold)
                        .opacity(animationPhase >= 2 ? 1.0 : 0)
                        .offset(y: animationPhase >= 2 ? 0 : 20)
                    
                    Text(milestone?.subtitle ?? "Keep it going!")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(QXColor.starlight)
                        .opacity(animationPhase >= 2 ? 1.0 : 0)
                        .offset(y: animationPhase >= 2 ? 0 : 20)
                    
                    Text(milestone?.message ?? "You're on a roll!")
                        .font(.system(size: 17))
                        .foregroundStyle(QXColor.starlight.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(4)
                        .opacity(animationPhase >= 3 ? 1.0 : 0)
                        .offset(y: animationPhase >= 3 ? 0 : 20)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    dismiss()
                }) {
                    Text("Keep Going!")
                        .font(.system(size: 17, weight: .semibold))
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
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(animationPhase >= 4 ? 1.0 : 0)
                .offset(y: animationPhase >= 4 ? 0 : 50)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let phases = [0, 1, 2, 3, 4]
        let delays: [Double] = [0, 0.3, 0.6, 0.9, 1.2]
        
        for (index, phase) in phases.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delays[index]) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animationPhase = phase
                }
                if phase == 1 {
                    showConfetti = true
                    QXHaptic.premiumUnlock()
                }
            }
        }
    }
}

// MARK: - Celebration Icon

struct CelebrationIcon: View {
    let milestone: StreakMilestone?
    let phase: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (milestone?.color ?? QXColor.gold).opacity(0.4),
                            .clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            // Orbiting particles
            if phase >= 1 {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(milestone?.color ?? QXColor.gold)
                        .frame(width: 8, height: 8)
                        .offset(
                            x: cos(Double(i) * .pi / 4) * 100,
                            y: sin(Double(i) * .pi / 4) * 100
                        )
                        .opacity(isAnimating ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 1)
                                .delay(Double(i) * 0.1)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            // Main icon container
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                (milestone?.color ?? QXColor.gold).opacity(0.3),
                                (milestone?.color ?? QXColor.gold).opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Circle()
                    .stroke(
                        (milestone?.color ?? QXColor.gold).opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(width: 140, height: 140)
                
                // Icon
                Image(systemName: milestone?.icon ?? "flame.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [milestone?.color ?? QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
                    .animation(
                        .linear(duration: 20).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Celebration Background

struct CelebrationBackground: View {
    let animationPhase: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Animated rings
            ForEach(0..<3) { i in
                Circle()
                    .stroke(QXColor.gold.opacity(0.1 - Double(i) * 0.03), lineWidth: 1)
                    .frame(width: 200 + CGFloat(i * 100), height: 200 + CGFloat(i * 100))
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.6 : 0.2)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 20 + Double(i) * 10)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            // Floating orbs
            ForEach(0..<5) { i in
                Circle()
                    .fill(QXColor.gold.opacity(0.1))
                    .frame(width: 20, height: 20)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .opacity(animationPhase >= 1 ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 3)
                            .delay(Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let x = particle.x * size.width
                    let y = particle.y * size.height
                    
                    var path = Path()
                    path.addRect(CGRect(x: x, y: y, width: 8, height: 8))
                    
                    context.fill(
                        path,
                        with: .color(particle.color.opacity(particle.opacity))
                    )
                }
            }
        }
        .onAppear {
            createParticles()
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            updateParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [QXColor.gold, QXColor.goldGlow, QXColor.cosmicPurple, QXColor.cosmicTeal, QXColor.mysticPurple]
        
        particles = (0..<50).map { _ in
            ConfettiParticle(
                x: 0.5,
                y: -0.1,
                vx: CGFloat.random(in: -0.02...0.02),
                vy: CGFloat.random(in: 0.005...0.015),
                color: colors.randomElement() ?? QXColor.gold,
                rotation: CGFloat.random(in: 0...360),
                rotationSpeed: CGFloat.random(in: -5...5),
                opacity: 1.0
            )
        }
    }
    
    private func updateParticles() {
        for index in particles.indices {
            particles[index].x += particles[index].vx
            particles[index].y += particles[index].vy
            particles[index].vy += 0.0002 // Gravity
            particles[index].rotation += particles[index].rotationSpeed
            particles[index].opacity -= 0.005
            
            // Reset if off screen or faded
            if particles[index].y > 1.2 || particles[index].opacity <= 0 {
                particles[index].y = -0.1
                particles[index].x = 0.5
                particles[index].vy = CGFloat.random(in: 0.005...0.015)
                particles[index].opacity = 1.0
            }
        }
    }
}

struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var color: Color
    var rotation: CGFloat
    var rotationSpeed: CGFloat
    var opacity: CGFloat
}

// MARK: - Streak Badge Component

struct StreakBadge: View {
    let streak: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundStyle(QXColor.gold)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("\(streak)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(QXColor.starlight)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(QXColor.gold.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear { isAnimating = streak > 0 }
    }
}

// MARK: - Mini Streak Progress View

struct MiniStreakProgress: View {
    @StateObject private var streakManager = StreakManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.gold)
                    
                    Text("\(streakManager.currentStreak) day streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(QXColor.starlight)
                }
                
                Spacer()
                
                if let next = streakManager.nextMilestone {
                    Text("\(streakManager.daysUntilNextMilestone) to \(next.days)")
                        .font(.system(size: 11))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(QXColor.sacredGeometry)
                        .frame(height: 4)
                    
                    if let next = streakManager.nextMilestone {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [QXColor.gold, QXColor.goldGlow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(streakManager.currentStreak) / CGFloat(next.days),
                                height: 4
                            )
                    }
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
    }
}

// MARK: - Preview

#Preview("Streak Celebration - 3 Days") {
    StreakCelebrationView(streak: 3)
        .preferredColorScheme(.dark)
}

#Preview("Streak Celebration - 7 Days") {
    StreakCelebrationView(streak: 7)
        .preferredColorScheme(.dark)
}

#Preview("Streak Celebration - 30 Days") {
    StreakCelebrationView(streak: 30)
        .preferredColorScheme(.dark)
}

#Preview("Streak Celebration - 100 Days") {
    StreakCelebrationView(streak: 100)
        .preferredColorScheme(.dark)
}
