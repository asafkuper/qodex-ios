//
//  SynchronicityEngine.swift
//  QodeX - Unified Esoteric Framework
//
//  Detects meaningful patterns and coincidences across all esoteric systems.
//

import Foundation

// MARK: - Synchronicity Engine

/// Detects and analyzes synchronicities across the user's esoteric journey.
/// Synchronicities are meaningful coincidences that suggest deeper patterning.
class SynchronicityEngine {
    static let shared = SynchronicityEngine()
    
    // MARK: - Detection Methods
    
    /// Main entry point: scan for all synchronicity types
    func detectAll(
        for blueprint: PersonalBlueprint,
        date: Date = Date(),
        lookbackDays: Int = 30
    ) -> SynchronicityReport {
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -lookbackDays, to: date) ?? date
        
        // Collect all patterns
        var allPatterns: [SynchronicityPattern] = []
        
        // Number patterns
        allPatterns += detectNumberPatterns(for: blueprint, date: date)
        
        // Transit patterns
        if let astro = blueprint.astrologyProfile {
            allPatterns += detectTransitPatterns(astro: astro, date: date)
        }
        
        // Temporal patterns (birthday, anniversaries)
        allPatterns += detectTemporalPatterns(for: blueprint, date: date)
        
        // Card repetition patterns
        allPatterns += detectCardRepetitions(for: blueprint, since: startDate)
        
        // Elemental convergence
        allPatterns += detectElementalConvergence(for: blueprint, date: date)
        
        // Master number activations
        allPatterns += detectMasterActivations(for: blueprint, date: date)
        
        // Frequency matches
        allPatterns += detectFrequencyMatches(for: blueprint, date: date)
        
        // Cross-system echoes
        allPatterns += detectCrossSystemEchoes(for: blueprint, date: date)
        
        // Calculate significance for each pattern
        let scoredPatterns = allPatterns.map { pattern in
            ScoredPattern(pattern: pattern, score: calculateSignificance(pattern))
        }.sorted { $0.score > $1.score }
        
        // Filter to only significant patterns
        let significantPatterns = scoredPatterns
            .filter { $0.score >= 0.5 }
            .map { $0.pattern }
        
