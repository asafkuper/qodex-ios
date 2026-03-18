//
//  NumerologyJournalView.swift
//  Daily journal with numerology insights
//

import SwiftUI

struct NumerologyJournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with date navigation
                dateHeader
                
                // Calendar strip
                calendarStrip
                
                // Journal content
                ScrollView {
                    VStack(spacing: 24) {
                        // Daily numerology card
                        dailyNumerologyCard
                        
                        // Journal entry
                        journalEntrySection
                        
                        // Reflection prompts
                        if viewModel.currentEntry.prompts.isEmpty == false {
                            promptsSection
                        }
                        
                        // Patterns insights
                        if viewModel.showPatterns {
                            patternsSection
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var dateHeader: some View {
        HStack {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(QodeXColors.gold)
            }
            .accessibilityLabel("Previous day")
            .accessibilityHint("Navigate to the previous day's journal entry")
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 14))
                    .foregroundStyle(QodeXColors.stardust)
                
                Text(selectedDate.formatted(.dateTime.month().day()))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
            }
            .accessibilityLabel("Selected date: \(selectedDate.formatted(.dateTime.weekday(.wide))), \(selectedDate.formatted(.dateTime.month().day()))")
            
            Spacer()
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(QodeXColors.gold)
            }
            .accessibilityLabel("Next day")
            .accessibilityHint("Navigate to the next day's journal entry")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var calendarStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.weekDays, id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasEntry: viewModel.hasEntry(for: date),
                        number: viewModel.personalDayNumber(for: date)
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedDate = date
                        }
                    }
                    .accessibilityLabel("\(date.formatted(.dateTime.weekday(.wide))), \(date.formatted(.dateTime.month().day())), Personal day number \(viewModel.personalDayNumber(for: date))")
                    .accessibilityHint("Double tap to select this date")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
    
    private var dailyNumerologyCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Numbers")
                        .font(QodeXTypography.caption)
                        .foregroundStyle(QodeXColors.stardust)
                    
                    Text("Personal Day \(viewModel.currentEntry.personalDay)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                }
                
                Spacer()
                
                // Number circle
                ZStack {
                    Circle()
                        .fill(QodeXColors.gold.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("\(viewModel.currentEntry.personalDay)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(QodeXColors.gold)
                }
            }
            
            Divider()
                .background(QodeXColors.starlight.opacity(0.3))
            
            Text(viewModel.currentEntry.numerologyInsight)
                .font(.system(size: 14))
                .foregroundStyle(QodeXColors.moonlight)
                .lineLimit(3)
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var journalEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Reflection")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                if viewModel.currentEntry.lastSaved != nil {
                    Text("Saved")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.cosmicTeal)
                        .accessibilityLabel("Entry saved")
                }
            }
            .padding(.horizontal, 20)
            
            TextEditor(text: $viewModel.currentEntry.content)
                .font(.system(size: 16))
                .foregroundStyle(QodeXColors.pureWhite)
                .scrollContentBackground(.hidden)
                .background(QodeXColors.deepVoid)
                .cornerRadius(16)
                .frame(minHeight: 200)
                .padding(.horizontal, 20)
                .onChange(of: viewModel.currentEntry.content) { _ in
                    viewModel.scheduleSave()
                }
                .accessibilityLabel("Journal entry text field")
                .accessibilityHint("Write your daily reflections and thoughts here")
        }
    }
    
    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reflection Prompts")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                ForEach(viewModel.currentEntry.prompts, id: \.self) { prompt in
                    PromptCard(prompt: prompt) {
                        viewModel.usePrompt(prompt)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Patterns")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                PatternInsightCard(
                    title: "Recurring Themes",
                    insight: "You've mentioned 'growth' 12 times this month",
                    icon: "chart.line.uptrend.xyaxis",
                    color: QodeXColors.gold
                )
                
                PatternInsightCard(
                    title: "Number Synchronicities",
                    insight: "You've seen 11:11 on 5 different days",
                    icon: "number",
                    color: QodeXColors.mysticPurple
                )
                
                PatternInsightCard(
                    title: "Emotional Cycle",
                    insight: "Your entries are most positive on Personal Day 3",
                    icon: "heart.fill",
                    color: QodeXColors.cosmicTeal
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
    
    private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
    }
}

