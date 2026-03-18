//
//  MockServices.swift
//  Mock implementations for testing and previews
//

import Foundation
import Combine
import FirebaseAuth

// MARK: - Mock Auth Service
class MockAuthService: AuthServiceProtocol {
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    var isAuthenticated: Bool = false
    var currentUserId: String? = nil
    var currentUserEmail: String? = nil
    
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.unauthenticated)
    
    init(isAuthenticated: Bool = false) {
        self.isAuthenticated = isAuthenticated
        self.currentUserId = isAuthenticated ? "mock-user-id" : nil
        self.currentUserEmail = isAuthenticated ? "mock@example.com" : nil
        authStateSubject.send(isAuthenticated ? .authenticated(user: UserInfo(
            uid: "mock-user-id",
            email: "mock@example.com",
            displayName: "Mock User",
            photoURL: nil,
            emailVerified: true
        )) : .unauthenticated)
    }
    
    func signIn(email: String, password: String) async throws {
        if email.isEmpty || password.isEmpty {
            throw AuthError.invalidCredentials
        }
        isAuthenticated = true
        currentUserId = "mock-user-id"
        currentUserEmail = email
        authStateSubject.send(.authenticated(user: UserInfo(
            uid: "mock-user-id",
            email: email,
            displayName: "Mock User",
            photoURL: nil,
            emailVerified: true
        )))
    }
    
    func signUp(email: String, password: String, fullName: String) async throws {
        if email.isEmpty || password.count < 6 {
            throw ValidationError.invalidPassword
        }
        isAuthenticated = true
        currentUserId = "mock-user-id"
        currentUserEmail = email
        authStateSubject.send(.authenticated(user: UserInfo(
            uid: "mock-user-id",
            email: email,
            displayName: fullName,
            photoURL: nil,
            emailVerified: false
        )))
    }
    
    func signOut() async throws {
        isAuthenticated = false
        currentUserId = nil
        currentUserEmail = nil
        authStateSubject.send(.unauthenticated)
    }
    
    func sendPasswordReset(email: String) async throws {}
    
    func deleteAccount() async throws {
        isAuthenticated = false
        currentUserId = nil
        currentUserEmail = nil
    }
    
    func reauthenticate(password: String) async throws {}
    
    func signInWithGoogle() async throws {
        isAuthenticated = true
        currentUserId = "google-user-id"
        currentUserEmail = "google@example.com"
        authStateSubject.send(.authenticated(user: UserInfo(
            uid: "google-user-id",
            email: "google@example.com",
            displayName: "Google User",
            photoURL: nil,
            emailVerified: true
        )))
    }
    
    func signInWithApple(authorization: Any) async throws {
        isAuthenticated = true
        currentUserId = "apple-user-id"
        currentUserEmail = "apple@example.com"
        authStateSubject.send(.authenticated(user: UserInfo(
            uid: "apple-user-id",
            email: "apple@example.com",
            displayName: "Apple User",
            photoURL: nil,
            emailVerified: true
        )))
    }
    
    func updateProfile(displayName: String?, photoURL: URL?) async throws {}
    func updateEmail(_ email: String) async throws {}
    func updatePassword(_ password: String) async throws {}
    func sendEmailVerification() async throws {}
    func reloadUser() async throws {}
}

// MARK: - Mock Subscription Service
class MockSubscriptionService: SubscriptionServiceProtocol {
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    var offeringsPublisher: AnyPublisher<[SubscriptionOffering], Never> {
        Just([
            SubscriptionOffering(
                id: "seeker",
                tier: .seeker,
                title: "Seeker",
                description: "Unlock daily insights and basic charts",
                monthlyPrice: 9.99,
                annualPrice: 59.99,
                monthlyPriceString: "$9.99",
                annualPriceString: "$59.99",
                hasTrial: true,
                trialDuration: "7 days",
                features: ["Daily Qodes", "Basic Charts", "Community Access"],
                isRecommended: false
            ),
            SubscriptionOffering(
                id: "initiate",
                tier: .initiate,
                title: "Initiate",
                description: "Full access to advanced numerology",
                monthlyPrice: 19.99,
                annualPrice: 119.99,
                monthlyPriceString: "$19.99",
                annualPriceString: "$119.99",
                hasTrial: true,
                trialDuration: "14 days",
                features: ["Everything in Seeker", "AI Chat", "Live Sessions", "No Ads"],
                isRecommended: true
            ),
            SubscriptionOffering(
                id: "master",
                tier: .master,
                title: "Master",
                description: "Complete access with mentorship - One-time purchase",
                monthlyPrice: 199.99,
                annualPrice: 199.99,
                monthlyPriceString: "$199.99",
                annualPriceString: "$199.99 lifetime",
                hasTrial: false,
                trialDuration: nil,
                features: ["Everything in Initiate", "1-on-1 Mentorship", "Priority Support", "Lifetime Access"],
                isRecommended: false
            )
        ]).eraseToAnyPublisher()
    }
    
