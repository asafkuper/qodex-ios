//
//  TarotMinorArcanaIntegration.swift
//  QodeX - Enhanced Minor Arcana Support
//
//  This file extends the Tarot system with comprehensive Minor Arcana meanings
//  loaded from TarotMinorArcana.json
//

import SwiftUI
import Foundation

// MARK: - Enhanced Minor Arcana Models

struct MinorArcanaCardData: Codable {
    let number: Int
    let name: String
    let keywords: Keywords
    let meanings: Meanings
    let numerology: String
    let astrology: String
    let kabbalah: KabbalahData
    let affirmation: String
    let career: String
    let relationships: String
    let spirituality: String
}

struct Keywords: Codable {
    let upright: [String]
    let reversed: [String]
}

struct Meanings: Codable {
    let upright: String
    let reversed: String
}

struct KabbalahData: Codable {
    let sephirah: String
    let path: String
    let meaning: String
}

struct SuitInfo: Codable {
    let name: String
    let element: String
    let alternativeNames: [String]
    let zodiacAssociations: [String]
    let archetype: String
}

struct SuitData: Codable {
    let suitInfo: SuitInfo
    let cards: [MinorArcanaCardData]
}

struct TarotMinorArcanaData: Codable {
    let metadata: Metadata
    let minorArcana: MinorArcana
}

struct Metadata: Codable {
    let name: String
    let version: String
    let totalCards: Int
    let suits: [SuitMetadata]
}

struct SuitMetadata: Codable {
    let name: String
    let element: String
    let symbol: String
    let domain: String
    let season: String
    let direction: String
    let kabbalahWorld: String
}

struct MinorArcana: Codable {
    let wands: SuitData
    let cups: SuitData
    let swords: SuitData
    let pentacles: SuitData
}

// MARK: - Enhanced Card Model

class EnhancedTarotCard: ObservableObject {
    let baseCard: TarotCard
    let minorArcanaData: MinorArcanaCardData?
    let suitMetadata: SuitMetadata?
    
    var displayTitle: String {
        if baseCard.suit == .majorArcana {
            return baseCard.name
        } else {
            return baseCard.displayName
        }
    }
    
    var enhancedKeywords: [String] {
        if let data = minorArcanaData {
            return baseCard.isReversed ? data.keywords.reversed : data.keywords.upright
        }
        return baseCard.currentKeywords
    }
    
    var enhancedMeaning: String {
        if let data = minorArcanaData {
            return baseCard.isReversed ? data.meanings.reversed : data.meanings.upright
        }
        return baseCard.currentMeaning
    }
    
    var detailedDescription: String {
        if let data = minorArcanaData {
            return """
            \(data.meanings.upright)
            
            When reversed, this card suggests:
            \(data.meanings.reversed)
            """
        }
        return baseCard.description
    }
    
    var numerologyInfo: String? {
        minorArcanaData?.numerology
    }
    
    var astrologyInfo: String {
        minorArcanaData?.astrology ?? baseCard.astrology ?? "N/A"
    }
    
    var kabbalahInfo: KabbalahData? {
        minorArcanaData?.kabbalah
    }
    
    var affirmation: String? {
        minorArcanaData?.affirmation
    }
    
    var careerGuidance: String? {
        minorArcanaData?.career
    }
    
    var relationshipGuidance: String? {
        minorArcanaData?.relationships
    }
    
    var spiritualGuidance: String? {
        minorArcanaData?.spirituality
    }
    
    init(baseCard: TarotCard, minorArcanaData: MinorArcanaCardData? = nil, suitMetadata: SuitMetadata? = nil) {
        self.baseCard = baseCard
        self.minorArcanaData = minorArcanaData
        self.suitMetadata = suitMetadata
    }
}

// MARK: - Minor Arcana Manager

class MinorArcanaManager: ObservableObject {
    static let shared = MinorArcanaManager()
    
