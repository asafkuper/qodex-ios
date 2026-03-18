//
//  ChaldeanCalculator.swift
//  QodeX - Chaldean Numerology Calculation Engine
//
//  The Chaldean system is an ancient Babylonian numerology system that assigns
//  numbers based on sound/vibration rather than alphabetical order.
//  It is considered more mystical and spiritually oriented than Pythagorean.
//

import Foundation

/// Enumeration of supported numerology systems
enum NumerologySystem: String, CaseIterable, Identifiable {
    case pythagorean = "Pythagorean"
    case chaldean = "Chaldean"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .pythagorean:
            return "Modern Western system based on alphabetical order"
        case .chaldean:
            return "Ancient Babylonian system based on sound vibration"
        }
    }
    
    var origin: String {
        switch self {
        case .pythagorean:
            return "Ancient Greece (6th century BCE)"
        case .chaldean:
            return "Ancient Babylon/Chaldea (circa 4000 BCE)"
        }
    }
}

/// Chaldean Numerology Calculator
/// Implements the ancient Chaldean/Babylonian numerology system
class ChaldeanCalculator {
    static let shared = ChaldeanCalculator()
    
    // MARK: - Constants
    
    private let masterNumbers = [11, 22, 33]
    private let karmicDebtNumbers = [13, 14, 16, 19]
    
    /// Chaldean letter values based on sound vibration
    /// Source: Ancient Chaldean/Babylonian numerology tablets
    /// Note: Unlike Pythagorean, this is NOT alphabetical - it's based on vibrational energy
    private let chaldeanLetterValues: [Character: Int] = [
        // Number 1: Sun energy - leadership, individuality
        "A": 1, "I": 1, "J": 1, "Q": 1, "Y": 1,
        
        // Number 2: Moon energy - sensitivity, cooperation
        "B": 2, "K": 2, "R": 2,
        
        // Number 3: Jupiter energy - creativity, expansion
        "C": 3, "G": 3, "L": 3, "S": 3,
        
        // Number 4: Uranus/Rahu energy - practicality, foundation
        "D": 4, "M": 4, "T": 4,
        
        // Number 5: Mercury energy - communication, change
        "E": 5, "H": 5, "N": 5, "X": 5,
        
        // Number 6: Venus energy - love, harmony, beauty
        "U": 6, "V": 6, "W": 6,
        
        // Number 7: Neptune/Ketu energy - spirituality, mysticism
        "O": 7, "Z": 7,
        
        // Number 8: Saturn energy - karma, discipline, authority
        "F": 8, "P": 8,
        
        // Note: In Chaldean system, there is NO letter for 9
        // Number 9 is considered sacred/complete and reserved for divine energy
        // Some traditions assign it to no letters, others to special cases
    ]
    
    /// Letters grouped by their Chaldean number for educational display
    let chaldeanNumberGroups: [(number: Int, letters: [Character], planet: String, meaning: String)] = [
        (1, ["A", "I", "J", "Q", "Y"], "Sun", "Leadership, individuality, ambition"),
        (2, ["B", "K", "R"], "Moon", "Sensitivity, cooperation, intuition"),
        (3, ["C", "G", "L", "S"], "Jupiter", "Creativity, expansion, optimism"),
        (4, ["D", "M", "T"], "Uranus/Rahu", "Practicality, foundation, sudden changes"),
        (5, ["E", "H", "N", "X"], "Mercury", "Communication, intellect, change"),
        (6, ["U", "V", "W"], "Venus", "Love, harmony, beauty, responsibility"),
        (7, ["O", "Z"], "Neptune/Ketu", "Spirituality, mysticism, introspection"),
        (8, ["F", "P"], "Saturn", "Karma, discipline, authority, material success"),
    ]
    
    // MARK: - Life Path Number (same calculation as Pythagorean)
    
    /// Calculate Life Path Number from birth date
    /// The Life Path calculation is identical between systems
    func calculateLifePathNumber(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)
        
