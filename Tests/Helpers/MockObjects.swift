//
//  MockObjects.swift
//  Mock implementations for testing
//

import Foundation
import Combine
@testable import QodeX

// MARK: - Mock Authentication Manager

@MainActor
class MockAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: QodeXUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var shouldSucceed = true
    var simulatedError: Error?
    var mockUser: QodeXUser?
    
    func signUp(email: String, password: String, fullName: String, birthDate: Date) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if let error = simulatedError {
            errorMessage = error.localizedDescription
            throw error
        }
        
        guard shouldSucceed else {
            let error = AuthError.invalidCredential
            errorMessage = error.localizedDescription
            throw error
        }
        
        let user = QodeXUser(
            id: UUID().uuidString,
            email: email,
            fullName: fullName,
            birthDate: birthDate,
            membershipTier: .free,
            createdAt: Date()
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        self.mockUser = user
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if let error = simulatedError {
            errorMessage = error.localizedDescription
            throw error
        }
        
        guard shouldSucceed else {
            throw AuthError.invalidCredential
        }
        
        self.isAuthenticated = true
        self.currentUser = mockUser
    }
    
    func signOut() throws {
        if let error = simulatedError {
            throw error
        }
        
        isAuthenticated = false
        currentUser = nil
    }
}

// MARK: - Mock Subscription Manager

@MainActor
class MockSubscriptionManager: ObservableObject {
    @Published var currentTier: MembershipTier = .free
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var shouldSucceed = true
    var simulatedError: Error?
    var availableProducts: [SubscriptionProduct] = [
        .seekerMonthly, .seekerAnnual,
        .initiateMonthly, .initiateAnnual,
        .masterMonthly, .masterAnnual
    ]
    
    func purchase(product: SubscriptionProduct) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if let error = simulatedError {
            errorMessage = error.localizedDescription
            throw error
        }
        
        guard shouldSucceed else {
            throw SubscriptionError.purchaseFailed
        }
        
        currentTier = product.tier
    }
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        if let error = simulatedError {
            throw error
        }
        
        // Restore to mock state
        currentTier = .seeker
    }
    
    func fetchAvailableProducts() async -> [SubscriptionProduct] {
        isLoading = true
        defer { isLoading = false }
        
        return availableProducts
    }
}

enum SubscriptionError: Error {
    case purchaseFailed
    case productNotFound
    case restoreFailed
}

// MARK: - Mock Notification Manager

@MainActor
class MockNotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var scheduledNotifications: [MockScheduledNotification] = []
    
    var shouldRequestAuthorization = true
    
    func requestAuthorization() async -> Bool {
        isAuthorized = shouldRequestAuthorization
        return isAuthorized
    }
    
    func scheduleDailyQodeNotification(date: Date, title: String, body: String) {
        let notification = MockScheduledNotification(
            id: UUID().uuidString,
            date: date,
            title: title,
            body: body,
            type: .dailyQode
        )
        scheduledNotifications.append(notification)
    }
    
    func scheduleReminder(date: Date, title: String, body: String) {
        let notification = MockScheduledNotification(
            id: UUID().uuidString,
            date: date,
            title: title,
            body: body,
            type: .reminder
        )
        scheduledNotifications.append(notification)
    }
    
    func cancelAllNotifications() {
        scheduledNotifications.removeAll()
    }
    
    func cancelNotification(id: String) {
        scheduledNotifications.removeAll { $0.id == id }
    }
}

struct MockScheduledNotification: Identifiable {
    let id: String
    let date: Date
    let title: String
    let body: String
    let type: NotificationType
    
    enum NotificationType {
        case dailyQode
        case reminder
        case system
    }
}

// MARK: - Mock Analytics Manager

class MockAnalyticsManager {
    var trackedEvents: [MockAnalyticsEvent] = []
    var userProperties: [String: Any] = [:]
    
    func trackEvent(_ event: String, parameters: [String: Any] = [:]) {
        let analyticsEvent = MockAnalyticsEvent(
            name: event,
            parameters: parameters,
            timestamp: Date()
        )
        trackedEvents.append(analyticsEvent)
    }
    
    func setUserProperty(_ value: Any, forName name: String) {
        userProperties[name] = value
    }
    
    func setUserId(_ userId: String) {
        userProperties["user_id"] = userId
    }
    
    func logScreenView(screenName: String, screenClass: String? = nil) {
        trackEvent("screen_view", parameters: [
            "screen_name": screenName,
            "screen_class": screenClass ?? "Unknown"
        ])
    }
    
    func clearEvents() {
        trackedEvents.removeAll()
    }
}

struct MockAnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
}

// MARK: - Mock Numerology Calculator

class MockNumerologyCalculator {
    static let shared = MockNumerologyCalculator()
    
    var mockLifePath: Int = 5
    var mockExpression: Int = 3
    var mockSoulUrge: Int = 7
    var mockPersonality: Int = 1
    
    func calculateLifePath(day: Int, month: Int, year: Int) -> Int {
        return mockLifePath
    }
    
    func calculateExpression(from name: String) -> Int {
        return mockExpression
    }
    
    func calculateSoulUrge(from name: String) -> Int {
        return mockSoulUrge
    }
    
    func calculatePersonality(from name: String) -> Int {
        return mockPersonality
    }
    
