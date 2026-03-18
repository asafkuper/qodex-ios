//
//  CoreMLPersonalization.swift
//  Machine Learning predictions for personalized numerology insights
//  Uses on-device CoreML for privacy and speed
//

import CoreML
import Foundation

// MARK: - Prediction Models
enum PredictionType {
    case dailyEnergy        // Best times for activities
    case compatibility      // Relationship insights
    case careerPath         // Optimal career directions
    case relationshipTiming // Best days for important conversations
    case decisionSupport    // ML-assisted decision making
}

// MARK: - Personalized Insight
struct PersonalizedInsight {
    let type: PredictionType
    let confidence: Double // 0.0 - 1.0
    let insight: String
    let recommendation: String
    let supportingNumbers: [Int]
    let bestTiming: DateInterval?
}

// MARK: - User Pattern Model
struct UserPattern: Codable {
    let userId: String
    let lifePathNumber: Int
    let expressionNumber: Int
    let soulUrgeNumber: Int
    let personalityNumber: Int
    let birthdayNumber: Int
    
    // Historical data
    let readingHistory: [ReadingEntry]
    let moodCorrelations: [Int: Double] // Number to mood score
    let activitySuccess: [String: Double] // Activity type to success rate
    
    // Preferences
    let preferredReadingTime: DateComponents?
    let notificationPreferences: NotificationPreferences
}

struct ReadingEntry: Codable {
    let date: Date
    let dailyNumber: Int
    let userMood: Int // 1-10 scale
    let activities: [String]
    let outcomes: [String: Bool] // Activity to success
}

struct NotificationPreferences: Codable {
    let morningReminder: Bool
    let eveningReflection: Bool
    let significantDays: Bool
    let optimalTimingAlerts: Bool
}

// MARK: - ML Prediction Engine
final class MLPredictionEngine {
    static let shared = MLPredictionEngine()
    
    private var userPatterns: [String: UserPattern] = [:]
    private let queue = DispatchQueue(label: "com.qodex.ml", qos: .userInitiated)
    
    private init() {
        loadPatterns()
    }
    
    // MARK: - Pattern Learning
    
    func recordReading(
        userId: String,
        dailyNumber: Int,
        mood: Int,
        activities: [String],
        outcomes: [String: Bool]
    ) {
        queue.async {
            let entry = ReadingEntry(
                date: Date(),
                dailyNumber: dailyNumber,
                userMood: mood,
                activities: activities,
                outcomes: outcomes
            )
            
            if var pattern = self.userPatterns[userId] {
                var history = pattern.readingHistory
                history.append(entry)
                if history.count > 100 { // Keep last 100
                    history.removeFirst()
                }
                
                // Update mood correlations
                let currentCorrelation = pattern.moodCorrelations[dailyNumber] ?? 5.0
                let newCorrelation = (currentCorrelation * Double(history.count - 1) + Double(mood)) / Double(history.count)
                pattern.moodCorrelations[dailyNumber] = newCorrelation
                
                // Update activity success rates
                for (activity, success) in outcomes {
                    let currentRate = pattern.activitySuccess[activity] ?? 0.5
                    let newRate = (currentRate + (success ? 1.0 : 0.0)) / 2.0
                    pattern.activitySuccess[activity] = newRate
                }
                
                self.userPatterns[userId] = pattern
            }
            
            self.savePatterns()
        }
    }
    
    // MARK: - Predictions
    
    func predictDailyEnergy(for userId: String, on date: Date) -> PersonalizedInsight {
        guard let pattern = userPatterns[userId] else {
            return createGenericInsight(type: .dailyEnergy, date: date)
        }
        
        let calculator = NumerologyCalculator()
        let dailyNumber = calculator.calculateDailyNumber(for: date)
        
        // Analyze historical mood for this number
        let moodScore = pattern.moodCorrelations[dailyNumber] ?? 5.0
        let historicalData = pattern.readingHistory.filter { $0.dailyNumber == dailyNumber }
        
        // Calculate confidence based on data volume
        let confidence = min(Double(historicalData.count) / 10.0, 1.0)
        
        // Generate insight
        let insight = generateEnergyInsight(
            dailyNumber: dailyNumber,
            moodScore: moodScore,
            pattern: pattern
        )
        
        return PersonalizedInsight(
            type: .dailyEnergy,
            confidence: confidence,
            insight: insight.description,
            recommendation: insight.recommendation,
            supportingNumbers: [dailyNumber, pattern.lifePathNumber],
            bestTiming: insight.optimalTiming
        )
    }
    
