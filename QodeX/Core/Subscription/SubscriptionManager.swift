//
//  SubscriptionManager.swift
//  RevenueCat Integration with comprehensive error handling
//

import Foundation
import RevenueCat
import Combine

// MARK: - Subscription Manager
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Published State
    @Published var hasActiveSubscription = false
    @Published var currentTier: MembershipTier = .free
    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var isLoading = false
    @Published var offerings: [SubscriptionPackage] = []
    @Published var customerInfo: CustomerInfo?
    @Published var error: SubscriptionError?
    @Published var lastErrorMessage: String?
    
    // MARK: - Publishers
    private let statusSubject = CurrentValueSubject<SubscriptionStatus, Never>(.unknown)
    var statusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private var isConfigured = false
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupRevenueCat()
        fetchCustomerInfo()
    }
    
    // MARK: - Configuration
    private func setupRevenueCat() {
        Purchases.logLevel = .debug
        
        // Configure with your API key
        // In production, use your actual RevenueCat API key
        // Purchases.configure(withAPIKey: "your_api_key")
        
        // Set delegate for updates
        Purchases.shared.delegate = self
        isConfigured = true
    }
    
    func configure(withAPIKey apiKey: String, appUserID: String? = nil) {
        if let appUserID = appUserID {
            Purchases.configure(withAPIKey: apiKey, appUserID: appUserID)
        } else {
            Purchases.configure(withAPIKey: apiKey)
        }
        isConfigured = true
        fetchCustomerInfo()
    }
    
    // MARK: - Fetching
    
    func fetchOfferings() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Convert to our model
            var packages: [SubscriptionPackage] = []
            
            for (_, offering) in offerings.all {
                let tier = tier(from: offering.identifier)
                
                if let monthly = offering.monthly {
                    packages.append(SubscriptionPackage(
                        from: monthly,
                        tier: tier,
                        isAnnual: false
                    ))
                }
                if let annual = offering.annual {
                    packages.append(SubscriptionPackage(
                        from: annual,
                        tier: tier,
                        isAnnual: true
                    ))
                }
                // Handle lifetime package for Master tier
                if tier == .master, let lifetime = offering.lifetime {
                    packages.append(SubscriptionPackage(
                        from: lifetime,
                        tier: tier,
                        isAnnual: false,
                        isLifetime: true
                    ))
                }
            }
            
            self.offerings = packages.sorted { $0.monthlyPrice < $1.monthlyPrice }
            
        } catch let error as ErrorCode {
            handleRevenueCatError(error, context: "fetch_offerings")
        } catch {
            self.error = .purchaseFailed
            self.lastErrorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchCustomerInfo() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await updateSubscriptionStatus(with: customerInfo)
            } catch let error as ErrorCode {
                handleRevenueCatError(error, context: "fetch_customer_info")
            } catch {
                print("[SUBSCRIPTION] Error fetching customer info: \(error)")
            }
        }
    }
    
    // MARK: - Purchasing
    
    func purchase(tier: MembershipTier, isAnnual: Bool) async -> Result<PurchaseResult, SubscriptionError> {
        guard !isLoading else {
            return .failure(.purchaseFailed)
        }
        
        guard let package = getPackage(for: tier, isAnnual: isAnnual) else {
            return .failure(.productNotFound)
        }
        
        return await purchase(package: package)
    }
    
    func purchase(package: Package) async -> Result<PurchaseResult, SubscriptionError> {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            if userCancelled {
                error = .paymentCancelled
                return .failure(.paymentCancelled)
            }
            
            // Check for deferred transaction (e.g., parental approval pending)
            if transaction.transactionState == .deferred {
                print("[SUBSCRIPTION] Transaction deferred - awaiting approval")
                error = .paymentPending
                return .failure(.paymentPending)
            }
            
            await updateSubscriptionStatus(with: customerInfo)
            
            // Log success
            AnalyticsManager.shared.logPurchaseCompleted(
                tier: currentTier,
                isAnnual: package.packageType == .annual,
                price: package.storeProduct.price
            )
            
            return .success(PurchaseResult(
                transaction: transaction,
                customerInfo: customerInfo
            ))
            
        } catch let error as ErrorCode {
            handleRevenueCatError(error, context: "purchase")
            return .failure(mapRevenueCatError(error))
        } catch {
            let subError = SubscriptionError.unknown(error)
            self.error = subError
            self.lastErrorMessage = error.localizedDescription
            return .failure(subError)
        }
    }
    
    func restorePurchases() async -> Result<Void, SubscriptionError> {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await updateSubscriptionStatus(with: customerInfo)
            
            AnalyticsManager.shared.logSubscriptionRestored(tier: currentTier)
            
            return .success(())
            
        } catch let error as ErrorCode {
            handleRevenueCatError(error, context: "restore")
            return .failure(mapRevenueCatError(error))
        } catch {
            self.error = .restoreFailed
            self.lastErrorMessage = error.localizedDescription
            return .failure(.restoreFailed)
        }
    }
    
    // MARK: - Validation
    
    func verifySubscription() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await updateSubscriptionStatus(with: customerInfo)
            return hasActiveSubscription
        } catch {
            print("[SUBSCRIPTION] Verification failed: \(error)")
            return false
        }
    }
    
    func canAccessFeature(_ feature: PremiumFeature) -> Bool {
        switch feature.requiredTier {
        case .free:
            return true
        case .seeker:
            return currentTier.rawValue >= MembershipTier.seeker.rawValue
        case .initiate:
            return currentTier.rawValue >= MembershipTier.initiate.rawValue
        case .master:
            return currentTier.rawValue >= MembershipTier.master.rawValue
        }
    }
    
    func getManagementURL() async -> URL? {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.managementURL
        } catch {
            print("[SUBSCRIPTION] Error getting management URL: \(error)")
            return nil
        }
    }
    
    // MARK: - Eligibility
    
    func checkTrialEligibility(for product: String) async -> IntroEligibilityStatus {
        do {
            let eligibility = try await Purchases.shared.checkTrialOrIntroductoryPriceEligibility(productIdentifiers: [product])
            return eligibility[product]?.status ?? .unknown
        } catch {
            return .unknown
        }
    }
    
    // MARK: - Private Methods
    
    private func getPackage(for tier: MembershipTier, isAnnual: Bool) -> Package? {
        let offeringIdentifier: String
        switch tier {
        case .free:
            return nil
        case .seeker:
            offeringIdentifier = "seeker"
        case .initiate:
            offeringIdentifier = "initiate"
        case .master:
            offeringIdentifier = "master"
        }
        
        guard let offering = Purchases.shared.offerings().current?.offering(identifier: offeringIdentifier) else {
            return nil
        }
        
        // Master tier is lifetime - not monthly or annual
        if tier == .master {
            // Try to find lifetime package first, then fallback to available package
            return offering.lifetime ?? offering.availablePackages.first
        }
        
        // For other tiers, use monthly or annual
        guard let package = isAnnual ? offering.annual : offering.monthly else {
            return nil
        }
        
        return package
    }
    
    private func updateSubscriptionStatus(with customerInfo: CustomerInfo) async {
        self.customerInfo = customerInfo
        
        // Check for active subscriptions
        let activeEntitlements = customerInfo.entitlements.active
        
        if activeEntitlements.isEmpty {
            hasActiveSubscription = false
            currentTier = .free
            subscriptionStatus = .free
            statusSubject.send(.free)
            return
        }
        
        // Determine tier from entitlements
        var detectedTier: MembershipTier = .free
        
        if activeEntitlements["master"]?.isActive == true {
            detectedTier = .master
        } else if activeEntitlements["initiate"]?.isActive == true {
            detectedTier = .initiate
        } else if activeEntitlements["seeker"]?.isActive == true {
            detectedTier = .seeker
        }
        
        hasActiveSubscription = detectedTier != .free
        currentTier = detectedTier
        
        // Check for billing issues or other states
        if customerInfo.entitlements.all.values.contains(where: { $0.periodType == .trial }) {
            subscriptionStatus = .active(tier: detectedTier, expiryDate: nil)
        } else if customerInfo.entitlements.all.values.contains(where: { $0.willRenew == false }) {
            subscriptionStatus = .expired(tier: detectedTier, gracePeriod: false)
        } else {
            subscriptionStatus = .active(tier: detectedTier, expiryDate: nil)
        }
        
        statusSubject.send(subscriptionStatus)
    }
    
    private func tier(from offeringId: String) -> MembershipTier {
        switch offeringId.lowercased() {
        case "seeker":
            return .seeker
        case "initiate":
            return .initiate
        case "master":
            return .master
        default:
            return .free
        }
    }
    
    // MARK: - Error Handling
    
    private func handleRevenueCatError(_ error: ErrorCode, context: String) {
        let mappedError = mapRevenueCatError(error)
        self.error = mappedError
        self.lastErrorMessage = error.localizedDescription
        
        // Log to analytics
        AnalyticsManager.shared.logError(error, context: "subscription_\(context)")
        
        print("[SUBSCRIPTION] Error in \(context): \(mappedError)")
    }
    
    private func mapRevenueCatError(_ error: ErrorCode) -> SubscriptionError {
        switch error {
        case .purchaseCancelledError:
            return .paymentCancelled
        case .storeProblemError:
            return .purchaseFailed
        case .purchaseNotAllowedError:
            return .userNotEligible
        case .purchaseInvalidError:
            return .invalidReceipt
        case .productNotAvailableForPurchaseError:
            return .productNotFound
        case .productAlreadyPurchasedError:
            return .alreadyPurchased
        case .receiptAlreadyInUseError:
            return .invalidReceipt
        case .invalidReceiptError:
            return .invalidReceipt
        case .missingReceiptFileError:
            return .invalidReceipt
        case .networkError:
            return .purchaseFailed
        case .invalidCredentialsError:
            return .serverVerificationFailed
        case .unexpectedBackendResponseError:
            return .serverVerificationFailed
        case .receiptInUseByOtherSubscriberError:
            return .invalidReceipt
        case .operationAlreadyInProgressForProductError:
            return .purchaseFailed
        case .unknownBackendError:
            return .serverVerificationFailed
        case .invalidAppleSubscriptionKeyError:
            return .serverVerificationFailed
        case .ineligibleError:
            return .userNotEligible
        case .insufficientPermissionsError:
            return .userNotEligible
        case .paymentPendingError:
            return .paymentPending
        case .invalidSubscriberAttributesError:
            return .serverVerificationFailed
        case .logOutAnonymousUserError:
            return .serverVerificationFailed
        case .configurationError:
            return .serverVerificationFailed
        case .unsupportedError:
            return .purchaseFailed
        case .emptySubscriberAttributesError:
            return .purchaseFailed
        case .productDiscountMissingIdentifierError:
            return .purchaseFailed
        case .missingAppUserIDForAliasCreationError:
            return .serverVerificationFailed
        case .invalidPromotionalOfferError:
            return .purchaseFailed
        case .offlineConnectionError:
            return .purchaseFailed
        case .apiEndpointBlockedError:
            return .serverVerificationFailed
        case .invalidPlistTemplateError:
            return .serverVerificationFailed
        @unknown default:
            return .purchaseFailed
        }
    }
    
    func clearError() {
        error = nil
        lastErrorMessage = nil
    }
}