        let month = reduceWithMasters(components.month ?? 0)
        let day = reduceWithMasters(components.day ?? 0)
        let year = reduceWithMasters(components.year ?? 0)
        
        let sum = month + day + year
        return reduceWithMasters(sum)
    }
    
    /// Calculate full Life Path with master number detection
    func calculateLifePathDetails(birthDate: Date) -> ChaldeanLifePathDetails {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)
        
        let month = reduceWithMasters(components.month ?? 0)
        let day = reduceWithMasters(components.day ?? 0)
        let year = reduceWithMasters(components.year ?? 0)
        
        let sum = month + day + year
        let finalNumber = reduceWithMasters(sum)
        
        let isMasterNumber = masterNumbers.contains(finalNumber)
        let hasKarmicDebt = karmicDebtNumbers.contains(sum)
        let karmicDebtNumber = hasKarmicDebt ? sum : nil
        
        return ChaldeanLifePathDetails(
            number: finalNumber,
            isMasterNumber: isMasterNumber,
            monthComponent: month,
            dayComponent: day,
            yearComponent: year,
            hasKarmicDebt: hasKarmicDebt,
            karmicDebtNumber: karmicDebtNumber,
            calculationBreakdown: "\(month) + \(day) + \(year) = \(sum) → \(finalNumber)",
            system: .chaldean
        )
    }
    
    // MARK: - Expression Number (Chaldean Method)
    
    /// Calculate Expression Number using Chaldean letter values
    /// Uses all letters in the name with Chaldean vibrational mappings
    func calculateExpressionNumber(name: String) -> Int {
        let sum = name.uppercased()
            .filter { $0.isLetter }
            .compactMap { chaldeanLetterValues[$0] }
            .reduce(0, +)
        
        return reduceWithMasters(sum)
    }
    
    /// Calculate Expression Number with detailed Chaldean breakdown
    func calculateExpressionDetails(name: String) -> ChaldeanNameNumberDetails {
        let upperName = name.uppercased().filter { $0.isLetter }
        
        var letterBreakdown: [(letter: Character, value: Int, planet: String)] = []
        var totalSum = 0
        
        for char in upperName {
            if let value = chaldeanLetterValues[char] {
                let planet = planetForNumber(value)
                letterBreakdown.append((char, value, planet))
                totalSum += value
            }
        }
        
        let finalNumber = reduceWithMasters(totalSum)
        let isMasterNumber = masterNumbers.contains(finalNumber)
        
        return ChaldeanNameNumberDetails(
            number: finalNumber,
            isMasterNumber: isMasterNumber,
            totalSum: totalSum,
            calculationBreakdown: "\(totalSum) → \(finalNumber)",
            letterValues: letterBreakdown,
            system: .chaldean
        )
    }
    
    // MARK: - Soul Urge Number (Chaldean Method)
    
    /// Calculate Soul Urge (Heart's Desire) Number from vowels using Chaldean values
    /// Vowels: A, E, I, O, U
    /// Y is treated as a vowel ONLY when it makes a vowel sound (simplified: treat as consonant)
    func calculateSoulUrgeNumber(name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased()
            .filter { vowels.contains($0) }
            .compactMap { chaldeanLetterValues[$0] }
            .reduce(0, +)
        
        return reduceWithMasters(sum)
    }
    
    /// Calculate Soul Urge with Chaldean breakdown
    func calculateSoulUrgeDetails(name: String) -> ChaldeanNameNumberDetails {
        let vowels = "AEIOU"
        let upperName = name.uppercased()
        
        var letterBreakdown: [(letter: Character, value: Int, planet: String)] = []
        var totalSum = 0
        
        for char in upperName where vowels.contains(char) {
            if let value = chaldeanLetterValues[char] {
                let planet = planetForNumber(value)
                letterBreakdown.append((char, value, planet))
                totalSum += value
            }
        }
        
        let finalNumber = reduceWithMasters(totalSum)
        let isMasterNumber = masterNumbers.contains(finalNumber)
        
        return ChaldeanNameNumberDetails(
            number: finalNumber,
            isMasterNumber: isMasterNumber,
            totalSum: totalSum,
            calculationBreakdown: "\(totalSum) → \(finalNumber)",
            letterValues: letterBreakdown,
            system: .chaldean
        )
    }
    
    // MARK: - Personality Number (Chaldean Method)
    
    /// Calculate Personality Number from consonants using Chaldean values
    func calculatePersonalityNumber(name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased()
            .filter { $0.isLetter && !vowels.contains($0) }
            .compactMap { chaldeanLetterValues[$0] }
            .reduce(0, +)
        
        return reduceWithoutMasters(sum)
    }
    
    /// Calculate Personality with Chaldean breakdown
    func calculatePersonalityDetails(name: String) -> ChaldeanNameNumberDetails {
        let vowels = "AEIOU"
        let upperName = name.uppercased().filter { $0.isLetter }
        
        var letterBreakdown: [(letter: Character, value: Int, planet: String)] = []
        var totalSum = 0
        
        for char in upperName where !vowels.contains(char) {
            if let value = chaldeanLetterValues[char] {
                let planet = planetForNumber(value)
                letterBreakdown.append((char, value, planet))
                totalSum += value
            }
        }
        
        let finalNumber = reduceWithoutMasters(totalSum)
        
        return ChaldeanNameNumberDetails(
            number: finalNumber,
            isMasterNumber: false,
            totalSum: totalSum,
            calculationBreakdown: "\(totalSum) → \(finalNumber)",
            letterValues: letterBreakdown,
            system: .chaldean
        )
    }
    
    // MARK: - Compound Number Analysis (Unique to Chaldean)
    
    /// Chaldean system places special significance on compound numbers (10-52)
    /// These reveal deeper karmic and spiritual meanings
    func getCompoundNumberMeaning(_ number: Int) -> ChaldeanCompoundMeaning? {
        let meanings: [Int: ChaldeanCompoundMeaning] = [
            10: ChaldeanCompoundMeaning(
                number: 10,
                title: "The Wheel of Fortune",
                meaning: "Symbolizes honor, faith, and confidence. Rise and fall in life. Lucky number.",
                keyword: "Fortune"
            ),
            11: ChaldeanCompoundMeaning(
                number: 11,
                title: "The Lion",
                meaning: "Hidden dangers, hidden enemies, trials and treachery from others. Great mental powers but must be used wisely.",
                keyword: "Mastery"
            ),
            12: ChaldeanCompoundMeaning(
                number: 12,
                title: "The Sacrifice",
                meaning: "Suffering and anxiety, sacrifice for others. Victimization by others' plans.",
                keyword: "Sacrifice"
            ),
            13: ChaldeanCompoundMeaning(
                number: 13,
                title: "The Rebirth",
                meaning: "Powerful but dangerous. Transformation through upheaval. Warning of change.",
                keyword: "Transformation"
            ),
            14: ChaldeanCompoundMeaning(
                number: 14,
                title: "The Movement",
                meaning: "Lucky for dealings with money, risk-taking, and change. Natural business ability.",
                keyword: "Commerce"
            ),
            15: ChaldeanCompoundMeaning(
                number: 15,
                title: "The Magician",
                meaning: "Strong occult and psychic influences. Power over others through charm.",
                keyword: "Enchantment"
            ),
            16: ChaldeanCompoundMeaning(
                number: 16,
                title: "The Shattered Citadel",
                meaning: "Fall from pride and position. Destruction of ego. Warning of sudden calamity.",
                keyword: "Fall"
            ),
            17: ChaldeanCompoundMeaning(
                number: 17,
                title: "The Star of the Magi",
                meaning: "Highly spiritual, psychic gifts, superior intelligence. Victory over obstacles.",
                keyword: "Spirituality"
            ),
            18: ChaldeanCompoundMeaning(
                number: 18,
                title: "The Materialism",
                meaning: "War, strife, deception. Success through mental struggle. Danger from money.",
                keyword: "Struggle"
            ),
            19: ChaldeanCompoundMeaning(
                number: 19,
                title: "The Prince of Heaven",
                meaning: "Universal love, rising above adversity. Victory and success assured.",
                keyword: "Victory"
            ),
            20: ChaldeanCompoundMeaning(
                number: 20,
                title: "The Awakening",
                meaning: "New purpose, judgment, awakening. Partnerships and change.",
                keyword: "Judgment"
            ),
            21: ChaldeanCompoundMeaning(
                number: 21,
                title: "The Crown of the Magi",
                meaning: "Success after struggle, honors, elevation in life. Universal triumph.",
                keyword: "Triumph"
            ),
            22: ChaldeanCompoundMeaning(
                number: 22,
                title: "The Fool",
                meaning: "Blindness to reality, foolishness, lack of foresight. Caution needed.",
                keyword: "Caution"
            ),
            23: ChaldeanCompoundMeaning(
                number: 23,
                title: "The Royal Star of the Lion",
                meaning: "Most fortunate number. Protection, success in all endeavors, divine favor.",
                keyword: "Protection"
            ),
            24: ChaldeanCompoundMeaning(
                number: 24,
                title: "The Love",
                meaning: "Love, beauty, artistic success, fortunate in love and business.",
                keyword: "Harmony"
            ),
            25: ChaldeanCompoundMeaning(
                number: 25,
                title: "The Discrimination",
                meaning: "Strength through experience, wise discernment. Gains through investigation.",
                keyword: "Wisdom"
            ),
            26: ChaldeanCompoundMeaning(
                number: 26,
                title: "The Disappointment",
                meaning: "Grave warnings for the future. Danger through bad advice, partnership failures.",
                keyword: "Warning"
            ),
            27: ChaldeanCompoundMeaning(
                number: 27,
                title: "The Scepter",
                meaning: "Commanding power, authority, leadership. Success through bold action.",
                keyword: "Authority"
            ),
            28: ChaldeanCompoundMeaning(
                number: 28,
                title: "The Uncertainty",
                meaning: "Contradictory, threat of loss through law or conflict. Trust carefully.",
                keyword: "Risk"
            ),
            29: ChaldeanCompoundMeaning(
                number: 29,
                title: "The Grace",
                meaning: "Warnings of trials and tribulations. Must rely on intuition and inner wisdom.",
                keyword: "Trials"
            ),
            30: ChaldeanCompoundMeaning(
                number: 30,
                title: "The Faith",
                meaning: "Thoughtful deduction, mental superiority, devotion to duty. Reliable.",
                keyword: "Devotion"
            ),
            31: ChaldeanCompoundMeaning(
                number: 31,
                title: "The Child",
                meaning: "Innocence, purity, trust. Living in thought rather than action.",
                keyword: "Innocence"
            ),
            32: ChaldeanCompoundMeaning(
                number: 32,
                title: "The Transport",
                meaning: "Magical number of communication, transportation, travel. Quick success.",
                keyword: "Communication"
            ),
            33: ChaldeanCompoundMeaning(
                number: 33,
                title: "The Blessing",
                meaning: "Blessing of the divine, spiritual teacher, master healer. Great responsibility.",
                keyword: "Blessing"
            ),
        ]
        
        return meanings[number]
    }
    
    // MARK: - Full Chaldean Profile
    
    /// Calculate complete Chaldean numerology profile
    func calculateFullProfile(birthDate: Date, fullName: String) -> ChaldeanProfile {
        let lifePath = calculateLifePathNumber(birthDate: birthDate)
        let expression = calculateExpressionNumber(name: fullName)
        let soulUrge = calculateSoulUrgeNumber(name: fullName)
        let personality = calculatePersonalityNumber(name: fullName)
        
        // Calculate compound meanings for double-digit results
        let expressionCompound = expression > 9 ? getCompoundNumberMeaning(expression) : nil
        let soulUrgeCompound = soulUrge > 9 ? getCompoundNumberMeaning(soulUrge) : nil
        
        return ChaldeanProfile(
            lifePath: lifePath,
            expression: expression,
            soulUrge: soulUrge,
            personality: personality,
            expressionCompound: expressionCompound,
            soulUrgeCompound: soulUrgeCompound
        )
    }
    
    // MARK: - Helper Methods
    
    /// Get planet associated with a Chaldean number
    func planetForNumber(_ number: Int) -> String {
        let planets: [Int: String] = [
            1: "Sun ☉",
            2: "Moon ☽",
            3: "Jupiter ♃",
            4: "Uranus ♅",
            5: "Mercury ☿",
            6: "Venus ♀",
            7: "Neptune ♆",
            8: "Saturn ♄",
            9: "Mars ♂ (Sacred)"
        ]
        return planets[number] ?? "Unknown"
    }
    
    /// Reduce a number to a single digit, preserving master numbers
    func reduceWithMasters(_ number: Int) -> Int {
        var n = abs(number)
        
        while n > 9 {
            if masterNumbers.contains(n) {
                return n
            }
            
            var sum = 0
            var temp = n
            while temp > 0 {
                sum += temp % 10
                temp /= 10
            }
            n = sum
        }
        
        return n
    }
    
    /// Reduce a number to a single digit, ignoring master numbers
    func reduceWithoutMasters(_ number: Int) -> Int {
        var n = abs(number)
        
        while n > 9 {
            var sum = 0
            var temp = n
            while temp > 0 {
                sum += temp % 10
                temp /= 10
            }
            n = sum
        }
        
        return n
    }
    
    /// Compare Pythagorean and Chaldean results for the same name
    func compareSystems(name: String, birthDate: Date) -> SystemComparison {
        let pythagorean = NumerologyCalculator.shared.calculateFullProfile(
            birthDate: birthDate,
            fullName: name
        )
        
        let chaldean = calculateFullProfile(
            birthDate: birthDate,
            fullName: name
        )
        
        return SystemComparison(
            name: name,
            pythagorean: pythagorean,
            chaldean: chaldean,
            differences: findDifferences(pythagorean: pythagorean, chaldean: chaldean)
        )
    }
    
    private func findDifferences(pythagorean: NumerologyProfile, chaldean: ChaldeanProfile) -> [String] {
        var differences: [String] = []
        
        if pythagorean.expression != chaldean.expression {
            differences.append("Expression: Pythagorean \(pythagorean.expression) vs Chaldean \(chaldean.expression)")
        }
        if pythagorean.soulUrge != chaldean.soulUrge {
            differences.append("Soul Urge: Pythagorean \(pythagorean.soulUrge) vs Chaldean \(chaldean.soulUrge)")
        }
        if pythagorean.personality != chaldean.personality {
            differences.append("Personality: Pythagorean \(pythagorean.personality) vs Chaldean \(chaldean.personality)")
        }
        
        return differences.isEmpty ? ["Both systems yield identical results for this name"] : differences
    }
}

