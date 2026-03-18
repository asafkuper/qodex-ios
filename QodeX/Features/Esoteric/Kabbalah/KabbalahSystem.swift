//
//  KabbalahSystem.swift
//  QodeX - Kabbalah Feature Module
//
//  Tree of Life, Sephirot, Hebrew letter correspondences,
//  and pathworking meditations.
//

import Foundation
import SwiftUI

// MARK: - Kabbalah System

final class KabbalahSystem: EsotericSystem {
    static var systemName: String { "Kabbalah" }
    static var systemIcon: String { "tree.fill" }
    static var systemDescription: String { "Tree of Life wisdom, divine emanations, and Hebrew mysteries" }
    static var originTradition: String { "Medieval Jewish Mysticism" }
    static var onboardingDuration: Int { 25 }
    static var learningCurve: LearningCurve { .advanced }
    
    typealias CalculationResult = KabbalahProfile
    typealias Interpretation = KabbalahInterpretation
    typealias VisualizationData = TreeOfLifeVisualization
    
    private let treeOfLife: TreeOfLife
    
    init() {
        self.treeOfLife = TreeOfLife()
    }
    
    func calculate(for blueprint: PersonalBlueprint) async throws -> KabbalahProfile {
        // Calculate active Sephirot based on birth data
        let activeSephirot = calculateActiveSephirot(for: blueprint)
        
        // Find guardian angels
        let guardianAngels = findGuardianAngels(for: blueprint)
        
        // Calculate Hebrew name value if available
        let hebrewNameValue = blueprint.birthName.isEmpty ? nil : calculateHebrewValue(blueprint.birthName)
        
        // Get current path working
        let currentPath = calculateCurrentPath(for: blueprint)
        
        return KabbalahProfile(
            activeSephirot: activeSephirot,
            guardianAngels: guardianAngels,
            hebrewNameValue: hebrewNameValue,
            currentPathWorking: currentPath,
            personalTree: generatePersonalTree(for: blueprint)
        )
    }
    
    func interpret(_ result: KabbalahProfile, context: InterpretationContext) -> KabbalahInterpretation {
        return KabbalahInterpretation(
            sephirahFocus: result.activeSephirot.first?.sephirah.name ?? "Balance",
            divineName: result.activeSephirot.first?.sephirah.divineName ?? "Eheieh",
            meditationFocus: "Connect with \(result.guardianAngels.first?.rawValue ?? "your guides")",
            pathGuidance: result.currentPathWorking?.guidance ?? "Walk the middle path"
        )
    }
    
    func generateVisualization(_ result: KabbalahProfile, style: VisualizationStyle) -> TreeOfLifeVisualization {
        return TreeOfLifeVisualization(
            activeSephirot: result.activeSephirot.map { $0.sephirah },
            currentPath: result.currentPathWorking,
            animationStyle: .glow,
            depthLevel: style == .detailed ? .full : .simplified
        )
    }
    