    var currentTier: MembershipTier
    var hasActiveSubscription: Bool
    var subscriptionExpiryDate: Date?
    var isEligibleForTrial: Bool = true
    var isEligibleForIntroOffer: Bool = true
    
    private let statusSubject = CurrentValueSubject<SubscriptionStatus, Never>(.free)
    
    init(tier: MembershipTier = .free) {
        self.currentTier = tier
        self.hasActiveSubscription = tier != .free
        self.subscriptionExpiryDate = tier != .free ? Date().addingTimeInterval(30 * 24 * 60 * 60) : nil
        self.statusSubject.send(tier == .free ? .free : .active(tier: tier, expiryDate: subscriptionExpiryDate))
    }
    
    func configure(withAPIKey: String, appUserID: String?) {}
    
    func fetchOfferings() async throws -> [SubscriptionOffering] {
        return [
            SubscriptionOffering(
                id: "seeker",
                tier: .seeker,
                title: "Seeker",
                description: "Unlock daily insights and basic charts",
                monthlyPrice: 9.99,
                annualPrice: 59.99,
                monthlyPriceString: "$9.99",
                annualPriceString: "$59.99",
                hasTrial: true,
                trialDuration: "7 days",
                features: ["Daily Qodes", "Basic Charts", "Community Access"],
                isRecommended: false
            )
        ]
    }
    
    func fetchCustomerInfo() async throws -> CustomerInfo {
        throw SubscriptionError.serverVerificationFailed
    }
    
    func purchase(_ tier: MembershipTier, isAnnual: Bool) async throws -> PurchaseResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        currentTier = tier
        hasActiveSubscription = true
        statusSubject.send(.active(tier: tier, expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60)))
        
        return PurchaseResult.success(
            transaction: MockStoreTransaction(),
            customerInfo: MockCustomerInfo()
        )
    }
    
    func purchase(package: Any) async throws -> PurchaseResult {
        return PurchaseResult.success(
            transaction: MockStoreTransaction(),
            customerInfo: MockCustomerInfo()
        )
    }
    
    func restorePurchases() async throws -> RestoreResult {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if currentTier != .free {
            return RestoreResult.success(customerInfo: MockCustomerInfo())
        }
        return RestoreResult.noPurchasesFound
    }
    
    func syncPurchases() async throws {}
    
    func checkTrialOrIntroductoryPriceEligibility(for products: [String]) async -> [String: IntroEligibilityStatus] {
        return products.reduce(into: [:]) { dict, product in
            dict[product] = .eligible
        }
    }
    
    func presentCodeRedemptionSheet() async {}
    
    func verifySubscription() async -> Bool {
        return hasActiveSubscription
    }
    
    func canAccessPremiumFeature(_ feature: PremiumFeature) -> Bool {
        return currentTier.rawValue >= feature.requiredTier.rawValue
    }
    
    func getManagementURL() async -> URL? {
        return URL(string: "https://apps.apple.com/account/subscriptions")
    }
}

// MARK: - Mock Analytics Service
class MockAnalyticsService: AnalyticsServiceProtocol {
    var loggedEvents: [(name: String, parameters: [String: Any]?)] = []
    
    func configure(userId: String?) {}
    func setUserId(_ userId: String?) {}
    func setUserProperties(_ properties: [String: Any?]) {}
    
