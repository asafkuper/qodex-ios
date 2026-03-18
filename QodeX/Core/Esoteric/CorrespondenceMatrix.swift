//
//  CorrespondenceMatrix.swift
//  QodeX - Unified Esoteric Framework
//
//  The master mapping system connecting all esoteric disciplines.
//  This is the "Rosetta Stone" that translates between systems.
//

import Foundation

// MARK: - Correspondence Matrix

/// The central registry of correspondences between all esoteric systems.
/// This enables cross-system intelligence and unified readings.
class CorrespondenceMatrix {
    static let shared = CorrespondenceMatrix()
    
    // MARK: - Grand Correspondence Table
    
    /// The master table mapping numbers to complete correspondences
    private let grandTable: [Int: CompleteCorrespondence]
    
    /// Index by planet
    private let planetIndex: [Planet: [CompleteCorrespondence]]
    
    /// Index by Sephirah
    private let sephirahIndex: [Sephirah: CompleteCorrespondence]
    
    /// Index by Tarot Major Arcana
    private let tarotIndex: [Int: CompleteCorrespondence]  // 0-21
    
    /// Index by element
    private let elementIndex: [Element: [CompleteCorrespondence]]
    
    /// Index by frequency
    private let frequencyIndex: [SolfeggioFrequency: [CompleteCorrespondence]]
    
    private init() {
        // Build the grand table
        var table: [Int: CompleteCorrespondence] = [:]
        var byPlanet: [Planet: [CompleteCorrespondence]] = [:]
        var bySephirah: [Sephirah: CompleteCorrespondence] = [:]
        var byTarot: [Int: CompleteCorrespondence] = [:]
        var byElement: [Element: [CompleteCorrespondence]] = [:]
        var byFrequency: [SolfeggioFrequency: [CompleteCorrespondence]] = [:]
        
        // Build 1-10 + master numbers
        for number in 1...10 {
            let correspondence = CompleteCorrespondence.forNumber(number)
            table[number] = correspondence
            
            // Index by planet
            byPlanet[correspondence.planetaryRuler, default: []].append(correspondence)
            
            // Index by Sephirah
            bySephirah[correspondence.sephirah] = correspondence
            
            // Index by Tarot
            byTarot[correspondence.tarotMajor] = correspondence
            
            // Index by element
            byElement[correspondence.element, default: []].append(correspondence)
            
            // Index by frequency
            byFrequency[correspondence.solfeggioFrequency, default: []].append(correspondence)
        }
        
        // Add master numbers
        let master11 = CompleteCorrespondence.forNumber(11)
        table[11] = master11
        bySephirah[master11.sephirah] = master11
        byTarot[master11.tarotMajor] = master11
        
        let master22 = CompleteCorrespondence.forNumber(22)
        table[22] = master22
        byTarot[master22.tarotMajor] = master22
        
        let master33 = CompleteCorrespondence.forNumber(33)
        table[33] = master33
        
        self.grandTable = table
        self.planetIndex = byPlanet
        self.sephirahIndex = bySephirah
        self.tarotIndex = byTarot
        self.elementIndex = byElement
        self.frequencyIndex = byFrequency
    }
    
    // MARK: - Lookup Methods
    
    /// Get complete correspondence for a number
    func findByNumber(_ number: Int) -> CompleteCorrespondence? {
        return grandTable[number]
    }
    
    /// Get correspondences for a planet
    func findByPlanet(_ planet: Planet) -> [CompleteCorrespondence] {
        return planetIndex[planet] ?? []
    }
    
    /// Get correspondence for a Sephirah
    func findBySephirah(_ sephirah: Sephirah) -> CompleteCorrespondence? {
        return sephirahIndex[sephirah]
    }
    
    /// Get correspondence for a Tarot Major Arcana (0-21)
    func findByTarotMajor(_ cardNumber: Int) -> CompleteCorrespondence? {
        return tarotIndex[cardNumber]
    }
    
    /// Get correspondences for an element
    func findByElement(_ element: Element) -> [CompleteCorrespondence] {
        return elementIndex[element] ?? []
    }
    
    /// Get correspondences for a Solfeggio frequency
    func findBySolfeggio(_ frequency: SolfeggioFrequency) -> [CompleteCorrespondence] {
        return frequencyIndex[frequency] ?? []
    }
    
    /// Get correspondence by Hebrew letter
    func findByHebrewLetter(_ letter: HebrewLetter) -> CompleteCorrespondence? {
        return grandTable.values.first { $0.hebrewLetter == letter }
    }
    
