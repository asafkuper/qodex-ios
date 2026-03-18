//
//  PersonalBlueprint.swift
//  QodeX - Unified Esoteric Framework
//
//  The user's complete esoteric profile across all systems.
//  This is the central identity in the QodeX ecosystem.
//

import Foundation
import SwiftData

// MARK: - Personal Blueprint

/// The master model containing a user's complete esoteric profile.
/// This is the "soul fingerprint" that all systems reference.
@Model
final class PersonalBlueprint {
    // MARK: - Identity
    
    @Attribute(.unique) var id: UUID
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    var version: Int  // For data migrations
    
    // MARK: - Birth Data (Foundation)
    
    var birthDate: Date
    var birthLocation: GeoLocation?
    var birthName: String  // Name at birth
    var currentName: String?  // Current name (if different)
    
    // MARK: - System Profiles
    
    var numerologyProfile: NumerologyProfile?
    var astrologyProfile: AstrologyProfile?
    var kabbalahProfile: KabbalahProfile?
    var tarotProfile: TarotProfile?
    var playingCardProfile: PlayingCardProfile?
    var elementalProfile: ElementalProfile?
    var frequencyProfile: FrequencyProfile?
    var sacredGeometryProfile: SacredGeometryProfile?
    
    // MARK: - System Settings
    
    /// Which systems the user has unlocked
    var unlockedSystems: [String]
    
    /// Which systems are currently active/enabled
    var activeSystems: [String]
    
    /// User's learning progress for each system (system name: 0.0-1.0)
    var learningProgress: [String: Double]
    
    /// User's proficiency level for each system
    var proficiencyLevels: [String: String]  // System name: ProficiencyLevel raw value
    
    // MARK: - Preferences
    
    var preferredInterpretationLevel: String  // InterpretationContext.DetailLevel
    var preferredVisualizationStyle: String   // VisualizationStyle
    var primaryFocus: String?  // love, career, spiritual, health
    
    // MARK: - Derived Cache (recomputed when birth data changes)
    
    var dominantEnergyCache: EnergySignature?
    var lifeThemeCache: String?
    var currentCycleCache: LifeCycle?
    var lastCacheUpdate: Date?
    
    // MARK: - Initialization
    
    init(
        userId: String,
        birthDate: Date,
        birthName: String,
        birthLocation: GeoLocation? = nil,
        currentName: String? = nil
    ) {
        self.id = UUID()
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.version = 1
        
        self.birthDate = birthDate
        self.birthLocation = birthLocation
        self.birthName = birthName
        self.currentName = currentName
        
        // Start with numerology unlocked (existing system)
        self.unlockedSystems = ["Numerology"]
        self.activeSystems = ["Numerology"]
        
        self.learningProgress = ["Numerology": 0.0]
        self.proficiencyLevels = [:]
        
        self.preferredInterpretationLevel = "standard"
        self.preferredVisualizationStyle = "standard"
        
        // Calculate initial profiles
        self.regenerateProfiles()
    }
    
    // MARK: - Profile Management
    
    /// Regenerate all profiles from birth data
    func regenerateProfiles() {
        // Numerology (always available)
        self.numerologyProfile = NumerologyProfile(from: self)
        
        // Only regenerate if unlocked
        if unlockedSystems.contains("Astrology") {
            self.astrologyProfile = AstrologyProfile(from: self)
        }
        
        if unlockedSystems.contains("Kabbalah") {
            self.kabbalahProfile = KabbalahProfile(from: self)
        }
        
        if unlockedSystems.contains("Tarot") {
            self.tarotProfile = TarotProfile(from: self)
        }
        
        if unlockedSystems.contains("PlayingCards") {
            self.playingCardProfile = PlayingCardProfile(from: self)
        }
        
        // Always regenerate derived profiles
        self.elementalProfile = ElementalProfile(from: self)
        self.frequencyProfile = FrequencyProfile(from: self)
        self.sacredGeometryProfile = SacredGeometryProfile(from: self)
        
        // Update cache
        self.updateDerivedCache()
        
        self.updatedAt = Date()
    }
    