        return SynchronicityReport(
            generatedAt: Date(),
            forDate: date,
            patterns: significantPatterns,
            overallSignificance: calculateOverallSignificance(scoredPatterns),
            topRecommendation: generateTopRecommendation(from: significantPatterns),
            suggestedActions: generateActions(from: significantPatterns)
        )
    }
    
    // MARK: - Specific Pattern Detection
    
    /// Detect when user's core numbers appear in the current date
    func detectNumberPatterns(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        guard let numerology = blueprint.numerologyProfile else {
            return patterns
        }
        
        let userNumbers = [
            ("Life Path", numerology.lifePath),
            ("Expression", numerology.expression),
            ("Soul Urge", numerology.soulUrge),
            ("Birthday", numerology.birthday),
            ("Personal Year", numerology.personalYear),
            ("Personal Month", numerology.personalMonth)
        ]
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let yearDigits = year % 100  // Last two digits
        
        // Check each component against user's numbers
        for (name, number) in userNumbers {
            if day == number {
                patterns.append(.dateNumberMatch(
                    userNumber: number,
                    numberName: name,
                    dateComponent: .day,
                    componentValue: day
                ))
            }
            if month == number {
                patterns.append(.dateNumberMatch(
                    userNumber: number,
                    numberName: name,
                    dateComponent: .month,
                    componentValue: month
                ))
            }
            if yearDigits == number || reduceToDigit(year) == number {
                patterns.append(.dateNumberMatch(
                    userNumber: number,
                    numberName: name,
                    dateComponent: .year,
                    componentValue: year
                ))
            }
        }
        
        // Check for repeating digit patterns (11:11, 2:22, etc.)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        if hour == minute {
            patterns.append(.repeatingDigits(
                pattern: "\(hour):\(String(format: "%02d", minute))",
                significance: hour == 11 ? .masterNumber : .standard
            ))
        }
        
        return patterns
    }
    
    /// Detect significant astrological transits
    func detectTransitPatterns(astro: AstrologyProfile, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // This would require actual ephemeris calculations
        // Placeholder for transit types:
        
        // Return patterns
        // patterns.append(.planetaryReturn(planet: .saturn, age: 29))
        // patterns.append(.majorTransit(transiting: .jupiter, natal: .sun, aspect: .conjunction))
        
        return patterns
    }
    
    /// Detect patterns related to birth date and anniversaries
    func detectTemporalPatterns(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day], from: blueprint.birthDate)
        let todayComponents = calendar.dateComponents([.month, .day], from: date)
        
        // Exact birthday
        if birthComponents.month == todayComponents.month &&
           birthComponents.day == todayComponents.day {
            patterns.append(.birthdaySolarReturn)
        }
        
        // Half birthday
        let halfBirthdayMonth = ((birthComponents.month ?? 1) + 6) % 12
        if halfBirthdayMonth == todayComponents.month &&
           birthComponents.day == todayComponents.day {
            patterns.append(.halfBirthday)
        }
        
        // Personal new year (birth month)
        if birthComponents.month == todayComponents.month && todayComponents.day == 1 {
            patterns.append(.personalNewYear)
        }
        
        return patterns
    }
    
    /// Detect when the same cards appear repeatedly
    func detectCardRepetitions(for blueprint: PersonalBlueprint, since: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // This would query the journal/store for card draws
        // and find repetitions within the lookback period
        
        return patterns
    }
    
    /// Detect when all systems point to the same element
    func detectElementalConvergence(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // Collect elemental data from all active systems
        var elementCounts: [Element: [String]] = [:]
        
        // From numerology
        if let num = blueprint.numerologyProfile {
            if let corr = CorrespondenceMatrix.shared.findByNumber(num.lifePath) {
                elementCounts[corr.element, default: []].append("Numerology (Life Path)")
            }
        }
        
        // From elemental profile
        if let elemental = blueprint.elementalProfile,
           let dominant = elemental.dominant {
            elementCounts[dominant, default: []].append("Elemental Profile")
        }
        
        // Check for convergence (3+ systems on same element)
        for (element, systems) in elementCounts where systems.count >= 3 {
            patterns.append(.elementalConvergence(
                element: element,
                systems: systems,
                strength: systems.count >= 5 ? .master : .strong
            ))
        }
        
        return patterns
    }
    
    /// Detect master number (11, 22, 33) activations
    func detectMasterActivations(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        guard let numerology = blueprint.numerologyProfile else {
            return patterns
        }
        
        let masterNumbers = [
            ("Life Path", numerology.lifePath),
            ("Expression", numerology.expression),
            ("Soul Urge", numerology.soulUrge)
        ].filter { [11, 22, 33].contains($0.1) }
        
        for (name, number) in masterNumbers {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            
            // Master number appears in date
            if day == number || month == number {
                patterns.append(.masterNumberActivation(
                    masterNumber: number,
                    location: name,
                    trigger: day == number ? "day" : "month"
                ))
            }
        }
        
        return patterns
    }
    
    /// Detect when current frequencies match personal frequencies
    func detectFrequencyMatches(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // This would compare the day's frequency (from numerology/astrology)
        // with the user's personal frequency profile
        
        return patterns
    }
    
    /// Detect when the same value appears across multiple systems
    func detectCrossSystemEchoes(for blueprint: PersonalBlueprint, date: Date) -> [SynchronicityPattern] {
        var patterns: [SynchronicityPattern] = []
        
        // Gather values from all profiles
        var valueMap: [String: [(String, String)]] = [:]  // value: [(system, context)]
        
        // Numerology numbers
        if let num = blueprint.numerologyProfile {
            valueMap["\(num.lifePath)", default: []].append(("Numerology", "Life Path"))
            valueMap["\(num.expression)", default: []].append(("Numerology", "Expression"))
            valueMap["\(num.soulUrge)", default: []].append(("Numerology", "Soul Urge"))
        }
        
        // Find echoes (same value, different systems/contexts)
        for (value, occurrences) in valueMap where occurrences.count > 1 {
            let systems = occurrences.map { $0.0 }
            let contexts = occurrences.map { $0.1 }
            
            patterns.append(.crossSystemEcho(
                value: value,
                systems: systems,
                contexts: contexts
            ))
        }
        
        return patterns
    }
    
    // MARK: - Significance Calculation
    
    private func calculateSignificance(_ pattern: SynchronicityPattern) -> Double {
        var score = 0.0
        
        switch pattern {
        case .dateNumberMatch(_, _, _, _):
            score = 0.7  // Calendar alignment is significant
            
        case .repeatingDigits(_, let significance):
            score = significance == .masterNumber ? 0.9 : 0.6
            
        case .planetaryReturn(let planet, let age):
            // Saturn return at 29 is major
            if planet == .saturn && age == 29 {
                score = 1.0
            } else {
                score = 0.8
            }
            
        case .majorTransit(_, _, let aspect):
            switch aspect {
            case .conjunction: score = 0.9
            case .opposition: score = 0.8
            case .square: score = 0.7
            case .trine: score = 0.6
            case .sextile: score = 0.5
            default: score = 0.4
            }
            
        case .birthdaySolarReturn:
            score = 1.0  // Major life marker
            
        case .halfBirthday:
            score = 0.5
            
        case .personalNewYear:
            score = 0.7
            
        case .cardRepetition(_, let count):
            score = min(0.5 + (Double(count) * 0.1), 1.0)
            
        case .elementalConvergence(_, _, let strength):
            switch strength {
            case .subtle: score = 0.3
            case .moderate: score = 0.5
            case .strong: score = 0.8
            case .master: score = 1.0
            }
            
        case .masterNumberActivation(let number, _, _):
            // 33 is highest
            score = 0.7 + (Double(number) / 100.0)
            
        case .frequencyMatch(_, let matchType):
            switch matchType {
            case .exact: score = 0.9
            case .harmonic: score = 0.6
            case .resonant: score = 0.4
            }
            
        case .crossSystemEcho(_, let systems, _):
            score = 0.5 + (Double(systems.count) * 0.1)
        }
        
        return min(score, 1.0)
    }
    
    private func calculateOverallSignificance(_ patterns: [ScoredPattern]) -> OverallSignificance {
        guard !patterns.isEmpty else { return .quiet }
        
        let averageScore = patterns.map(\.score).reduce(0, +) / Double(patterns.count)
        let maxScore = patterns.map(\.score).max() ?? 0
        let count = patterns.filter { $0.score >= 0.5 }.count
        
        // Calculate based on multiple factors
        if maxScore >= 0.9 && count >= 3 {
            return .transformational
        } else if maxScore >= 0.8 || count >= 5 {
            return .highlySignificant
        } else if maxScore >= 0.6 || count >= 3 {
            return .significant
        } else if averageScore >= 0.4 {
            return .moderate
        } else {
            return .subtle
        }
    }
    
    private func generateTopRecommendation(from patterns: [SynchronicityPattern]) -> String {
        guard let topPattern = patterns.first else {
            return "Stay present and open to the day's energies."
        }
        
        switch topPattern {
        case .dateNumberMatch(let number, _, _, _):
            return "Your number \(number) is highlighted today. Pay attention to synchronicities and trust your intuition."
            
        case .birthdaySolarReturn:
            return "Happy Solar Return! This is your personal new year. Set intentions for the year ahead."
            
        case .masterNumberActivation(let number, _, _):
            return "Master Number \(number) is activated. Your spiritual sensitivity is heightened—meditate and journal."
            
        case .elementalConvergence(let element, _, _):
            return "Strong \(element.rawValue) energy surrounds you. Work with this element for maximum effect."
            
        default:
            return "The universe is speaking through patterns today. Notice the connections."
        }
    }
    
    private func generateActions(from patterns: [SynchronicityPattern]) -> [String] {
        return patterns.prefix(3).map { pattern in
            switch pattern {
            case .dateNumberMatch(let number, _, _, _):
                return "Journal about the significance of \(number) in your life"
            case .birthdaySolarReturn:
                return "Write intentions for your new solar year"
            case .masterNumberActivation:
                return "Practice grounding to handle heightened energy"
            case .elementalConvergence(let element, _, _):
                return "Connect with the \(element.rawValue) element today"
            default:
                return "Meditate on the patterns you're noticing"
            }
        }
    }
    
    // MARK: - Helpers
    
    private func reduceToDigit(_ number: Int) -> Int {
        var n = number
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
}

