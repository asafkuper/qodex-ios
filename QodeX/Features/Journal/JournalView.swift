//
//  JournalView.swift
//  QodeX
//
//  Premium Daily Journaling with Numerology Insights
//  Style: Glassmorphism, Gold Accents (#E5C158), Cosmic Dark
//

import SwiftUI
import PDFKit

// MARK: - Main View

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntry = false
    @State private var showingSearch = false
    @State private var showingExport = false
    @State private var showingPrivacyLock = false
    @State private var isLocked = true
    @State private var lockCode = ""
    @State private var selectedMonth = Date()
    
    var body: some View {
        ZStack {
            // Cosmic background with gradient
            cosmicBackground
            
            if isLocked && viewModel.privacyEnabled {
                privacyLockOverlay
            } else {
                mainContent
            }
            
            // Search overlay
            if showingSearch {
                SearchOverlay(viewModel: viewModel, isPresented: $showingSearch)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            if viewModel.privacyEnabled {
                isLocked = true
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewEntryView(viewModel: viewModel, isPresented: $showingNewEntry)
        }
        .sheet(isPresented: $showingExport) {
            ExportView(viewModel: viewModel, isPresented: $showingExport)
        }
    }
    
    // MARK: - Background
    
    private var cosmicBackground: some View {
        ZStack {
            // Deep cosmic black base
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Animated nebula effect
            GeometryReader { geo in
                ZStack {
                    // Purple nebula
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.purple.opacity(0.3),
                                    Color.purple.opacity(0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.8
                            )
                        )
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                        .blur(radius: 60)
                    
                    // Blue nebula
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.blue.opacity(0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.6
                            )
                        )
                        .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                        .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.2)
                        .blur(radius: 50)
                    
                    // Gold accent glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#E5C158").opacity(0.15),
                                    Color(hex: "#E5C158").opacity(0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.4
                            )
                        )
                        .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.4)
                        .offset(x: geo.size.width * 0.1, y: geo.size.height * 0.4)
                        .blur(radius: 40)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            headerBar
            
            // Calendar with mood indicators
            CalendarView(
                selectedDate: $viewModel.selectedDate,
                selectedMonth: $selectedMonth,
                entries: viewModel.entries,
                onDateSelected: { date in
                    viewModel.selectDate(date)
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Entry list
            JournalListView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header
    
    private var headerBar: some View {
        HStack(spacing: 16) {
            // Title with glass effect
            VStack(alignment: .leading, spacing: 2) {
                Text("Journal")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.selectedDate.formatted(.dateTime.month().year()))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#E5C158"))
            }
            
            Spacer()
            
            // Search button
            GlassButton(icon: "magnifyingglass") {
                withAnimation(.spring()) {
                    showingSearch = true
                }
            }
            
            // Export button
            GlassButton(icon: "square.and.arrow.up") {
                showingExport = true
            }
            
            // Privacy lock button
            GlassButton(icon: viewModel.privacyEnabled ? "lock.fill" : "lock.open.fill") {
                if viewModel.privacyEnabled {
                    isLocked = true
                } else {
                    showingPrivacyLock = true
                }
            }
            
            // New entry button
            Button(action: { showingNewEntry = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("New")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.08))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#E5C158"),
                            Color(hex: "#D4A84A")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color(hex: "#E5C158").opacity(0.3), radius: 10, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    // MARK: - Privacy Lock Overlay
    
    private var privacyLockOverlay: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Lock icon with glow
            ZStack {
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "#E5C158"))
            }
            
            VStack(spacing: 8) {
                Text("Journal Locked")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Enter passcode to unlock")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Passcode dots
            HStack(spacing: 16) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index < lockCode.count ? Color(hex: "#E5C158") : Color.white.opacity(0.3))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            
            // Numpad
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    NumpadButton(number: "\(number)") {
                        if lockCode.count < 4 {
                            lockCode.append("\(number)")
                            if lockCode.count == 4 {
                                checkPasscode()
                            }
                        }
                    }
                }
                
                // Empty space for layout
                Color.clear
                    .frame(height: 70)
                
                NumpadButton(number: "0") {
                    if lockCode.count < 4 {
                        lockCode.append("0")
                        if lockCode.count == 4 {
                            checkPasscode()
                        }
                    }
                }
                
                Button(action: {
                    if !lockCode.isEmpty {
                        lockCode.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 70, height: 70)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
        )
    }
    
    private func checkPasscode() {
        if viewModel.validatePasscode(lockCode) {
            withAnimation {
                isLocked = false
                lockCode = ""
            }
        } else {
            // Wrong code animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                lockCode = ""
            }
        }
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    let entries: [JournalEntry]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "#E5C158"))
                        .font(.system(size: 18, weight: .medium))
                }
                
                Spacer()
                
                Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "#E5C158"))
                        .font(.system(size: 18, weight: .medium))
                }
            }
            
            // Day headers
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            entry: entryFor(date: date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                                onDateSelected(date)
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: selectedMonth) {
                days.append(date)
            }
        }
        
        // Pad to complete weeks
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func entryFor(date: Date) -> JournalEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let entry: JournalEntry?
    
    private var personalDayNumber: Int {
        NumerologyCalculator.personalDayNumber(for: date)
    }
    
    var body: some View {
        ZStack {
            // Selection background
            if isSelected {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#E5C158").opacity(0.8),
                                Color(hex: "#D4A84A").opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#E5C158").opacity(0.4), radius: 8, x: 0, y: 4)
            } else if entry != nil {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            VStack(spacing: 4) {
                // Day number
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(red: 0.05, green: 0.05, blue: 0.08) : .white)
                
                // Personal day number badge
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.3) : Color(hex: "#E5C158").opacity(0.3))
                        .frame(width: 18, height: 18)
                    
                    Text("\(personalDayNumber)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? Color(red: 0.05, green: 0.05, blue: 0.08) : Color(hex: "#E5C158"))
                }
                
                // Mood indicator
                if let mood = entry?.mood {
                    MoodDot(mood: mood)
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear
                        .frame(height: 6)
                }
            }
            .padding(.vertical, 6)
        }
        .frame(height: 50)
    }
}