    /// Get correspondence by day of week
    func findByDay(_ day: DayOfWeek) -> [CompleteCorrespondence] {
        return grandTable.values.filter { $0.dayOfWeek == day }
    }
    
    // MARK: - Cross-Query Methods
    
    /// Find what connects two different systems
    func findBridge(from: Query, to: Query) -> [BridgeResult] {
        var results: [BridgeResult] = []
        
        // Get source correspondences
        let sourceCorrespondences = findCorrespondences(for: from)
        
        // For each source, check if it matches the target query
        for corr in sourceCorrespondences {
            if matches(corr, query: to) {
                results.append(BridgeResult(
                    sourceValue: from.description,
                    targetValue: to.description,
                    throughCorrespondence: corr,
                    significance: .strong
                ))
            }
        }
        
        return results
    }
    
    /// Find all systems that share a value with the query
    func findSharedSystems(_ query: Query) -> [SystemConnection] {
        guard let correspondence = findCorrespondences(for: query).first else {
            return []
        }
        
        return [
            SystemConnection(system: "Numerology", value: "\(correspondence.number)"),
            SystemConnection(system: "Astrology", value: correspondence.planetaryRuler.rawValue),
            SystemConnection(system: "Kabbalah", value: correspondence.sephirah.name),
            SystemConnection(system: "Tarot", value: "Major Arcana \(correspondence.tarotMajor)"),
            SystemConnection(system: "Alchemy", value: correspondence.element.rawValue),
            SystemConnection(system: "Frequency", value: "\(correspondence.solfeggioFrequency.rawValue)Hz"),
        ]
    }
    
    // MARK: - Synthesis
    
    /// Synthesize multiple energy signatures into a unified reading
    func synthesize(_ signatures: [EnergySignature]) -> UnifiedCorrespondence {
        // Find common correspondences across all signatures
        var numberMatches: [Int: Int] = [:]
        
        for sig in signatures {
            for (num, _) in sig.coreNumbers {
                numberMatches[num, default: 0] += 1
            }
        }
        
        // Numbers that appear in multiple signatures are significant
        let convergentNumbers = numberMatches
            .filter { $0.value > 1 }
            .sorted { $0.value > $1.value }
            .map { $0.key }
        
        // Get full correspondences for convergent numbers
        let convergentCorrespondences = convergentNumbers.compactMap { grandTable[$0] }
        
        // Build unified interpretation
        let themes = convergentCorrespondences.map { $0.theme }
        let unifiedTheme = themes.joined(separator: " + ")
        
        return UnifiedCorrespondence(
            convergentNumbers: convergentNumbers,
            correspondences: convergentCorrespondences,
            unifiedTheme: unifiedTheme,
            primaryEnergy: signatures.first?.vibrationalQuality ?? .integrating,
            significance: convergentNumbers.isEmpty ? .low : .high
        )
    }
    
    /// Detect synchronicities across a user's blueprint
    func detectSynchronicities(in blueprint: PersonalBlueprint, date: Date = Date()) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // Get user's numbers
        let userNumbers = [
            blueprint.numerology.lifePath,
            blueprint.numerology.expression,
            blueprint.numerology.soulUrge,
            blueprint.numerology.birthday
        ]
        
        // Check current date against user numbers
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        // Date matches user's numbers
        if userNumbers.contains(day) {
            patterns.append(.dateMatch(number: day, component: .day))
        }
        if userNumbers.contains(month) {
            patterns.append(.dateMatch(number: month, component: .month))
        }
        
        // Check day of week
        let weekday = calendar.component(.weekday, from: date)
        if let dayOfWeek = DayOfWeek(rawValue: weekday),
           let correspondence = findByDay(dayOfWeek).first,
           userNumbers.contains(correspondence.number) {
            patterns.append(.dayOfWeekMatch(day: dayOfWeek, number: correspondence.number))
        }
        
        // Check for master number activation
        let masterNumbers = userNumbers.filter { [11, 22, 33].contains($0) }
        if !masterNumbers.isEmpty {
            patterns.append(.masterNumberActivation(numbers: masterNumbers))
        }
        
