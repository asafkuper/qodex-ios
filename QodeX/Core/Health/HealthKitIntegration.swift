//
//  HealthKitIntegration.swift
//  Wellness tracking integration
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private var mindfulnessType: HKObjectType? {
        return HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }
    
    private var sleepType: HKObjectType? {
        return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
    }
    
    // MARK: - Request Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        guard let mindfulness = mindfulnessType,
              let sleep = sleepType else {
            return false
        }
        
        let typesToWrite: Set = [
            mindfulness
        ]
        
        let typesToRead: Set = [
            sleep,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            return true
        } catch {
            print("❌ HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    // MARK: - Log Meditation Session
    func logMeditationSession(duration: TimeInterval, startDate: Date) async {
        guard let mindfulType = mindfulnessType as? HKCategoryType else { return }
        
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValueMindfulSession.mindfulSession.rawValue,
            start: startDate,
            end: startDate.addingTimeInterval(duration)
        )
        
        do {
            try await healthStore.save(sample)
            print("✅ Meditation session logged to HealthKit")
        } catch {
            print("❌ Failed to log meditation: \(error)")
        }
    }
    
    // MARK: - Fetch Sleep Data
    func fetchSleepData(for days: Int = 7) async -> [SleepData] {
        guard let sleepType = sleepType as? HKCategoryType else { return [] }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: days * 10,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let sleepData = samples.map { sample -> SleepData in
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    let quality: SleepQuality
                    
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        quality = .rem
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        quality = .deep
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        quality = .light
                    default:
                        quality = .unknown
                    }
                    
                    return SleepData(
                        date: sample.startDate,
                        duration: duration,
                        quality: quality
                    )
                }
                
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Correlation with Numerology
    func analyzeNumerologyHealthCorrelation(user: QodeXUser) async -> HealthCorrelation {
        let sleepData = await fetchSleepData(for: 30)
        let lifePath = calculateLifePath(user)
        
        // Analyze patterns
        let avgSleep = sleepData.map { $0.duration }.reduce(0, +) / Double(sleepData.count)
        
        // Life Path specific insights
        let insight: String
        switch lifePath {
        case 1, 8:
            insight = "As a Life Path \(lifePath), you may experience better sleep when you exercise leadership during the day."
        case 2, 6:
            insight = "Your sensitive nature benefits from consistent sleep schedules."
        case 3, 5:
            insight = "Variety in your routine supports your creative energy."
        case 4, 7:
            insight = "Quality sleep is essential for your analytical mind."
        default:
            insight = "Track your sleep patterns to discover your optimal rest schedule."
        }
        
        return HealthCorrelation(
            lifePath: lifePath,
            averageSleepDuration: avgSleep,
            sleepConsistency: calculateConsistency(sleepData),
            insight: insight,
            recommendations: generateSleepRecommendations(lifePath: lifePath, sleepData: sleepData)
        )
    }
    
    private func calculateLifePath(_ user: QodeXUser) -> Int {
        guard let birthDate = user.birthDate else { return 7 }
        return NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
    
    private func calculateConsistency(_ data: [SleepData]) -> Double {
        guard data.count > 1 else { return 0 }
        let durations = data.map { $0.duration }
        let avg = durations.reduce(0, +) / Double(durations.count)
        let variance = durations.map { pow($0 - avg, 2) }.reduce(0, +) / Double(durations.count)
        let stdDev = sqrt(variance)
        return max(0, 100 - (stdDev / 60)) // Normalize to 0-100
    }
    
    private func generateSleepRecommendations(lifePath: Int, sleepData: [SleepData]) -> [String] {
        var recommendations: [String] = []
        
        if lifePath == 1 || lifePath == 8 {
            recommendations.append("Try going to bed before 11 PM to maximize your power energy")
        } else if lifePath == 2 || lifePath == 6 {
            recommendations.append("Consistent bedtime supports your nurturing nature")
        }
        
        if sleepData.count > 7 {
            let avgDuration = sleepData.map { $0.duration }.reduce(0, +) / Double(sleepData.count)
            if avgDuration < 7 * 3600 {
                recommendations.append("Aim for 7-8 hours to support your spiritual growth")
            }
        }
        
        return recommendations
    }
}

// MARK: - Supporting Types
struct SleepData {
    let date: Date
    let duration: TimeInterval
    let quality: SleepQuality
}

enum SleepQuality: String {
    case rem = "REM"
    case deep = "Deep"
    case light = "Light"
    case awake = "Awake"
    case unknown = "Unknown"
}

struct HealthCorrelation {
    let lifePath: Int
    let averageSleepDuration: TimeInterval
    let sleepConsistency: Double
    let insight: String
    let recommendations: [String]
}
