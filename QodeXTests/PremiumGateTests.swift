//
//  PremiumGateTests.swift
//  Comprehensive tests for QodeX Premium Access Control System
//  Tests subscription tiers, feature access restrictions, and subscription status validation
//
//  Test Coverage:
//  - Free tier access restrictions
//  - Seeker tier permissions
//  - Initiate tier permissions
//  - Master tier permissions
//  - Subscription status checking
//  - Feature access validation across all tiers
//  - Upgrade/downgrade scenarios
//  - Grace period and billing issue handling
//

import Foundation
import XCTest
import Combine
@testable import QodeX

// MARK: - Mock Premium Gate
/// A testable version of the premium gate system for unit testing
class MockPremiumGate: ObservableObject {
    @Published var currentTier: MembershipTier
    @Published var subscriptionStatus: SubscriptionStatus
    @Published var hasActiveSubscription: Bool
    @Published var subscriptionExpiryDate: Date?
    @Published var lastError: SubscriptionError?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(tier: MembershipTier = .free, status: SubscriptionStatus = .free) {
        self.currentTier = tier
        self.subscriptionStatus = status
        self.hasActiveSubscription = tier != .free
        self.subscriptionExpiryDate = tier != .free ? Date().addingTimeInterval(30 * 24 * 60 * 60) : nil
    }
    
    /// Updates the subscription tier and status
    func updateTier(_ tier: MembershipTier, status: SubscriptionStatus? = nil) {
        currentTier = tier
        hasActiveSubscription = tier != .free
        subscriptionExpiryDate = tier != .free ? Date().addingTimeInterval(30 * 24 * 60 * 60) : nil
        
        if let newStatus = status {
            subscriptionStatus = newStatus
        } else {
            subscriptionStatus = tier == .free ? .free : .active(tier: tier, expiryDate: subscriptionExpiryDate)
        }
    }
    
    /// Checks if the user can access a specific premium feature
    func canAccess(feature: PremiumFeature) -> Bool {
        let requiredTier = feature.requiredTier
        
        // Free tier features are always accessible
        if requiredTier == .free {
            return true
        }
        
        // Check if current tier meets the requirement
        return currentTier.rawValue >= requiredTier.rawValue
    }
    
    /// Checks if the user can access content at a specific tier level
    func canAccessTierContent(_ tier: MembershipTier) -> Bool {
        return currentTier.rawValue >= tier.rawValue
    }
    
    /// Returns the highest tier the user has access to
    var accessibleTier: MembershipTier {
        return currentTier
    }
    
    /// Checks if the subscription is in a valid state for access
    var isSubscriptionValid: Bool {
        switch subscriptionStatus {
        case .active, .free:
            return true
        case .expired(let tier, let gracePeriod):
            // During grace period, user still has access
            return gracePeriod
        default:
            return false
        }
    }
    
    /// Returns features accessible to the current tier
    var accessibleFeatures: [PremiumFeature] {
        return PremiumFeature.allCases.filter { canAccess(feature: $0) }
    }
    
    /// Returns features locked for the current tier
    var lockedFeatures: [PremiumFeature] {
        return PremiumFeature.allCases.filter { !canAccess(feature: $0) }
    }
    
    /// Simulates subscription expiration
    func simulateExpiration(gracePeriod: Bool = false) {
        subscriptionStatus = .expired(tier: currentTier, gracePeriod: gracePeriod)
        if !gracePeriod {
            hasActiveSubscription = false
        }
    }
    
    /// Simulates billing issue
    func simulateBillingIssue() {
        subscriptionStatus = .billingIssue
        lastError = .billingIssue
    }
    
    /// Simulates pending subscription (e.g., parental approval)
    func simulatePendingSubscription() {
        subscriptionStatus = .pending
    }
}

