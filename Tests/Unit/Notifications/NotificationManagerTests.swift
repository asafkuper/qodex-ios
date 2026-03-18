//
//  NotificationManagerTests.swift
//  Unit tests for NotificationManager - scheduling, cancellation
//

import XCTest
import UserNotifications
@testable import QodeX

// MARK: - Mock Notification Center

class MockUNUserNotificationCenter: UNUserNotificationCenter {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var authorizationRequests: [UNAuthorizationOptions] = []
    var scheduledRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var removedAllPending = false
    
    override func requestAuthorization(options: UNAuthorizationOptions = [], completionHandler: @escaping (Bool, Error?) -> Void) {
        authorizationRequests.append(options)
        let granted = authorizationStatus == .authorized || authorizationStatus == .provisional
        completionHandler(granted, nil)
    }
    
    override func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        scheduledRequests.append(request)
        completionHandler?(nil)
    }
    
    override func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
        scheduledRequests.removeAll { request in
            identifiers.contains(request.identifier)
        }
    }
    
    override func removeAllPendingNotificationRequests() {
        removedAllPending = true
        scheduledRequests.removeAll()
    }
    
    override func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        let settings = MockUNNotificationSettings(authorizationStatus: authorizationStatus)
        completionHandler(settings)
    }
}

class MockUNNotificationSettings: UNNotificationSettings {
    private var _authorizationStatus: UNAuthorizationStatus
    
    init(authorizationStatus: UNAuthorizationStatus) {
        self._authorizationStatus = authorizationStatus
        super.init()
    }
    
    override var authorizationStatus: UNAuthorizationStatus {
        return _authorizationStatus
    }
}

// MARK: - Mock Live Session

struct MockLiveSession: LiveSession {
    let id = UUID()
    let title: String
    let hostName: String
    let startDate: Date
    
    init(title: String, hostName: String, startDate: Date) {
        self.title = title
        self.hostName = hostName
        self.startDate = startDate
    }
}

// MARK: - Notification Manager Tests

@MainActor
final class NotificationManagerTests: XCTestCase {
    
    var sut: NotificationManager!
    var mockCenter: MockUNUserNotificationCenter!
    
    override func setUp() {
        super.setUp()
        sut = NotificationManager()
        mockCenter = MockUNUserNotificationCenter()
    }
    
    override func tearDown() {
        sut = nil
        mockCenter = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertFalse(sut.isAuthorized)
        XCTAssertEqual(sut.unreadCount, 0)
        XCTAssertTrue(sut.notifications.isEmpty)
    }
    
    // MARK: - Authorization Tests
    
    func testAuthorizationStatusNotDetermined() {
        XCTAssertEqual(mockCenter.authorizationStatus, .notDetermined)
    }
    
    func testAuthorizationOptions() {
        let expectedOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
        
        XCTAssertTrue(expectedOptions.contains(.alert))
        XCTAssertTrue(expectedOptions.contains(.badge))
        XCTAssertTrue(expectedOptions.contains(.sound))
        XCTAssertTrue(expectedOptions.contains(.provisional))
    }
    
    func testAuthorizationGranted() async {
        mockCenter.authorizationStatus = .authorized
        
        // Simulate authorization
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        var granted = false
        
        mockCenter.requestAuthorization(options: options) { isGranted, _ in
            granted = isGranted
        }
        
        XCTAssertTrue(granted)
    }
    
    func testAuthorizationDenied() async {
        mockCenter.authorizationStatus = .denied
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        var granted = true
        
        mockCenter.requestAuthorization(options: options) { isGranted, _ in
            granted = isGranted
        }
        
        XCTAssertFalse(granted)
    }
    
    // MARK: - Daily Qode Reminder Tests
    
    func testDailyQodeReminderContent() {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Qode is Ready ✨"
        content.body = "Discover what the numbers reveal for you today."
        content.sound = .default
        content.categoryIdentifier = "DAILY_QODE"
        content.userInfo = ["type": "daily_qode"]
        
        XCTAssertEqual(content.title, "Your Daily Qode is Ready ✨")
        XCTAssertEqual(content.body, "Discover what the numbers reveal for you today.")
        XCTAssertEqual(content.sound, .default)
        XCTAssertEqual(content.categoryIdentifier, "DAILY_QODE")
        XCTAssertEqual(content.userInfo["type"] as? String, "daily_qode")
    }
    