        return patterns
    }
    
    // MARK: - Private Helpers
    
    private func findCorrespondences(for query: Query) -> [CompleteCorrespondence] {
        switch query {
        case .number(let n):
            return grandTable[n].map { [$0] } ?? []
        case .planet(let p):
            return planetIndex[p] ?? []
        case .sephirah(let s):
            return sephirahIndex[s].map { [$0] } ?? []
        case .tarotMajor(let t):
            return tarotIndex[t].map { [$0] } ?? []
        case .element(let e):
            return elementIndex[e] ?? []
        case .frequency(let f):
            return frequencyIndex[f] ?? []
        }
    }
    
    private func matches(_ correspondence: CompleteCorrespondence, query: Query) -> Bool {
        switch query {
        case .number(let n): return correspondence.number == n
        case .planet(let p): return correspondence.planetaryRuler == p
        case .sephirah(let s): return correspondence.sephirah == s
        case .tarotMajor(let t): return correspondence.tarotMajor == t
        case .element(let e): return correspondence.element == e
        case .frequency(let f): return correspondence.solfeggioFrequency == f
        }
    }
}

// MARK: - Complete Correspondence

/// A complete cross-system correspondence for a given number
struct CompleteCorrespondence {
    let number: Int
    let planetaryRuler: Planet
    let sephirah: Sephirah
    let tarotMajor: Int  // 0-21
    let tarotMinorSuit: Suit
    let element: Element
    let solfeggioFrequency: SolfeggioFrequency
    let sacredForm: SacredForm
    let hebrewLetter: HebrewLetter
    let alchemicalStage: AlchemicalStage
    let color: EsotericColor
    let crystal: Crystal
    let archangel: Archangel
    let virtue: String
    let vice: String
    let dayOfWeek: DayOfWeek?
    let theme: String
    
    enum Suit: String {
        case wands = "Wands"
        case cups = "Cups"
        case swords = "Swords"
        case pentacles = "Pentacles"
    }
    
