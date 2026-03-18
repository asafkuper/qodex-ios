//
//  SubscriptionRetentionEngine.swift
//  AI-powered churn prevention and retention
//

import Foundation
import FirebaseFirestore

class SubscriptionRetentionEngine {
    static let shared = SubscriptionRetentionEngine()
    private let db = Firestore.firestore()
    
    // MARK: - Churn Prediction Model
    struct ChurnRiskAssessment {
        let userId: String
        let riskScore: Double // 0-100
        let riskLevel: RiskLevel
        let factors: [RiskFactor]
        let recommendedAction: RetentionAction
        
        enum RiskLevel {
            case low      // 0-30
            case medium   // 31-60
            case high     // 61-85
            case critical // 86-100
            
            var description: String {
                switch self {
                case .low: return "User is engaged"
                case .medium: return "Showing signs of disengagement"
                case .high: return "Likely to churn within 7 days"
                case .critical: return "Immediate intervention required"
                }
            }
        }
        
        struct RiskFactor {
            let name: String
            let impact: Double
            let description: String
        }
    }
    
    // MARK: - Assess Churn Risk
    func assessChurnRisk(for user: QodeXUser) async -> ChurnRiskAssessment {
        var factors: [ChurnRiskAssessment.RiskFactor] = []
        var totalScore: Double = 0
        
        // Factor 1: Days since last active
        let daysInactive = daysSinceLastActive(user)
        let inactivityScore = min(Double(daysInactive) * 5, 40)
        if inactivityScore > 0 {
            factors.append(.init(
                name: "Inactivity",
                impact: inactivityScore,
                description: "\(daysInactive) days since last session"
            ))
            totalScore += inactivityScore
        }
        
        // Factor 2: Feature usage decline
        let usageDecline = await calculateUsageDecline(user)
        if usageDecline > 20 {
            factors.append(.init(
                name: "Usage Decline",
                impact: usageDecline / 2,
                description: "\(Int(usageDecline))% decrease in feature usage"
            ))
            totalScore += usageDecline / 2
        }
        
        // Factor 3: Support tickets
        let supportScore = await calculateSupportScore(user)
        if supportScore > 0 {
            factors.append(.init(
                name: "Support Issues",
                impact: supportScore,
                description: "Recent support interactions"
            ))
            totalScore += supportScore
        }
        
        // Factor 4: Payment issues
        if let expiry = user.membershipExpiry, expiry < Date().addingTimeInterval(7*24*60*60) {
            factors.append(.init(
                name: "Upcoming Renewal",
                impact: 15,
                description: "Renewal in less than 7 days"
            ))
            totalScore += 15
        }
        
        // Factor 5: Community engagement
        let communityScore = await calculateCommunityScore(user)
        if communityScore < 10 {
            factors.append(.init(
                name: "Low Community Engagement",
                impact: 10,
                description: "Not engaged with community features"
            ))
            totalScore += 10
        }
        
        let riskLevel: ChurnRiskAssessment.RiskLevel
        switch totalScore {
        case 0...30: riskLevel = .low
        case 31...60: riskLevel = .medium
        case 61...85: riskLevel = .high
        default: riskLevel = .critical
        }
        
        let action = determineRetentionAction(riskLevel: riskLevel, user: user)
        
        return ChurnRiskAssessment(
            userId: user.id,
            riskScore: totalScore,
            riskLevel: riskLevel,
            factors: factors,
            recommendedAction: action
        )
    }
    
    // MARK: - Execute Retention Action
    func executeRetentionAction(_ action: RetentionAction, for user: QodeXUser) async {
        switch action {
        case .sendPushNotification(let title, let body):
            await sendRetentionPush(to: user, title: title, body: body)
            
        case .offerDiscount(let percentage, let duration):
            await createDiscountOffer(for: user, percentage: percentage, duration: duration)
            
        case .scheduleMentorCall:
            await scheduleCheckInCall(for: user)
            
        case .unlockPremiumFeature(let feature):
            await temporarilyUnlockFeature(for: user, feature: feature)
            
        case .personalEmail(let subject, let content):
            await sendPersonalEmail(to: user, subject: subject, content: content)
            
        case .activateWinbackCampaign:
            await activateWinbackCampaign(for: user)
        }
        
        // Log the intervention
        await logIntervention(userId: user.id, action: action)
    }
    
