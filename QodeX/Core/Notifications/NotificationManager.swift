//
//  NotificationManager.swift
//  Push Notifications, Local Reminders & Engagement
//

import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseFirestore

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var unreadCount = 0
    @Published var notifications: [QodeXNotification] = []
    
    private let center = UNUserNotificationCenter.current()
    private let db = Firestore.firestore()
    
    // MARK: - Setup
    
    override init() {
        super.init()
        center.delegate = self
        Messaging.messaging().delegate = self
    }
    
    func requestAuthorization() async {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
            let granted = try await center.requestAuthorization(options: options)
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
                subscribeToTopics()
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }
    
    // MARK: - Topic Subscriptions
    
    func subscribeToTopics() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Subscribe to user-specific topic
        Messaging.messaging().subscribe(toTopic: "user_\(userId)")
        
        // Subscribe to tier-specific topics
        Messaging.messaging().subscribe(toTopic: "all_members")
        Messaging.messaging().subscribe(toTopic: "seekers")
        
        // Tier-specific
        if SubscriptionManager.shared.currentTier == .initiate {
            Messaging.messaging().subscribe(toTopic: "initiates")
        }
        if SubscriptionManager.shared.currentTier == .master {
            Messaging.messaging().subscribe(toTopic: "masters")
        }
    }
    
    func unsubscribeFromTopics() {
        Messaging.messaging().unsubscribe(fromTopic: "all_members")
        Messaging.messaging().unsubscribe(fromTopic: "seekers")
        Messaging.messaging().unsubscribe(fromTopic: "initiates")
        Messaging.messaging().unsubscribe(fromTopic: "masters")
    }
    
    // MARK: - Local Reminders
    
    func scheduleDailyQodeReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Qode is Ready ✨"
        content.body = "Discover what the numbers reveal for you today."
        content.sound = .default
        content.categoryIdentifier = "DAILY_QODE"
        content.userInfo = ["type": "daily_qode"]
        
        // Schedule for 8 AM local time
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_qode", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func scheduleLiveSessionReminder(session: LiveSession) {
        let content = UNMutableNotificationContent()
        content.title = "🔴 Live Session Starting Soon"
        content.body = "\(session.title) with \(session.hostName) begins in 15 minutes"
        content.sound = .default
        content.categoryIdentifier = "LIVE_SESSION"
        content.userInfo = [
            "type": "live_session",
            "session_id": session.id.uuidString
        ]
        
        // 15 minutes before
        let triggerDate = session.startDate.addingTimeInterval(-15 * 60)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "live_\(session.id)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Qode Report 📊"
        content.body = "See how your numbers aligned this week and what's coming next."
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REPORT"
        content.userInfo = ["type": "weekly_report"]
        
        // Every Sunday at 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_report", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func scheduleMeditationReminder(time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🧘 Time for Your Practice"
        content.body = "A moment of stillness to align with your Qode."
        content.sound = .default
        content.categoryIdentifier = "MEDITATION"
        content.userInfo = ["type": "meditation"]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "meditation", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func schedulePersonalSessionReminder(session: PersonalSession) {
        let content = UNMutableNotificationContent()
        content.title = "🌟 Your Session with Shani"
        content.body = "Your 1:1 Qode reading begins in 1 hour. Prepare your questions."
        content.sound = .default
        content.categoryIdentifier = "PERSONAL_SESSION"
        content.userInfo = [
            "type": "personal_session",
            "session_id": session.id.uuidString
        ]
        
        // 1 hour before and 15 minutes before
        for (offset, idSuffix) in [(3600, "1h"), (900, "15m")] {
            let triggerDate = session.startDate.addingTimeInterval(-Double(offset))
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "session_\(session.id)_\(idSuffix)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
    
    // MARK: - Cancel Reminders
    
    func cancelReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Notification Categories (Actions)
    
    func setupNotificationCategories() {
        // Daily Qode actions
        let viewQode = UNNotificationAction(
            identifier: "VIEW_QODE",
            title: "View My Qode",
            options: .foreground
        )
        
        let dailyQodeCategory = UNNotificationCategory(
            identifier: "DAILY_QODE",
            actions: [viewQode],
            intentIdentifiers: [],
            options: []
        )
        
        // Live session actions
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
        
        let liveSessionCategory = UNNotificationCategory(
            identifier: "LIVE_SESSION",
            actions: [joinLive, remindLater],
            intentIdentifiers: [],
            options: []
        )
        
        // Community reply
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your message..."
        )
        
        let communityCategory = UNNotificationCategory(
            identifier: "COMMUNITY_REPLY",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([dailyQodeCategory, liveSessionCategory, communityCategory])
    }
    
    // MARK: - Badge Management
    
    func updateBadgeCount(_ count: Int) {
        unreadCount = count
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    func incrementBadge() {
        unreadCount += 1
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
    
    func clearBadge() {
        unreadCount = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - In-App Notification Center
    
    func fetchNotifications() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await db
                .collection("users")
                .document(userId)
                .collection("notifications")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let notifications = snapshot.documents.compactMap { doc -> QodeXNotification? in
                try? doc.data(as: QodeXNotification.self)
            }
            
            await MainActor.run {
                self.notifications = notifications
                self.updateBadgeCount(notifications.filter { !$0.isRead }.count)
            }
        } catch {
            print("Error fetching notifications: \(error)")
        }
    }
    
    func markAsRead(notificationId: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db
                .collection("users")
                .document(userId)
                .collection("notifications")
                .document(notificationId)
                .updateData(["isRead": true])
            
            await fetchNotifications()
        } catch {
            print("Error marking notification as read: \(error)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle actions
        switch response.actionIdentifier {
        case "VIEW_QODE":
            // Navigate to daily qode
            NotificationCenter.default.post(name: .navigateToDailyQode, object: nil)
            
        case "JOIN_LIVE":
            if let sessionId = userInfo["session_id"] as? String {
                NotificationCenter.default.post(name: .joinLiveSession, object: sessionId)
            }
            
        case "REPLY":
            if let textResponse = response as? UNTextInputNotificationResponse {
                // Handle reply
                await sendCommunityReply(textResponse.userText)
            }
            
        default:
            break
        }
        
        // Track notification opened
        if let notificationId = userInfo["notification_id"] as? String {
            await markAsRead(notificationId: notificationId)
        }
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        // Save token to Firestore
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore()
                .collection("users")
                .document(userId)
                .setData(["fcmToken": token], merge: true)
        }
        
        print("FCM Token: \(token)")
    }
}

// MARK: - Models

struct QodeXNotification: Identifiable, Codable {
    @DocumentID var id: String?
    let type: NotificationType
    let title: String
    let body: String
    let imageURL: String?
    let actionURL: String?
    let isRead: Bool
    let createdAt: Date
    let metadata: [String: String]?
}

enum NotificationType: String, Codable {
    case dailyQode = "daily_qode"
    case liveSession = "live_session"
    case communityReply = "community_reply"
    case newTeaching = "new_teaching"
    case personalSession = "personal_session"
    case weeklyReport = "weekly_report"
    case membershipExpiry = "membership_expiry"
    case specialOffer = "special_offer"
}

struct PersonalSession: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let hostName: String
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToDailyQode = Notification.Name("navigateToDailyQode")
    static let joinLiveSession = Notification.Name("joinLiveSession")
}

// MARK: - Server-Side Push Functions (Firebase Functions)

/*
// These would be deployed as Firebase Cloud Functions:

// Send daily qode to all users
exports.sendDailyQode = functions.pubsub.schedule('0 8 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const message = {
      topic: 'all_members',
      notification: {
        title: 'Your Daily Qode is Ready ✨',
        body: 'Discover what the numbers reveal for you today.'
      },
      data: {
        type: 'daily_qode',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };
    await admin.messaging().send(message);
  });

// Notify about new live session
exports.notifyLiveSession = functions.firestore
  .document('live_sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const session = snap.data();
    const message = {
      topic: session.tierRequirement,
      notification: {
        title: '📅 New Live Session Scheduled',
        body: `${session.title} with ${session.hostName}`
      },
      data: {
        type: 'live_session',
        session_id: context.params.sessionId
      }
    };
    await admin.messaging().send(message);
  });

// Welcome new subscriber
exports.welcomeSubscriber = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    if (newData.membershipTier !== oldData.membershipTier && 
        newData.membershipTier !== 'free') {
      const message = {
        token: newData.fcmToken,
        notification: {
          title: '🎉 Welcome to the Inner Circle',
          body: 'Your journey into the Qode begins now.'
        }
      };
      await admin.messaging().send(message);
    }
  });
*/
