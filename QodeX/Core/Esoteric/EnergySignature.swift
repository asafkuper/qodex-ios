//
//  EnergySignature.swift
//  QodeX - Unified Esoteric Framework
//
//  The universal language that allows all esoteric systems to communicate.
//  Every calculation result reduces to an EnergySignature that other systems can read.
//

import Foundation
import SwiftUI

// MARK: - Energy Signature

/// The universal representation of energy across all esoteric systems.
/// This is the "translation layer" that enables cross-system intelligence.
struct EnergySignature: Codable, Hashable, Identifiable {
    let id = UUID()
    let timestamp: Date
    
    // MARK: - Vibrational Properties
    
    /// Primary frequency in Hz (for frequency work and resonance)
    let primaryFrequency: Double
    
    /// Secondary harmonics
    let harmonicFrequencies: [Double]
    
    /// The quality of vibration (what it "feels" like)
    let vibrationalQuality: VibrationalQuality
    
    /// Elemental composition as percentages
    let elementalResonance: ElementalBalance
    
    // MARK: - Numerical Core
    
    /// Core numbers and their archetypal meanings
    let coreNumbers: [Int: NumericalArchetype]
    
    /// Master numbers present (11, 22, 33, etc.)
    let masterResonance: [Int]
    
    /// Karmic indicators
    let karmicIndicators: [KarmicIndicator]
    
    // MARK: - Geometric Form
    
    /// Associated sacred geometric forms
    let sacredForms: [SacredForm]
    
    /// Mathematical ratios present (Phi, √2, √3, etc.)
    let geometricRatios: [Double]
    
    /// Symmetry type
    let symmetryType: SymmetryType
    
    // MARK: - Planetary/Temporal
    
    /// Primary planetary rulers
    let planetaryRulers: [PlanetaryInfluence]
    
    /// Zodiacal resonance with weights
    let zodiacResonance: [ZodiacInfluence]
    
    /// Lunar phase significance
    let lunarPhase: LunarPhase?
    
    /// Seasonal resonance
    let seasonalResonance: Season?
    
    // MARK: - Kabbalistic
    
    /// Sephirot on the Tree of Life
    let sephiroticPath: [SephiricInfluence]
    
    /// Associated Hebrew letter
    let hebrewLetter: HebrewLetter?
    
    /// Divine name resonance
    let divineName: String?
    
    // MARK: - Symbolic
    
    /// Corresponding tarot cards
    let tarotCorrespondences: [TarotReference]
    
    /// Corresponding playing cards
    let playingCardCorrespondences: [PlayingCardReference]
    
    // MARK: - Alchemical
    
    /// Current alchemical stage
    let alchemicalStage: AlchemicalStage?
    
    /// Recommended alchemical operations
    let recommendedOperations: [AlchemicalOperation]
    
    // MARK: - Quality
    
    /// Masculine/feminine/neutral
    let polarity: Polarity
    
    /// Cardinal, fixed, mutable
    let modality: Modality
    
    /// Cardinal direction
    let direction: CardinalDirection?
    
    // MARK: - Computed Properties
    
    /// Dominant number (highest weighted)
    var dominantNumber: Int? {
        coreNumbers.max { a, b in
            a.value.weight < b.value.weight
        }?.key
    }
    
    /// Dominant planet
    var dominantPlanet: PlanetaryInfluence? {
        planetaryRulers.max { $0.influenceStrength < $1.influenceStrength }
    }
    
    /// Dominant element
    var dominantElement: Element? {
        elementalResonance.dominant
    }
    
    /// Overall intensity (0.0 - 1.0)
    var intensity: Double {
        let factor1 = min(primaryFrequency / 1000.0, 1.0)
        let factor2 = Double(coreNumbers.count) / 10.0
        let factor3 = Double(planetaryRulers.count) / 7.0
        return (factor1 + factor2 + factor3) / 3.0
    }
    
    // MARK: - Synthesis
    