    static func forNumber(_ number: Int) -> CompleteCorrespondence {
        switch number {
        case 1:
            return CompleteCorrespondence(
                number: 1,
                planetaryRuler: .sun,
                sephirah: .kether,
                tarotMajor: 1,  // Magician
                tarotMinorSuit: .wands,
                element: .fire,
                solfeggioFrequency: .si,
                sacredForm: .circle,
                hebrewLetter: .aleph,
                alchemicalStage: .coagulation,
                color: .brightGold,
                crystal: .clearQuartz,
                archangel: .metatron,
                virtue: "Independence, leadership, originality",
                vice: "Selfishness, ego, isolation",
                dayOfWeek: .sunday,
                theme: "Creation, Will, New Beginnings"
            )
            
        case 2:
            return CompleteCorrespondence(
                number: 2,
                planetaryRuler: .moon,
                sephirah: .chokmah,
                tarotMajor: 2,  // High Priestess
                tarotMinorSuit: .cups,
                element: .water,
                solfeggioFrequency: .la,
                sacredForm: .vesicaPiscis,
                hebrewLetter: .beth,
                alchemicalStage: .dissolution,
                color: .silver,
                crystal: .moonstone,
                archangel: .raziel,
                virtue: "Cooperation, intuition, diplomacy",
                vice: "Over-sensitivity, indecision, dependency",
                dayOfWeek: .monday,
                theme: "Duality, Reflection, Partnership"
            )
            
        case 3:
            return CompleteCorrespondence(
                number: 3,
                planetaryRuler: .jupiter,
                sephirah: .binah,
                tarotMajor: 3,  // Empress
                tarotMinorSuit: .cups,
                element: .water,
                solfeggioFrequency: .sol,
                sacredForm: .triangle,
                hebrewLetter: .gimel,
                alchemicalStage: .fermentation,
                color: .yellow,
                crystal: .yellowSapphire,
                archangel: .tzaphkiel,
                virtue: "Creativity, expression, joy",
                vice: "Scattered energy, superficiality, excess",
                dayOfWeek: .thursday,
                theme: "Expression, Abundance, Creation"
            )
            
        case 4:
            return CompleteCorrespondence(
                number: 4,
                planetaryRuler: .uranus,
                sephirah: .chesed,
                tarotMajor: 4,  // Emperor
                tarotMinorSuit: .pentacles,
                element: .earth,
                solfeggioFrequency: .fa,
                sacredForm: .cube,
                hebrewLetter: .daleth,
                alchemicalStage: .calcination,
                color: .blue,
                crystal: .lapisLazuli,
                archangel: .tzadkiel,
                virtue: "Stability, order, practicality",
                vice: "Rigidity, limitation, stubbornness",
                dayOfWeek: .wednesday,
                theme: "Structure, Foundation, Stability"
            )
            
        case 5:
            return CompleteCorrespondence(
                number: 5,
                planetaryRuler: .mercury,
                sephirah: .geburah,
                tarotMajor: 5,  // Hierophant
                tarotMinorSuit: .swords,
                element: .air,
                solfeggioFrequency: .mi,
                sacredForm: .pentagon,
                hebrewLetter: .heh,
                alchemicalStage: .separation,
                color: .orange,
                crystal: .agate,
                archangel: .khamael,
                virtue: "Freedom, adaptability, versatility",
                vice: "Restlessness, inconsistency, excess",
                dayOfWeek: .wednesday,
                theme: "Change, Freedom, Communication"
            )
            
        case 6:
            return CompleteCorrespondence(
                number: 6,
                planetaryRuler: .venus,
                sephirah: .tiphareth,
                tarotMajor: 6,  // Lovers
                tarotMinorSuit: .swords,
                element: .air,
                solfeggioFrequency: .mi,
                sacredForm: .hexagon,
                hebrewLetter: .vau,
                alchemicalStage: .conjunction,
                color: .pink,
                crystal: .roseQuartz,
                archangel: .raphael,
                virtue: "Harmony, love, responsibility",
                vice: "Self-sacrifice, martyrdom, perfectionism",
                dayOfWeek: .friday,
                theme: "Harmony, Love, Balance"
            )
            
        case 7:
            return CompleteCorrespondence(
                number: 7,
                planetaryRuler: .neptune,
                sephirah: .netzach,
                tarotMajor: 7,  // Chariot
                tarotMinorSuit: .cups,
                element: .water,
                solfeggioFrequency: .re,
                sacredForm: .seedOfLife,
                hebrewLetter: .zayin,
                alchemicalStage: .distillation,
                color: .violet,
                crystal: .amethyst,
                archangel: .haniel,
                virtue: "Wisdom, analysis, spirituality",
                vice: "Isolation, skepticism, aloofness",
                dayOfWeek: .saturday,
                theme: "Mystery, Wisdom, Spirituality"
            )
            
        case 8:
            return CompleteCorrespondence(
                number: 8,
                planetaryRuler: .saturn,
                sephirah: .hod,
                tarotMajor: 8,  // Strength
                tarotMinorSuit: .pentacles,
                element: .earth,
                solfeggioFrequency: .re,
                sacredForm: .octagon,
                hebrewLetter: .cheth,
                alchemicalStage: .coagulation,
                color: .indigo,
                crystal: .obsidian,
                archangel: .michael,
                virtue: "Power, abundance, authority",
                vice: "Materialism, greed, domination",
                dayOfWeek: .saturday,
                theme: "Power, Infinity, Abundance"
            )
            
        case 9:
            return CompleteCorrespondence(
                number: 9,
                planetaryRuler: .mars,
                sephirah: .yesod,
                tarotMajor: 9,  // Hermit
                tarotMinorSuit: .pentacles,
                element: .earth,
                solfeggioFrequency: .ut,
                sacredForm: .enneagram,
                hebrewLetter: .teth,
                alchemicalStage: .fermentation,
                color: .red,
                crystal: .ruby,
                archangel: .gabriel,
                virtue: "Compassion, completion, service",
                vice: "Self-pity, attachment, endings",
                dayOfWeek: .tuesday,
                theme: "Completion, Compassion, Service"
            )
            
        case 10:
            return CompleteCorrespondence(
                number: 10,
                planetaryRuler: .pluto,
                sephirah: .malkuth,
                tarotMajor: 10,  // Wheel of Fortune
                tarotMinorSuit: .pentacles,
                element: .earth,
                solfeggioFrequency: .ut,
                sacredForm: .treeOfLife,
                hebrewLetter: .yod,
                alchemicalStage: .coagulation,
                color: .brown,
                crystal: .garnet,
                archangel: .sandalphon,
                virtue: "Manifestation, completion, destiny",
                vice: "Attachment to outcome, stagnation",
                dayOfWeek: nil,
                theme: "Manifestation, Completion, Return"
            )
            
        case 11:
            // Master Number 11 - Illumination
            return CompleteCorrespondence(
                number: 11,
                planetaryRuler: .moon,  // Secondary
                sephirah: .daath,
                tarotMajor: 11,  // Justice
                tarotMinorSuit: .swords,
                element: .air,
                solfeggioFrequency: .la,  // Spiritual order
                sacredForm: .metatronsCube,
                hebrewLetter: .kaph,
                alchemicalStage: .distillation,
                color: .silver,
                crystal: .selenite,
                archangel: .uriel,
                virtue: "Illumination, intuition, spiritual insight",
                vice: "Anxiety, nervous tension, over-sensitivity",
                dayOfWeek: nil,
                theme: "Master Illuminator, Gateway"
            )
            
        case 22:
            // Master Number 22 - Master Builder
            return CompleteCorrespondence(
                number: 22,
                planetaryRuler: .uranus,
                sephirah: .yesod,
                tarotMajor: 0,  // The Fool (22nd path)
                tarotMinorSuit: .pentacles,
                element: .earth,
                solfeggioFrequency: .ut,
                sacredForm: .treeOfLife,
                hebrewLetter: .lamed,
                alchemicalStage: .coagulation,
                color: .white,
                crystal: .diamond,
                archangel: .metatron,
                virtue: "Mastery, practical manifestation, legacy",
                vice: "Overwhelm, dictatorship, impracticality",
                dayOfWeek: nil,
                theme: "Master Builder, Cosmic Manifestation"
            )
            
        case 33:
            // Master Number 33 - Christ Consciousness
            return CompleteCorrespondence(
                number: 33,
                planetaryRuler: .jupiter,
                sephirah: .tiphareth,
                tarotMajor: 12,  // Hanged Man (sacrifice)
                tarotMinorSuit: .cups,
                element: .water,
                solfeggioFrequency: .mi,
                sacredForm: .flowerOfLife,
                hebrewLetter: .mem,
                alchemicalStage: .dissolution,
                color: .gold,
                crystal: .goldCalcite,
                archangel: .metatron,
                virtue: "Christ consciousness, unconditional love, healing",
                vice: "Martyr complex, over-giving, burnout",
                dayOfWeek: nil,
                theme: "Master Teacher, Universal Love"
            )
            
        default:
            // Fallback for numbers outside 1-33
            return CompleteCorrespondence(
                number: number,
                planetaryRuler: .sun,
                sephirah: .malkuth,
                tarotMajor: number % 22,
                tarotMinorSuit: .wands,
                element: .quintessence,
                solfeggioFrequency: .si,
                sacredForm: .circle,
                hebrewLetter: .aleph,
                alchemicalStage: .calcination,
                color: .white,
                crystal: .clearQuartz,
                archangel: .metatron,
                virtue: "Universal potential",
                vice: "Scattered energy",
                dayOfWeek: nil,
                theme: "Unknown, Explore"
            )
        }
    }
}

