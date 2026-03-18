import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - Firebase Service Protocol
protocol FirebaseServiceProtocol {
    // User Management
    func fetchUserProfile(userId: String) async throws -> UserProfileData
    func saveUserProfile(_ profile: UserProfileData) async throws
    func updateUserProfile(userId: String, updates: [String: Any]) async throws
    
    // Daily Qodes
    func fetchDailyQode(for date: Date, lifePath: Int) async throws -> DailyQodeData
    func markQodeAsRead(userId: String, date: Date) async throws
    
    // Live Sessions
    func fetchUpcomingSessions() async throws -> [LiveSessionData]
    func registerForSession(userId: String, sessionId: String) async throws
    
    // Community
    func fetchCommunityPosts(limit: Int, lastDocument: String?) async throws -> ([CommunityPostData], String?)
    func createPost(userId: String, content: String, tags: [String]) async throws
    func likePost(userId: String, postId: String) async throws
    
    // Subscriptions
    func fetchSubscriptionStatus(userId: String) async throws -> SubscriptionData
    func recordSubscription(userId: String, tier: String, isYearly: Bool, transactionId: String) async throws
    
    // Analytics
    func trackEvent(userId: String, event: String, parameters: [String: Any]) async throws
}

// MARK: - Firebase Service Manager
class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) -> AppError {
        if let error = error as? FirebaseError {
            return .firebase(error)
        }
        
