//
//  TarotView.swift
//  QodeX - Premium Tarot Experience
//
//  A complete tarot card reading app with glassmorphism design,
//  gold accents, and mystical dark theme.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Data Models

enum TarotSuit: String, CaseIterable {
    case wands = "Wands"
    case cups = "Cups"
    case swords = "Swords"
    case pentacles = "Pentacles"
    case majorArcana = "Major Arcana"
    
    var symbol: String {
        switch self {
        case .wands: return "🔥"
        case .cups: return "🌊"
        case .swords: return "💨"
        case .pentacles: return "🌍"
        case .majorArcana: return "✨"
        }
    }
    
    var element: String {
        switch self {
        case .wands: return "Fire"
        case .cups: return "Water"
        case .swords: return "Air"
        case .pentacles: return "Earth"
        case .majorArcana: return "Spirit"
        }
    }
}

struct TarotCard: Identifiable, Codable, Equatable {
    let id = UUID()
    let number: Int
    let name: String
    let suit: TarotSuit
    let imageName: String
    let keywordsUpright: [String]
    let keywordsReversed: [String]
    let meaningUpright: String
    let meaningReversed: String
    let description: String
    let astrology: String?
    let element: String
    
    var isReversed: Bool = false
    
    var displayName: String {
        if suit == .majorArcana {
            return name
        } else {
            return "\(number) of \(suit.rawValue)"
        }
    }
    
    var currentMeaning: String {
        isReversed ? meaningReversed : meaningUpright
    }
    
    var currentKeywords: [String] {
        isReversed ? keywordsReversed : keywordsUpright
    }
}

enum SpreadType: String, CaseIterable {
    case oneCard = "One Card"
    case threeCard = "Three Card Spread"
    case celticCross = "Celtic Cross"
    
    var cardCount: Int {
        switch self {
        case .oneCard: return 1
        case .threeCard: return 3
        case .celticCross: return 10
        }
    }
    
    var description: String {
        switch self {
        case .oneCard:
            return "A single card for daily guidance or quick insight"
        case .threeCard:
            return "Past, Present, Future - or Mind, Body, Spirit"
        case .celticCross:
            return "The classic 10-card spread for deep exploration"
        }
    }
    
    var positions: [String] {
        switch self {
        case .oneCard:
            return ["The Answer"]
        case .threeCard:
            return ["Past/Mind", "Present/Body", "Future/Spirit"]
        case .celticCross:
            return [
                "Present Situation",
                "Challenge/Cross",
                "Foundation/Root",
                "Recent Past",
                "Crown/Goal",
                "Near Future",
                "Self/Attitude",
                "Environment",
                "Hopes/Fears",
                "Final Outcome"
            ]
        }
    }
}

struct TarotReading: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let spreadType: SpreadType
    let cards: [TarotCard]
    let notes: String
    let title: String
}

// MARK: - Card Database

class TarotDeck {
    static let shared = TarotDeck()
    
    let cards: [TarotCard]
    
    private init() {
        cards = TarotDeck.createFullDeck()
    }
    
