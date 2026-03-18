//
//  YearlyForecastView.swift
//  QodeX
//
//  Annual numerology forecast with glassmorphism design
//

import SwiftUI
import Charts

// MARK: - Data Models

struct YearlyForecast: Identifiable {
    let id = UUID()
    let year: Int
    let personalYearNumber: Int
    let theme: String
    let overallVibe: String
    let challenges: [String]
    let opportunities: [String]
    let keyDates: [KeyDate]
    let monthlyForecasts: [MonthlyForecast]
}

struct KeyDate: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let significance: String
    let type: KeyDateType
}

enum KeyDateType: String, CaseIterable {
    case power = "Power"
    case caution = "Caution"
    case opportunity = "Opportunity"
    case reflection = "Reflection"
    
    var color: Color {
        switch self {
        case .power: return .purple
        case .caution: return .red
        case .opportunity: return Color(hex: "#E5C158")
        case .reflection: return .cyan
        }
    }
    
    var icon: String {
        switch self {
        case .power: return "bolt.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .opportunity: return "star.fill"
        case .reflection: return "moon.fill"
        }
    }
}

struct MonthlyForecast: Identifiable {
    let id = UUID()
    let month: Int
    let monthName: String
    let energy: Int
    let theme: String
    let advice: String
    let focus: String
    let color: Color
}

// MARK: - View Model

class YearlyForecastViewModel: ObservableObject {
    @Published var forecast: YearlyForecast
    @Published var selectedMonth: Int?
    @Published var showShareSheet = false
    
    init() {
        self.forecast = YearlyForecast(
            year: Calendar.current.component(.year, from: Date()),
            personalYearNumber: 7,
            theme: "The Year of Inner Wisdom",
            overallVibe: "A time for introspection, spiritual growth, and uncovering hidden truths",
            challenges: [
                "Resisting the urge to rush ahead without reflection",
                "Dealing with feelings of isolation during deep work periods",
                "Balancing practical needs with spiritual pursuits"
            ],
            opportunities: [
                "Deepening your understanding of yourself and your path",
                "Developing intuition and inner guidance systems",
                "Making breakthroughs in long-standing problems",
                "Building knowledge and expertise in your field"
            ],
            keyDates: [
                KeyDate(date: Date.from(month: 3, day: 15), title: "Personal Power Day", significance: "Your energy peaks—ideal for important decisions", type: .power),
                KeyDate(date: Date.from(month: 6, day: 7), title: "Karmic Reflection", significance: "Review and release what no longer serves", type: .reflection),
                KeyDate(date: Date.from(month: 9, day: 23), title: "Golden Opportunity", significance: "Unexpected doors open in career/finance", type: .opportunity),
                KeyDate(date: Date.from(month: 11, day: 11), title: "Mind the Details", significance: "Double-check all contracts and agreements", type: .caution)
            ],
            monthlyForecasts: [
                MonthlyForecast(month: 1, monthName: "January", energy: 8, theme: "Foundation Building", advice: "Start the year with clear intentions. Set goals that align with your deeper purpose.", focus: "Career & Structure", color: .blue),
                MonthlyForecast(month: 2, monthName: "February", energy: 9, theme: "Emotional Flow", advice: "Let go of what you cannot control. Trust the process.", focus: "Relationships & Healing", color: .pink),
                MonthlyForecast(month: 3, monthName: "March", energy: 1, theme: "New Beginnings", advice: "Plant seeds for future growth. Be bold in your vision.", focus: "Creativity & Initiative", color: .green),
                MonthlyForecast(month: 4, monthName: "April", energy: 2, theme: "Partnership Focus", advice: "Collaboration brings success. Listen more than you speak.", focus: "Teamwork & Harmony", color: .orange),
                MonthlyForecast(month: 5, monthName: "May", energy: 3, theme: "Expressive Energy", advice: "Share your ideas with the world. Communication is key.", focus: "Self-Expression", color: .yellow),
                MonthlyForecast(month: 6, monthName: "June", energy: 4, theme: "Inner Foundation", advice: "Build strong roots. Stability brings freedom.", focus: "Home & Security", color: .brown),
                MonthlyForecast(month: 7, monthName: "July", energy: 5, theme: "Freedom & Change", advice: "Embrace the unexpected. Flexibility is your strength.", focus: "Adventure & Growth", color: .purple),
                MonthlyForecast(month: 8, monthName: "August", energy: 6, theme: "Heart Centered", advice: "Lead with love. Your relationships need attention.", focus: "Love & Family", color: .red),
                MonthlyForecast(month: 9, monthName: "September", energy: 7, theme: "Deep Reflection", advice: "Go within. The answers you seek are inside you.", focus: "Spirituality & Wisdom", color: .indigo),
                MonthlyForecast(month: 10, monthName: "October", energy: 8, theme: "Manifestation", advice: "Your efforts bear fruit. Harvest what you've sown.", focus: "Achievement & Power", color: .teal),
                MonthlyForecast(month: 11, monthName: "November", energy: 9, theme: "Completion", advice: "Finish what you started. Closure brings new beginnings.", focus: "Release & Gratitude", color: .mint),
                MonthlyForecast(month: 12, monthName: "December", energy: 1, theme: "Preparation", advice: "Rest and recharge. The best is yet to come.", focus: "Rest & Renewal", color: .cyan)
            ]
        )
    }
    
