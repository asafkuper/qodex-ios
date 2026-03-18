//
//  GamificationEngine.swift
//  Achievement system and streak mechanics
//

import Foundation
import FirebaseFirestore

class GamificationEngine {
    static let shared = GamificationEngine()
    private let db = Firestore.firestore()
    
    // MARK: - Achievements
    enum Achievement: String, CaseIterable {
        case firstCalculation = "first_calculation"
        case streak7 = "streak_7"
        case streak30 = "streak_30"
        case streak100 = "streak_100"
        case streak365 = "streak_365"
        case chartMaster = "chart_master"
        case communityContributor = "community_contributor"
        case mentorMatch = "mentor_match"
        case liveAttendee = "live_attendee"
        case deepDiver = "deep_diver"
        case earlyBird = "early_bird"
        case nightOwl = "night_owl"
        case shareMaster = "share_master"
        case premiumPioneer = "premium_pioneer"
        
        var title: String {
            switch self {
            case .firstCalculation: return "First Steps"
            case .streak7: return "Week Warrior"
            case .streak30: return "Monthly Master"
            case .streak100: return "Century Club"
            case .streak365: return "Year of Power"
            case .chartMaster: return "Chart Master"
            case .communityContributor: return "Community Voice"
            case .mentorMatch: return "Guided Path"
            case .liveAttendee: return "Live & Present"
            case .deepDiver: return "Deep Diver"
            case .earlyBird: return "Early Bird"
            case .nightOwl: return "Night Owl"
            case .shareMaster: return "Spread the Light"
            case .premiumPioneer: return "Pioneer"
            }
        }
        
        var description: String {
            switch self {
            case .firstCalculation: return "Calculate your first numerology chart"
            case .streak7: return "Check your daily number 7 days in a row"
            case .streak30: return "Maintain a 30-day streak"
            case .streak100: return "Reach 100 consecutive days"
            case .streak365: return "Complete a full year of daily insights"
            case .chartMaster: return "View all 9 core numbers"
            case .communityContributor: return "Make your first community post"
            case .mentorMatch: return "Connect with a mentor"
            case .liveAttendee: return "Join your first live session"
            case .deepDiver: return "Spend 10 minutes in meditation"
            case .earlyBird: return "Check your numbers before 7 AM"
            case .nightOwl: return "Check your numbers after 10 PM"
            case .shareMaster: return "Share your reading 5 times"
            case .premiumPioneer: return "Upgrade to premium"
            }
        }
        
        var icon: String {
            switch self {
            case .firstCalculation: return "number.circle.fill"
            case .streak7: return "flame.fill"
            case .streak30: return "calendar.badge.clock"
            case .streak100: return "100.circle.fill"
            case .streak365: return "crown.fill"
            case .chartMaster: return "chart.pie.fill"
            case .communityContributor: return "bubble.left.fill"
            case .mentorMatch: return "person.2.fill"
            case .liveAttendee: return "video.fill"
            case .deepDiver: return "waveform"
            case .earlyBird: return "sunrise.fill"
            case .nightOwl: return "moon.fill"
            case .shareMaster: return "square.and.arrow.up.fill"
            case .premiumPioneer: return "star.fill"
            }
        }
        
        var xpReward: Int {
            switch self {
            case .firstCalculation: return 50
            case .streak7: return 100
            case .streak30: return 500
            case .streak100: return 2000
            case .streak365: return 10000
            case .chartMaster: return 150
            case .communityContributor: return 100
            case .mentorMatch: return 200
            case .liveAttendee: return 150
            case .deepDiver: return 75
            case .earlyBird: return 50
            case .nightOwl: return 50
            case .shareMaster: return 100
            case .premiumPioneer: return 300
            }
        }
    }
    
    // MARK: - Check Achievement
    func checkAndAwardAchievements(for user: QodeXUser) async {
        let earnedAchievements = await fetchEarnedAchievements(userId: user.id)
        
        for achievement in Achievement.allCases {
            guard !earnedAchievements.contains(achievement.rawValue) else { continue }
            
            let isEarned = await checkAchievement(achievement, for: user)
            if isEarned {
                await awardAchievement(achievement, to: user)
            }
        }
    }
    
