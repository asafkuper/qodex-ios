//
//  FrequencySystem.swift
//  QodeX - Frequency Work Feature Module
//
//  Solfeggio frequencies, binaural beats, and sound healing.
//

import Foundation
import AVFoundation

// MARK: - Frequency System

final class FrequencySystem: EsotericSystem {
    // MARK: - EsotericSystem Protocol
    
    static var systemName: String { "Frequency Work" }
    static var systemIcon: String { "waveform" }
    static var systemDescription: String { "Sound healing, Solfeggio frequencies, and vibrational medicine" }
    static var originTradition: String { "Ancient Gregorian / Modern Sound Science" }
    static var onboardingDuration: Int { 10 }
    static var learningCurve: LearningCurve { .beginner }
    
    typealias CalculationResult = FrequencyProfile
    typealias Interpretation = FrequencyInterpretation
    typealias VisualizationData = FrequencyVisualization
    
    // MARK: - Audio Engine
    
    private let audioEngine: FrequencyAudioEngine
    
    init() {
        self.audioEngine = FrequencyAudioEngine()
    }
    
    // MARK: - EsotericSystem Methods
    
    func calculate(for blueprint: PersonalBlueprint) async throws -> FrequencyProfile {
        // Calculate personal frequencies from birth data
        let baseFrequency = calculateBaseFrequency(from: blueprint)
        
        // Determine optimal Solfeggio frequency
        let solfeggio = determineSolfeggioFrequency(from: blueprint)
        
        // Calculate chakra frequencies
        let chakraFrequencies = calculateChakraFrequencies(from: blueprint)
        
        // Generate binaural recommendations
        let binauralRecommendations = generateBinauralRecommendations(from: blueprint)
        
        return FrequencyProfile(
            baseFrequency: baseFrequency,
            solfeggioFrequency: solfeggio,
            chakraFrequencies: chakraFrequencies,
            binauralRecommendations: binauralRecommendations,
            planetaryFrequencies: calculatePlanetaryFrequencies(),
            elementalFrequencies: calculateElementalFrequencies()
        )
    }
    
    func interpret(_ result: FrequencyProfile, context: InterpretationContext) -> FrequencyInterpretation {
        return FrequencyInterpretation(
            primaryFrequency: result.solfeggioFrequency,
            meaning: getFrequencyMeaning(result.solfeggioFrequency),
            benefits: getFrequencyBenefits(result.solfeggioFrequency),
            recommendedUsage: getRecommendedUsage(result.solfeggioFrequency),
            contraindications: getContraindications(result.solfeggioFrequency)
        )
    }
    
    func generateVisualization(_ result: FrequencyProfile, style: VisualizationStyle) -> FrequencyVisualization {
        return FrequencyVisualization(
            primaryFrequency: result.solfeggioFrequency,
            waveform: generateWaveform(for: result.solfeggioFrequency),
            color: frequencyColor(result.solfeggioFrequency),
            animationStyle: .ripple
        )
    }
    
