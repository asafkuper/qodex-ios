//
//  ContentRecommendationEngine.swift
//  AI-powered content personalization
//

import Foundation
import FirebaseFirestore

class ContentRecommendationEngine {
    static let shared = ContentRecommendationEngine()
    private let db = Firestore.firestore()
    
    // MARK: - Recommendation Types
    enum ContentType {
        case dailyReading
        case teaching
        case meditation
        case communityPost
        case liveSession
        case mentor
    }
    
    struct Recommendation {
        let id: String
        let type: ContentType
        let title: String
        let description: String
        let relevanceScore: Double
        let reason: String
        let metadata: [String: Any]
    }
    
    // MARK: - Get Personalized Feed
    func getPersonalizedFeed(for user: QodeXUser, limit: Int = 10) async -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // 1. Numerology-based recommendations
        let numerologyRecs = await getNumerologyRecommendations(for: user)
        recommendations.append(contentsOf: numerologyRecs)
        
        // 2. Behavioral recommendations
        let behavioralRecs = await getBehavioralRecommendations(for: user)
        recommendations.append(contentsOf: behavioralRecs)
        
        // 3. Collaborative filtering
        let collaborativeRecs = await getCollaborativeRecommendations(for: user)
        recommendations.append(contentsOf: collaborativeRecs)
        
        // 4. Trending content
        let trendingRecs = await getTrendingContent()
        recommendations.append(contentsOf: trendingRecs)
        