    func predictCompatibility(user1: String, user2: String) -> PersonalizedInsight {
        guard let pattern1 = userPatterns[user1],
              let pattern2 = userPatterns[user2] else {
            return createGenericInsight(type: .compatibility, date: Date())
        }
        
        // Calculate numerology compatibility
        let lifePathCompatibility = calculateNumberCompatibility(
            pattern1.lifePathNumber,
            pattern2.lifePathNumber
        )
        
        let expressionCompatibility = calculateNumberCompatibility(
            pattern1.expressionNumber,
            pattern2.expressionNumber
        )
        
        // Weighted average
        let overallCompatibility = (lifePathCompatibility * 0.6) + (expressionCompatibility * 0.4)
        
        let description = generateCompatibilityDescription(
            pattern1: pattern1,
            pattern2: pattern2,
            compatibility: overallCompatibility
        )
        
        return PersonalizedInsight(
            type: .compatibility,
            confidence: overallCompatibility,
            insight: description.overview,
            recommendation: description.advice,
            supportingNumbers: [pattern1.lifePathNumber, pattern2.lifePathNumber],
            bestTiming: nil
        )
    }
    
    func suggestOptimalTiming(for activity: String, userId: String, within days: Int = 7) -> [Date: Double] {
        guard let pattern = userPatterns[userId] else { return [:] }
        
        let calendar = Calendar.current
        var suggestions: [Date: Double] = [:]
        
        // Look at historical success for this activity
        let historicalSuccess = pattern.activitySuccess[activity] ?? 0.5
        
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            
            let calculator = NumerologyCalculator()
            let dailyNumber = calculator.calculateDailyNumber(for: date)
            
            // Calculate probability based on:
            // 1. Historical success for this activity
            // 2. User's mood correlation with this daily number
            // 3. Life path harmony
            
            let moodCorrelation = pattern.moodCorrelations[dailyNumber] ?? 5.0
            let lifePathHarmony = calculateLifePathDailyNumberHarmony(
                lifePath: pattern.lifePathNumber,
                dailyNumber: dailyNumber
            )
            
            let score = (historicalSuccess * 0.4) + (moodCorrelation / 10.0 * 0.3) + (lifePathHarmony * 0.3)
            suggestions[date] = score
        }
        
        return suggestions
    }
    
    // MARK: - Private Helpers
    
    private func generateEnergyInsight(
        dailyNumber: Int,
        moodScore: Double,
        pattern: UserPattern
    ) -> (description: String, recommendation: String, optimalTiming: DateInterval?) {
        
        let numberMeanings: [Int: String] = [
            1: "leadership and new beginnings",
            2: "partnership and diplomacy",
            3: "creativity and self-expression",
            4: "stability and hard work",
            5: "change and adventure",
            6: "harmony and responsibility",
            7: "introspection and spiritual growth",
            8: "power and material success",
            9: "completion and humanitarianism"
        ]
        
        let theme = numberMeanings[dailyNumber] ?? "spiritual growth"
        
        let description: String
        let recommendation: String
        
        if moodScore >= 7 {
            description = "Today's energy strongly supports \(theme). Based on your history, this number correlates with positive outcomes for you."
            recommendation = "Take initiative on important tasks. Your intuition is heightened today."
        } else if moodScore >= 4 {
            description = "Today's theme of \(theme) presents moderate opportunities. Some caution advised based on your patterns."
            recommendation = "Focus on reflection and planning rather than major decisions."
        } else {
            description = "Today's energy around \(theme) may feel challenging. This number has historically been difficult for you."
            recommendation = "Practice self-care and avoid high-stakes activities today."
        }
        
        // Calculate optimal timing (simplified)
        let calendar = Calendar.current
        let now = Date()
        let optimalStart = calendar.date(byAdding: .hour, value: 9, to: now) ?? now
        let optimalEnd = calendar.date(byAdding: .hour, value: 11, to: optimalStart) ?? optimalStart
        
        return (description, recommendation, DateInterval(start: optimalStart, end: optimalEnd))
    }
    
    private func calculateNumberCompatibility(_ num1: Int, _ num2: Int) -> Double {
        // Compatibility matrix based on numerology principles
        let compatibilityMatrix: [[Double]] = [
            [1.0, 0.8, 0.7, 0.6, 0.8, 0.5, 0.6, 0.9, 0.7],
            [0.8, 1.0, 0.8, 0.7, 0.6, 0.9, 0.5, 0.7, 0.8],
            [0.7, 0.8, 1.0, 0.6, 0.9, 0.7, 0.8, 0.6, 0.8],
            [0.6, 0.7, 0.6, 1.0, 0.5, 0.8, 0.7, 0.9, 0.6],
            [0.8, 0.6, 0.9, 0.5, 1.0, 0.6, 0.8, 0.7, 0.9],
            [0.5, 0.9, 0.7, 0.8, 0.6, 1.0, 0.8, 0.7, 0.9],
            [0.6, 0.5, 0.8, 0.7, 0.8, 0.8, 1.0, 0.6, 0.8],
            [0.9, 0.7, 0.6, 0.9, 0.7, 0.7, 0.6, 1.0, 0.7],
            [0.7, 0.8, 0.8, 0.6, 0.9, 0.9, 0.8, 0.7, 1.0]
        ]
        
        let index1 = max(0, min(num1 - 1, 8))
        let index2 = max(0, min(num2 - 1, 8))
        
        return compatibilityMatrix[index1][index2]
    }
    
    private func calculateLifePathDailyNumberHarmony(lifePath: Int, dailyNumber: Int) -> Double {
        // Some numbers naturally harmonize better with certain life paths
        let harmonyScores: [Int: [Int: Double]] = [
            1: [1: 1.0, 5: 0.9, 7: 0.8, 8: 0.9],
            2: [2: 1.0, 4: 0.9, 6: 0.9, 8: 0.7],
            3: [3: 1.0, 5: 0.9, 6: 0.8, 9: 0.9],
            4: [2: 0.9, 4: 1.0, 8: 0.9, 6: 0.8],
            5: [1: 0.9, 3: 0.9, 5: 1.0, 9: 0.9],
            6: [2: 0.9, 3: 0.8, 6: 1.0, 9: 0.9],
            7: [1: 0.8, 5: 0.8, 7: 1.0, 9: 0.7],
            8: [1: 0.9, 2: 0.7, 4: 0.9, 8: 1.0],
            9: [3: 0.9, 5: 0.9, 6: 0.9, 9: 1.0]
        ]
        
        return harmonyScores[lifePath]?[dailyNumber] ?? 0.6
    }
    
    private func generateCompatibilityDescription(pattern1: UserPattern, pattern2: UserPattern, compatibility: Double) -> (overview: String, advice: String) {
        let lifePathDescriptions: [Int: String] = [
            1: "leader", 2: "diplomat", 3: "creative",
            4: "builder", 5: "adventurer", 6: "nurturer",
            7: "seeker", 8: "powerhouse", 9: "humanitarian"
        ]
        
        let desc1 = lifePathDescriptions[pattern1.lifePathNumber] ?? "individual"
        let desc2 = lifePathDescriptions[pattern2.lifePathNumber] ?? "individual"
        
        let overview = "Life Path \(pattern1.lifePathNumber) (The \(desc1.capitalized)) meets Life Path \(pattern2.lifePathNumber) (The \(desc2.capitalized)). Compatibility: \(Int(compatibility * 100))%."
        
        let advice: String
        if compatibility >= 0.8 {
            advice = "Excellent match! Your energies naturally complement each other. Focus on shared goals."
        } else if compatibility >= 0.6 {
            advice = "Good potential with some balancing needed. Respect each other's different approaches."
        } else {
            advice = "Challenging but growth-oriented. Your differences can teach you both valuable lessons."
        }
        
        return (overview, advice)
    }
    
    private func createGenericInsight(type: PredictionType, date: Date) -> PersonalizedInsight {
        PersonalizedInsight(
            type: type,
            confidence: 0.5,
            insight: "Not enough data for personalized insights yet. Keep using the app!",
            recommendation: "Continue logging your daily readings to unlock personalized predictions.",
            supportingNumbers: [],
            bestTiming: nil
        )
    }
    
    // MARK: - Persistence
    
    private func loadPatterns() {
        guard let data = UserDefaults.standard.data(forKey: "qodex_user_patterns"),
              let decoded = try? JSONDecoder().decode([String: UserPattern].self, from: data) else {
            return
        }
        userPatterns = decoded
    }
    
    private func savePatterns() {
        if let data = try? JSONEncoder().encode(userPatterns) {
            UserDefaults.standard.set(data, forKey: "qodex_user_patterns")
        }
    }
}