    func calculatePersonalYear(birthDate: Date, targetYear: Int) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: birthDate)
        let birthMonth = components.month ?? 1
        let birthDay = components.day ?? 1
        
        let sum = birthMonth + birthDay + targetYear
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 && result != 11 && result != 22 && result != 33 {
            result = String(result).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return result
    }
    
    func shareForecast() -> String {
        """
        ✨ My Numerology Forecast for \(forecast.year) ✨
        
        Personal Year: \(forecast.personalYearNumber)
        Theme: \(forecast.theme)
        
        \(forecast.overallVibe)
        
        🔮 Key Opportunities:
        \(forecast.opportunities.prefix(3).map { "• \($0)" }.joined(separator: "\n"))
        
        📅 Notable Dates:
        \(forecast.keyDates.map { "• \($0.date.formatted(.dateTime.month().day())): \($0.title)" }.joined(separator: "\n"))
        
        Shared from QodeX Numerology
        """
    }
}

// MARK: - Main View

struct YearlyForecastView: View {
    @StateObject private var viewModel = YearlyForecastViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSegment = 0
    
    private let segments = ["Overview", "Timeline", "Monthly", "Key Dates"]
    
    var body: some View {
        ZStack {
            // Dynamic Background
            ForecastBackground()
            
            ScrollView {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Hero Section with Large Year Display
                    YearHeroSection(forecast: viewModel.forecast, scrollOffset: scrollOffset)
                    
                    // Segmented Control
                    SegmentedControl(
                        segments: segments,
                        selectedIndex: $selectedSegment
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content based on selected segment
                    Group {
                        switch selectedSegment {
                        case 0:
                            OverviewSection(forecast: viewModel.forecast)
                        case 1:
                            TimelineSection(forecast: viewModel.forecast)
                        case 2:
                            MonthlyGridSection(forecast: viewModel.forecast, selectedMonth: $viewModel.selectedMonth)
                        case 3:
                            KeyDatesSection(keyDates: viewModel.forecast.keyDates)
                        default:
                            OverviewSection(forecast: viewModel.forecast)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Share Button
                    ShareButton {
                        viewModel.showShareSheet = true
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(activityItems: [viewModel.shareForecast()])
        }
        .sheet(item: $viewModel.selectedMonth) { month in
            if let forecast = viewModel.forecast.monthlyForecasts.first(where: { $0.month == month }) {
                MonthlyDetailSheet(forecast: forecast)
            }
        }
    }
}

// MARK: - Background

struct ForecastBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0F0F1A"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated gold orbs
            GeometryReader { geo in
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: animate ? geo.size.width * 0.7 : geo.size.width * 0.3,
                        y: animate ? geo.size.height * 0.3 : geo.size.height * 0.2
                    )
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(
                        x: animate ? geo.size.width * 0.1 : geo.size.width * 0.5,
                        y: animate ? geo.size.height * 0.6 : geo.size.height * 0.4
                    )
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
            }
            .ignoresSafeArea()
        }
        .onAppear { animate = true }
    }
}

// MARK: - Hero Section

struct YearHeroSection: View {
    let forecast: YearlyForecast
    let scrollOffset: CGFloat
    
