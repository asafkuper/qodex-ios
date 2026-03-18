//
//  DependencyContainer.swift
//  Central dependency injection container
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - Dependency Container
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Shared Instance
    static let shared = DependencyContainer()
    
    // MARK: - Services (Protocol-based)
    let authService: AuthServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let firebaseService: FirebaseServiceProtocol
    let cacheService: CacheServiceProtocol
    let notificationService: NotificationServiceProtocol
    let deepLinkService: DeepLinkServiceProtocol
    
    // MARK: - Managers (Concrete implementations)
    let errorHandler: ErrorHandler
    let recoveryManager: ErrorRecoveryManager
    let networkMonitor: NetworkMonitor
    let inputValidator: InputValidator.Type
    
    // MARK: - View Model Factories
    lazy var dashboardViewModelFactory: () -> DashboardViewModel = {
        { [weak self] in
            guard let self = self else {
                // Return a minimal view model instead of crashing
                return DashboardViewModel(
                    firebaseService: MockFirebaseService(),
                    authService: MockAuthService(),
                    analyticsService: MockAnalyticsService()
                )
            }
            return DashboardViewModel(
                firebaseService: self.firebaseService,
                authService: self.authService,
                analyticsService: self.analyticsService
            )
        }
    }()
    
    lazy var calculatorViewModelFactory: () -> CalculatorViewModel = {
        { [weak self] in
            guard let self = self else {
                return CalculatorViewModel(
                    analyticsService: MockAnalyticsService()
                )
            }
            return CalculatorViewModel(
                analyticsService: self.analyticsService
            )
        }
    }()
    
    lazy var dailyQodeViewModelFactory: () -> DailyQodeViewModel = {
        { [weak self] in
            guard let self = self else {
                return DailyQodeViewModel(
                    firebaseService: MockFirebaseService(),
                    authService: MockAuthService(),
                    cacheService: MockCacheService()
                )
            }
            return DailyQodeViewModel(
                firebaseService: self.firebaseService,
                authService: self.authService,
                cacheService: self.cacheService
            )
        }
    }()
    
    lazy var profileViewModelFactory: () -> ProfileViewModel = {
        { [weak self] in
            guard let self = self else {
                return ProfileViewModel(
                    authService: MockAuthService(),
                    firebaseService: MockFirebaseService(),
                    subscriptionService: MockSubscriptionService()
                )
            }
            return ProfileViewModel(
                authService: self.authService,
                firebaseService: self.firebaseService,
                subscriptionService: self.subscriptionService
            )
        }
    }()
    
    lazy var communityViewModelFactory: () -> CommunityViewModel = {
        { [weak self] in
            guard let self = self else {
                return CommunityViewModel(
                    firebaseService: MockFirebaseService(),
                    authService: MockAuthService(),
                    analyticsService: MockAnalyticsService()
                )
            }
            return CommunityViewModel(
                firebaseService: self.firebaseService,
                authService: self.authService,
                analyticsService: self.analyticsService
            )
        }
    }()
    
    lazy var subscriptionViewModelFactory: () -> SubscriptionViewModel = {
        { [weak self] in
            guard let self = self else {
                return SubscriptionViewModel(
                    subscriptionService: MockSubscriptionService(),
                    analyticsService: MockAnalyticsService()
                )
            }
            return SubscriptionViewModel(
                subscriptionService: self.subscriptionService,
                analyticsService: self.analyticsService
            )
        }
    }()
    
    lazy var authViewModelFactory: () -> AuthViewModel = {
        { [weak self] in
            guard let self = self else {
                return AuthViewModel(
                    authService: MockAuthService(),
                    analyticsService: MockAnalyticsService()
                )
            }
            return AuthViewModel(
                authService: self.authService,
                analyticsService: self.analyticsService
            )
        }
    }()
    
    lazy var onboardingViewModelFactory: () -> OnboardingViewModel = {
        { [weak self] in
            guard let self = self else {
                return OnboardingViewModel(
                    authService: MockAuthService(),
                    firebaseService: MockFirebaseService()
                )
            }
            return OnboardingViewModel(
                authService: self.authService,
                firebaseService: self.firebaseService
            )
        }
    }()
    
    lazy var settingsViewModelFactory: () -> SettingsViewModel = {
        { [weak self] in
            guard let self = self else {
                return SettingsViewModel(
                    authService: MockAuthService(),
                    subscriptionService: MockSubscriptionService(),
                    notificationService: MockNotificationService()
                )
            }
            return SettingsViewModel(
                authService: self.authService,
                subscriptionService: self.subscriptionService,
                notificationService: self.notificationService
            )
        }
    }()
    
    // MARK: - Initialization
    init(
        authService: AuthServiceProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        firebaseService: FirebaseServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        deepLinkService: DeepLinkServiceProtocol? = nil
    ) {
        // Use provided services or create default implementations
        self.authService = authService ?? AuthService()
        self.subscriptionService = subscriptionService ?? SubscriptionService()
        self.analyticsService = analyticsService ?? AnalyticsService()
        self.firebaseService = firebaseService ?? FirebaseServiceAdapter()
        self.cacheService = cacheService ?? CacheService()
        self.notificationService = notificationService ?? NotificationService()
        self.deepLinkService = deepLinkService ?? DeepLinkService()
        
        // Initialize managers
        self.errorHandler = ErrorHandler.shared
        self.recoveryManager = ErrorRecoveryManager.shared
        self.networkMonitor = NetworkMonitor.shared
        self.inputValidator = InputValidator.self
        
        // Setup service dependencies
        setupDependencies()
    }
    
    // MARK: - Setup
    private func setupDependencies() {
        // Configure services that depend on each other
        // This is where we wire up circular dependencies if needed
    }
    
    // MARK: - Environment Injection
    func injectEnvironment(into view: some View) -> some View {
        view
            .environmentObject(self)
            .environmentObject(authService as! AuthService)
            .environmentObject(subscriptionService as! SubscriptionService)
            .environmentObject(analyticsService as! AnalyticsService)
            .environmentObject(firebaseService as! FirebaseServiceAdapter)
            .environmentObject(errorHandler)
            .environmentObject(networkMonitor)
    }
}

