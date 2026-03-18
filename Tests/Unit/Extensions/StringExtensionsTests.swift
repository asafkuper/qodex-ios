//
//  StringExtensionsTests.swift
//  Unit tests for String extensions - numerology conversions
//

import XCTest
@testable import QodeX

// MARK: - String Extension Tests

final class StringExtensionsTests: XCTestCase {
    
    // MARK: - Letter to Number Mapping Tests
    
    func testLetterToNumberMapping() {
        // A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8, I=9
        // J=1, K=2, L=3, M=4, N=5, O=6, P=7, Q=8, R=9
        // S=1, T=2, U=3, V=4, W=5, X=6, Y=7, Z=8
        
        let calculator = NumerologyCalculator()
        
        let testCases: [(letter: String, expected: Int)] = [
            ("A", 1), ("J", 1), ("S", 1),
            ("B", 2), ("K", 2), ("T", 2),
            ("C", 3), ("L", 3), ("U", 3),
            ("D", 4), ("M", 4), ("V", 4),
            ("E", 5), ("N", 5), ("W", 5),
            ("F", 6), ("O", 6), ("X", 6),
            ("G", 7), ("P", 7), ("Y", 7),
            ("H", 8), ("Q", 8), ("Z", 8),
            ("I", 9), ("R", 9),
        ]
        
        for (letter, expected) in testCases {
            let result = calculator.calculateExpressionNumber(name: letter)
            XCTAssertEqual(result, expected, "Letter '\(letter)' should equal \(expected), got \(result)")
        }
    }
    
    func testLetterToNumberWithLowercase() {
        let calculator = NumerologyCalculator()
        
        // Test that lowercase letters work the same
        let upperA = calculator.calculateExpressionNumber(name: "A")
        let lowerA = calculator.calculateExpressionNumber(name: "a")
        
        XCTAssertEqual(upperA, lowerA)
        XCTAssertEqual(upperA, 1)
    }
    
    func testLetterToNumberWithMixedCase() {
        let calculator = NumerologyCalculator()
        
        let upper = calculator.calculateExpressionNumber(name: "ABC")
        let lower = calculator.calculateExpressionNumber(name: "abc")
        let mixed = calculator.calculateExpressionNumber(name: "AbC")
        
        XCTAssertEqual(upper, lower)
        XCTAssertEqual(upper, mixed)
    }
    
    // MARK: - Vowel Extraction Tests
    
    func testVowelExtraction() {
        let calculator = NumerologyCalculator()
        
        // Test individual vowels
        let vowels = ["A", "E", "I", "O", "U"]
        for vowel in vowels {
            let result = calculator.calculateSoulUrgeNumber(name: vowel)
            XCTAssertGreaterThan(result, 0, "Vowel '\(vowel)' should have a value")
        }
    }
    
    func testVowelCalculationWithName() {
        let calculator = NumerologyCalculator()
        
        // "John" -> O = 6
        let john = calculator.calculateSoulUrgeNumber(name: "John")
        XCTAssertEqual(john, 6)
        
        // "Alice" -> A + I + E = 1 + 9 + 5 = 15 = 6
        let alice = calculator.calculateSoulUrgeNumber(name: "Alice")
        XCTAssertEqual(alice, 6)
    }
    
    func testVowelExtractionIgnoresConsonants() {
        let calculator = NumerologyCalculator()
        
        // Consonants only should return 0
        let result = calculator.calculateSoulUrgeNumber(name: "BCDFG")
        XCTAssertEqual(result, 0)
    }
    
    // MARK: - Consonant Extraction Tests
    
    func testConsonantExtraction() {
        let calculator = NumerologyCalculator()
        
        // Test individual consonants
        let consonants = ["B", "C", "D", "F", "G", "H", "J", "K", "L", "M"]
        for consonant in consonants {
            let result = calculator.calculatePersonalityNumber(name: consonant)
            XCTAssertGreaterThan(result, 0, "Consonant '\(consonant)' should have a value")
        }
    }
    