    func generateMockChart(for birthDate: Date, fullName: String) -> NumerologyChart {
        return NumerologyChart(
            lifePath: mockLifePath,
            expression: mockExpression,
            soulUrge: mockSoulUrge,
            personality: mockPersonality,
            birthday: Calendar.current.component(.day, from: birthDate),
            maturity: mockLifePath + mockExpression,
            challenges: [1, 2, 3, 4],
            pinnacles: [
                Pinnacle(number: 1, ageStart: 0, ageEnd: 35),
                Pinnacle(number: 2, ageStart: 36, ageEnd: 44),
                Pinnacle(number: 3, ageStart: 45, ageEnd: 53),
                Pinnacle(number: 4, ageStart: 54, ageEnd: nil)
            ],
            personalYear: 5,
            personalMonth: 3,
            personalDay: 1,
            birthDate: birthDate,
            fullName: fullName
        )
    }
}

// MARK: - Mock UserDefaults

class MockUserDefaults {
    private var storage: [String: Any] = [:]
    
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
    
    func object(forKey key: String) -> Any? {
        return storage[key]
    }
    
    func string(forKey key: String) -> String? {
        return storage[key] as? String
    }
    
    func bool(forKey key: String) -> Bool {
        return storage[key] as? Bool ?? false
    }
    
    func integer(forKey key: String) -> Int {
        return storage[key] as? Int ?? 0
    }
    
    func data(forKey key: String) -> Data? {
        return storage[key] as? Data
    }
    
    func removeObject(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    func reset() {
        storage.removeAll()
    }
    
    var allKeys: [String] {
        return Array(storage.keys)
    }
}

// MARK: - Mock URLSession

class MockURLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return (data, response)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return (data, response)
    }
}

// MARK: - Mock Image Cache

@MainActor
class MockImageCache {
    private var cache: [String: Data] = [:]
    
    func store(_ data: Data, forKey key: String) {
        cache[key] = data
    }
    
    func retrieve(forKey key: String) -> Data? {
        return cache[key]
    }
    
    func remove(forKey key: String) {
        cache.removeValue(forKey: key)
    }
    
    func clear() {
        cache.removeAll()
    }
    
    var count: Int {
        return cache.count
    }
}

// MARK: - Mock Deep Link Manager

@MainActor
class MockDeepLinkManager: ObservableObject {
    @Published var currentDeepLink: DeepLink?
    @Published var handledDeepLinks: [DeepLink] = []
    
    func handle(url: URL) -> Bool {
        guard let deepLink = parse(url: url) else {
            return false
        }
        
        currentDeepLink = deepLink
        handledDeepLinks.append(deepLink)
        return true
    }
    
    private func parse(url: URL) -> DeepLink? {
        // Mock parsing logic
        if url.scheme == "qodex" {
            return DeepLink(type: .profile, parameters: ["id": "123"])
        }
        return nil
    }
}

struct DeepLink {
    enum LinkType {
        case profile
        case content
        case settings
        case subscription
    }
    
    let type: LinkType
    let parameters: [String: String]
}

// MARK: - Mock Error Handler

@MainActor
class MockErrorHandler: ObservableObject {
    @Published var currentError: Error?
    @Published var errorMessage: String?
    @Published var shouldShowError = false
    
    var loggedErrors: [Error] = []
    
    func handle(_ error: Error, context: String? = nil) {
        currentError = error
        loggedErrors.append(error)
        
        if let context = context {
            errorMessage = "\(context): \(error.localizedDescription)"
        } else {
            errorMessage = error.localizedDescription
        }
        
        shouldShowError = true
    }
    
    func clearError() {
        currentError = nil
        errorMessage = nil
        shouldShowError = false
    }
    
    func reset() {
        loggedErrors.removeAll()
        clearError()
    }
}

// MARK: - Mock Timer

class MockTimer {
    private var timer: Timer?
    private var fireDate: Date?
    
    var isValid: Bool {
        return timer?.isValid ?? false
    }
    
    func schedule(timeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void) {
        fireDate = Date().addingTimeInterval(timeInterval)
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { _ in
            block()
        }
    }
    
    func fire() {
        timer?.fire()
    }
    
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Mock Date Provider

class MockDateProvider {
    var currentDate: Date
    
    init(date: Date = Date()) {
        self.currentDate = date
    }
    
    func now() -> Date {
        return currentDate
    }
    
    func advance(by timeInterval: TimeInterval) {
        currentDate = currentDate.addingTimeInterval(timeInterval)
    }
    
    func setDate(_ date: Date) {
        self.currentDate = date
    }
}

// MARK: - Mock File Manager

class MockFileManager {
    private var files: [String: Data] = [:]
    
    func fileExists(atPath path: String) -> Bool {
        return files[path] != nil
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes: [FileAttributeKey: Any]? = nil) -> Bool {
        files[path] = data
        return true
    }
    
    func contents(atPath path: String) -> Data? {
        return files[path]
    }
    
    func removeItem(atPath path: String) throws {
        files.removeValue(forKey: path)
    }
    
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        return Array(files.keys)
    }
    
    func reset() {
        files.removeAll()
    }
}

// MARK: - Test Doubles Protocol

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, fullName: String, birthDate: Date) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

protocol SubscriptionServiceProtocol {
    func purchase(product: SubscriptionProduct) async throws
    func restorePurchases() async throws
    func fetchAvailableProducts() async -> [SubscriptionProduct]
}

protocol NotificationServiceProtocol {
    func requestAuthorization() async -> Bool
    func scheduleNotification(date: Date, title: String, body: String)
    func cancelAllNotifications()
}