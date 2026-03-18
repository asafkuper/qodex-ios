//
//  CoreMLPredictions.swift
//  On-device machine learning for numerology insights
//

import CoreML
import Foundation

class CoreMLPredictions {
    static let shared = CoreMLPredictions()
    
    // MARK: - Prediction Models
    
    /// Predicts optimal times for user actions based on their numerology and history
    func predictOptimalTime(for activity: ActivityType, user: QodeXUser) async -> OptimalTimePrediction {
        let lifePath = calculateLifePath(user)
        let currentDay = NumerologyCalculator().calculateDailyNumber(for: Date())
        let personalYear = calculatePersonalYear(user)
        
        // Simulate ML model inference (would be actual CoreML model in production)
        let confidence: Double
        let recommendedHour: Int
        let reasoning: String
        
        switch activity {
        case .meditation:
            // Life Path 7s do best with morning meditation
            if lifePath == 7 {
                recommendedHour = 6
                confidence = 0.92
                reasoning = "Your Life Path 7 energy aligns with dawn contemplation"
            } else if lifePath == 8 {
                recommendedHour = 20
                confidence = 0.88
                reasoning = "Evening meditation helps you process power decisions"
            } else {
                recommendedHour = 7
                confidence = 0.75
                reasoning = "Morning meditation suits your numerological profile"
            }
            
        case .importantDecision:
            if currentDay == lifePath {
                recommendedHour = 12
                confidence = 0.95
                reasoning = "Today is your Power Day—make decisions at noon"
            } else {
                recommendedHour = 10
                confidence = 0.82
                reasoning = "Late morning clarity for important choices"
            }
            
        case .socializing:
            if lifePath == 3 || lifePath == 5 {
                recommendedHour = 19
                confidence = 0.89
                reasoning = "Evening social energy peaks for your creative/freedom path"
            } else {
                recommendedHour = 18
                confidence = 0.78
                reasoning = "Early evening for harmonious connections"
            }
            
        case .work:
            if lifePath == 1 || lifePath == 8 {
                recommendedHour = 9
                confidence = 0.91
                reasoning = "Early start maximizes your leadership/power energy"
            } else if lifePath == 4 {
                recommendedHour = 13
                confidence = 0.87
                reasoning = "Midday focus aligns with your builder nature"
            } else {
                recommendedHour = 10
                confidence = 0.80
                reasoning = "Mid-morning productivity window"
            }
        }
        
        return OptimalTimePrediction(
            recommendedHour: recommendedHour,
            confidence: confidence,
            reasoning: reasoning,
            alternativeHours: generateAlternatives(baseHour: recommendedHour),
            factorsConsidered: ["Life Path \(lifePath)", "Daily Number \(currentDay)", "Personal Year \(personalYear)"]
        )
    }
    
    /// Predicts potential challenges and opportunities for the day
    func predictDailyForecast(user: QodeXUser) async -> DailyForecast {
        let lifePath = calculateLifePath(user)
        let dailyNumber = NumerologyCalculator().calculateDailyNumber(for: Date())
        let compatibility = calculateCompatibility(lifePath: lifePath, dailyNumber: dailyNumber)
        
        var opportunities: [String] = []
        var challenges: [String] = []
        var focusAreas: [String] = []
        
        if compatibility >= 80 {
            opportunities.append("Power Day—major initiatives favored")
            focusAreas.append("Leadership")
        } else if compatibility >= 60 {
            opportunities.append("Steady progress on ongoing projects")
            focusAreas.append("Consistency")
        } else {
            challenges.append("Energy mismatch—take it slow")
            focusAreas.append("Rest")
        }
        
        // Life Path specific predictions
        switch lifePath {
        case 1:
            if dailyNumber == 1 {
                opportunities.append("Double 1 energy—start new ventures")
            }
        case 7:
            if dailyNumber == 7 {
                opportunities.append("Spiritual downloads likely—journal insights")
            }
        case 8:
            if dailyNumber == 8 {
                opportunities.append("Financial opportunities emerge")
            }
        default:
            break
        }
        
        return DailyForecast(
            overallScore: compatibility,
            opportunities: opportunities,
            challenges: challenges,
            focusAreas: focusAreas,
            luckyNumbers: generateLuckyNumbers(lifePath: lifePath, daily: dailyNumber),
            powerHours: generatePowerHours(lifePath: lifePath)
        )
    }
    
    /// Predicts relationship compatibility using ML
    func predictRelationshipCompatibility(person1: QodeXUser, person2: QodeXUser) async -> RelationshipPrediction {
        let lp1 = calculateLifePath(person1)
        let lp2 = calculateLifePath(person2)
        
        // Traditional numerology compatibility
        let traditionalScore = calculateTraditionalCompatibility(lp1: lp1, lp2: lp2)
        
        // Enhanced with "ML" (simulated patterns)
        var enhancedScore = traditionalScore
        var insights: [String] = []
        
        // Pattern recognition
        if lp1 + lp2 == 11 || lp1 + lp2 == 22 {
            enhancedScore += 10
            insights.append("Master number potential in your union")
        }
        
        if abs(lp1 - lp2) == 1 {
            enhancedScore += 5
            insights.append("Sequential numbers suggest natural flow")
        }
        
        if lp1 == lp2 {
            insights.append("Same Life Path—deep understanding but potential competition")
        }
        
        // Cap at 100
        enhancedScore = min(enhancedScore, 100)
        
        return RelationshipPrediction(
            overallScore: enhancedScore,
            romanceScore: calculateRomanceScore(lp1: lp1, lp2: lp2),
            friendshipScore: calculateFriendshipScore(lp1: lp1, lp2: lp2),
            businessScore: calculateBusinessScore(lp1: lp1, lp2: lp2),
            strengths: generateStrengths(lp1: lp1, lp2: lp2),
            challenges: generateChallenges(lp1: lp1, lp2: lp2),
            insights: insights
        )
    }
    
