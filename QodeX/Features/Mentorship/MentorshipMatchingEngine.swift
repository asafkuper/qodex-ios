//
//  MentorshipMatchingEngine.swift
//  AI-powered mentor-mentee matching
//

import Foundation
import FirebaseFirestore

class MentorshipMatchingEngine {
    static let shared = MentorshipMatchingEngine()
    private let db = Firestore.firestore()
    
    // MARK: - Compatibility Factors
    struct CompatibilityScore {
        let overall: Double // 0-100
        let lifePathMatch: Double
        let goalsAlignment: Double
        let experienceGap: Double
        let communicationStyle: Double
        let timezoneCompatibility: Double
        
        var isStrongMatch: Bool {
            return overall >= 75
        }
    }
    
    // MARK: - Find Mentors
    func findMentors(for mentee: QodeXUser, limit: Int = 5) async throws -> [MentorMatch] {
        // Get all available mentors
        let mentorsQuery = db.collection("users")
            .whereField("isMentor", isEqualTo: true)
            .whereField("mentorshipAvailable", isEqualTo: true)
            .limit(to: 50)
        
        let snapshot = try await mentorsQuery.getDocuments()
        var matches: [MentorMatch] = []
        
        for document in snapshot.documents {
            guard let mentor = QodeXUser(from: document) else { continue }
            
            // Skip if same user
            if mentor.id == mentee.id { continue }
            
            // Calculate compatibility
            let score = calculateCompatibility(mentee: mentee, mentor: mentor)
            
            if score.isStrongMatch {
                matches.append(MentorMatch(
                    mentor: mentor,
                    score: score,
                    matchReasons: generateMatchReasons(score: score, mentee: mentee, mentor: mentor)
                ))
            }
        }
        
        // Sort by score and return top matches
        return matches.sorted { $0.score.overall > $1.score.overall }.prefix(limit).map { $0 }
    }
    
    // MARK: - Calculate Compatibility
    private func calculateCompatibility(mentee: QodeXUser, mentor: QodeXUser) -> CompatibilityScore {
        // Life Path compatibility
        let menteeLifePath = calculateLifePath(mentee)
        let mentorLifePath = calculateLifePath(mentor)
        let lifePathMatch = calculateLifePathCompatibility(mentee: menteeLifePath, mentor: mentorLifePath)
        
        // Experience gap (mentor should be 2+ levels ahead)
        let experienceGap = calculateExperienceGap(mentee: mentee, mentor: mentor)
        
        // Communication style match
        let communicationStyle = calculateCommunicationCompatibility(mentee: mentee, mentor: mentor)
        
        // Timezone compatibility
        let timezoneCompatibility = calculateTimezoneCompatibility(mentee: mentee, mentor: mentor)
        
        // Goals alignment
        let goalsAlignment = calculateGoalsAlignment(mentee: mentee, mentor: mentor)
        
        // Weighted overall score
        let overall = (
            lifePathMatch * 0.30 +
            goalsAlignment * 0.25 +
            experienceGap * 0.20 +
            communicationStyle * 0.15 +
            timezoneCompatibility * 0.10
        )
        
        return CompatibilityScore(
            overall: overall,
            lifePathMatch: lifePathMatch,
            goalsAlignment: goalsAlignment,
            experienceGap: experienceGap,
            communicationStyle: communicationStyle,
            timezoneCompatibility: timezoneCompatibility
        )
    }
    
    // MARK: - Compatibility Algorithms
    private func calculateLifePathCompatibility(mentee: Int, mentor: Int) -> Double {
        // Based on numerology compatibility research
        let compatiblePairs: [(Int, Int)] = [
            (1, 5), (1, 7), (1, 9),
            (2, 4), (2, 6), (2, 8),
            (3, 6), (3, 9),
            (4, 8),
            (5, 7),
            (6, 9),
            (1, 1), (2, 2), (3, 3) // Same numbers can work
        ]
        
        if compatiblePairs.contains(where: { ($0 == mentee && $1 == mentor) || ($0 == mentor && $1 == mentee) }) {
            return 90 + Double.random(in: 0...10)
        }
        
        // Calculate difference
        let diff = abs(mentee - mentor)
        return max(40, 100 - Double(diff) * 10)
    }
    
