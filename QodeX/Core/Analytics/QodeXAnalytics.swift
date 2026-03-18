//
//  QodeXAnalytics.swift
//  Comprehensive analytics tracking
//

import Foundation
import FirebaseAnalytics
import FirebaseFirestore

class QodeXAnalytics {
    static let shared = QodeXAnalytics()
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - User Properties
    func setUserProperties(_ user: QodeXUser) {
        Analytics.setUserProperty(user.membershipTier.rawValue, forName: "membership_tier")
        Analytics.setUserProperty(String(user.blueprintCompletion), forName: "blueprint_completion")
        Analytics.setUserProperty(user.timezone, forName: "timezone")
        
        if let birthDate = user.birthDate {
            let lifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
            Analytics.setUserProperty(String(lifePath), forName: "life_path")
        }
    }
    
    // MARK: - Screen Tracking
    func logScreen(_ screenName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenName
        ].merging(parameters ?? [:]) { current, _ in current })
    }
    
    // MARK: - Onboarding Funnel
    enum OnboardingStep: String {
        case started = "onboarding_started"
        case nameEntered = "onboarding_name_entered"
        case birthDateEntered = "onboarding_birthdate_entered"
        case chartGenerated = "onboarding_chart_generated"
        case completed = "onboarding_completed"
        
        var stepNumber: Int {
            switch self {
            case .started: return 1
            case .nameEntered: return 2
            case .birthDateEntered: return 3
            case .chartGenerated: return 4
            case .completed: return 5
            }
        }
    }
    
    func logOnboardingStep(_ step: OnboardingStep, duration: TimeInterval? = nil) {
        var parameters: [String: Any] = [
            "step_name": step.rawValue,
            "step_number": step.stepNumber
        ]
        
        if let duration = duration {
            parameters["duration_seconds"] = duration
        }
        
        Analytics.logEvent(step.rawValue, parameters: parameters)
        
        // Also track drop-off points
        if step == .completed {
            userDefaults.set(true, forKey: "has_completed_onboarding")
        }
    }
    
    // MARK: - Feature Usage
    func logFeatureUsed(_ feature: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent("feature_used", parameters: [
            "feature_name": feature
        ].merging(parameters ?? [:]) { current, _ in current })
    }
    
    // MARK: - Conversion Events
    func logPaywallViewed(source: String, feature: PremiumFeature) {
        Analytics.logEvent("paywall_viewed", parameters: [
            "source": source,
            "feature": feature.rawValue,
            "feature_price": feature.price
        ])
    }
    
    func logPurchaseStarted(_ feature: PremiumFeature, price: Double) {
        Analytics.logEvent("purchase_started", parameters: [
            "feature": feature.rawValue,
            "value": price,
            "currency": "USD"
        ])
    }
    
    func logPurchaseCompleted(_ feature: PremiumFeature, price: Double, transactionId: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterTransactionID: transactionId,
            AnalyticsParameterValue: price,
            AnalyticsParameterCurrency: "USD",
            "feature": feature.rawValue
        ])
        
        // Also track in Firestore for real-time dashboard
        trackRevenueInFirestore(amount: price, feature: feature)
    }
    
    func logPurchaseFailed(_ feature: PremiumFeature, error: String) {
        Analytics.logEvent("purchase_failed", parameters: [
            "feature": feature.rawValue,
            "error": error
        ])
    }
    
    // MARK: - Engagement
    func logSessionStart() {
        let sessionCount = userDefaults.integer(forKey: "session_count") + 1
        userDefaults.set(sessionCount, forKey: "session_count")
        
        Analytics.logEvent("session_start", parameters: [
            "session_number": sessionCount
        ])
    }
    
    func logSessionEnd(duration: TimeInterval) {
        Analytics.logEvent("session_end", parameters: [
            "duration_seconds": duration,
            "duration_minutes": Int(duration / 60)
        ])
    }
    
    func logStreakMaintained(days: Int) {
        Analytics.logEvent("streak_maintained", parameters: [
            "streak_days": days
        ])
        
        // Milestone events
        if [7, 30, 100, 365].contains(days) {
            Analytics.logEvent("streak_milestone", parameters: [
                "milestone_days": days
            ])
        }
    }
    
    // MARK: - Custom Events
    func logNumerologyCalculated(type: String, result: Int) {
        Analytics.logEvent("numerology_calculated", parameters: [
            "calculation_type": type,
            "result": result
        ])
    }
    
    func logCommunityInteraction(action: String, postId: String? = nil) {
        Analytics.logEvent("community_interaction", parameters: [
            "action": action,
            "post_id": postId ?? "none"
        ])
    }
    
    func logLiveSessionJoined(sessionId: String, tier: String) {
        Analytics.logEvent("live_session_joined", parameters: [
            "session_id": sessionId,
            "required_tier": tier
        ])
    }
    
    // MARK: - A/B Testing
    func logExperimentViewed(experimentId: String, variant: String) {
        Analytics.logEvent("experiment_viewed", parameters: [
            "experiment_id": experimentId,
            "variant": variant
        ])
    }
    
    func logExperimentConversion(experimentId: String, variant: String) {
        Analytics.logEvent("experiment_conversion", parameters: [
            "experiment_id": experimentId,
            "variant": variant
        ])
    }
    
    // MARK: - Private Helpers
    private func trackRevenueInFirestore(amount: Double, feature: PremiumFeature) {
        let data: [String: Any] = [
            "amount": amount,
            "feature": feature.rawValue,
            "timestamp": FieldValue.serverTimestamp(),
            "date": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        ]
        
        db.collection("analytics").document("revenue").collection("transactions").addDocument(data: data)
        
        // Update daily revenue counter
        let today = Calendar.current.startOfDay(for: Date())
        let dailyRef = db.collection("analytics").document("revenue").collection("daily").document("\(today.timeIntervalSince1970)")
        
        dailyRef.updateData([
            "total": FieldValue.increment(amount),
            "transactionCount": FieldValue.increment(Int64(1)),
            "lastUpdated": FieldValue.serverTimestamp()
        ])
    }
}

// MARK: - Analytics Helper Extensions
extension QodeXAnalytics {
    func timeEvent(_ eventName: String) {
        // Start timing an event
        let key = "timer_\(eventName)"
        userDefaults.set(Date().timeIntervalSince1970, forKey: key)
    }
    
    func trackTimedEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        let key = "timer_\(eventName)"
        guard let startTime = userDefaults.object(forKey: key) as? TimeInterval else { return }
        
        let duration = Date().timeIntervalSince1970 - startTime
        var params = parameters ?? [:]
        params["duration_seconds"] = duration
        
        Analytics.logEvent(eventName, parameters: params)
        userDefaults.removeObject(forKey: key)
    }
}
