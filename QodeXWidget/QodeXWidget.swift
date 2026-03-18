import WidgetKit
import SwiftUI

struct DailyQodeEntry: TimelineEntry {
    let date: Date
    let dailyNumber: Int
    let dailyMessage: String
    let energyLevel: EnergyLevel
}

enum EnergyLevel: String {
    case high = "🔥"
    case medium = "⚡"
    case low = "🌊"
    case rest = "🌙"
}

struct DailyQodeProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyQodeEntry {
        DailyQodeEntry(
            date: Date(),
            dailyNumber: 7,
            dailyMessage: "A day for introspection and wisdom",
            energyLevel: .high
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailyQodeEntry) -> Void) {
        let entry = loadDailyQode()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyQodeEntry>) -> Void) {
        var entries: [DailyQodeEntry] = []
        let currentDate = Date()
        
        // Generate entries for next 24 hours
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = loadDailyQode(for: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadDailyQode(for date: Date = Date()) -> DailyQodeEntry {
        // Calculate daily number from date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let dailyNumber = calculateDailyNumber(day: day, month: month, year: year)
        let (message, energy) = getDailyMessage(number: dailyNumber)
        
        return DailyQodeEntry(
            date: date,
            dailyNumber: dailyNumber,
            dailyMessage: message,
            energyLevel: energy
        )
    }
    
    private func calculateDailyNumber(day: Int, month: Int, year: Int) -> Int {
        var sum = day + month + year
        while sum > 9 && sum != 11 && sum != 22 && sum != 33 {
            sum = String(sum).compactMap { Int(String($0)) }.reduce(0, +)
        }
        return sum
    }
    
    private func getDailyMessage(number: Int) -> (String, EnergyLevel) {
        let messages: [Int: (String, EnergyLevel)] = [
            1: ("Leadership and new beginnings", .high),
            2: ("Cooperation and balance", .medium),
            3: ("Creativity and expression", .high),
            4: ("Stability and hard work", .medium),
            5: ("Change and adventure", .high),
            6: ("Harmony and nurturing", .low),
            7: ("Introspection and wisdom", .low),
            8: ("Success and abundance", .high),
            9: ("Completion and compassion", .medium),
            11: ("Spiritual insight", .high),
            22: ("Master builder energy", .high),
            33: ("Master teacher guidance", .medium)
        ]
        return messages[number] ?? ("A day of possibilities", .medium)
    }
}

struct QodeXWidgetEntryView: View {
    var entry: DailyQodeProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: DailyQodeEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color("WidgetBackground"))
            
            VStack(spacing: 8) {
                Text("Daily Qode")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(entry.dailyNumber)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("QodeGold"))
                
                Text(entry.energyLevel.rawValue)
                    .font(.title2)
            }
        }
    }
}

struct MediumWidgetView: View {
    let entry: DailyQodeEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color("WidgetBackground"))
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(entry.dailyNumber)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color("QodeGold"))
                    
                    Text(entry.energyLevel.rawValue)
                        .font(.title)
                }
                .frame(width: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Energy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.dailyMessage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(3)
                    
                    Text(entry.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

struct LargeWidgetView: View {
    let entry: DailyQodeEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color("WidgetBackground"))
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Daily Qode")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(entry.energyLevel.rawValue)
                        .font(.largeTitle)
                }
                
                HStack {
                    Text("\(entry.dailyNumber)")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundColor(Color("QodeGold"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.dailyMessage)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(getExtendedMessage(number: entry.dailyNumber))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
            }
            .padding()
        }
    }
    
    private func getExtendedMessage(number: Int) -> String {
        let extended: [Int: String] = [
            1: "Today favors new beginnings. Take the lead on projects and trust your instincts.",
            2: "Focus on partnerships and diplomacy. Listen more than you speak today.",
            3: "Express yourself creatively. Social connections bring joy and inspiration.",
            4: "Build solid foundations. Attention to detail will serve you well.",
            5: "Embrace change and spontaneity. Adventure awaits those who seek it.",
            6: "Nurture relationships and home. Family and harmony take priority.",
            7: "Go within. Research, study, and spiritual practices are favored.",
            8: "Focus on career and finances. Your efforts yield tangible results.",
            9: "Complete what you've started. Service to others brings fulfillment.",
            11: "Trust your intuition. Spiritual insights and dreams carry messages.",
            22: "Think big and build for the future. Your vision can become reality.",
            33: "Teach and guide others. Your wisdom impacts many lives today."
        ]
        return extended[number] ?? "Stay mindful and trust the journey."
    }
}

@main
struct QodeXWidget: Widget {
    let kind: String = "QodeXWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyQodeProvider()) { entry in
            QodeXWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Qode")
        .description("Your daily numerology guidance at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