// MARK: - Premium Gate Tests
class PremiumGateTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Free Tier Tests
    
    func testFreeTier_BasicProperties() {
        let gate = MockPremiumGate(tier: .free, status: .free)
        
        XCTAssertEqual(gate.currentTier, .free)
        XCTAssertEqual(gate.subscriptionStatus, .free)
        XCTAssertFalse(gate.hasActiveSubscription)
        XCTAssertNil(gate.subscriptionExpiryDate)
        XCTAssertTrue(gate.isSubscriptionValid)
    }
    
    func testFreeTier_AccessibleFeatures() {
        let gate = MockPremiumGate(tier: .free)
        
        // Free tier should access only free features
        XCTAssertTrue(gate.canAccess(feature: .dailyQode))
        XCTAssertTrue(gate.canAccess(feature: .community))
        
        // Free tier should NOT access paid features
        XCTAssertFalse(gate.canAccess(feature: .unlimitedCalculations))
        XCTAssertFalse(gate.canAccess(feature: .birthChart))
        XCTAssertFalse(gate.canAccess(feature: .compatibility))
        XCTAssertFalse(gate.canAccess(feature: .journal))
        XCTAssertFalse(gate.canAccess(feature: .noAds))
        XCTAssertFalse(gate.canAccess(feature: .liveSessions))
        XCTAssertFalse(gate.canAccess(feature: .aiChat))
        XCTAssertFalse(gate.canAccess(feature: .exportData))
        XCTAssertFalse(gate.canAccess(feature: .mentorship))
    }
    
    func testFreeTier_LockedFeaturesCount() {
        let gate = MockPremiumGate(tier: .free)
        let lockedFeatures = gate.lockedFeatures
        let accessibleFeatures = gate.accessibleFeatures
        
        // Should have 2 accessible features (dailyQode, community)
        XCTAssertEqual(accessibleFeatures.count, 2)
        
        // Should have 8 locked features
        XCTAssertEqual(lockedFeatures.count, 8)
    }
    
    func testFreeTier_CannotAccessTierContent() {
        let gate = MockPremiumGate(tier: .free)
        
        XCTAssertFalse(gate.canAccessTierContent(.seeker))
        XCTAssertFalse(gate.canAccessTierContent(.initiate))
        XCTAssertFalse(gate.canAccessTierContent(.master))
        XCTAssertTrue(gate.canAccessTierContent(.free))
    }
    
    // MARK: - Seeker Tier Tests
    
    func testSeekerTier_BasicProperties() {
        let expiryDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let gate = MockPremiumGate(
            tier: .seeker,
            status: .active(tier: .seeker, expiryDate: expiryDate)
        )
        
        XCTAssertEqual(gate.currentTier, .seeker)
        XCTAssertTrue(gate.hasActiveSubscription)
        XCTAssertNotNil(gate.subscriptionExpiryDate)
        XCTAssertTrue(gate.isSubscriptionValid)
    }
    
    func testSeekerTier_AccessibleFeatures() {
        let gate = MockPremiumGate(tier: .seeker)
        
        // Free features should be accessible
        XCTAssertTrue(gate.canAccess(feature: .dailyQode))
        XCTAssertTrue(gate.canAccess(feature: .community))
        
        // Seeker features should be accessible
        XCTAssertTrue(gate.canAccess(feature: .unlimitedCalculations))
        XCTAssertTrue(gate.canAccess(feature: .birthChart))
        XCTAssertTrue(gate.canAccess(feature: .compatibility))
        XCTAssertTrue(gate.canAccess(feature: .journal))
        XCTAssertTrue(gate.canAccess(feature: .noAds))
        
        // Initiate features should NOT be accessible
        XCTAssertFalse(gate.canAccess(feature: .liveSessions))
        XCTAssertFalse(gate.canAccess(feature: .aiChat))
        XCTAssertFalse(gate.canAccess(feature: .exportData))
        
        // Master features should NOT be accessible
        XCTAssertFalse(gate.canAccess(feature: .mentorship))
    }
    
    func testSeekerTier_TierContentAccess() {
        let gate = MockPremiumGate(tier: .seeker)
        
        XCTAssertTrue(gate.canAccessTierContent(.free))
        XCTAssertTrue(gate.canAccessTierContent(.seeker))
        XCTAssertFalse(gate.canAccessTierContent(.initiate))
        XCTAssertFalse(gate.canAccessTierContent(.master))
    }
    
    func testSeekerTier_FeatureCount() {
        let gate = MockPremiumGate(tier: .seeker)
        
        // Should have 7 accessible features (2 free + 5 seeker)
        XCTAssertEqual(gate.accessibleFeatures.count, 7)
        
        // Should have 3 locked features (liveSessions, aiChat, exportData from initiate + mentorship from master)
        // Actually: liveSessions, aiChat, exportData (initiate), mentorship (master) = 4
        XCTAssertEqual(gate.lockedFeatures.count, 4)
    }
    
    func testSeekerTier_DisplayProperties() {
        XCTAssertEqual(MembershipTier.seeker.displayName, "Inner Circle")
        XCTAssertEqual(MembershipTier.seeker.subtitle, "Full access to teachings")
        XCTAssertEqual(MembershipTier.seeker.price, "$9.99/month")
        XCTAssertEqual(MembershipTier.seeker.annualPrice, "$59.99/year")
        XCTAssertFalse(MembershipTier.seeker.isLifetime)
        XCTAssertTrue(MembershipTier.seeker.isPopular)
    }
    
    // MARK: - Initiate Tier Tests
    
    func testInitiateTier_BasicProperties() {
        let expiryDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let gate = MockPremiumGate(
            tier: .initiate,
            status: .active(tier: .initiate, expiryDate: expiryDate)
        )
        
        XCTAssertEqual(gate.currentTier, .initiate)
        XCTAssertTrue(gate.hasActiveSubscription)
        XCTAssertTrue(gate.isSubscriptionValid)
    }
    
    func testInitiateTier_AccessibleFeatures() {
        let gate = MockPremiumGate(tier: .initiate)
        
        // Free features should be accessible
        XCTAssertTrue(gate.canAccess(feature: .dailyQode))
        XCTAssertTrue(gate.canAccess(feature: .community))
        
        // Seeker features should be accessible
        XCTAssertTrue(gate.canAccess(feature: .unlimitedCalculations))
        XCTAssertTrue(gate.canAccess(feature: .birthChart))
        XCTAssertTrue(gate.canAccess(feature: .compatibility))
        XCTAssertTrue(gate.canAccess(feature: .journal))
        XCTAssertTrue(gate.canAccess(feature: .noAds))
        
        // Initiate features should be accessible
        XCTAssertTrue(gate.canAccess(feature: .liveSessions))
        XCTAssertTrue(gate.canAccess(feature: .aiChat))
        XCTAssertTrue(gate.canAccess(feature: .exportData))
        
        // Master features should NOT be accessible
        XCTAssertFalse(gate.canAccess(feature: .mentorship))
    }
    
    func testInitiateTier_AllFeaturesExceptMentorship() {
        let gate = MockPremiumGate(tier: .initiate)
        
        // Should have 10 accessible features (all except mentorship)
        XCTAssertEqual(gate.accessibleFeatures.count, 10)
        
        // Should have 1 locked feature (mentorship)
        XCTAssertEqual(gate.lockedFeatures.count, 1)
        XCTAssertEqual(gate.lockedFeatures.first, .mentorship)
    }
    
    func testInitiateTier_TierContentAccess() {
        let gate = MockPremiumGate(tier: .initiate)
        
        XCTAssertTrue(gate.canAccessTierContent(.free))
        XCTAssertTrue(gate.canAccessTierContent(.seeker))
        XCTAssertTrue(gate.canAccessTierContent(.initiate))
        XCTAssertFalse(gate.canAccessTierContent(.master))
    }
    
    func testInitiateTier_DisplayProperties() {
        XCTAssertEqual(MembershipTier.initiate.displayName, "Qode Initiate")
        XCTAssertEqual(MembershipTier.initiate.subtitle, "Personal guidance & community")
        XCTAssertEqual(MembershipTier.initiate.price, "$19.99/month")
        XCTAssertEqual(MembershipTier.initiate.annualPrice, "$119.99/year")
        XCTAssertFalse(MembershipTier.initiate.isLifetime)
        XCTAssertFalse(MembershipTier.initiate.isPopular)
    }
    
    // MARK: - Master Tier Tests
    
    func testMasterTier_BasicProperties() {
        let gate = MockPremiumGate(
            tier: .master,
            status: .active(tier: .master, expiryDate: nil)
        )
        
        XCTAssertEqual(gate.currentTier, .master)
        XCTAssertTrue(gate.hasActiveSubscription)
        XCTAssertTrue(gate.isSubscriptionValid)
        // Master tier is lifetime, so no expiry date
    }
    
    func testMasterTier_AllFeaturesAccessible() {
        let gate = MockPremiumGate(tier: .master)
        
        // All features should be accessible at Master tier
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(gate.canAccess(feature: feature), "Master tier should access \(feature)")
        }
    }
    
    func testMasterTier_NoLockedFeatures() {
        let gate = MockPremiumGate(tier: .master)
        
        XCTAssertEqual(gate.accessibleFeatures.count, PremiumFeature.allCases.count)
        XCTAssertEqual(gate.lockedFeatures.count, 0)
    }
    
    func testMasterTier_TierContentAccess() {
        let gate = MockPremiumGate(tier: .master)
        
        XCTAssertTrue(gate.canAccessTierContent(.free))
        XCTAssertTrue(gate.canAccessTierContent(.seeker))
        XCTAssertTrue(gate.canAccessTierContent(.initiate))
        XCTAssertTrue(gate.canAccessTierContent(.master))
    }
    
    func testMasterTier_DisplayProperties() {
        XCTAssertEqual(MembershipTier.master.displayName, "Qode Master")
        XCTAssertEqual(MembershipTier.master.subtitle, "1:1 sessions with Shani")
        XCTAssertEqual(MembershipTier.master.price, "$199.99")
        XCTAssertEqual(MembershipTier.master.annualPrice, "$199.99 lifetime")
        XCTAssertTrue(MembershipTier.master.isLifetime)
        XCTAssertFalse(MembershipTier.master.isPopular)
    }
    
    // MARK: - Subscription Status Tests
    
    func testSubscriptionStatus_Unknown() {
        let gate = MockPremiumGate(tier: .free, status: .unknown)
        
        XCTAssertEqual(gate.subscriptionStatus, .unknown)
        XCTAssertFalse(gate.isSubscriptionValid) // Unknown is not valid
    }
    
    func testSubscriptionStatus_Active() {
        let expiryDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let gate = MockPremiumGate(tier: .seeker, status: .active(tier: .seeker, expiryDate: expiryDate))
        
        XCTAssertTrue(gate.isSubscriptionValid)
        XCTAssertTrue(gate.hasActiveSubscription)
    }
    
    func testSubscriptionStatus_Expired() {
        let gate = MockPremiumGate(tier: .seeker)
        gate.simulateExpiration(gracePeriod: false)
        
        XCTAssertFalse(gate.isSubscriptionValid)
        XCTAssertFalse(gate.hasActiveSubscription)
        
        if case .expired(let tier, let gracePeriod) = gate.subscriptionStatus {
            XCTAssertEqual(tier, .seeker)
            XCTAssertFalse(gracePeriod)
        } else {
            XCTFail("Expected expired status")
        }
    }
    
    func testSubscriptionStatus_ExpiredWithGracePeriod() {
        let gate = MockPremiumGate(tier: .initiate)
        gate.simulateExpiration(gracePeriod: true)
        
        // During grace period, subscription is still valid
        XCTAssertTrue(gate.isSubscriptionValid)
        XCTAssertTrue(gate.hasActiveSubscription) // Still has access during grace period
        
        if case .expired(let tier, let gracePeriod) = gate.subscriptionStatus {
            XCTAssertEqual(tier, .initiate)
            XCTAssertTrue(gracePeriod)
        } else {
            XCTFail("Expected expired status with grace period")
        }
    }
    
    func testSubscriptionStatus_Pending() {
        let gate = MockPremiumGate(tier: .seeker)
        gate.simulatePendingSubscription()
        
        XCTAssertEqual(gate.subscriptionStatus, .pending)
        XCTAssertFalse(gate.isSubscriptionValid)
    }
    
    func testSubscriptionStatus_BillingIssue() {
        let gate = MockPremiumGate(tier: .initiate)
        gate.simulateBillingIssue()
        
        XCTAssertEqual(gate.subscriptionStatus, .billingIssue)
        XCTAssertNotNil(gate.lastError)
        XCTAssertEqual(gate.lastError, .billingIssue)
        XCTAssertFalse(gate.isSubscriptionValid)
    }
    
    // MARK: - Tier Upgrade/Downgrade Tests
    
    func testTierUpgrade_FreeToSeeker() {
        let gate = MockPremiumGate(tier: .free)
        
        XCTAssertEqual(gate.accessibleFeatures.count, 2)
        
        gate.updateTier(.seeker)
        
        XCTAssertEqual(gate.currentTier, .seeker)
        XCTAssertEqual(gate.accessibleFeatures.count, 7)
        XCTAssertTrue(gate.hasActiveSubscription)
    }
    
    func testTierUpgrade_SeekerToInitiate() {
        let gate = MockPremiumGate(tier: .seeker)
        
        XCTAssertEqual(gate.lockedFeatures.count, 4) // liveSessions, aiChat, exportData, mentorship
        
        gate.updateTier(.initiate)
        
        XCTAssertEqual(gate.currentTier, .initiate)
        XCTAssertEqual(gate.lockedFeatures.count, 1) // Only mentorship locked
        XCTAssertTrue(gate.canAccess(feature: .liveSessions))
        XCTAssertTrue(gate.canAccess(feature: .aiChat))
        XCTAssertTrue(gate.canAccess(feature: .exportData))
    }
    
    func testTierUpgrade_InitiateToMaster() {
        let gate = MockPremiumGate(tier: .initiate)
        
        XCTAssertEqual(gate.lockedFeatures.count, 1) // mentorship
        
        gate.updateTier(.master)
        
        XCTAssertEqual(gate.currentTier, .master)
        XCTAssertEqual(gate.lockedFeatures.count, 0)
        XCTAssertTrue(gate.canAccess(feature: .mentorship))
    }
    
    func testTierUpgrade_FreeToMaster() {
        let gate = MockPremiumGate(tier: .free)
        
        XCTAssertEqual(gate.accessibleFeatures.count, 2)
        
        gate.updateTier(.master)
        
        XCTAssertEqual(gate.currentTier, .master)
        XCTAssertEqual(gate.accessibleFeatures.count, PremiumFeature.allCases.count)
    }
    
    func testTierDowngrade_MasterToFree() {
        let gate = MockPremiumGate(tier: .master)
        
        XCTAssertEqual(gate.accessibleFeatures.count, PremiumFeature.allCases.count)
        
        gate.updateTier(.free)
        
        XCTAssertEqual(gate.currentTier, .free)
        XCTAssertEqual(gate.accessibleFeatures.count, 2)
        XCTAssertFalse(gate.hasActiveSubscription)
    }
    
    func testTierDowngrade_WithExpiredStatus() {
        let gate = MockPremiumGate(tier: .initiate)
        gate.updateTier(.free, status: .expired(tier: .initiate, gracePeriod: false))
        
        XCTAssertEqual(gate.currentTier, .free)
        XCTAssertFalse(gate.hasActiveSubscription)
        
        if case .expired(let previousTier, _) = gate.subscriptionStatus {
            XCTAssertEqual(previousTier, .initiate)
        } else {
            XCTFail("Expected expired status with previous tier info")
        }
    }
    
    // MARK: - Feature Required Tier Tests
    
    func testFeatureRequiredTiers() {
        // Verify each feature maps to the correct required tier
        XCTAssertEqual(PremiumFeature.dailyQode.requiredTier, .free)
        XCTAssertEqual(PremiumFeature.community.requiredTier, .free)
        
        XCTAssertEqual(PremiumFeature.unlimitedCalculations.requiredTier, .seeker)
        XCTAssertEqual(PremiumFeature.birthChart.requiredTier, .seeker)
        XCTAssertEqual(PremiumFeature.compatibility.requiredTier, .seeker)
        XCTAssertEqual(PremiumFeature.journal.requiredTier, .seeker)
        XCTAssertEqual(PremiumFeature.noAds.requiredTier, .seeker)
        
        XCTAssertEqual(PremiumFeature.liveSessions.requiredTier, .initiate)
        XCTAssertEqual(PremiumFeature.aiChat.requiredTier, .initiate)
        XCTAssertEqual(PremiumFeature.exportData.requiredTier, .initiate)
        
        XCTAssertEqual(PremiumFeature.mentorship.requiredTier, .master)
    }
    
    func testFeatureDisplayNames() {
        XCTAssertEqual(PremiumFeature.dailyQode.displayName, "Daily Qode Insights")
        XCTAssertEqual(PremiumFeature.birthChart.displayName, "Complete Birth Chart")
        XCTAssertEqual(PremiumFeature.mentorship.displayName, "1-on-1 Mentorship")
        XCTAssertEqual(PremiumFeature.unlimitedCalculations.displayName, "Unlimited Calculations")
    }
    
    func testFeatureIcons() {
        XCTAssertEqual(PremiumFeature.dailyQode.icon, "sun.max.fill")
        XCTAssertEqual(PremiumFeature.birthChart.icon, "chart.pie.fill")
        XCTAssertEqual(PremiumFeature.mentorship.icon, "person.fill.checkmark")
        XCTAssertEqual(PremiumFeature.unlimitedCalculations.icon, "infinity")
    }
    
    // MARK: - Publisher Tests
    
    func testTierPublisher_EmitsOnUpdate() {
        let gate = MockPremiumGate(tier: .free)
        var receivedTiers: [MembershipTier] = []
        
        let expectation = self.expectation(description: "Tier publisher emits")
        expectation.expectedFulfillmentCount = 3
        
        gate.$currentTier
            .sink { tier in
                receivedTiers.append(tier)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        gate.updateTier(.seeker)
        gate.updateTier(.initiate)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(receivedTiers, [.free, .seeker, .initiate])
    }
    
    func testSubscriptionStatusPublisher_EmitsOnUpdate() {
        let gate = MockPremiumGate(tier: .free, status: .free)
        var receivedStatuses: [SubscriptionStatus] = []
        
        let expectation = self.expectation(description: "Status publisher emits")
        expectation.expectedFulfillmentCount = 3
        
        gate.$subscriptionStatus
            .sink { status in
                receivedStatuses.append(status)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let expiryDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        gate.updateTier(.seeker, status: .active(tier: .seeker, expiryDate: expiryDate))
        gate.simulateExpiration(gracePeriod: false)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(receivedStatuses.count, 3)
    }
    
    // MARK: - Edge Cases
    
    func testAccessDuringGracePeriod() {
        let gate = MockPremiumGate(tier: .initiate)
        gate.simulateExpiration(gracePeriod: true)
        
        // During grace period, user should still have access to their tier
        XCTAssertTrue(gate.canAccess(feature: .liveSessions))
        XCTAssertTrue(gate.canAccess(feature: .aiChat))
        XCTAssertTrue(gate.canAccess(feature: .exportData))
        XCTAssertFalse(gate.canAccess(feature: .mentorship))
    }
    
    func testAccessAfterGracePeriod() {
        let gate = MockPremiumGate(tier: .initiate)
        gate.simulateExpiration(gracePeriod: false)
        
        // After grace period, user loses access to paid features
        XCTAssertFalse(gate.canAccess(feature: .liveSessions))
        XCTAssertFalse(gate.canAccess(feature: .aiChat))
        XCTAssertFalse(gate.canAccess(feature: .exportData))
        
        // But still has access to free features
        XCTAssertTrue(gate.canAccess(feature: .dailyQode))
        XCTAssertTrue(gate.canAccess(feature: .community))
    }
    
    func testTierComparison() {
        // Test tier ordering
        XCTAssertTrue(MembershipTier.master.rawValue > MembershipTier.initiate.rawValue)
        XCTAssertTrue(MembershipTier.initiate.rawValue > MembershipTier.seeker.rawValue)
        XCTAssertTrue(MembershipTier.seeker.rawValue > MembershipTier.free.rawValue)
        
        // Test equality
        XCTAssertEqual(MembershipTier.free, MembershipTier.free)
        XCTAssertNotEqual(MembershipTier.free, MembershipTier.seeker)
    }
    
    func testAllCasesCoverage() {
        let allTiers = MembershipTier.allCases
        XCTAssertEqual(allTiers.count, 4)
        XCTAssertTrue(allTiers.contains(.free))
        XCTAssertTrue(allTiers.contains(.seeker))
        XCTAssertTrue(allTiers.contains(.initiate))
        XCTAssertTrue(allTiers.contains(.master))
    }
    
    func testTierColors() {
        XCTAssertEqual(MembershipTier.free.color, "8B8B9E")
        XCTAssertEqual(MembershipTier.seeker.color, "D4AF37")
        XCTAssertEqual(MembershipTier.initiate.color, "6B4EE6")
        XCTAssertEqual(MembershipTier.master.color, "00D4AA")
    }
    
    func testTierFeaturesNotEmpty() {
        for tier in MembershipTier.allCases {
            XCTAssertFalse(tier.features.isEmpty, "Tier \(tier) should have features")
        }
    }
    
    // MARK: - Subscription Product Tests
    
    func testSubscriptionProduct_TierMapping() {
        XCTAssertEqual(SubscriptionProduct.seekerMonthly.tier, .seeker)
        XCTAssertEqual(SubscriptionProduct.seekerAnnual.tier, .seeker)
        XCTAssertEqual(SubscriptionProduct.initiateMonthly.tier, .initiate)
        XCTAssertEqual(SubscriptionProduct.initiateAnnual.tier, .initiate)
        XCTAssertEqual(SubscriptionProduct.masterLifetime.tier, .master)
    }
    
    func testSubscriptionProduct_IsAnnual() {
        XCTAssertFalse(SubscriptionProduct.seekerMonthly.isAnnual)
        XCTAssertTrue(SubscriptionProduct.seekerAnnual.isAnnual)
        XCTAssertFalse(SubscriptionProduct.initiateMonthly.isAnnual)
        XCTAssertTrue(SubscriptionProduct.initiateAnnual.isAnnual)
        XCTAssertFalse(SubscriptionProduct.masterLifetime.isAnnual)
    }
    
    func testSubscriptionProduct_IsLifetime() {
        XCTAssertFalse(SubscriptionProduct.seekerMonthly.isLifetime)
        XCTAssertFalse(SubscriptionProduct.seekerAnnual.isLifetime)
        XCTAssertFalse(SubscriptionProduct.initiateMonthly.isLifetime)
        XCTAssertFalse(SubscriptionProduct.initiateAnnual.isLifetime)
        XCTAssertTrue(SubscriptionProduct.masterLifetime.isLifetime)
    }
    
    // MARK: - Performance Tests
    
    func testFeatureAccessPerformance() {
        let gate = MockPremiumGate(tier: .master)
        
        measure {
            for _ in 0..<1000 {
                _ = gate.canAccess(feature: .mentorship)
                _ = gate.canAccess(feature: .dailyQode)
                _ = gate.canAccess(feature: .liveSessions)
            }
        }
    }
    
    func testTierComparisonPerformance() {
        measure {
            for _ in 0..<10000 {
                _ = MembershipTier.master.rawValue > MembershipTier.seeker.rawValue
            }
        }
    }
}

// MARK: - SubscriptionStatus Equatable Tests
extension PremiumGateTests {
    
    func testSubscriptionStatusEquality() {
        let date1 = Date()
        let date2 = Date().addingTimeInterval(1000)
        
        // Same status should be equal
        XCTAssertEqual(SubscriptionStatus.unknown, SubscriptionStatus.unknown)
        XCTAssertEqual(SubscriptionStatus.free, SubscriptionStatus.free)
        XCTAssertEqual(SubscriptionStatus.pending, SubscriptionStatus.pending)
        XCTAssertEqual(SubscriptionStatus.billingIssue, SubscriptionStatus.billingIssue)
        
        // Active with same tier and date should be equal
        XCTAssertEqual(
            SubscriptionStatus.active(tier: .seeker, expiryDate: date1),
            SubscriptionStatus.active(tier: .seeker, expiryDate: date1)
        )
        
        // Active with different dates should not be equal
        XCTAssertNotEqual(
            SubscriptionStatus.active(tier: .seeker, expiryDate: date1),
            SubscriptionStatus.active(tier: .seeker, expiryDate: date2)
        )
        
        // Different statuses should not be equal
        XCTAssertNotEqual(SubscriptionStatus.free, SubscriptionStatus.unknown)
        XCTAssertNotEqual(SubscriptionStatus.active(tier: .seeker, expiryDate: nil), SubscriptionStatus.free)
    }
    
    func testSubscriptionStatusIsActive() {
        XCTAssertFalse(SubscriptionStatus.unknown.isActive)
        XCTAssertFalse(SubscriptionStatus.free.isActive)
        XCTAssertFalse(SubscriptionStatus.pending.isActive)
        XCTAssertFalse(SubscriptionStatus.billingIssue.isActive)
        XCTAssertFalse(SubscriptionStatus.expired(tier: .seeker, gracePeriod: false).isActive)
        
        XCTAssertTrue(SubscriptionStatus.active(tier: .seeker, expiryDate: nil).isActive)
        XCTAssertTrue(SubscriptionStatus.active(tier: .master, expiryDate: Date()).isActive)
    }
    
    func testSubscriptionStatusTier() {
        XCTAssertEqual(SubscriptionStatus.free.tier, .free)
        XCTAssertEqual(SubscriptionStatus.unknown.tier, .free)
        XCTAssertEqual(SubscriptionStatus.pending.tier, .free)
        XCTAssertEqual(SubscriptionStatus.active(tier: .seeker, expiryDate: nil).tier, .seeker)
        XCTAssertEqual(SubscriptionStatus.active(tier: .initiate, expiryDate: nil).tier, .initiate)
        XCTAssertEqual(SubscriptionStatus.expired(tier: .master, gracePeriod: false).tier, .master)
    }
}

// MARK: - Mock StoreTransaction for Tests
struct MockStoreTransaction: StoreTransaction {
    var productIdentifier: String = "com.qodex.test"
    var purchaseDate: Date = Date()
    var transactionIdentifier: String = "test_transaction_123"
}

// MARK: - Mock CustomerInfo for Tests
struct MockCustomerInfoTest {
    var entitlements: MockEntitlementsTest = MockEntitlementsTest()
    var managementURL: URL? = URL(string: "https://apps.apple.com/account/subscriptions")
}

struct MockEntitlementsTest {
    var all: [String: MockEntitlementInfo] = [:]
    var active: [String: MockEntitlementInfo] = [:]
}

struct MockEntitlementInfo {
    var identifier: String
    var isActive: Bool
    var willRenew: Bool
    var periodType: PeriodType
    var expirationDate: Date?
    
    enum PeriodType {
        case normal
        case trial
        case intro
    }
}
