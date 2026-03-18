//
//  UnifiedDailyReading.swift
//  QodeX - Unified Esoteric Framework
//
//  Synthesizes insights from all active esoteric systems into a single coherent reading.
//

import Foundation
import SwiftUI

// MARK: - Unified Daily Reading

/// The master daily reading that combines insights from all active esoteric systems.
/// This is what users see on their "Today" screen.
struct UnifiedDailyReading: Identifiable {
    let id = UUID()
    let date: Date
    let blueprintId: UUID
    let generatedAt: Date
    
    // MARK: - Components
    
    /// Individual system readings
    let systemReadings: [String: SystemDailyReading]
    
    /// The synthesized unified theme
    let unifiedTheme: UnifiedTheme
    
    /// Detected synchronicities
    let synchronicities: [Synchronicity]
    
    /// Cross-system patterns
    let crossPatterns: [CrossSystemPattern]
    
    // MARK: - Guidance
    
    /// Overall energy for the day
    let dailyEnergy: DailyEnergy
    
    /// Key action items
    let actionItems: [ActionItem]
    
    /// Recommended meditation
    let meditation: MeditationRecommendation?
    
    /// Daily affirmation
    let affirmation: String
    
    /// Caution/warning areas
    let cautions: [String]
    
    /// Opportunity areas
    let opportunities: [String]
    
    // MARK: - Computed Properties
    
    var activeSystems: [String] {
        Array(systemReadings.keys)
    }
    
    var hasSynchronicity: Bool {
        !synchronicities.isEmpty
    }
    
    var primaryNumber: Int? {
        unifiedTheme.primaryNumber
    }
    
    var primaryElement: Element? {
        dailyEnergy.dominantElement
    }
    
    var intensityLevel: EnergyIntensity {
        dailyEnergy.intensity
    }
}

// MARK: - Unified Theme

struct UnifiedTheme {
    let title: String
    let subtitle: String
    let description: String
    let keywords: [String]
    let primaryNumber: Int?
    let primaryPlanet: Planet?
    let primaryElement: Element?
    let primaryTarot: TarotReference?
    let primarySephirah: Sephirah?
    let correspondences: [CompleteCorrespondence]
    
    /// Systems that converged on this theme
    let contributingSystems: [String]
    
    /// Strength of the unified theme (how many systems agree)
    let convergenceStrength: ConvergenceStrength
    
    enum ConvergenceStrength: String {
        case weak = "Emerging"
        case moderate = "Building"
        case strong = "Powerful"
        case master = "Transformational"
    }
}

// MARK: - System Daily Reading

struct SystemDailyReading {
    let systemName: String
    let theme: String
    let insight: String
    let detailLevel: DetailLevel
    let energyLevel: EnergyLevel
    let color: Color
    let symbol: String  // SF Symbol
    let numericalValue: Int?
    let advice: String
    let practice: String?
    
    enum DetailLevel: String {
        case brief = "Brief"
        case standard = "Standard"
        case detailed = "Detailed"
    }
    
    enum EnergyLevel: String {
        case low = "Subdued"
        case moderate = "Balanced"
        case high = "Active"
        case veryHigh = "Intense"
        
        var color: Color {
            switch self {
            case .low: return .blue
            case .moderate: return .green
            case .high: return .orange
            case .veryHigh: return .red
            }
        }
    }
}

// MARK: - Daily Energy

struct DailyEnergy {
    let overallQuality: VibrationalQuality
    let intensity: EnergyIntensity
    let dominantElement: Element
    let elementalBalance: ElementalBalance
    let primaryFrequency: Double
    let recommendedFrequency: SolfeggioFrequency?
    let sacredForm: SacredForm
    let polarity: Polarity
    let modality: Modality
    
    enum EnergyIntensity: String {
        case gentle = "Gentle"
        case moderate = "Moderate"
        case strong = "Strong"
        case intense = "Intense"
        
        var numericValue: Double {
            switch self {
            case .gentle: return 0.25
            case .moderate: return 0.5
            case .strong: return 0.75
            case .intense: return 1.0
            }
        }
    }
}

// MARK: - Synchronicity

struct Synchronicity: Identifiable {
    let id = UUID()
    let detectedAt: Date
    let type: SynchronicityType
    let systemsInvolved: [String]
    let description: String
    let explanation: String
    let significance: SignificanceLevel
    let actionRecommendation: String
    let relatedCorrespondences: [CompleteCorrespondence]
    