    func logEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvents.append((name, parameters))
        print("[ANALYTICS] \(name): \(parameters ?? [:])")
    }
    
    func logScreenView(screenName: String, screenClass: String?) {
        logEvent("screen_view", parameters: ["screen_name": screenName])
    }
    
    func logUserAction(_ action: String, category: String, value: Double?) {
        logEvent("user_action", parameters: [
            "action": action,
            "category": category,
            "value": value ?? 0
        ])
    }
    
    func logAppOpen() {
        logEvent("app_open", parameters: nil)
    }
    
    func logAppBackground() {
        logEvent("app_background", parameters: nil)
    }
    
    func logAppForeground() {
        logEvent("app_foreground", parameters: nil)
    }
    
    func logSignUp(method: String) {
        logEvent("sign_up", parameters: ["method": method])
    }
    
    func logLogin(method: String) {
        logEvent("login", parameters: ["method": method])
    }
    
    func logLogout() {
        logEvent("logout", parameters: nil)
    }
    
    func logPurchase(params: PurchaseEventParams) {
        logEvent("purchase", parameters: [
            "value": params.value,
            "currency": params.currency
        ])
    }
    
    func logRefund(params: RefundEventParams) {
        logEvent("refund", parameters: ["value": params.value])
    }
    
    func logAddToCart(params: CartEventParams) {
        logEvent("add_to_cart", parameters: ["value": params.value])
    }
    
    func logBeginCheckout(params: CheckoutEventParams) {
        logEvent("begin_checkout", parameters: ["value": params.value])
    }
    
    func logContentView(contentId: String, contentType: String, contentName: String?) {
        logEvent("content_view", parameters: [
            "content_id": contentId,
            "content_type": contentType
        ])
    }
    
    func logContentShare(contentId: String, contentType: String, method: String) {
        logEvent("share", parameters: [
            "content_id": contentId,
            "method": method
        ])
    }
    
    func logSearch(query: String, resultsCount: Int?) {
        logEvent("search", parameters: [
            "query": query,
            "results_count": resultsCount ?? 0
        ])
    }
    
    func logError(_ error: Error, context: String) {
        logEvent("error", parameters: [
            "error": error.localizedDescription,
            "context": context
        ])
    }
    
    func logNonFatalException(_ exception: NSException) {
        logEvent("exception", parameters: ["reason": exception.reason ?? "unknown"])
    }
    
    func startTimer(name: String) {}
    func stopTimer(name: String, params: [String: Any]?) {}
    func logPerformanceMetric(name: String, value: Double, unit: String?) {}
}

// MARK: - Mock Firebase Service
class MockFirebaseService: FirebaseServiceProtocol {
    var mockUserProfile: UserProfileData?
    var mockDailyQode: DailyQodeData?
    var mockSessions: [LiveSessionData] = []
    var mockPosts: [CommunityPostData] = []
    
    func fetchUserProfile(userId: String) async throws -> UserProfileData {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if let profile = mockUserProfile {
            return profile
        }
        
        return UserProfileData(
            userId: userId,
            name: "Mock User",
            email: "mock@example.com",
            birthDate: Date(),
            birthTime: nil,
            timezone: "UTC",
            lifePath: 7,
            createdAt: Date()
        )
    }
    