    /// Combine multiple signatures into a unified signature
    static func synthesize(_ signatures: [EnergySignature]) -> EnergySignature {
        guard !signatures.isEmpty else {
            return EnergySignature.neutral
        }
        
        // Average frequencies
        let avgFrequency = signatures.map(\.primaryFrequency).reduce(0, +) / Double(signatures.count)
        
        // Combine elemental balances
        let combinedElements = ElementalBalance.combine(signatures.map(\.elementalResonance))
        
        // Merge core numbers
        var mergedNumbers: [Int: NumericalArchetype] = [:]
        for sig in signatures {
            for (num, archetype) in sig.coreNumbers {
                if let existing = mergedNumbers[num] {
                    if let merged = existing.merged(with: archetype) {
                        mergedNumbers[num] = merged
                    }
                } else {
                    mergedNumbers[num] = archetype
                }
            }
        }
        
        // Combine all master numbers
        let allMasters = Array(Set(signatures.flatMap(\.masterResonance)))
        
        // Collect all forms
        let allForms = Array(Set(signatures.flatMap(\.sacredForms)))
        
        // Average planetary influences
        var planetaryMap: [Planet: [PlanetaryInfluence]] = [:]
        for sig in signatures {
            for influence in sig.planetaryRulers {
                planetaryMap[influence.planet, default: []].append(influence)
            }
        }
        let averagedPlanets = planetaryMap.compactMap { _, influences in
            PlanetaryInfluence.average(influences)
        }
        
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: avgFrequency,
            harmonicFrequencies: Array(Set(signatures.flatMap(\.harmonicFrequencies))),
            vibrationalQuality: signatures.mostCommon(\.vibrationalQuality),
            elementalResonance: combinedElements,
            coreNumbers: mergedNumbers,
            masterResonance: allMasters,
            karmicIndicators: Array(Set(signatures.flatMap(\.karmicIndicators))),
            sacredForms: allForms,
            geometricRatios: Array(Set(signatures.flatMap(\.geometricRatios))),
            symmetryType: signatures.mostCommon(\.symmetryType),
            planetaryRulers: averagedPlanets,
            zodiacResonance: ZodiacInfluence.combine(signatures.flatMap(\.zodiacResonance)),
            lunarPhase: signatures.compactMap(\.lunarPhase).mostCommon(),
            seasonalResonance: signatures.compactMap(\.seasonalResonance).mostCommon(),
            sephiroticPath: Array(Set(signatures.flatMap(\.sephiroticPath))),
            hebrewLetter: signatures.compactMap(\.hebrewLetter).mostCommon(),
            divineName: signatures.compactMap(\.divineName).mostCommon(),
            tarotCorrespondences: Array(Set(signatures.flatMap(\.tarotCorrespondences))),
            playingCardCorrespondences: Array(Set(signatures.flatMap(\.playingCardCorrespondences))),
            alchemicalStage: signatures.compactMap(\.alchemicalStage).mostCommon(),
            recommendedOperations: Array(Set(signatures.flatMap(\.recommendedOperations))),
            polarity: signatures.mostCommon(\.polarity),
            modality: signatures.mostCommon(\.modality),
            direction: signatures.compactMap(\.direction).mostCommon()
        )
    }
    
    /// A neutral/blank signature
    static var neutral: EnergySignature {
        EnergySignature(
            timestamp: Date(),
            primaryFrequency: 432.0,
            harmonicFrequencies: [],
            vibrationalQuality: .integrating,
            elementalResonance: ElementalBalance.balanced,
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

// MARK: - Vibrational Quality

enum VibrationalQuality: String, Codable, CaseIterable {
    case grounding     = "Grounding"      // Earth/Cube - stable, manifesting
    case flowing       = "Flowing"        // Water/Icosahedron - emotional, intuitive
    case activating    = "Activating"     // Fire/Tetrahedron - transformative, will
    case clarifying    = "Clarifying"     // Air/Octahedron - mental, communicative
    case integrating   = "Integrating"    // Ether/Dodecahedron - spiritual, unifying
    case transcending  = "Transcending"   // Void/Merkaba - beyond duality
    
    var element: Element {
        switch self {
        case .grounding: return .earth
        case .flowing: return .water
        case .activating: return .fire
        case .clarifying: return .air
        case .integrating: return .quintessence
        case .transcending: return .void
        }
    }
    
    var sacredForm: SacredForm {
        switch self {
        case .grounding: return .cube
        case .flowing: return .icosahedron
        case .activating: return .tetrahedron
        case .clarifying: return .octahedron
        case .integrating: return .dodecahedron
        case .transcending: return .merkaba
        }
    }
    
    var frequencyRange: ClosedRange<Double> {
        switch self {
        case .grounding: return 174.0...285.0
        case .flowing: return 285.0...396.0
        case .activating: return 396.0...417.0
        case .clarifying: return 417.0...528.0
        case .integrating: return 528.0...852.0
        case .transcending: return 852.0...963.0
        }
    }
}

// MARK: - Numerical Archetype

struct NumericalArchetype: Codable, Hashable {
    let number: Int
    let archetypeName: String
    let keywords: [String]
    let description: String
    let shadow: String
    let gift: String
    let weight: Double  // How significant this number is (0.0 - 1.0)
    
    func merged(with other: NumericalArchetype) -> NumericalArchetype? {
        guard self.number == other.number else {
            // Cannot merge archetypes of different numbers - return nil instead of crashing
            return nil
        }
        
        let totalWeight = self.weight + other.weight
        return NumericalArchetype(
            number: number,
            archetypeName: archetypeName,
            keywords: Array(Set(keywords + other.keywords)),
            description: description,
            shadow: shadow,
            gift: gift,
            weight: min(totalWeight, 1.0)
        )
    }
}

// MARK: - Karmic Indicators

enum KarmicIndicator: String, Codable, CaseIterable {
    case karmicDebt13 = "Karmic Debt 13"    // Misuse of power in past life
    case karmicDebt14 = "Karmic Debt 14"    // Abuse of freedom
    case karmicDebt16 = "Karmic Debt 16"    // Ego/vanity issues
    case karmicDebt19 = "Karmic Debt 19"    // Abuse of power/position
    case masterTeacher11 = "Master Teacher 11"
    case masterBuilder22 = "Master Builder 22"
    case masterCommunicator33 = "Master Communicator 33"
    case soulRetrieval = "Soul Retrieval Needed"
    
    var description: String {
        switch self {
        case .karmicDebt13:
            return "Learning to work with others, letting go of control"
        case .karmicDebt14:
            return "Commitment and responsibility with freedom"
        case .karmicDebt16:
            return "Humility and authentic self-expression"
        case .karmicDebt19:
            return "Using power for collective good, not ego"
        case .masterTeacher11:
            return "Spiritual teaching and illumination"
        case .masterBuilder22:
            return "Building structures for collective benefit"
        case .masterCommunicator33:
            return "Christ consciousness, unconditional love"
        case .soulRetrieval:
            return "Reclaiming fragmented aspects of self"
        }
    }
}

// MARK: - Sacred Forms

enum SacredForm: String, Codable, CaseIterable {
    // 2D Forms
    case circle = "Circle"
    case vesicaPiscis = "Vesica Piscis"
    case triangle = "Triangle"
    case square = "Square"
    case pentagon = "Pentagon"
    case hexagon = "Hexagon"
    case heptagon = "Heptagon"
    case octagon = "Octagon"
    case enneagram = "Enneagram"
    case decagon = "Decagon"
    
    // Complex 2D
    case seedOfLife = "Seed of Life"
    case flowerOfLife = "Flower of Life"
    case fruitOfLife = "Fruit of Life"
    case treeOfLife = "Tree of Life"
    case metatronsCube = "Metatron's Cube"
    case SriYantra = "Sri Yantra"
    
    // Platonic Solids
    case tetrahedron = "Tetrahedron"       // 4 faces, fire
    case cube = "Cube"                     // 6 faces, earth
    case octahedron = "Octahedron"         // 8 faces, air
    case dodecahedron = "Dodecahedron"     // 12 faces, ether
    case icosahedron = "Icosahedron"       // 20 faces, water
    
    // Advanced
    case merkaba = "Merkaba"               // Star tetrahedron
    case torus = "Torus"                   // Energy flow
    case goldenSpiral = "Golden Spiral"
    case fibonacciSpiral = "Fibonacci Spiral"
    
    var element: Element {
        switch self {
        case .tetrahedron: return .fire
        case .cube: return .earth
        case .octahedron: return .air
        case .dodecahedron: return .quintessence
        case .icosahedron: return .water
        case .merkaba: return .void
        default: return .quintessence
        }
    }
    
    var numberOfPoints: Int {
        switch self {
        case .circle: return 0
        case .vesicaPiscis: return 2
        case .triangle: return 3
        case .tetrahedron: return 4
        case .square, .pentagon: return 4
        case .hexagon: return 6
        case .heptagon: return 7
        case .octagon, .cube: return 8
        case .enneagram: return 9
        case .decagon: return 10
        case .seedOfLife: return 7
        case .flowerOfLife: return 19
        case .fruitOfLife: return 13
        case .octahedron: return 6
        case .dodecahedron: return 12
        case .icosahedron: return 12
        case .merkaba: return 8
        case .treeOfLife: return 10
        case .metatronsCube: return 13
        case .SriYantra: return 9
        default: return 0
        }
    }
}

enum SymmetryType: String, Codable {
    case none = "Asymmetric"
    case bilateral = "Bilateral"
    case radial = "Radial"
    case spherical = "Spherical"
    case fractal = "Fractal"
}

// MARK: - Planetary Influence

struct PlanetaryInfluence: Codable, Hashable {
    let planet: Planet
    let influenceStrength: Double  // 0.0 - 1.0
    let aspect: AspectType?
    let house: Int?
    let isRetrograde: Bool
    let dignity: Dignity
    
    enum Dignity: String, Codable {
        case domicile = "Domicile"     // Ruling sign
        case exaltation = "Exaltation" // Strong placement
        case neutral = "Neutral"
        case detriment = "Detriment"   // Opposite ruling sign
        case fall = "Fall"             // Opposite exaltation
    }
    
    static func average(_ influences: [PlanetaryInfluence]) -> PlanetaryInfluence? {
        guard !influences.isEmpty else {
            // Return nil instead of crashing
            return nil
        }
        
        let planet = influences[0].planet
        let avgStrength = influences.map(\.influenceStrength).reduce(0, +) / Double(influences.count)
        
        return PlanetaryInfluence(
            planet: planet,
            influenceStrength: avgStrength,
            aspect: influences.compactMap(\.aspect).mostCommon(),
            house: influences.compactMap(\.house).mostCommon(),
            isRetrograde: influences.contains { $0.isRetrograde },
            dignity: influences.map(\.dignity).mostCommon() ?? .neutral
        )
    }
}

enum Planet: String, Codable, CaseIterable {
    case sun = "Sun"
    case moon = "Moon"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"
    case northNode = "North Node"
    case southNode = "South Node"
    case chiron = "Chiron"
    
    var rulingNumbers: [Int] {
        switch self {
        case .sun: return [1, 19]
        case .moon: return [2, 20]
        case .jupiter: return [3, 12, 21]
        case .uranus, .saturn: return [4, 22]
        case .mercury: return [5, 14, 23]
        case .venus: return [6, 15, 24]
        case .neptune: return [7, 16, 25]
        case .mars: return [8, 17, 26]
        case .pluto: return [9, 18, 27]
        default: return []
        }
    }
}

enum AspectType: String, Codable {
    case conjunction = "Conjunction"   // 0°
    case sextile = "Sextile"           // 60°
    case square = "Square"             // 90°
    case trine = "Trine"               // 120°
    case opposition = "Opposition"     // 180°
    case quincunx = "Quincunx"         // 150°
}

// MARK: - Zodiac

struct ZodiacInfluence: Codable, Hashable {
    let sign: ZodiacSign
    let strength: Double
    let house: Int?
    let planets: [Planet]
    
    static func combine(_ influences: [ZodiacInfluence]) -> [ZodiacInfluence] {
        var bySign: [ZodiacSign: [ZodiacInfluence]] = [:]
        for inf in influences {
            bySign[inf.sign, default: []].append(inf)
        }
        
        return bySign.map { sign, infs in
            let totalStrength = infs.map(\.strength).reduce(0, +)
            let allPlanets = Array(Set(infs.flatMap(\.planets)))
            return ZodiacInfluence(
                sign: sign,
                strength: min(totalStrength, 1.0),
                house: infs.compactMap(\.house).mostCommon(),
                planets: allPlanets
            )
        }
    }
}

enum ZodiacSign: String, Codable, CaseIterable {
    case aries = "Aries"
    case taurus = "Taurus"
    case gemini = "Gemini"
    case cancer = "Cancer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn = "Capricorn"
    case aquarius = "Aquarius"
    case pisces = "Pisces"
    
    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }
    
    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }
    
    var rulingPlanet: Planet {
        switch self {
        case .aries: return .mars
        case .taurus: return .venus
        case .gemini: return .mercury
        case .cancer: return .moon
        case .leo: return .sun
        case .virgo: return .mercury
        case .libra: return .venus
        case .scorpio: return .pluto
        case .sagittarius: return .jupiter
        case .capricorn: return .saturn
        case .aquarius: return .uranus
        case .pisces: return .neptune
        }
    }
}