    enum SynchronicityType: String {
        case numberRepetition = "Number Pattern"
        case planetaryAlignment = "Planetary Alignment"
        case tarotConfirmation = "Card Confirmation"
        case elementConvergence = "Elemental Convergence"
        case frequencyMatch = "Frequency Match"
        case masterActivation = "Master Number"
        case birthdayPattern = "Birth Pattern"
        case transitTrigger = "Transit Trigger"
        case crossSystemEcho = "Cross-System Echo"
    }
    
    enum SignificanceLevel: String {
        case subtle = "Subtle"
        case noticeable = "Noticeable"
        case significant = "Significant"
        case profound = "Profound"
        
        var color: Color {
            switch self {
            case .subtle: return .gray
            case .noticeable: return .blue
            case .significant: return .purple
            case .profound: return .red
            }
        }
    }
}

// MARK: - Cross System Pattern

struct CrossSystemPattern {
    let patternType: PatternType
    let systems: [String]
    let sharedValue: String
    let description: String
    let interpretation: String
    
    enum PatternType: String {
        case numberAgreement = "Number Agreement"
        case elementHarmony = "Element Harmony"
        case planetaryResonance = "Planetary Resonance"
        case archetypeAlignment = "Archetype Alignment"
        case polarityBalance = "Polarity Balance"
    }
}

// MARK: - Action Items

struct ActionItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let system: String
    let priority: Priority
    let estimatedTime: TimeInterval?
    let isCompleted: Bool
    let relatedCorrespondence: CompleteCorrespondence?
    
    enum Priority: String {
        case optional = "Optional"
        case recommended = "Recommended"
        case important = "Important"
        case essential = "Essential"
        
        var color: Color {
            switch self {
            case .optional: return .gray
            case .recommended: return .blue
            case .important: return .orange
            case .essential: return .red
            }
        }
    }
}

// MARK: - Meditation Recommendation

struct MeditationRecommendation {
    let title: String
    let description: String
    let duration: TimeInterval
    let frequency: Double?
    let associatedSystems: [String]
    let guidance: String
    let visualization: String
    let breathingPattern: BreathingPattern?
    let affirmations: [String]
    let soundFile: String?  // Reference to audio resource
    
    struct BreathingPattern {
        let inhale: TimeInterval
        let hold: TimeInterval
        let exhale: TimeInterval
        let name: String
    }
}

// MARK: - Reading Generator

class UnifiedReadingGenerator {
    static let shared = UnifiedReadingGenerator()
    
    /// Generate a complete unified daily reading
    func generateReading(for blueprint: PersonalBlueprint, date: Date = Date()) async -> UnifiedDailyReading {
        
        // Generate individual system readings
        var systemReadings: [String: SystemDailyReading] = [:]
        
        for systemName in blueprint.activeSystems {
            if let system = EsotericSystemRegistry.shared.getSystem(named: systemName) {
                let content = system.getDailyContent(for: blueprint, date: date)
                systemReadings[systemName] = SystemDailyReading(from: content, systemName: systemName)
            }
        }
        
        // Detect synchronicities
        let synchronicities = await detectSynchronicities(for: blueprint, date: date, readings: systemReadings)
        
        // Find cross-system patterns
        let crossPatterns = findCrossPatterns(readings: systemReadings)
        
        // Synthesize unified theme
        let unifiedTheme = synthesizeTheme(from: systemReadings, patterns: crossPatterns)
        
        // Calculate daily energy
        let dailyEnergy = calculateDailyEnergy(from: blueprint, readings: systemReadings, date: date)
        
        // Generate action items
        let actionItems = generateActionItems(from: unifiedTheme, synchronicities: synchronicities)
        
        // Generate meditation
        let meditation = generateMeditation(from: unifiedTheme, energy: dailyEnergy)
        
        // Generate affirmation
        let affirmation = generateAffirmation(from: unifiedTheme)
        
        // Identify cautions and opportunities
        let (cautions, opportunities) = analyzeEnergeticClimate(readings: systemReadings, synchronicities: synchronicities)
        
        return UnifiedDailyReading(
            date: date,
            blueprintId: blueprint.id,
            generatedAt: Date(),
            systemReadings: systemReadings,
            unifiedTheme: unifiedTheme,
            synchronicities: synchronicities,
            crossPatterns: crossPatterns,
            dailyEnergy: dailyEnergy,
            actionItems: actionItems,
            meditation: meditation,
            affirmation: affirmation,
            cautions: cautions,
            opportunities: opportunities
        )
    }
    