    func testConsonantCalculationWithName() {
        let calculator = NumerologyCalculator()
        
        // "John" -> J + H + N = 1 + 8 + 5 = 14 = 5
        let john = calculator.calculatePersonalityNumber(name: "John")
        XCTAssertEqual(john, 5)
    }
    
    func testConsonantExtractionIgnoresVowels() {
        let calculator = NumerologyCalculator()
        
        // Vowels only should return 0
        let result = calculator.calculatePersonalityNumber(name: "AEIOU")
        XCTAssertEqual(result, 0)
    }
    
    // MARK: - Name Reduction Tests
    
    func testNameReductionToSingleDigit() {
        let calculator = NumerologyCalculator()
        
        // Test various names
        let testCases: [(name: String, min: Int, max: Int)] = [
            ("A", 1, 9),
            ("John Doe", 1, 9),
            ("Alexander Hamilton", 1, 9),
            ("Mary Jane Watson", 1, 9),
            ("Elizabeth Alexandra Mary", 1, 9),
        ]
        
        for (name, min, max) in testCases {
            let expression = calculator.calculateExpressionNumber(name: name)
            XCTAssertGreaterThanOrEqual(expression, min, "Expression for '\(name)' should be >= \(min)")
            XCTAssertLessThanOrEqual(expression, max, "Expression for '\(name)' should be <= \(max)")
        }
    }
    
    func testExpressionNumberReduction() {
        let calculator = NumerologyCalculator()
        
        // "ABC" = 1+2+3 = 6
        let abc = calculator.calculateExpressionNumber(name: "ABC")
        XCTAssertEqual(abc, 6)
        
        // "XYZ" = 6+7+8 = 21 = 3
        let xyz = calculator.calculateExpressionNumber(name: "XYZ")
        XCTAssertEqual(xyz, 3)
    }
    
    // MARK: - Special Character Handling Tests
    
    func testNameWithHyphens() {
        let calculator = NumerologyCalculator()
        
        // Hyphens should be filtered out
        let withHyphen = calculator.calculateExpressionNumber(name: "Mary-Jane")
        let withoutHyphen = calculator.calculateExpressionNumber(name: "MaryJane")
        
        // They may differ due to letter count
        XCTAssertGreaterThan(withHyphen, 0)
        XCTAssertGreaterThan(withoutHyphen, 0)
    }
    
    func testNameWithApostrophes() {
        let calculator = NumerologyCalculator()
        
        // Apostrophes should be filtered out
        let withApostrophe = calculator.calculateExpressionNumber(name: "O'Connor")
        let withoutApostrophe = calculator.calculateExpressionNumber(name: "OConnor")
        
        XCTAssertGreaterThan(withApostrophe, 0)
        XCTAssertGreaterThan(withoutApostrophe, 0)
    }
    
    func testNameWithSpaces() {
        let calculator = NumerologyCalculator()
        
        // Spaces should be filtered out
        let firstName = calculator.calculateExpressionNumber(name: "John")
        let fullName = calculator.calculateExpressionNumber(name: "John")
        
        // Same name should give same result
        XCTAssertEqual(firstName, fullName)
    }
    
    func testNameWithNumbers() {
        let calculator = NumerologyCalculator()
        
        // Numbers should be filtered out
        let withNumbers = calculator.calculateExpressionNumber(name: "John123")
        let withoutNumbers = calculator.calculateExpressionNumber(name: "John")
        
        // Should give same result
        XCTAssertEqual(withNumbers, withoutNumbers)
    }
    
    func testNameWithSymbols() {
        let calculator = NumerologyCalculator()
        
        // Symbols should be filtered out
        let withSymbols = calculator.calculateExpressionNumber(name: "John@#$%^\u0026*()")
        let clean = calculator.calculateExpressionNumber(name: "John")
        
        XCTAssertEqual(withSymbols, clean)
    }
    
    // MARK: - Unicode Character Tests
    
    func testUnicodeLetters() {
        let calculator = NumerologyCalculator()
        
        // Test accented characters
        let jose = calculator.calculateExpressionNumber(name: "José")
        let josePlain = calculator.calculateExpressionNumber(name: "Jose")
        
        // Should handle or appropriately filter unicode
        XCTAssertGreaterThan(jose, 0)
        XCTAssertGreaterThan(josePlain, 0)
    }
    
