//
//  FirebaseServiceTests.swift
//  Integration tests for Firebase Service with mocked Firestore
//

import Testing
import Foundation
import Combine
@testable import QodeX

// MARK: - Mock Firestore Types

enum MockFirebaseError: Error {
    case documentNotFound
    case networkError
    case invalidData
    case permissionDenied
    case unknown
}

// MARK: - Mock Firestore Document

class MockDocumentSnapshot {
    let documentID: String
    let data: [String: Any]?
    let exists: Bool
    
    init(documentID: String, data: [String: Any]? = nil, exists: Bool = true) {
        self.documentID = documentID
        self.data = data
        self.exists = exists
    }
}

// MARK: - Mock Firestore Query Snapshot

class MockQuerySnapshot {
    let documents: [MockDocumentSnapshot]
    
    init(documents: [MockDocumentSnapshot]) {
        self.documents = documents
    }
}

// MARK: - Mock Firebase Service

class MockFirebaseService {
    var mockUsers: [String: [String: Any]] = [:]
    var mockDailyQodes: [String: [String: Any]] = [:]
    var mockSessions: [String: [String: Any]] = [:]
    var mockPosts: [String: [String: Any]] = [:]
    var mockSubscriptions: [[String: Any]] = []
    
    var shouldSimulateError: MockFirebaseError?
    var simulatedDelay: TimeInterval = 0
    
    // MARK: - User Management Mocks
    
    func createUserProfile(userId: String, profile: UserProfileData) -> AnyPublisher<Void, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        mockUsers[userId] = profile.toDictionary()
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchUserProfile(userId: String) -> AnyPublisher<UserProfileData, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let data = mockUsers[userId] else {
            return Fail(error: MockFirebaseError.documentNotFound).eraseToAnyPublisher()
        }
        
        let profile = UserProfileData(from: data)
        return Just(profile).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateUserProfile(userId: String, updates: [String: Any]) -> AnyPublisher<Void, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard mockUsers[userId] != nil else {
            return Fail(error: MockFirebaseError.documentNotFound).eraseToAnyPublisher()
        }
        
        for (key, value) in updates {
            mockUsers[userId]?[key] = value
        }
        
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Daily Qodes Mocks
    
    func fetchDailyQode(for date: Date, userLifePath: Int) -> AnyPublisher<DailyQodeData, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let dateString = ISO8601DateFormatter().string(from: date)
        