    // MARK: - Private Generation Methods
    
    private func detectSynchronicities(
        for blueprint: PersonalBlueprint,
        date: Date,
        readings: [String: SystemDailyReading]
    ) async -> [Synchronicity] {
        var synchronicities: [Synchronicity] = []
        
        // Check for number patterns
        let userNumbers = [
            blueprint.numerologyProfile?.lifePath,
            blueprint.numerologyProfile?.expression,
            blueprint.numerologyProfile?.soulUrge
        ].compactMap { $0 }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        // Date matches user's numbers
        if userNumbers.contains(day) {
            let corr = CorrespondenceMatrix.shared.findByNumber(day)
            synchronicities.append(Synchronicity(
                detectedAt: Date(),
                type: .numberRepetition,
                systemsInvolved: ["Numerology", "Calendar"],
                description: "Today's date (\(day)) matches your core number",
                explanation: "When the calendar aligns with your personal numbers, your energy is amplified.",
                significance: .significant,
                actionRecommendation: "Pay special attention to opportunities that arise today—they carry extra resonance for your path.",
                relatedCorrespondences: corr.map { [$0] } ?? []
            ))
        }
        
        // Check for master number activation
        let masterNumbers = userNumbers.filter { [11, 22, 33].contains($0) }
        if !masterNumbers.isEmpty {
            synchronicities.append(Synchronicity(
                detectedAt: Date(),
                type: .masterActivation,
                systemsInvolved: ["Numerology"],
                description: "Master number \(masterNumbers.joined(separator: ", ")) is active in your chart",
                explanation: "Master numbers carry intensified spiritual vibration and require conscious channeling.",
                significance: .profound,
                actionRecommendation: "Practice mindfulness today. Your intuition is heightened.",
                relatedCorrespondences: masterNumbers.compactMap { CorrespondenceMatrix.shared.findByNumber($0) }
            ))
        }
        
        // Check for cross-system echoes (same number appears in multiple systems)
        var numberCounts: [Int: [String]] = [:]
        for (system, reading) in readings {
            if let num = reading.numericalValue {
                numberCounts[num, default: []].append(system)
            }
        }
        
        for (number, systems) in numberCounts where systems.count > 1 {
            let corr = CorrespondenceMatrix.shared.findByNumber(number)
            synchronicities.append(Synchronicity(
                detectedAt: Date(),
                type: .crossSystemEcho,
                systemsInvolved: systems,
                description: "Number \(number) appears across \(systems.joined(separator: ", "))",
                explanation: "When multiple systems highlight the same number, the universe is emphasizing this energy.",
                significance: systems.count >= 3 ? .profound : .significant,
                actionRecommendation: "Reflect on the \(corr?.theme ?? "meaning") of \(number) in your life right now.",
                relatedCorrespondences: corr.map { [$0] } ?? []
            ))
        }
        
        return synchronicities.sorted { $0.significance.rawValue > $1.significance.rawValue }
    }
    
    private func findCrossPatterns(readings: [String: SystemDailyReading]) -> [CrossSystemPattern] {
        var patterns: [CrossSystemPattern] = []
        
        // This would analyze readings for deeper patterns
        // Placeholder implementation
        
        return patterns
    }
    