enum Modality: String, Codable {
    case cardinal = "Cardinal"   // Initiating
    case fixed = "Fixed"         // Sustaining
    case mutable = "Mutable"     // Adapting
}

enum LunarPhase: String, Codable {
    case new = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case full = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"
    
    var isWaxing: Bool {
        [.waxingCrescent, .firstQuarter, .waxingGibbous].contains(self)
    }
    
    var isWaning: Bool {
        [.waningGibbous, .lastQuarter, .waningCrescent].contains(self)
    }
}

enum Season: String, Codable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
}

// MARK: - Sephirotic

struct SephiricInfluence: Codable, Hashable {
    let sephirah: Sephirah
    let activationLevel: Double  // 0.0 - 1.0
    let associatedPaths: [Int]  // Path numbers on Tree of Life
}

enum Sephirah: Int, Codable, CaseIterable {
    case kether = 1      // Crown
    case chokmah = 2     // Wisdom
    case binah = 3       // Understanding
    case chesed = 4      // Mercy
    case geburah = 5     // Severity
    case tiphareth = 6   // Beauty
    case netzach = 7     // Victory
    case hod = 8         // Splendor
    case yesod = 9       // Foundation
    case malkuth = 10    // Kingdom
    case daath = 11      // Knowledge (hidden)
    
