//
//  AnalyticsServiceProtocol.swift
//  Analytics service protocol for tracking events
//

import Foundation
import Combine

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol: AnyObject {
    // MARK: - Configuration
    func configure(userId: String?)
    func setUserId(_ userId: String?)
    func setUserProperties(_ properties: [String: Any?])
    
    // MARK: - Event Tracking
    func logEvent(_ name: String, parameters: [String: Any]?)
    func logScreenView(screenName: String, screenClass: String?)
    func logUserAction(_ action: String, category: String, value: Double?)
    
    // MARK: - User Lifecycle
    func logAppOpen()
    func logAppBackground()
    func logAppForeground()
    func logSignUp(method: String)
    func logLogin(method: String)
    func logLogout()
    
    // MARK: - E-commerce
    func logPurchase(params: PurchaseEventParams)
    func logRefund(params: RefundEventParams)
    func logAddToCart(params: CartEventParams)
    func logBeginCheckout(params: CheckoutEventParams)
    
    // MARK: - Content
    func logContentView(contentId: String, contentType: String, contentName: String?)
    func logContentShare(contentId: String, contentType: String, method: String)
    func logSearch(query: String, resultsCount: Int?)
    
    // MARK: - Errors
    func logError(_ error: Error, context: String)
    func logNonFatalException(_ exception: NSException)
    
    // MARK: - Performance
    func startTimer(name: String)
    func stopTimer(name: String, params: [String: Any]?)
    func logPerformanceMetric(name: String, value: Double, unit: String?)
}

// MARK: - Event Parameters
struct PurchaseEventParams {
    let transactionId: String?
    let value: Double
    let currency: String
    let tax: Double?
    let shipping: Double?
    let items: [AnalyticsItem]
    let coupon: String?
}

struct RefundEventParams {
    let transactionId: String?
    let value: Double
    let currency: String
}

struct CartEventParams {
    let currency: String
    let value: Double
    let items: [AnalyticsItem]
}

struct CheckoutEventParams {
    let currency: String
    let value: Double
    let items: [AnalyticsItem]
    let coupon: String?
}

struct AnalyticsItem {
    let itemId: String
    let itemName: String
    let itemCategory: String?
    let itemVariant: String?
    let quantity: Int
    let price: Double
}

// MARK: - Default Implementations
extension AnalyticsServiceProtocol {
    func logEvent(_ name: String) {
        logEvent(name, parameters: nil)
    }
    
    func logScreenView(screenName: String) {
        logScreenView(screenName: screenName, screenClass: nil)
    }
    
    func logUserAction(_ action: String, category: String) {
        logUserAction(action, category: category, value: nil)
    }
}

// MARK: - QodeX Analytics Events
enum QodeXAnalyticsEvent: String {
    // App Lifecycle
    case appLaunch = "app_launch"
    case appFirstLaunch = "app_first_launch"
    case appUpdate = "app_update"
    case appBackground = "app_background"
    case appForeground = "app_foreground"
    case appTerminate = "app_terminate"
    
    // Onboarding
    case onboardingStart = "onboarding_start"
    case onboardingStepComplete = "onboarding_step_complete"
    case onboardingComplete = "onboarding_complete"
    case onboardingSkip = "onboarding_skip"
    
    // Auth
    case loginStart = "login_start"
    case loginSuccess = "login_success"
    case loginFailure = "login_failure"
    case signupStart = "signup_start"
    case signupSuccess = "signup_success"
    case signupFailure = "signup_failure"
    case logout = "logout"
    case passwordReset = "password_reset"
    
    // Calculator
    case calculatorOpen = "calculator_open"
    case calculatorCalculate = "calculator_calculate"
    case calculatorSave = "calculator_save"
    case calculatorShare = "calculator_share"
    
    // Daily Qode
    case dailyQodeView = "daily_qode_view"
    case dailyQodeRead = "daily_qode_read"
    case dailyQodeShare = "daily_qode_share"
    case dailyQodeBookmark = "daily_qode_bookmark"
    
    // Birth Chart
    case birthChartView = "birth_chart_view"
    case birthChartDetail = "birth_chart_detail"
    
    // Compatibility
    case compatibilityCalculate = "compatibility_calculate"
    case compatibilityShare = "compatibility_share"
    
    // Community
    case communityFeedView = "community_feed_view"
    case communityPostCreate = "community_post_create"
    case communityPostLike = "community_post_like"
    case communityPostComment = "community_post_comment"
    case communityPostShare = "community_post_share"
    case communityUserFollow = "community_user_follow"
    
    // Live Sessions
    case liveSessionBrowse = "live_session_browse"
    case liveSessionRegister = "live_session_register"
    case liveSessionJoin = "live_session_join"
    case liveSessionWatchRecording = "live_session_watch_recording"
    