    // MARK: - Private Methods
    private func daysSinceLastActive(_ user: QodeXUser) -> Int {
        guard let lastActive = user.lastActiveAt else { return 30 }
        return Calendar.current.dateComponents([.day], from: lastActive, to: Date()).day ?? 30
    }
    
    private func calculateUsageDecline(_ user: QodeXUser) async -> Double {
        // Compare last week vs previous week
        // Return percentage decline
        return 0 // Placeholder
    }
    
    private func calculateSupportScore(_ user: QodeXUser) async -> Double {
        // Query support tickets from last 30 days
        return 0 // Placeholder
    }
    
    private func calculateCommunityScore(_ user: QodeXUser) async -> Double {
        // Calculate community engagement score
        return 50 // Placeholder
    }
    
    private func determineRetentionAction(riskLevel: ChurnRiskAssessment.RiskLevel, user: QodeXUser) -> RetentionAction {
        let lifePath = calculateLifePath(user)
        
        switch riskLevel {
        case .low:
            return .sendPushNotification(
                title: "Your daily number is ready",
                body: getPersonalizedDailyMessage(lifePath: lifePath)
            )
            
        case .medium:
            return .unlockPremiumFeature(.dailyExtended)
            
        case .high:
            return .offerDiscount(percentage: 30, duration: "month")
            
        case .critical:
            return .scheduleMentorCall
        }
    }
    
    private func getPersonalizedDailyMessage(lifePath: Int) -> String {
        let messages: [Int: String] = [
            1: "A day for leadership and new beginnings awaits.",
            2: "Partnership opportunities are highlighted today.",
            3: "Your creativity is at its peak—express yourself.",
            7: "Spiritual insights are flowing—take time to reflect.",
            8: "Financial opportunities align with your energy today."
        ]
        return messages[lifePath] ?? "Discover what today holds for you."
    }
    
    private func calculateLifePath(_ user: QodeXUser) -> Int {
        guard let birthDate = user.birthDate else { return 7 }
        return NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
    
    // MARK: - Action Execution
    private func sendRetentionPush(to user: QodeXUser, title: String, body: String) async {
        // Use Cloud Functions to send push
    }
    
    private func createDiscountOffer(for user: QodeXUser, percentage: Int, duration: String) async {
        let offerData: [String: Any] = [
            "userId": user.id,
            "percentage": percentage,
            "duration": duration,
            "expiresAt": FieldValue.serverTimestamp(),
            "status": "active"
        ]
        
        try? await db.collection("retention_offers").addDocument(data: offerData)
    }
    
    private func scheduleCheckInCall(for user: QodeXUser) async {
        // Create calendar event and notify mentor
    }
    
    private func temporarilyUnlockFeature(for user: QodeXUser, feature: PremiumFeature) async {
        // Grant temporary access
    }
    
    private func sendPersonalEmail(to user: QodeXUser, subject: String, content: String) async {
        // Trigger email via Cloud Function
    }
    
    private func activateWinbackCampaign(for user: QodeXUser) async {
        // Multi-touch campaign over 30 days
    }
    
    private func logIntervention(userId: String, action: RetentionAction) async {
        let log: [String: Any] = [
            "userId": userId,
            "action": String(describing: action),
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        try? await db.collection("retention_logs").addDocument(data: log)
    }
}

// MARK: - Retention Actions
enum RetentionAction {
    case sendPushNotification(title: String, body: String)
    case offerDiscount(percentage: Int, duration: String)
    case scheduleMentorCall
    case unlockPremiumFeature(PremiumFeature)
    case personalEmail(subject: String, content: String)
    case activateWinbackCampaign
}