        let nsError = error as NSError
        switch nsError.domain {
        case FirestoreErrorDomain:
            switch nsError.code {
            case FirestoreErrorCode.permissionDenied.rawValue:
                return .firebase(.permissionDenied)
            case FirestoreErrorCode.notFound.rawValue:
                return .firebase(.documentNotFound)
            case FirestoreErrorCode.unavailable.rawValue:
                return .network(.serverError(statusCode: 503))
            case FirestoreErrorCode.resourceExhausted.rawValue:
                return .firebase(.quotaExceeded)
            default:
                return .firebase(.writeFailed)
            }
        default:
            return .unknown(error)
        }
    }
    
    // MARK: - Retry Configuration
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 1.0
    
    // MARK: - User Management
    func createUserProfile(userId: String, profile: UserProfileData) -> AnyPublisher<Void, AppError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.firebase(.writeFailed)))
                return
            }
            
            self.db.collection("users").document(userId).setData(profile.toDictionary()) { error in
                if let error = error {
                    promise(.failure(self.handleError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchUserProfile(userId: String) async throws -> UserProfileData {
        return try await withRetry {
            let document = try await self.db.collection("users").document(userId).getDocument()
            
            guard document.exists else {
                throw FirebaseError.documentNotFound
            }
            
            guard let data = document.data() else {
                throw FirebaseError.invalidData
            }
            
            return UserProfileData(from: data)
        }
    }
    
    func saveUserProfile(_ profile: UserProfileData) async throws {
        try await withRetry {
            try await self.db.collection("users").document(profile.userId).setData(
                profile.toDictionary(),
                merge: true
            )
        }
    }
    
    func updateUserProfile(userId: String, updates: [String: Any]) -> AnyPublisher<Void, AppError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.firebase(.writeFailed)))
                return
            }
            
            self.db.collection("users").document(userId).updateData(updates) { error in
                if let error = error {
                    promise(.failure(self.handleError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Daily Qodes
    func fetchDailyQode(for date: Date, lifePath: Int) async throws -> DailyQodeData {
        return try await withRetry {
            let dateString = date.formatted(.iso8601)
            
            let document = try await self.db.collection("daily_qodes")
                .document(dateString)
                .getDocument()
            
            if let data = document.data() {
                return DailyQodeData(from: data, lifePath: lifePath)
            } else {
                // Generate default if not found
                return self.generateDefaultQode(for: date, lifePath: lifePath)
            }
        }
    }
    
    func markQodeAsRead(userId: String, date: Date) async throws {
        let data: [String: Any] = [
            "userId": userId,
            "date": Timestamp(date: date),
            "readAt": Timestamp(date: Date()),
            "streakUpdated": true
        ]
        
        try await withRetry {
            _ = try await self.db.collection("qode_reads").addDocument(data: data)
        }
    }
    
    // MARK: - Live Sessions
    func fetchUpcomingSessions() async throws -> [LiveSessionData] {
        return try await withRetry {
            let now = Timestamp(date: Date())
            
            let snapshot = try await self.db.collection("live_sessions")
                .whereField("startTime", isGreaterThan: now)
                .order(by: "startTime")
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                LiveSessionData(from: doc.data(), id: doc.documentID)
            }
        }
    }
    
    func registerForSession(userId: String, sessionId: String) async throws {
        let registrationData: [String: Any] = [
            "userId": userId,
            "sessionId": sessionId,
            "registeredAt": Timestamp(date: Date()),
            "attended": false
        ]
        
        try await withRetry {
            _ = try await self.db.collection("session_registrations").addDocument(data: registrationData)
            
            // Increment attendee count
            try await self.db.collection("live_sessions").document(sessionId)
                .updateData(["registeredAttendees": FieldValue.increment(Int64(1))])
        }
    }
    
    // MARK: - Community
    func fetchCommunityPosts(limit: Int = 20, lastDocument: DocumentSnapshot? = nil) -> AnyPublisher<([CommunityPostData], DocumentSnapshot?), AppError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.firebase(.writeFailed)))
                return
            }
            
            var query = self.db.collection("community_posts")
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
            
            if let lastDoc = lastDocument {
                query = query.start(afterDocument: lastDoc)
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(self.handleError(error)))
                } else {
                    let posts = snapshot?.documents.compactMap { doc -> CommunityPostData? in
                        CommunityPostData(from: doc.data(), id: doc.documentID)
                    } ?? []
                    
                    let lastDoc = snapshot?.documents.last
                    promise(.success((posts, lastDoc)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func createPost(userId: String, content: String, tags: [String]) async throws {
        let data: [String: Any] = [
            "userId": userId,
            "content": content,
            "tags": tags,
            "timestamp": Timestamp(date: Date()),
            "likes": 0,
            "comments": 0
        ]
        
        try await withRetry {
            _ = try await self.db.collection("community_posts").addDocument(data: data)
        }
    }
    
    func likePost(userId: String, postId: String) async throws {
        let likeId = "\(userId)_\(postId)"
        let data: [String: Any] = [
            "userId": userId,
            "postId": postId,
            "timestamp": Timestamp(date: Date())
        ]
        
        try await withRetry {
            try await self.db.collection("post_likes").document(likeId).setData(data)
            
            // Increment like count
            try await self.db.collection("community_posts").document(postId)
                .updateData(["likes": FieldValue.increment(Int64(1))])
        }
    }
    
    // MARK: - Subscriptions
    func fetchSubscriptionStatus(userId: String) async throws -> SubscriptionData {
        return try await withRetry {
            let snapshot = try await self.db.collection("subscriptions")
                .whereField("userId", isEqualTo: userId)
                .whereField("status", isEqualTo: "active")
                .getDocuments()
            
            if let doc = snapshot.documents.first {
                return SubscriptionData(from: doc.data())
            } else {
                return SubscriptionData.free()
            }
        }
    }
    
    func recordSubscription(userId: String, tier: String, isYearly: Bool, transactionId: String) async throws {
        let data: [String: Any] = [
            "userId": userId,
            "tier": tier,
            "isYearly": isYearly,
            "transactionId": transactionId,
            "startDate": Timestamp(date: Date()),
            "status": "active"
        ]
        
        try await withRetry {
            _ = try await self.db.collection("subscriptions").addDocument(data: data)
        }
    }
    
    // MARK: - Analytics
    func trackEvent(userId: String, event: String, parameters: [String: Any] = [:]) {
        let data: [String: Any] = [
            "userId": userId,
            "event": event,
            "parameters": parameters,
            "timestamp": Timestamp(date: Date()),
            "sessionId": SessionManager.shared.currentSessionId
        ]
        
        // Fire and forget - don't block for analytics
        db.collection("analytics_events").addDocument(data: data) { error in
            if let error = error {
                print("[ANALYTICS] Failed to track event: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generateDefaultQode(for date: Date, lifePath: Int) -> DailyQodeData {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let universalDay = calculateUniversalDay(day: day, month: month, year: year)
        let personalDay = calculatePersonalDay(universalDay: universalDay, lifePath: lifePath)
        
        return DailyQodeData(
            date: date,
            universalDay: universalDay,
            personalDay: personalDay,
            lifePath: lifePath,
            title: QodeLibrary.titles[personalDay] ?? "Day of Discovery",
            description: QodeLibrary.descriptions[personalDay] ?? "A day for new experiences.",
            affirmation: QodeLibrary.affirmations[personalDay] ?? "I embrace the day with openness.",
            activities: QodeLibrary.activities[personalDay] ?? [],
            avoidances: QodeLibrary.avoidances[personalDay] ?? []
        )
    }
    
    private func calculateUniversalDay(day: Int, month: Int, year: Int) -> Int {
        let sum = day + month + (year % 100) + (year / 100)
        return reduceToSingleDigit(sum)
    }
    
    private func calculatePersonalDay(universalDay: Int, lifePath: Int) -> Int {
        let sum = universalDay + lifePath
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 {
            n = String(n).compactMap { Int(String($0)) }.reduce(0, +)
        }
        return n == 0 ? 9 : n
    }
    
    // MARK: - Retry Helper
    private func withRetry<T>(
        maxAttempts: Int = 3,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                let isLastAttempt = attempt == maxAttempts - 1
                if isLastAttempt {
                    throw handleError(error)
                }
                
                // Exponential backoff
                let delay = baseDelay * pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw handleError(lastError ?? NSError(domain: "FirebaseService", code: -1))
    }
}

// MARK: - Session Manager
class SessionManager {
    static let shared = SessionManager()
    let currentSessionId = UUID().uuidString
}

// MARK: - Qode Library
struct QodeLibrary {
    static let titles: [Int: String] = [
        1: "Day of New Beginnings",
        2: "Day of Partnership",
        3: "Day of Creativity",
        4: "Day of Foundation",
        5: "Day of Change",
        6: "Day of Harmony",
        7: "Day of Wisdom",
        8: "Day of Power",
        9: "Day of Completion"
    ]
    
    static let descriptions: [Int: String] = [
        1: "Today carries the energy of initiation and leadership. It's a perfect day to start new projects and take decisive action.",
        2: "Cooperation and diplomacy are highlighted today. Focus on relationships and finding balance in partnerships.",
        3: "Creative energy flows freely today. Express yourself through art, writing, or any form of creative communication.",
        4: "Build solid foundations today. Focus on organization, planning, and creating lasting structures in your life.",
        5: "Change is in the air. Embrace flexibility and be open to new experiences and unexpected opportunities.",
        6: "Nurture yourself and others today. Focus on home, family, and creating beauty in your environment.",
        7: "Go within today. Research, analysis, and spiritual pursuits are favored. Trust your intuition.",
        8: "Abundance and achievement are today's themes. Focus on business, finances, and manifesting your goals.",
        9: "A day of completion and letting go. Release what no longer serves you and prepare for new cycles."
    ]
    
    static let affirmations: [Int: String] = [
        1: "I am a confident leader and creator.",
        2: "I create harmonious relationships with ease.",
        3: "My creativity flows freely and joyfully.",
        4: "I build solid foundations for my dreams.",
        5: "I embrace change with courage and excitement.",
        6: "I nurture myself and others with love.",
        7: "I trust my inner wisdom and intuition.",
        8: "I am abundant and successful in all I do.",
        9: "I release the old and welcome the new."
    ]
    
    static let activities: [Int: [String]] = [
        1: ["Start new projects", "Take initiative", "Make decisions", "Exercise leadership"],
        2: ["Collaborate with others", "Seek harmony", "Practice diplomacy", "Listen actively"],
        3: ["Create art", "Write", "Socialize", "Express yourself"],
        4: ["Organize", "Plan", "Build", "Establish routines"],
        5: ["Try something new", "Travel", "Be spontaneous", "Adapt to change"],
        6: ["Spend time with family", "Decorate", "Cook", "Care for others"],
        7: ["Meditate", "Research", "Study", "Spend time alone"],
        8: ["Work on goals", "Manage finances", "Network", "Take charge"],
        9: ["Complete tasks", "Release clutter", "Forgive", "Prepare for new beginnings"]
    ]
    
    static let avoidances: [Int: [String]] = [
        1: ["Procrastination", "Following others", "Indecision"],
        2: ["Conflict", "Isolation", "Harsh words"],
        3: ["Boredom", "Routine", "Suppressing expression"],
        4: ["Chaos", "Shortcuts", "Disorganization"],
        5: ["Rigidity", "Staying stuck", "Fear of change"],
        6: ["Neglecting family", "Harsh criticism", "Perfectionism"],
        7: ["Superficiality", "Over-socializing", "Ignoring intuition"],
        8: ["Laziness", "Poor financial decisions", "Giving up"],
        9: ["Starting new things", "Holding on", "Resisting closure"]
    ]
}