// MARK: - Mood Dot

struct MoodDot: View {
    let mood: Mood
    
    var body: some View {
        Circle()
            .fill(mood.color)
            .shadow(color: mood.color.opacity(0.5), radius: 2, x: 0, y: 0)
    }
}

// MARK: - Journal List View

struct JournalListView: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var filteredEntries: [JournalEntry] {
        if viewModel.searchQuery.isEmpty {
            return viewModel.entries.sorted(by: { $0.date > $1.date })
        } else {
            return viewModel.entries
                .filter { entry in
                    entry.content.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
                    entry.promptResponses.contains { $0.localizedCaseInsensitiveContains(viewModel.searchQuery) }
                }
                .sorted(by: { $0.date > $1.date })
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Number of the day card
                NumberOfTheDayCard(date: viewModel.selectedDate)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Entries list
                LazyVStack(spacing: 12) {
                    if filteredEntries.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(filteredEntries) { entry in
                            EntryCard(entry: entry)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        viewModel.shareEntry(entry)
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Number of the Day Card

struct NumberOfTheDayCard: View {
    let date: Date
    
    private var number: Int {
        NumerologyCalculator.personalDayNumber(for: date)
    }
    
    private var insight: String {
        NumerologyCalculator.insightForPersonalDay(number)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Large number circle
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color(hex: "#E5C158").opacity(0.3),
                                Color.purple.opacity(0.3),
                                Color(hex: "#E5C158").opacity(0.3)
                            ],
                            center: .center
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 2)
                    )
                
                Text("\(number)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#E5C158"))
                    .shadow(color: Color(hex: "#E5C158").opacity(0.5), radius: 10, x: 0, y: 0)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Number of the Day")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("Personal Day \(number)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(insight)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Entry Card

struct EntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date.formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(entry.date.formatted(.dateTime.month().day()))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Mood badge
                if let mood = entry.mood {
                    HStack(spacing: 4) {
                        MoodDot(mood: mood)
                            .frame(width: 8, height: 8)
                        Text(mood.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(mood.color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(mood.color.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            
            // Content preview
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
            }
            
            // Prompt responses
            if !entry.promptResponses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(entry.promptResponses.prefix(2), id: \.self) { response in
                        HStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#E5C158"))
                            
                            Text(response)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            // Footer
            HStack {
                // Personal day badge
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#E5C158"))
                    Text("Day \(entry.personalDayNumber)")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#E5C158"))
                }
                
                Spacer()
                
                if entry.hasAttachments {
                    Image(systemName: "paperclip")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "#E5C158").opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No entries yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Start journaling to capture your thoughts and track your numerology journey")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.vertical, 60)
    }
}

// MARK: - New Entry View

struct NewEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Binding var isPresented: Bool
    
    @State private var content = ""
    @State private var selectedMood: Mood?
    @State private var promptResponses: [String] = []
    @State private var showingPrompts = true
    
    private let prompts = [
        "What synchronicities did you notice today?",
        "How did today's number energy show up for you?",
        "What are you grateful for right now?",
        "What patterns from your Life Path are emerging?",
        "How did your Personal Day number influence your decisions?"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Mood selector
                        moodSelector
                        
                        // Prompts section
                        if showingPrompts {
                            promptsSection
                        }
                        
                        // Journal content
                        contentEditor
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .foregroundColor(Color(hex: "#E5C158"))
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reflection Prompts")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingPrompts = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            VStack(spacing: 8) {
                ForEach(prompts, id: \.self) { prompt in
                    PromptButton(prompt: prompt) {
                        if content.isEmpty {
                            content = "\(prompt)\n\n"
                        } else {
                            content += "\n\n\(prompt)\n"
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var contentEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Thoughts")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            TextEditor(text: $content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 200)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            id: UUID(),
            date: viewModel.selectedDate,
            content: content,
            mood: selectedMood,
            personalDayNumber: NumerologyCalculator.personalDayNumber(for: viewModel.selectedDate),
            promptResponses: promptResponses,
            hasAttachments: false
        )
        
        viewModel.addEntry(entry)
        isPresented = false
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                
                Text(mood.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? mood.color : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? mood.color : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Prompt Button

struct PromptButton: View {
    let prompt: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#E5C158"))
                
                Text(prompt)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#E5C158"))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Overlay

struct SearchOverlay: View {
    @ObservedObject var viewModel: JournalViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search entries...", text: $viewModel.searchQuery)
                    .foregroundColor(.white)
                    .placeholder(when: viewModel.searchQuery.isEmpty) {
                        Text("Search entries...")
                            .foregroundColor(.white.opacity(0.5))
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Button("Done") {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
                .foregroundColor(Color(hex: "#E5C158"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(16)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(title: "All", isSelected: viewModel.selectedFilter == .all) {
                        viewModel.selectedFilter = .all
                    }
                    
                    ForEach(Mood.allCases, id: \.self) { mood in
                        FilterChip(title: mood.rawValue, isSelected: viewModel.selectedFilter == .mood(mood)) {
                            viewModel.selectedFilter = .mood(mood)
                        }
                    }
                    
                    FilterChip(title: "This Week", isSelected: viewModel.selectedFilter == .thisWeek) {
                        viewModel.selectedFilter = .thisWeek
                    }
                    
                    FilterChip(title: "This Month", isSelected: viewModel.selectedFilter == .thisMonth) {
                        viewModel.selectedFilter = .thisMonth
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .background(
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .opacity(0.95)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? Color(red: 0.05, green: 0.05, blue: 0.08) : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "#E5C158") : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Export View

struct ExportView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Binding var isPresented: Bool
    @State private var isGeneratingPDF = false
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Export options
                    VStack(spacing: 16) {
                        ExportOptionCard(
                            icon: "doc.text.fill",
                            title: "Export to PDF",
                            description: "Create a beautiful PDF of your journal entries"
                        ) {
                            generatePDF()
                        }
                        
                        ExportOptionCard(
                            icon: "calendar.badge.clock",
                            title: "Export Date Range",
                            description: "Select specific dates to export"
                        ) {
                            // Show date range picker
                        }
                        
                        ExportOptionCard(
                            icon: "arrow.up.doc.fill",
                            title: "Export All Entries",
                            description: "Export your complete journal history"
                        ) {
                            // Export all
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .overlay {
                if isGeneratingPDF {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(hex: "#E5C158"))
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(items: [pdfData])
                }
            }
        }
    }
    
    private func generatePDF() {
        isGeneratingPDF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfCreator = PDFCreator()
            let data = pdfCreator.createPDF(from: viewModel.entries)
            
            DispatchQueue.main.async {
                pdfData = data
                isGeneratingPDF = false
                showShareSheet = true
            }
        }
    }
}

// MARK: - Export Option Card

struct ExportOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#E5C158").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#E5C158"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glass Button

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Numpad Button

struct NumpadButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
}

// MARK: - PDF Creator

class PDFCreator {
    func createPDF(from entries: [JournalEntry]) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "QodeX Journal",
            kCGPDFContextAuthor: "QodeX App",
            kCGPDFContextTitle: "My Numerology Journal"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(red: 0.9, green: 0.76, blue: 0.35, alpha: 1.0)
            ]
            
            let title = "My Numerology Journal"
            title.draw(at: CGPoint(x: 72, y: 72), withAttributes: titleAttributes)
            
            // Entries
            var yOffset: CGFloat = 140
            
            for entry in entries.sorted(by: { $0.date > $1.date }) {
                if yOffset > pageHeight - 100 {
                    context.beginPage()
                    yOffset = 72
                }
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.darkGray
                ]
                
                dateFormatter.string(from: entry.date).draw(
                    at: CGPoint(x: 72, y: yOffset),
                    withAttributes: dateAttributes
                )
                
                yOffset += 24
                
                // Content
                if !entry.content.isEmpty {
                    let contentAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.black
                    ]
                    
                    let contentRect = CGRect(x: 72, y: yOffset, width: pageWidth - 144, height: 200)
                    entry.content.draw(in: contentRect, withAttributes: contentAttributes)
                    
                    yOffset += 100
                }
                
                yOffset += 40
            }
        }
        
        return data
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Numerology Calculator

enum NumerologyCalculator {
    static func personalDayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let sum = day + month + reduceToDigit(year)
        return reduceToDigit(sum)
    }
    
    static func reduceToDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 {
            result = String(result).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return result == 0 ? 1 : result
    }
    
    static func insightForPersonalDay(_ number: Int) -> String {
        let insights = [
            1: "New beginnings. Take initiative and lead with confidence.",
            2: "Cooperation. Focus on partnerships and diplomacy.",
            3: "Creativity. Express yourself and embrace joy.",
            4: "Stability. Build foundations and organize your life.",
            5: "Change. Embrace freedom and new opportunities.",
            6: "Responsibility. Focus on family and home matters.",
            7: "Reflection. Seek inner wisdom and spiritual growth.",
            8: "Abundance. Focus on success and material achievements.",
            9: "Completion. Release what no longer serves you."
        ]
        return insights[number] ?? "Trust the journey of number \(number)."
    }
}

// MARK: - Mood Enum

enum Mood: String, CaseIterable {
    case joyful = "Joyful"
    case calm = "Calm"
    case neutral = "Neutral"
    case anxious = "Anxious"
    case sad = "Sad"
    
    var emoji: String {
        switch self {
        case .joyful: return "😊"
        case .calm: return "😌"
        case .neutral: return "😐"
        case .anxious: return "😰"
        case .sad: return "😔"
        }
    }
    
    var color: Color {
        switch self {
        case .joyful: return Color.yellow
        case .calm: return Color.green
        case .neutral: return Color.gray
        case .anxious: return Color.orange
        case .sad: return Color.blue
        }
    }
}

// MARK: - Filter Enum

enum JournalFilter {
    case all
    case mood(Mood)
    case thisWeek
    case thisMonth
}

// MARK: - Journal Entry Model

struct JournalEntry: Identifiable {
    let id: UUID
    let date: Date
    let content: String
    let mood: Mood?
    let personalDayNumber: Int
    let promptResponses: [String]
    let hasAttachments: Bool
}

// MARK: - View Model

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var selectedDate = Date()
    @Published var searchQuery = ""
    @Published var selectedFilter: JournalFilter = .all
    @Published var privacyEnabled = false
    
    private let passcode = "1234" // In production, use Keychain
    
    init() {
        loadSampleEntries()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
    }
    
    func shareEntry(_ entry: JournalEntry) {
        // Share functionality
    }
    
    func validatePasscode(_ code: String) -> Bool {
        code == passcode
    }
    
    private func loadSampleEntries() {
        // Sample entries for demonstration
        let sampleEntry = JournalEntry(
            id: UUID(),
            date: Date(),
            content: "Today I noticed repeating numbers everywhere - 11:11 on the clock, license plates, and even my coffee receipt! The energy of Personal Day 3 is definitely bringing more synchronicities into my awareness.",
            mood: .joyful,
            personalDayNumber: 3,
            promptResponses: ["What synchronicities did you notice today?"],
            hasAttachments: false
        )
        entries.append(sampleEntry)
    }
}

// MARK: - Color Extension

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

// MARK: - TextField Placeholder Extension

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .preferredColorScheme(.dark)
    }
}