// MARK: - Purchases Delegate
extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            await self.updateSubscriptionStatus(with: customerInfo)
        }
    }
    
    /// Handles transaction updates from RevenueCat
    /// This is called for purchase interruptions, restorations, and updates
    nonisolated func purchases(_ purchases: Purchases, 
                              startedPurchaseFor product: StoreProduct,
                              with userCancelled: Bool) {
        Task { @MainActor in
            if userCancelled {
                print("[SUBSCRIPTION] User cancelled purchase for \(product.productIdentifier)")
                self.error = .paymentCancelled
            } else {
                print("[SUBSCRIPTION] Started purchase for \(product.productIdentifier)")
                self.isLoading = true
            }
        }
    }
    
    /// Called when a purchase completes successfully
    nonisolated func purchases(_ purchases: Purchases,
                              completedPurchase transaction: StoreTransaction,
                              with customerInfo: CustomerInfo) {
        Task { @MainActor in
            print("[SUBSCRIPTION] Purchase completed: \(transaction.productIdentifier)")
            await self.updateSubscriptionStatus(with: customerInfo)
            self.isLoading = false
            
            // Clear any errors
            self.error = nil
            self.lastErrorMessage = nil
            
            // Log success
            AnalyticsManager.shared.logPurchaseCompleted(
                tier: self.currentTier,
                isAnnual: transaction.productIdentifier.contains("yearly") || transaction.productIdentifier.contains("annual"),
                price: transaction.price
            )
        }
    }
    
    /// Called when a purchase fails
    nonisolated func purchases(_ purchases: Purchases,
                              failedToPurchaseWithError error: Error) {
        Task { @MainActor in
            print("[SUBSCRIPTION] Purchase failed: \(error.localizedDescription)")
            self.isLoading = false
            
            if let errorCode = error as? ErrorCode {
                self.handleRevenueCatError(errorCode, context: "purchase_delegate")
            } else {
                self.error = .purchaseFailed
                self.lastErrorMessage = error.localizedDescription
            }
        }
    }
    
    /// Called when purchases are restored
    nonisolated func purchases(_ purchases: Purchases,
                              restoredPurchasesWith customerInfo: CustomerInfo) {
        Task { @MainActor in
            print("[SUBSCRIPTION] Purchases restored")
            await self.updateSubscriptionStatus(with: customerInfo)
            self.isLoading = false
            
            AnalyticsManager.shared.logSubscriptionRestored(tier: self.currentTier)
        }
    }
    
    /// Called when restoration fails
    nonisolated func purchases(_ purchases: Purchases,
                              failedToRestoreWithError error: Error) {
        Task { @MainActor in
            print("[SUBSCRIPTION] Restore failed: \(error.localizedDescription)")
            self.isLoading = false
            
            if let errorCode = error as? ErrorCode {
                self.handleRevenueCatError(errorCode, context: "restore_delegate")
            } else {
                self.error = .restoreFailed
                self.lastErrorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Subscription Package Model
struct SubscriptionPackage: Identifiable {
    let id: String
    let tier: MembershipTier
    let isAnnual: Bool
    let isLifetime: Bool
    let price: Double
    let priceString: String
    let monthlyPrice: Double
    let monthlyPriceString: String
    let trialPeriod: String?
    let hasTrial: Bool
    
    init(from package: Package, tier: MembershipTier, isAnnual: Bool, isLifetime: Bool = false) {
        self.id = package.identifier
        self.tier = tier
        self.isAnnual = isAnnual
        self.isLifetime = isLifetime
        self.price = package.storeProduct.price
        self.priceString = package.localizedPriceString
        
        // For lifetime, monthly price is the full price (one-time payment)
        if isLifetime {
            self.monthlyPrice = package.storeProduct.price
            self.monthlyPriceString = package.localizedPriceString
        } else {
            self.monthlyPrice = isAnnual ? package.storeProduct.price / 12 : package.storeProduct.price
            
            if isAnnual {
                self.monthlyPriceString = String(format: "%.2f", self.monthlyPrice)
            } else {
                self.monthlyPriceString = package.localizedPriceString
            }
        }
        
        self.trialPeriod = package.storeProduct.introductoryDiscount?.subscriptionPeriod.periodTitle()
        self.hasTrial = package.storeProduct.introductoryDiscount != nil && !isLifetime
    }
    
    var annualSavings: Double {
        guard isAnnual else { return 0 }
        let monthlyTotal = monthlyPrice * 12
        return monthlyTotal - price
    }
    
    var savingsPercentage: Int {
        guard isAnnual, monthlyPrice > 0 else { return 0 }
        return Int((annualSavings / (monthlyPrice * 12)) * 100)
    }
}

// MARK: - Purchase Result
struct PurchaseResult {
    let transaction: StoreTransaction
    let customerInfo: CustomerInfo
}

// MARK: - Subscription Period Extension
extension SubscriptionPeriod {
    func periodTitle() -> String {
        let unitString: String
        switch self.unit {
        case .day:
            unitString = value == 1 ? "day" : "days"
        case .week:
            unitString = value == 1 ? "week" : "weeks"
        case .month:
            unitString = value == 1 ? "month" : "months"
        case .year:
            unitString = value == 1 ? "year" : "years"
        @unknown default:
            unitString = "period"
        }
        return "\(value) \(unitString)"
    }
}

// MARK: - Premium Feature Enum
enum PremiumFeature {
    case unlimitedCalculations
    case dailyQode
    case birthChart
    case compatibility
    case community
    case liveSessions
    case mentorship
    case journal
    case aiChat
    case noAds
    case exportData
    
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

// MARK: - Preview Helpers
extension SubscriptionManager {
    static var preview: SubscriptionManager {
        let manager = SubscriptionManager()
        manager.currentTier = .seeker
        manager.hasActiveSubscription = true
        manager.subscriptionStatus = .active(tier: .seeker, expiryDate: nil)
        return manager
    }
}