// MARK: - Supporting Types

enum DayOfWeek: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var rulingPlanet: Planet {
        switch self {
        case .sunday: return .sun
        case .monday: return .moon
        case .tuesday: return .mars
        case .wednesday: return .mercury
        case .thursday: return .jupiter
        case .friday: return .venus
        case .saturday: return .saturn
        }
    }
}

enum EsotericColor: String {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case indigo = "Indigo"
    case violet = "Violet"
    case white = "White"
    case black = "Black"
    case silver = "Silver"
    case gold = "Gold"
    case brightGold = "Bright Gold"
    case brown = "Brown"
    case pink = "Pink"
    case lavender = "Lavender"
    
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .indigo: return .indigo
        case .violet: return .purple
        case .white: return .white
        case .black: return .black
        case .silver: return .gray
        case .gold: return Color.yellow.opacity(0.8)
        case .brightGold: return Color.yellow
        case .brown: return Color.brown
        case .pink: return .pink
        case .lavender: return Color(hex: "9B7CB6")
        }
    }
}

enum Crystal: String {
    case clearQuartz = "Clear Quartz"
    case amethyst = "Amethyst"
    case roseQuartz = "Rose Quartz"
    case citrine = "Citrine"
    case lapisLazuli = "Lapis Lazuli"
    case obsidian = "Obsidian"
    case moonstone = "Moonstone"
    case garnet = "Garnet"
    case ruby = "Ruby"
    case agate = "Agate"
    case yellowSapphire = "Yellow Sapphire"
    case selenite = "Selenite"
    case diamond = "Diamond"
    case goldCalcite = "Gold Calcite"
    
    var properties: String {
        switch self {
        case .clearQuartz:
            return "Amplification, clarity, programming"
        case .amethyst:
            return "Spiritual protection, intuition, calm"
        case .roseQuartz:
            return "Love, compassion, emotional healing"
        case .citrine:
            return "Abundance, manifestation, confidence"
        case .lapisLazuli:
            return "Wisdom, truth, royal energies"
        case .obsidian:
            return "Protection, grounding, shadow work"
        case .moonstone:
            return "Intuition, feminine energy, cycles"
        case .garnet:
            return "Passion, energy, revitalization"
        case .ruby:
            return "Vitality, courage, heart energy"
        case .agate:
            return "Stability, grounding, strength"
        case .yellowSapphire:
            return "Wisdom, prosperity, spiritual growth"
        case .selenite:
            return "Cleansing, clarity, angelic connection"
        case .diamond:
            return "Purity, strength, invincibility"
        case .goldCalcite:
            return "Confidence, manifestation, higher consciousness"
        }
    }
}