// MARK: - Preview Container
extension DependencyContainer {
    static var preview: DependencyContainer {
        DependencyContainer(
            authService: MockAuthService(),
            subscriptionService: MockSubscriptionService(),
            analyticsService: MockAnalyticsService(),
            firebaseService: MockFirebaseService(),
            cacheService: MockCacheService(),
            notificationService: MockNotificationService(),
            deepLinkService: MockDeepLinkService()
        )
    }
}

// MARK: - Service Protocols
protocol CacheServiceProtocol {
    func get<T: Codable>(key: String) async throws -> T?
    func set<T: Codable>(_ value: T, key: String, expiry: TimeInterval?) async throws
    func delete(key: String) async
    func clear() async
}

protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleNotification(id: String, content: NotificationContent, trigger: NotificationTrigger) async throws
    func cancelNotification(id: String)
    func getPendingNotifications() async -> [NotificationContent]
}

protocol DeepLinkServiceProtocol {
    func handle(url: URL) -> DeepLinkRoute?
    func registerHandler(_ handler: DeepLinkHandler)
}

struct NotificationContent {
    let title: String
    let body: String
    let userInfo: [String: Any]
}

enum NotificationTrigger {
    case date(Date)
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int)
}

// MARK: - Default Service Implementations
class AuthService: AuthServiceProtocol {
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.unauthenticated)
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user != nil ? .authenticated : .unauthenticated)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
}

class SubscriptionService: SubscriptionServiceProtocol {
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    private let statusSubject = CurrentValueSubject<SubscriptionStatus, Never>(.free)
    
    var currentTier: MembershipTier { .free }
    var hasActiveSubscription: Bool { false }
    
    func purchase(_ tier: MembershipTier, isAnnual: Bool) async throws {
        // Implementation
    }
    
    func restorePurchases() async throws {
        // Implementation
    }
}

class AnalyticsService: AnalyticsServiceProtocol {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        AnalyticsManager.shared.logCustomEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, forName: String) {
        AnalyticsManager.shared.logUserProperties(user: QodeXUser(
            id: "", email: "", fullName: "", membershipTier: .free, createdAt: Date()
        ))
    }
}

class FirebaseServiceAdapter: FirebaseServiceProtocol {
    func fetchUserProfile(userId: String) async throws -> UserProfileData {
        // Implementation using existing FirebaseService
        throw FirebaseError.documentNotFound
    }
    
    func saveUserProfile(_ profile: UserProfileData) async throws {
        // Implementation using existing FirebaseService
    }
    
    func fetchDailyQode(for date: Date, lifePath: Int) async throws -> DailyQodeData {
        // Implementation
        throw FirebaseError.documentNotFound
    }
    
    func fetchCommunityPosts(limit: Int, lastDocument: String?) async throws -> ([CommunityPostData], String?) {
        // Implementation
        return ([], nil)
    }
    
    func createPost(_ post: CommunityPostData) async throws {
        // Implementation
    }
}

class CacheService: CacheServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func get<T: Codable>(key: String) async throws -> T? {
        // Try keychain first for sensitive data
        if let keychainData = KeychainManager.retrieve(key: KeychainKey(rawValue: "cache_\(key)") ?? .userAuthToken),
           let value = try? decoder.decode(T.self, from: keychainData) {
            return value
        }
        
        // Fall back to UserDefaults for non-sensitive cache
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }
    
    func set<T: Codable>(_ value: T, key: String, expiry: TimeInterval?) async throws {
        let data = try encoder.encode(value)
        
        // Store sensitive cache data in Keychain
        _ = KeychainManager.store(data, key: KeychainKey(rawValue: "cache_\(key)") ?? .userAuthToken)
        
        if let expiry = expiry {
            userDefaults.set(Date().addingTimeInterval(expiry), forKey: "\(key)_expiry")
        }
    }
    
    func delete(key: String) async {
        _ = KeychainManager.delete(key: KeychainKey(rawValue: "cache_\(key)") ?? .userAuthToken)
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() async {
        // Clear all cache keys
    }
}

class NotificationService: NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool {
        // Implementation
        return false
    }
    
    func scheduleNotification(id: String, content: NotificationContent, trigger: NotificationTrigger) async throws {
        // Implementation
    }
    
    func cancelNotification(id: String) {
        // Implementation
    }
    
    func getPendingNotifications() async -> [NotificationContent] {
        // Implementation
        return []
    }
}

class DeepLinkService: DeepLinkServiceProtocol {
    private var handlers: [DeepLinkHandler] = []
    
    func handle(url: URL) -> DeepLinkRoute? {
        DeepLinkRoute(url: url)
    }
    
    func registerHandler(_ handler: DeepLinkHandler) {
        handlers.append(handler)
    }
}

enum SubscriptionStatus {
    case free
    case active(tier: MembershipTier)
    case expired
    case pending
}
