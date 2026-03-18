//
//  CompatibilityEngine.swift
//  Advanced numerology compatibility matching
//

import Foundation

class CompatibilityEngine {
    static let shared = CompatibilityEngine()
    
    private init() {}
    
    // MARK: - Core Numbers Calculation
    
    func calculateFullChart(for birthDate: Date, fullName: String) -> NumerologyChart {
        let lifePath = calculateLifePath(from: birthDate)
        let expression = calculateExpression(from: fullName)
        let soulUrge = calculateSoulUrge(from: fullName)
        let personality = calculatePersonality(from: fullName)
        let birthday = calculateBirthday(from: birthDate)
        let maturity = calculateMaturity(lifePath: lifePath, expression: expression)
        
        // Challenge numbers
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
            fullName: fullName
        )
    }
    
    // MARK: - Compatibility Analysis
    
    func calculateCompatibility(between chart1: NumerologyChart, and chart2: NumerologyChart) -> CompatibilityReport {
        // Life Path compatibility (most important)
        let lifePathScore = calculateLifePathCompatibility(chart1.lifePath, chart2.lifePath)
        
        // Expression compatibility (communication)
        let expressionScore = calculateExpressionCompatibility(chart1.expression, chart2.expression)
        
        // Soul Urge compatibility (heart's desire)
        let soulUrgeScore = calculateSoulUrgeCompatibility(chart1.soulUrge, chart2.soulUrge)
        
        // Personality compatibility (surface attraction)
        let personalityScore = calculatePersonalityCompatibility(chart1.personality, chart2.personality)
        
        // Birthday compatibility (special connection)
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
            advice: generateAdvice(chart1: chart1, chart2: chart2)
        )
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
    
    // MARK: - Private Calculations
    
    private func calculateLifePath(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        let day = reduceToSingleDigit(components.day ?? 1, allowMasters: true)
        let month = reduceToSingleDigit(components.month ?? 1, allowMasters: true)
        let year = reduceToSingleDigit(components.year ?? 2000, allowMasters: true)
        
        return reduceToSingleDigit(day + month + year, allowMasters: true)
    }
    
    private func calculateExpression(from name: String) -> Int {
        let sum = name.uppercased().reduce(0) { sum, char in
            sum + letterValue(char, usePythagorean: true)
        }
        return reduceToSingleDigit(sum, allowMasters: true)
    }
    
    private func calculateSoulUrge(from name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased().reduce(0) { sum, char in
            vowels.contains(char) ? sum + letterValue(char, usePythagorean: true) : sum
        }
        return reduceToSingleDigit(sum, allowMasters: true)
    }
    
    private func calculatePersonality(from name: String) -> Int {
        let vowels = "AEIOU"
        let sum = name.uppercased().reduce(0) { sum, char in
            !vowels.contains(char) && char.isLetter ? sum + letterValue(char, usePythagorean: true) : sum
        }
        return reduceToSingleDigit(sum, allowMasters: false)
    }
    
    private func calculateBirthday(from birthDate: Date) -> Int {
        let day = Calendar.current.component(.day, from: birthDate)
        return reduceToSingleDigit(day, allowMasters: true)
    }
    
    private func calculateMaturity(lifePath: Int, expression: Int) -> Int {
        return reduceToSingleDigit(lifePath + expression, allowMasters: true)
    }
    
    private func calculateChallenge1(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day, .month], from: birthDate)
        return abs(reduceToSingleDigit(components.day ?? 1) - reduceToSingleDigit(components.month ?? 1))
    }
    
    private func calculateChallenge2(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day, .year], from: birthDate)
        return abs(reduceToSingleDigit(components.day ?? 1) - reduceToSingleDigit(components.year ?? 2000))
    }
    
    private func calculateChallenge3(from birthDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.month, .year], from: birthDate)
        return abs(reduceToSingleDigit(components.month ?? 1) - reduceToSingleDigit(components.year ?? 2000))
    }
    
    private func calculateChallenge4(from birthDate: Date) -> Int {
        let c1 = calculateChallenge1(from: birthDate)
        let c2 = calculateChallenge2(from: birthDate)
        return abs(c1 - c2)
    }
    
    private func calculatePinnacles(from birthDate: Date) -> [Pinnacle] {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: birthDate)
        let m = reduceToSingleDigit(components.month ?? 1)
        let d = reduceToSingleDigit(components.day ?? 1)
        let y = reduceToSingleDigit(components.year ?? 2000)
        
        return [
            Pinnacle(number: reduceToSingleDigit(m + d), ageStart: 0, ageEnd: 35),
            Pinnacle(number: reduceToSingleDigit(d + y), ageStart: 36, ageEnd: 44),
            Pinnacle(number: reduceToSingleDigit(m + y), ageStart: 45, ageEnd: 53),
            Pinnacle(number: reduceToSingleDigit(m + d + y), ageStart: 54, ageEnd: nil)
        ]
    }
    
    private func calculatePersonalYear(from birthDate: Date) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: today)
        
        var targetYear = currentYear
        let thisYearBirthday = calendar.date(from: DateComponents(year: currentYear, month: birthComponents.month, day: birthComponents.day))!
        
        if today < thisYearBirthday {
            targetYear -= 1
        }
        
        let sum = (birthComponents.month ?? 1) + (birthComponents.day ?? 1) + reduceToSingleDigit(targetYear)
        return reduceToSingleDigit(sum, allowMasters: true)
    }
    
    private func calculatePersonalMonth(from birthDate: Date) -> Int {
        let personalYear = calculatePersonalYear(from: birthDate)
        let currentMonth = Calendar.current.component(.month, from: Date())
        return reduceToSingleDigit(personalYear + currentMonth, allowMasters: true)
    }
    
    private func calculatePersonalDay(from birthDate: Date) -> Int {
        let personalMonth = calculatePersonalMonth(from: birthDate)
        let currentDay = Calendar.current.component(.day, from: Date())
        return reduceToSingleDigit(personalMonth + currentDay, allowMasters: true)
    }
    
    // MARK: - Compatibility Scoring
    
    private func calculateLifePathCompatibility(_ n1: Int, _ n2: Int) -> Double {
        let compatiblePairs: [(Int, Int)] = [
            (1, 5), (1, 7), (1, 9),
            (2, 4), (2, 6), (2, 8),
            (3, 1), (3, 5), (3, 7), (3, 9),
            (4, 2), (4, 6), (4, 8),
            (5, 1), (5, 3), (5, 7), (5, 9),
            (6, 2), (6, 4), (6, 8),
            (7, 1), (7, 3), (7, 5), (7, 9),
            (8, 2), (8, 4), (8, 6),
            (9, 1), (9, 3), (9, 5), (9, 7)
        ]
        
        if n1 == n2 { return 0.85 } // Same number
        if compatiblePairs.contains(where: { ($0 == n1 && $1 == n2) || ($0 == n2 && $1 == n1) }) {
            return 0.90
        }
        return 0.50
    }
    
    private func calculateExpressionCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Similar logic with emphasis on communication
        return calculateLifePathCompatibility(n1, n2) * 0.95
    }
    
    private func calculateSoulUrgeCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Heart connection
        return calculateLifePathCompatibility(n1, n2) * 0.90
    }
    
    private func calculatePersonalityCompatibility(_ n1: Int, _ n2: Int) -> Double {
        // Surface attraction - more flexible
        return 0.60 + (Double(abs(n1 - n2)) / 10.0)
    }
    
    private func calculateBirthdayCompatibility(_ n1: Int, _ n2: Int) -> Double {
        return n1 == n2 ? 1.0 : 0.70
    }
    
    // MARK: - Helper Functions
    
    private func reduceToSingleDigit(_ number: Int, allowMasters: Bool = false) -> Int {
        var n = number
        while n > 9 {
            if allowMasters && (n == 11 || n == 22 || n == 33) {
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
    
    private func letterValue(_ char: Character, usePythagorean: Bool) -> Int {
        let pythagorean: [Character: Int] = [
            "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9,
            "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "O": 6, "P": 7, "Q": 8, "R": 9,
            "S": 1, "T": 2, "U": 3, "V": 4, "W": 5, "X": 6, "Y": 7, "Z": 8
        ]
        return pythagorean[char] ?? 0
    }
    
    // MARK: - Report Generation
    
    private func generateCompatibilityInsights(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        var insights: [String] = []
        
        // Life Path insight
        insights.append("Your Life Paths (\(chart1.lifePath) & \(chart2.lifePath)) suggest \(relationshipDynamic(chart1.lifePath, chart2.lifePath))")
        
        // Expression insight
        insights.append("Communication flows \(communicationStyle(chart1.expression, chart2.expression)) between you")
        
        // Soul Urge insight
        insights.append("At the heart level, you both seek \(sharedDesires(chart1.soulUrge, chart2.soulUrge))")
        
        return insights
    }
    
    private func determineRelationshipType(lifePath1: Int, lifePath2: Int) -> RelationshipType {
        if lifePath1 == lifePath2 { return .mirror }
        if abs(lifePath1 - lifePath2) == 1 { return .consecutive }
        if lifePath1 + lifePath2 == 10 { return .complementary }
        if [11, 22, 33].contains(lifePath1) || [11, 22, 33].contains(lifePath2) {
            return .masterConnection
        }
        return .harmonious
    }
    
    private func identifyStrengths(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        // Generate based on compatible numbers
        return ["Natural understanding", "Complementary energies", "Shared growth path"]
    }
    
    private func identifyChallenges(chart1: NumerologyChart, chart2: NumerologyChart) -> [String] {
        // Generate based on challenging combinations
        return ["Different pacing", "Communication styles may clash"]
    }
    
    private func generateAdvice(chart1: NumerologyChart, chart2: NumerologyChart) -> String {
        return "Focus on your shared Life Path goals while respecting each other's individual expression."
    }
    
    private func generateMatchReasons(compatibility: CompatibilityReport, user: QodeXUser, match: QodeXUser) -> [String] {
        var reasons: [String] = []
        
        if compatibility.lifePathScore >= 85 {
            reasons.append("Highly compatible life paths")
        }
        if compatibility.soulUrgeScore >= 80 {
            reasons.append("Deep spiritual connection")
        }
        if match.location == user.location {
            reasons.append("Same location")
        }
        
        return reasons
    }
    
    private func calculateInterestAlignment(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        // Compare interests, topics followed, etc.
        return 0.75
    }
    
    private func calculateActivityMatch(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        // Compare activity patterns
        return 0.80
    }
    
    private func calculateTimezoneCompatibility(_ u1: QodeXUser, _ u2: QodeXUser) -> Double {
        guard let t1 = u1.timezone, let t2 = u2.timezone else { return 0.5 }
        // Calculate overlap in waking hours
        return t1 == t2 ? 1.0 : 0.6
    }
    
    private func relationshipDynamic(_ n1: Int, _ n2: Int) -> String {
        return "a dynamic of mutual growth and understanding"
    }
    
    private func communicationStyle(_ n1: Int, _ n2: Int) -> String {
        return "naturally and with ease"
    }
    
    private func sharedDesires(_ n1: Int, _ n2: Int) -> String {
        return "similar spiritual fulfillment"
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
    
    var compatibilityLevel: String {
        switch overallScore {
        case 90...100: return "Soul Connection"
        case 80..<90: return "Highly Compatible"
        case 70..<80: return "Compatible"
        case 60..<70: return "Moderate"
        default: return "Challenging"
        }
    }
}

enum RelationshipType {
    case mirror
    case consecutive
    case complementary
    case masterConnection
    case harmonious
    
    var description: String {
        switch self {
        case .mirror: return "Mirror Souls"
        case .consecutive: return "Sequential Growth"
        case .complementary: return "Perfect Balance"
        case .masterConnection: return "Master Teacher Connection"
        case .harmonious: return "Harmonious Partners"
        }
    }
}

struct MemberMatch {
    let user: QodeXUser
    let compatibility: CompatibilityReport
    let compositeScore: Int
    let matchReasons: [String]
}
