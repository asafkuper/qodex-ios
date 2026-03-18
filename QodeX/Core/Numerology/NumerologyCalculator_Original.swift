//
//  NumerologyCalculator.swift
//  Core numerology calculation engine
//

import Foundation

class NumerologyCalculator {
    static let shared = NumerologyCalculator()
    
    // MARK: - Life Path Number
    func calculateLifePathNumber(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)
        
        let year = reduceToDigit(components.year ?? 0)
        let month = reduceToDigit(components.month ?? 0)
        let day = reduceToDigit(components.day ?? 0)
        
        let sum = year + month + day
        let result = reduceToSingleDigit(sum)
        
        // Check for master numbers
        if [11, 22, 33].contains(sum) {
            return sum
        }
        
        return result
    }
    
    // MARK: - Expression Number (from name)
    func calculateExpressionNumber(name: String) -> Int {
        let sum = name.uppercased()
            .filter { $0.isLetter }
            .compactMap { letterToNumber($0) }
            .reduce(0, +)
        
        return reduceToSingleDigit(sum)
    }
    
    // MARK: - Soul Urge Number (from vowels)
    func calculateSoulUrgeNumber(name: String) -> Int {
        let vowels = CharacterSet(charactersIn: "AEIOU")
        let sum = name.uppercased()
            .filter { $0.unicodeScalars.allSatisfy { vowels.contains($0) } }
            .compactMap { letterToNumber($0) }
            .reduce(0, +)
        
        return reduceToSingleDigit(sum)
    }
    
    // MARK: - Personality Number (from consonants)
    func calculatePersonalityNumber(name: String) -> Int {
        let vowels = CharacterSet(charactersIn: "AEIOU")
        let sum = name.uppercased()
            .filter { $0.isLetter && !$0.unicodeScalars.allSatisfy { vowels.contains($0) } }
            .compactMap { letterToNumber($0) }
            .reduce(0, +)
        
        return reduceToSingleDigit(sum)
    }
    
    // MARK: - Daily Number
    func calculateDailyNumber(for date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2024
        
        let sum = day + month + reduceToDigit(year)
        return reduceToSingleDigit(sum)
    }
    
    // MARK: - Personal Year
    func calculatePersonalYear(birthDate: Date, for date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        let currentComponents = calendar.dateComponents([.year], from: date)
        
        let month = birthComponents.month ?? 1
        let day = birthComponents.day ?? 1
        let year = reduceToDigit(currentComponents.year ?? 2024)
        
        return reduceToSingleDigit(month + day + year)
    }
    
    // MARK: - Personal Month
    func calculatePersonalMonth(birthDate: Date, for date: Date = Date()) -> Int {
        let personalYear = calculatePersonalYear(birthDate: birthDate, for: date)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        return reduceToSingleDigit(personalYear + month)
    }
    
    // MARK: - Personal Day
    func calculatePersonalDay(birthDate: Date, for date: Date = Date()) -> Int {
        let personalMonth = calculatePersonalMonth(birthDate: birthDate, for: date)
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        return reduceToSingleDigit(personalMonth + day)
    }
    
    // MARK: - Compatibility
    func calculateCompatibility(between person1: QodeXUser, and person2: QodeXUser) -> CompatibilityResult {
        guard let date1 = person1.birthDate, let date2 = person2.birthDate else {
            return CompatibilityResult(score: 0, description: "Insufficient data")
        }
        
        let lp1 = calculateLifePathNumber(birthDate: date1)
        let lp2 = calculateLifePathNumber(birthDate: date2)
        
        let score = calculateCompatibilityScore(lp1: lp1, lp2: lp2)
        let description = generateCompatibilityDescription(lp1: lp1, lp2: lp2)
        
        return CompatibilityResult(score: score, description: description)
    }
    
    // MARK: - Helper Methods
    private func reduceToDigit(_ number: Int) -> Int {
        var sum = 0
        var n = number
        while n > 0 {
            sum += n % 10
            n /= 10
        }
        return sum
    }
    
    func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 {
            // Check for master numbers
            if [11, 22, 33].contains(result) {
                return result
            }
            result = reduceToDigit(result)
        }
        return result
    }
    
    private func letterToNumber(_ letter: Character) -> Int? {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        guard let index = alphabet.firstIndex(of: letter) else { return nil }
        return ((index + 1) % 9) == 0 ? 9 : (index + 1) % 9
    }
    
    private func calculateCompatibilityScore(lp1: Int, lp2: Int) -> Int {
        let compatiblePairs: [(Int, Int)] = [
            (1, 5), (1, 7), (1, 9),
            (2, 4), (2, 6), (2, 8),
            (3, 6), (3, 9),
            (4, 8),
            (5, 7)
        ]
        
        if compatiblePairs.contains(where: { ($0 == lp1 && $1 == lp2) || ($0 == lp2 && $1 == lp1) }) {
            return 85
        }
        
        if lp1 == lp2 {
            return 75
        }
        
        return 60
    }
    
    private func generateCompatibilityDescription(lp1: Int, lp2: Int) -> String {
        if lp1 == lp2 {
            return "Same Life Path numbers share deep understanding but may need to work on bringing different perspectives."
        }
        
        let descriptions: [(Int, Int, String)] = [
            (1, 5, "Dynamic partnership with complementary energies"),
            (1, 7, "Intellectual connection with mutual respect"),
            (2, 6, "Harmonious and nurturing relationship"),
            (3, 9, "Creative and humanitarian bond")
        ]
        
        for (a, b, desc) in descriptions {
            if (lp1 == a && lp2 == b) || (lp1 == b && lp2 == a) {
                return desc
            }
        }
        
        return "Unique connection with growth potential"
    }
}

// MARK: - Supporting Types
struct CompatibilityResult {
    let score: Int
    let description: String
}

struct NumerologyProfile {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let birthday: Int
    let maturity: Int
}