    func extractEnergySignature(from result: KabbalahProfile) -> EnergySignature {
        guard let primarySephira = result.activeSephirot.first else {
            return .neutral
        }
        
        let correspondence = CorrespondenceMatrix.shared.findBySephirah(primarySephira.sephirah)
        
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: correspondence?.solfeggioFrequency.rawValue ?? 432,
            harmonicFrequencies: [],
            vibrationalQuality: primarySephira.sephirah.toVibrationalQuality(),
            elementalResonance: primarySephira.sephirah.toElementalBalance(),
            coreNumbers: [correspondence?.number ?? 1: NumericalArchetype(
                number: correspondence?.number ?? 1,
                archetypeName: primarySephira.sephirah.name,
                keywords: [primarySephira.sephirah.divineName],
                description: "Divine emanation on the Tree of Life",
                shadow: "",
                gift: "",
                weight: 1.0
            )],
            masterResonance: [],
            karmicIndicators: [],
            sacredForms: [.treeOfLife],
            geometricRatios: [],
            symmetryType: .radial,
            planetaryRulers: [PlanetaryInfluence(
                planet: correspondence?.planetaryRuler ?? .sun,
                influenceStrength: 1.0,
                aspect: nil,
                house: nil,
                isRetrograde: false,
                dignity: .domicile
            )],
            zodiacResonance: [],
            lunarPhase: nil,
            seasonalResonance: nil,
            sephiroticPath: result.activeSephirot,
            hebrewLetter: correspondence?.hebrewLetter,
            divineName: primarySephira.sephirah.divineName,
            tarotCorrespondences: [TarotReference(
                cardName: "Major Arcana \(correspondence?.tarotMajor ?? 0)",
                cardNumber: correspondence?.tarotMajor ?? 0,
                suit: nil,
                isReversed: false
            )],
            playingCardCorrespondences: [],
            alchemicalStage: correspondence?.alchemicalStage,
            recommendedOperations: [],
            polarity: primarySephira.sephirah.toPolarity(),
            modality: .fixed,
            direction: nil
        )
    }
    
    func getCorrespondences(_ signature: EnergySignature) -> [SystemCorrespondence] {
        return []
    }
    
    func getDailyContent(for blueprint: PersonalBlueprint, date: Date) -> SystemDailyContent {
        let profile = try? calculate(for: blueprint)
        let activeSephira = profile?.activeSephirot.first?.sephirah ?? .tiphareth
        
        return SystemDailyContent(
            systemName: Self.systemName,
            date: date,
            theme: activeSephira.name,
            keySymbol: "tree.fill",
            briefInsight: activeSephira.divineName,
            detailedInsight: "Connect with \(activeSephira.name), the Sephirah of \(activeSephira.virtue). Meditate on the Divine Name: \(activeSephira.divineName)",
            actionSuggestion: "Practice the virtue of \(activeSephira.virtue.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? "balance")",
            meditationPrompt: "Visualize the \(activeSephira.color.rawValue) light of \(activeSephira.name)",
            color: activeSephira.color.swiftUIColor,
            energyLevel: .high
        )
    }
    
    // MARK: - Calculations
    
    private func calculateActiveSephirot(for blueprint: PersonalBlueprint) -> [SephiricInfluence] {
        var active: [SephiricInfluence] = []
        
        // Based on numerology life path
        if let lifePath = blueprint.numerologyProfile?.lifePath {
            if let corr = CorrespondenceMatrix.shared.findByNumber(lifePath) {
                active.append(SephiricInfluence(
                    sephirah: corr.sephirah,
                    activationLevel: 1.0,
                    associatedPaths: []
                ))
            }
        }
        
        // Add complementary Sephirot
        if active.isEmpty {
            active.append(SephiricInfluence(sephirah: .tiphareth, activationLevel: 0.8, associatedPaths: []))
        }
        
        return active
    }
    
    private func findGuardianAngels(for blueprint: PersonalBlueprint) -> [Archangel] {
        var angels: [Archangel] = []
        
        if let profile = blueprint.numerologyProfile {
            if let corr = CorrespondenceMatrix.shared.findByNumber(profile.lifePath) {
                angels.append(corr.archangel)
            }
        }
        
        return angels.isEmpty ? [.metatron] : angels
    }
    
    private func calculateHebrewValue(_ name: String) -> Int {
        // Gematria calculation
        let hebrewMap: [Character: Int] = [
            "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9,
            "J": 10, "K": 20, "L": 30, "M": 40, "N": 50, "O": 60, "P": 70, "Q": 80, "R": 90,
            "S": 100, "T": 200, "U": 300, "V": 400, "W": 500, "X": 600, "Y": 700, "Z": 800
        ]
        
        return name.uppercased().reduce(0) { sum, char in
            sum + (hebrewMap[char] ?? 0)
        }
    }
    
    private func calculateCurrentPath(for blueprint: PersonalBlueprint) -> PathWorking? {
        // Determine current path based on age/personal year
        guard let age = Calendar.current.dateComponents([.year], from: blueprint.birthDate, to: Date()).year else {
            return nil
        }
        
        let pathNumber = (age % 22) + 1
        return treeOfLife.paths.first { $0.number == pathNumber }
    }
    
    private func generatePersonalTree(for blueprint: PersonalBlueprint) -> PersonalTreeOfLife {
        return PersonalTreeOfLife(
            activeSephirot: calculateActiveSephirot(for: blueprint).map { $0.sephirah },
            completedPaths: [],
            currentFocus: calculateActiveSephirot(for: blueprint).first?.sephirah
        )
    }
}

