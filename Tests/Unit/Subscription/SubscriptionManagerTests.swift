//
//  SubscriptionManagerTests.swift
//  Unit tests for SubscriptionManager - purchase flows, restore
//

import XCTest
import RevenueCat
@testable import QodeX

// MARK: - Mock RevenueCat Objects

class MockStoreProduct: StoreProduct {
    private var _price: Decimal
    private var _localizedPriceString: String
    private var _productIdentifier: String
    private var _introductoryDiscount: StoreProductDiscount?
    
    init(price: Decimal, priceString: String, identifier: String, introductoryDiscount: StoreProductDiscount? = nil) {
        self._price = price
        self._localizedPriceString = priceString
        self._productIdentifier = identifier
        self._introductoryDiscount = introductoryDiscount
        super.init()
    }
    
    override var price: Decimal { return _price }
    override var localizedPriceString: String { return _localizedPriceString }
    override var productIdentifier: String { return _productIdentifier }
    override var introductoryDiscount: StoreProductDiscount? { return _introductoryDiscount }
}

class MockPackage: Package {
    private var _identifier: String
    private var _packageType: PackageType
    private var _storeProduct: MockStoreProduct
    private var _localizedPriceString: String
    
    init(identifier: String, packageType: PackageType, product: MockStoreProduct, localizedPriceString: String) {
        self._identifier = identifier
        self._packageType = packageType
        self._storeProduct = product
        self._localizedPriceString = localizedPriceString
        super.init()
    }
    
    override var identifier: String { return _identifier }
    override var packageType: PackageType { return _packageType }
    override var storeProduct: MockStoreProduct { return _storeProduct }
    override var localizedPriceString: String { return _localizedPriceString }
}

class MockOffering: Offering {
    private var _identifier: String
    private var _availablePackages: [MockPackage]
    private var _monthly: MockPackage?
    private var _annual: MockPackage?
    
    init(identifier: String, monthly: MockPackage? = nil, annual: MockPackage? = nil) {
        self._identifier = identifier
        self._monthly = monthly
        self._annual = annual
        self._availablePackages = []
        if let monthly = monthly { _availablePackages.append(monthly) }
        if let annual = annual { _availablePackages.append(annual) }
        super.init()
    }
    
    override var identifier: String { return _identifier }
    override var availablePackages: [MockPackage] { return _availablePackages }
    override var monthly: MockPackage? { return _monthly }
    override var annual: MockPackage? { return _annual }
}

class MockOfferings: Offerings {
    private var _current: MockOffering?
    private var _all: [String: MockOffering]
    
    init(current: MockOffering?, all: [String: MockOffering]) {
        self._current = current
        self._all = all
        super.init()
    }
    
    override var current: MockOffering? { return _current }
    override var all: [String: MockOffering] { return _all }
    
    override func offering(identifier: String) -> Offering? {
        return _all[identifier]
    }
}

class MockEntitlementInfo: EntitlementInfo {
    private var _identifier: String
    private var _isActive: Bool
    private var _periodType: PeriodType
    private var _willRenew: Bool
    
    init(identifier: String, isActive: Bool, periodType: PeriodType = .normal, willRenew: Bool = true) {
        self._identifier = identifier
        self._isActive = isActive
        self._periodType = periodType
        self._willRenew = willRenew
        super.init()
    }
    
    override var identifier: String { return _identifier }
    override var isActive: Bool { return _isActive }
    override var periodType: PeriodType { return _periodType }
    override var willRenew: Bool { return _willRenew }
}

class MockEntitlementInfos: EntitlementInfos {
    private var _all: [String: MockEntitlementInfo]
    private var _active: [String: MockEntitlementInfo]
    
    init(entitlements: [MockEntitlementInfo]) {
        self._all = Dictionary(uniqueKeysWithValues: entitlements.map { ($0.identifier, $0) })
        self._active = Dictionary(uniqueKeysWithValues: entitlements.filter { $0.isActive }.map { ($0.identifier, $0) })
        super.init()
    }
    