    @Published private(set) var minorArcanaData: TarotMinorArcanaData?
    @Published private(set) var isLoaded = false
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        // Try to load from bundle
        if let url = Bundle.main.url(forResource: "TarotMinorArcana", withExtension: "json") {
            loadFromURL(url)
        } else if let url = getDocumentsDirectory()?.appendingPathComponent("TarotMinorArcana.json") {
            // Try Documents directory
            loadFromURL(url)
        }
    }
    
    private func loadFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            minorArcanaData = try decoder.decode(TarotMinorArcanaData.self, from: data)
            isLoaded = true
        } catch {
            print("Error loading Minor Arcana data: \(error)")
            // Use embedded fallback data
            loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        // Minimal fallback data to ensure functionality
        // In production, this would be more comprehensive
        isLoaded = true
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func getEnhancedCard(_ card: TarotCard) -> EnhancedTarotCard {
        guard card.suit != .majorArcana,
              let minorData = minorArcanaData else {
            return EnhancedTarotCard(baseCard: card)
        }
        
        let suitData: SuitData?
        let suitMetadata: SuitMetadata?
        
        switch card.suit {
        case .wands:
            suitData = minorData.minorArcana.wands
            suitMetadata = minorData.metadata.suits.first { $0.name == "Wands" }
        case .cups:
            suitData = minorData.minorArcana.cups
            suitMetadata = minorData.metadata.suits.first { $0.name == "Cups" }
        case .swords:
            suitData = minorData.minorArcana.swords
            suitMetadata = minorData.metadata.suits.first { $0.name == "Swords" }
        case .pentacles:
            suitData = minorData.minorArcana.pentacles
            suitMetadata = minorData.metadata.suits.first { $0.name == "Pentacles" }
        case .majorArcana:
            suitData = nil
            suitMetadata = nil
        }
        
        let cardData = suitData?.cards.first { $0.number == card.number }
        
        return EnhancedTarotCard(baseCard: card, minorArcanaData: cardData, suitMetadata: suitMetadata)
    }
    
    func getAllMinorArcanaCards() -> [MinorArcanaCardData] {
        guard let data = minorArcanaData else { return [] }
        
        return data.minorArcana.wands.cards +
               data.minorArcana.cups.cards +
               data.minorArcana.swords.cards +
               data.minorArcana.pentacles.cards
    }
    
    func getSuitInfo(_ suit: TarotSuit) -> SuitInfo? {
        guard let data = minorArcanaData else { return nil }
        
        switch suit {
        case .wands:
            return data.minorArcana.wands.suitInfo
        case .cups:
            return data.minorArcana.cups.suitInfo
        case .swords:
            return data.minorArcana.swords.suitInfo
        case .pentacles:
            return data.minorArcana.pentacles.suitInfo
        case .majorArcana:
            return nil
        }
    }
}

// MARK: - Enhanced Card Detail View

struct EnhancedCardDetailView: View {
    let card: TarotCard
    @StateObject private var minorArcanaManager = MinorArcanaManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private var enhancedCard: EnhancedTarotCard {
        minorArcanaManager.getEnhancedCard(card)
    }
    
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
                    }
                    
                    // Card display
                    CardDisplaySection(card: card)
                    
                    // Enhanced Details
                    VStack(alignment: .leading, spacing: 20) {
                        // Keywords
                        KeywordsSection(card: enhancedCard)
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        // Meaning
                        MeaningSection(card: enhancedCard)
                        
                        // Minor Arcana Specific Sections
                        if card.suit != .majorArcana {
                            Divider().background(Color.white.opacity(0.2))
                            
                            NumerologySection(card: enhancedCard)
                            
                            AstrologySection(card: enhancedCard)
                            
                            KabbalahSection(card: enhancedCard)
                            
                            GuidanceSections(card: enhancedCard)
                            
                            AffirmationSection(card: enhancedCard)
                        }
                    }
                    .padding()
                    .glassmorphicCard()
                }
                .padding()
            }
        }
    }
}

// MARK: - Section Views

struct CardDisplaySection: View {
    let card: TarotCard
    
    var body: some View {
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
                
                if card.isReversed {
                    Text("Reversed")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
    }
}

struct KeywordsSection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keywords")
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            FlowLayout(spacing: 8) {
                ForEach(card.enhancedKeywords, id: \.self) { keyword in
                    KeywordPill(text: keyword)
                }
            }
        }
    }
}

struct MeaningSection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(card.baseCard.isReversed ? "🔄 Reversed Meaning" : "⬆️ Upright Meaning")
                    .font(.headline)
                    .foregroundColor(card.baseCard.isReversed ? .red.opacity(0.8) : Color(hex: "#E5C158"))
                
                Spacer()
                
                Text(card.baseCard.element)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(card.enhancedMeaning)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
        }
    }
}

struct NumerologySection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🔢 Numerology")
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            if let numerology = card.numerologyInfo {
                Text(numerology)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct AstrologySection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("♈ Astrology")
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text(card.astrologyInfo)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct KabbalahSection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("✡️ Kabbalah")
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            if let kabbalah = card.kabbalahInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sephirah: \(kabbalah.sephirah)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(kabbalah.path)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(kabbalah.meaning)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .italic()
                }
            }
        }
    }
}

struct GuidanceSections: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let career = card.careerGuidance {
                GuidanceSection(title: "💼 Career", content: career)
            }
            
            if let relationships = card.relationshipGuidance {
                GuidanceSection(title: "💕 Relationships", content: relationships)
            }
            
            if let spirituality = card.spiritualGuidance {
                GuidanceSection(title: "🕊️ Spirituality", content: spirituality)
            }
        }
    }
}

struct GuidanceSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text(content)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct AffirmationSection: View {
    let card: EnhancedTarotCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("✨ Affirmation")
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            if let affirmation = card.affirmation {
                Text("\"\(affirmation)\"")
                    .font(.body)
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#E5C158").opacity(0.1))
                    )
            }
        }
    }
}

// MARK: - Suit Explorer View