    private static func createFullDeck() -> [TarotCard] {
        var deck: [TarotCard] = []
        
        // Major Arcana (0-21)
        let majorArcana: [(Int, String, [String], [String], String, String, String, String?)] = [
            (0, "The Fool", ["New beginnings", "Innocence", "Spontaneity"], ["Recklessness", "Risk-taking", "Foolishness"], "A new journey begins. Trust in the universe and take a leap of faith.", "Caution is needed. You may be acting without thinking things through.", "The eternal dreamer, stepping off the cliff into the unknown.", "Uranus"),
            (1, "The Magician", ["Manifestation", "Resourcefulness", "Power"], ["Manipulation", "Poor planning", "Untapped talents"], "You have all the tools you need. Channel your energy to manifest your desires.", "You may be misusing your abilities or failing to see your potential.", "The alchemist who transforms reality through will and wisdom.", "Mercury"),
            (2, "The High Priestess", ["Intuition", "Unconscious", "Mystery"], ["Secrets", "Disconnected", "Confusion"], "Listen to your inner voice. Hidden knowledge is revealed through intuition.", "You may be ignoring your intuition or keeping secrets from yourself.", "The guardian of hidden wisdom, keeper of sacred mysteries.", "Moon"),
            (3, "The Empress", ["Fertility", "Nature", "Abundance"], ["Creative block", "Dependence", "Smothering"], "Nurture your creations. Abundance flows when you connect with nature.", "You may be feeling creatively blocked or overly dependent on others.", "The mother of all, embodiment of earthly abundance and creative power.", "Venus"),
            (4, "The Emperor", ["Authority", "Structure", "Father figure"], ["Tyranny", "Rigidity", "Coldness"], "Establish order and discipline. Take charge of your situation with confidence.", "You may be too rigid or controlling. Flexibility is needed.", "The divine father, architect of structure and earthly authority.", "Aries"),
            (5, "The Hierophant", ["Tradition", "Conformity", "Education"], ["Rebellion", "Unconventionality", "Non-conformity"], "Seek wisdom from established traditions. Learn from teachers and mentors.", "You may need to break from tradition or question established beliefs.", "The bridge between heaven and earth, interpreter of sacred mysteries.", "Taurus"),
            (6, "The Lovers", ["Love", "Harmony", "Choices"], ["Disharmony", "Imbalance", "Misalignment"], "A significant relationship or choice. Align your actions with your values.", "You may be making poor choices or experiencing relationship difficulties.", "The sacred union of opposites, choice made from the heart.", "Gemini"),
            (7, "The Chariot", ["Control", "Willpower", "Victory"], ["Lack of control", "Aggression", "Defeat"], "Focus your willpower. Triumph comes through determination and self-discipline.", "You may be losing control or allowing external forces to direct you.", "The warrior who masters opposing forces through sheer will.", "Cancer"),
            (8, "Strength", ["Courage", "Persuasion", "Influence"], ["Self-doubt", "Weakness", "Insecurity"], "Gentle strength prevails. Master your emotions with compassion and patience.", "You may be feeling powerless or struggling with self-confidence.", "The soul's dominion over primal forces through love, not force.", "Leo"),
            (9, "The Hermit", ["Soul-searching", "Introspection", "Guidance"], ["Isolation", "Loneliness", "Withdrawal"], "Take time for reflection. Wisdom comes from within through quiet contemplation.", "You may be isolating yourself too much or feeling lost.", "The wise seeker who finds truth in the silence of the soul.", "Virgo"),
            (10, "Wheel of Fortune", ["Good luck", "Karma", "Cycles"], ["Bad luck", "Resistance", "Clinging"], "The wheel turns in your favor. Embrace the cycles of change and opportunity.", "You may be resisting necessary change or experiencing bad luck.", "The eternal cycle of existence, fortune's ever-turning wheel.", "Jupiter"),
            (11, "Justice", ["Fairness", "Truth", "Law"], ["Unfairness", "Dishonesty", "Lack of accountability"], "Truth and fairness prevail. Accept the consequences of your actions with grace.", "You may be experiencing injustice or avoiding responsibility.", "The impartial balance, where every action meets its true measure.", "Libra"),
            (12, "The Hanged Man", ["Pause", "Surrender", "New perspective"], ["Delays", "Resistance", "Stalling"], "Let go and see things differently. Sometimes suspension brings clarity.", "You may be resisting necessary delays or refusing to see another view.", "The willing sacrifice who finds enlightenment through surrender.", "Neptune"),
            (13, "Death", ["Endings", "Transformation", "Transition"], ["Resistance to change", "Stagnation", "Decay"], "A necessary ending brings transformation. Embrace the new beginning.", "You may be resisting necessary change or clinging to the past.", "The great transformer, where endings become beginnings.", "Scorpio"),
            (14, "Temperance", ["Balance", "Moderation", "Patience"], ["Imbalance", "Excess", "Lack of harmony"], "Find the middle path. Balance and patience create the perfect blend.", "You may be living in excess or struggling to find balance.", "The angel of balance, mixing the waters of conscious and unconscious.", "Sagittarius"),
            (15, "The Devil", ["Shadow self", "Attachment", "Restriction"], ["Releasing", "Overcoming", "Freedom"], "Acknowledge your shadows. You may be bound by attachments or illusions.", "You are breaking free from limiting beliefs and toxic patterns.", "The shadow within, chains we forge through our own desires.", "Capricorn"),
            (16, "The Tower", ["Sudden change", "Upheaval", "Awakening"], ["Avoidance", "Fear of change", "Delaying"], "Sudden revelation destroys false foundations. Truth brings necessary upheaval.", "You may be avoiding necessary change or fearing the inevitable.", "The lightning-struck tower, where false structures fall to reveal truth.", "Mars"),
            (17, "The Star", ["Hope", "Faith", "Rejuvenation"], ["Despair", "Discouragement", "Disconnection"], "Hope shines brightly. Trust in the universe's guidance and healing.", "You may be losing hope or feeling disconnected from your path.", "The heavenly guide, pouring waters of inspiration upon the world.", "Aquarius"),
            (18, "The Moon", ["Illusion", "Fear", "Anxiety"], ["Clarity", "Truth", "Facing fears"], "Trust your intuition through uncertainty. Not everything is as it appears.", "You are seeing through illusions and facing your fears with courage.", "The realm of dreams and shadows, where intuition speaks in symbols.", "Pisces"),
            (19, "The Sun", ["Positivity", "Fun", "Warmth"], ["Temporary depression", "Lack of energy", "Sadness"], "Joy and success illuminate your path. Bask in the warmth of achievement.", "You may be experiencing temporary setbacks or lack of enthusiasm.", "The source of all life, bringing clarity, joy, and vital energy.", "Sun"),
            (20, "Judgement", ["Rebirth", "Inner calling", "Forgiveness"], ["Self-doubt", "Refusal", "Denial"], "A wake-up call arrives. Heed your true calling and embrace renewal.", "You may be ignoring your calling or refusing to forgive yourself.", "The angel's trumpet, calling the soul to its higher purpose.", "Pluto"),
            (21, "The World", ["Completion", "Integration", "Accomplishment"], ["Lack of closure", "Incomplete", "Delays"], "A cycle completes successfully. You have achieved wholeness and integration.", "You may be feeling incomplete or struggling to finish what you started.", "The cosmic dance complete, the soul's journey through the manifested world.", "Saturn")
        ]
        
        for (num, name, upKey, revKey, upMean, revMean, desc, astro) in majorArcana {
            deck.append(TarotCard(
                number: num,
                name: name,
                suit: .majorArcana,
                imageName: "card_\(num)_major",
                keywordsUpright: upKey,
                keywordsReversed: revKey,
                meaningUpright: upMean,
                meaningReversed: revMean,
                description: desc,
                astrology: astro,
                element: "Spirit"
            ))
        }
        
        // Minor Arcana
        let suits: [(TarotSuit, String, String)] = [
            (.wands, "Fire", "🔥"),
            (.cups, "Water", "🌊"),
            (.swords, "Air", "💨"),
            (.pentacles, "Earth", "🌍")
        ]
        
        let minorCards: [(Int, String, [String], [String], String, String)] = [
            (1, "Ace", ["New beginning", "Potential", "Gift"], ["Blocked potential", "Delays", "Wasted opportunity"], "A powerful new beginning full of potential.", "Missed opportunity or blocked creative flow."),
            (2, "Two", ["Balance", "Partnership", "Union"], ["Imbalance", "Conflict", "Disconnection"], "Harmony through partnership and balance.", "Struggle to find balance or partnership difficulties."),
            (3, "Three", ["Creation", "Collaboration", "Growth"], ["Disruption", "Chaos", "Conflict"], "Creative expansion through collaboration.", "Disagreements or creative blocks in group efforts."),
            (4, "Four", ["Stability", "Structure", "Foundation"], ["Instability", "Restriction", "Boredom"], "Solid foundation and security established.", "Restlessness or feeling trapped by stability."),
            (5, "Five", ["Conflict", "Loss", "Challenge"], ["Recovery", "Reconciliation", "Hope"], "Difficulty and loss, but lessons learned.", "Healing from conflict or finding hope in loss."),
            (6, "Six", ["Victory", "Recognition", "Progress"], ["Setback", "Delay", "Ego"], "Triumph and well-deserved recognition.", "Temporary setback or excessive pride."),
            (7, "Seven", ["Perseverance", "Defense", "Strategy"], ["Overwhelm", "Giving up", "Vulnerability"], "Standing your ground with determination.", "Feeling overwhelmed or ready to surrender."),
            (8, "Eight", ["Movement", "Speed", "Action"], ["Stagnation", "Delays", "Frustration"], "Swift progress and dynamic energy.", "Obstacles causing delays or stagnation."),
            (9, "Nine", ["Resilience", "Courage", "Persistence"], ["Exhaustion", "Defensiveness", "Paranoia"], "Inner strength and preparedness.", "Wearing yourself thin or excessive worry."),
            (10, "Ten", ["Completion", "Fulfillment", "Manifestation"], ["Burden", "Exhaustion", "Completion"], "The culmination of your efforts.", "Feeling overwhelmed by responsibilities."),
            (11, "Page", ["Exploration", "Enthusiasm", "Discovery"], ["Lack of direction", "Procrastination", "Immaturity"], "A messenger bringing new opportunities.", "Unfocused energy or delayed messages."),
            (12, "Knight", ["Action", "Adventure", "Passion"], ["Recklessness", "Haste", "Aggression"], "Bold action and pursuit of goals.", "Impulsive actions or reckless behavior."),
            (13, "Queen", ["Nurturing", "Mastery", "Abundance"], ["Selfishness", "Insecurity", "Smothering"], "Mastery through caring and intuition.", "Emotional manipulation or self-doubt."),
            (14, "King", ["Authority", "Leadership", "Achievement"], ["Tyranny", "Rigidity", "Impulsiveness"], "Mature mastery and benevolent authority.", "Authoritarian control or lack of discipline.")
        ]
        
        for (suit, element, _) in suits {
            for (num, name, upKey, revKey, upMean, revMean) in minorCards {
                let cardName = "\(name) of \(suit.rawValue)"
                deck.append(TarotCard(
                    number: num,
                    name: cardName,
                    suit: suit,
                    imageName: "card_\(num)_\(suit.rawValue.lowercased())",
                    keywordsUpright: upKey,
                    keywordsReversed: revKey,
                    meaningUpright: upMean,
                    meaningReversed: revMean,
                    description: "The \(cardName) embodies \(element) energy.",
                    astrology: nil,
                    element: element
                ))
            }
        }
        
        return deck
    }
    