    private func calculateExperienceGap(mentee: QodeXUser, mentor: QodeXUser) -> Double {
        let menteeLevel = experienceLevel(for: mentee)
        let mentorLevel = experienceLevel(for: mentor)
        
        let gap = mentorLevel - menteeLevel
        
        // Optimal gap is 2-4 levels
        if gap >= 2 && gap <= 4 {
            return 95
        } else if gap > 4 {
            return max(60, 100 - Double(gap - 4) * 5)
        } else {
            return max(40, Double(gap) * 20)
        }
    }
    
    private func experienceLevel(for user: QodeXUser) -> Int {
        var level = 0
        
        // Membership tier contribution
        switch user.membershipTier {
        case .free: level += 1
        case .seeker: level += 3
        case .initiate: level += 5
        case .master: level += 7
        }
        
        // Blueprint completion
        level += Int(user.blueprintCompletion / 15)
        
        // Streak
        if let streak = user.streakData {
            level += streak.currentStreak / 10
        }
        
        return level
    }
    
    private func calculateCommunicationCompatibility(mentee: QodeXUser, mentor: QodeXUser) -> Double {
        // This would use personality data if available
        // For now, return high compatibility as default
        return 80 + Double.random(in: 0...20)
    }
    
    private func calculateTimezoneCompatibility(mentee: QodeXUser, mentor: QodeXUser) -> Double {
        guard let menteeTZ = TimeZone(identifier: mentee.timezone),
              let mentorTZ = TimeZone(identifier: mentor.timezone) else {
            return 50
        }
        
        let offsetDiff = abs(menteeTZ.secondsFromGMT() - mentorTZ.secondsFromGMT())
        let hourDiff = offsetDiff / 3600
        
        // Within 3 hours is ideal
        if hourDiff <= 3 {
            return 95
        } else if hourDiff <= 6 {
            return 75
        } else if hourDiff <= 9 {
            return 55
        } else {
            return 40
        }
    }
    
    private func calculateGoalsAlignment(mentee: QodeXUser, mentor: QodeXUser) -> Double {
        // This would compare user goals from profile
        // For now, use membership tier as proxy for goal alignment
        if mentee.membershipTier == mentor.membershipTier {
            return 85
        }
        return 70 + Double.random(in: 0...20)
    }
    
    // MARK: - Generate Match Reasons
    private func generateMatchReasons(score: CompatibilityScore, mentee: QodeXUser, mentor: QodeXUser) -> [String] {
        var reasons: [String] = []
        
        if score.lifePathMatch >= 85 {
            reasons.append("Life path numerology harmony")
        }
        
        if score.experienceGap >= 80 {
            reasons.append("Optimal experience gap for growth")
        }
        
        if score.timezoneCompatibility >= 80 {
            reasons.append("Compatible scheduling")
        }
        
        if score.goalsAlignment >= 75 {
            reasons.append("Aligned spiritual goals")
        }
        
        if reasons.isEmpty {
            reasons.append("Strong overall compatibility")
        }
        
        return reasons
    }
    
    // MARK: - Request Mentorship
    func requestMentorship(mentee: QodeXUser, mentor: QodeXUser, message: String) async throws {
        let requestData: [String: Any] = [
            "menteeId": mentee.id,
            "mentorId": mentor.id,
            "message": message,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
            "compatibilityScore": calculateCompatibility(mentee: mentee, mentor: mentor).overall
        ]
        
        try await db.collection("mentorship_requests").addDocument(data: requestData)
        
        // Send notification to mentor
        // This would trigger a Cloud Function
    }
    
    // MARK: - Helper
    private func calculateLifePath(_ user: QodeXUser) -> Int {
        guard let birthDate = user.birthDate else { return 7 }
        return NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
}

// MARK: - Models
struct MentorMatch: Identifiable {
    let id = UUID()
    let mentor: QodeXUser
    let score: MentorshipMatchingEngine.CompatibilityScore
    let matchReasons: [String]
}

struct MentorshipSession: Identifiable {
    let id: String
    let mentorId: String
    let menteeId: String
    let scheduledDate: Date
    let duration: Int // minutes
    let topic: String
    let status: SessionStatus
    
    enum SessionStatus: String {
        case scheduled
        case inProgress
        case completed
        case cancelled
    }
}
