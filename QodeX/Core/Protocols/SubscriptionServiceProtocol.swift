//
//  SubscriptionServiceProtocol.swift
//  Subscription service protocol for in-app purchases
//

import Foundation
import Combine
import RevenueCat

// MARK: - Subscription Service Protocol
protocol SubscriptionServiceProtocol: AnyObject {
    // MARK: - Publishers
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> { get }
    var offeringsPublisher: AnyPublisher<[SubscriptionOffering], Never> { get }
    
    // MARK: - Properties
    var currentTier: MembershipTier { get }
    var hasActiveSubscription: Bool { get }
    var subscriptionExpiryDate: Date? { get }
    var isEligibleForTrial: Bool { get }
    var isEligibleForIntroOffer: Bool { get }
    
    // MARK: - Configuration
    func configure(withAPIKey: String, appUserID: String?)
    
    // MARK: - Fetching
    func fetchOfferings() async throws -> [SubscriptionOffering]
    func fetchCustomerInfo() async throws -> CustomerInfo
    
    // MARK: - Purchasing
    func purchase(_ tier: MembershipTier, isAnnual: Bool) async throws -> PurchaseResult
    func purchase(package: Package) async throws -> PurchaseResult
    func restorePurchases() async throws -> RestoreResult
    
    // MARK: - Management
    func syncPurchases() async throws
    func checkTrialOrIntroductoryPriceEligibility(for products: [String]) async -> [String: IntroEligibilityStatus]
    func presentCodeRedemptionSheet() async
    
    // MARK: - Validation
    func verifySubscription() async -> Bool
    func canAccessPremiumFeature(_ feature: PremiumFeature) -> Bool
    
    // MARK: - Management URL
    func getManagementURL() async -> URL?
}

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case unknown
    case free
    case active(tier: MembershipTier, expiryDate: Date?)
    case expired(tier: MembershipTier, gracePeriod: Bool)
    case pending
    case billingIssue
    
    var isActive: Bool {
        if case .active = self { return true }
        return false
    }
    
    var tier: MembershipTier {
        switch self {
        case .active(let tier, _):
            return tier
        case .expired(let tier, _):
            return tier
        default:
            return .free
        }
    }
}

// MARK: - Subscription Offering
struct SubscriptionOffering: Identifiable, Equatable {
    let id: String
    let tier: MembershipTier
    let title: String
    let description: String
    let monthlyPrice: Double
    let annualPrice: Double
    let monthlyPriceString: String
    let annualPriceString: String
    let hasTrial: Bool
    let trialDuration: String?
    let features: [String]
    let isRecommended: Bool
    
    var monthlyEquivalent: Double {
        annualPrice / 12
    }
    
    var annualSavings: Double {
        (monthlyPrice * 12) - annualPrice
    }
    
    var annualSavingsPercentage: Int {
        guard monthlyPrice > 0 else { return 0 }
        return Int((annualSavings / (monthlyPrice * 12)) * 100)
    }
}

// MARK: - Purchase Result
enum PurchaseResult {
    case success(transaction: StoreTransaction, customerInfo: CustomerInfo)
    case userCancelled
    case pending
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

// MARK: - Restore Result
enum RestoreResult {
    case success(customerInfo: CustomerInfo)
    case noPurchasesFound
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

// MARK: - Premium Features
enum PremiumFeature: String, CaseIterable {
    case unlimitedCalculations = "unlimited_calculations"
    case dailyQode = "daily_qode"
    case birthChart = "birth_chart"
    case compatibility = "compatibility"
    case community = "community"
    case liveSessions = "live_sessions"
    case mentorship = "mentorship"
    case journal = "journal"
    case aiChat = "ai_chat"
    case noAds = "no_ads"
    case exportData = "export_data"
    
    var displayName: String {
        switch self {
        case .unlimitedCalculations:
            return "Unlimited Calculations"
        case .dailyQode:
            return "Daily Qode Insights"
        case .birthChart:
            return "Complete Birth Chart"
        case .compatibility:
            return "Compatibility Reports"
        case .community:
            return "Community Access"
        case .liveSessions:
            return "Live Sessions"
        case .mentorship:
            return "1-on-1 Mentorship"
        case .journal:
            return "Numerology Journal"
        case .aiChat:
            return "AI Numerology Chat"
        case .noAds:
            return "Ad-Free Experience"
        case .exportData:
            return "Export Your Data"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedCalculations:
            return "infinity"
        case .dailyQode:
            return "sun.max.fill"
        case .birthChart:
            return "chart.pie.fill"
        case .compatibility:
            return "heart.fill"
        case .community:
            return "person.3.fill"
        case .liveSessions:
            return "video.fill"
        case .mentorship:
            return "person.fill.checkmark"
        case .journal:
            return "book.fill"
        case .aiChat:
            return "bubble.left.fill"
        case .noAds:
            return "nosign"
        case .exportData:
            return "square.and.arrow.up"
        }
    }
    
    var requiredTier: MembershipTier {
        switch self {
        case .unlimitedCalculations:
            return .seeker
        case .dailyQode:
            return .free
        case .birthChart:
            return .seeker
        case .compatibility:
            return .seeker
        case .community:
            return .free
        case .liveSessions:
            return .initiate
        case .mentorship:
            return .master
        case .journal:
            return .seeker
        case .aiChat:
            return .initiate
        case .noAds:
            return .seeker
        case .exportData:
            return .initiate
        }
    }
}

// MARK: - Intro Eligibility Status
enum IntroEligibilityStatus {
    case eligible
    case ineligible
    case unknown
}

// MARK: - Subscription Event
enum SubscriptionEvent {
    case purchaseStarted(tier: MembershipTier)
    case purchaseCompleted(tier: MembershipTier)
    case purchaseFailed(tier: MembershipTier, error: SubscriptionError)
    case purchaseCancelled(tier: MembershipTier)
    case restoreStarted
    case restoreCompleted
    case restoreFailed(error: SubscriptionError)
    case statusChanged(oldStatus: SubscriptionStatus, newStatus: SubscriptionStatus)
}

// MARK: - Subscription Analytics
protocol SubscriptionAnalytics {
    func logPaywallViewed(source: String, variant: String?)
    func logPaywallDismissed()
    func logPricingTapped(tier: MembershipTier, isAnnual: Bool, price: Double)
    func logPurchaseStarted(tier: MembershipTier, isAnnual: Bool)
    func logPurchaseCompleted(tier: MembershipTier, isAnnual: Bool, price: Double, transactionId: String)
    func logPurchaseFailed(tier: MembershipTier, error: SubscriptionError)
    func logRestoreStarted()
    func logRestoreCompleted(tier: MembershipTier?)
    func logRestoreFailed(error: SubscriptionError)
}

// MARK: - Paywall Configuration
struct PaywallConfiguration {
    let source: String
    let variant: String?
    let allowRestore: Bool
    let showTerms: Bool
    let highlightTier: MembershipTier?
    let defaultAnnual: Bool
    
    static let `default` = PaywallConfiguration(
        source: "unknown",
        variant: nil,
        allowRestore: true,
        showTerms: true,
        highlightTier: nil,
        defaultAnnual: true
    )
}

// MARK: - Subscription Plan
enum SubscriptionPlan: CaseIterable {
    case monthly
    case annual
    
    var displayName: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        }
    }
    
    var billingPeriod: String {
        switch self {
        case .monthly:
            return "month"
        case .annual:
            return "year"
        }
    }
}