enum Archangel: String {
    case metatron = "Metatron"
    case raziel = "Raziel"
    case tzaphkiel = "Tzaphkiel"
    case tzadkiel = "Tzadkiel"
    case khamael = "Khamael"
    case raphael = "Raphael"
    case haniel = "Haniel"
    case michael = "Michael"
    case gabriel = "Gabriel"
    case sandalphon = "Sandalphon"
    case uriel = "Uriel"
    
    var domain: String {
        switch self {
        case .metatron:
            return "Divine presence, records, sacred geometry"
        case .raziel:
            return "Divine mysteries, esoteric knowledge"
        case .tzaphkiel:
            return "Understanding, contemplation, Binah"
        case .tzadkiel:
            return "Mercy, benevolence, memory"
        case .khamael:
            return "Severity, divine justice, courage"
        case .raphael:
            return "Healing, guidance, Tiphareth"
        case .haniel:
            return "Love, harmony, Netzach"
        case .michael:
            return "Protection, strength, Hod"
        case .gabriel:
            return "Messages, resurrection, Yesod"
        case .sandalphon:
            return "Grounding, prayers, Malkuth"
        case .uriel:
            return "Wisdom, prophecy, illumination"
        }
    }
}

// MARK: - Query Types

enum Query: CustomStringConvertible {
    case number(Int)
    case planet(Planet)
    case sephirah(Sephirah)
    case tarotMajor(Int)
    case element(Element)
    case frequency(SolfeggioFrequency)
    
    var description: String {
        switch self {
        case .number(let n): return "Number \(n)"
        case .planet(let p): return p.rawValue
        case .sephirah(let s): return s.name
        case .tarotMajor(let t): return "Tarot \(t)"
        case .element(let e): return e.rawValue
        case .frequency(let f): return "\(f.rawValue)Hz"
        }
    }
}

// MARK: - Result Types

struct BridgeResult {
    let sourceValue: String
    let targetValue: String
    let throughCorrespondence: CompleteCorrespondence
    let significance: Significance
    
    enum Significance {
        case weak
        case moderate
        case strong
        case primary
    }
}

struct SystemConnection {
    let system: String
    let value: String
}

struct UnifiedCorrespondence {
    let convergentNumbers: [Int]
    let correspondences: [CompleteCorrespondence]
    let unifiedTheme: String
    let primaryEnergy: VibrationalQuality
    let significance: Significance
    
    enum Significance {
        case low
        case medium
        case high
    }
}

enum SynchronicityPattern {
    case dateMatch(number: Int, component: DateComponent)
    case dayOfWeekMatch(day: DayOfWeek, number: Int)
    case masterNumberActivation(numbers: [Int])
    case planetaryReturn(planet: Planet, age: Int)
    case elementConvergence(element: Element, systems: [String])
    
    enum DateComponent {
        case day
        case month
        case year
    }
    
    var description: String {
        switch self {
        case .dateMatch(let number, let component):
            return "Your number \(number) appears in today's \(component)"
        case .dayOfWeekMatch(let day, let number):
            return "\(day.name) (ruled by \(day.rulingPlanet.rawValue)) corresponds to your number \(number)"
        case .masterNumberActivation(let numbers):
            return "Master number(s) \(numbers.map(String.init).joined(separator: ", ")) are activated today"
        case .planetaryReturn(let planet, let age):
            return "\(planet.rawValue) return at age \(age)"
        case .elementConvergence(let element, let systems):
            return "\(element.rawValue) energy converges across \(systems.joined(separator: ", "))"
        }
    }
}

enum SolfeggioFrequency: Double, CaseIterable {
    case ut = 174    // Pain reduction, security
    case re = 285    // Healing tissues, immunity
    case mi = 396    // Liberating guilt and fear
    case fa = 417    // Undoing situations, change
    case sol = 528   // Transformation, DNA repair
    case la = 639    // Connecting, relationships
    case si = 741    // Awakening intuition
    case highSi = 852 // Returning to spiritual order
    case divine = 963 // Divine consciousness
}