    func shuffledDeck() -> [TarotCard] {
        cards.shuffled().map { card in
            var mutableCard = card
            mutableCard.isReversed = Bool.random()
            return mutableCard
        }
    }
}

// MARK: - ViewModel

@MainActor
class TarotViewModel: ObservableObject {
    @Published var selectedSpread: SpreadType = .oneCard
    @Published var currentReading: [TarotCard] = []
    @Published var readingHistory: [TarotReading] = []
    @Published var isShuffling = false
    @Published var showCardDetail: TarotCard?
    @Published var dailyCard: TarotCard?
    @Published var lastDailyCardDate: Date?
    @Published var readingNotes = ""
    @Published var readingTitle = ""
    @Published var showSavedConfirmation = false
    @Published var selectedTab: TarotTab = .read
    
    enum TarotTab {
        case read, history, daily, learn
    }
    
    private let historyKey = "tarotReadingHistory"
    private let dailyCardKey = "dailyTarotCard"
    private let dailyDateKey = "dailyTarotDate"
    
    init() {
        loadHistory()
        loadDailyCard()
        requestNotificationPermission()
    }
    
    func shuffleAndDeal() {
        guard !isShuffling else { return }
        
        isShuffling = true
        currentReading = []
        
        // Simulate shuffle animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            let deck = TarotDeck.shared.shuffledDeck()
            self.currentReading = Array(deck.prefix(self.selectedSpread.cardCount))
            self.isShuffling = false
        }
    }
    
    func saveReading() {
        guard !currentReading.isEmpty else { return }
        
        let reading = TarotReading(
            date: Date(),
            spreadType: selectedSpread,
            cards: currentReading,
            notes: readingNotes,
            title: readingTitle.isEmpty ? "Reading \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))" : readingTitle
        )
        
        readingHistory.insert(reading, at: 0)
        saveHistory()
        
        readingNotes = ""
        readingTitle = ""
        showSavedConfirmation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showSavedConfirmation = false
        }
    }
    
    func deleteReading(at offsets: IndexSet) {
        readingHistory.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func drawDailyCard() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastDailyCardDate,
           Calendar.current.isDate(lastDate, inSameDayAs: today) {
            // Already drawn today
            return
        }
        
        let deck = TarotDeck.shared.shuffledDeck()
        dailyCard = deck.first
        lastDailyCardDate = Date()
        
        UserDefaults.standard.set(lastDailyCardDate, forKey: dailyDateKey)
        if let card = dailyCard {
            if let encoded = try? JSONEncoder().encode(card) {
                UserDefaults.standard.set(encoded, forKey: dailyCardKey)
            }
        }
        
        scheduleDailyNotification()
    }
    
    func shareReading(reading: TarotReading) -> String {
        var text = "🔮 \(reading.title)\n"
        text += "📅 \(reading.date.formatted(date: .long, time: .shortened))\n"
        text += "📿 \(reading.spreadType.rawValue)\n\n"
        
        for (index, card) in reading.cards.enumerated() {
            let position = reading.spreadType.positions[safe: index] ?? "Card \(index + 1)"
            text += "\(position): \(card.displayName)"
            text += card.isReversed ? " (Reversed)" : " (Upright)"
            text += "\n"
            text += "Keywords: \(card.currentKeywords.joined(separator: ", "))\n\n"
        }
        
        if !reading.notes.isEmpty {
            text += "📝 Notes: \(reading.notes)\n"
        }
        
        text += "\n✨ Read with QodeX Tarot"
        return text
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([TarotReading].self, from: data) {
            readingHistory = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(readingHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadDailyCard() {
        lastDailyCardDate = UserDefaults.standard.object(forKey: dailyDateKey) as? Date
        
        if let data = UserDefaults.standard.data(forKey: dailyCardKey),
           let card = try? JSONDecoder().decode(TarotCard.self, from: data) {
            dailyCard = card
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "✨ Your Daily Tarot Card"
        content.body = "Discover what the cards have in store for you today."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyTarot", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Views

struct TarotView: View {
    @StateObject private var viewModel = TarotViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ReadingTabView(viewModel: viewModel)
                .tabItem {
                    Label("Read", systemImage: "sparkles")
                }
                .tag(TarotViewModel.TarotTab.read)
            
            DailyCardView(viewModel: viewModel)
                .tabItem {
                    Label("Daily", systemImage: "sun.max")
                }
                .tag(TarotViewModel.TarotTab.daily)
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(TarotViewModel.TarotTab.history)
            
            CardLibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(TarotViewModel.TarotTab.learn)
        }
        .accentColor(Color(hex: "#E5C158"))
        .preferredColorScheme(.dark)
    }
}

// MARK: - Reading Tab

struct ReadingTabView: View {
    @ObservedObject var viewModel: TarotViewModel
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Mystical Background
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("✨ Tarot Reading")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                        .shadow(color: Color(hex: "#E5C158").opacity(0.5), radius: 10)
                    
                    // Spread Selector
                    SpreadSelectorView(selectedSpread: $viewModel.selectedSpread)
                    
                    // Shuffle Button
                    ShuffleButton(isShuffling: viewModel.isShuffling) {
                        withAnimation(.spring()) {
                            viewModel.shuffleAndDeal()
                        }
                    }
                    
                    // Card Display
                    if viewModel.isShuffling {
                        ShufflingAnimationView()
                    } else if !viewModel.currentReading.isEmpty {
                        CardSpreadView(
                            cards: viewModel.currentReading,
                            spreadType: viewModel.selectedSpread,
                            onCardTap: { card in
                                viewModel.showCardDetail = card
                            }
                        )
                        
                        // Save Reading Section
                        SaveReadingSection(viewModel: viewModel)
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
        }
        .sheet(item: $viewModel.showCardDetail) { card in
            if card.suit == .majorArcana {
                CardDetailView(card: card)
            } else {
                EnhancedCardDetailView(card: card)
            }
        }
        .overlay {
            if viewModel.showSavedConfirmation {
                SavedConfirmationView()
            }
        }
    }
}

// MARK: - Daily Card View

struct DailyCardView: View {
    @ObservedObject var viewModel: TarotViewModel
    @State private var showCardDetail = false
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Text("☀️ Card of the Day")
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if let card = viewModel.dailyCard {
                        // Today's Card
                        DailyCardDisplay(card: card)
                            .onTapGesture {
                                showCardDetail = true
                            }
                        
                        Text("Tap card for details")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        
                        // Guidance
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Guidance")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#E5C158"))
                            
                            Text(card.currentMeaning)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                            
                            // Keywords
                            FlowLayout(spacing: 8) {
                                ForEach(card.currentKeywords, id: \.self) { keyword in
                                    KeywordPill(text: keyword)
                                }
                            }
                        }
                        .padding()
                        .glassmorphicCard()
                    } else {
                        // Draw Card Button
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#E5C158"))
                                .shadow(color: Color(hex: "#E5C158").opacity(0.5), radius: 20)
                            
                            Text("Draw your card for today")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                viewModel.drawDailyCard()
                            }) {
                                Text("Reveal My Card")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "#E5C158"), Color(hex: "#F0D878")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(25)
                            }
                            .accessibilityLabel("Reveal daily card")
                            .accessibilityHint("Double tap to draw your tarot card for today")
                        }
                        .padding(40)
                        .glassmorphicCard()
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showCardDetail) {
            if let card = viewModel.dailyCard {
                if card.suit == .majorArcana {
                    CardDetailView(card: card)
                } else {
                    EnhancedCardDetailView(card: card)
                }
            }
        }
        .onAppear {
            viewModel.drawDailyCard()
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @ObservedObject var viewModel: TarotViewModel
    @State private var selectedReading: TarotReading?
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("📜 Reading History")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    if viewModel.readingHistory.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("No readings yet")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Your tarot readings will appear here")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.readingHistory) { reading in
                                ReadingHistoryCard(reading: reading)
                                    .onTapGesture {
                                        selectedReading = reading
                                    }
                                    .contextMenu {
                                        Button {
                                            let text = viewModel.shareReading(reading: reading)
                                            UIPasteboard.general.string = text
                                        } label: {
                                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                        }
                                        
                                        ShareLink(item: viewModel.shareReading(reading: reading)) {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedReading) { reading in
            ReadingDetailView(reading: reading, viewModel: viewModel)
        }
    }
}

