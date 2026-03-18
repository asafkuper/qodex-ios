import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

// MARK: - Enhanced Notification Manager
class EnhancedNotificationManager: NSObject, ObservableObject {
    static let shared = EnhancedNotificationManager()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount = 0
    @Published var currentDeepLink: DeepLink?
    
    private let notificationCenter = UNUserNotificationCenter.current
    
    // MARK: - Secure Storage Keys
    private enum Keys {
        static let fcmToken = KeychainKey.fcmToken
        static let pendingDeepLink = KeychainKey.pendingDeepLink
    }
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Request permissions
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Notification permission: \(granted)")
        }
        
        notificationCenter.delegate = self
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Deep Link Handling
    func handleDeepLink(from userInfo: [AnyHashable: Any]) {
        guard let deepLinkString = userInfo["deep_link"] as? String,
              let url = URL(string: deepLinkString) else {
            return
        }
        
        let deepLink = DeepLink(url: url)
        
        DispatchQueue.main.async {
            self.currentDeepLink = deepLink
            self.processDeepLink(deepLink)
        }
    }
    
    private func processDeepLink(_ deepLink: DeepLink) {
        // Store securely in Keychain instead of UserDefaults
        _ = KeychainManager.store(deepLink.url.absoluteString, key: Keys.pendingDeepLink)
        
        // Post notification for views to observe
        NotificationCenter.default.post(
            name: .deepLinkReceived,
            object: nil,
            userInfo: ["deepLink": deepLink]
        )
    }
    
    /// Retrieve and clear any pending deep link
    func retrievePendingDeepLink() -> String? {
        guard let deepLink = KeychainManager.retrieveString(key: Keys.pendingDeepLink) else {
            return nil
        }
        // Clear after retrieval
        _ = KeychainManager.delete(key: Keys.pendingDeepLink)
        return deepLink
    }
    
    // MARK: - Local Notifications
    func scheduleDailyQodeNotification(number: Int, title: String) {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Qode: \(number)"
        content.body = "\(title). Tap to discover today's guidance."
        content.sound = .default
        content.categoryIdentifier = "DAILY_QODE"
        content.userInfo = [
            "type": "daily_qode",
            "number": number,
            "deep_link": "qodex://daily-qode/\(number)"
        ]
        
        // Schedule for 8 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_qode", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func scheduleLiveSessionReminder(session: LiveSession, minutesBefore: Int = 15) {
        let content = UNMutableNotificationContent()
        content.title = "Live Session Starting Soon!"
        content.body = "\(session.title) begins in \(minutesBefore) minutes. Tap to join."
        content.sound = .default
        content.categoryIdentifier = "LIVE_SESSION"
        content.userInfo = [
            "type": "live_session",
            "session_id": session.id,
            "deep_link": "qodex://live-session/\(session.id)"
        ]
        
        let triggerDate = session.startTime.addingTimeInterval(Double(-minutesBefore * 60))
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "live_session_\(session.id)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    func scheduleStreakReminder(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "You're on a \(streak)-day streak. Check your Daily Qode to keep it going!"
        content.sound = .default
        content.categoryIdentifier = "STREAK"
        content.userInfo = [
            "type": "streak",
            "streak": streak,
            "deep_link": "qodex://daily-qode"
        ]
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Notification Actions
    func registerNotificationCategories() {
        // Daily Qode actions
        let readAction = UNNotificationAction(
            identifier: "READ_QODE",
            title: "Read Now",
            options: .foreground
        )
        
        let shareAction = UNNotificationAction(
            identifier: "SHARE_QODE",
            title: "Share",
            options: .foreground
        )
        
        let dailyQodeCategory = UNNotificationCategory(
            identifier: "DAILY_QODE",
            actions: [readAction, shareAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Live Session actions
        let joinAction = UNNotificationAction(
            identifier: "JOIN_SESSION",
            title: "Join Now",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me Later",
            options: []
        )
        
        let liveSessionCategory = UNNotificationCategory(
            identifier: "LIVE_SESSION",
            actions: [joinAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([dailyQodeCategory, liveSessionCategory])
    }
    
    // MARK: - FCM Token Management
    
    /// Get the stored FCM token from secure Keychain storage
    func getFCMToken() -> String? {
        return KeychainManager.retrieveString(key: Keys.fcmToken)
    }
    
    /// Clear all notification-related secure data
    func clearSecureData() {
        _ = KeychainManager.delete(key: Keys.fcmToken)
        _ = KeychainManager.delete(key: Keys.pendingDeepLink)
    }
}

// MARK: - Deep Link Model
struct DeepLink: Identifiable {
    let id = UUID()
    let url: URL
    
    var type: DeepLinkType {
        switch url.host {
        case "daily-qode":
            return .dailyQode
        case "live-session":
            return .liveSession
        case "community":
            return .community
        case "profile":
            return .profile
        case "subscription":
            return .subscription
        default:
            return .unknown
        }
    }
    
    var parameter: String? {
        url.pathComponents.dropFirst().first
    }
    
    enum DeepLinkType {
        case dailyQode
        case liveSession
        case community
        case profile
        case subscription
        case unknown
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}

extension EnhancedNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle action buttons
        switch response.actionIdentifier {
        case "READ_QODE":
            handleDeepLink(from: userInfo)
        case "JOIN_SESSION":
            handleDeepLink(from: userInfo)
        case "SHARE_QODE":
            // Trigger share sheet
            NotificationCenter.default.post(name: .init("shareQode"), object: nil)
        default:
            // Default tap action
            if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                handleDeepLink(from: userInfo)
            }
        }
        
        completionHandler()
    }
}

extension EnhancedNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        // Store token securely in Keychain instead of UserDefaults
        if let token = fcmToken {
            _ = KeychainManager.store(token, key: Keys.fcmToken)
        }
    }
}