    private func synthesizeTheme(
        from readings: [String: SystemDailyReading],
        patterns: [CrossSystemPattern]
    ) -> UnifiedTheme {
        
        // Extract numbers from readings
        let numbers = readings.values.compactMap { $0.numericalValue }
        let primaryNumber = numbers.mostCommon()
        
        // Get correspondence for primary number
        let correspondence = primaryNumber.flatMap { CorrespondenceMatrix.shared.findByNumber($0) }
        
        // Build theme
        let themeTitle: String
        let themeSubtitle: String
        
        if let num = primaryNumber, let corr = correspondence {
            themeTitle = "The Energy of \(num): \(corr.theme)"
            themeSubtitle = "\(corr.planetaryRuler.rawValue) • \(corr.element.rawValue) • \(corr.sephirah.name)"
        } else {
            themeTitle = "Harmonizing Multiple Energies"
            themeSubtitle = "Integration and Balance"
        }
        
        // Determine convergence strength
        let convergenceStrength: UnifiedTheme.ConvergenceStrength
        let uniqueNumbers = Set(numbers).count
        switch uniqueNumbers {
        case 1: convergenceStrength = .master
        case 2: convergenceStrength = .strong
        case 3: convergenceStrength = .moderate
        default: convergenceStrength = .weak
        }
        
        return UnifiedTheme(
            title: themeTitle,
            subtitle: themeSubtitle,
            description: correspondence.map { "Today resonates with the energy of \($0.number): \($0.theme). This brings themes of \($0.virtue)." } ?? "Multiple energies are present today. Stay flexible and open to diverse influences.",
            keywords: correspondence.map { [$0.element.rawValue, $0.virtue.split(separator: ",").first.map(String.init)].compactMap { $0 } } ?? ["balance", "integration"],
            primaryNumber: primaryNumber,
            primaryPlanet: correspondence?.planetaryRuler,
            primaryElement: correspondence?.element,
            primaryTarot: correspondence.map { TarotReference(cardName: "Major Arcana \($0.tarotMajor)", cardNumber: $0.tarotMajor, suit: nil, isReversed: false) },
            primarySephirah: correspondence?.sephirah,
            correspondences: correspondence.map { [$0] } ?? [],
            contributingSystems: Array(readings.keys),
            convergenceStrength: convergenceStrength
        )
    }
    
    private func calculateDailyEnergy(
        from blueprint: PersonalBlueprint,
        readings: [String: SystemDailyReading],
        date: Date
    ) -> DailyEnergy {
        
        // Calculate based on dominant energy in readings
        let dominantElement: Element
        if let blueprintElement = blueprint.elementalProfile.flatMap({ $0.dominant }) {
            dominantElement = blueprintElement
        } else {
            dominantElement = .quintessence
        }
        
        let quality = dominantElement.toVibrationalQuality()
        
        // Calculate intensity based on synchronicities
        let intensity: DailyEnergy.EnergyIntensity = .moderate
        
        // Get frequency from correspondence
        let primaryNum = readings.values.compactMap { $0.numericalValue }.first
        let frequency = primaryNum.flatMap { CorrespondenceMatrix.shared.findByNumber($0)?.solfeggioFrequency }
        
        return DailyEnergy(
            overallQuality: quality,
            intensity: intensity,
            dominantElement: dominantElement,
            elementalBalance: blueprint.elementalProfile.map {
                ElementalBalance(fire: $0.fire, water: $0.water, air: $0.air, earth: $0.earth, quintessence: 0.1)
            } ?? .balanced,
            primaryFrequency: frequency?.rawValue ?? 432,
            recommendedFrequency: frequency,
            sacredForm: primaryNum.flatMap { CorrespondenceMatrix.shared.findByNumber($0)?.sacredForm } ?? .circle,
            polarity: primaryNum.map { $0 % 2 == 0 ? .feminine : .masculine } ?? .neutral,
            modality: .fixed
        )
    }
    
    private func generateActionItems(
        from theme: UnifiedTheme,
        synchronicities: [Synchronicity]
    ) -> [ActionItem] {
        var items: [ActionItem] = []
        
        // Primary action based on theme
        if let number = theme.primaryNumber {
            let corr = CorrespondenceMatrix.shared.findByNumber(number)
            items.append(ActionItem(
                title: "Reflect on \(number)",
                description: "Spend 5 minutes contemplating what \(corr?.theme ?? "this number") means in your life right now.",
                system: "Numerology",
                priority: .recommended,
                estimatedTime: 300,
                isCompleted: false,
                relatedCorrespondence: corr
            ))
        }
        
        // Action for each synchronicity
        for sync in synchronicities where sync.significance != .subtle {
            items.append(ActionItem(
                title: "Acknowledge Synchronicity",
                description: sync.actionRecommendation,
                system: sync.systemsInvolved.first ?? "Unified",
                priority: sync.significance == .profound ? .important : .recommended,
                estimatedTime: 60,
                isCompleted: false,
                relatedCorrespondence: sync.relatedCorrespondences.first
            ))
        }
        
        // Element-based action
        if let element = theme.primaryElement {
            items.append(ActionItem(
                title: "Connect with \(element.rawValue)",
                description: elementAction(for: element),
                system: "Alchemy",
                priority: .optional,
                estimatedTime: 600,
                isCompleted: false,
                relatedCorrespondence: nil
            ))
        }
        
        return items
    }
    