// MARK: - Card Library View

struct CardLibraryView: View {
    @State private var selectedSuit: TarotSuit?
    @State private var searchText = ""
    @State private var selectedCard: TarotCard?
    @State private var showMinorArcanaExplorer = false
    
    var filteredCards: [TarotCard] {
        var cards = TarotDeck.shared.cards
        
        if let suit = selectedSuit {
            cards = cards.filter { $0.suit == suit }
        }
        
        if !searchText.isEmpty {
            cards = cards.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.keywordsUpright.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return cards
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                MysticalBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("📚 Card Library")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        // Minor Arcana Explorer Button
                        Button(action: { showMinorArcanaExplorer = true }) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                Image(systemName: "wind")
                                    .foregroundColor(.yellow)
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                
                                Text("Explore Minor Arcana")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#E5C158"))
                            }
                            .padding()
                            .glassmorphicCard()
                        }
                        .padding(.horizontal)
                        
                        // Search
                        SearchBar(text: $searchText)
                        
                        // Suit Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedSuit == nil
                                ) {
                                    selectedSuit = nil
                                }
                                
                                ForEach(TarotSuit.allCases, id: \.self) { suit in
                                    FilterChip(
                                        title: "\(suit.symbol) \(suit.rawValue)",
                                        isSelected: selectedSuit == suit
                                    ) {
                                        selectedSuit = suit
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Cards Grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                            ForEach(filteredCards) { card in
                                LibraryCardView(card: card)
                                    .onTapGesture {
                                        selectedCard = card
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                if card.suit == .majorArcana {
                    CardDetailView(card: card)
                } else {
                    EnhancedCardDetailView(card: card)
                }
            }
            .sheet(isPresented: $showMinorArcanaExplorer) {
                NavigationView {
                    MinorArcanaExplorerView()
                        .navigationTitle("Minor Arcana")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showMinorArcanaExplorer = false
                                }
                                .foregroundColor(Color(hex: "#E5C158"))
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MysticalBackground: View {
    var body: some View {
        ZStack {
            // Deep purple gradient
            LinearGradient(
                colors: [
                    Color(hex: "#0D0221"),
                    Color(hex: "#1A0B2E"),
                    Color(hex: "#261447")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Mystical orbs
            GeometryReader { geo in
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(x: geo.size.width - 200, y: geo.size.height / 2)
                
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: geo.size.width / 2, y: geo.size.height - 150)
            }
            .ignoresSafeArea()
        }
    }
}

struct SpreadSelectorView: View {
    @Binding var selectedSpread: SpreadType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Spread")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            ForEach(SpreadType.allCases, id: \.self) { spread in
                SpreadCard(
                    spread: spread,
                    isSelected: selectedSpread == spread
                ) {
                    withAnimation(.spring()) {
                        selectedSpread = spread
                    }
                }
            }
        }
        .padding()
        .glassmorphicCard()
    }
}

struct SpreadCard: View {
    let spread: SpreadType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spread.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? Color(hex: "#E5C158") : .white)
                    
                    Text(spread.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#E5C158"))
                        .font(.title3)
                }
                
                Text("\(spread.cardCount) cards")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "#E5C158").opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "#E5C158").opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel("\(spread.rawValue)")
        .accessibilityHint("\(spread.description). Uses \(spread.cardCount) cards. Double tap to \(isSelected ? "keep" : "select") this spread")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct ShuffleButton: View {
    let isShuffling: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isShuffling {
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "shuffle")
                        .font(.title3)
                }
                
                Text(isShuffling ? "Shuffling..." : "Shuffle & Deal")
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: isShuffling ?
                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                        [Color(hex: "#E5C158"), Color(hex: "#F0D878")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(color: Color(hex: "#E5C158").opacity(isShuffling ? 0 : 0.4), radius: 15)
        }
        .disabled(isShuffling)
        .accessibilityLabel(isShuffling ? "Shuffling cards" : "Shuffle and deal cards")
        .accessibilityHint(isShuffling ? "Please wait while cards are being shuffled" : "Double tap to shuffle the deck and deal a new reading")
    }
}

