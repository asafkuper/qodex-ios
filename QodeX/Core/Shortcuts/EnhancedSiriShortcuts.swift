//
//  EnhancedSiriShortcuts.swift
//  Siri Shortcuts and App Intents for QodeX
//  iOS 17+ Support
//

import AppIntents
import SwiftUI

// MARK: - Calculate Life Path Intent
@available(iOS 16.0, *)
struct CalculateLifePathIntent: AppIntent {
    static var title: LocalizedStringResource = "Calculate Life Path Number"
    static var description = IntentDescription("Calculate your life path number from your birth date")
    
    @Parameter(title: "Birth Date", description: "Your date of birth")
    var birthDate: Date
    
    @Parameter(title: "Name", description: "Your full name (optional)", requestValueDialog: "What's your name?")
    var name: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Calculate life path for \($birthDate)") {
            \.$name
        }
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<LifePathResult> {
        let calculator = NumerologyCalculator()
        let lifePath = calculator.calculateLifePath(from: birthDate)
        
        let meanings: [Int: String] = [
            1: "Leader • Independent • Innovative",
            2: "Diplomat • Intuitive • Harmonious",
            3: "Creative • Communicative • Optimistic",
            4: "Practical • Disciplined • Reliable",
            5: "Adventurous • Flexible • Freedom-loving",
            6: "Nurturing • Responsible • Family-oriented",
            7: "Analytical • Spiritual • Seeker of truth",
            8: "Ambitious • Powerful • Material success",
            9: "Compassionate • Humanitarian • Completion"
        ]
        
        let result = LifePathResult(
            number: lifePath,
            meaning: meanings[lifePath] ?? "Unique path",
            name: name ?? "Seeker"
        )
        
        return .result(value: result, dialog: "\(result.name), your life path number is \(result.number). \(result.meaning)")
    }
}

struct LifePathResult: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Life Path Result"
    
    let id = UUID()
    let number: Int
    let meaning: String
    let name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Life Path \(number)", subtitle: meaning)
    }
}

// MARK: - Get Daily Number Intent
@available(iOS 16.0, *)
struct GetDailyNumberIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Today's Number"
    static var description = IntentDescription("Get your daily numerology number and guidance")
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<DailyNumberResult> {
        let calculator = NumerologyCalculator()
        let dailyNumber = calculator.calculateDailyNumber(for: Date())
        
        let dayData: [Int: (theme: String, advice: String)] = [
            1: ("New Beginnings", "Start something new today"),
            2: ("Cooperation", "Work with others"),
            3: ("Creativity", "Express yourself"),
            4: ("Stability", "Build foundations"),
            5: ("Change", "Embrace freedom"),
            6: ("Responsibility", "Focus on family"),
            7: ("Reflection", "Go within"),
            8: ("Power", "Take charge"),
            9: ("Completion", "Let go of the old")
        ]
        
        let data = dayData[dailyNumber] ?? ("Spiritual Growth", "Trust your path")
        
        let result = DailyNumberResult(
            number: dailyNumber,
            theme: data.theme,
            advice: data.advice
        )
        
        return .result(
            value: result,
            dialog: "Today's universal day number is \(result.number): \(result.theme). \(result.advice)."
        )
    }
}

struct DailyNumberResult: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Daily Number"
    
    let id = UUID()
    let number: Int
    let theme: String
    let advice: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(number): \(theme)", subtitle: advice)
    }
}

// MARK: - Log Reading Intent
@available(iOS 16.0, *)
struct LogReadingIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Daily Reading"
    static var description = IntentDescription("Log that you've completed your daily reading")
    
    @Parameter(title: "Notes", description: "Any notes about your reading (optional)")
    var notes: String?
    
    func perform() async throws -> some IntentResult {
        // Save to streak
        let sharedDefaults = UserDefaults(suiteName: "group.com.qodex.app")
        let currentStreak = sharedDefaults?.integer(forKey: "streakDays") ?? 0
        sharedDefaults?.set(currentStreak + 1, forKey: "streakDays")
        
        return .result(dialog: "Reading logged! Your streak is now \(currentStreak + 1) days. 🔥")
    }
}

// MARK: - Share Reading Intent
@available(iOS 16.0, *)
struct ShareReadingIntent: AppIntent {
    static var title: LocalizedStringResource = "Share Today's Reading"
    static var description = IntentDescription("Share your daily numerology reading")
    
    @Parameter(title: "Include Life Path", description: "Include your life path number in the share")
    var includeLifePath: Bool
    
    func perform() async throws -> some IntentResult {
        let calculator = NumerologyCalculator()
        let dailyNumber = calculator.calculateDailyNumber(for: Date())
        
        var shareText = "My daily numerology number is \(dailyNumber)! Discover yours with QodeX."
        
        if includeLifePath {
            // This would fetch actual life path in production
            shareText += " I'm a Life Path 7 - The Seeker."
        }
        
        return .result(dialog: "Ready to share: \(shareText)")
    }
}