    // Mentorship
    case mentorshipBrowse = "mentorship_browse"
    case mentorshipRequest = "mentorship_request"
    case mentorshipSessionStart = "mentorship_session_start"
    
    // Journal
    case journalOpen = "journal_open"
    case journalEntryCreate = "journal_entry_create"
    case journalEntryEdit = "journal_entry_edit"
    case journalEntryDelete = "journal_entry_delete"
    
    // Subscription
    case paywallView = "paywall_view"
    case paywallDismiss = "paywall_dismiss"
    case purchaseStart = "purchase_start"
    case purchaseComplete = "purchase_complete"
    case purchaseFailed = "purchase_failed"
    case purchaseCancelled = "purchase_cancelled"
    case subscriptionRestore = "subscription_restore"
    case subscriptionCancel = "subscription_cancel"
    
    // Settings
    case settingsOpen = "settings_open"
    case settingsChange = "settings_change"
    case notificationsToggle = "notifications_toggle"
    
    // Support
    case supportContact = "support_contact"
    case faqView = "faq_view"
    case tutorialView = "tutorial_view"
}

// MARK: - Analytics User Properties
enum AnalyticsUserProperty: String {
    case membershipTier = "membership_tier"
    case lifePathNumber = "life_path_number"
    case timezone = "timezone"
    case signupDate = "signup_date"
    case lastActive = "last_active"
    case appVersion = "app_version"
    case platform = "platform"
    case deviceType = "device_type"
    case totalCalculations = "total_calculations"
    case journalEntriesCount = "journal_entries_count"
    case communityPostsCount = "community_posts_count"
}

// MARK: - Analytics Parameter Keys
struct AnalyticsParameter {
    static let source = "source"
    static let method = "method"
    static let errorCode = "error_code"
    static let errorMessage = "error_message"
    static let duration = "duration"
    static let contentType = "content_type"
    static let contentId = "content_id"
    static let screenName = "screen_name"
    static let feature = "feature"
    static let tier = "tier"
    static let isAnnual = "is_annual"
    static let price = "price"
    static let currency = "currency"
    static let result = "result"
    static let step = "step"
}

// MARK: - Analytics Wrapper
class AnalyticsTracker {
    private let service: AnalyticsServiceProtocol
    
    init(service: AnalyticsServiceProtocol) {
        self.service = service
    }
    
    func track(_ event: QodeXAnalyticsEvent, parameters: [String: Any]? = nil) {
        service.logEvent(event.rawValue, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, for property: AnalyticsUserProperty) {
        service.setUserProperties([property.rawValue: value])
    }
    
    func trackScreen(_ screenName: String) {
        service.logScreenView(screenName: screenName)
    }
    
    func trackError(_ error: Error, context: String) {
        service.logError(error, context: context)
    }
    
    func timeOperation<T>(name: String, operation: () async throws -> T) async rethrows -> T {
        service.startTimer(name: name)
        defer { service.stopTimer(name: name, params: nil) }
        return try await operation()
    }
}

// MARK: - Analytics Enums
enum LoginMethod: String {
    case email = "email"
    case google = "google"
    case apple = "apple"
    case facebook = "facebook"
}

enum SignupMethod: String {
    case email = "email"
    case google = "google"
    case apple = "apple"
}

enum PaywallSource: String {
    case onboarding = "onboarding"
    case dashboard = "dashboard"
    case featureGate = "feature_gate"
    case settings = "settings"
    case notification = "notification"
    case deepLink = "deep_link"
}

enum ContentType: String {
    case dailyQode = "daily_qode"
    case birthChart = "birth_chart"
    case compatibility = "compatibility"
    case communityPost = "community_post"
    case liveSession = "live_session"
    case journalEntry = "journal_entry"
}

// MARK: - Privacy-compliant Analytics
protocol PrivacyCompliantAnalytics {
    var isAnalyticsEnabled: Bool { get }
    var isCrashReportingEnabled: Bool { get }
    var isPersonalizationEnabled: Bool { get }
    
    func disableAnalytics()
    func enableAnalytics()
    func deleteUserData()
}

// MARK: - Analytics Debugging
#if DEBUG
class AnalyticsDebugger {
    static let shared = AnalyticsDebugger()
    
    var loggedEvents: [(name: String, parameters: [String: Any]?)] = []
    var isEnabled = true
    
    func logEvent(_ name: String, parameters: [String: Any]?) {
        guard isEnabled else { return }
        loggedEvents.append((name, parameters))
        print("[ANALYTICS] \(name): \(parameters ?? [:])")
    }
    
    func clearLogs() {
        loggedEvents.removeAll()
    }
    
    func exportLogs() -> String {
        loggedEvents.map { "\($0.name): \($0.parameters ?? [:])" }.joined(separator: "\n")
    }
}
#endif