struct ShufflingAnimationView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                CardBackView()
                    .rotationEffect(.degrees(rotation + Double(i) * 15))
                    .offset(x: cos(rotation * 0.05 + Double(i)) * 30,
                            y: sin(rotation * 0.05 + Double(i)) * 30)
                    .scaleEffect(scale)
            }
        }
        .frame(height: 200)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

struct CardSpreadView: View {
    let cards: [TarotCard]
    let spreadType: SpreadType
    let onCardTap: (TarotCard) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Reading")
                .font(.title2)
                .foregroundColor(Color(hex: "#E5C158"))
            
            switch spreadType {
            case .oneCard:
                OneCardLayout(card: cards[0], onTap: onCardTap)
            case .threeCard:
                ThreeCardLayout(cards: cards, onTap: onCardTap)
            case .celticCross:
                CelticCrossLayout(cards: cards, onTap: onCardTap)
            }
        }
        .padding()
        .glassmorphicCard()
    }
}

struct OneCardLayout: View {
    let card: TarotCard
    let onTap: (TarotCard) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            TarotCardView(card: card)
                .onTapGesture { onTap(card) }
            
            Text(card.displayName)
                .font(.headline)
                .foregroundColor(.white)
            
            if card.isReversed {
                Text("Reversed")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
            }
        }
    }
}

