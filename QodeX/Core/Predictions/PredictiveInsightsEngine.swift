//
//  PredictiveInsightsEngine.swift
//  AI-powered future predictions based on numerology patterns
//

import Foundation
import CoreML

class PredictiveInsightsEngine {
    static let shared = PredictiveInsightsEngine()
    
    private let calculator = NumerologyCalculator()
    
    // MARK: - Predict Next 30 Days
    func predictNext30Days(user: QodeXUser) -> [DailyPrediction] {
        guard let birthDate = user.birthDate else { return [] }
        
        var predictions: [DailyPrediction] = []
        let calendar = Calendar.current
        
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            
            let dailyNumber = calculator.calculateDailyNumber(for: date)
            let personalDay = calculator.calculatePersonalDay(birthDate: birthDate, for: date)
            let lifePath = calculator.calculateLifePathNumber(birthDate: birthDate)
            
            let prediction = generatePrediction(
                date: date,
                dailyNumber: dailyNumber,
                personalDay: personalDay,
                lifePath: lifePath,
                user: user
            )
            
            predictions.append(prediction)
        }
        
        return predictions
    }
    
    // MARK: - Generate Daily Prediction
    private func generatePrediction(
        date: Date,
        dailyNumber: Int,
        personalDay: Int,
        lifePath: Int,
        user: QodeXUser
    ) -> DailyPrediction {
        
        // Calculate compatibility between numbers
        let numberAlignment = calculateAlignment(dailyNumber, personalDay, lifePath)
        
        // Determine power level
        let powerLevel: PowerLevel
        if numberAlignment >= 90 {
            powerLevel = .powerDay
        } else if numberAlignment >= 70 {
            powerLevel = .favorable
        } else if numberAlignment >= 50 {
            powerLevel = .neutral
        } else {
            powerLevel = .challenging
        }
        
        // Generate specific insights
        let insights = generateInsights(
            dailyNumber: dailyNumber,
            personalDay: personalDay,
            lifePath: lifePath,
            powerLevel: powerLevel
        )
        
        // Determine best activities
        let activities = recommendActivities(
            dailyNumber: dailyNumber,
            powerLevel: powerLevel,
            user: user
        )
        
        // Calculate lucky hours
        let luckyHours = calculateLuckyHours(
            dailyNumber: dailyNumber,
            lifePath: lifePath
        )
        
        return DailyPrediction(
            date: date,
            dailyNumber: dailyNumber,
            personalDay: personalDay,
            powerLevel: powerLevel,
            alignmentScore: numberAlignment,
            insights: insights,
            recommendedActivities: activities,
            luckyHours: luckyHours,
            color: luckyColor(for: dailyNumber),
            gemstone: luckyGemstone(for: dailyNumber)
        )
    }
    
    // MARK: - Alignment Calculation
    private func calculateAlignment(_ daily: Int, _ personal: Int, _ lifePath: Int) -> Int {
        var score = 50 // Base score
        
        // Daily matches life path (power day)
        if daily == lifePath {
            score += 40
        }
        
        // Personal day matches life path
        if personal == lifePath {
            score += 20
        }
        
        // All three align (rare power day)
        if daily == personal && personal == lifePath {
            score += 20
        }
        
        // Compatible numbers
        let compatiblePairs = [(1,5), (1,7), (2,4), (3,6), (4,8), (5,7)]
        for (a, b) in compatiblePairs {
            if (daily == a && lifePath == b) || (daily == b && lifePath == a) {
                score += 15
            }
        }
        
        return min(score, 100)
    }
    
    // MARK: - Insight Generation
    private func generateInsights(
        dailyNumber: Int,
        personalDay: Int,
        lifePath: Int,
        powerLevel: PowerLevel
    ) -> [String] {
        var insights: [String] = []
        
        // Power day insights
        if powerLevel == .powerDay {
            insights.append("🌟 POWER DAY: Your Daily Number and Life Path align perfectly")
            insights.append("Major decisions favored. Take initiative on important matters.")
        }
        
        // Daily number specific
        let dailyInsights: [Int: [String]] = [
            1: ["Leadership energy strong", "Start new projects", "Take decisive action"],
            2: ["Partnership opportunities", "Diplomacy favored", "Collaborate with others"],
            3: ["Creativity peaks", "Express yourself", "Social connections highlighted"],
            4: ["Build foundations", "Organize and plan", "Attention to detail pays off"],
            5: ["Change and freedom", "Be adaptable", "Travel or exploration favored"],
            6: ["Home and family focus", "Nurturing energy", "Responsibilities call"],
            7: ["Spiritual insights", "Introspection valuable", "Research and analysis"],
            8: ["Financial opportunities", "Career advancement", "Executive decisions"],
            9: ["Completion and release", "Humanitarian acts", "Let go of what no longer serves"]
        ]
        
        if let specific = dailyInsights[dailyNumber] {
            insights.append(contentsOf: specific.prefix(2))
        }
        
        // Personal day insight
        let personalDayVibes = ["", "new beginnings", "partnership", "creativity", "foundation", "freedom", "harmony", "spirituality", "abundance", "completion"]
        insights.append("Personal Day theme: \(personalDayVibes[personalDay] ?? "growth")")
        
        return insights
    }
    
    // MARK: - Activity Recommendations
    private func recommendActivities(
        dailyNumber: Int,
        powerLevel: PowerLevel,
        user: QodeXUser
    ) -> [RecommendedActivity] {
        var activities: [RecommendedActivity] = []
        
        let activityDatabase: [Int: [RecommendedActivity]] = [
            1: [
                RecommendedActivity(name: "Start new project", icon: "rocket.fill", priority: .high),
                RecommendedActivity(name: "Make important decisions", icon: "checkmark.seal.fill", priority: .high),
                RecommendedActivity(name: "Lead a meeting", icon: "person.3.fill", priority: .medium)
            ],
            2: [
                RecommendedActivity(name: "Have a heart-to-heart", icon: "heart.fill", priority: .high),
                RecommendedActivity(name: "Collaborate", icon: "person.2.fill", priority: .high),
                RecommendedActivity(name: "Meditate on balance", icon: "sparkles", priority: .medium)
            ],
            7: [
                RecommendedActivity(name: "Journal your thoughts", icon: "pencil", priority: .high),
                RecommendedActivity(name: "Read spiritual texts", icon: "book.fill", priority: .high),
                RecommendedActivity(name: "Nature walk", icon: "leaf.fill", priority: .medium)
            ],
            8: [
                RecommendedActivity(name: "Review finances", icon: "dollarsign.circle.fill", priority: .high),
                RecommendedActivity(name: "Career planning", icon: "briefcase.fill", priority: .high),
                RecommendedActivity(name: "Power workout", icon: "figure.strengthtraining", priority: .medium)
            ]
        ]
        
        if let dailyActivities = activityDatabase[dailyNumber] {
            activities.append(contentsOf: dailyActivities)
        }
        
        // Add power day bonus
        if powerLevel == .powerDay {
            activities.insert(RecommendedActivity(name: "🌟 POWER HOUR: Take bold action", icon: "star.fill", priority: .urgent), at: 0)
        }
        
        return activities.prefix(3).map { $0 }
    }
    
    // MARK: - Lucky Hours
    private func calculateLuckyHours(dailyNumber: Int, lifePath: Int) -> [Int] {
        var hours: [Int] = []
        
        // Morning power hour
        let morningHour = (dailyNumber + lifePath) % 12 + 6 // 6am - 6pm range
        hours.append(morningHour)
        
        // Afternoon hour
        hours.append((morningHour + 4) % 12 + 6)
        
        // Evening hour
        hours.append((morningHour + 8) % 12 + 6)
        
        return hours.sorted()
    }
    
    // MARK: - Lucky Color
    private func luckyColor(for number: Int) -> String {
        let colors = ["", "Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Purple", "Pink", "Gold"]
        return colors[number] ?? "White"
    }
    
    // MARK: - Lucky Gemstone
    private func luckyGemstone(for number: Int) -> String {
        let stones = ["", "Garnet", "Moonstone", "Amethyst", "Emerald", "Aquamarine", "Pearl", "Ruby", "Diamond", "Sapphire"]
        return stones[number] ?? "Clear Quartz"
    }
    
    // MARK: - Compatibility Forecast
    func forecastCompatibility(user: QodeXUser, with contact: QodeXUser, for date: Date) -> CompatibilityForecast {
        guard let userDate = user.birthDate, let contactDate = contact.birthDate else {
            return CompatibilityForecast(score: 0, outlook: "Insufficient data")
        }
        
        let userLP = calculator.calculateLifePathNumber(birthDate: userDate)
        let contactLP = calculator.calculateLifePathNumber(birthDate: contactDate)
        let dailyNumber = calculator.calculateDailyNumber(for: date)
        
        // Calculate dynamic compatibility
        let baseCompatibility = calculator.calculateCompatibility(between: user, and: contact)
        
        // Daily influence
        var dailyModifier = 0
        if dailyNumber == userLP || dailyNumber == contactLP {
            dailyModifier += 10
        }
        
        let finalScore = min(100, baseCompatibility.score + dailyModifier)
        
        let outlook: String
        if finalScore >= 80 {
            outlook = "Exceptional day for connection. Deep conversations favored."
        } else if finalScore >= 60 {
            outlook = "Positive energy for your relationship. Good day for collaboration."
        } else if finalScore >= 40 {
            outlook = "Neutral day. Practice patience and understanding."
        } else {
            outlook = "Challenging day. Give each other space if tensions arise."
        }
        
        return CompatibilityForecast(score: finalScore, outlook: outlook)
    }
}

// MARK: - Supporting Types
struct DailyPrediction {
    let date: Date
    let dailyNumber: Int
    let personalDay: Int
    let powerLevel: PowerLevel
    let alignmentScore: Int
    let insights: [String]
    let recommendedActivities: [RecommendedActivity]
    let luckyHours: [Int]
    let color: String
    let gemstone: String
}

enum PowerLevel: String {
    case powerDay = "🌟 Power Day"
    case favorable = "✨ Favorable"
    case neutral = "⚡ Neutral"
    case challenging = "💫 Challenging"
}

struct RecommendedActivity {
    let name: String
    let icon: String
    let priority: Priority
    
    enum Priority {
        case urgent
        case high
        case medium
        case low
    }
}

struct CompatibilityForecast {
    let score: Int
    let outlook: String
}