// MARK: - Supporting Types

struct KabbalahProfile {
    let activeSephirot: [SephiricInfluence]
    let guardianAngels: [Archangel]
    let hebrewNameValue: Int?
    let currentPathWorking: PathWorking?
    let personalTree: PersonalTreeOfLife
}

struct KabbalahInterpretation {
    let sephirahFocus: String
    let divineName: String
    let meditationFocus: String
    let pathGuidance: String
}

struct TreeOfLifeVisualization {
    let activeSephirot: [Sephirah]
    let currentPath: PathWorking?
    let animationStyle: AnimationStyle
    let depthLevel: DepthLevel
    
    enum AnimationStyle {
        case glow
        case pulse
        case flow
    }
    
    enum DepthLevel {
        case simplified
        case standard
        case full
    }
}

struct TreeOfLife {
    let sephirot: [Sephirah: SephirahData]
    let paths: [PathWorking]
    
    init() {
        self.sephirot = Self.createSephirotData()
        self.paths = Self.createPaths()
    }
    
    static func createSephirotData() -> [Sephirah: SephirahData] {
        var data: [Sephirah: SephirahData] = [:]
        
        data[.kether] = SephirahData(
            sephirah: .kether,
            divineName: "Eheieh",
            archangel: .metatron,
            color: .white,
            virtue: "Attainment",
            vice: "-"
        )
        
        data[.chokmah] = SephirahData(
            sephirah: .chokmah,
            divineName: "Yah",
            archangel: .raziel,
            color: .silver,
            virtue: "Wisdom",
            vice: "-"
        )
        
        data[.daath] = SephirahData(
            sephirah: .daath,
            divineName: "YHVH Elohim",
            archangel: .uriel,
            color: .lavender,
            virtue: "Knowledge",
            vice: "Ignorance"
        )
        
        data[.binah] = SephirahData(
            sephirah: .binah,
            divineName: "YHVH Elohim",
            archangel: .tzaphkiel,
            color: .black,
            virtue: "Understanding",
            vice: "-"
        )
        
        data[.chesed] = SephirahData(
            sephirah: .chesed,
            divineName: "El",
            archangel: .tzadkiel,
            color: .blue,
            virtue: "Mercy",
            vice: "Bigotry"
        )
        
        data[.geburah] = SephirahData(
            sephirah: .geburah,
            divineName: "Elohim Gibor",
            archangel: .khamael,
            color: .red,
            virtue: "Energy",
            vice: "Cruelty"
        )
        
        data[.tiphareth] = SephirahData(
            sephirah: .tiphareth,
            divineName: "YHVH Eloah ve-Da'at",
            archangel: .raphael,
            color: .yellow,
            virtue: "Devotion",
            vice: "Pride"
        )
        
        data[.netzach] = SephirahData(
            sephirah: .netzach,
            divineName: "YHVH Tzaba'oth",
            archangel: .haniel,
            color: .green,
            virtue: "Unselfishness",
            vice: "Lust"
        )
        
        data[.hod] = SephirahData(
            sephirah: .hod,
            divineName: "Elohim Tzaba'oth",
            archangel: .michael,
            color: .orange,
            virtue: "Truth",
            vice: "Falsehood"
        )
        
        data[.yesod] = SephirahData(
            sephirah: .yesod,
            divineName: "Shaddai El Chai",
            archangel: .gabriel,
            color: .violet,
            virtue: "Independence",
            vice: "Idleness"
        )
        
        data[.malkuth] = SephirahData(
            sephirah: .malkuth,
            divineName: "Adonai ha-Aretz",
            archangel: .sandalphon,
            color: .brown,
            virtue: "Discrimination",
            vice: "Greed"
        )
        
        return data
    }
    