// MARK: - Supporting Types

struct ChaldeanLifePathDetails {
    let number: Int
    let isMasterNumber: Bool
    let monthComponent: Int
    let dayComponent: Int
    let yearComponent: Int
    let hasKarmicDebt: Bool
    let karmicDebtNumber: Int?
    let calculationBreakdown: String
    let system: NumerologySystem
}

struct ChaldeanNameNumberDetails {
    let number: Int
    let isMasterNumber: Bool
    let totalSum: Int
    let calculationBreakdown: String
    let letterValues: [(letter: Character, value: Int, planet: String)]
    let system: NumerologySystem
}

struct ChaldeanCompoundMeaning {
    let number: Int
    let title: String
    let meaning: String
    let keyword: String
}

struct ChaldeanProfile {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let expressionCompound: ChaldeanCompoundMeaning?
    let soulUrgeCompound: ChaldeanCompoundMeaning?
    
    var hasMasterNumber: Bool {
        [lifePath, expression, soulUrge, personality].contains { [11, 22, 33].contains($0) }
    }
    
    var hasCompoundMeaning: Bool {
        expressionCompound != nil || soulUrgeCompound != nil
    }
}

struct SystemComparison {
    let name: String
    let pythagorean: NumerologyProfile
    let chaldean: ChaldeanProfile
    let differences: [String]
}

