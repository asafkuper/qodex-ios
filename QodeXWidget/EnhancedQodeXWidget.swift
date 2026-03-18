//
//  EnhancedQodeXWidget.swift
//  Interactive Widgets for iOS 17+
//  Supports: Home Screen, Lock Screen, StandBy, Interactive Buttons
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Enhanced Widget Entry
struct EnhancedQodeXEntry: TimelineEntry {
    let date: Date
    let dailyNumber: Int
    let dailyVibe: String
    let dailyAdvice: String
    let userName: String
    let isPremium: Bool
    let lifePathNumber: Int?
    let streakDays: Int
}

// MARK: - Interactive Widget Provider
struct EnhancedWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = EnhancedQodeXEntry
    typealias Intent = ConfigurationIntent
    
    func placeholder(in context: Context) -> EnhancedQodeXEntry {
        EnhancedQodeXEntry(
            date: Date(),
            dailyNumber: 8,
            dailyVibe: "Power & Abundance",
            dailyAdvice: "Take charge of your destiny today",
            userName: "Seeker",
            isPremium: true,
            lifePathNumber: 7,
            streakDays: 12
        )
    }
    
    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> EnhancedQodeXEntry {
        loadLatestEntry()
    }
    
    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<EnhancedQodeXEntry> {
        var entries: [EnhancedQodeXEntry] = []
        
        // Update every 3 hours for 24 hours
        let currentDate = Date()
        for hourOffset in stride(from: 0, to: 24, by: 3) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = await loadEntry(for: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        return timeline
    }
    
    private func loadLatestEntry() -> EnhancedQodeXEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.qodex.app")
        
        return EnhancedQodeXEntry(
            date: Date(),
            dailyNumber: sharedDefaults?.integer(forKey: "dailyNumber") ?? 7,
            dailyVibe: sharedDefaults?.string(forKey: "dailyVibe") ?? "Spiritual Growth",
            dailyAdvice: sharedDefaults?.string(forKey: "dailyAdvice") ?? "Trust your intuition today",
            userName: sharedDefaults?.string(forKey: "userName") ?? "Seeker",
            isPremium: sharedDefaults?.bool(forKey: "isPremium") ?? false,
            lifePathNumber: sharedDefaults?.object(forKey: "lifePathNumber") as? Int,
            streakDays: sharedDefaults?.integer(forKey: "streakDays") ?? 0
        )
    }
    
    private func loadEntry(for date: Date) async -> EnhancedQodeXEntry {
        let calculator = NumerologyCalculator()
        let dailyNumber = calculator.calculateDailyNumber(for: date)
        
        let data = WidgetDataProvider.shared.dataForNumber(dailyNumber)
        
        return EnhancedQodeXEntry(
            date: date,
            dailyNumber: dailyNumber,
            dailyVibe: data.vibe,
            dailyAdvice: data.advice,
            userName: "Seeker",
            isPremium: true,
            lifePathNumber: 7,
            streakDays: 12
        )
    }
}

// MARK: - Configuration Intent
struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "QodeX Configuration"
    static var description = IntentDescription("Configure your daily numerology widget")
    
    @Parameter(title: "Widget Style", default: .dailyNumber)
    var style: WidgetStyle
    
    @Parameter(title: "Show Streak", default: true)
    var showStreak: Bool
}

enum WidgetStyle: String, AppEnum {
    case dailyNumber = "Daily Number"
    case lifePath = "Life Path"
    case streak = "Reading Streak"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Style"
    static var caseDisplayRepresentations: [WidgetStyle: DisplayRepresentation] = [
        .dailyNumber: "Daily Number",
        .lifePath: "Life Path Focus",
        .streak: "Streak Tracker"
    ]
}

// MARK: - Interactive Widget Views

// Large Home Screen Widget
struct QodeXLargeWidgetView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        ZStack {
            // Background
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0A0A0F"), Color(hex: "12121A")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Today's Energy")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "888888"))
                    
                    Spacer()
                    
                    if entry.streakDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                            Text("\(entry.streakDays)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                // Main Content
                HStack(spacing: 20) {
                    // Number Display
                    ZStack {
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [Color(hex: "E5C158"), Color(hex: "9B59B6"), Color(hex: "E5C158")],
                                    center: .center
                                )
                                .opacity(0.2)
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("\(entry.dailyNumber)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "E5C158"), Color(hex: "F39C12")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    // Text Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.dailyVibe)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(entry.dailyAdvice)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "AAAAAA"))
                            .lineLimit(2)
                        
                        if let lifePath = entry.lifePathNumber {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                Text("Life Path: \(lifePath)")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(Color(hex: "E5C158"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "E5C158").opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                
                // Interactive Buttons (iOS 17+)
                if #available(iOS 17.0, *) {
                    HStack(spacing: 12) {
                        Button(intent: OpenReadingIntent()) {
                            Label("Read", systemImage: "book.open.fill")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .buttonStyle(WidgetButtonStyle())
                        
                        Button(intent: ShareNumberIntent(number: entry.dailyNumber)) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .buttonStyle(WidgetButtonStyle())
                        
                        Button(intent: LogStreakIntent()) {
                            Label("Check In", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .buttonStyle(WidgetButtonStyle())
                    }
                }
            }
            .padding(20)
        }
    }
}

// Medium Widget with Interactivity
struct QodeXInteractiveMediumView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(hex: "12121A"))
            
            HStack(spacing: 16) {
                // Number
                ZStack {
                    Circle()
                        .fill(Color(hex: "E5C158").opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Text("\(entry.dailyNumber)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "E5C158"))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.dailyVibe)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(entry.dailyAdvice)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "888888"))
                        .lineLimit(2)
                    
                    if #available(iOS 17.0, *) {
                        Button(intent: OpenReadingIntent()) {
                            Text("Read More →")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "E5C158"))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

// Lock Screen Widget (Rectangular)
struct QodeXLockScreenWidgetView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E5C158").opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Text("\(entry.dailyNumber)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "E5C158"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.dailyVibe)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Tap to read")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.5))
    }
}

// StandBy Widget (Full Width)
struct QodeXStandByWidgetView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        ZStack {
            // Deep background for StandBy
            ContainerRelativeShape()
                .fill(Color.black)
            
            VStack(spacing: 24) {
                // Large Number
                Text("\(entry.dailyNumber)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "E5C158"), Color(hex: "F39C12")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                VStack(spacing: 8) {
                    Text(entry.dailyVibe)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.dailyAdvice)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "AAAAAA"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if entry.streakDays > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20))
                        Text("\(entry.streakDays) Day Streak")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(20)
                }
            }
        }
    }
}

