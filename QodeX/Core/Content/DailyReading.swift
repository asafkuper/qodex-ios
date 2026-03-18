//
//  DailyReading.swift
//  Data model for personalized daily readings
//  Combines Universal Day with Life Path for unique insights
//

import Foundation

// MARK: - Data Models

struct PersonalizedDailyReadings: Codable {
    let description: String
    let universalDay1: UniversalDayReadings
    let universalDay2: UniversalDayReadings
    let universalDay3: UniversalDayReadings
    let universalDay4: UniversalDayReadings
    let universalDay5: UniversalDayReadings
    let universalDay6: UniversalDayReadings
    let universalDay7: UniversalDayReadings
    let universalDay8: UniversalDayReadings
    let universalDay9: UniversalDayReadings
    
    enum CodingKeys: String, CodingKey {
        case description
        case universalDay1 = "universal_day_1"
        case universalDay2 = "universal_day_2"
        case universalDay3 = "universal_day_3"
        case universalDay4 = "universal_day_4"
        case universalDay5 = "universal_day_5"
        case universalDay6 = "universal_day_6"
        case universalDay7 = "universal_day_7"
        case universalDay8 = "universal_day_8"
        case universalDay9 = "universal_day_9"
    }
}

struct UniversalDayReadings: Codable {
    let lifePath1: LifePathReading
    let lifePath2: LifePathReading
    let lifePath3: LifePathReading
    let lifePath4: LifePathReading
    let lifePath5: LifePathReading
    let lifePath6: LifePathReading
    let lifePath7: LifePathReading
    let lifePath8: LifePathReading
    let lifePath9: LifePathReading
    let lifePath11: LifePathReading
    let lifePath22: LifePathReading
    let lifePath33: LifePathReading
    
    enum CodingKeys: String, CodingKey {
        case lifePath1 = "1"
        case lifePath2 = "2"
        case lifePath3 = "3"
        case lifePath4 = "4"
        case lifePath5 = "5"
        case lifePath6 = "6"
        case lifePath7 = "7"
        case lifePath8 = "8"
        case lifePath9 = "9"
        case lifePath11 = "11"
        case lifePath22 = "22"
        case lifePath33 = "33"
    }
}

struct LifePathReading: Codable {
    let insight: String
    let advice: String
    let energy: EnergyLevel
    let bestActivities: [String]
    
    enum CodingKeys: String, CodingKey {
        case insight
        case advice
        case energy
        case bestActivities = "best_activities"
    }
}

enum EnergyLevel: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayText: String {
        switch self {
        case .high: return "High Energy Day"
        case .medium: return "Balanced Energy"
        case .low: return "Rest & Reflect"
        }
    }
    
    var colorHex: String {
        switch self {
        case .high: return "FFD700" // Gold
        case .medium: return "87CEEB" // Sky Blue
        case .low: return "DDA0DD" // Plum
        }
    }
    
    var iconName: String {
        switch self {
        case .high: return "bolt.fill"
        case .medium: return "circle.fill"
        case .low: return "moon.fill"
        }
    }
}

// MARK: - Reading Manager

class DailyReadingManager: ObservableObject {
    static let shared = DailyReadingManager()
    
    @Published private(set) var readings: PersonalizedDailyReadings?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private init() {
        loadReadings()
    }
    
    // MARK: - Loading
    
    private func loadReadings() {
        isLoading = true
        
        guard let url = Bundle.main.url(
            forResource: "PersonalizedDailyReadings",
            withExtension: "json"
        ) else {
            // Try to load from Core/Content directory
            let fileManager = FileManager.default
            let possiblePaths = [
                fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
                fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
                URL(fileURLWithPath: "QodeX/Core/Content")
            ]
            
            for baseURL in possiblePaths.compactMap({ $0 }) {
                let fileURL = baseURL.appendingPathComponent("PersonalizedDailyReadings.json")
                if fileManager.fileExists(atPath: fileURL.path) {
                    loadFromURL(fileURL)
                    return
                }
            }
            
            // If file not found, create default readings
            createDefaultReadings()
            return
        }
        
        loadFromURL(url)
    }
    