// MARK: - App Notification Model
struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    let isRead: Bool
    let deepLink: String?
    
    enum NotificationType {
        case dailyQode
        case liveSession
        case community
        case streak
        case system
    }
}

// MARK: - Deep Link Handler View
struct DeepLinkHandler: ViewModifier {
    @StateObject private var notificationManager = EnhancedNotificationManager.shared
    @State private var activeDeepLink: DeepLink?
    @State private var navigateToDailyQode = false
    @State private var navigateToLiveSession = false
    @State private var navigateToCommunity = false
    @State private var navigateToSubscription = false
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .deepLinkReceived)) { notification in
                if let deepLink = notification.userInfo?["deepLink"] as? DeepLink {
                    handleDeepLink(deepLink)
                }
            }
            .onOpenURL { url in
                let deepLink = DeepLink(url: url)
                handleDeepLink(deepLink)
            }
            // Navigation destinations
            .background(
                NavigationLink(
                    destination: DailyQodeView_Enhanced(),
                    isActive: $navigateToDailyQode
                ) { EmptyView() }
            )
            .background(
                NavigationLink(
                    destination: LiveSessionHubView(),
                    isActive: $navigateToLiveSession
                ) { EmptyView() }
            )
            .background(
                NavigationLink(
                    destination: CommunityFeedView_Enhanced(),
                    isActive: $navigateToCommunity
                ) { EmptyView() }
            )
            .background(
                NavigationLink(
                    destination: EnhancedPaywallView(),
                    isActive: $navigateToSubscription
                ) { EmptyView() }
            )
    }
    
    private func handleDeepLink(_ deepLink: DeepLink) {
        switch deepLink.type {
        case .dailyQode:
            navigateToDailyQode = true
        case .liveSession:
            navigateToLiveSession = true
        case .community:
            navigateToCommunity = true
        case .subscription:
            navigateToSubscription = true
        default:
            break
        }
    }
}

// MARK: - Notification Center View
struct NotificationCenterView: View {
    @StateObject private var manager = EnhancedNotificationManager.shared
    @State private var selectedFilter: NotificationFilter = .all
    
    enum NotificationFilter {
        case all, unread, dailyQode, liveSessions
    }
    
    var filteredNotifications: [AppNotification] {
        switch selectedFilter {
        case .all:
            return manager.notifications
        case .unread:
            return manager.notifications.filter { !$0.isRead }
        case .dailyQode:
            return manager.notifications.filter { $0.type == .dailyQode }
        case .liveSessions:
            return manager.notifications.filter { $0.type == .liveSession }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Filter tabs
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "All", count: manager.notifications.count, isSelected: selectedFilter == .all) {
                                selectedFilter = .all
                            }
                            FilterChip(title: "Unread", count: manager.unreadCount, isSelected: selectedFilter == .unread) {
                                selectedFilter = .unread
                            }
                            FilterChip(title: "Daily Qodes", count: nil, isSelected: selectedFilter == .dailyQode) {
                                selectedFilter = .dailyQode
                            }
                            FilterChip(title: "Live Sessions", count: nil, isSelected: selectedFilter == .liveSessions) {
                                selectedFilter = .liveSessions
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Notifications
                Section {
                    ForEach(filteredNotifications) { notification in
                        NotificationRow(notification: notification)
                            .swipeActions {
                                Button(role: .destructive) {
                                    // Delete
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark All Read") {
                        // Mark all as read
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.gold)
                        )
                }
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.gold : Color.white.opacity(0.1))
            )
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var icon: String {
        switch notification.type {
        case .dailyQode: return "sparkles"
        case .liveSession: return "video.fill"
        case .community: return "bubble.left.fill"
        case .streak: return "flame.fill"
        case .system: return "bell.fill"
        }
    }
    
    var color: Color {
        switch notification.type {
        case .dailyQode: return .gold
        case .liveSession: return .purple
        case .community: return .blue
        case .streak: return .orange
        case .system: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.gold)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondaryText.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}
