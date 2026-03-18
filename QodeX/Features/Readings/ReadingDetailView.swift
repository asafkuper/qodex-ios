//
//  ReadingDetailView.swift
//  QodeX - Premium Daily Reading Detail
//  Inspired by Apple Health, Day One
//

import SwiftUI

struct ReadingDetailView: View {
    let reading: DailyReading
    @State private var isBookmarked = false
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            // Background based on number energy
            reading.numberColor.opacity(0.1)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Date Header
                    DateHeader(reading: reading)
                    
                    // Number Hero
                    NumberHero(reading: reading)
                    
                    // Energy Description
                    EnergyCard(reading: reading)
                    
                    // Lucky Elements
                    LuckyElementsCard(reading: reading)
                    
                    // Affirmation
                    AffirmationCard(reading: reading)
                    
                    // Actionable Advice
                    AdviceSection(reading: reading)
                    
                    // Navigation
                    DayNavigation()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { isBookmarked.toggle() }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 20))
                            .foregroundColor(isBookmarked ? .goldPrimary : .starlight)
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.starlight)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareReadingView(reading: reading)
        }
    }
}

// MARK: - Daily Reading Model
struct DailyReading {
    let date: Date
    let number: Int
    let title: String
    let description: String
    let energy: String
    let luckyColors: [String]
    let luckyNumbers: [Int]
    let affirmation: String
    let advice: [String]
    let lunarPhase: String
    let numberColor: Color
}

// MARK: - Date Header
struct DateHeader: View {
    let reading: DailyReading
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.starlight)
                
                HStack(spacing: 8) {
                    Text("🌙")
                        .font(.system(size: 16))
                    
                    Text(reading.lunarPhase)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.starlightTertiary)
                }
            }
            
            Spacer()
            
            // Day number badge
            ZStack {
                Circle()
                    .fill(reading.numberColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 0) {
                    Text("DAY")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(reading.numberColor)
                    
                    Text("\(Calendar.current.component(.day, from: reading.date))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.starlight)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: reading.date)
    }
}

// MARK: - Number Hero
struct NumberHero: View {
    let reading: DailyReading
    
    var body: some View {
        VStack(spacing: 16) {
            // Large number with glow
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                reading.numberColor.opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                // Number
                Text("\(reading.number)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [reading.numberColor.opacity(0.8), reading.numberColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: reading.numberColor.opacity(0.5), radius: 30, x: 0, y: 0)
            }
            .frame(height: 200)
            
            // Title
            Text(reading.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.starlight)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }
}

// MARK: - Energy Card
struct EnergyCard: View {
    let reading: DailyReading
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(reading.numberColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: reading.numberColor, radius: 10, x: 0, y: 0)
                    
                    Text("Today's Energy")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(reading.numberColor)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(reading.energy)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.starlight)
                
                Text(reading.description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

// MARK: - Lucky Elements Card
struct LuckyElementsCard: View {
    let reading: DailyReading
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.goldPrimary)
                        .frame(width: 8, height: 8)
                        .shadow(color: .goldPrimary, radius: 10, x: 0, y: 0)
                    
                    Text("Lucky Elements")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                HStack(spacing: 24) {
                    // Lucky Colors
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.starlightTertiary)
                            
                            Text("Colors")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.starlightTertiary)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(reading.luckyColors, id: \.self) { color in
                                ColorSwatch(colorName: color)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Lucky Numbers
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "number")
                                .font(.system(size: 14))
                                .foregroundColor(.starlightTertiary)
                            
                            Text("Numbers")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.starlightTertiary)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(reading.luckyNumbers, id: \.self) { number in
                                LuckyNumberPill(number: number)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct ColorSwatch: View {
    let colorName: String
    
    var color: Color {
        switch colorName.lowercased() {
        case "gold": return .goldPrimary
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(colorName.capitalized)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
    }
}

struct LuckyNumberPill: View {
    let number: Int
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.goldPrimary)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.goldPrimary.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Affirmation Card
struct AffirmationCard: View {
    let reading: DailyReading
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 16))
                        .foregroundColor(.pink)
                    
                    Text("Daily Affirmation")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.pink)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(reading.affirmation)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.starlight)
                    .italic()
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: - Advice Section
struct AdviceSection: View {
    let reading: DailyReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actionable Advice")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(Array(reading.advice.enumerated()), id: \.element) { index, advice in
                    AdviceRow(number: index + 1, advice: advice)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
    }
}

struct AdviceRow: View {
    let number: Int
    let advice: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number
            ZStack {
                Circle()
                    .fill(Color.goldPrimary.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.goldPrimary)
            }
            
            Text(advice)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(4)
                .padding(.top, 6)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Day Navigation
struct DayNavigation: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationButton(direction: .previous)
            
            Spacer()
            
            Text("Today")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.starlightTertiary)
            
            Spacer()
            
            NavigationButton(direction: .next)
        }
    }
}

enum NavigationDirection {
    case previous, next
    
    var icon: String {
        switch self {
        case .previous: return "chevron.left"
        case .next: return "chevron.right"
        }
    }
}

struct NavigationButton: View {
    let direction: NavigationDirection
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: direction.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.starlight)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// MARK: - Share Reading View
struct ShareReadingView: View {
    let reading: DailyReading
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Shareable Card
                    ShareableCard(reading: reading)
                    
                    // Share Options
                    VStack(spacing: 12) {
                        ShareButton(title: "Share to Instagram Stories", icon: "camera.fill", color: .purple)
                        ShareButton(title: "Share to Messages", icon: "message.fill", color: .green)
                        ShareButton(title: "Copy Link", icon: "link", color: .blue)
                        ShareButton(title: "Save Image", icon: "square.and.arrow.down", color: .goldPrimary)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Share Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.goldPrimary)
                }
            }
        }
    }
}

struct ShareableCard: View {
    let reading: DailyReading
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("QODE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.goldPrimary)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            // Number
            Text("\(reading.number)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.goldBright, .goldPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Title
            Text(reading.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
                .multilineTextAlignment(.center)
            
            // Affirmation
            Text(reading.affirmation)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.starlightSecondary)
                .multilineTextAlignment(.center)
                .italic()
                .lineLimit(2)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: reading.date)
    }
}

struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.1))
                    )
                
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.starlightQuaternary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sample Data
let sampleReading = DailyReading(
    date: Date(),
    number: 8,
    title: "Power & Abundance",
    description: "The energy of 8 brings opportunities for financial growth and career advancement. This is a day to take charge, make bold decisions, and step into your authority. The universe supports your ambitions today.",
    energy: "Today's vibration is one of power, abundance, and material success. The number 8 represents the balance between the spiritual and material worlds.",
    luckyColors: ["Gold", "Purple", "Black"],
    luckyNumbers: [8, 17, 26, 35],
    affirmation: "I am worthy of abundance and success. I claim my power and create my reality.",
    advice: [
        "Take the lead in meetings and presentations",
        "Make important financial decisions",
        "Ask for that raise or promotion",
        "Focus on long-term goals rather than short-term comforts"
    ],
    lunarPhase: "Waxing Gibbous",
    numberColor: .goldPrimary
)

// MARK: - Preview
struct ReadingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadingDetailView(reading: sampleReading)
        }
        .preferredColorScheme(.dark)
    }
}