        // Sort by relevance and deduplicate
        let uniqueRecs = Array(Dictionary(grouping: recommendations, by: \.id).values.compactMap { $0.first })
        return Array(uniqueRecs.sorted { $0.relevanceScore > $1.relevanceScore }.prefix(limit))
    }
    
    // MARK: - Numerology-Based Recommendations
    private func getNumerologyRecommendations(for user: QodeXUser) async -> [Recommendation] {
        guard let birthDate = user.birthDate else { return [] }
        
        let lifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
        let currentDay = NumerologyCalculator().calculateDailyNumber(for: Date())
        let personalYear = calculatePersonalYear(birthDate: birthDate)
        
        var recs: [Recommendation] = []
        
        // Life Path specific content
        let lifePathContent = await fetchContentForLifePath(lifePath)
        recs.append(contentsOf: lifePathContent)
        
        // Current day alignment
        if lifePath == currentDay {
            recs.append(Recommendation(
                id: "power_day_alert",
                type: .dailyReading,
                title: "🔥 Power Day Alert",
                description: "Today your Life Path and Daily Number align. Perfect for important decisions.",
                relevanceScore: 95,
                reason: "Numerological alignment",
                metadata: [:]
            ))
        }
        
        // Personal year guidance
        let yearContent = await fetchContentForPersonalYear(personalYear)
        recs.append(contentsOf: yearContent)
        
        return recs
    }
    
    // MARK: - Behavioral Recommendations
    private func getBehavioralRecommendations(for user: QodeXUser) async -> [Recommendation] {
        var recs: [Recommendation] = []
        
        // Get user's interaction history
        let interactions = await fetchUserInteractions(userId: user.id)
        
        // If user meditates frequently, recommend longer sessions
        if interactions.meditationCount > 10 {
            recs.append(Recommendation(
                id: "advanced_meditation",
                type: .meditation,
                title: "20-Minute Deep Dive",
                description: "Ready to deepen your practice?",
                relevanceScore: 85,
                reason: "Based on your meditation streak",
                metadata: [:]
            ))
        }
        
        // If user checks daily number but not full chart
        if interactions.dailyChecks > 7 && interactions.chartViews == 0 {
            recs.append(Recommendation(
                id: "unlock_full_chart",
                type: .dailyReading,
                title: "Your Complete Chart Awaits",
                description: "See all 9 of your core numbers",
                relevanceScore: 90,
                reason: "You love daily numbers—discover more",
                metadata: [:]
            ))
        }
        
        // Time-based recommendations
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 9 {
            recs.append(Recommendation(
                id: "morning_intention",
                type: .meditation,
                title: "Morning Intention Setting",
                description: "Start your day aligned with your numbers",
                relevanceScore: 88,
                reason: "Morning ritual opportunity",
                metadata: [:]
            ))
        }
        
        return recs
    }
    
    // MARK: - Collaborative Filtering
    private func getCollaborativeRecommendations(for user: QodeXUser) async -> [Recommendation] {
        // Find similar users based on numerology
        let similarUsers = await findSimilarUsers(to: user)
        
        // Get content they liked
        var recs: [Recommendation] = []
        for similarUser in similarUsers {
            let theirFavorites = await fetchUserFavorites(userId: similarUser.id)
            recs.append(contentsOf: theirFavorites)
        }
        
        return recs
    }
    
    // MARK: - Trending Content
    private func getTrendingContent() async -> [Recommendation] {
        let snapshot = try? await db.collection("content")
            .order(by: "engagementScore", descending: true)
            .limit(to: 5)
            .getDocuments()
        
        return snapshot?.documents.compactMap { doc in
            Recommendation(
                id: doc.documentID,
                type: .teaching,
                title: doc.data()["title"] as? String ?? "",
                description: doc.data()["description"] as? String ?? "",
                relevanceScore: Double(doc.data()["engagementScore"] as? Int ?? 0) / 100.0,
                reason: "Trending in the community",
                metadata: doc.data()
            )
        } ?? []
    }
    
    // MARK: - Helper Methods
    private func calculatePersonalYear(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let birthMonth = calendar.component(.month, from: birthDate)
        let birthDay = calendar.component(.day, from: birthDate)
        
        let yearNumber = String(currentYear).compactMap { $0.wholeNumberValue }.reduce(0, +)
        let monthNumber = birthMonth
        let dayNumber = birthDay
        
        let total = yearNumber + monthNumber + dayNumber
        return reduceToSingleDigit(total)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 {
            n = String(n).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return n
    }
    
    private func fetchContentForLifePath(_ lifePath: Int) async -> [Recommendation] {
        let snapshot = try? await db.collection("teachings")
            .whereField("lifePaths", arrayContains: lifePath)
            .limit(to: 3)
            .getDocuments()
        
        return snapshot?.documents.map { doc in
            Recommendation(
                id: doc.documentID,
                type: .teaching,
                title: doc.data()["title"] as? String ?? "",
                description: doc.data()["description"] as? String ?? "",
                relevanceScore: 80,
                reason: "Perfect for Life Path \(lifePath)",
                metadata: doc.data()
            )
        } ?? []
    }
    
    private func fetchContentForPersonalYear(_ year: Int) async -> [Recommendation] {
        // Fetch content specific to user's personal year
        return []
    }
    
    private func fetchUserInteractions(userId: String) async -> UserInteractions {
        let doc = try? await db.collection("user_analytics").document(userId).getDocument()
        let data = doc?.data() ?? [:]
        
        return UserInteractions(
            meditationCount: data["meditationCount"] as? Int ?? 0,
            dailyChecks: data["dailyChecks"] as? Int ?? 0,
            chartViews: data["chartViews"] as? Int ?? 0
        )
    }
    
    private func findSimilarUsers(to user: QodeXUser) async -> [QodeXUser] {
        // Find users with same/similar life path
        guard let birthDate = user.birthDate else { return [] }
        let lifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
        
        let snapshot = try? await db.collection("users")
            .whereField("lifePath", isEqualTo: lifePath)
            .limit(to: 5)
            .getDocuments()
        
        return snapshot?.documents.compactMap { QodeXUser(from: $0) } ?? []
    }
    
    private func fetchUserFavorites(userId: String) async -> [Recommendation] {
        // Fetch content this user has liked/saved
        return []
    }
}

// MARK: - Supporting Types
struct UserInteractions {
    let meditationCount: Int
    let dailyChecks: Int
    let chartViews: Int
}