    func extractEnergySignature(from result: FrequencyProfile) -> EnergySignature {
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: result.solfeggioFrequency.rawValue,
            harmonicFrequencies: result.chakraFrequencies.values.map { $0 },
            vibrationalQuality: frequencyToQuality(result.solfeggioFrequency),
            elementalResonance: frequenciesToElements(result),
            coreNumbers: [:],
            masterResonance: [],
            karmicIndicators: [],
            sacredForms: [],
            geometricRatios: [],
            symmetryType: .radial,
            planetaryRulers: [],
            zodiacResonance: [],
            lunarPhase: nil,
            seasonalResonance: nil,
            sephiroticPath: [],
            hebrewLetter: nil,
            divineName: nil,
            tarotCorrespondences: [frequencyToTarot(result.solfeggioFrequency)],
            playingCardCorrespondences: [],
            alchemicalStage: nil,
            recommendedOperations: [],
            polarity: .neutral,
            modality: .fixed,
            direction: nil
        )
    }
    
    func getCorrespondences(_ signature: EnergySignature) -> [SystemCorrespondence] {
        return []
    }
    
    func getDailyContent(for blueprint: PersonalBlueprint, date: Date) -> SystemDailyContent {
        let profile = try? calculate(for: blueprint)
        let frequency = profile?.solfeggioFrequency ?? .mi
        
        return SystemDailyContent(
            systemName: Self.systemName,
            date: date,
            theme: "\(frequency.name) (\(Int(frequency.rawValue))Hz)",
            keySymbol: "waveform",
            briefInsight: frequency.shortDescription,
            detailedInsight: frequency.fullDescription,
            actionSuggestion: "Listen to \(Int(frequency.rawValue))Hz for 10 minutes today",
            meditationPrompt: "Close your eyes and let the frequency wash through you",
            color: frequencyColor(frequency),
            energyLevel: .moderate
        )
    }
    
    // MARK: - Audio Playback
    
    /// Play a Solfeggio frequency
    func playSolfeggio(_ frequency: SolfeggioFrequency, duration: TimeInterval = 600) async throws {
        try await audioEngine.playTone(frequency: frequency.rawValue, duration: duration)
    }
    
    /// Play binaural beats
    func playBinaural(carrier: Double, beat: Double, duration: TimeInterval = 600) async throws {
        try await audioEngine.playBinaural(carrier: carrier, beat: beat, duration: duration)
    }
    
    /// Generate frequency for a specific purpose
    func generateHealingSession(for purpose: HealingPurpose, duration: TimeInterval = 900) -> HealingSession {
        let (frequency, binauralBeat) = purpose.frequencies
        
        return HealingSession(
            title: purpose.title,
            description: purpose.description,
            primaryFrequency: frequency,
            binauralBeat: binauralBeat,
            duration: duration,
            affirmation: purpose.affirmation,
            visualization: purpose.visualization
        )
    }
    
    // MARK: - Calculations
    
    private func calculateBaseFrequency(from blueprint: PersonalBlueprint) -> Double {
        // Start with 432Hz (natural tuning)
        var base = 432.0
        
        // Adjust based on numerology
        if let lifePath = blueprint.numerologyProfile?.lifePath {
            let correspondence = CorrespondenceMatrix.shared.findByNumber(lifePath)
            if let freq = correspondence?.solfeggioFrequency {
                base = freq.rawValue
            }
        }
        
        return base
    }
    
    private func determineSolfeggioFrequency(from blueprint: PersonalBlueprint) -> SolfeggioFrequency {
        // Default to 528Hz (transformation)
        var frequency = SolfeggioFrequency.mi
        
        // Check current personal year
        if let personalYear = blueprint.numerologyProfile?.personalYear {
            switch personalYear {
            case 1, 5, 9: frequency = .ut      // Liberation
            case 2, 6: frequency = .re        // Change
            case 3, 7: frequency = .mi        // Transformation
            case 4, 8: frequency = .fa        // Relationships
            default: frequency = .sol         // Intuition
            }
        }
        
        return frequency
    }
    
    private func calculateChakraFrequencies(from blueprint: PersonalBlueprint) -> [Chakra: Double] {
        // Standard chakra frequencies with personal adjustments
        let base = calculateBaseFrequency(from: blueprint)
        let multiplier = base / 432.0 // Adjust from 432Hz baseline
        
        return [
            .root: 396 * multiplier,
            .sacral: 417 * multiplier,
            .solarPlexus: 528 * multiplier,
            .heart: 639 * multiplier,
            .throat: 741 * multiplier,
            .thirdEye: 852 * multiplier,
            .crown: 963 * multiplier
        ]
    }
    
    private func generateBinauralRecommendations(from blueprint: PersonalBlueprint) -> [BinauralRecommendation] {
        var recommendations: [BinauralRecommendation] = []
        
        // Based on numerology life path
        if let lifePath = blueprint.numerologyProfile?.lifePath {
            switch lifePath {
            case 1, 8:
                recommendations.append(BinauralRecommendation(
                    name: "Confidence & Power",
                    carrier: 200,
                    beat: 12, // Beta - focus
                    purpose: "Career success and leadership"
                ))
            case 2, 6:
                recommendations.append(BinauralRecommendation(
                    name: "Heart Opening",
                    carrier: 200,
                    beat: 6, // Theta - intuition
                    purpose: "Relationships and harmony"
                ))
            case 7, 9:
                recommendations.append(BinauralRecommendation(
                    name: "Deep Meditation",
                    carrier: 200,
                    beat: 4, // Theta - deep meditation
                    purpose: "Spiritual insight"
                ))
            default:
                recommendations.append(BinauralRecommendation(
                    name: "Balance & Flow",
                    carrier: 200,
                    beat: 8, // Alpha - relaxation
                    purpose: "General wellbeing"
                ))
            }
        }
        
        return recommendations
    }
    
    private func calculatePlanetaryFrequencies() -> [Planet: Double] {
        return [
            .sun: 126.22,
            .moon: 210.42,
            .mercury: 141.27,
            .venus: 221.23,
            .mars: 144.72,
            .jupiter: 183.58,
            .saturn: 147.85,
            .uranus: 207.36,
            .neptune: 211.44,
            .pluto: 140.25
        ]
    }
    
    private func calculateElementalFrequencies() -> [Element: Double] {
        return [
            .fire: 396,   // Liberation
            .water: 417,  // Change
            .air: 639,    // Connection
            .earth: 174,  // Foundation
            .quintessence: 963 // Divine
        ]
    }
    
    // MARK: - Interpretation Helpers
    
    private func getFrequencyMeaning(_ frequency: SolfeggioFrequency) -> String {
        switch frequency {
        case .ut: return "Liberating Guilt & Fear"
        case .re: return "Undoing Situations & Facilitating Change"
        case .mi: return "Transformation & DNA Repair"
        case .fa: return "Connecting & Relationships"
        case .sol: return "Awakening Intuition"
        case .la: return "Returning to Spiritual Order"
        case .si: return "Awakening Perfect State"
        }
    }
    
    private func getFrequencyBenefits(_ frequency: SolfeggioFrequency) -> [String] {
        switch frequency {
        case .ut:
            return ["Releases guilt and fear", "Grounds and stabilizes", "Supports root chakra"]
        case .re:
            return ["Facilitates change", "Cleanses traumatic experiences", "Supports sacral chakra"]
        case .mi:
            return ["Promotes DNA repair", "Brings miracles", "Supports solar plexus"]
        case .fa:
            return ["Heals relationships", "Promotes connection", "Supports heart chakra"]
        case .sol:
            return ["Awakens intuition", "Promotes problem-solving", "Supports throat chakra"]
        case .la:
            return ["Returns to spiritual order", "Enhances awareness", "Supports third eye"]
        case .si:
            return ["Awakens higher consciousness", "Connects to divine", "Supports crown chakra"]
        }
    }
    
    private func getRecommendedUsage(_ frequency: SolfeggioFrequency) -> String {
        return "Listen for 10-15 minutes daily, preferably with headphones. Best during meditation or quiet reflection."
    }
    
    private func getContraindications(_ frequency: SolfeggioFrequency) -> [String] {
        return ["Do not use while driving or operating machinery"]
    }
    
    private func frequencyToQuality(_ frequency: SolfeggioFrequency) -> VibrationalQuality {
        switch frequency {
        case .ut: return .grounding
        case .re: return .flowing
        case .mi: return .activating
        case .fa: return .integrating
        case .sol: return .clarifying
        case .la: return .integrating
        case .si: return .transcending
        }
    }
    
    private func frequenciesToElements(_ profile: FrequencyProfile) -> ElementalBalance {
        // Map frequencies to elemental balance
        let solfeggio = profile.solfeggioFrequency
        var balance = ElementalBalance.balanced
        
        switch solfeggio {
        case .ut:
            balance = ElementalBalance(fire: 0.1, water: 0.1, air: 0.1, earth: 0.5, quintessence: 0.2)
        case .re:
            balance = ElementalBalance(fire: 0.1, water: 0.5, air: 0.1, earth: 0.1, quintessence: 0.2)
        case .mi:
            balance = ElementalBalance(fire: 0.5, water: 0.1, air: 0.1, earth: 0.1, quintessence: 0.2)
        case .fa:
            balance = ElementalBalance(fire: 0.1, water: 0.1, air: 0.5, earth: 0.1, quintessence: 0.2)
        default:
            balance = ElementalBalance(fire: 0.2, water: 0.2, air: 0.2, earth: 0.2, quintessence: 0.2)
        }
        
        return balance
    }
    
    private func frequencyToTarot(_ frequency: SolfeggioFrequency) -> TarotReference {
        let mapping: [SolfeggioFrequency: Int] = [
            .ut: 21,  // World - completion
            .re: 13,  // Death - transformation
            .mi: 14,  // Temperance - balance
            .fa: 6,   // Lovers - connection
            .sol: 2,  // High Priestess - intuition
            .la: 9,   // Hermit - spiritual order
            .si: 0    // Fool - pure potential
        ]
        let num = mapping[frequency] ?? 0
        return TarotReference(cardName: "Major Arcana \(num)", cardNumber: num, suit: nil, isReversed: false)
    }
    
    private func frequencyColor(_ frequency: SolfeggioFrequency) -> Color {
        switch frequency {
        case .ut: return .red
        case .re: return .orange
        case .mi: return .yellow
        case .fa: return .green
        case .sol: return .blue
        case .la: return .indigo
        case .si: return .purple
        }
    }
    
    private func generateWaveform(for frequency: SolfeggioFrequency) -> WaveformType {
        return .sine
    }
}