    var name: String {
        switch self {
        case .kether: return "Kether"
        case .chokmah: return "Chokmah"
        case .binah: return "Binah"
        case .chesed: return "Chesed"
        case .geburah: return "Geburah"
        case .tiphareth: return "Tiphareth"
        case .netzach: return "Netzach"
        case .hod: return "Hod"
        case .yesod: return "Yesod"
        case .malkuth: return "Malkuth"
        case .daath: return "Da'ath"
        }
    }
    
    var divineName: String {
        switch self {
        case .kether: return "Eheieh"
        case .chokmah: return "Yah"
        case .binah: return "YHVH Elohim"
        case .chesed: return "El"
        case .geburah: return "Elohim Gibor"
        case .tiphareth: return "YHVH Eloah ve-Da'at"
        case .netzach: return "YHVH Tzaba'oth"
        case .hod: return "Elohim Tzaba'oth"
        case .yesod: return "Shaddai El Chai"
        case .malkuth: return "Adonai ha-Aretz"
        case .daath: return "YHVH Elohim"  // Divine name same as Binah - Da'at emerges from Understanding
        }
    }
}

enum HebrewLetter: String, Codable, CaseIterable {
    case aleph = "Aleph"
    case beth = "Beth"
    case gimel = "Gimel"
    case daleth = "Daleth"
    case heh = "Heh"
    case vau = "Vau"
    case zayin = "Zayin"
    case cheth = "Cheth"
    case teth = "Teth"
    case yod = "Yod"
    case kaph = "Kaph"
    case lamed = "Lamed"
    case mem = "Mem"
    case nun = "Nun"
    case samekh = "Samekh"
    case ayin = "Ayin"
    case peh = "Peh"
    case tzaddi = "Tzaddi"
    case qoph = "Qoph"
    case resh = "Resh"
    case shin = "Shin"
    case tav = "Tav"
    