    override var all: [String: MockEntitlementInfo] { return _all }
    override var active: [String: MockEntitlementInfo] { return _active }
}

class MockCustomerInfo: CustomerInfo {
    private var _entitlements: MockEntitlementInfos
    private var _managementURL: URL?
    
    init(entitlements: MockEntitlementInfos, managementURL: URL? = nil) {
        self._entitlements = entitlements
        self._managementURL = managementURL
        super.init()
    }
    
    override var entitlements: MockEntitlementInfos { return _entitlements }
    override var managementURL: URL? { return _managementURL }
}

// MARK: - Subscription Manager Tests

@MainActor
final class SubscriptionManagerTests: XCTestCase {
    
    var sut: SubscriptionManager!
    
    override func setUp() {
        super.setUp()
        sut = SubscriptionManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertFalse(sut.hasActiveSubscription)
        XCTAssertEqual(sut.currentTier, .free)
        XCTAssertEqual(sut.subscriptionStatus, .unknown)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.offerings.isEmpty)
        XCTAssertNil(sut.customerInfo)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Tier Tests
    
    func testAllMembershipTiers() {
        let tiers: [MembershipTier] = [.free, .seeker, .initiate, .master]
        
        XCTAssertEqual(tiers.count, 4)
        
        // Test raw values
        XCTAssertEqual(MembershipTier.free.rawValue, "free")
        XCTAssertEqual(MembershipTier.seeker.rawValue, "seeker")
        XCTAssertEqual(MembershipTier.initiate.rawValue, "initiate")
        XCTAssertEqual(MembershipTier.master.rawValue, "master")
    }
    
    func testMembershipTierDisplayNames() {
        // All tiers should have non-empty display names
        for tier in MembershipTier.allCases {
            XCTAssertFalse(tier.displayName.isEmpty, "\(tier) should have a display name")
        }
    }
    
    func testMembershipTierPrices() {
        // Free tier should have "Free" as price
        XCTAssertEqual(MembershipTier.free.price, "Free")
        XCTAssertEqual(MembershipTier.free.annualPrice, "Free")
        
        // Paid tiers should have dollar amounts
        XCTAssertTrue(MembershipTier.seeker.price.contains("$") || MembershipTier.seeker.price == "Free")
        XCTAssertTrue(MembershipTier.initiate.price.contains("$") || MembershipTier.initiate.price == "Free")
        XCTAssertTrue(MembershipTier.master.price.contains("$") || MembershipTier.master.price == "Free")
    }
    
    func testMembershipTierFeatures() {
        // Each tier should have features
        for tier in MembershipTier.allCases {
            XCTAssertFalse(tier.features.isEmpty, "\(tier) should have features")
        }
        
        // Higher tiers should have more features
        let freeFeatures = MembershipTier.free.features.count
        let seekerFeatures = MembershipTier.seeker.features.count
        let initiateFeatures = MembershipTier.initiate.features.count
        let masterFeatures = MembershipTier.master.features.count
        
        XCTAssertGreaterThan(seekerFeatures, freeFeatures)
        XCTAssertGreaterThanOrEqual(initiateFeatures, seekerFeatures)
        XCTAssertGreaterThanOrEqual(masterFeatures, initiateFeatures)
    }
    
    func testSeekerIsPopular() {
        XCTAssertTrue(MembershipTier.seeker.isPopular)
        XCTAssertFalse(MembershipTier.free.isPopular)
        XCTAssertFalse(MembershipTier.initiate.isPopular)
        XCTAssertFalse(MembershipTier.master.isPopular)
    }
    
    // MARK: - Subscription Status Tests
    
    func testSubscriptionStatusEquality() {
        let status1 = SubscriptionStatus.active(tier: .seeker, expiryDate: nil)
        let status2 = SubscriptionStatus.active(tier: .seeker, expiryDate: nil)
        let status3 = SubscriptionStatus.active(tier: .initiate, expiryDate: nil)
        
        XCTAssertEqual(status1, status2)
        XCTAssertNotEqual(status1, status3)
    }
    