    /// Update cached derived values
    private func updateDerivedCache() {
        self.dominantEnergyCache = calculateDominantEnergy()
        self.lifeThemeCache = deriveLifeTheme()
        self.currentCycleCache = calculateCurrentCycle()
        self.lastCacheUpdate = Date()
    }
    
    // MARK: - System Unlocking
    
    func unlockSystem(_ systemName: String) {
        guard !unlockedSystems.contains(systemName) else { return }
        
        unlockedSystems.append(systemName)
        learningProgress[systemName] = 0.0
        
        // Auto-activate
        activateSystem(systemName)
        
        // Regenerate affected profiles
        regenerateProfiles()
    }
    
    func activateSystem(_ systemName: String) {
        guard unlockedSystems.contains(systemName),
              !activeSystems.contains(systemName) else { return }
        
        activeSystems.append(systemName)
        updatedAt = Date()
    }
    
    func deactivateSystem(_ systemName: String) {
        activeSystems.removeAll { $0 == systemName }
        updatedAt = Date()
    }
    
    // MARK: - Learning Progress
    
    func updateProgress(for system: String, progress: Double) {
        learningProgress[system] = min(max(progress, 0.0), 1.0)
        
        // Update proficiency level based on progress
        let level: ProficiencyLevel
        switch progress {
        case 0.0..<0.25: level = .novice
        case 0.25..<0.5: level = .apprentice
        case 0.5..<0.75: level = .adept
        default: level = .master
        }
        
        proficiencyLevels[system] = level.rawValue
        updatedAt = Date()
    }
    
    // MARK: - Energy Calculations
    
    /// Calculate the user's dominant energy signature
    func calculateDominantEnergy() -> EnergySignature {
        var signatures: [EnergySignature] = []
        
        if let num = numerologyProfile {
            signatures.append(num.toEnergySignature())
        }
        
        if let astro = astrologyProfile {
            signatures.append(astro.toEnergySignature())
        }
        
        if let tarot = tarotProfile {
            signatures.append(tarot.toEnergySignature())
        }
        
        if let elemental = elementalProfile {
            signatures.append(elemental.toEnergySignature())
        }
        
        return EnergySignature.synthesize(signatures)
    }
    
    /// Derive the user's life theme
    func deriveLifeTheme() -> String {
        guard let num = numerologyProfile else {
            return "Discovering Your Path"
        }
        
        let lifePath = num.lifePath
        let lifePathThemes: [Int: String] = [
            1: "The Pioneer - Creating New Paths",
            2: "The Diplomat - Building Bridges",
            3: "The Creator - Expressing Beauty",
            4: "The Builder - Establishing Order",
            5: "The Explorer - Embracing Change",
            6: "The Nurturer - Harmonizing Love",
            7: "The Seeker - Unveiling Truth",
            8: "The Leader - Manifesting Power",
            9: "The Humanitarian - Serving All",
            11: "The Illuminator - Awakening Others",
            22: "The Master Builder - Shaping Reality",
            33: "The Master Teacher - Healing Hearts"
        ]
        
        return lifePathThemes[lifePath] ?? "The Journey of Self-Discovery"
    }
    
    /// Calculate current life cycle
    func calculateCurrentCycle() -> LifeCycle {
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        
        // First pinnacle: 0-35
        // Second: 36-44
        // Third: 45-53
        // Fourth: 54+
        let cycleNumber: Int
        let cycleName: String
        
        switch age {
        case 0...35:
            cycleNumber = 1
            cycleName = "Foundation Building"
        case 36...44:
            cycleNumber = 2
            cycleName = "Personal Expression"
        case 45...53:
            cycleNumber = 3
            cycleName = "Wisdom Integration"
        default:
            cycleNumber = 4
            cycleName = "Legacy and Service"
        }
        
        // Personal year calculation
        let currentYear = Calendar.current.component(.year, from: Date())
        let birthMonth = Calendar.current.component(.month, from: birthDate)
        let birthDay = Calendar.current.component(.day, from: birthDate)
        
        var personalYearNumber = birthMonth + birthDay + currentYear
        while personalYearNumber > 9 {
            if personalYearNumber == 11 || personalYearNumber == 22 || personalYearNumber == 33 {
                break
            }
            var sum = 0
            var n = personalYearNumber
            while n > 0 {
                sum += n % 10
                n /= 10
            }
            personalYearNumber = sum
        }
        
        return LifeCycle(
            age: age,
            pinnacleNumber: cycleNumber,
            pinnacleName: cycleName,
            personalYear: personalYearNumber,
            universalYear: currentYear,
            theme: deriveYearTheme(personalYear: personalYearNumber)
        )
    }
    