    var numericalValue: Int {
        switch self {
        case .aleph: return 1
        case .beth: return 2
        case .gimel: return 3
        case .daleth: return 4
        case .heh: return 5
        case .vau: return 6
        case .zayin: return 7
        case .cheth: return 8
        case .teth: return 9
        case .yod: return 10
        case .kaph: return 20
        case .lamed: return 30
        case .mem: return 40
        case .nun: return 50
        case .samekh: return 60
        case .ayin: return 70
        case .peh: return 80
        case .tzaddi: return 90
        case .qoph: return 100
        case .resh: return 200
        case .shin: return 300
        case .tav: return 400
        }
    }
}

// MARK: - Tarot Reference

struct TarotReference: Codable, Hashable {
    let cardName: String
    let cardNumber: Int  // 0-21 for major, 1-10/court for minor
    let suit: Suit?
    let isReversed: Bool
    
    enum Suit: String, Codable {
        case wands = "Wands"
        case cups = "Cups"
        case swords = "Swords"
        case pentacles = "Pentacles"
    }
}

// MARK: - Playing Card Reference

struct PlayingCardReference: Codable, Hashable {
    let rank: Rank
    let suit: PlayingSuit
    
    enum Rank: String, Codable {
        case ace = "Ace"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "10"
        case jack = "Jack"
        case queen = "Queen"
        case king = "King"
        case joker = "Joker"
    }
    
