//
//  WatchComplication.swift
//  Apple Watch complications for numerology
//

import ClockKit
import SwiftUI

@main
struct QodeXWatchComplications: WidgetBundle {
    var body: some Widget {
        DailyNumberComplication()
        StreakComplication()
        NextSessionComplication()
    }
}

// MARK: - Daily Number Complication
struct DailyNumberComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.qodex.dailynumber",
            provider: DailyNumberProvider()
        ) { entry in
            DailyNumberView(entry: entry)
        }
        .configurationDisplayName("Daily Number")
        .description("Your daily numerology number")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

struct DailyNumberEntry: TimelineEntry {
    let date: Date
    let number: Int
    let vibe: String
}

struct DailyNumberProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyNumberEntry {
        DailyNumberEntry(date: Date(), number: 7, vibe: "Spiritual Growth")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailyNumberEntry) -> Void) {
        let entry = getEntry(for: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyNumberEntry>) -> Void) {
        var entries: [DailyNumberEntry] = []
        
        // Generate entries for next 24 hours
        let currentDate = Date()
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(getEntry(for: entryDate))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getEntry(for date: Date) -> DailyNumberEntry {
        let calculator = NumerologyCalculator()
        let number = calculator.calculateDailyNumber(for: date)
        let vibes = ["", "New Beginnings", "Partnership", "Creativity", "Foundation", "Freedom", "Harmony", "Wisdom", "Abundance", "Completion"]
        
        return DailyNumberEntry(
            date: date,
            number: number,
            vibe: vibes[number]
        )
    }
}

struct DailyNumberView: View {
    let entry: DailyNumberEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(number: entry.number)
        case .accessoryCorner:
            CornerView(number: entry.number, vibe: entry.vibe)
        case .accessoryInline:
            InlineView(number: entry.number)
        case .accessoryRectangular:
            RectangularView(number: entry.number, vibe: entry.vibe)
        default:
            CircularView(number: entry.number)
        }
    }
}

struct CircularView: View {
    let number: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gold, lineWidth: 3)
            
            Text("\(number)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.gold)
        }
    }
}

struct CornerView: View {
    let number: Int
    let vibe: String
    
    var body: some View {
        HStack {
            Image(systemName: "number.circle.fill")
                .foregroundColor(.gold)
            
            VStack(alignment: .leading) {
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.gold)
                
                Text(vibe)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
    }
}

struct InlineView: View {
    let number: Int
    
    var body: some View {
        HStack {
            Image(systemName: "number")
                .foregroundColor(.gold)
            Text("\(number)")
                .foregroundColor(.gold)
        }
    }
}

struct RectangularView: View {
    let number: Int
    let vibe: String
    
    var body: some View {
        HStack {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.gold)
            
            VStack(alignment: .leading) {
                Text("Today's Number")
                    .font(.caption)
                Text(vibe)
                    .font(.caption2)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

// MARK: - Streak Complication
struct StreakComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.qodex.streak",
            provider: StreakProvider()
        ) { entry in
            StreakView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Your current check-in streak")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 7)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        // Get from UserDefaults or shared container
        let streak = UserDefaults.standard.integer(forKey: "currentStreak")
        completion(StreakEntry(date: Date(), streak: streak))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
}

struct StreakView: View {
    let entry: StreakEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            
            Text("\(entry.streak)")
                .font(.headline)
                .foregroundColor(.gold)
        }
    }
}

// MARK: - Next Session Complication
struct NextSessionComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.qodex.nextsession",
            provider: NextSessionProvider()
        ) { entry in
            NextSessionView(entry: entry)
        }
        .configurationDisplayName("Next Session")
        .description("Time until your next live session")
        .supportedFamilies([.accessoryCorner, .accessoryRectangular])
    }
}

struct NextSessionEntry: TimelineEntry {
    let date: Date
    let sessionName: String
    let timeRemaining: TimeInterval
}

struct NextSessionProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextSessionEntry {
        NextSessionEntry(date: Date(), sessionName: "Meditation", timeRemaining: 3600)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextSessionEntry) -> Void) {
        // Fetch from Firestore or shared container
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextSessionEntry>) -> Void) {
        // Update every minute
        var entries: [NextSessionEntry] = []
        let now = Date()
        
        for minute in 0..<60 {
            let date = now.addingTimeInterval(TimeInterval(minute * 60))
            entries.append(NextSessionEntry(
                date: date,
                sessionName: "Live Session",
                timeRemaining: 3600 - TimeInterval(minute * 60)
            ))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct NextSessionView: View {
    let entry: NextSessionEntry
    
    var body: some View {
        HStack {
            Image(systemName: "video.fill")
                .foregroundColor(.gold)
            
            VStack(alignment: .leading) {
                Text(entry.sessionName)
                    .font(.caption)
                
                Text(formatDuration(entry.timeRemaining))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.gold)
            }
        }
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