    private func deriveYearTheme(personalYear: Int) -> String {
        let themes: [Int: String] = [
            1: "New Beginnings - Plant Seeds",
            2: "Cooperation - Build Partnerships",
            3: "Creativity - Express Yourself",
            4: "Foundation - Work Diligently",
            5: "Change - Embrace Freedom",
            6: "Responsibility - Focus on Home",
            7: "Reflection - Study and Grow",
            8: "Achievement - Reap Rewards",
            9: "Completion - Release and Serve",
            11: "Illumination - Trust Intuition",
            22: "Building - Think Big"
        ]
        return themes[personalYear] ?? "Growth and Discovery"
    }
    
    // MARK: - Daily Insights
    
    /// Generate daily personalized content
    func generateDailyContent(for date: Date = Date()) -> DailyPersonalContent {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        // Check for synchronicities
        let syncPatterns = CorrespondenceMatrix.shared.detectSynchronicities(in: self, date: date)
        
        // Get active system content
        var systemContents: [SystemDailyContent] = []
        for systemName in activeSystems {
            if let system = EsotericSystemRegistry.shared.getSystem(named: systemName) {
                systemContents.append(system.getDailyContent(for: self, date: date))
            }
        }
        
        // Synthesize into unified theme
        let unifiedTheme = synthesizeDailyTheme(systemContents, syncPatterns: syncPatterns)
        
        return DailyPersonalContent(
            date: date,
            blueprintId: id,
            unifiedTheme: unifiedTheme,
            systemContents: systemContents,
            synchronicities: syncPatterns,
            dominantEnergy: dominantEnergyCache ?? calculateDominantEnergy(),
            recommendedAction: generateDailyAction(syncPatterns: syncPatterns),
            meditation: generateDailyMeditation(theme: unifiedTheme)
        )
    }
    
    private func synthesizeDailyTheme(_ contents: [SystemDailyContent], syncPatterns: [SynchronicityPattern]) -> String {
        // Find common themes across systems
        let allThemes = contents.map { $0.theme }
        
        // If synchronicities exist, highlight them
        if let firstSync = syncPatterns.first {
            return "\(firstSync.description) - Themes: \(allThemes.joined(separator: ", "))"
        }
        
        return allThemes.joined(separator: " + ")
    }
    
    private func generateDailyAction(syncPatterns: [SynchronicityPattern]) -> String {
        if let pattern = syncPatterns.first {
            return "Pay attention to \(pattern.description.lowercased())"
        }
        
        return "Stay open to today's energies"
    }
    
    private func generateDailyMeditation(theme: String) -> String? {
        // Generate meditation based on theme and dominant energy
        guard let energy = dominantEnergyCache else { return nil }
        
        return "Focus on \(energy.vibrationalQuality.rawValue) energy. Visualize \(energy.sacredForms.first?.rawValue ?? "your inner light"). Breathe in the frequency of \(Int(energy.primaryFrequency))Hz."
    }
}

// MARK: - Supporting Types

struct GeoLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let locationName: String?
}

enum ProficiencyLevel: String, CaseIterable {
    case novice = "Novice"
    case apprentice = "Apprentice"
    case adept = "Adept"
    case master = "Master"
}

struct LifeCycle {
    let age: Int
    let pinnacleNumber: Int
    let pinnacleName: String
    let personalYear: Int
    let universalYear: Int
    let theme: String
    
    var description: String {
        return "Age \(age) - \(pinnacleName) (Pinnacle \(pinnacleNumber)) - Personal Year: \(personalYear) - \(theme)"
    }
}