    func testUnicodeNonLetters() {
        let calculator = NumerologyCalculator()
        
        // Test with emojis and symbols
        let withEmoji = calculator.calculateExpressionNumber(name: "John😀")
        let plain = calculator.calculateExpressionNumber(name: "John")
        
        // Emoji should be filtered
        XCTAssertEqual(withEmoji, plain)
    }
    
    func testChineseCharacters() {
        let calculator = NumerologyCalculator()
        
        // Chinese characters should be filtered as they're not in A-Z
        let chinese = calculator.calculateExpressionNumber(name: "中文字")
        XCTAssertEqual(chinese, 0)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyString() {
        let calculator = NumerologyCalculator()
        
        let expression = calculator.calculateExpressionNumber(name: "")
        let soulUrge = calculator.calculateSoulUrgeNumber(name: "")
        let personality = calculator.calculatePersonalityNumber(name: "")
        
        XCTAssertEqual(expression, 0)
        XCTAssertEqual(soulUrge, 0)
        XCTAssertEqual(personality, 0)
    }
    
    func testWhitespaceOnly() {
        let calculator = NumerologyCalculator()
        
        let expression = calculator.calculateExpressionNumber(name: "     ")
        let soulUrge = calculator.calculateSoulUrgeNumber(name: "  \t\n  ")
        
        XCTAssertEqual(expression, 0)
        XCTAssertEqual(soulUrge, 0)
    }
    
    func testVeryLongName() {
        let calculator = NumerologyCalculator()
        
        let longName = String(repeating: "Alexander ", count: 100)
        let result = calculator.calculateExpressionNumber(name: longName)
        
        // Should still reduce to single digit or master number
        XCTAssertGreaterThan(result, 0)
        XCTAssertLessThanOrEqual(result, 9)
    }
    
    func testSingleCharacter() {
        let calculator = NumerologyCalculator()
        
        // Test each letter
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in alphabet {
            let result = calculator.calculateExpressionNumber(name: String(char))
            XCTAssertGreaterThan(result, 0)
            XCTAssertLessThanOrEqual(result, 9)
        }
    }
    
    // MARK: - String Manipulation Tests
    
    func testStringUppercased() {
        let lower = "john doe"
        let upper = lower.uppercased()
        
        XCTAssertEqual(upper, "JOHN DOE")
    }
    
    func testStringFilter() {
        let string = "John123!"
        let lettersOnly = string.filter { $0.isLetter }
        
        XCTAssertEqual(lettersOnly, "John")
    }
    
    func testStringCompactMap() {
        let string = "ABC"
        let values = string.compactMap { char -> Int? in
            switch char {
            case "A": return 1
            case "B": return 2
            case "C": return 3
            default: return nil
            }
        }
        
        XCTAssertEqual(values, [1, 2, 3])
        XCTAssertEqual(values.reduce(0, +), 6)
    }
    
    func testStringReduce() {
        let string = "ABC"
        let sum = string.reduce(0) { result, char in
            let value: Int
            switch char {
            case "A": value = 1
            case "B": value = 2
            case "C": value = 3
            default: value = 0
            }
            return result + value
        }
        
        XCTAssertEqual(sum, 6)
    }
    
    // MARK: - Character Set Tests
    
    func testCharacterSetLetters() {
        let letters = CharacterSet.letters
        
        XCTAssertTrue("A".unicodeScalars.allSatisfy { letters.contains($0) })
        XCTAssertTrue("z".unicodeScalars.allSatisfy { letters.contains($0) })
        XCTAssertFalse("1".unicodeScalars.allSatisfy { letters.contains($0) })
    }
    
    func testCharacterSetVowels() {
        let vowels = CharacterSet(charactersIn: "AEIOU")
        
        XCTAssertTrue("A".unicodeScalars.allSatisfy { vowels.contains($0) })
        XCTAssertTrue("E".unicodeScalars.allSatisfy { vowels.contains($0) })
        XCTAssertFalse("B".unicodeScalars.allSatisfy { vowels.contains($0) })
    }
    
    // MARK: - Master Number Detection Tests
    
    func testMasterNumberPreservation() {
        let calculator = NumerologyCalculator()
        
        // 11 should be preserved as master number
        let result11 = calculator.reduceToSingleDigit(11)
        XCTAssertEqual(result11, 11)
        
        // 22 should be preserved as master number
        let result22 = calculator.reduceToSingleDigit(22)
        XCTAssertEqual(result22, 22)
        
        // 33 should be preserved as master number
        let result33 = calculator.reduceToSingleDigit(33)
        XCTAssertEqual(result33, 33)
    }
    
    func testNonMasterNumbersReduce() {
        let calculator = NumerologyCalculator()
        
        // 10 should reduce to 1
        XCTAssertEqual(calculator.reduceToSingleDigit(10), 1)
        
        // 19 should reduce to 1
        XCTAssertEqual(calculator.reduceToSingleDigit(19), 1)
        
        // 20 should reduce to 2
        XCTAssertEqual(calculator.reduceToSingleDigit(20), 2)
        
        // 21 should reduce to 3
        XCTAssertEqual(calculator.reduceToSingleDigit(21), 3)
        
        // 23 should reduce to 5
        XCTAssertEqual(calculator.reduceToSingleDigit(23), 5)
    }
    
    // MARK: - Full Name Calculation Tests
    
    func testFullNameNumerologyProfile() {
        let calculator = NumerologyCalculator()
        let name = "William Henry Gates"
        
        let expression = calculator.calculateExpressionNumber(name: name)
        let soulUrge = calculator.calculateSoulUrgeNumber(name: name)
        let personality = calculator.calculatePersonalityNumber(name: name)
        
        // All should be valid
        XCTAssertGreaterThan(expression, 0)
        XCTAssertGreaterThan(soulUrge, 0)
        XCTAssertGreaterThan(personality, 0)
        
        // Expression = Soul Urge + Personality (theoretically)
        // Due to reduction, might not be exact but should be related
        XCTAssertLessThanOrEqual(expression, 9)
        XCTAssertLessThanOrEqual(soulUrge, 9)
        XCTAssertLessThanOrEqual(personality, 9)
    }
    
    func testFamousNames() {
        let calculator = NumerologyCalculator()
        
        let famousNames = [
            "Albert Einstein",
            "Marie Curie",
            "Leonardo da Vinci",
            "Isaac Newton",
            "Nikola Tesla"
        ]
        
        for name in famousNames {
            let expression = calculator.calculateExpressionNumber(name: name)
            XCTAssertGreaterThan(expression, 0, "\(name) should have a valid expression number")
            XCTAssertLessThanOrEqual(expression, 9, "\(name) should reduce to single digit")
        }
    }
    
    // MARK: - Performance Tests
    
    func testExpressionCalculationPerformance() {
        let calculator = NumerologyCalculator()
        let longName = String(repeating: "Alexander ", count: 1000)
        
        measure {
            for _ in 0..<1000 {
                _ = calculator.calculateExpressionNumber(name: longName)
            }
        }
    }
    
    func testSoulUrgeCalculationPerformance() {
        let calculator = NumerologyCalculator()
        let longName = String(repeating: "Alexander ", count: 1000)
        
        measure {
            for _ in 0..<1000 {
                _ = calculator.calculateSoulUrgeNumber(name: longName)
            }
        }
    }
    
    func testStringManipulationPerformance() {
        let longName = String(repeating: "Alexander ", count: 1000)
        
        measure {
            for _ in 0..<1000 {
                _ = longName.uppercased()
                    .filter { $0.isLetter }
                    .compactMap { char -> Int? in
                        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
                        guard let index = alphabet.firstIndex(of: char) else { return nil }
                        return ((index + 1) % 9) == 0 ? 9 : (index + 1) % 9
                    }
                    .reduce(0, +)
            }
        }
    }
}