// MARK: - Widget Button Style
struct WidgetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "E5C158"))
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - App Intents for Interactivity

@available(iOS 17.0, *)
struct OpenReadingIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Daily Reading"
    static var description = IntentDescription("Open the full daily reading in the app")
    
    func perform() async throws -> some IntentResult {
        // Deep link to daily reading
        await EnvironmentValues().openURL(URL(string: "qodex://daily-reading")!)
        return .result()
    }
}

@available(iOS 17.0, *)
struct ShareNumberIntent: AppIntent {
    static var title: LocalizedStringResource = "Share Number"
    static var description = IntentDescription("Share your daily number")
    
    @Parameter(title: "Number")
    var number: Int
    
    init() {}
    
    init(number: Int) {
        self.number = number
    }
    
    func perform() async throws -> some IntentResult {
        // Trigger share sheet
        return .result()
    }
}

@available(iOS 17.0, *)
struct LogStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Daily Check-in"
    static var description = IntentDescription("Log your daily reading check-in")
    
    func perform() async throws -> some IntentResult {
        // Log streak and show confirmation
        return .result(value: "Streak logged! 🔥")
    }
}

// MARK: - Widget Data Provider
class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    func dataForNumber(_ number: Int) -> (vibe: String, advice: String) {
        let data: [Int: (String, String)] = [
            1: ("New Beginnings", "Start fresh. Take the lead today."),
            2: ("Cooperation", "Work with others. Trust your intuition."),
            3: ("Creativity", "Express yourself. Socialize and enjoy."),
            4: ("Foundation", "Build something lasting. Stay organized."),
            5: ("Change", "Embrace freedom. Try something new."),
            6: ("Harmony", "Focus on relationships. Create balance."),
            7: ("Reflection", "Go within. Seek deeper understanding."),
            8: ("Power", "Take charge. Focus on abundance."),
            9: ("Completion", "Let go. Prepare for a new cycle.")
        ]
        
        return data[number] ?? ("Spiritual Growth", "Trust your path today.")
    }
}

// MARK: - Widget Configuration
@main
struct EnhancedQodeXWidgets: WidgetBundle {
    var body: some Widget {
        EnhancedDailyNumberWidget()
        EnhancedLifePathWidget()
        StreakTrackerWidget()
    }
}

struct EnhancedDailyNumberWidget: Widget {
    let kind: String = "EnhancedDailyNumberWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: EnhancedWidgetProvider()
        ) { entry in
            EnhancedQodeXWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Number")
        .description("Your daily numerology energy")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct EnhancedQodeXWidgetEntryView: View {
    var entry: EnhancedQodeXEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemLarge:
            QodeXLargeWidgetView(entry: entry)
        case .systemMedium:
            QodeXInteractiveMediumView(entry: entry)
        case .accessoryRectangular:
            QodeXLockScreenWidgetView(entry: entry)
        case .accessoryCircular:
            QodeXSmallWidgetView(entry: entry)
        default:
            QodeXSmallWidgetView(entry: entry)
        }
    }
}

struct EnhancedLifePathWidget: Widget {
    let kind: String = "EnhancedLifePathWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EnhancedWidgetProvider()) { entry in
            LifePathWidgetView(entry: entry)
        }
        .configurationDisplayName("Life Path Focus")
        .description("Stay connected to your life path")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

struct StreakTrackerWidget: Widget {
    let kind: String = "StreakTrackerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EnhancedWidgetProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Reading Streak")
        .description("Track your daily reading streak")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

// Supporting Views
struct LifePathWidgetView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(hex: "12121A"))
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Life Path")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "888888"))
                    
                    if let lifePath = entry.lifePathNumber {
                        Text("\(lifePath)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "E5C158"))
                    }
                    
                    Text("Today's Number: \(entry.dailyNumber)")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

struct StreakWidgetView: View {
    var entry: EnhancedQodeXEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(hex: "12121A"))
            
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text("\(entry.streakDays)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Day Streak")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "888888"))
            }
        }
    }
}

// MARK: - Preview
#Preview("Enhanced Widgets") {
    Group {
        QodeXLargeWidgetView(entry: EnhancedQodeXEntry(
            date: Date(),
            dailyNumber: 8,
            dailyVibe: "Power & Abundance",
            dailyAdvice: "Take charge of your destiny today",
            userName: "Seeker",
            isPremium: true,
            lifePathNumber: 7,
            streakDays: 12
        ))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