    private func elementAction(for element: Element) -> String {
        switch element {
        case .fire:
            return "Light a candle, sit in sunlight, or do something that sparks your passion."
        case .water:
            return "Drink water mindfully, take a bath, or spend time near natural water."
        case .air:
            return "Practice deep breathing, open windows for fresh air, or journal your thoughts."
        case .earth:
            return "Walk barefoot on grass, hold a crystal, or eat grounding foods."
        case .quintessence:
            return "Meditate on unity, practice gratitude for all elements."
        case .void:
            return "Sit in silence, embrace the unknown, release attachments."
        }
    }
    
    private func generateMeditation(from theme: UnifiedTheme, energy: DailyEnergy) -> MeditationRecommendation? {
        guard let number = theme.primaryNumber else { return nil }
        
        let corr = CorrespondenceMatrix.shared.findByNumber(number)
        
        return MeditationRecommendation(
            title: "\(number) Energy Meditation",
            description: "Connect with the vibration of \(number) and \(corr?.theme ?? "your inner wisdom").",
            duration: 600, // 10 minutes
            frequency: energy.primaryFrequency,
            associatedSystems: theme.contributingSystems,
            guidance: "Sit comfortably. Breathe deeply. Visualize \(corr?.sacredForm.rawValue ?? "your center of light"). Feel the \(energy.dominantElement.rawValue) energy within you.",
            visualization: "Imagine \(theme.primarySephirah?.name ?? "your inner sanctuary") glowing with \(corr?.color.rawValue ?? "brilliant") light.",
            breathingPattern: MeditationRecommendation.BreathingPattern(
                inhale: 4,
                hold: 4,
                exhale: 4,
                name: "Box Breathing"
            ),
            affirmations: [
                "I align with the energy of \(number).",
                "I embrace \(corr?.theme ?? "my highest path").",
                "I am open to divine guidance."
            ],
            soundFile: corr?.solfeggioFrequency.rawValue.description
        )
    }
    
    private func generateAffirmation(from theme: UnifiedTheme) -> String {
        if let number = theme.primaryNumber, let corr = CorrespondenceMatrix.shared.findByNumber(number) {
            return "Today I embody \(number): \(corr.virtue.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? corr.theme)."
        }
        return "I am open to the wisdom of all energies flowing through me today."
    }
    
    private func analyzeEnergeticClimate(
        readings: [String: SystemDailyReading],
        synchronicities: [Synchronicity]
    ) -> (cautions: [String], opportunities: [String]) {
        var cautions: [String] = []
        var opportunities: [String] = []
        
        // Analyze for challenging aspects
        for reading in readings.values {
            if reading.energyLevel == .veryHigh {
                cautions.append("High energy in \(reading.systemName) - pace yourself")
            }
        }
        
        // Analyze for opportunities
        for sync in synchronicities {
            opportunities.append(sync.description)
        }
        
        if cautions.isEmpty {
            cautions.append("No major cautions today - flow with the energy")
        }
        
        if opportunities.isEmpty {
            opportunities.append("A day for steady progress on your path")
        }
        
        return (cautions, opportunities)
    }
}

// MARK: - Extensions

extension SystemDailyReading {
    init(from content: SystemDailyContent, systemName: String) {
        self.systemName = systemName
        self.theme = content.theme
        self.insight = content.detailedInsight
        self.detailLevel = .standard
        self.energyLevel = .moderate
        self.color = content.color
        self.symbol = content.keySymbol
        self.numericalValue = nil  // Would extract from content if available
        self.advice = content.actionSuggestion
        self.practice = content.meditationPrompt
    }
}

// MARK: - Reading Storage

/// Stores and retrieves daily readings
class DailyReadingStore {
    static let shared = DailyReadingStore()
    
    private var cache: [UUID: [Date: UnifiedDailyReading]] = [:]
    
    func store(_ reading: UnifiedDailyReading) {
        var userCache = cache[reading.blueprintId] ?? [:]
        userCache[reading.date.startOfDay] = reading
        cache[reading.blueprintId] = userCache
    }
    
    func getReading(for blueprintId: UUID, date: Date) -> UnifiedDailyReading? {
        return cache[blueprintId]?[date.startOfDay]
    }
    
    func hasReading(for blueprintId: UUID, date: Date) -> Bool {
        return cache[blueprintId]?[date.startOfDay] != nil
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