        if let data = mockDailyQodes[dateString] {
            let qode = DailyQodeData(from: data, lifePath: userLifePath)
            return Just(qode).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // Return default qode
            let defaultQode = DailyQodeData(
                date: date,
                universalDay: 1,
                personalDay: 1,
                lifePath: userLifePath,
                title: "Default Qode",
                description: "A day for discovery.",
                affirmation: "I embrace the day.",
                activities: ["Reflect", "Plan"],
                avoidances: ["Procrastinate"]
            )
            return Just(defaultQode).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Live Sessions Mocks
    
    func fetchUpcomingSessions() -> AnyPublisher<[LiveSessionData], Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let sessions = mockSessions.compactMap { id, data in
            LiveSessionData(from: data, id: id)
        }
        
        return Just(sessions).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Community Mocks
    
    func fetchCommunityPosts(limit: Int = 20) -> AnyPublisher<([CommunityPostData], DocumentSnapshot?), Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let posts = mockPosts.compactMap { id, data in
            CommunityPostData(from: data, id: id)
        }
        
        return Just((posts, nil)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func createPost(userId: String, content: String, tags: [String]) -> AnyPublisher<Void, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let postId = UUID().uuidString
        let data: [String: Any] = [
            "userId": userId,
            "content": content,
            "tags": tags,
            "timestamp": Date(),
            "likes": 0,
            "comments": 0
        ]
        
        mockPosts[postId] = data
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Subscription Mocks
    
    func fetchSubscriptionStatus(userId: String) -> AnyPublisher<SubscriptionData, Error> {
        if let error = shouldSimulateError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let activeSubscription = mockSubscriptions.first { sub in
            (sub["userId"] as? String) == userId &&
            (sub["status"] as? String) == "active"
        }
        
        if let data = activeSubscription {
            return Just(SubscriptionData(from: data)).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Just(SubscriptionData.free()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        mockUsers.removeAll()
        mockDailyQodes.removeAll()
        mockSessions.removeAll()
        mockPosts.removeAll()
        mockSubscriptions.removeAll()
        shouldSimulateError = nil
    }
    
    func addMockUser(id: String, data: [String: Any]) {
        mockUsers[id] = data
    }
    
    func addMockDailyQode(date: Date, data: [String: Any]) {
        let dateString = ISO8601DateFormatter().string(from: date)
        mockDailyQodes[dateString] = data
    }
}

// MARK: - Test Data Builders

struct FirebaseTestDataBuilder {
    static func makeUserProfileData(
        userId: String = UUID().uuidString,
        name: String = "Test User",
        email: String = "test@example.com"
    ) -> UserProfileData {
        return UserProfileData(
            userId: userId,
            name: name,
            email: email,
            birthDate: Date(),
            birthTime: nil,
            timezone: "UTC",
            lifePath: 5,
            createdAt: Date()
        )
    }
    
    static func makeMockUserDictionary(
        id: String,
        email: String = "test@example.com",
        name: String = "Test User",
        tier: String = "free"
    ) -> [String: Any] {
        return [
            "id": id,
            "email": email,
            "fullName": name,
            "birthDate": Date(),
            "membershipTier": tier,
            "createdAt": Date(),
            "lastActiveAt": Date()
        ]
    }
    
    static func makeMockDailyQodeDictionary(
        date: Date = Date(),
        universalDay: Int = 3,
        personalDay: Int = 5,
        title: String = "Test Qode"
    ) -> [String: Any] {
        return [
            "date": date,
            "universalDay": universalDay,
            "personalDay": personalDay,
            "title": title,
            "description": "Test description",
            "affirmation": "Test affirmation",
            "activities": ["Activity 1", "Activity 2"],
            "avoidances": ["Avoidance 1"]
        ]
    }
    
    static func makeMockSessionDictionary(
        id: String = UUID().uuidString,
        title: String = "Test Session",
        startTime: Date = Date().addingTimeInterval(3600)
    ) -> [String: Any] {
        return [
            "title": title,
            "description": "Test session description",
            "startTime": startTime,
            "duration": 60,
            "maxAttendees": 100,
            "registeredAttendees": 0,
            "isPremium": false,
            "type": "qa"
        ]
    }
    
    static func makeMockPostDictionary(
        id: String = UUID().uuidString,
        userId: String = "user-123",
        content: String = "Test post content"
    ) -> [String: Any] {
        return [
            "userId": userId,
            "content": content,
            "tags": ["test", "mock"],
            "timestamp": Date(),
            "likes": 0,
            "comments": 0
        ]
    }
    
    static func makeMockSubscriptionDictionary(
        userId: String = "user-123",
        tier: String = "seeker",
        status: String = "active"
    ) -> [String: Any] {
        return [
            "userId": userId,
            "tier": tier,
            "isYearly": false,
            "startDate": Date(),
            "renewalDate": Date().addingTimeInterval(30 * 24 * 3600),
            "status": status
        ]
    }
}

// MARK: - Firebase Service Tests

@Suite("Firebase Service CRUD Tests")
struct FirebaseServiceCRUDTests {
    let mockService = MockFirebaseService()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        mockService.reset()
    }
    
    // MARK: - Create Tests
    
    @Test("Create user profile succeeds")
    func testCreateUserProfile() async throws {
        let userId = UUID().uuidString
        let profile = FirebaseTestDataBuilder.makeUserProfileData(userId: userId)
        
        var success = false
        var error: Error?
        
        mockService.createUserProfile(userId: userId, profile: profile)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        // Wait a moment for async operation
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
        #expect(error == nil)
        #expect(mockService.mockUsers[userId] != nil)
    }
    
    @Test("Create user profile stores correct data")
    func testCreateUserProfileData() async throws {
        let userId = UUID().uuidString
        let profile = FirebaseTestDataBuilder.makeUserProfileData(
            userId: userId,
            name: "John Doe",
            email: "john@example.com"
        )
        
        mockService.createUserProfile(userId: userId, profile: profile)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let storedData = mockService.mockUsers[userId]
        #expect(storedData?["name"] as? String == "John Doe")
        #expect(storedData?["email"] as? String == "john@example.com")
    }
    
    // MARK: - Read Tests
    
    @Test("Fetch existing user profile succeeds")
    func testFetchExistingUserProfile() async throws {
        let userId = UUID().uuidString
        let mockData = FirebaseTestDataBuilder.makeMockUserDictionary(
            id: userId,
            name: "Jane Doe"
        )
        mockService.addMockUser(id: userId, data: mockData)
        
        var fetchedProfile: UserProfileData?
        var fetchError: Error?
        
        mockService.fetchUserProfile(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        fetchError = e
                    }
                },
                receiveValue: { profile in
                    fetchedProfile = profile
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(fetchedProfile != nil)
        #expect(fetchedProfile?.name == "Jane Doe")
        #expect(fetchError == nil)
    }
    
    @Test("Fetch non-existent user profile fails")
    func testFetchNonExistentUserProfile() async throws {
        let userId = UUID().uuidString
        
        var fetchError: Error?
        
        mockService.fetchUserProfile(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        fetchError = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(fetchError != nil)
    }
    
    // MARK: - Update Tests
    
    @Test("Update existing user profile succeeds")
    func testUpdateExistingUserProfile() async throws {
        let userId = UUID().uuidString
        let initialData = FirebaseTestDataBuilder.makeMockUserDictionary(
            id: userId,
            name: "Original Name"
        )
        mockService.addMockUser(id: userId, data: initialData)
        
        var success = false
        var error: Error?
        
        mockService.updateUserProfile(userId: userId, updates: ["fullName": "Updated Name"])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
        #expect(error == nil)
        #expect(mockService.mockUsers[userId]?["fullName"] as? String == "Updated Name")
    }
    
    @Test("Update non-existent user profile fails")
    func testUpdateNonExistentUserProfile() async throws {
        let userId = UUID().uuidString
        
        var error: Error?
        
        mockService.updateUserProfile(userId: userId, updates: ["fullName": "Name"])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error != nil)
    }
    
    // MARK: - Daily Qode Tests
    
    @Test("Fetch daily qode returns data")
    func testFetchDailyQode() async throws {
        let date = Date()
        let lifePath = 5
        
        var fetchedQode: DailyQodeData?
        var error: Error?
        
        mockService.fetchDailyQode(for: date, userLifePath: lifePath)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { qode in
                    fetchedQode = qode
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(fetchedQode != nil)
        #expect(fetchedQode?.lifePath == lifePath)
        #expect(error == nil)
    }
    
    @Test("Fetch daily qode returns default when not found")
    func testFetchDailyQodeDefault() async throws {
        let date = Date()
        let lifePath = 3
        
        var fetchedQode: DailyQodeData?
        
        mockService.fetchDailyQode(for: date, userLifePath: lifePath)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { qode in
                    fetchedQode = qode
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(fetchedQode != nil)
        #expect(!fetchedQode!.title.isEmpty)
    }
    
    // MARK: - Live Session Tests
    
    @Test("Fetch upcoming sessions returns empty array when none exist")
    func testFetchEmptySessions() async throws {
        var sessions: [LiveSessionData]?
        var error: Error?
        
        mockService.fetchUpcomingSessions()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { fetchedSessions in
                    sessions = fetchedSessions
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(sessions != nil)
        #expect(sessions!.isEmpty)
        #expect(error == nil)
    }
    
    // MARK: - Community Post Tests
    
    @Test("Create post succeeds")
    func testCreatePost() async throws {
        let userId = UUID().uuidString
        let content = "Test post content"
        let tags = ["test", "mock"]
        
        var success = false
        var error: Error?
        
        mockService.createPost(userId: userId, content: content, tags: tags)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
        #expect(error == nil)
        #expect(mockService.mockPosts.count == 1)
    }
    
    @Test("Fetch community posts returns posts")
    func testFetchCommunityPosts() async throws {
        // Add some mock posts
        let postId = UUID().uuidString
        let postData = FirebaseTestDataBuilder.makeMockPostDictionary(
            id: postId,
            content: "Test content"
        )
        mockService.mockPosts[postId] = postData
        
        var posts: [CommunityPostData]?
        var error: Error?
        
        mockService.fetchCommunityPosts()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { (fetchedPosts, _) in
                    posts = fetchedPosts
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(posts != nil)
        #expect(posts?.count == 1)
        #expect(error == nil)
    }
    
    // MARK: - Subscription Tests
    
    @Test("Fetch subscription status returns free tier for non-subscriber")
    func testFetchFreeSubscriptionStatus() async throws {
        let userId = UUID().uuidString
        
        var subscription: SubscriptionData?
        var error: Error?
        
        mockService.fetchSubscriptionStatus(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { sub in
                    subscription = sub
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(subscription != nil)
        #expect(subscription?.tier == "free")
        #expect(error == nil)
    }
    
    @Test("Fetch subscription status returns active subscription")
    func testFetchActiveSubscriptionStatus() async throws {
        let userId = UUID().uuidString
        let subData = FirebaseTestDataBuilder.makeMockSubscriptionDictionary(
            userId: userId,
            tier: "seeker",
            status: "active"
        )
        mockService.mockSubscriptions.append(subData)
        
        var subscription: SubscriptionData?
        
        mockService.fetchSubscriptionStatus(userId: userId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { sub in
                    subscription = sub
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(subscription?.tier == "seeker")
    }
}

// MARK: - Error Handling Tests

@Suite("Firebase Service Error Handling Tests")
struct FirebaseServiceErrorTests {
    let mockService = MockFirebaseService()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        mockService.reset()
    }
    
    @Test("Create user profile fails with network error")
    func testCreateUserNetworkError() async throws {
        mockService.shouldSimulateError = .networkError
        
        let profile = FirebaseTestDataBuilder.makeUserProfileData()
        var error: Error?
        
        mockService.createUserProfile(userId: "test", profile: profile)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error != nil)
    }
    
    @Test("Fetch user profile fails with document not found")
    func testFetchUserDocumentNotFound() async throws {
        mockService.shouldSimulateError = nil // Don't simulate error, just don't add user
        
        var error: Error?
        
        mockService.fetchUserProfile(userId: "non-existent")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error is MockFirebaseError)
    }
    
    @Test("Update user profile fails with permission denied")
    func testUpdateUserPermissionDenied() async throws {
        let userId = UUID().uuidString
        mockService.addMockUser(id: userId, data: ["name": "Test"])
        mockService.shouldSimulateError = .permissionDenied
        
        var error: Error?
        
        mockService.updateUserProfile(userId: userId, updates: [:])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error != nil)
    }
    
    @Test("Create post fails with invalid data")
    func testCreatePostInvalidData() async throws {
        mockService.shouldSimulateError = .invalidData
        
        var error: Error?
        
        mockService.createPost(userId: "test", content: "", tags: [])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error != nil)
    }
    
    @Test("Simulated unknown error")
    func testUnknownError() async throws {
        mockService.shouldSimulateError = .unknown
        
        let profile = FirebaseTestDataBuilder.makeUserProfileData()
        var error: Error?
        
        mockService.createUserProfile(userId: "test", profile: profile)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(error != nil)
    }
}

// MARK: - Edge Case Tests

@Suite("Firebase Service Edge Case Tests")
struct FirebaseServiceEdgeCaseTests {
    let mockService = MockFirebaseService()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        mockService.reset()
    }
    
    @Test("Create user with empty email")
    func testCreateUserWithEmptyEmail() async throws {
        let profile = UserProfileData(
            userId: "test",
            name: "Test",
            email: "",
            birthDate: Date(),
            birthTime: nil,
            timezone: "UTC",
            lifePath: 1,
            createdAt: Date()
        )
        
        var success = false
        
        mockService.createUserProfile(userId: "test", profile: profile)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
    }
    
    @Test("Update user with empty updates")
    func testUpdateUserWithEmptyUpdates() async throws {
        let userId = UUID().uuidString
        let initialData: [String: Any] = ["name": "Original"]
        mockService.addMockUser(id: userId, data: initialData)
        
        var success = false
        
        mockService.updateUserProfile(userId: userId, updates: [:])
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
    }
    
    @Test("Create post with long content")
    func testCreatePostWithLongContent() async throws {
        let longContent = String(repeating: "A", count: 10000)
        
        var success = false
        
        mockService.createPost(userId: "test", content: longContent, tags: [])
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
    }
    
    @Test("Create post with many tags")
    func testCreatePostWithManyTags() async throws {
        let manyTags = (1...50).map { "tag\($0)" }
        
        var success = false
        
        mockService.createPost(userId: "test", content: "Test", tags: manyTags)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    success = true
                }
            )
            .store(in: &cancellables)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(success == true)
    }
    
    @Test("Fetch daily qode with different life paths")
    func testFetchDailyQodeDifferentLifePaths() async throws {
        let date = Date()
        
        for lifePath in 1...9 {
            var fetchedQode: DailyQodeData?
            
            mockService.fetchDailyQode(for: date, userLifePath: lifePath)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { qode in
                        fetchedQode = qode
                    }
                )
                .store(in: &cancellables)
            
            try await Task.sleep(nanoseconds: 10_000_000)
            
            #expect(fetchedQode?.lifePath == lifePath)
        }
    }
}