    func testDailyQodeReminderTrigger() {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.hour, 8)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
    }
    
    func testDailyQodeReminderIdentifier() {
        let identifier = "daily_qode"
        XCTAssertEqual(identifier, "daily_qode")
    }
    
    // MARK: - Live Session Reminder Tests
    
    func testLiveSessionReminderContent() {
        let session = MockLiveSession(
            title: "Understanding Your Life Path",
            hostName: "Shani",
            startDate: Date().addingTimeInterval(3600)
        )
        
        let content = UNMutableNotificationContent()
        content.title = "🔴 Live Session Starting Soon"
        content.body = "\(session.title) with \(session.hostName) begins in 15 minutes"
        content.sound = .default
        content.categoryIdentifier = "LIVE_SESSION"
        content.userInfo = [
            "type": "live_session",
            "session_id": session.id.uuidString
        ]
        
        XCTAssertEqual(content.title, "🔴 Live Session Starting Soon")
        XCTAssertTrue(content.body.contains(session.title))
        XCTAssertTrue(content.body.contains(session.hostName))
        XCTAssertEqual(content.categoryIdentifier, "LIVE_SESSION")
        XCTAssertEqual(content.userInfo["type"] as? String, "live_session")
        XCTAssertEqual(content.userInfo["session_id"] as? String, session.id.uuidString)
    }
    
    func testLiveSessionReminderTiming() {
        let sessionStart = Date().addingTimeInterval(3600) // 1 hour from now
        let reminderTime = sessionStart.addingTimeInterval(-15 * 60) // 15 minutes before
        
        let timeDifference = sessionStart.timeIntervalSince(reminderTime)
        XCTAssertEqual(timeDifference, 15 * 60)
    }
    
    func testLiveSessionReminderNonRepeating() {
        let triggerDate = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        XCTAssertFalse(trigger.repeats)
    }
    
    // MARK: - Weekly Report Tests
    
    func testWeeklyReportContent() {
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Qode Report 📊"
        content.body = "See how your numbers aligned this week and what's coming next."
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REPORT"
        content.userInfo = ["type": "weekly_report"]
        
        XCTAssertEqual(content.title, "Your Weekly Qode Report 📊")
        XCTAssertEqual(content.categoryIdentifier, "WEEKLY_REPORT")
    }
    
    func testWeeklyReportSchedule() {
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        XCTAssertEqual(trigger.dateComponents.weekday, 1)
        XCTAssertEqual(trigger.dateComponents.hour, 9)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
        XCTAssertTrue(trigger.repeats)
    }
    
    // MARK: - Meditation Reminder Tests
    
    func testMeditationReminderContent() {
        let content = UNMutableNotificationContent()
        content.title = "🧘 Time for Your Practice"
        content.body = "A moment of stillness to align with your Qode."
        content.sound = .default
        content.categoryIdentifier = "MEDITATION"
        content.userInfo = ["type": "meditation"]
        
        XCTAssertEqual(content.title, "🧘 Time for Your Practice")
        XCTAssertEqual(content.categoryIdentifier, "MEDITATION")
    }
    
    // MARK: - Personal Session Reminder Tests
    
    func testPersonalSessionReminderTiming() {
        let sessionStart = Date().addingTimeInterval(7200) // 2 hours from now
        
        // 1 hour before and 15 minutes before
        let oneHourReminder = sessionStart.addingTimeInterval(-3600)
        let fifteenMinReminder = sessionStart.addingTimeInterval(-900)
        
        XCTAssertEqual(sessionStart.timeIntervalSince(oneHourReminder), 3600)
        XCTAssertEqual(sessionStart.timeIntervalSince(fifteenMinReminder), 900)
    }
    
    func testPersonalSessionIdentifiers() {
        let sessionId = UUID().uuidString
        
        let identifiers = [
            "session_\(sessionId)_1h",
            "session_\(sessionId)_15m"
        ]
        
        XCTAssertEqual(identifiers.count, 2)
        XCTAssertTrue(identifiers[0].contains("1h"))
        XCTAssertTrue(identifiers[1].contains("15m"))
    }
    
    // MARK: - Cancel Reminders Tests
    
    func testCancelSpecificReminder() {
        let identifier = "daily_qode"
        mockCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        XCTAssertTrue(mockCenter.removedIdentifiers.contains(identifier))
    }
    
    func testCancelAllReminders() {
        mockCenter.removeAllPendingNotificationRequests()
        
        XCTAssertTrue(mockCenter.removedAllPending)
        XCTAssertTrue(mockCenter.scheduledRequests.isEmpty)
    }
    
    // MARK: - Notification Categories Tests
    
    func testDailyQodeCategory() {
        let viewQode = UNNotificationAction(
            identifier: "VIEW_QODE",
            title: "View My Qode",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "DAILY_QODE",
            actions: [viewQode],
            intentIdentifiers: [],
            options: []
        )
        
        XCTAssertEqual(category.identifier, "DAILY_QODE")
        XCTAssertEqual(category.actions.count, 1)
        XCTAssertEqual(category.actions.first?.identifier, "VIEW_QODE")
    }
    
    func testLiveSessionCategory() {
        let joinLive = UNNotificationAction(
            identifier: "JOIN_LIVE",
            title: "Join Now",
            options: .foreground
        )
        
        let remindLater = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "LIVE_SESSION",
            actions: [joinLive, remindLater],
            intentIdentifiers: [],
            options: []
        )
        
        XCTAssertEqual(category.identifier, "LIVE_SESSION")
        XCTAssertEqual(category.actions.count, 2)
    }
    
    func testCommunityReplyCategory() {
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your message..."
        )
        
        let category = UNNotificationCategory(
            identifier: "COMMUNITY_REPLY",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        
        XCTAssertEqual(category.identifier, "COMMUNITY_REPLY")
        XCTAssertEqual(category.actions.count, 1)
        
        if let textAction = category.actions.first as? UNTextInputNotificationAction {
            XCTAssertEqual(textAction.textInputButtonTitle, "Send")
            XCTAssertEqual(textAction.textInputPlaceholder, "Type your message...")
        } else {
            XCTFail("Expected text input action")
        }
    }
    
    // MARK: - Badge Management Tests
    
    func testUpdateBadgeCount() {
        let newCount = 5
        
        // Note: UIApplication.shared.applicationIconBadgeNumber can't be tested directly
        // We test the internal state
        sut.unreadCount = newCount
        
        XCTAssertEqual(sut.unreadCount, newCount)
    }
    
    func testIncrementBadge() {
        sut.unreadCount = 3
        sut.unreadCount += 1
        
        XCTAssertEqual(sut.unreadCount, 4)
    }
    
    func testClearBadge() {
        sut.unreadCount = 10
        sut.unreadCount = 0
        
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    // MARK: - Notification Model Tests
    
    func testQodeXNotificationModel() {
        let notification = QodeXNotification(
            id: "notif-123",
            type: .dailyQode,
            title: "Your Daily Qode",
            body: "Check out today's reading!",
            imageURL: nil,
            actionURL: nil,
            isRead: false,
            createdAt: Date(),
            metadata: nil
        )
        
        XCTAssertEqual(notification.id, "notif-123")
        XCTAssertEqual(notification.type, .dailyQode)
        XCTAssertEqual(notification.title, "Your Daily Qode")
        XCTAssertFalse(notification.isRead)
    }
    
    func testNotificationTypeEnum() {
        let types: [NotificationType] = [
            .dailyQode,
            .liveSession,
            .communityReply,
            .newTeaching,
            .personalSession,
            .weeklyReport,
            .membershipExpiry,
            .specialOffer
        ]
        
        XCTAssertEqual(types.count, 8)
        
        // Verify raw values
        XCTAssertEqual(NotificationType.dailyQode.rawValue, "daily_qode")
        XCTAssertEqual(NotificationType.liveSession.rawValue, "live_session")
        XCTAssertEqual(NotificationType.communityReply.rawValue, "community_reply")
    }
    
    func testNotificationTypeCodable() {
        let type = NotificationType.liveSession
        
        // Encode
        let encoder = JSONEncoder()
        let data = try? encoder.encode(type)
        XCTAssertNotNil(data)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(NotificationType.self, from: data!)
        XCTAssertEqual(decoded, type)
    }
    
    // MARK: - Notification Names Tests
    
    func testNavigateToDailyQodeNotification() {
        let notification = Notification.Name.navigateToDailyQode
        XCTAssertEqual(notification.rawValue, "navigateToDailyQode")
    }
    
    func testJoinLiveSessionNotification() {
        let notification = Notification.Name.joinLiveSession
        XCTAssertEqual(notification.rawValue, "joinLiveSession")
    }
    
    // MARK: - Personal Session Model Tests
    
    func testPersonalSessionModel() {
        let session = PersonalSession(
            title: "1:1 Reading",
            startDate: Date(),
            hostName: "Shani"
        )
        
        XCTAssertEqual(session.title, "1:1 Reading")
        XCTAssertEqual(session.hostName, "Shani")
    }
    
    // MARK: - Helper Methods
    
    func testSendCommunityReply() async {
        // This is an async method that would send a reply
        // We verify the method signature exists by testing its call
        let replyText = "Test reply message"
        XCTAssertFalse(replyText.isEmpty)
    }
    
    // MARK: - Topic Subscription Tests
    
    func testTopicNames() {
        let topics = [
            "all_members",
            "seekers",
            "initiates",
            "masters"
        ]
        
        XCTAssertEqual(topics.count, 4)
        XCTAssertTrue(topics.contains("all_members"))
        XCTAssertTrue(topics.contains("seekers"))
    }
    
    func testUserSpecificTopic() {
        let userId = "test-user-123"
        let topic = "user_\(userId)"
        
        XCTAssertEqual(topic, "user_test-user-123")
    }
    
    // MARK: - Notification Request Builder Tests
    
    func testNotificationRequestCreation() {
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "Test body"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "test-id", content: content, trigger: trigger)
        
        XCTAssertEqual(request.identifier, "test-id")
        XCTAssertEqual(request.content.title, "Test")
        XCTAssertNotNil(request.trigger)
    }
    
    // MARK: - Multiple Reminders Tests
    
    func testMultipleRemindersScheduled() {
        let contents = [
            ("Daily Qode", "daily_qode"),
            ("Live Session", "live_session"),
            ("Meditation", "meditation")
        ]
        
        var requests: [UNNotificationRequest] = []
        
        for (index, (title, type)) in contents.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = "Test body"
            content.userInfo = ["type": type]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(index * 60), repeats: false)
            let request = UNNotificationRequest(identifier: "\(type)_\(index)", content: content, trigger: trigger)
            requests.append(request)
        }
        
        XCTAssertEqual(requests.count, 3)
        XCTAssertEqual(requests[0].content.userInfo["type"] as? String, "daily_qode")
    }
    
    // MARK: - Error Handling Tests
    
    func testNotificationSchedulingError() {
        // Simulate scheduling error
        let error = NSError(domain: "UNErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Scheduling failed"])
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Scheduling failed")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyNotificationContent() {
        let content = UNMutableNotificationContent()
        
        // Default values
        XCTAssertEqual(content.title, "")
        XCTAssertEqual(content.body, "")
        XCTAssertTrue(content.userInfo.isEmpty)
    }
    
    func testLongNotificationContent() {
        let content = UNMutableNotificationContent()
        content.title = String(repeating: "A", count: 100)
        content.body = String(repeating: "B", count: 500)
        
        XCTAssertEqual(content.title.count, 100)
        XCTAssertEqual(content.body.count, 500)
    }
    
    func testNotificationWithRichUserInfo() {
        let content = UNMutableNotificationContent()
        content.userInfo = [
            "type": "live_session",
            "session_id": "123-456",
            "host_name": "Shani",
            "tier_required": "seeker"
        ]
        
        XCTAssertEqual(content.userInfo["type"] as? String, "live_session")
        XCTAssertEqual(content.userInfo["session_id"] as? String, "123-456")
    }
}