    enum PlayingSuit: String, Codable {
        case hearts = "Hearts"
        case diamonds = "Diamonds"
        case clubs = "Clubs"
        case spades = "Spades"
    }
}

// MARK: - Alchemical

enum AlchemicalStage: String, Codable {
    case calcination = "Calcination"
    case dissolution = "Dissolution"
    case separation = "Separation"
    case conjunction = "Conjunction"
    case fermentation = "Fermentation"
    case distillation = "Distillation"
    case coagulation = "Coagulation"
    
    var element: Element {
        switch self {
        case .calcination: return .fire
        case .dissolution: return .water
        case .separation: return .air
        case .conjunction: return .earth
        case .fermentation: return .quintessence
        case .distillation: return .water
        case .coagulation: return .earth
        }
    }
    
    var planet: Planet {
        switch self {
        case .calcination: return .saturn
        case .dissolution: return .moon
        case .separation: return .mercury
        case .conjunction: return .venus
        case .fermentation: return .jupiter
        case .distillation: return .mercury
        case .coagulation: return .sun
        }
    }
}

enum AlchemicalOperation: String, Codable {
    case purify = "Purify"
    case dissolve = "Dissolve"
    case separate = "Separate"
    case combine = "Combine"
    case ferment = "Ferment"
    case distill = "Distill"
    case coagulate = "Coagulate"
}

// MARK: - Elements

enum Element: String, Codable, CaseIterable {
    case fire = "Fire"
    case water = "Water"
    case air = "Air"
    case earth = "Earth"
    case quintessence = "Quintessence"
    case void = "Void"
}

struct ElementalBalance: Codable, Hashable {
    let fire: Double
    let water: Double
    let air: Double
    let earth: Double
    let quintessence: Double
    
    var dominant: Element? {
        let maxVal = max(fire, water, air, earth, quintessence)
        guard maxVal > 0.3 else { return nil }
        
        if fire == maxVal { return .fire }
        if water == maxVal { return .water }
        if air == maxVal { return .air }
        if earth == maxVal { return .earth }
        if quintessence == maxVal { return .quintessence }
        return nil
    }
    
    var deficient: Element? {
        let minVal = min(fire, water, air, earth)
        guard minVal < 0.15 else { return nil }
        
        if fire == minVal { return .fire }
        if water == minVal { return .water }
        if air == minVal { return .air }
        if earth == minVal { return .earth }
        return nil
    }
    
    static var balanced: ElementalBalance {
        ElementalBalance(fire: 0.2, water: 0.2, air: 0.2, earth: 0.2, quintessence: 0.2)
    }
    
    static func combine(_ balances: [ElementalBalance]) -> ElementalBalance {
        guard !balances.isEmpty else { return .balanced }
        
        let count = Double(balances.count)
        return ElementalBalance(
            fire: balances.map(\.fire).reduce(0, +) / count,
            water: balances.map(\.water).reduce(0, +) / count,
            air: balances.map(\.air).reduce(0, +) / count,
            earth: balances.map(\.earth).reduce(0, +) / count,
            quintessence: balances.map(\.quintessence).reduce(0, +) / count
        )
    }
}

enum Polarity: String, Codable {
    case masculine = "Masculine"
    case feminine = "Feminine"
    case neutral = "Neutral"
}

enum CardinalDirection: String, Codable {
    case north = "North"
    case east = "East"
    case south = "South"
    case west = "West"
    case center = "Center"
    case above = "Above"
    case below = "Below"
}

// MARK: - Array Extensions for Most Common

extension Array {
    func mostCommon<T: Hashable>(_ keyPath: KeyPath<Element, T>) -> T? {
        guard !isEmpty else { return nil }
        
        var counts: [T: Int] = [:]
        for element in self {
            let value = element[keyPath: keyPath]
            counts[value, default: 0] += 1
        }
        
        return counts.max { $0.value < $1.value }?.key
    }
    
    func mostCommon() -> Element? where Element: Hashable {
        guard !isEmpty else { return nil }
        
        var counts: [Element: Int] = [:]
        for element in self {
            counts[element, default: 0] += 1
        }
        
        return counts.max { $0.value < $1.value }?.key
    }
}