// MARK: - Educational Content

extension ChaldeanCalculator {
    
    /// Get educational content about Chaldean numerology
    static func getEducationalContent() -> ChaldeanEducationalContent {
        return ChaldeanEducationalContent(
            title: "Chaldean Numerology: The Ancient Babylonian System",
            origin: "Originating in ancient Babylon (modern-day Iraq) around 4000 BCE, the Chaldean system is one of the oldest known forms of numerology.",
            philosophy: "Unlike the Pythagorean system which assigns numbers alphabetically, Chaldean numerology is based on the sound vibration and energy of each letter. The ancient Chaldeans believed that everything in the universe vibrates at a specific frequency, and these vibrations correspond to numerical values.",
            keyDifferences: [
                "Sound-Based: Letters are assigned values based on their vibrational energy, not alphabetical position",
                "No 9 in Alphabet: The number 9 is considered sacred and divine, so no letters are assigned to it",
                "Compound Numbers: Special meanings are given to all double-digit numbers (10-52)",
                "Planetary Associations: Each number corresponds to a specific planet's energy",
                "More Mystical: Considered more spiritual and occult than the Pythagorean system",
                "Single Name Focus: Traditionally used with one name rather than full birth certificate names"
            ],
            letterValuesDescription: "Each letter vibrates with planetary energy:",
            whenToUse: [
                "When seeking deeper spiritual insights",
                "For understanding karmic patterns and past life influences",
                "When making important business or financial decisions",
                "For understanding hidden aspects of personality",
                "When the Pythagorean system doesn't seem to 'fit'"
            ],
            famousPractitioners: [
                "Cheiro (William John Warner) - Famous Irish astrologer and numerologist",
                "Dr. Julian St. Aubyn - British numerologist and author",
                "Various mystery schools and esoteric traditions"
            ]
        )
    }
}

