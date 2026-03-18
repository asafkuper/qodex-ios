//
//  SmartRemindersEngine.swift
//  AI-powered reminder optimization
//

import Foundation
import UserNotifications

/// Intelligent reminder system that learns user behavior
/// and optimizes notification timing for maximum engagement
@MainActor
class SmartRemindersEngine: ObservableObject {
    static let shared = SmartRemindersEngine()
    
    @Published var optimalDailyQodeTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    @Published var userEngagementScore: Double = 0.5
    
    private let userDefaults = UserDefaults.standard
    private let engagementKey = "user_engagement_patterns"
    
    private init() {}
    
    // MARK: - Learning User Behavior
    
    /// Records when user opens the app after a notification
    func recordNotificationResponse(type: NotificationType, sentAt: Date, openedAt: Date) {
        let responseTime = openedAt.timeIntervalSince(sentAt)
        
        var patterns = loadEngagementPatterns()
        
        let hour = Calendar.current.component(.hour, from: sentAt)
        var hourData = patterns.hourlyEngagement[hour] ?? HourEngagementData()
        hourData.totalSent += 1
        hourData.totalOpened += 1
        hourData.averageResponseTime = (hourData.averageResponseTime * Double(hourData.totalOpened - 1) + responseTime) / Double(hourData.totalOpened)
        patterns.hourlyEngagement[hour] = hourData
        
        saveEngagementPatterns(patterns)
        recalculateOptimalTimes()
    }
    
    /// Records app open without notification (organic engagement)
    func recordOrganicOpen() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var patterns = loadEngagementPatterns()
        var hourData = patterns.hourlyEngagement[hour] ?? HourEngagementData()
        hourData.organicOpens += 1
        patterns.hourlyEngagement[hour] = hourData
        
