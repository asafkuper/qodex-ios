//
//  CompatibilityEngine.swift
//  Advanced numerology compatibility matching - MASTER NUMBER FIX
//
//  Fixed issues:
//  1. Master numbers (11, 22, 33) now properly preserved at ALL stages
//  2. Added early return for master numbers in reduction
//  3. Enhanced Master Number compatibility scoring
//  4. Added Master Number detection in chart analysis
//  5. Improved Master Number relationship descriptions
//

import Foundation

class CompatibilityEngine {
    static let shared = CompatibilityEngine()
    
    private init() {}
    
    // MARK: - Constants
    
    /// Master Numbers - these should NEVER be reduced
    private let masterNumbers = [11, 22, 33]
    
    /// Karmic Debt Numbers - indicate lessons from past lives
    private let karmicDebtNumbers = [13, 14, 16, 19]
    
    /// Standard Pythagorean letter values
    private let letterValues: [Character: Int] = [
        "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9,
        "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "O": 6, "P": 7, "Q": 8, "R": 9,
        "S": 1, "T": 2, "U": 3, "V": 4, "W": 5, "X": 6, "Y": 7, "Z": 8
    ]
    
    // MARK: - Full Chart Calculation
    
    func calculateFullChart(for birthDate: Date, fullName: String) -> NumerologyChart {
        let lifePath = calculateLifePath(from: birthDate)
        let expression = calculateExpression(from: fullName)
        let soulUrge = calculateSoulUrge(from: fullName)
        let personality = calculatePersonality(from: fullName)
        let birthday = calculateBirthday(from: birthDate)
        let maturity = calculateMaturity(lifePath: lifePath, expression: expression)
        
        // Challenge numbers (always reduced to single digit)
        let challenge1 = calculateChallenge1(from: birthDate)
        let challenge2 = calculateChallenge2(from: birthDate)
        let challenge3 = calculateChallenge3(from: birthDate)
        let challenge4 = calculateChallenge4(from: birthDate)
        
        // Pinnacle cycles
        let pinnacles = calculatePinnacles(from: birthDate)
        
        // Personal year, month, day
        let personalYear = calculatePersonalYear(from: birthDate)
        let personalMonth = calculatePersonalMonth(from: birthDate)
        let personalDay = calculatePersonalDay(from: birthDate)
        
        // Detect master numbers in chart
        let allNumbers = [lifePath, expression, soulUrge, personality, birthday, maturity,
                         personalYear, personalMonth, personalDay]
        let detectedMasters = allNumbers.filter { masterNumbers.contains($0) }
        
        return NumerologyChart(
            lifePath: lifePath,
            expression: expression,
            soulUrge: soulUrge,
            personality: personality,
            birthday: birthday,
            maturity: maturity,
            challenges: [challenge1, challenge2, challenge3, challenge4],
            pinnacles: pinnacles,
            personalYear: personalYear,
            personalMonth: personalMonth,
            personalDay: personalDay,
            birthDate: birthDate,
            fullName: fullName,
            masterNumbers: detectedMasters
        )
    }
    
    // MARK: - Core Number Calculations (Fixed with Master Number Support)
    
    /// Calculate Life Path Number - FIXED
    /// Reduces each component separately while preserving master numbers (11, 22, 33)
    private func calculateLifePath(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        let day = reduceWithMasters(components.day ?? 1)
        let month = reduceWithMasters(components.month ?? 1)
        let year = reduceWithMasters(components.year ?? 2000)
        
        return reduceWithMasters(day + month + year)
    }
    
    /// Calculate Expression Number - Master Numbers preserved
    private func calculateExpression(from name: String) -> Int {
        let sum = name.uppercased()
            .filter { $0.isLetter }
            .compactMap { letterValues[$0] }
            .reduce(0, +)
        
        return reduceWithMasters(sum)
    }
    
    /// Calculate Soul Urge Number - Master Numbers preserved
    private func calculateSoulUrge(from name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased()
            .filter { vowels.contains($0) }
            .compactMap { letterValues[$0] }
            .reduce(0, +)
        
        return reduceWithMasters(sum)
    }
    