struct DailyPersonalContent {
    let date: Date
    let blueprintId: UUID
    let unifiedTheme: String
    let systemContents: [SystemDailyContent]
    let synchronicities: [SynchronicityPattern]
    let dominantEnergy: EnergySignature
    let recommendedAction: String
    let meditation: String?
    
    var hasSynchronicity: Bool {
        !synchronicities.isEmpty
    }
}

// MARK: - Profile Protocols

protocol EsotericProfile {
    init(from blueprint: PersonalBlueprint)
    func toEnergySignature() -> EnergySignature
}

// MARK: - Numerology Profile

struct NumerologyProfile: Codable, EsotericProfile {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let birthday: Int
    let maturity: Int
    let personalYear: Int
    let personalMonth: Int
    let personalDay: Int
    let challenges: [Int]
    let pinnacles: [PinnacleData]
    
    struct PinnacleData: Codable {
        let number: Int
        let ageStart: Int
        let ageEnd: Int?
    }
    
    init(from blueprint: PersonalBlueprint) {
        let engine = NumerologyEngine()
        let chart = engine.calculateFullChart(
            birthDate: blueprint.birthDate,
            fullName: blueprint.birthName
        )
        
        self.lifePath = chart.lifePath
        self.expression = chart.expression
        self.soulUrge = chart.soulUrge
        self.personality = chart.personality
        self.birthday = chart.birthday
        self.maturity = chart.maturity
        self.personalYear = chart.personalYear
        self.personalMonth = chart.personalMonth
        self.personalDay = chart.personalDay
        self.challenges = chart.challenges
        self.pinnacles = chart.pinnacles.map {
            PinnacleData(number: $0.number, ageStart: $0.ageStart, ageEnd: $0.ageEnd)
        }
    }
    
    func toEnergySignature() -> EnergySignature {
        let correspondence = CorrespondenceMatrix.shared.findByNumber(lifePath)
        
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: correspondence?.solfeggioFrequency.rawValue ?? 432,
            harmonicFrequencies: [],
            vibrationalQuality: correspondence.map { $0.element.toVibrationalQuality() } ?? .integrating,
            elementalResonance: ElementalBalance(
                fire: correspondence?.element == .fire ? 0.5 : 0.1,
                water: correspondence?.element == .water ? 0.5 : 0.1,
                air: correspondence?.element == .air ? 0.5 : 0.1,
                earth: correspondence?.element == .earth ? 0.5 : 0.1,
                quintessence: 0.1
            ),
            coreNumbers: [
                lifePath: NumericalArchetype(
                    number: lifePath,
                    archetypeName: "Life Path",
                    keywords: ["purpose", "journey"],
                    description: "Your life's primary lesson",
                    shadow: "",
                    gift: "",
                    weight: 1.0
                ),
                expression: NumericalArchetype(
                    number: expression,
                    archetypeName: "Expression",
                    keywords: ["talents", "abilities"],
                    description: "How you express in the world",
                    shadow: "",
                    gift: "",
                    weight: 0.8
                ),
                soulUrge: NumericalArchetype(
                    number: soulUrge,
                    archetypeName: "Soul Urge",
                    keywords: ["desires", "motivations"],
                    description: "What your heart truly wants",
                    shadow: "",
                    gift: "",
                    weight: 0.8
                )
            ],
            masterResonance: [lifePath, expression, soulUrge].filter { [11, 22, 33].contains($0) },
            karmicIndicators: [],
            sacredForms: [correspondence?.sacredForm ?? .circle].compactMap { $0 },
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
            sephiroticPath: [SephiricInfluence(
                sephirah: correspondence?.sephirah ?? .malkuth,
                activationLevel: 1.0,
                associatedPaths: []
            )],
            hebrewLetter: correspondence?.hebrewLetter,
            divineName: correspondence?.sephirah.divineName,
            tarotCorrespondences: [TarotReference(
                cardName: "Major Arcana \(correspondence?.tarotMajor ?? 0)",
                cardNumber: correspondence?.tarotMajor ?? 0,
                suit: nil,
                isReversed: false
            )],
            playingCardCorrespondences: [],
            alchemicalStage: correspondence?.alchemicalStage,
            recommendedOperations: [],
            polarity: lifePath % 2 == 0 ? .feminine : .masculine,
            modality: .fixed,
            direction: nil
        )
    }
}