// MARK: - Synchronicity Pattern Types

enum SynchronicityPattern {
    // Number patterns
    case dateNumberMatch(userNumber: Int, numberName: String, dateComponent: DateComponent, componentValue: Int)
    case repeatingDigits(pattern: String, significance: DigitSignificance)
    
    // Astrological patterns
    case planetaryReturn(planet: Planet, age: Int)
    case majorTransit(transiting: Planet, natal: Planet, aspect: AspectType)
    
    // Temporal patterns
    case birthdaySolarReturn
    case halfBirthday
    case personalNewYear
    
    // Card patterns
    case cardRepetition(cardIdentifier: String, count: Int)
    
    // Elemental patterns
    case elementalConvergence(element: Element, systems: [String], strength: ConvergenceStrength)
    
    // Master number patterns
    case masterNumberActivation(masterNumber: Int, location: String, trigger: String)
    
    // Frequency patterns
    case frequencyMatch(frequency: Double, matchType: FrequencyMatchType)
    
    // Cross-system patterns
    case crossSystemEcho(value: String, systems: [String], contexts: [String])
    
    enum DateComponent {
        case day
        case month
        case year
    }
    
    enum DigitSignificance {
        case standard
        case masterNumber
        case angelNumber
    }
    
    enum ConvergenceStrength {
        case subtle
        case moderate
        case strong
        case master
    }
    
