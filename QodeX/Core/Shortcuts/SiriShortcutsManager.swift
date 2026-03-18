//
//  SiriShortcutsManager.swift
//  Siri and Shortcuts integration
//

import Foundation
import Intents
import AppIntents

// MARK: - App Shortcuts (iOS 16+)
@available(iOS 16.0, *)
struct QodeXShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: GetDailyNumberIntent(),
                phrases: [
                    "What's my number today in \(.applicationName)",
                    "Show my daily energy in \(.applicationName)",
                    "Check my numerology in \(.applicationName)"
                ],
                shortTitle: "Daily Number",
                systemImageName: "number.circle.fill"
            ),
            
            AppShortcut(
                intent: CalculateLifePathIntent(),
                phrases: [
                    "Calculate life path in \(.applicationName)",
                    "What's my life path number in \(.applicationName)"
                ],
                shortTitle: "Life Path",
                systemImageName: "person.circle.fill"
            ),
            
            AppShortcut(
                intent: StartMeditationIntent(),
                phrases: [
                    "Start numerology meditation in \(.applicationName)",
                    "Meditate with \(.applicationName)"
                ],
                shortTitle: "Meditate",
                systemImageName: "sparkles"
            )
        ]
    }
}

// MARK: - Get Daily Number Intent
@available(iOS 16.0, *)
struct GetDailyNumberIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Daily Number"
    static var description = IntentDescription("Shows today's numerology number and energy")
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let calculator = NumerologyCalculator()
        let number = calculator.calculateDailyNumber(for: Date())
        let vibes = ["", "New Beginnings", "Partnership", "Creativity", "Foundation", 
                     "Freedom", "Harmony", "Wisdom", "Abundance", "Completion"]
        let vibe = vibes[number]
        
        let dialog = IntentDialog(full: "Today's number is \(number), which represents \(vibe).")
        
        return .result(
            dialog: dialog,
            view: DailyNumberSnippet(number: number, vibe: vibe)
        )
    }
}

// MARK: - Calculate Life Path Intent
@available(iOS 16.0, *)
struct CalculateLifePathIntent: AppIntent {
    static var title: LocalizedStringResource = "Calculate Life Path"
    static var description = IntentDescription("Calculate your life path number")
    
    @Parameter(title: "Birth Date", description: "Your date of birth")
    var birthDate: Date
    
    static var parameterSummary: some ParameterSummary {
        Summary("Calculate life path for \($birthDate)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let calculator = NumerologyCalculator()
        let lifePath = calculator.calculateLifePathNumber(birthDate: birthDate)
        
        let descriptions: [Int: String] = [
            1: "The Leader - Independent and ambitious",
            2: "The Diplomat - Cooperative and intuitive",
            3: "The Creative - Expressive and optimistic",
            4: "The Builder - Practical and disciplined",
            5: "The Freedom Seeker - Adventurous and adaptable",
            6: "The Nurturer - Responsible and compassionate",
            7: "The Seeker - Analytical and spiritual",
            8: "The Powerhouse - Ambitious and authoritative",
            9: "The Humanitarian - Compassionate and wise"
        ]
        
        let description = descriptions[lifePath] ?? "Unique and special"
        
        return .result(dialog: "Your life path number is \(lifePath). \(description).")
    }
}

// MARK: - Start Meditation Intent
@available(iOS 16.0, *)
struct StartMeditationIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Numerology Meditation"
    static var description = IntentDescription("Begin a guided meditation based on your daily number")
    
    @Parameter(title: "Duration", description: "Meditation duration in minutes", default: 10)
    var duration: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Meditate for \($duration) minutes")
    }
    
    func perform() async throws -> some IntentResult & OpensIntent {
        // Open app to meditation screen
        return .result(opensIntent: OpenMeditationIntent(duration: duration))
    }
}

@available(iOS 16.0, *)
struct OpenMeditationIntent: OpenIntent {
    let duration: Int
}

// MARK: - Snippet Views
@available(iOS 16.0, *)
struct DailyNumberSnippet: View {
    let number: Int
    let vibe: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Today's Number")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(number)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.gold)
            
            Text(vibe)
                .font(.title3)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Legacy SiriKit Support (iOS 15 and earlier)
class QodeXIntentHandler: NSObject, QodeXDailyNumberIntentHandling {
    
    func handle(intent: QodeXDailyNumberIntent, completion: @escaping (QodeXDailyNumberIntentResponse) -> Void) {
        let calculator = NumerologyCalculator()
        let number = calculator.calculateDailyNumber(for: Date())
        
        let response = QodeXDailyNumberIntentResponse(code: .success, userActivity: nil)
        response.number = NSNumber(value: number)
        completion(response)
    }
}

// MARK: - Shortcut Donations
class ShortcutDonationManager {
    static let shared = ShortcutDonationManager()
    
    func donateDailyNumberShortcut() {
        let activity = NSUserActivity(activityType: "com.qodex.dailyNumber")
        activity.title = "Check Daily Number"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        
        // Suggest at 8 AM daily
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let morning = formatter.date(from: "08:00") {
            activity.suggestedInvocationPhrase = "What's my number today?"
        }
        
        activity.becomeCurrent()
    }
    
    func donateMeditationShortcut() {
        let activity = NSUserActivity(activityType: "com.qodex.meditation")
        activity.title = "Start Numerology Meditation"
        activity.isEligibleForPrediction = true
        activity.userInfo = ["duration": 10]
        activity.becomeCurrent()
    }
}