    // MARK: - Private Helpers
    
    private func calculateLifePath(_ user: QodeXUser) -> Int {
        guard let birthDate = user.birthDate else { return 7 }
        return NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
    
    private func calculatePersonalYear(_ user: QodeXUser) -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let birthMonth = calendar.component(.month, from: user.birthDate ?? Date())
        let birthDay = calendar.component(.day, from: user.birthDate ?? Date())
        
        let sum = String(currentYear).compactMap { $0.wholeNumberValue }.reduce(0, +)
            + birthMonth + birthDay
        
        var result = sum
        while result > 9 {
            result = String(result).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return result
    }
    
    private func calculateCompatibility(lifePath: Int, dailyNumber: Int) -> Double {
        if lifePath == dailyNumber {
            return 95.0 // Power day
        }
        
        let diff = abs(lifePath - dailyNumber)
        return max(40.0, 100.0 - Double(diff) * 8.0)
    }
    
    private func generateAlternatives(baseHour: Int) -> [Int] {
        return [baseHour - 1, baseHour + 1, baseHour + 2].filter { $0 >= 0 && $0 <= 23 }
    }
    
    private func generateLuckyNumbers(lifePath: Int, daily: Int) -> [Int] {
        var numbers = [lifePath, daily]
        numbers.append((lifePath + daily) % 9 + 1)
        numbers.append(abs(lifePath - daily) + 1)
        return Array(Set(numbers)).sorted()
    }
    
    private func generatePowerHours(lifePath: Int) -> [Int] {
        switch lifePath {
        case 1: return [6, 12, 18]
        case 2: return [7, 14, 20]
        case 3: return [9, 15, 21]
        case 4: return [5, 13, 19]
        case 5: return [10, 16, 22]
        case 6: return [8, 14, 19]
        case 7: return [6, 15, 23]
        case 8: return [7, 13, 20]
        case 9: return [9, 18, 21]
        default: return [9, 12, 18]
        }
    }
    
    private func calculateTraditionalCompatibility(lp1: Int, lp2: Int) -> Double {
        let compatiblePairs: [(Int, Int)] = [
            (1, 5), (1, 7), (1, 9),
            (2, 4), (2, 6), (2, 8),
            (3, 6), (3, 9),
            (4, 8),
            (5, 7)
        ]
        
        if compatiblePairs.contains(where: { ($0 == lp1 && $1 == lp2) || ($0 == lp2 && $1 == lp1) }) {
            return 85.0
        }
        
        if lp1 == lp2 {
            return 75.0
        }
        
        return 60.0
    }
    
    private func calculateRomanceScore(lp1: Int, lp2: Int) -> Double {
        // 2, 6, 9 are romance numbers
        let romanceNumbers = [2, 6, 9]
        var score = 50.0
        if romanceNumbers.contains(lp1) { score += 15 }
        if romanceNumbers.contains(lp2) { score += 15 }
        return min(score, 100)
    }
    
    private func calculateFriendshipScore(lp1: Int, lp2: Int) -> Double {
        // 3, 5, 7 are social numbers
        let socialNumbers = [3, 5, 7]
        var score = 50.0
        if socialNumbers.contains(lp1) { score += 15 }
        if socialNumbers.contains(lp2) { score += 15 }
        return min(score, 100)
    }
    
    private func calculateBusinessScore(lp1: Int, lp2: Int) -> Double {
        // 1, 4, 8 are business numbers
        let businessNumbers = [1, 4, 8]
        var score = 50.0
        if businessNumbers.contains(lp1) { score += 15 }
        if businessNumbers.contains(lp2) { score += 15 }
        return min(score, 100)
    }
    
    private func generateStrengths(lp1: Int, lp2: Int) -> [String] {
        return ["Complementary energies", "Growth potential", "Learning opportunities"]
    }
    
    private func generateChallenges(lp1: Int, lp2: Int) -> [String] {
        if lp1 == lp2 {
            return ["Similar blind spots", "Potential competition"]
        }
        return ["Different communication styles", "Varying pace of action"]
    }
}

// MARK: - Supporting Types

enum ActivityType {
    case meditation
    case importantDecision
    case socializing
    case work
}

struct OptimalTimePrediction {
    let recommendedHour: Int
    let confidence: Double
    let reasoning: String
    let alternativeHours: [Int]
    let factorsConsidered: [String]
}

struct DailyForecast {
    let overallScore: Double
    let opportunities: [String]
    let challenges: [String]
    let focusAreas: [String]
    let luckyNumbers: [Int]
    let powerHours: [Int]
}

struct RelationshipPrediction {
    let overallScore: Double
    let romanceScore: Double
    let friendshipScore: Double
    let businessScore: Double
    let strengths: [String]
    let challenges: [String]
    let insights: [String]
}