    private var yearScale: CGFloat {
        let offset = max(0, -scrollOffset)
        return max(0.6, 1 - offset / 400)
    }
    
    private var yearOpacity: Double {
        let offset = max(0, -scrollOffset)
        return max(0.3, 1 - offset / 300)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Large Year Display
            ZStack {
                // Glow effect
                Text("\(forecast.year)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#E5C158").opacity(0.3))
                    .blur(radius: 20)
                
                // Main year number
                Text("\(forecast.year)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#E5C158"), Color(hex: "#F5E6A3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#E5C158").opacity(0.5), radius: 30, x: 0, y: 0)
            }
            .scaleEffect(yearScale)
            .opacity(yearOpacity)
            
            // Personal Year Badge
            GlassContainer {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(forecast.personalYearNumber)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Text("Personal Year")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(width: 80)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(forecast.theme)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(forecast.overallVibe)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

// MARK: - Segmented Control

struct SegmentedControl: View {
    let segments: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        GlassContainer(cornerRadius: 16) {
            HStack(spacing: 4) {
                ForEach(segments.indices, id: \.self) { index in
                    Button(action: { selectedIndex = index }) {
                        Text(segments[index])
                            .font(.subheadline)
                            .fontWeight(selectedIndex == index ? .semibold : .medium)
                            .foregroundColor(selectedIndex == index ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedIndex == index ?
                                Color(hex: "#E5C158") :
                                Color.clear
                            )
                            .cornerRadius(12)
                    }
                }
            }
            .padding(4)
        }
    }
}

// MARK: - Overview Section

struct OverviewSection: View {
    let forecast: YearlyForecast
    
    var body: some View {
        VStack(spacing: 20) {
            // Challenges & Opportunities
            HStack(spacing: 16) {
                ChallengeOpportunityCard(
                    title: "Challenges",
                    items: forecast.challenges,
                    icon: "exclamationmark.circle.fill",
                    color: .red.opacity(0.8)
                )
                
                ChallengeOpportunityCard(
                    title: "Opportunities",
                    items: forecast.opportunities.prefix(3).map { $0 },
                    icon: "star.circle.fill",
                    color: Color(hex: "#E5C158")
                )
            }
            .padding(.horizontal)
            
            // Energy Chart
            EnergyChartCard(monthlyForecasts: forecast.monthlyForecasts)
                .padding(.horizontal)
        }
    }
}

struct ChallengeOpportunityCard: View {
    let title: String
    let items: [String]
    let icon: String
    let color: Color
    
    var body: some View {
        GlassContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items.prefix(3), id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(color)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            
                            Text(item)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct EnergyChartCard: View {
    let monthlyForecasts: [MonthlyForecast]
    
    var body: some View {
        GlassContainer {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Energy Flow")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color(hex: "#E5C158"))
                }
                
                // Energy bar chart
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(monthlyForecasts) { month in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [month.color, month.color.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: CGFloat(month.energy) * 8)
                            
                            Text("\(month.month)")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
            }
        }
    }
}

// MARK: - Timeline Section

struct TimelineSection: View {
    let forecast: YearlyForecast
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(forecast.monthlyForecasts.enumerated()), id: \.element.id) { index, month in
                TimelineRow(
                    month: month,
                    isFirst: index == 0,
                    isLast: index == forecast.monthlyForecasts.count - 1
                )
            }
        }
        .padding(.horizontal)
    }
}