// MARK: - Placeholder Profile Types

struct AstrologyProfile: Codable, EsotericProfile {
    init(from blueprint: PersonalBlueprint) {
        // Placeholder - requires ephemeris calculation
    }
    
    func toEnergySignature() -> EnergySignature {
        return .neutral
    }
}

struct KabbalahProfile: Codable, EsotericProfile {
    init(from blueprint: PersonalBlueprint) {
        // Placeholder
    }
    
    func toEnergySignature() -> EnergySignature {
        return .neutral
    }
}

struct TarotProfile: Codable, EsotericProfile {
    init(from blueprint: PersonalBlueprint) {
        // Placeholder
    }
    
    func toEnergySignature() -> EnergySignature {
        return .neutral
    }
}

struct PlayingCardProfile: Codable, EsotericProfile {
    init(from blueprint: PersonalBlueprint) {
        // Placeholder
    }
    
    func toEnergySignature() -> EnergySignature {
        return .neutral
    }
}

struct ElementalProfile: Codable, EsotericProfile {
    let fire: Double
    let water: Double
    let air: Double
    let earth: Double
    
    init(from blueprint: PersonalBlueprint) {
        // Calculate from numerology and other available data
        if let num = blueprint.numerologyProfile {
            let correspondence = CorrespondenceMatrix.shared.findByNumber(num.lifePath)
            let dominant = correspondence?.element ?? .quintessence
            
            self.fire = dominant == .fire ? 0.4 : 0.15
            self.water = dominant == .water ? 0.4 : 0.15
            self.air = dominant == .air ? 0.4 : 0.15
            self.earth = dominant == .earth ? 0.4 : 0.15
        } else {
            self.fire = 0.25
            self.water = 0.25
            self.air = 0.25
            self.earth = 0.25
        }
    }
    
    func toEnergySignature() -> EnergySignature {
        let dominant: Element
        let maxVal = max(fire, water, air, earth)
        if fire == maxVal { dominant = .fire }
        else if water == maxVal { dominant = .water }
        else if air == maxVal { dominant = .air }
        else { dominant = .earth }
        
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: 432,
            harmonicFrequencies: [],
            vibrationalQuality: dominant.toVibrationalQuality(),
            elementalResonance: ElementalBalance(fire: fire, water: water, air: air, earth: earth, quintessence: 0.1),
            coreNumbers: [:],
            masterResonance: [],
            karmicIndicators: [],
            sacredForms: [dominant.toSacredForm()],
            geometricRatios: [],
            symmetryType: .radial,
            planetaryRulers: [],
            zodiacResonance: [],
            lunarPhase: nil,
            seasonalResonance: nil,
            sephiroticPath: [],
            hebrewLetter: nil,
            divineName: nil,
            tarotCorrespondences: [],
            playingCardCorrespondences: [],
            alchemicalStage: nil,
            recommendedOperations: [],
            polarity: .neutral,
            modality: .fixed,
            direction: nil
        )
    }
}

struct FrequencyProfile: Codable, EsotericProfile {
    let baseFrequency: Double
    let harmonics: [Double]
    
    init(from blueprint: PersonalBlueprint) {
        if let num = blueprint.numerologyProfile {
            let correspondence = CorrespondenceMatrix.shared.findByNumber(num.lifePath)
            self.baseFrequency = correspondence?.solfeggioFrequency.rawValue ?? 432
        } else {
            self.baseFrequency = 432
        }
        self.harmonics = [baseFrequency * 2, baseFrequency * 3, baseFrequency / 2]
    }
    
    func toEnergySignature() -> EnergySignature {
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: baseFrequency,
            harmonicFrequencies: harmonics,
            vibrationalQuality: .integrating,
            elementalResonance: .balanced,
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
            tarotCorrespondences: [],
            playingCardCorrespondences: [],
            alchemicalStage: nil,
            recommendedOperations: [],
            polarity: .neutral,
            modality: .fixed,
            direction: nil
        )
    }
}