struct ChaldeanEducationalContent {
    let title: String
    let origin: String
    let philosophy: String
    let keyDifferences: [String]
    let letterValuesDescription: String
    let whenToUse: [String]
    let famousPractitioners: [String]
}

// MARK: - System Selection Manager

/// Manages the user's preferred numerology system
class NumerologySystemManager: ObservableObject {
    static let shared = NumerologySystemManager()
    static let systemKey = "preferredNumerologySystem"
    
    @Published var currentSystem: NumerologySystem {
        didSet {
            UserDefaults.standard.set(currentSystem.rawValue, forKey: Self.systemKey)
        }
    }
    
    private init() {
        let storedValue = UserDefaults.standard.string(forKey: Self.systemKey)
        self.currentSystem = NumerologySystem(rawValue: storedValue ?? "") ?? .pythagorean
    }
    
    /// Get the appropriate calculator based on current system
    var calculator: Any {
        switch currentSystem {
        case .pythagorean:
            return NumerologyCalculator.shared
        case .chaldean:
            return ChaldeanCalculator.shared
        }
    }
    
    /// Calculate Expression number using current system
    func calculateExpression(name: String) -> Int {
        switch currentSystem {
        case .pythagorean:
            return NumerologyCalculator.shared.calculateExpressionNumber(name: name)
        case .chaldean:
            return ChaldeanCalculator.shared.calculateExpressionNumber(name: name)
        }
    }
    
    /// Calculate Soul Urge number using current system
    func calculateSoulUrge(name: String) -> Int {
        switch currentSystem {
        case .pythagorean:
            return NumerologyCalculator.shared.calculateSoulUrgeNumber(name: name)
        case .chaldean:
            return ChaldeanCalculator.shared.calculateSoulUrgeNumber(name: name)
        }
    }
    
    /// Calculate Personality number using current system
    func calculatePersonality(name: String) -> Int {
        switch currentSystem {
        case .pythagorean:
            return NumerologyCalculator.shared.calculatePersonalityNumber(name: name)
        case .chaldean:
            return ChaldeanCalculator.shared.calculatePersonalityNumber(name: name)
        }
    }
}