        saveEngagementPatterns(patterns)
    }
    
    // MARK: - Optimal Time Calculation
    
    private func recalculateOptimalTimes() {
        let patterns = loadEngagementPatterns()
        
        // Find hour with highest engagement rate
        var bestHour = 8
        var bestScore = 0.0
        
        for hour in 6...22 { // Reasonable hours only
            if let data = patterns.hourlyEngagement[hour] {
                let engagementRate = Double(data.totalOpened) / Double(max(data.totalSent, 1))
                let organicWeight = Double(data.organicOpens) * 0.1
                let score = engagementRate + organicWeight
                
                if score > bestScore {
                    bestScore = score
                    bestHour = hour
                }
            }
        }
        
        optimalDailyQodeTime = Calendar.current.date(from: DateComponents(hour: bestHour, minute: 0))!
        userEngagementScore = min(bestScore, 1.0)
        
        // Reschedule with new optimal time
        rescheduleDailyQode()
    }
    
    private func rescheduleDailyQode() {
        // Cancel existing
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_qode_smart"])
        
        // Schedule at optimal time
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Qode is Ready ✨"
        content.body = generatePersonalizedMessage()
        content.sound = .default
        content.categoryIdentifier = "DAILY_QODE"
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: optimalDailyQodeTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_qode_smart", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Personalized Messaging
    
    private func generatePersonalizedMessage() -> String {
        let patterns = loadEngagementPatterns()
        let streak = calculateStreak()
        
        if streak >= 7 {
            return "🔥 \(streak)-day streak! Your Qode awaits."
        } else if userEngagementScore > 0.7 {
            return "Ready for today's insight, seeker?"
        } else if patterns.hourlyEngagement.isEmpty {
            return "Discover what the numbers reveal for you today."
        } else {
            return "Your daily guidance is here."
        }
    }
    
    private func calculateStreak() -> Int {
        // Check consecutive days of app opens
        let patterns = loadEngagementPatterns()
        return patterns.currentStreak
    }
    
    // MARK: - Smart Session Reminders
    
    /// Calculates best time to remind about upcoming live session
    /// based on user's typical response patterns
    func optimalSessionReminderTime(for session: LiveSession) -> [Date] {
        let patterns = loadEngagementPatterns()
        var reminderTimes: [Date] = []
        
        // Always remind 15 min before
        reminderTimes.append(session.startDate.addingTimeInterval(-15 * 60))
        
        // If user typically needs more prep time, add earlier reminder
        let avgResponseTime = patterns.averageResponseTime
        if avgResponseTime > 300 { // If usually takes >5 min to open
            reminderTimes.append(session.startDate.addingTimeInterval(-60 * 60)) // 1 hour before
        }
        
        // Sort by time
        return reminderTimes.sorted()
    }
    
    // MARK: - Re-engagement Campaigns
    
    /// Triggers win-back notifications for inactive users
    func checkReengagementNeeded() {
        let patterns = loadEngagementPatterns()
        let daysSinceLastOpen = daysSince(patterns.lastOpenDate)
        
        if daysSinceLastOpen == 3 {
            scheduleReengagementNotification(type: .gentle)
        } else if daysSinceLastOpen == 7 {
            scheduleReengagementNotification(type: .moderate)
        } else if daysSinceLastOpen == 14 {
            scheduleReengagementNotification(type: .strong)
        }
    }
    
    private func scheduleReengagementNotification(type: ReengagementType) {
        let content = UNMutableNotificationContent()
        
        switch type {
        case .gentle:
            content.title = "Missing your daily Qode? ✨"
            content.body = "The numbers have been waiting for you."
        case .moderate:
            content.title = "Your journey continues 🌟"
            content.body = "New teachings have been added since you were last here."
        case .strong:
            content.title = "We miss you in the Inner Circle 💫"
            content.body = "Shani shared something special this week. Come see!"
        }
        
        content.sound = .default
        content.categoryIdentifier = "REENGAGEMENT"
        
        // Schedule for optimal time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "reengagement_\(type)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Persistence
    
    private func loadEngagementPatterns() -> EngagementPatterns {
        guard let data = userDefaults.data(forKey: engagementKey),
              let patterns = try? JSONDecoder().decode(EngagementPatterns.self, from: data) else {
            return EngagementPatterns()
        }
        return patterns
    }
    
    private func saveEngagementPatterns(_ patterns: EngagementPatterns) {
        if let data = try? JSONEncoder().encode(patterns) {
            userDefaults.set(data, forKey: engagementKey)
        }
    }
    
    private func daysSince(_ date: Date?) -> Int {
        guard let date = date else { return 999 }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}

// MARK: - Data Models

struct EngagementPatterns: Codable {
    var hourlyEngagement: [Int: HourEngagementData] = [:]
    var lastOpenDate: Date?
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageResponseTime: TimeInterval = 0
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastOpen = lastOpenDate {
            let lastOpenDay = calendar.startOfDay(for: lastOpen)
            let daysBetween = calendar.dateComponents([.day], from: lastOpenDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastOpenDate = Date()
    }
}

struct HourEngagementData: Codable {
    var totalSent: Int = 0
    var totalOpened: Int = 0
    var organicOpens: Int = 0
    var averageResponseTime: TimeInterval = 0
    
    var engagementRate: Double {
        guard totalSent > 0 else { return 0 }
        return Double(totalOpened) / Double(totalSent)
    }
}

enum ReengagementType {
    case gentle
    case moderate
    case strong
}

// MARK: - Contextual Reminders

/// Sends reminders based on user's current context
class ContextualReminderService {
    
    /// Sends reminder when user is near a significant date
    static func checkSignificantDates(for user: QodeXUser) {
        guard let birthDate = user.birthDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextBirthday = calendar.nextDate(
            after: today,
            matching: calendar.dateComponents([.month, .day], from: birthDate),
            matchingPolicy: .nextTime
        )
        
        if let birthday = nextBirthday {
            let daysUntil = calendar.dateComponents([.day], from: today, to: birthday).day ?? 0
            
            if daysUntil == 7 {
                scheduleBirthdayReminder(user: user, daysUntil: 7)
            } else if daysUntil == 1 {
                scheduleBirthdayReminder(user: user, daysUntil: 1)
            }
        }
    }
    
    private static func scheduleBirthdayReminder(user: QodeXUser, daysUntil: Int) {
        let content = UNMutableNotificationContent()
        
        if daysUntil == 7 {
            content.title = "🎂 Your Solar Return Approaches"
            content.body = "In one week, a new cycle begins. Prepare for your personal year reading."
        } else {
            content.title = "🌟 Happy Qode Day!"
            content.body = "Today marks your personal new year. Discover what this cycle holds."
        }
        
        content.sound = .default
        content.categoryIdentifier = "BIRTHDAY_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "birthday_\(daysUntil)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Sends reminder about incomplete content
    static func remindAboutIncompleteContent(_ item: ContentItem) {
        guard item.progress > 0 && item.progress < 1 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📚 Continue Your Journey"
        content.body = "You're \(Int(item.progress * 100))% through \"\(item.title)\". Ready to continue?"
        content.sound = .default
        content.categoryIdentifier = "CONTINUE_LEARNING"
        content.userInfo = ["content_id": item.id.uuidString]
        
        // Schedule for evening when user typically engages
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "continue_\(item.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