struct SacredGeometryProfile: Codable, EsotericProfile {
    let primaryForm: SacredForm
    let secondaryForms: [SacredForm]
    
    init(from blueprint: PersonalBlueprint) {
        if let num = blueprint.numerologyProfile {
            let correspondence = CorrespondenceMatrix.shared.findByNumber(num.lifePath)
            self.primaryForm = correspondence?.sacredForm ?? .circle
        } else {
            self.primaryForm = .circle
        }
        self.secondaryForms = [.flowerOfLife, .treeOfLife]
    }
    
    func toEnergySignature() -> EnergySignature {
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: 432,
            harmonicFrequencies: [],
            vibrationalQuality: primaryForm.toVibrationalQuality(),
            elementalResonance: .balanced,
            coreNumbers: [:],
            masterResonance: [],
            karmicIndicators: [],
            sacredForms: [primaryForm] + secondaryForms,
            geometricRatios: [1.618, 1.414, 1.732],
            symmetryType: primaryForm.toSymmetryType(),
            planetaryRulers: [],
            zodiacResonance: [],
            lunarPhase: nil,
            seasonalResonance: nil,
            sephiroticPath: [],
            hebrewLetter: nil,
            divineName: nil,
            tarotCorrespondences: [],
            playingCardCorrespondences: [],
            alchemicalStage: nil,
            recommendedOperations: [],
            polarity: .neutral,
            modality: .fixed,
            direction: nil
        )
    }
}

// MARK: - Extensions

extension Element {
    func toVibrationalQuality() -> VibrationalQuality {
        switch self {
        case .fire: return .activating
        case .water: return .flowing
        case .air: return .clarifying
        case .earth: return .grounding
        case .quintessence: return .integrating
        case .void: return .transcending
        }
    }
    
    func toSacredForm() -> SacredForm {
        switch self {
        case .fire: return .tetrahedron
        case .water: return .icosahedron
        case .air: return .octahedron
        case .earth: return .cube
        case .quintessence: return .dodecahedron
        case .void: return .merkaba
        }
    }
}

extension SacredForm {
    func toVibrationalQuality() -> VibrationalQuality {
        switch self {
        case .tetrahedron: return .activating
        case .icosahedron: return .flowing
        case .octahedron: return .clarifying
        case .cube: return .grounding
        case .dodecahedron: return .integrating
        case .merkaba: return .transcending
        default: return .integrating
        }
    }
    
    func toSymmetryType() -> SymmetryType {
        switch self {
        case .circle, .flowerOfLife, .treeOfLife:
            return .radial
        case .triangle, .square, .pentagon:
            return .radial
        case .tetrahedron, .cube, .octahedron, .dodecahedron, .icosahedron:
            return .spherical
        default:
            return .fractal
        }
    }
}

// Placeholder for NumerologyEngine - references existing implementation
struct NumerologyEngine {
    func calculateFullChart(birthDate: Date, fullName: String) -> NumerologyChart {
        // This would call the existing CompatibilityEngine or similar
        // Placeholder implementation
        return NumerologyChart(
            lifePath: 7,
            expression: 5,
            soulUrge: 3,
            personality: 2,
            birthday: 7,
            maturity: 3,
            challenges: [1, 2, 0, 1],
            pinnacles: [
                Pinnacle(number: 3, ageStart: 0, ageEnd: 35),
                Pinnacle(number: 5, ageStart: 36, ageEnd: 44),
                Pinnacle(number: 8, ageStart: 45, ageEnd: 53),
                Pinnacle(number: 9, ageStart: 54, ageEnd: nil)
            ],
            personalYear: 8,
            personalMonth: 4,
            personalDay: 2,
            birthDate: birthDate,
            fullName: fullName
        )
    }
}

// Matching existing structure from CompatibilityEngine.swift
struct NumerologyChart {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let birthday: Int
    let maturity: Int
    let challenges: [Int]
    let pinnacles: [Pinnacle]
    let personalYear: Int
    let personalMonth: Int
    let personalDay: Int
    let birthDate: Date
    let fullName: String
}

struct Pinnacle {
    let number: Int
    let ageStart: Int
    let ageEnd: Int?
}