struct TimelineRow: View {
    let month: MonthlyForecast
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline line
            ZStack {
                // Vertical line
                VStack(spacing: 0) {
                    if !isFirst {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 2, height: 20)
                    } else {
                        Spacer().frame(height: 20)
                    }
                    
                    Circle()
                        .strokeBorder(Color(hex: "#E5C158"), lineWidth: 2)
                        .background(Circle().fill(month.color.opacity(0.3)))
                        .frame(width: 16, height: 16)
                    
                    if !isLast {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 2, height: 20)
                    } else {
                        Spacer().frame(height: 20)
                    }
                }
            }
            .frame(width: 20)
            
            // Content
            GlassContainer {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(month.monthName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("\(month.energy)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(hex: "#E5C158"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#E5C158").opacity(0.2))
                        )
                    }
                    
                    Text(month.theme)
                        .font(.subheadline)
                        .foregroundColor(month.color)
                        .fontWeight(.medium)
                    
                    Text(month.focus)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Monthly Grid Section

struct MonthlyGridSection: View {
    let forecast: YearlyForecast
    @Binding var selectedMonth: Int?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(forecast.monthlyForecasts) { month in
                MonthlyCard(forecast: month)
                    .onTapGesture {
                        selectedMonth = month.month
                    }
            }
        }
        .padding(.horizontal)
    }
}

struct MonthlyCard: View {
    let forecast: MonthlyForecast
    @State private var isHovered = false
    
    var body: some View {
        GlassContainer(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(forecast.monthName.prefix(3))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(forecast.color.opacity(0.3))
                            .frame(width: 32, height: 32)
                        
                        Text("\(forecast.energy)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(forecast.color)
                    }
                }
                
                Text(forecast.theme)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#E5C158"))
                
                Text(forecast.advice)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Advice tag
                Text(forecast.focus)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .frame(height: 140)
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Key Dates Section

struct KeyDatesSection: View {
    let keyDates: [KeyDate]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(keyDates) { date in
                KeyDateCard(keyDate: date)
            }
        }
        .padding(.horizontal)
    }
}

struct KeyDateCard: View {
    let keyDate: KeyDate
    
    var body: some View {
        GlassContainer {
            HStack(spacing: 16) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(keyDate.type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: keyDate.type.icon)
                        .font(.title3)
                        .foregroundColor(keyDate.type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(keyDate.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(keyDate.date.formatted(.dateTime.month().day()))
                            .font(.caption)
                            .foregroundColor(Color(hex: "#E5C158"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#E5C158").opacity(0.2))
                            )
                    }
                    
                    Text(keyDate.significance)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(keyDate.type.rawValue)
                        .font(.caption2)
                        .foregroundColor(keyDate.type.color)
                        .padding(.top, 2)
                }
            }
        }
    }
}

// MARK: - Monthly Detail Sheet

struct MonthlyDetailSheet: View {
    let forecast: MonthlyForecast
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ForecastBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text(forecast.monthName)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(forecast.theme)
                                .font(.title2)
                                .foregroundColor(Color(hex: "#E5C158"))
                        }
                        
                        // Energy badge
                        GlassContainer {
                            HStack(spacing: 20) {
                                VStack {
                                    Text("\(forecast.energy)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(forecast.color)
                                    Text("Energy")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                VStack(alignment: .leading) {
                                    Text("Focus Area")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(forecast.focus)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Advice Card
                        GlassContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color(hex: "#E5C158"))
                                    
                                    Text("Monthly Advice")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Text(forecast.advice)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Action Items
                        GlassContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Action Steps")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ActionItem(text: "Set clear intentions for \(forecast.monthName)")
                                    ActionItem(text: "Focus on \(forecast.focus.lowercased())")
                                    ActionItem(text: "Journal about your progress weekly")
                                    ActionItem(text: "Practice gratitude daily")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#E5C158"))
                }
            }
        }
    }
}

struct ActionItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Share Button

struct ShareButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Forecast")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(hex: "#E5C158"), Color(hex: "#F5E6A3")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

// MARK: - Reusable Components

struct GlassContainer<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Helper Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Date {
    static func from(month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = Calendar.current.component(.year, from: Date())
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

struct YearlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyForecastView()
            .preferredColorScheme(.dark)
    }
}