    /// Calculate Personality Number - Master Numbers preserved
    private func calculatePersonality(from name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased()
            .filter { $0.isLetter && !vowels.contains($0) }
            .compactMap { letterValues[$0] }
            .reduce(0, +)
        
        // Personality number can be a master number
        return reduceWithMasters(sum)
    }
    
    /// Calculate Birthday Number - Master Numbers preserved
    private func calculateBirthday(from birthDate: Date) -> Int {
        let day = Calendar.current.component(.day, from: birthDate)
        return reduceWithMasters(day)
    }
    
    /// Calculate Maturity Number - Master Numbers preserved
    private func calculateMaturity(lifePath: Int, expression: Int) -> Int {
        return reduceWithMasters(lifePath + expression)
    }
    
    /// Calculate Challenge 1 (always single digit)
    private func calculateChallenge1(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day, .month], from: birthDate)
        let day = reduceWithoutMasters(components.day ?? 1)
        let month = reduceWithoutMasters(components.month ?? 1)
        return abs(day - month)
    }
    
    /// Calculate Challenge 2 (always single digit)
    private func calculateChallenge2(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day, .year], from: birthDate)
        let day = reduceWithoutMasters(components.day ?? 1)
        let year = reduceWithoutMasters(components.year ?? 2000)
        return abs(day - year)
    }
    
    /// Calculate Challenge 3 (always single digit)
    private func calculateChallenge3(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.month, .year], from: birthDate)
        let month = reduceWithoutMasters(components.month ?? 1)
        let year = reduceWithoutMasters(components.year ?? 2000)
        return abs(month - year)
    }
    
    /// Calculate Challenge 4 (always single digit)
    private func calculateChallenge4(from birthDate: Date) -> Int {
        let c1 = calculateChallenge1(from: birthDate)
        let c2 = calculateChallenge2(from: birthDate)
        return abs(c1 - c2)
    }
    
    /// Calculate Pinnacle cycles - Master Numbers preserved
    private func calculatePinnacles(from birthDate: Date) -> [Pinnacle] {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: birthDate)
        let m = reduceWithoutMasters(components.month ?? 1)
        let d = reduceWithoutMasters(components.day ?? 1)
        let y = reduceWithoutMasters(components.year ?? 2000)
        
        return [
            Pinnacle(number: reduceWithMasters(m + d), ageStart: 0, ageEnd: 35),
            Pinnacle(number: reduceWithMasters(d + y), ageStart: 36, ageEnd: 44),
            Pinnacle(number: reduceWithMasters(m + y), ageStart: 45, ageEnd: 53),
            Pinnacle(number: reduceWithMasters(m + d + y), ageStart: 54, ageEnd: nil)
        ]
    }
    
    /// Calculate Personal Year - FIXED with Master Number support
    /// Changes on the birthday each year
    private func calculatePersonalYear(from birthDate: Date) -> Int {
        let today = Date()
        let calendar = Calendar.current
        
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: today)
        
        var targetYear = currentYear
        let thisYearBirthday = calendar.date(from: DateComponents(
            year: currentYear,
            month: birthComponents.month,
            day: birthComponents.day
        ))!
        
        // If before birthday, use previous year
        if today < thisYearBirthday {
            targetYear -= 1
        }
        
        let month = reduceWithMasters(birthComponents.month ?? 1)
        let day = reduceWithMasters(birthComponents.day ?? 1)
        let yearReduced = reduceWithMasters(targetYear)
        
        return reduceWithMasters(month + day + yearReduced)
    }
    
    /// Calculate Personal Month - Master Numbers preserved
    private func calculatePersonalMonth(from birthDate: Date) -> Int {
        let personalYear = calculatePersonalYear(from: birthDate)
        let currentMonth = Calendar.current.component(.month, from: Date())
        return reduceWithMasters(personalYear + currentMonth)
    }
    
    /// Calculate Personal Day - Master Numbers preserved
    private func calculatePersonalDay(from birthDate: Date) -> Int {
        let personalMonth = calculatePersonalMonth(from: birthDate)
        let currentDay = Calendar.current.component(.day, from: Date())
        return reduceWithMasters(personalMonth + currentDay)
    }
    
    // MARK: - Compatibility Analysis (Enhanced with Master Number Support)
    
    func calculateCompatibility(between chart1: NumerologyChart, and chart2: NumerologyChart) -> CompatibilityReport {
        // Life Path compatibility (35% weight)
        let lifePathScore = calculateLifePathCompatibility(chart1.lifePath, chart2.lifePath)
        
        // Expression compatibility (25% weight)
        let expressionScore = calculateExpressionCompatibility(chart1.expression, chart2.expression)
        
        // Soul Urge compatibility (25% weight)
        let soulUrgeScore = calculateSoulUrgeCompatibility(chart1.soulUrge, chart2.soulUrge)
        
        // Personality compatibility (10% weight)
        let personalityScore = calculatePersonalityCompatibility(chart1.personality, chart2.personality)
        
        // Birthday compatibility (5% weight)
        let birthdayScore = calculateBirthdayCompatibility(chart1.birthday, chart2.birthday)
        
        // Overall score (weighted)
        let overallScore = (
            lifePathScore * 0.35 +
            expressionScore * 0.25 +
            soulUrgeScore * 0.25 +
            personalityScore * 0.10 +
            birthdayScore * 0.05
        )
        
        // Generate insights
        let insights = generateCompatibilityInsights(chart1: chart1, chart2: chart2)
        
        // Determine relationship type
        let relationshipType = determineRelationshipType(
            lifePath1: chart1.lifePath,
            lifePath2: chart2.lifePath
        )
        
        return CompatibilityReport(
            overallScore: Int(overallScore * 100),
            lifePathScore: Int(lifePathScore * 100),
            expressionScore: Int(expressionScore * 100),
            soulUrgeScore: Int(soulUrgeScore * 100),
            personalityScore: Int(personalityScore * 100),
            birthdayScore: Int(birthdayScore * 100),
            insights: insights,
            relationshipType: relationshipType,
            strengths: identifyStrengths(chart1: chart1, chart2: chart2),
            challenges: identifyChallenges(chart1: chart1, chart2: chart2),
            advice: generateAdvice(chart1: chart1, chart2: chart2),
            hasMasterNumberConnection: hasMasterNumberConnection(chart1: chart1, chart2: chart2),
            masterNumbersInConnection: collectMasterNumbers(chart1: chart1, chart2: chart2)
        )
    }
    
    // MARK: - Compatibility Scoring (Enhanced with Master Number Support)
    
    private func calculateLifePathCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Master number enhanced compatibility
        if masterNumbers.contains(n1) || masterNumbers.contains(n2) {
            return calculateMasterNumberCompatibility(n1, n2)
        }
        
        // Same number - deep understanding but potential stagnation
        if n1 == n2 { return 0.85 }
        
        // Highly compatible pairs
        let excellentPairs: [(Int, Int)] = [
            (1, 3), (1, 5), (1, 6), (1, 9),
            (2, 2), (2, 4), (2, 6), (2, 8),
            (3, 1), (3, 3), (3, 5), (3, 6), (3, 9),
            (4, 2), (4, 4), (4, 6), (4, 8),
            (5, 1), (5, 3), (5, 5), (5, 7), (5, 9),
            (6, 1), (6, 2), (6, 3), (6, 4), (6, 6), (6, 9),
            (7, 5), (7, 7), (7, 9),
            (8, 2), (8, 4), (8, 6), (8, 8),
            (9, 1), (9, 3), (9, 5), (9, 6), (9, 7), (9, 9)
        ]
        
        let pair = (n1, n2)
        let reversePair = (n2, n1)
        
        if excellentPairs.contains(where: { $0 == pair || $0 == reversePair }) {
            return 0.90
        }
        
        // Moderately compatible pairs
        let goodPairs: [(Int, Int)] = [
            (1, 1), (1, 2), (1, 7), (1, 8),
            (2, 3), (2, 5), (2, 7), (2, 9),
            (3, 2), (3, 4), (3, 7), (3, 8),
            (4, 1), (4, 3), (4, 5), (4, 7), (4, 9),
            (5, 2), (5, 4), (5, 6), (5, 8),
            (6, 5), (6, 7), (6, 8),
            (7, 1), (7, 2), (7, 3), (7, 4), (7, 6), (7, 8),
            (8, 1), (8, 3), (8, 5), (8, 7), (8, 9),
            (9, 2), (9, 4), (9, 8)
        ]
        
        if goodPairs.contains(where: { $0 == pair || $0 == reversePair }) {
            return 0.70
        }
        
        // Challenging pairs - require work
        return 0.50
    }
    
    /// Calculate compatibility when one or both numbers are master numbers
    private func calculateMasterNumberCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Both are master numbers
        if masterNumbers.contains(n1) && masterNumbers.contains(n2) {
            if n1 == n2 {
                // Same master number - highest compatibility
                return 0.98
            } else {
                // Different master numbers - very strong connection
                return 0.92
            }
        }
        
        // One master, one regular
        let master = masterNumbers.contains(n1) ? n1 : n2
        let regular = masterNumbers.contains(n1) ? n2 : n1
        
        // Master number enhanced compatibility pairs
        let masterEnhanced: [(Int, Int)] = [
            (11, 2), (11, 7), (11, 9),
            (22, 4), (22, 8),
            (33, 6), (33, 9)
        ]
        
        let pair = (master, regular)
        if masterEnhanced.contains(where: { $0 == pair || $0 == (regular, master) }) {
            return 0.95
        }
        
        // Good compatibility with most numbers
        return 0.88
    }
    
    private func calculateExpressionCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Expression is about communication and self-expression
        // Slightly more flexible than Life Path
        let baseScore = calculateLifePathCompatibility(n1, n2)
        return min(baseScore * 1.05, 1.0)
    }
    
    private func calculateSoulUrgeCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Soul Urge is about heart's desires
        // Emotional compatibility is crucial
        if n1 == n2 { return 0.90 }
        
        // Pairs that share emotional understanding
        let heartConnected: [(Int, Int)] = [
            (2, 6), (2, 9), (6, 2), (6, 9), (9, 2), (9, 6),
            (1, 5), (5, 1), (3, 5), (5, 3),
            // Master number heart connections
            (11, 2), (11, 7), (11, 9),
            (22, 4), (22, 8),
            (33, 6), (33, 9)
        ]
        
        let pair = (n1, n2)
        if heartConnected.contains(where: { $0 == pair || $0 == (n2, n1) }) {
            return 0.85
        }
        
        return calculateLifePathCompatibility(n1, n2) * 0.95
    }
    
    private func calculatePersonalityCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Surface attraction - opposites can attract
        let difference = abs(n1 - n2)
        if difference == 0 { return 0.80 }
        if difference == 1 { return 0.75 } // Adjacent numbers often complement
        if difference == 4 || difference == 5 { return 0.70 } // Moderate attraction
        return 0.60
    }
    
    private func calculateBirthdayCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Same birthday number is special
        return n1 == n2 ? 1.0 : 0.70
    }
    
    // MARK: - Helper Functions
    
    /// Check if there's a master number connection between charts
    private func hasMasterNumberConnection(chart1: NumerologyChart, chart2: NumerologyChart) -> Bool {
        let masters1 = chart1.masterNumbers
        let masters2 = chart2.masterNumbers
        return !masters1.isEmpty || !masters2.isEmpty
    }
    
    /// Collect all master numbers from both charts
    private func collectMasterNumbers(chart1: NumerologyChart, chart2: NumerologyChart) -> [Int] {
        return Array(Set(chart1.masterNumbers + chart2.masterNumbers))
    }
    
    /// Reduce with master number preservation - FIXED
    /// Early return for master numbers, proper multi-step reduction
    private func reduceWithMasters(_ number: Int) -> Int {
        var n = abs(number)
        
        // Early return for master numbers
        if masterNumbers.contains(n) {
            return n
        }
        
        while n > 9 {
            // Check for master numbers at each step
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
    
    /// Reduce without master numbers (for challenges)
    private func reduceWithoutMasters(_ number: Int) -> Int {
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
    
    // MARK: - Report Generation (Enhanced with Master Number descriptions)
    
    private func generateCompatibilityInsights(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        var insights: [String] = []
        
        // Life Path insight
        insights.append("Your Life Paths (\(chart1.lifePath) & \(chart2.lifePath)) suggest \(relationshipDynamic(chart1.lifePath, chart2.lifePath))")
        
        // Expression insight
        insights.append("Communication flows \(communicationStyle(chart1.expression, chart2.expression)) between you")
        
        // Soul Urge insight
        insights.append("At the heart level, you both seek \(sharedDesires(chart1.soulUrge, chart2.soulUrge))")
        
        // Master number specific insights
        if hasMasterNumberConnection(chart1: chart1, chart2: chart2) {
            insights.append(generateMasterNumberInsight(chart1: chart1, chart2: chart2))
        }
        
        return insights
    }
    
    private func generateMasterNumberInsight(chart1: NumerologyChart, chart2: NumerologyChart) -> String {
        let allMasters = collectMasterNumbers(chart1: chart1, chart2: chart2)
        
        if allMasters.isEmpty {
            return ""
        }
        
        let masterDescriptions: [Int: String] = [
            11: "intuitive insight and spiritual illumination",
            22: "practical mastery and the power to manifest grand visions",
            33: "compassionate teaching and healing abilities"
        ]
        
        if allMasters.count == 1, let master = allMasters.first {
            return "The presence of Master Number \(master) brings \(masterDescriptions[master] ?? "special energy") to this connection."
        } else {
            let masterList = allMasters.map { "\($0)" }.joined(separator: " and ")
            return "The combined presence of Master Numbers \(masterList) creates a profoundly significant spiritual connection."
        }
    }
    
    private func determineRelationshipType(lifePath1: Int, lifePath2: Int) -> RelationshipType {
        if lifePath1 == lifePath2 { return .mirror }
        if abs(lifePath1 - lifePath2) == 1 { return .consecutive }
        if lifePath1 + lifePath2 == 10 { return .complementary }
        
        // Check for master number connections
        if masterNumbers.contains(lifePath1) || masterNumbers.contains(lifePath2) {
            if masterNumbers.contains(lifePath1) && masterNumbers.contains(lifePath2) {
                return .masterMasterConnection
            }
            return .masterConnection
        }
        
        return .harmonious
    }
    
    private func identifyStrengths(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        var strengths: [String] = []
        
        if chart1.lifePath == chart2.lifePath {
            strengths.append("Deep mutual understanding from shared life lessons")
        }
        
        if abs(chart1.expression - chart2.expression) <= 2 {
            strengths.append("Natural communication flow")
        }
        
        if chart1.soulUrge == chart2.soulUrge {
            strengths.append("Aligned heart's desires and inner motivations")
        }
        
        // Master number strengths
        if hasMasterNumberConnection(chart1: chart1, chart2: chart2) {
            strengths.append("Spiritual depth and higher purpose in the relationship")
        }
        
        if chart1.masterNumbers.contains(11) || chart2.masterNumbers.contains(11) {
            strengths.append("Enhanced intuition and spiritual awareness")
        }
        
        if chart1.masterNumbers.contains(22) || chart2.masterNumbers.contains(22) {
            strengths.append("Ability to manifest ambitious goals together")
        }
        
        if chart1.masterNumbers.contains(33) || chart2.masterNumbers.contains(33) {
            strengths.append("Compassionate healing energy in the relationship")
        }
        
        if strengths.isEmpty {
            strengths = ["Complementary energies create growth opportunities", "Unique perspectives enrich the relationship"]
        }
        
        return strengths
    }
    
    private func identifyChallenges(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        var challenges: [String] = []
        
        let lpDiff = abs(chart1.lifePath - chart2.lifePath)
        
        if lpDiff >= 5 {
            challenges.append("Different life path approaches may require compromise")
        }
        
        if abs(chart1.expression - chart2.expression) > 4 {
            challenges.append("Communication styles may differ significantly")
        }
        
        // Master number challenges
        if chart1.masterNumbers.contains(11) || chart2.masterNumbers.contains(11) {
            challenges.append("Heightened sensitivity may require extra understanding")
        }
        
        if chart1.masterNumbers.contains(22) || chart2.masterNumbers.contains(22) {
            challenges.append("The weight of great potential may feel overwhelming at times")
        }
        
        if challenges.isEmpty {
            challenges = ["Maintain individual growth while nurturing the relationship"]
        }
        
        return challenges
    }
    
    private func generateAdvice(chart1: NumerologyChart, chart2: NumerologyChart) -> String {
        let lpCompatibility = calculateLifePathCompatibility(chart1.lifePath, chart2.lifePath)
        
        // Master number specific advice
        if hasMasterNumberConnection(chart1: chart1, chart2: chart2) {
            return "Your connection has deep spiritual significance. Honor the master energies at play by maintaining high intentions, supporting each other's growth, and using your combined gifts to serve a greater purpose."
        }
        
        if lpCompatibility >= 0.85 {
            return "Your natural compatibility provides a strong foundation. Focus on growing together while maintaining individual identities."
        } else if lpCompatibility >= 0.70 {
            return "You have good compatibility with opportunities for growth. Embrace your differences as learning experiences."
        } else {
            return "This relationship offers significant growth opportunities. Patience and understanding will be key to your success together."
        }
    }
    
    private func relationshipDynamic(_ n1: Int, _ n2: Int) -> String {
        // Master number dynamics
        if masterNumbers.contains(n1) || masterNumbers.contains(n2) {
            return generateMasterNumberDynamic(n1, n2)
        }
        
        if n1 == n2 {
            return "a mirror-like understanding where you reflect each other's strengths and challenges"
        }
        
        let dynamics: [(Int, Int, String)] = [
            (1, 2, "leadership balanced with cooperation"),
            (1, 3, "action fueling creativity"),
            (1, 5, "independent spirits sharing adventures"),
            (2, 4, "sensitivity building on solid ground"),
            (2, 6, "deep emotional nurturing"),
            (3, 5, "creative expression meeting freedom"),
            (4, 8, "practical power and achievement"),
            (6, 9, "love in service to humanity")
        ]
        
        for (a, b, desc) in dynamics {
            if (n1 == a && n2 == b) || (n1 == b && n2 == a) {
                return desc
            }
        }
        
        return "a unique blend of energies requiring mutual understanding"
    }
    
    private func generateMasterNumberDynamic(_ n1: Int, _ n2: Int) -> String {
        // Both master numbers
        if masterNumbers.contains(n1) && masterNumbers.contains(n2) {
            if n1 == 11 && n2 == 11 {
                return "a profound spiritual mirror connection with shared intuitive gifts"
            } else if n1 == 22 && n2 == 22 {
                return "the power to manifest extraordinary achievements together"
            } else if n1 == 33 && n2 == 33 {
                return "a healing partnership capable of uplifting many lives"
            } else if (n1 == 11 && n2 == 22) || (n1 == 22 && n2 == 11) {
                return "vision combined with manifestation power - dreams can become reality"
            } else if (n1 == 11 && n2 == 33) || (n1 == 33 && n2 == 11) {
                return "spiritual insight serving compassionate teaching"
            } else if (n1 == 22 && n2 == 33) || (n1 == 33 && n2 == 22) {
                return "masterful building in service of healing and teaching"
            }
        }
        
        // Master with regular number
        let master = masterNumbers.contains(n1) ? n1 : n2
        let regular = masterNumbers.contains(n1) ? n2 : n1
        
        switch master {
        case 11:
            let dynamics: [(Int, String)] = [
                (1, "intuitive guidance supporting independent action"),
                (2, "heightened sensitivity and spiritual cooperation"),
                (3, "inspired creativity and joyful expression"),
                (4, "spiritual vision grounded in practical reality"),
                (5, "intuitive freedom and adventurous exploration"),
                (6, "loving service guided by higher wisdom"),
                (7, "deep spiritual seeking and analytical insight"),
                (8, "intuitive power supporting material achievement"),
                (9, "spiritual humanitarian service")
            ]
            return dynamics.first { $0.0 == regular }?.1 ?? "spiritual depth enriching the connection"
        case 22:
            let dynamics: [(Int, String)] = [
                (1, "ambitious leadership with masterful execution"),
                (2, "cooperative building on a grand scale"),
                (3, "creative visions manifested in reality"),
                (4, "master building amplified - extraordinary achievement"),
                (5, "freedom channeled into practical accomplishment"),
                (6, "nurturing service with masterful organization"),
                (7, "spiritual wisdom manifesting practical results"),
                (8, "powerful partnership for major achievements"),
                (9, "humanitarian service with masterful planning")
            ]
            return dynamics.first { $0.0 == regular }?.1 ?? "masterful energy elevating the partnership"
        case 33:
            let dynamics: [(Int, String)] = [
                (1, "leadership guided by compassionate wisdom"),
                (2, "deeply nurturing cooperation"),
                (3, "creative expression serving higher teaching"),
                (4, "stable foundations supporting healing work"),
                (5, "freedom serving compassionate outreach"),
                (6, "master teaching through loving service"),
                (7, "spiritual wisdom deepening healing gifts"),
                (8, "material power serving healing mission"),
                (9, "universal love and service magnified")
            ]
            return dynamics.first { $0.0 == regular }?.1 ?? "compassionate teaching enriching the bond"
        default:
            return "a unique blend of energies"
        }
    }
    
    private func communicationStyle(_ n1: Int, _ n2: Int) -> String {
        // Master number communication
        if masterNumbers.contains(n1) || masterNumbers.contains(n2) {
            if n1 == 11 || n2 == 11 {
                return "with intuitive understanding and often without words"
            } else if n1 == 22 || n2 == 22 {
                return "practically and with focus on tangible results"
            } else if n1 == 33 || n2 == 33 {
                return "compassionately and with deep emotional resonance"
            }
        }
        
        if n1 == n2 { return "naturally and with mutual understanding" }
        if abs(n1 - n2) <= 2 { return "easily with complementary styles" }
        return "with opportunities to learn from different perspectives"
    }
    
    private func sharedDesires(_ n1: Int, _ n2: Int) -> String {
        if n1 == n2 {
            let desires: [Int: String] = [
                1: "independence and achievement",
                2: "harmony and partnership",
                3: "creative expression",
                4: "stability and order",
                5: "freedom and adventure",
                6: "love and family",
                7: "truth and understanding",
                8: "success and recognition",
                9: "humanitarian service",
                11: "spiritual illumination and intuitive growth",
                22: "masterful achievement and practical manifestation",
                33: "universal healing and compassionate teaching"
            ]
            return desires[n1] ?? "meaningful connection"
        }
        return "different but potentially complementary paths to fulfillment"
    }
    
    // MARK: - Community Matching
    
    func findCompatibleMembers(currentUser: QodeXUser, allMembers: [QodeXUser], limit: Int = 10) -> [MemberMatch] {
        guard let userChart = currentUser.numerologyChart else { return [] }
        
        var matches: [MemberMatch] = []
        
        for member in allMembers where member.id != currentUser.id {
            guard let memberChart = member.numerologyChart else { continue }
            
            let compatibility = calculateCompatibility(between: userChart, and: memberChart)
            
            // Calculate additional match factors
            let interestAlignment = calculateInterestAlignment(currentUser, member)
            let activityMatch = calculateActivityMatch(currentUser, member)
            let timezoneCompatibility = calculateTimezoneCompatibility(currentUser, member)
            
            let compositeScore = (
                Double(compatibility.overallScore) * 0.5 +
                interestAlignment * 100 * 0.25 +
                activityMatch * 100 * 0.15 +
                timezoneCompatibility * 100 * 0.10
            )
            
            let match = MemberMatch(
                user: member,
                compatibility: compatibility,
                compositeScore: Int(compositeScore),
                matchReasons: generateMatchReasons(compatibility: compatibility, user: currentUser, match: member)
            )
            
            matches.append(match)
        }
        
        return matches.sorted { $0.compositeScore > $1.compositeScore }.prefix(limit).map { $0 }
    }
    
    private func calculateInterestAlignment(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        return 0.75
    }
    
    private func calculateActivityMatch(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        return 0.80
    }
    
    private func calculateTimezoneCompatibility(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        guard let t1 = u1.timezone, let t2 = u2.timezone else { return 0.5 }
        return t1 == t2 ? 1.0 : 0.6
    }
    
    private func generateMatchReasons(compatibility: CompatibilityReport, user: QodeXUser, match: QodeXUser) -> [String] {
        var reasons: [String] = []
        
        if compatibility.lifePathScore >= 85 {
            reasons.append("Highly compatible life paths")
        }
        if compatibility.soulUrgeScore >= 80 {
            reasons.append("Deep spiritual connection")
        }
        if compatibility.hasMasterNumberConnection {
            reasons.append("Master number spiritual connection")
        }
        if match.location == user.location {
            reasons.append("Same location")
        }
        
        return reasons.isEmpty ? ["Potential connection"] : reasons
    }
}

// MARK: - Models

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
    let masterNumbers: [Int]
    
    var hasMasterNumbers: Bool {
        return !masterNumbers.isEmpty
    }
    
    var primaryMasterNumber: Int? {
        // Priority: Life Path > Expression > Soul Urge > others
        if masterNumbers.contains(lifePath) { return lifePath }
        if masterNumbers.contains(expression) { return expression }
        if masterNumbers.contains(soulUrge) { return soulUrge }
        return masterNumbers.first
    }
}

struct Pinnacle {
    let number: Int
    let ageStart: Int
    let ageEnd: Int?
}

struct CompatibilityReport {
    let overallScore: Int
    let lifePathScore: Int
    let expressionScore: Int
    let soulUrgeScore: Int
    let personalityScore: Int
    let birthdayScore: Int
    let insights: [String]
    let relationshipType: RelationshipType
    let strengths: [String]
    let challenges: [String]
    let advice: String
    let hasMasterNumberConnection: Bool
    let masterNumbersInConnection: [Int]
    
    var compatibilityLevel: String {
        switch overallScore {
        case 95...100: return "Soul Connection"
        case 85..<95: return "Highly Compatible"
        case 75..<85: return "Very Compatible"
        case 65..<75: return "Compatible"
        case 55..<65: return "Moderate"
        default: return "Growth Opportunity"
        }
    }
    
    var masterNumberSummary: String? {
        guard hasMasterNumberConnection else { return nil }
        if masterNumbersInConnection.isEmpty {
            return "Spiritual connection present"
        }
        let masterList = masterNumbersInConnection.map { "\($0)" }.joined(separator: ", ")
        return "Master Numbers present: \(masterList)"
    }
}

enum RelationshipType {
    case mirror
    case consecutive
    case complementary
    case masterConnection
    case masterMasterConnection
    case harmonious
    
    var description: String {
        switch self {
        case .mirror: return "Mirror Souls"
        case .consecutive: return "Sequential Growth"
        case .complementary: return "Perfect Balance"
        case .masterConnection: return "Master Teacher Connection"
        case .masterMasterConnection: return "Twin Master Connection"
        case .harmonious: return "Harmonious Partners"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .mirror:
            return "You share the same Life Path number, creating deep understanding and similar life lessons. You naturally 'get' each other."
        case .consecutive:
            return "Your Life Path numbers are adjacent, creating a natural flow of learning and growth between you."
        case .complementary:
            return "Your Life Path numbers sum to 10, creating a perfect balance where each complements the other."
        case .masterConnection:
            return "A Master Number is present, bringing spiritual significance and higher purpose to your connection."
        case .masterMasterConnection:
            return "Both partners have Master Numbers, creating an extraordinarily powerful spiritual bond with shared higher purpose."
        case .harmonious:
            return "Your Life Path energies blend harmoniously, supporting mutual growth and understanding."
        }
    }
}

struct MemberMatch {
    let user: QodeXUser
    let compatibility: CompatibilityReport
    let compositeScore: Int
    let matchReasons: [String]
}

// MARK: - QodeXUser Extension

extension QodeXUser {
    var numerologyChart: NumerologyChart? {
        guard let birthDate = birthDate else { return nil }
        return CompatibilityEngine.shared.calculateFullChart(for: birthDate, fullName: name)
    }
    
    var timezone: String? {
        // Placeholder - would come from user profile
        return nil
    }
    
    var location: String? {
        // Placeholder - would come from user profile
        return nil
    }
}