    enum FrequencyMatchType {
        case exact
        case harmonic
        case resonant
    }
}

// MARK: - Supporting Types

struct ScoredPattern {
    let pattern: SynchronicityPattern
    let score: Double
}

struct SynchronicityReport {
    let generatedAt: Date
    let forDate: Date
    let patterns: [SynchronicityPattern]
    let overallSignificance: OverallSignificance
    let topRecommendation: String
    let suggestedActions: [String]
    
    var hasSignificantPatterns: Bool {
        overallSignificance != .quiet && overallSignificance != .subtle
    }
}

enum OverallSignificance: String {
    case quiet = "Quiet"                   // No significant patterns
    case subtle = "Subtle"                 // Light patterns
    case moderate = "Moderate"             // Some patterns
    case significant = "Significant"       // Clear patterns
    case highlySignificant = "High"        // Strong patterns
    case transformational = "Transformational" // Major alignment
    
    var color: String {
        switch self {
        case .quiet: return "gray"
        case .subtle: return "blue"
        case .moderate: return "green"
        case .significant: return "orange"
        case .highlySignificant: return "purple"
        case .transformational: return "red"
        }
    }
    
    var description: String {
        switch self {
        case .quiet:
            return "A peaceful day for steady progress"
        case .subtle:
            return "Gentle patterns are emerging—stay observant"
        case .moderate:
            return "Multiple energies are aligning"
        case .significant:
            return "Important synchronicities are present"
        case .highlySignificant:
            return "Major patterns are active—pay close attention"
        case .transformational:
            return "Transformational energy surrounds you"
        }
    }
}

// MARK: - Extensions

extension SynchronicityPattern: CustomStringConvertible {
    var description: String {
        switch self {
        case .dateNumberMatch(let number, let name, let component, let value):
            return "Your \(name) (\(number)) appears in today's \(component) (\(value))"
            
        case .repeatingDigits(let pattern, _):
            return "Repeating pattern: \(pattern)"
            
        case .planetaryReturn(let planet, let age):
            return "\(planet.rawValue) return at age \(age)"
            
        case .majorTransit(let transiting, let natal, let aspect):
            return "\(transiting.rawValue) \(aspect.rawValue) your natal \(natal.rawValue)"
            
        case .birthdaySolarReturn:
            return "Solar Return - Your personal new year"
            
        case .halfBirthday:
            return "Half-birthday milestone"
            
        case .personalNewYear:
            return "Personal new year begins"
            
        case .cardRepetition(let card, let count):
            return "\(card) has appeared \(count) times recently"
            
        case .elementalConvergence(let element, let systems, _):
            return "\(element.rawValue) converges across \(systems.joined(separator: ", "))"
            
        case .masterNumberActivation(let number, let location, _):
            return "Master Number \(number) (\(location)) is activated"
            
        case .frequencyMatch(let freq, let type):
            return "\(type) frequency match at \(Int(freq))Hz"
            
        case .crossSystemEcho(let value, let systems, _):
            return "Value '\(value)' echoes across \(systems.joined(separator: ", "))"
        }
    }
}