    private func loadFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            readings = try decoder.decode(PersonalizedDailyReadings.self, from: data)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            createDefaultReadings()
        }
    }
    
    private func createDefaultReadings() {
        // Create minimal default readings as fallback
        readings = PersonalizedDailyReadings(
            description: "Default personalized daily readings",
            universalDay1: createDefaultUniversalDayReadings(),
            universalDay2: createDefaultUniversalDayReadings(),
            universalDay3: createDefaultUniversalDayReadings(),
            universalDay4: createDefaultUniversalDayReadings(),
            universalDay5: createDefaultUniversalDayReadings(),
            universalDay6: createDefaultUniversalDayReadings(),
            universalDay7: createDefaultUniversalDayReadings(),
            universalDay8: createDefaultUniversalDayReadings(),
            universalDay9: createDefaultUniversalDayReadings()
        )
    }
    
    private func createDefaultUniversalDayReadings() -> UniversalDayReadings {
        let defaultReading = LifePathReading(
            insight: "Today's energy offers unique opportunities aligned with your Life Path.",
            advice: "Trust your intuition and take aligned action.",
            energy: .medium,
            bestActivities: ["Reflection", "Planning", "Connection"]
        )
        
        return UniversalDayReadings(
            lifePath1: defaultReading,
            lifePath2: defaultReading,
            lifePath3: defaultReading,
            lifePath4: defaultReading,
            lifePath5: defaultReading,
            lifePath6: defaultReading,
            lifePath7: defaultReading,
            lifePath8: defaultReading,
            lifePath9: defaultReading,
            lifePath11: defaultReading,
            lifePath22: defaultReading,
            lifePath33: defaultReading
        )
    }
    
    // MARK: - Public Methods
    
    func getReading(universalDay: Int, lifePath: Int) -> LifePathReading? {
        guard let readings = readings else { return nil }
        
        let dayReadings: UniversalDayReadings?
        switch universalDay {
        case 1: dayReadings = readings.universalDay1
        case 2: dayReadings = readings.universalDay2
        case 3: dayReadings = readings.universalDay3
        case 4: dayReadings = readings.universalDay4
        case 5: dayReadings = readings.universalDay5
        case 6: dayReadings = readings.universalDay6
        case 7: dayReadings = readings.universalDay7
        case 8: dayReadings = readings.universalDay8
        case 9: dayReadings = readings.universalDay9
        default: dayReadings = nil
        }
        
        guard let day = dayReadings else { return nil }
        
        switch lifePath {
        case 1: return day.lifePath1
        case 2: return day.lifePath2
        case 3: return day.lifePath3
        case 4: return day.lifePath4
        case 5: return day.lifePath5
        case 6: return day.lifePath6
        case 7: return day.lifePath7
        case 8: return day.lifePath8
        case 9: return day.lifePath9
        case 11: return day.lifePath11
        case 22: return day.lifePath22
        case 33: return day.lifePath33
        default: return nil
        }
    }
    
    func getTodayReading(for user: QodeXUser?) -> PersonalizedReading? {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate Universal Day
        let universalDay = NumerologyCalculator.shared.calculateUniversalDay(for: today)
        
        // Get user's Life Path
        let lifePath: Int
        if let birthDate = user?.birthDate {
            lifePath = NumerologyCalculator.shared.calculateLifePathNumber(birthDate: birthDate)
        } else {
            // Default to 1 if no user data
            lifePath = 1
        }
        
        guard let reading = getReading(universalDay: universalDay, lifePath: lifePath) else {
            return nil
        }
        
        return PersonalizedReading(
            universalDay: universalDay,
            lifePath: lifePath,
            insight: reading.insight,
            advice: reading.advice,
            energy: reading.energy,
            bestActivities: reading.bestActivities,
            date: today
        )
    }
}

// MARK: - Personalized Reading

struct PersonalizedReading: Identifiable {
    let id = UUID()
    let universalDay: Int
    let lifePath: Int
    let insight: String
    let advice: String
    let energy: EnergyLevel
    let bestActivities: [String]
    let date: Date
    
    var universalDayTitle: String {
        let titles = [
            1: "New Beginnings",
            2: "Partnership & Harmony",
            3: "Creative Expression",
            4: "Building Foundations",
            5: "Freedom & Change",
            6: "Love & Responsibility",
            7: "Inner Wisdom",
            8: "Power & Abundance",
            9: "Completion & Service"
        ]
        return titles[universalDay] ?? "Today's Energy"
    }
    
    var lifePathTitle: String {
        NumerologyCalculator.shared.lifePathMeaning(lifePath).title
    }
    
    var personalizedSummary: String {
        "Universal Day \(universalDay) meets Life Path \(lifePath): \(universalDayTitle) through the lens of \(lifePathTitle)"
    }
}

// MARK: - Today View Model

import Combine

class TodayViewModel: ObservableObject {
    @Published var reading: PersonalizedReading?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let readingManager = DailyReadingManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadReading()
    }
    
    func loadReading(for user: QodeXUser? = nil) {
        isLoading = true
        
        // In a real app, you'd fetch the current user
        // For now, we'll use a mock or passed user
        reading = readingManager.getTodayReading(for: user)
        
        isLoading = false
        
        // Subscribe to reading manager updates
        readingManager.$readings
            .sink { [weak self] _ in
                self?.reading = self?.readingManager.getTodayReading(for: user)
            }
            .store(in: &cancellables)
    }
    
    func refreshReading() {
        loadReading()
    }
}