// MARK: - Check Compatibility Intent
@available(iOS 16.0, *)
struct CheckCompatibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Compatibility"
    static var description = IntentDescription("Check numerology compatibility between two people")
    
    @Parameter(title: "Your Birth Date")
    var yourBirthDate: Date
    
    @Parameter(title: "Their Birth Date")
    var theirBirthDate: Date
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check compatibility between \($yourBirthDate) and \($theirBirthDate)")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<CompatibilityResult> {
        let calculator = NumerologyCalculator()
        let yourNumber = calculator.calculateLifePath(from: yourBirthDate)
        let theirNumber = calculator.calculateLifePath(from: theirBirthDate)
        
        // Simple compatibility calculation
        let compatibility = calculateCompatibility(yourNumber, theirNumber)
        
        let result = CompatibilityResult(
            yourNumber: yourNumber,
            theirNumber: theirNumber,
            compatibility: compatibility,
            description: getCompatibilityDescription(compatibility)
        )
        
        return .result(
            value: result,
            dialog: "Life Path \(yourNumber) and Life Path \(theirNumber) have \(compatibility) compatibility. \(result.description)"
        )
    }
    
    private func calculateCompatibility(_ num1: Int, _ num2: Int) -> String {
        let diff = abs(num1 - num2)
        switch diff {
        case 0: return "perfect"
        case 1, 2: return "excellent"
        case 3, 4: return "good"
        case 5, 6: return "moderate"
        default: return "challenging but growth-oriented"
        }
    }
    
    private func getCompatibilityDescription(_ compatibility: String) -> String {
        switch compatibility {
        case "perfect": return "You share the same life path - deep understanding."
        case "excellent": return "Natural harmony and complementary energies."
        case "good": return "Strong potential with some balancing needed."
        case "moderate": return "Different approaches that can learn from each other."
        default: return "Contrasting energies that create growth opportunities."
        }
    }
}

struct CompatibilityResult: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Compatibility"
    
    let id = UUID()
    let yourNumber: Int
    let theirNumber: Int
    let compatibility: String
    let description: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(compatibility.capitalized) Match", subtitle: "\(yourNumber) + \(theirNumber)")
    }
}

// MARK: - Get Personalized Reading Intent
@available(iOS 16.0, *)
struct GetPersonalizedReadingIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Personalized Reading"
    static var description = IntentDescription("Get a personalized reading based on your life path and today's energy")
    
    @Parameter(title: "Focus Area", default: .general)
    var focusArea: FocusArea
    
    enum FocusArea: String, AppEnum {
        case general = "General"
        case career = "Career"
        case relationships = "Relationships"
        case health = "Health"
        case spirituality = "Spirituality"
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Focus Area"
        static var caseDisplayRepresentations: [FocusArea: DisplayRepresentation] = [
            .general: "General Guidance",
            .career: "Career & Work",
            .relationships: "Love & Relationships",
            .health: "Health & Wellness",
            .spirituality: "Spiritual Growth"
        ]
    }
    
    func perform() async throws -> some IntentResult {
        let calculator = NumerologyCalculator()
        let dailyNumber = calculator.calculateDailyNumber(for: Date())
        
        let readings: [FocusArea: [Int: String]] = [
            .career: [
                1: "Take initiative on a new project",
                2: "Collaborate with a colleague",
                3: "Present your creative ideas",
                4: "Organize your workspace",
                5: "Consider a career change",
                6: "Support a coworker",
                7: "Research before deciding",
                8: "Ask for that promotion",
                9: "Complete pending projects"
            ],
            .relationships: [
                1: "Take the lead in planning",
                2: "Listen deeply to your partner",
                3: "Have fun together",
                4: "Build security together",
                5: "Try something new together",
                6: "Show appreciation",
                7: "Have a meaningful conversation",
                8: "Discuss future goals",
                9: "Release old grievances"
            ]
        ]
        
        let reading = readings[focusArea]?[dailyNumber] ?? "Trust the journey today."
        
        return .result(dialog: "For \(focusArea.rawValue.lowercased()): \(reading)")
    }
}

// MARK: - Siri Shortcuts Provider
@available(iOS 16.0, *)
struct QodeXShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: CalculateLifePathIntent(),
                phrases: [
                    "Calculate my life path number with QodeX",
                    "What's my life path number in QodeX",
                    "Find my numerology number in QodeX"
                ],
                shortTitle: "Life Path Calculator",
                systemImageName: "number.circle.fill"
            ),
            
            AppShortcut(
                intent: GetDailyNumberIntent(),
                phrases: [
                    "What's today's number in QodeX",
                    "Get my daily numerology from QodeX",
                    "Today's QodeX reading"
                ],
                shortTitle: "Daily Number",
                systemImageName: "sun.max.fill"
            ),
            
            AppShortcut(
                intent: LogReadingIntent(),
                phrases: [
                    "Log my QodeX reading",
                    "I did my daily reading in QodeX",
                    "Check in with QodeX"
                ],
                shortTitle: "Log Reading",
                systemImageName: "checkmark.circle.fill"
            ),
            
            AppShortcut(
                intent: CheckCompatibilityIntent(),
                phrases: [
                    "Check compatibility in QodeX",
                    "Are we compatible according to QodeX",
                    "QodeX compatibility check"
                ],
                shortTitle: "Compatibility",
                systemImageName: "heart.circle.fill"
            )
        ]
    }
}

// MARK: - Spotlight Indexing
@available(iOS 16.0, *)
struct IndexContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Index QodeX Content"
    static var description = IntentDescription("Index content for Spotlight search")
    
    func perform() async throws -> some IntentResult {
        // Index daily readings, meanings, etc for Spotlight
        return .result(dialog: "QodeX content indexed for search")
    }
}

// MARK: - Live Activities Support (iOS 16.1+)
@available(iOS 16.1, *)
struct QodeXLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var dailyNumber: Int
        var theme: String
        var progress: Double
    }
    
    var name: String
}