struct ThreeCardLayout: View {
    let cards: [TarotCard]
    let onTap: (TarotCard) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    VStack(spacing: 8) {
                        Text(SpreadType.threeCard.positions[index])
                            .font(.caption)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        TarotCardView(card: card)
                            .onTapGesture { onTap(card) }
                        
                        Text(card.displayName)
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

struct CelticCrossLayout: View {
    let cards: [TarotCard]
    let onTap: (TarotCard) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Row 1: Staff (cards 4, 5, 6)
            HStack(spacing: 8) {
                ForEach(3..<6) { i in
                    if i < cards.count {
                        MiniCardView(card: cards[i], position: SpreadType.celticCross.positions[i])
                            .onTapGesture { onTap(cards[i]) }
                    }
                }
            }
            
            // Row 2: Cross center with cards 1, 2
            HStack(spacing: 8) {
                if cards.count > 0 {
                    MiniCardView(card: cards[0], position: SpreadType.celticCross.positions[0])
                        .onTapGesture { onTap(cards[0]) }
                }
                if cards.count > 1 {
                    MiniCardView(card: cards[1], position: SpreadType.celticCross.positions[1])
                        .rotationEffect(.degrees(90))
                        .onTapGesture { onTap(cards[1]) }
                }
                if cards.count > 6 {
                    MiniCardView(card: cards[6], position: SpreadType.celticCross.positions[6])
                        .onTapGesture { onTap(cards[6]) }
                }
            }
            
            // Row 3: Foundation (card 3)
            if cards.count > 2 {
                MiniCardView(card: cards[2], position: SpreadType.celticCross.positions[2])
                    .onTapGesture { onTap(cards[2]) }
            }
            
            // Row 4: Staff continues (cards 7, 8, 9)
            HStack(spacing: 8) {
                ForEach(7..<10) { i in
                    if i < cards.count {
                        MiniCardView(card: cards[i], position: SpreadType.celticCross.positions[i])
                            .onTapGesture { onTap(cards[i]) }
                    }
                }
            }
        }
    }
}