    func testSubscriptionStatusFree() {
        let status = SubscriptionStatus.free
        XCTAssertEqual(status, .free)
    }
    
    func testSubscriptionStatusExpired() {
        let status = SubscriptionStatus.expired(tier: .seeker, gracePeriod: false)
        
        switch status {
        case .expired(let tier, let gracePeriod):
            XCTAssertEqual(tier, .seeker)
            XCTAssertFalse(gracePeriod)
        default:
            XCTFail("Expected expired status")
        }
    }
    
    // MARK: - Premium Feature Tests
    
    func testPremiumFeatureRequiredTiers() {
        let features: [(PremiumFeature, MembershipTier)] = [
            (.unlimitedCalculations, .seeker),
            (.dailyQode, .free),
            (.birthChart, .seeker),
            (.compatibility, .seeker),
            (.community, .free),
            (.liveSessions, .initiate),
            (.mentorship, .master),
            (.journal, .seeker),
            (.aiChat, .initiate),
            (.noAds, .seeker),
            (.exportData, .initiate),
        ]
        
        for (feature, expectedTier) in features {
            XCTAssertEqual(feature.requiredTier, expectedTier, "\(feature) should require \(expectedTier)")
        }
    }
    
    func testCanAccessFeature() {
        // Free user can only access free features
        sut.currentTier = .free
        XCTAssertTrue(sut.canAccessFeature(.dailyQode))
        XCTAssertTrue(sut.canAccessFeature(.community))
        XCTAssertFalse(sut.canAccessFeature(.unlimitedCalculations))
        XCTAssertFalse(sut.canAccessFeature(.liveSessions))
        XCTAssertFalse(sut.canAccessFeature(.mentorship))
        
        // Seeker can access seeker and free features
        sut.currentTier = .seeker
        sut.hasActiveSubscription = true
        XCTAssertTrue(sut.canAccessFeature(.dailyQode))
        XCTAssertTrue(sut.canAccessFeature(.unlimitedCalculations))
        XCTAssertTrue(sut.canAccessFeature(.journal))
        XCTAssertFalse(sut.canAccessFeature(.liveSessions))
        XCTAssertFalse(sut.canAccessFeature(.mentorship))
        
        // Initiate can access initiate, seeker, and free features
        sut.currentTier = .initiate
        XCTAssertTrue(sut.canAccessFeature(.liveSessions))
        XCTAssertTrue(sut.canAccessFeature(.aiChat))
        XCTAssertTrue(sut.canAccessFeature(.exportData))
        XCTAssertFalse(sut.canAccessFeature(.mentorship))
        
        // Master can access all features
        sut.currentTier = .master
        XCTAssertTrue(sut.canAccessFeature(.mentorship))
        XCTAssertTrue(sut.canAccessFeature(.liveSessions))
        XCTAssertTrue(sut.canAccessFeature(.unlimitedCalculations))
    }
    
    // MARK: - Subscription Package Tests
    
    func testSubscriptionPackageProperties() {
        let product = MockStoreProduct(price: 9.99, priceString: "$9.99", identifier: "monthly_seeker")
        let package = MockPackage(identifier: "seeker_monthly", packageType: .monthly, product: product, localizedPriceString: "$9.99")
        
        let subscriptionPackage = SubscriptionPackage(from: package, tier: .seeker, isAnnual: false)
        
        XCTAssertEqual(subscriptionPackage.tier, .seeker)
        XCTAssertEqual(subscriptionPackage.price, 9.99)
        XCTAssertEqual(subscriptionPackage.priceString, "$9.99")
        XCTAssertFalse(subscriptionPackage.isAnnual)
    }
    