    private func checkAchievement(_ achievement: Achievement, for user: QodeXUser) async -> Bool {
        switch achievement {
        case .firstCalculation:
            return await hasCalculatedChart(userId: user.id)
            
        case .streak7:
            return (user.streakData?.currentStreak ?? 0) >= 7
            
        case .streak30:
            return (user.streakData?.currentStreak ?? 0) >= 30
            
        case .streak100:
            return (user.streakData?.currentStreak ?? 0) >= 100
            
        case .streak365:
            return (user.streakData?.currentStreak ?? 0) >= 365
            
        case .chartMaster:
            return await hasViewedAllCharts(userId: user.id)
            
        case .communityContributor:
            return await hasMadePost(userId: user.id)
            
        case .mentorMatch:
            return await hasMentorMatch(userId: user.id)
            
        case .liveAttendee:
            return await hasAttendedLive(userId: user.id)
            
        case .deepDiver:
            return await hasLongMeditation(userId: user.id)
            
        case .earlyBird:
            return await hasEarlyCheckIn(userId: user.id)
            
        case .nightOwl:
            return await hasLateCheckIn(userId: user.id)
            
        case .shareMaster:
            return await hasSharedMultipleTimes(userId: user.id)
            
        case .premiumPioneer:
            return user.isPremium
        }
    }
    
    // MARK: - Award Achievement
    private func awardAchievement(_ achievement: Achievement, to user: QodeXUser) async {
        let data: [String: Any] = [
            "userId": user.id,
            "achievementId": achievement.rawValue,
            "earnedAt": FieldValue.serverTimestamp(),
            "xpReward": achievement.xpReward
        ]
        
        try? await db.collection("user_achievements").addDocument(data: data)
        
        // Update user's total XP
        await addXP(userId: user.id, amount: achievement.xpReward)
        
        // Send notification
        await sendAchievementNotification(to: user, achievement: achievement)
        
        // Log analytics
        QodeXAnalytics.shared.logEvent("achievement_earned", parameters: [
            "achievement": achievement.rawValue,
            "xp": achievement.xpReward
        ])
    }
    
    // MARK: - XP System
    func addXP(userId: String, amount: Int) async {
        let userRef = db.collection("users").document(userId)
        
        try? await userRef.updateData([
            "totalXP": FieldValue.increment(Int64(amount))
        ])
        
        // Check for level up
        await checkLevelUp(userId: userId)
    }
    
    private func checkLevelUp(userId: String) async {
        let doc = try? await db.collection("users").document(userId).getDocument()
        guard let data = doc?.data(),
              let totalXP = data["totalXP"] as? Int else { return }
        
        let currentLevel = data["level"] as? Int ?? 1
        let newLevel = calculateLevel(from: totalXP)
        
        if newLevel > currentLevel {
            try? await db.collection("users").document(userId).updateData([
                "level": newLevel
            ])
            
            // Send level up notification
        }
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        // Level = sqrt(xp / 100)
        return Int(sqrt(Double(xp) / 100)) + 1
    }
    
    // MARK: - Leaderboards
    func getLeaderboard(type: LeaderboardType, limit: Int = 10) async -> [LeaderboardEntry] {
        let orderField: String
        switch type {
        case .streak: orderField = "streakData.currentStreak"
        case .xp: orderField = "totalXP"
        case .contributions: orderField = "contributionCount"
        }
        
        let snapshot = try? await db.collection("users")
            .order(by: orderField, descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot?.documents.enumerated().compactMap { index, doc in
            guard let user = QodeXUser(from: doc) else { return nil }
            return LeaderboardEntry(
                rank: index + 1,
                user: user,
                score: doc.data()[orderField] as? Int ?? 0
            )
        } ?? []
    }
    
    enum LeaderboardType {
        case streak
        case xp
        case contributions
    }
    
    struct LeaderboardEntry {
        let rank: Int
        let user: QodeXUser
        let score: Int
    }
    
    // MARK: - Private Helpers
    private func fetchEarnedAchievements(userId: String) async -> [String] {
        let snapshot = try? await db.collection("user_achievements")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot?.documents.compactMap { $0.data()["achievementId"] as? String } ?? []
    }
    
    private func hasCalculatedChart(userId: String) async -> Bool {
        let doc = try? await db.collection("user_analytics").document(userId).getDocument()
        return (doc?.data()["calculationCount"] as? Int ?? 0) > 0
    }
    
    private func hasViewedAllCharts(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasMadePost(userId: String) async -> Bool {
        let count = try? await db.collection("community_posts")
            .whereField("authorId", isEqualTo: userId)
            .count
            .getAggregation(source: .server)
            .count
        return (count ?? 0) > 0
    }
    
    private func hasMentorMatch(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasAttendedLive(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasLongMeditation(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasEarlyCheckIn(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasLateCheckIn(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func hasSharedMultipleTimes(userId: String) async -> Bool {
        return true // Placeholder
    }
    
    private func sendAchievementNotification(to user: QodeXUser, achievement: Achievement) async {
        // Trigger push notification
    }
}