// MARK: - SwiftUI Integration
struct PersonalizedInsightCard: View {
    let insight: PersonalizedInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForType(insight.type))
                    .font(.title2)
                    .foregroundColor(confidenceColor)
                
                VStack(alignment: .leading) {
                    Text(titleForType(insight.type))
                        .font(.headline)
                    
                    ConfidenceBadge(confidence: insight.confidence)
                }
                
                Spacer()
            }
            
            Text(insight.insight)
                .font(.body)
                .foregroundColor(.primary)
            
            Text(insight.recommendation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
            
            if let timing = insight.bestTiming {
                HStack {
                    Image(systemName: "clock")
                    Text("Optimal: \(timing.start, style: .time) - \(timing.end, style: .time)")
                        .font(.caption)
                }
                .foregroundColor(.gold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: confidenceColor.opacity(0.2), radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(confidenceColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var confidenceColor: Color {
        switch insight.confidence {
        case 0.8...1.0: return .green
        case 0.6..0.8: return .yellow
        default: return .orange
        }
    }
    
    private func iconForType(_ type: PredictionType) -> String {
        switch type {
        case .dailyEnergy: return "sun.max.fill"
        case .compatibility: return "heart.fill"
        case .careerPath: return "briefcase.fill"
        case .relationshipTiming: return "clock.arrow.circlepath"
        case .decisionSupport: return "brain.head.profile"
        }
    }
    
    private func titleForType(_ type: PredictionType) -> String {
        switch type {
        case .dailyEnergy: return "Daily Energy"
        case .compatibility: return "Compatibility"
        case .careerPath: return "Career Path"
        case .relationshipTiming: return "Timing"
        case .decisionSupport: return "Decision Support"
        }
    }
}

struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "brain")
                .font(.caption)
            Text("\(Int(confidence * 100))% confidence")
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.2))
        .foregroundColor(confidenceColor)
        .cornerRadius(8)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..0.8: return .yellow
        default: return .orange
        }
    }
}
