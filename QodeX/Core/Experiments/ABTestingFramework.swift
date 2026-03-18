//
//  ABTestingFramework.swift
//  Dynamic experimentation engine
//

import Foundation
import FirebaseFirestore
import FirebaseRemoteConfig

class ABTestingFramework {
    static let shared = ABTestingFramework()
    private let db = Firestore.firestore()
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private var experiments: [String: ABExperiment] = [:]
    private var userAssignments: [String: String] = [:]
    
    // MARK: - Active Experiments
    enum Experiment: String, CaseIterable {
        case onboardingFlow = "onboarding_flow_v2"
        case paywallDesign = "paywall_design_test"
        case pricingDisplay = "pricing_display_test"
        case notificationTiming = "notification_timing_test"
        case homeScreenLayout = "home_layout_v3"
        
        var variants: [String] {
            switch self {
            case .onboardingFlow:
                return ["control", "progressive", "gamified"]
            case .paywallDesign:
                return ["control", "curiosity_gap", "social_proof"]
            case .pricingDisplay:
                return ["control", "anchored", "simplified"]
            case .notificationTiming:
                return ["control", "ai_optimized", "user_choice"]
            case .homeScreenLayout:
                return ["control", "card_based", "list_based"]
            }
        }
    }
    
    // MARK: - Initialize
    func initialize() async {
        // Fetch remote config
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings
        
        do {
            try await remoteConfig.fetchAndActivate()
            loadExperiments()
        } catch {
            print("❌ Failed to fetch remote config: \(error)")
        }
    }
    
    // MARK: - Get Variant
    func getVariant(for experiment: Experiment) -> String {
        let experimentId = experiment.rawValue
        
        // Check if user already assigned
        if let assigned = userAssignments[experimentId] {
            return assigned
        }
        
        // Check Remote Config
        let remoteVariant = remoteConfig.configValue(forKey: experimentId).stringValue
        if !remoteVariant.isEmpty, experiment.variants.contains(remoteVariant) {
            userAssignments[experimentId] = remoteVariant
            return remoteVariant
        }
        
        // Assign based on user ID hash for consistency
        let userId = AuthManager.shared.currentUser?.id ?? UUID().uuidString
        let hash = abs(userId.hashValue)
        let variantIndex = hash % experiment.variants.count
        let variant = experiment.variants[variantIndex]
        
        userAssignments[experimentId] = variant
        
        // Log assignment
        QodeXAnalytics.shared.logExperimentViewed(
            experimentId: experimentId,
            variant: variant
        )
        
        // Store in Firestore
        storeAssignment(experimentId: experimentId, variant: variant)
        
        return variant
    }
    
    // MARK: - Check Feature Flags
    func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        return remoteConfig.configValue(forKey: feature.rawValue).boolValue
    }
    
    enum FeatureFlag: String {
        case newOnboarding = "feature_new_onboarding"
        case communityBeta = "feature_community_beta"
        case aiChat = "feature_ai_chat"
        case mentorship = "feature_mentorship"
        case widgets = "feature_ios17_widgets"
    }
    
    // MARK: - Track Conversions
    func trackConversion(for experiment: Experiment) {
        let variant = getVariant(for: experiment)
        QodeXAnalytics.shared.logExperimentConversion(
            experimentId: experiment.rawValue,
            variant: variant
        )
    }
    
    // MARK: - Get Experiment Config
    func getConfig(for experiment: Experiment) -> ExperimentConfig {
        let variant = getVariant(for: experiment)
        
        switch experiment {
        case .onboardingFlow:
            return OnboardingConfig(variant: variant)
        case .paywallDesign:
            return PaywallConfig(variant: variant)
        case .pricingDisplay:
            return PricingConfig(variant: variant)
        default:
            return ExperimentConfig(variant: variant)
        }
    }
    
    // MARK: - Private Helpers
    private func loadExperiments() {
        // Load from Remote Config or Firestore
    }
    
    private func storeAssignment(experimentId: String, variant: String) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        let data: [String: Any] = [
            "experimentId": experimentId,
            "variant": variant,
            "assignedAt": FieldValue.serverTimestamp(),
            "userId": userId
        ]
        
        db.collection("experiments").document("assignments").collection(userId).document(experimentId).setData(data)
    }
}

// MARK: - Experiment Configs
class ExperimentConfig {
    let variant: String
    
    init(variant: String) {
        self.variant = variant
    }
}

class OnboardingConfig: ExperimentConfig {
    var showProgressBar: Bool {
        return variant == "progressive" || variant == "gamified"
    }
    
    var showGamification: Bool {
        return variant == "gamified"
    }
    
    var numberOfSteps: Int {
        switch variant {
        case "progressive", "gamified": return 4
        default: return 3
        }
    }
}

class PaywallConfig: ExperimentConfig {
    var designType: PaywallDesignType {
        switch variant {
        case "curiosity_gap": return .curiosityGap
        case "social_proof": return .socialProof
        default: return .standard
        }
    }
    
    var showSocialProof: Bool {
        return variant == "social_proof" || variant == "curiosity_gap"
    }
}

enum PaywallDesignType {
    case standard
    case curiosityGap
    case socialProof
}

class PricingConfig: ExperimentConfig {
    var showAnnualSavings: Bool {
        return variant == "anchored"
    }
    
    var simplifyOptions: Bool {
        return variant == "simplified"
    }
}