struct TarotCardView: View {
    let card: TarotCard
    
    var body: some View {
        ZStack {
            // Card background with glassmorphism
            RoundedRectangle(cornerRadius: 16)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#E5C158").opacity(0.6), Color(hex: "#E5C158").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color(hex: "#E5C158").opacity(0.2), radius: 20)
            
            // Card content
            VStack(spacing: 12) {
                // Card illustration placeholder
                ZStack {
                    Circle()
                        .fill(card.suit.color.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Text(card.suit.symbol)
                        .font(.system(size: 40))
                }
                
                // Card number/name
                Text(card.suit == .majorArcana ? "\(card.number)" : "\(card.number)")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "#E5C158"))
                
                // Roman numeral for major arcana
                if card.suit == .majorArcana {
                    Text(romanNumeral(card.number))
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
                }
            }
            .padding()
            .rotationEffect(card.isReversed ? .degrees(180) : .degrees(0))
        }
        .frame(width: 120, height: 180)
        .accessibilityLabel("\(card.displayName)\(card.isReversed ? ", reversed" : "")")
        .accessibilityHint("Double tap to view card details")
    }
    
    func romanNumeral(_ num: Int) -> String {
        let values = [10, 9, 5, 4, 1]
        let symbols = ["X", "IX", "V", "IV", "I"]
        var num = num
        var result = ""
        for (value, symbol) in zip(values, symbols) {
            while num >= value {
                result += symbol
                num -= value
            }
        }
        return result
    }
}

struct MiniCardView: View {
    let card: TarotCard
    let position: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E5C158").opacity(0.4), lineWidth: 1)
                    )
                
                Text(card.suit.symbol)
                    .font(.system(size: 20))
                    .rotationEffect(card.isReversed ? .degrees(180) : .degrees(0))
            }
            .frame(width: 50, height: 70)
            
            Text(position)
                .font(.system(size: 8))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
        .accessibilityLabel("\(card.displayName) at \(position)\(card.isReversed ? ", reversed" : "")")
        .accessibilityHint("Double tap to view card details")
    }
}

struct CardBackView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1A0B2E"), Color(hex: "#261447")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Mystical pattern
            VStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 4) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color(hex: "#E5C158").opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            
            // Border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 2)
        }
        .frame(width: 80, height: 120)
    }
}

struct CardDetailView: View {
    let card: TarotCard
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .accessibilityLabel("Close card detail")
                        .accessibilityHint("Double tap to close the card detail view")
                    }
                    
                    // Card display
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 320)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#E5C158"), lineWidth: 3)
                            )
                            .shadow(color: Color(hex: "#E5C158").opacity(0.3), radius: 30)
                        
                        VStack(spacing: 20) {
                            Text(card.suit.symbol)
                                .font(.system(size: 80))
                            
                            Text(card.displayName)
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .rotationEffect(card.isReversed ? .degrees(180) : .degrees(0))
                        }
                    }
                    
                    // Card info
                    VStack(alignment: .leading, spacing: 16) {
                        // Orientation
                        HStack {
                            Text(card.isReversed ? "🔄 Reversed" : "⬆️ Upright")
                                .font(.headline)
                                .foregroundColor(card.isReversed ? .red.opacity(0.8) : Color(hex: "#E5C158"))
                            
                            Spacer()
                            
                            if let astro = card.astrology {
                                Text("♈ \(astro)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Keywords
                        Text("Keywords")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        FlowLayout(spacing: 8) {
                            ForEach(card.currentKeywords, id: \.self) { keyword in
                                KeywordPill(text: keyword)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Meaning
                        Text("Meaning")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Text(card.currentMeaning)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Description
                        Text("About this card")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Text(card.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                        
                        // Element
                        HStack {
                            Text("Element:")
                                .foregroundColor(.white.opacity(0.6))
                            Text(card.element)
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        .padding(.top, 8)
                    }
                    .padding()
                    .glassmorphicCard()
                }
                .padding()
            }
        }
    }
}

struct DailyCardDisplay: View {
    let card: TarotCard
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color(hex: "#E5C158").opacity(0.2))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
            
            // Card
            VStack(spacing: 16) {
                TarotCardView(card: card)
                    .scaleEffect(1.3)
                
                Text(card.displayName)
                    .font(.title2)
                    .foregroundColor(.white)
                
                if card.isReversed {
                    Text("Reversed")
                        .font(.subheadline)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 40)
    }
}

struct SaveReadingSection: View {
    @ObservedObject var viewModel: TarotViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Reading title (optional)", text: $viewModel.readingTitle)
                .textFieldStyle(GlassmorphicTextFieldStyle())
            
            TextEditor(text: $viewModel.readingNotes)
                .frame(height: 100)
                .glassmorphicTextEditor()
                .overlay(
                    Group {
                        if viewModel.readingNotes.isEmpty {
                            Text("Add notes about your reading...")
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 8)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            Button(action: { viewModel.saveReading() }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Reading")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#E5C158").opacity(0.8), Color(hex: "#F0D878").opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .accessibilityLabel("Save reading")
            .accessibilityHint("Double tap to save this tarot reading to your history")
        }
        .padding()
        .glassmorphicCard()
    }
}

struct ReadingHistoryCard: View {
    let reading: TarotReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reading.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(reading.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text(reading.spreadType.rawValue)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#E5C158"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#E5C158").opacity(0.15))
                    .cornerRadius(8)
            }
            
            // Mini card previews
            HStack(spacing: -15) {
                ForEach(reading.cards.prefix(4)) { card in
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#1A0B2E"))
                            .frame(width: 40, height: 40)
                        
                        Text(card.suit.symbol)
                            .font(.system(size: 16))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 1)
                    )
                }
                
                if reading.cards.count > 4 {
                    Text("+\(reading.cards.count - 4)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 8)
                }
            }
            
            if !reading.notes.isEmpty {
                Text(reading.notes)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding()
        .glassmorphicCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reading.title), \(reading.spreadType.rawValue), \(reading.cards.count) cards")
        .accessibilityHint("Double tap to view reading details")
    }
}