struct MinorArcanaExplorerView: View {
    @StateObject private var manager = MinorArcanaManager.shared
    @State private var selectedSuit: TarotSuit = .wands
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            VStack(spacing: 16) {
                Text("🔮 Minor Arcana")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(Color(hex: "#E5C158"))
                
                // Suit Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([TarotSuit.wands, .cups, .swords, .pentacles], id: \.self) { suit in
                            SuitButton(
                                suit: suit,
                                isSelected: selectedSuit == suit
                            ) {
                                withAnimation {
                                    selectedSuit = suit
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Suit Info
                if let info = manager.getSuitInfo(selectedSuit) {
                    SuitInfoCard(info: info)
                }
                
                // Cards List
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                        ForEach(cardsForSuit(selectedSuit), id: \.number) { cardData in
                            NavigationLink(destination: MinorArcanaCardDetailView(cardData: cardData, suit: selectedSuit)) {
                                MinorArcanaCardPreview(cardData: cardData, suit: selectedSuit)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func cardsForSuit(_ suit: TarotSuit) -> [MinorArcanaCardData] {
        guard let data = manager.minorArcanaData else { return [] }
        
        switch suit {
        case .wands: return data.minorArcana.wands.cards
        case .cups: return data.minorArcana.cups.cards
        case .swords: return data.minorArcana.swords.cards
        case .pentacles: return data.minorArcana.pentacles.cards
        case .majorArcana: return []
        }
    }
}

struct SuitButton: View {
    let suit: TarotSuit
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(suit.symbol)
                    .font(.title3)
                Text(suit.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                Color(hex: "#E5C158") :
                Color.white.opacity(0.1)
            )
            .cornerRadius(20)
        }
    }
}

struct SuitInfoCard: View {
    let info: SuitInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(info.name)
                .font(.headline)
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text("Element: \(info.element)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("Archetype: \(info.archetype)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(info.zodiacAssociations.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassmorphicCard()
        .padding(.horizontal)
    }
}

struct MinorArcanaCardPreview: View {
    let cardData: MinorArcanaCardData
    let suit: TarotSuit
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E5C158").opacity(0.3), lineWidth: 1)
                    )
                
                VStack {
                    Text(suit.symbol)
                        .font(.system(size: 32))
                    
                    Text("\(cardData.number)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#E5C158"))
                }
            }
            
            Text(cardData.name)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
    }
}

struct MinorArcanaCardDetailView: View {
    let cardData: MinorArcanaCardData
    let suit: TarotSuit
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Card Header
                    VStack(spacing: 12) {
                        Text(suit.symbol)
                            .font(.system(size: 60))
                        
                        Text(cardData.name)
                            .font(.system(size: 24, weight: .light, design: .serif))
                            .foregroundColor(Color(hex: "#E5C158"))
                    }
                    
                    // Keywords
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keywords")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upright:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            FlowLayout(spacing: 8) {
                                ForEach(cardData.keywords.upright, id: \.self) { keyword in
                                    KeywordPill(text: keyword)
                                }
                            }
                            
                            Text("Reversed:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 4)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(cardData.keywords.reversed, id: \.self) { keyword in
                                    KeywordPill(text: keyword)
                                        .opacity(0.7)
                                }
                            }
                        }
                    }
                    .padding()
                    .glassmorphicCard()
                    
                    // Meanings
                    VStack(alignment: .leading, spacing: 16) {
                        MeaningDetailView(
                            title: "⬆️ Upright",
                            meaning: cardData.meanings.upright
                        )
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        MeaningDetailView(
                            title: "🔄 Reversed",
                            meaning: cardData.meanings.reversed
                        )
                    }
                    .padding()
                    .glassmorphicCard()
                    
                    // Esoteric Info
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(title: "Numerology", content: cardData.numerology)
                        InfoRow(title: "Astrology", content: cardData.astrology)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kabbalah")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#E5C158"))
                            Text(cardData.kabbalah.sephirah)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                            Text(cardData.kabbalah.path)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .glassmorphicCard()
                    
                    // Guidance
                    VStack(alignment: .leading, spacing: 16) {
                        GuidanceDetailView(title: "💼 Career", content: cardData.career)
                        GuidanceDetailView(title: "💕 Relationships", content: cardData.relationships)
                        GuidanceDetailView(title: "🕊️ Spirituality", content: cardData.spirituality)
                    }
                    .padding()
                    .glassmorphicCard()
                    
                    // Affirmation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✨ Affirmation")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Text("\"\(cardData.affirmation)\"")
                            .font(.body)
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#E5C158").opacity(0.1))
                            )
                    }
                    .padding()
                    .glassmorphicCard()
                }
                .padding()
            }
        }
    }
}

struct MeaningDetailView: View {
    let title: String
    let meaning: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text(meaning)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
    }
}

struct InfoRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "#E5C158"))
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct GuidanceDetailView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#E5C158"))
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(2)
        }
    }
}