    static func createPaths() -> [PathWorking] {
        // The 22 paths of the Tree of Life
        var paths: [PathWorking] = []
        
        // Path 11: Kether - Chokmah (Aleph)
        paths.append(PathWorking(
            number: 11,
            from: .kether,
            to: .chokmah,
            hebrewLetter: .aleph,
            tarotCard: 0, // Fool
            meaning: "The breath of spirit entering wisdom"
        ))
        
        // Path 12: Kether - Binah (Beth)
        paths.append(PathWorking(
            number: 12,
            from: .kether,
            to: .binah,
            hebrewLetter: .beth,
            tarotCard: 1, // Magician
            meaning: "The house of understanding"
        ))
        
        // Additional paths would be defined here...
        
        return paths
    }
}

struct SephirahData {
    let sephirah: Sephirah
    let divineName: String
    let archangel: Archangel
    let color: EsotericColor
    let virtue: String
    let vice: String
}

struct PathWorking {
    let number: Int
    let from: Sephirah
    let to: Sephirah
    let hebrewLetter: HebrewLetter
    let tarotCard: Int
    let meaning: String
    
    var guidance: String {
        return "Journey from \(from.name) to \(to.name) through the path of \(hebrewLetter.rawValue)"
    }
}

struct PersonalTreeOfLife {
    let activeSephirot: [Sephirah]
    let completedPaths: [Int]
    let currentFocus: Sephirah?
}

// MARK: - Extensions

extension Sephirah {
    func toVibrationalQuality() -> VibrationalQuality {
        switch self {
        case .kether, .chokmah, .binah: return .transcending
        case .chesed, .tiphareth: return .integrating
        case .geburah: return .activating
        case .netzach: return .flowing
        case .hod: return .clarifying
        case .yesod, .malkuth: return .grounding
        case .daath: return .transcending
        }
    }
    
    func toElementalBalance() -> ElementalBalance {
        switch self {
        case .kether: return ElementalBalance(fire: 0.25, water: 0.25, air: 0.25, earth: 0.25, quintessence: 0.5)
        case .chokmah: return ElementalBalance(fire: 0.2, water: 0.1, air: 0.5, earth: 0.1, quintessence: 0.1)
        case .binah: return ElementalBalance(fire: 0.1, water: 0.5, air: 0.1, earth: 0.2, quintessence: 0.1)
        case .chesed: return ElementalBalance(fire: 0.1, water: 0.3, air: 0.2, earth: 0.3, quintessence: 0.1)
        case .geburah: return ElementalBalance(fire: 0.5, water: 0.1, air: 0.2, earth: 0.1, quintessence: 0.1)
        case .tiphareth: return ElementalBalance(fire: 0.25, water: 0.25, air: 0.25, earth: 0.25, quintessence: 0.3)
        case .netzach: return ElementalBalance(fire: 0.2, water: 0.4, air: 0.1, earth: 0.2, quintessence: 0.1)
        case .hod: return ElementalBalance(fire: 0.1, water: 0.1, air: 0.5, earth: 0.2, quintessence: 0.1)
        case .yesod: return ElementalBalance(fire: 0.1, water: 0.3, air: 0.1, earth: 0.4, quintessence: 0.1)
        case .malkuth: return ElementalBalance(fire: 0.1, water: 0.2, air: 0.2, earth: 0.5, quintessence: 0.1)
        case .daath: return ElementalBalance(fire: 0.2, water: 0.2, air: 0.2, earth: 0.2, quintessence: 0.5)
        }
    }
    
    func toPolarity() -> Polarity {
        switch self {
        case .chokmah, .chesed, .netzach: return .masculine
        case .binah, .geburah, .hod: return .feminine
        default: return .neutral
        }
    }
}