// MARK: - Supporting Views

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEntry: Bool
    let number: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Text(date.formatted(.dateTime.weekday(.narrow)))
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? QodeXColors.gold : QodeXColors.stardust)
            
            ZStack {
                Circle()
                    .fill(isSelected ? QodeXColors.gold : QodeXColors.deepVoid)
                    .frame(width: 40, height: 40)
                
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? QodeXColors.cosmicBlack : QodeXColors.pureWhite)
            }
            
            // Personal day number indicator
            ZStack {
                Circle()
                    .fill(QodeXColors.starlight)
                    .frame(width: 16, height: 16)
                
                Text("\(number)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(QodeXColors.pureWhite)
            }
            .opacity(isSelected ? 1 : 0.7)
            
            // Entry indicator
            Circle()
                .fill(QodeXColors.gold)
                .frame(width: 4, height: 4)
                .opacity(hasEntry ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(isSelected ? QodeXColors.gold.opacity(0.1) : Color.clear)
        .cornerRadius(12)
    }
}

struct PromptCard: View {
    let prompt: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(QodeXColors.gold)
                
                Text(prompt)
                    .font(.system(size: 14))
                    .foregroundStyle(QodeXColors.pureWhite)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundStyle(QodeXColors.stardust)
            }
            .padding(12)
            .background(QodeXColors.deepVoid)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Prompt: \(prompt)")
        .accessibilityHint("Double tap to add this prompt to your journal entry")
    }
}

struct PatternInsightCard: View {
    let title: String
    let insight: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text(insight)
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

// MARK: - View Model

class JournalViewModel: ObservableObject {
    @Published var currentEntry: JournalEntry = JournalEntry.empty
    @Published var weekDays: [Date] = []
    @Published var showPatterns = true
    
    private var saveTimer: Timer?
    private let calendar = Calendar.current
    
    init() {
        generateWeekDays()
        loadEntry(for: Date())
    }
    
    private func generateWeekDays() {
        let today = Date()
        weekDays = (-3...3).map { offset in
            calendar.date(byAdding: .day, value: offset, to: today)!
        }
    }
    
    func hasEntry(for date: Date) -> Bool {
        // Check if entry exists
        return Bool.random() // Mock
    }
    
    func personalDayNumber(for date: Date) -> Int {
        // Calculate based on user's chart
        return Int.random(in: 1...9) // Mock
    }
    
    func loadEntry(for date: Date) {
        // Load from Firestore or create new
        currentEntry = JournalEntry(
            date: date,
            content: "",
            personalDay: personalDayNumber(for: date),
            numerologyInsight: generateInsight(for: date),
            prompts: generatePrompts(for: date),
            lastSaved: nil
        )
    }
    
    func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.saveEntry()
        }
    }
    
    private func saveEntry() {
        // Save to Firestore
        currentEntry.lastSaved = Date()
    }
    
    func usePrompt(_ prompt: String) {
        if currentEntry.content.isEmpty {
            currentEntry.content = prompt + "\n\n"
        } else {
            currentEntry.content += "\n\n" + prompt + "\n\n"
        }
        scheduleSave()
    }
    
    private func generateInsight(for date: Date) -> String {
        let insights = [
            "Today is a Personal Day 3 — perfect for creative expression and social connections.",
            "Personal Day 7 invites introspection. Take time for meditation and inner work.",
            "With Personal Day 5, expect changes and embrace new opportunities.",
            "Personal Day 9 brings completion. Release what no longer serves you."
        ]
        return insights.randomElement()!
    }
    
    private func generatePrompts(for date: Date) -> [String] {
        return [
            "What synchronicities did you notice today?",
            "How did the energy of \(personalDayNumber(for: date)) show up for you?",
            "What are you grateful for on this Personal Day?",
            "What patterns from your Life Path are emerging?"
        ]
    }
}

// MARK: - Models

struct JournalEntry {
    let date: Date
    var content: String
    let personalDay: Int
    let numerologyInsight: String
    let prompts: [String]
    var lastSaved: Date?
    
    static var empty: JournalEntry {
        JournalEntry(
            date: Date(),
            content: "",
            personalDay: 1,
            numerologyInsight: "",
            prompts: [],
            lastSaved: nil
        )
    }
}

// MARK: - Preview

#Preview {
    NumerologyJournalView()
}