struct ReadingDetailView: View {
    let reading: TarotReading
    @ObservedObject var viewModel: TarotViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .accessibilityLabel("Close reading detail")
                        .accessibilityHint("Double tap to close the reading detail view")
                        
                        Spacer()
                        
                        ShareLink(item: viewModel.shareReading(reading: reading)) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#E5C158"))
                        }
                        .accessibilityLabel("Share reading")
                        .accessibilityHint("Double tap to share this reading")
                    }
                    
                    Text(reading.title)
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text(reading.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Cards
                    VStack(spacing: 16) {
                        ForEach(Array(reading.cards.enumerated()), id: \.element.id) { index, card in
                            ReadingDetailCardRow(
                                card: card,
                                position: reading.spreadType.positions[safe: index] ?? "Card \(index + 1)"
                            )
                        }
                    }
                    
                    if !reading.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#E5C158"))
                            
                            Text(reading.notes)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .glassmorphicCard()
                    }
                }
                .padding()
            }
        }
    }
}

struct ReadingDetailCardRow: View {
    let card: TarotCard
    let position: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Mini card
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 1)
                    )
                
                Text(card.suit.symbol)
                    .font(.system(size: 24))
                    .rotationEffect(card.isReversed ? .degrees(180) : .degrees(0))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(position)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#E5C158"))
                
                Text(card.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if card.isReversed {
                    Text("Reversed")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
                
                Text(card.currentKeywords.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .glassmorphicCard()
    }
}

struct LibraryCardView: View {
    let card: TarotCard
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E5C158").opacity(0.3), lineWidth: 1)
                    )
                
                VStack(spacing: 4) {
                    Text(card.suit.symbol)
                        .font(.system(size: 32))
                    
                    if card.suit == .majorArcana {
                        Text(romanNumeral(card.number))
                            .font(.system(size: 10, design: .serif))
                            .foregroundColor(Color(hex: "#E5C158"))
                    } else {
                        Text("\(card.number)")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#E5C158"))
                    }
                }
            }
            
            Text(card.name)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
        }
        .accessibilityLabel("\(card.name), \(card.suit.rawValue)")
        .accessibilityHint("Double tap to view card details")
    }
    
    func romanNumeral(_ num: Int) -> String {
        let values = [10, 9, 5, 4, 1]
        let symbols = ["X", "IX", "V", "IV", "I"]
        var num = num
        var result = ""
        for (value, symbol) in zip(values, symbols) {
            while num >= value {
                result += symbol
                num -= value
            }
        }
        return result
    }
}

// MARK: - Helper Views

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#E5C158").opacity(0.5))
            
            Text("Ready to begin")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Select a spread and shuffle the deck to receive your reading")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .glassmorphicCard()
    }
}

struct SavedConfirmationView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text("Reading Saved")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 1)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                        Color(hex: "#E5C158") :
                        Color.white.opacity(0.1)
                )
                .cornerRadius(20)
        }
        .accessibilityLabel("\(title) filter")
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") \(title) cards")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search cards...", text: $text)
                .foregroundColor(.white)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .glassmorphicCard()
    }
}

struct KeywordPill: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color(hex: "#E5C158"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: "#E5C158").opacity(0.15))
            .cornerRadius(12)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - View Modifiers

extension View {
    func glassmorphicCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
    }
    
    func glassmorphicTextEditor() -> some View {
        self
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

struct GlassmorphicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension TarotSuit {
    var color: Color {
        switch self {
        case .wands: return .orange
        case .cups: return .blue
        case .swords: return .yellow
        case .pentacles: return .green
        case .majorArcana: return .purple
        }
    }
}

// MARK: - Preview

struct TarotView_Previews: PreviewProvider {
    static var previews: some View {
        TarotView()
    }
}