// MARK: - Supporting Types

struct FrequencyProfile {
    let baseFrequency: Double
    let solfeggioFrequency: SolfeggioFrequency
    let chakraFrequencies: [Chakra: Double]
    let binauralRecommendations: [BinauralRecommendation]
    let planetaryFrequencies: [Planet: Double]
    let elementalFrequencies: [Element: Double]
}

struct FrequencyInterpretation {
    let primaryFrequency: SolfeggioFrequency
    let meaning: String
    let benefits: [String]
    let recommendedUsage: String
    let contraindications: [String]
}

struct FrequencyVisualization {
    let primaryFrequency: SolfeggioFrequency
    let waveform: WaveformType
    let color: Color
    let animationStyle: AnimationStyle
    
    enum AnimationStyle {
        case ripple
        case pulse
        case spiral
        case wave
    }
}

struct BinauralRecommendation {
    let name: String
    let carrier: Double
    let beat: Double
    let purpose: String
}

struct HealingSession {
    let title: String
    let description: String
    let primaryFrequency: Double
    let binauralBeat: Double?
    let duration: TimeInterval
    let affirmation: String
    let visualization: String
}

enum HealingPurpose {
    case sleep
    case focus
    case relaxation
    case energy
    case meditation
    case creativity
    
    var title: String {
        switch self {
        case .sleep: return "Deep Sleep"
        case .focus: return "Laser Focus"
        case .relaxation: return "Deep Relaxation"
        case .energy: return "Energy Boost"
        case .meditation: return "Meditation Support"
        case .creativity: return "Creative Flow"
        }
    }
    
