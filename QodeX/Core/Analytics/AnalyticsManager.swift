//
//  AnalyticsManager.swift
//  Comprehensive analytics tracking
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

@MainActor
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - User Lifecycle
    
    func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func logSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    func logLogin(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    func logUserProperties(user: QodeXUser) {
        Analytics.setUserProperty(user.membershipTier.rawValue, forName: "membership_tier")
        Analytics.setUserProperty(user.timezone, forName: "timezone")
        
        if let birthDate = user.birthDate {
            let lifePath = calculateLifePath(from: birthDate)
            Analytics.setUserProperty("\(lifePath)", forName: "life_path_number")
        }
    }
    
    // MARK: - Subscription Events
    
    func logSubscriptionStarted(tier: MembershipTier, isAnnual: Bool, price: Double) {
        Analytics.logEvent("subscription_started", parameters: [
            "tier": tier.rawValue,
            "billing_period": isAnnual ? "annual" : "monthly",
            "price": price,
            "currency": "USD"
        ])
    }
    
    func logSubscriptionCompleted(tier: MembershipTier, isAnnual: Bool, price: Double, transactionId: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterTransactionID: transactionId,
            AnalyticsParameterValue: price,
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterItemName: tier.displayName,
            "tier": tier.rawValue,
            "billing_period": isAnnual ? "annual" : "monthly"
        ])
    }
    
    func logSubscriptionCancelled(tier: MembershipTier) {
        Analytics.logEvent("subscription_cancelled", parameters: [
            "tier": tier.rawValue
        ])
    }
    
    func logSubscriptionRestored(tier: MembershipTier) {
        Analytics.logEvent("subscription_restored", parameters: [
            "tier": tier.rawValue
        ])
    }
    
    // MARK: - Content Engagement
    
    func logContentViewed(contentId: String, contentType: String, title: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: contentId,
            "content_title": title
        ])
    }
    
    func logVideoStarted(contentId: String, title: String, position: TimeInterval) {
        Analytics.logEvent("video_started", parameters: [
            "content_id": contentId,
            "content_title": title,
            "start_position": position
        ])
    }
    
    func logVideoProgress(contentId: String, progress: Double, duration: TimeInterval) {
        // Only log at 25%, 50%, 75%, 100%
        let milestones = [0.25, 0.5, 0.75, 1.0]
        for milestone in milestones {
            if abs(progress - milestone) < 0.02 {
                Analytics.logEvent("video_progress", parameters: [
                    "content_id": contentId,
                    "progress": Int(milestone * 100),
                    "duration_watched": duration * milestone
                ])
            }
        }
    }
    
    func logVideoCompleted(contentId: String, title: String, duration: TimeInterval) {
        Analytics.logEvent("video_completed", parameters: [
            "content_id": contentId,
            "content_title": title,
            "total_duration": duration
        ])
    }
    
    func logDownload(contentId: String, title: String, success: Bool) {
        Analytics.logEvent("content_downloaded", parameters: [
            "content_id": contentId,
            "content_title": title,
            "success": success
        ])
    }
    
    // MARK: - Qode Calculator
    
    func logQodeCalculated(lifePath: Int, expression: Int, soulUrge: Int) {
        Analytics.logEvent("qode_calculated", parameters: [
            "life_path": lifePath,
            "expression": expression,
            "soul_urge": soulUrge
        ])
    }
    
    func logDailyQodeViewed(number: Int) {
        Analytics.logEvent("daily_qode_viewed", parameters: [
            "number": number
        ])
    }
    
    // MARK: - Community
    
    func logTopicCreated(topicId: String, category: String) {
        Analytics.logEvent("topic_created", parameters: [
            "topic_id": topicId,
            "category": category
        ])
    }
    
    func logReplyPosted(topicId: String) {
        Analytics.logEvent("reply_posted", parameters: [
            "topic_id": topicId
        ])
    }
    
    func logLiveSessionJoined(sessionId: String, title: String) {
        Analytics.logEvent("live_session_joined", parameters: [
            "session_id": sessionId,
            "session_title": title
        ])
    }
    
    func logDirectMessageSent(recipientTier: String) {
        Analytics.logEvent("direct_message_sent", parameters: [
            "recipient_tier": recipientTier
        ])
    }
    
    // MARK: - Paywall
    
    func logPaywallViewed(source: String) {
        Analytics.logEvent("paywall_viewed", parameters: [
            "source": source
        ])
    }
    
    func logPaywallDismissed() {
        Analytics.logEvent("paywall_dismissed", parameters: nil)
    }
    
    func logPricingTapped(tier: MembershipTier, isAnnual: Bool) {
        Analytics.logEvent("pricing_tapped", parameters: [
            "tier": tier.rawValue,
            "billing_period": isAnnual ? "annual" : "monthly"
        ])
    }
    
    // MARK: - Sharing
    
    func logShare(contentType: String, contentId: String) {
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: contentId
        ])
    }
    
    func logInviteSent(code: String, method: String) {
        Analytics.logEvent("invite_sent", parameters: [
            "invite_code": code,
            "method": method
        ])
    }
    
    func logInviteAccepted(code: String) {
        Analytics.logEvent("invite_accepted", parameters: [
            "invite_code": code
        ])
    }
    
    // MARK: - Notifications
    
    func logNotificationReceived(type: String) {
        Analytics.logEvent("notification_received", parameters: [
            "notification_type": type
        ])
    }
    
    func logNotificationTapped(type: String) {
        Analytics.logEvent("notification_tapped", parameters: [
            "notification_type": type
        ])
    }
    
    // MARK: - Widget
    
    func logWidgetTapped(widgetType: String) {
        Analytics.logEvent("widget_tapped", parameters: [
            "widget_type": widgetType
        ])
    }
    
    // MARK: - Custom Events
    
    func logCustomEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    // MARK: - Crashlytics
    
    func logError(_ error: Error, context: String) {
        Crashlytics.crashlytics().record(error: error)
        Crashlytics.crashlytics().log(context)
    }
    
    func setUserIdentifier(_ userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    // MARK: - Helper
    
    private func calculateLifePath(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000
        
        var sum = day + month + year
        while sum > 9 && sum != 11 && sum != 22 && sum != 33 {
            var newSum = 0
            var n = sum
            while n > 0 {
                newSum += n % 10
                n /= 10
            }
            sum = newSum
        }
        
        return sum
    }
}

// MARK: - A/B Testing

enum Experiment: String {
    case paywallDesign = "paywall_design_v2"
    case pricingOrder = "pricing_order_test"
    case onboardingFlow = "onboarding_simplified"
    case dailyQodeTime = "daily_qode_timing"
}

extension AnalyticsManager {
    func getExperimentVariant(_ experiment: Experiment) -> String {
        // In production, fetch from Firebase Remote Config
        // For now, return control
        return "control"
    }
    
    func logExperimentExposure(_ experiment: Experiment, variant: String) {
        Analytics.logEvent("experiment_exposure", parameters: [
            "experiment_name": experiment.rawValue,
            "variant": variant
        ])
    }
}