    func saveUserProfile(_ profile: UserProfileData) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        mockUserProfile = profile
    }
    
    func updateUserProfile(userId: String, updates: [String: Any]) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
    
    func fetchDailyQode(for date: Date, lifePath: Int) async throws -> DailyQodeData {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if let qode = mockDailyQode {
            return qode
        }
        
        return DailyQodeData(
            date: date,
            universalDay: 3,
            personalDay: 1,
            lifePath: lifePath,
            title: "Day of New Beginnings",
            description: "A day to start fresh and embrace new opportunities.",
            affirmation: "I welcome new beginnings with open arms.",
            activities: ["Set intentions", "Start a new project"],
            avoidances: ["Procrastination", "Dwelling on the past"]
        )
    }
    
    func markQodeAsRead(userId: String, date: Date) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
    
    func fetchUpcomingSessions() async throws -> [LiveSessionData] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if !mockSessions.isEmpty {
            return mockSessions
        }
        
        return [
            LiveSessionData(
                id: "session-1",
                title: "Introduction to Numerology",
                description: "Learn the basics of numerology",
                startTime: Date().addingTimeInterval(86400),
                duration: 60,
                maxAttendees: 100,
                registeredAttendees: 45,
                isPremium: false,
                type: "qa",
                recordingUrl: nil
            )
        ]
    }
    
    func registerForSession(userId: String, sessionId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
    
    func fetchCommunityPosts(limit: Int, lastDocument: String?) async throws -> ([CommunityPostData], String?) {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if !mockPosts.isEmpty {
            return (mockPosts, nil)
        }
        
        let posts = [
            CommunityPostData(
                id: "post-1",
                userId: "user-1",
                content: "Just discovered my Life Path number is 7!",
                tags: ["lifepath", "discovery"],
                timestamp: Date(),
                likes: 12,
                comments: 3
            )
        ]
        
        return (posts, nil)
    }
    
    func createPost(userId: String, content: String, tags: [String]) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
    
    func likePost(userId: String, postId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
    
    func fetchSubscriptionStatus(userId: String) async throws -> SubscriptionData {
        return SubscriptionData.free()
    }
    
    func recordSubscription(userId: String, tier: String, isYearly: Bool, transactionId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
    
    func trackEvent(userId: String, event: String, parameters: [String: Any]) async throws {}
}

// MARK: - Mock Cache Service
class MockCacheService: CacheServiceProtocol {
    private var storage: [String: Data] = [:]
    private var expiry: [String: Date] = [:]
    
    func get<T: Codable>(key: String) async throws -> T? {
        // Check expiry
        if let expiryDate = expiry[key], expiryDate < Date() {
            storage.removeValue(forKey: key)
            expiry.removeValue(forKey: key)
            return nil
        }
        
        guard let data = storage[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func set<T: Codable>(_ value: T, key: String, expiry: TimeInterval?) async throws {
        let data = try JSONEncoder().encode(value)
        storage[key] = data
        
        if let expiry = expiry {
            self.expiry[key] = Date().addingTimeInterval(expiry)
        }
    }
    
    func delete(key: String) async {
        storage.removeValue(forKey: key)
        expiry.removeValue(forKey: key)
    }
    
    func clear() async {
        storage.removeAll()
        expiry.removeAll()
    }
}

// MARK: - Mock Notification Service
class MockNotificationService: NotificationServiceProtocol {
    var authorized = false
    var scheduledNotifications: [String: NotificationContent] = [:]
    
    func requestAuthorization() async throws -> Bool {
        authorized = true
        return true
    }
    
    func scheduleNotification(id: String, content: NotificationContent, trigger: NotificationTrigger) async throws {
        scheduledNotifications[id] = content
    }
    
    func cancelNotification(id: String) {
        scheduledNotifications.removeValue(forKey: id)
    }
    
    func getPendingNotifications() async -> [NotificationContent] {
        Array(scheduledNotifications.values)
    }
}

// MARK: - Mock Deep Link Service
class MockDeepLinkService: DeepLinkServiceProtocol {
    var handlers: [DeepLinkHandler] = []
    
    func handle(url: URL) -> DeepLinkRoute? {
        DeepLinkRoute(url: url)
    }
    
    func registerHandler(_ handler: DeepLinkHandler) {
        handlers.append(handler)
    }
}

// MARK: - Mock Store Transaction
struct MockStoreTransaction: StoreTransaction {
    var productIdentifier: String = "mock_product"
    var purchaseDate: Date = Date()
    var transactionIdentifier: String = "mock_transaction_123"
}

// MARK: - Mock Customer Info
struct MockCustomerInfo {
    var entitlements: Entitlements = MockEntitlements()
}

struct MockEntitlements {
    var all: [String: EntitlementInfo] = [:]
    var active: [String: EntitlementInfo] = [:]
}

// MARK: - Preview Helpers
extension DependencyContainer {
    static func mock(
        authService: AuthServiceProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        firebaseService: FirebaseServiceProtocol? = nil
    ) -> DependencyContainer {
        DependencyContainer(
            authService: authService ?? MockAuthService(),
            subscriptionService: subscriptionService ?? MockSubscriptionService(),
            analyticsService: analyticsService ?? MockAnalyticsService(),
            firebaseService: firebaseService ?? MockFirebaseService(),
            cacheService: MockCacheService(),
            notificationService: MockNotificationService(),
            deepLinkService: MockDeepLinkService()
        )
    }
}