    var description: String {
        switch self {
        case .sleep: return "Delta waves for deep restorative sleep"
        case .focus: return "Beta waves for concentration and alertness"
        case .relaxation: return "Alpha waves for calm and relaxation"
        case .energy: return "Gamma waves for peak performance"
        case .meditation: return "Theta waves for deep meditation"
        case .creativity: return "Theta-Alpha blend for creative insight"
        }
    }
    
    var frequencies: (Double, Double?) {
        switch self {
        case .sleep: return (174, 2.0)      // Delta
        case .focus: return (432, 15.0)     // Beta
        case .relaxation: return (432, 10.0) // Alpha
        case .energy: return (528, 40.0)    // Gamma
        case .meditation: return (417, 6.0) // Theta
        case .creativity: return (639, 8.0) // Alpha-Theta
        }
    }
    
    var affirmation: String {
        switch self {
        case .sleep: return "I release the day and embrace deep rest"
        case .focus: return "My mind is clear and my focus is sharp"
        case .relaxation: return "I am calm, centered, and at peace"
        case .energy: return "Vital energy flows through me"
        case .meditation: return "I am connected to infinite wisdom"
        case .creativity: return "Creative inspiration flows through me"
        }
    }
    
    var visualization: String {
        switch self {
        case .sleep: return "Imagine sinking into a soft, dark velvet"
        case .focus: return "Visualize a beam of white light from crown to earth"
        case .relaxation: return "See yourself floating on calm blue waters"
        case .energy: return "Picture golden sunlight filling every cell"
        case .meditation: return "Journey to your inner sanctuary of peace"
        case .creativity: return "Watch colors flowing and dancing freely"
        }
    }
}

enum Chakra: String, CaseIterable {
    case root = "Root"
    case sacral = "Sacral"
    case solarPlexus = "Solar Plexus"
    case heart = "Heart"
    case throat = "Throat"
    case thirdEye = "Third Eye"
    case crown = "Crown"
}

enum WaveformType {
    case sine
    case square
    case triangle
    case sawtooth
}

// MARK: - Audio Engine

class FrequencyAudioEngine {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    func playTone(frequency: Double, duration: TimeInterval) async throws {
        // Implementation would use AVAudioEngine to generate sine wave
        // This is a stub for the architecture
    }
    
    func playBinaural(carrier: Double, beat: Double, duration: TimeInterval) async throws {
        // Implementation would generate two tones with frequency difference
    }
    
    func stop() {
        playerNode?.stop()
        audioEngine?.stop()
    }
}