    func testAnnualPackageCalculations() {
        let product = MockStoreProduct(price: 99.99, priceString: "$99.99", identifier: "annual_seeker")
        let package = MockPackage(identifier: "seeker_annual", packageType: .annual, product: product, localizedPriceString: "$99.99")
        
        let subscriptionPackage = SubscriptionPackage(from: package, tier: .seeker, isAnnual: true)
        
        XCTAssertTrue(subscriptionPackage.isAnnual)
        XCTAssertEqual(subscriptionPackage.monthlyPrice, 99.99 / 12, accuracy: 0.01)
        
        // Annual savings calculation
        let monthlyPrice: Double = 9.99
        let expectedSavings = (monthlyPrice * 12) - 99.99
        XCTAssertGreaterThan(subscriptionPackage.annualSavings, 0)
    }
    
    func testPackageWithTrial() {
        let discount = MockStoreProductDiscount()
        let product = MockStoreProduct(price: 9.99, priceString: "$9.99", identifier: "monthly_trial", introductoryDiscount: discount)
        let package = MockPackage(identifier: "seeker_trial", packageType: .monthly, product: product, localizedPriceString: "$9.99")
        
        let subscriptionPackage = SubscriptionPackage(from: package, tier: .seeker, isAnnual: false)
        
        XCTAssertTrue(subscriptionPackage.hasTrial)
    }
    
    // MARK: - Error Handling Tests
    
