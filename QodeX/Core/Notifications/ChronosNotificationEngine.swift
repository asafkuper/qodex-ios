//
//  ChronosNotificationEngine.swift
//  Smart notification timing based on numerology
//

import Foundation
import UserNotifications
import FirebaseFirestore

class ChronosNotificationEngine {
    static let shared = ChronosNotificationEngine()
    private let db = Firestore.firestore()
    
    // MARK: - Optimal Notification Windows
    // Based on numerological research for each Life Path
    private let optimalHours: [Int: [Int]] = [
        1: [6, 12, 18],      // Leaders - morning decisive, midday action, evening reflection
        2: [7, 14, 20],      // Diplomats - gentle morning, collaborative afternoon, peaceful evening
        3: [9, 15, 21],      // Creatives - late start, creative afternoon, social evening
        4: [5, 13, 19],      // Builders - early start, practical afternoon, organized evening
        5: [10, 16, 22],     // Freedom seekers - varied schedule, adventure times
        6: [8, 14, 19],      // Nurturers - family morning, service afternoon, home evening
        7: [6, 15, 23],      // Seekers - meditation dawn, study afternoon, reflection night
        8: [7, 13, 20],      // Power - business morning, deal afternoon, success evening
        9: [9, 18, 21]       // Humanitarians - compassionate morning, giving afternoon, unity evening
    ]
    
    // MARK: - Calculate Optimal Notification Time
    func calculateOptimalTime(for user: QodeXUser, dailyNumber: Int) -> Date {
        let lifePath = calculateLifePath(from: user.birthDate)
        let optimalHoursForPath = optimalHours[lifePath] ?? [9, 15, 21]
        
        // Get current date components
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        // Determine which window based on current time
        let currentHour = Calendar.current.component(.hour, from: Date())
        var targetHour = optimalHoursForPath[0]
        
        for hour in optimalHoursForPath {
            if currentHour < hour {
                targetHour = hour
                break
            }
        }
        
        // If all windows passed, schedule for tomorrow's first window
        if currentHour >= optimalHoursForPath.last! {
            targetHour = optimalHoursForPath[0]
            components.day = (components.day ?? 0) + 1
        }
        
        components.hour = targetHour
        components.minute = Int.random(in: 0...15) // Add slight randomness to avoid server spikes
        
        return Calendar.current.date(from: components) ?? Date().addingTimeInterval(3600)
    }
    
    // MARK: - Schedule Daily Qode
    func scheduleDailyQode(for user: QodeXUser) async {
        guard user.notificationSettings.dailyQode else { return }
        
        let dailyNumber = NumerologyCalculator().calculateDailyNumber(for: Date())
        let optimalTime = calculateOptimalTime(for: user, dailyNumber: dailyNumber)
        
        let content = UNMutableNotificationContent()
        content.title = "✨ Today's Energy: \(dailyNumber)"
        content.subtitle = getVibeDescription(for: dailyNumber)
        content.body = getPersonalizedMessage(for: user, dailyNumber: dailyNumber)
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "type": "daily_qode",
            "number": dailyNumber,
            "deepLink": "qodex://daily"
        ]
        
        // Create trigger for optimal time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: optimalTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily_qode_\(user.id)_\(dailyNumber)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled daily qode for \(user.fullName) at \(optimalTime)")
        } catch {
            print("❌ Failed to schedule: \(error)")
        }
    }
    
    // MARK: - Schedule Streak Reminder
    func scheduleStreakReminder(for user: QodeXUser) async {
        guard let streak = user.streakData,
              streak.currentStreak > 0,
              user.notificationSettings.dailyQode else { return }
        
        // Check if they haven't opened app today
        let lastActive = user.lastActiveAt ?? Date.distantPast
        let isSameDay = Calendar.current.isDate(lastActive, inSameDayAs: Date())
        
        guard !isSameDay else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Alert!"
        content.body = "You're on a \(streak.currentStreak)-day streak. Don't break it—discover today's number!"
        content.sound = .default
        content.userInfo = ["type": "streak_reminder"]
        
        // Schedule for 8 PM local time
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_reminder_\(user.id)",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Helper Methods
    private func calculateLifePath(from birthDate: Date?) -> Int {
        guard let date = birthDate else { return 7 }
        return NumerologyCalculator().calculateLifePathNumber(birthDate: date)
    }
    
    private func getVibeDescription(for number: Int) -> String {
        let vibes = [
            "", "New Beginnings", "Partnership", "Expression", "Foundation",
            "Adventure", "Harmony", "Wisdom", "Abundance", "Completion"
        ]
        return vibes[number] ?? "Spiritual Growth"
    }
    
    private func getPersonalizedMessage(for user: QodeXUser, dailyNumber: Int) -> String {
        let lifePath = calculateLifePath(from: user.birthDate)
        
        // Personalize based on Life Path + Daily Number combination
        let combinations: [String: String] = [
            "1-8": "A powerful day to lead and manifest success. Take charge!",
            "2-6": "Focus on nurturing relationships. Your diplomacy shines today.",
            "3-5": "Express your freedom! Creative adventures await.",
            "7-9": "Deep spiritual insights coming. Trust your intuition.",
            "8-1": "Fresh starts in business. Your power is amplified."
        ]
        
        let key = "\(lifePath)-\(dailyNumber)"
        return combinations[key] ?? "Tap to discover what the numbers reveal for you today."
    }
}

// MARK: - Notification Content
struct QodeXNotification {
    let id: String
    let title: String
    let body: String
    let imageURL: URL?
    let deepLink: URL?
    let category: NotificationCategory
    
    enum NotificationCategory {
        case dailyQode
        case streakReminder
        case liveSession
        case newContent
        case communityReply
        case membershipExpiry
    }
}