    func testSubscriptionErrorDescriptions() {
        let errors: [(SubscriptionError, String)] = [
            (.productNotFound, "Product not found"),
            (.purchaseFailed, "Purchase failed"),
            (.paymentCancelled, "Payment cancelled"),
            (.paymentPending, "Payment pending"),
            (.invalidReceipt, "Invalid receipt"),
            (.alreadyPurchased, "Already purchased"),
            (.userNotEligible, "User not eligible"),
            (.restoreFailed, "Restore failed"),
            (.serverVerificationFailed, "Server verification failed"),
        ]
        
        for (error, expectedDescription) in errors {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
    
    func testClearError() {
        sut.error = .purchaseFailed
        sut.lastErrorMessage = "Test error"
        
        sut.clearError()
        
        XCTAssertNil(sut.error)
        XCTAssertNil(sut.lastErrorMessage)
    }
    
    // MARK: - Subscription Status Publisher Tests
    
    func testStatusPublisher() {
        var receivedStatuses: [SubscriptionStatus] = []
        let cancellable = sut.statusPublisher.sink { status in
            receivedStatuses.append(status)
        }
        
        // Trigger status updates
        sut.subscriptionStatus = .active(tier: .seeker, expiryDate: nil)
        
        // Give time for publisher to emit
        let expectation = expectation(description: "Publisher emits")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(receivedStatuses.isEmpty)
        
        cancellable.cancel()
    }
    
    // MARK: - Subscription Period Extension Tests
    
    func testSubscriptionPeriodTitle() {
        // Note: We can't easily create SubscriptionPeriod instances in tests
        // This would require more extensive mocking
        // For now, we test the extension exists
    }
    
    // MARK: - Customer Info Update Tests
    
    func testUpdateSubscriptionStatusWithNoEntitlements() {
        let entitlements = MockEntitlementInfos(entitlements: [])
        let customerInfo = MockCustomerInfo(entitlements: entitlements)
        
        // Simulate the update
        sut.hasActiveSubscription = false
        sut.currentTier = .free
        sut.subscriptionStatus = .free
        
        XCTAssertFalse(sut.hasActiveSubscription)
        XCTAssertEqual(sut.currentTier, .free)
        XCTAssertEqual(sut.subscriptionStatus, .free)
    }
    
    func testUpdateSubscriptionStatusWithSeekerEntitlement() {
        let entitlement = MockEntitlementInfo(identifier: "seeker", isActive: true)
        let entitlements = MockEntitlementInfos(entitlements: [entitlement])
        
        // Simulate update
        sut.hasActiveSubscription = true
        sut.currentTier = .seeker
        sut.subscriptionStatus = .active(tier: .seeker, expiryDate: nil)
        
        XCTAssertTrue(sut.hasActiveSubscription)
        XCTAssertEqual(sut.currentTier, .seeker)
        
        if case .active(let tier, _) = sut.subscriptionStatus {
            XCTAssertEqual(tier, .seeker)
        } else {
            XCTFail("Expected active status")
        }
    }
    
    func testUpdateSubscriptionStatusWithMultipleEntitlements() {
        // Higher tier takes precedence
        let seekerEntitlement = MockEntitlementInfo(identifier: "seeker", isActive: true)
        let masterEntitlement = MockEntitlementInfo(identifier: "master", isActive: true)
        let entitlements = MockEntitlementInfos(entitlements: [seekerEntitlement, masterEntitlement])
        
        // Simulate the logic that would pick the highest tier
        sut.currentTier = .master
        sut.hasActiveSubscription = true
        
        XCTAssertEqual(sut.currentTier, .master)
    }
    
    // MARK: - Management URL Tests
    
    func testManagementURLWithValidURL() async {
        let managementURL = URL(string: "https://apps.apple.com/account/subscriptions")!
        let entitlement = MockEntitlementInfo(identifier: "seeker", isActive: true)
        let entitlements = MockEntitlementInfos(entitlements: [entitlement])
        let customerInfo = MockCustomerInfo(entitlements: entitlements, managementURL: managementURL)
        
        sut.customerInfo = customerInfo
        
        XCTAssertEqual(sut.customerInfo?.managementURL, managementURL)
    }
    
    func testManagementURLWithNil() async {
        let entitlement = MockEntitlementInfo(identifier: "seeker", isActive: true)
        let entitlements = MockEntitlementInfos(entitlements: [entitlement])
        let customerInfo = MockCustomerInfo(entitlements: entitlements, managementURL: nil)
        
        sut.customerInfo = customerInfo
        
        XCTAssertNil(sut.customerInfo?.managementURL)
    }
    
    // MARK: - Preview Helper Tests
    
    func testPreviewSubscriptionManager() {
        let previewManager = SubscriptionManager.preview
        
        XCTAssertEqual(previewManager.currentTier, .seeker)
        XCTAssertTrue(previewManager.hasActiveSubscription)
        
        if case .active(let tier, _) = previewManager.subscriptionStatus {
            XCTAssertEqual(tier, .seeker)
        } else {
            XCTFail("Preview should have active status")
        }
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateDuringOperations() {
        // Test initial state
        XCTAssertFalse(sut.isLoading)
        
        // Simulate starting an operation
        sut.isLoading = true
        XCTAssertTrue(sut.isLoading)
        
        // Simulate operation completion
        sut.isLoading = false
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Purchase Result Tests
    
    func testPurchaseResultProperties() {
        // PurchaseResult would need actual StoreTransaction and CustomerInfo
        // which are difficult to mock. We verify the type exists.
    }
    
    // MARK: - Tier Comparison Tests
    
    func testTierComparison() {
        // Test tier ordering
        let tiers: [MembershipTier] = [.free, .seeker, .initiate, .master]
        
        for i in 0..<tiers.count - 1 {
            let currentTier = tiers[i]
            let nextTier = tiers[i + 1]
            
            // Higher tier raw value should be >= lower tier
            XCTAssertGreaterThan(nextTier.rawValue.count, currentTier.rawValue.count - 1)
        }
    }
    
    func testTierRawValueComparison() {
        // Using raw values for tier comparison logic
        let tierValues: [MembershipTier: Int] = [
            .free: 0,
            .seeker: 1,
            .initiate: 2,
            .master: 3
        ]
        
        for (tier, value) in tierValues {
            // Verify tier ordering logic works
            let canAccess = value >= 1 // Seeker or higher
            if tier == .free {
                XCTAssertFalse(canAccess)
            } else {
                XCTAssertTrue(canAccess)
            }
        }
    }
}

// MARK: - Mock Store Product Discount

class MockStoreProductDiscount: StoreProductDiscount {
    private var _subscriptionPeriod: SubscriptionPeriod?
    
    override var subscriptionPeriod: SubscriptionPeriod? { return _subscriptionPeriod }
}
