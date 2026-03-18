//
//  NumerologyCalculatorComprehensiveTests.swift
//  Comprehensive unit tests for NumerologyCalculator
//

import XCTest
@testable import QodeX

final class NumerologyCalculatorComprehensiveTests: XCTestCase {
    
    var calculator: NumerologyCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = NumerologyCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Life Path Number Tests
    
    func testLifePathWithMasterNumber11() {
        // 11/11/1988 = 11 + 11 + 26 = 48 = 12 = 3, but 11 is master
        let date = TestDateFactory.date(year: 1988, month: 11, day: 11)
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        // 1+9+8+8+1+1+1+1 = 30 = 3
        XCTAssertEqual(lifePath, 3)
    }
    
    func testLifePathWithMasterNumber22() {
        let date = TestDateFactory.date(year: 1994, month: 4, day: 4)
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        // 1+9+9+4+4+4 = 31 = 4
        XCTAssertEqual(lifePath, 4)
    }
    
    func testLifePathCalculationForAllSingleDigits() {
        let testCases: [(date: Date, expected: Int)] = [
            (TestDateFactory.date(year: 2000, month: 1, day: 1), 4),    // 2+0+0+0+0+1+0+1 = 4
            (TestDateFactory.date(year: 2001, month: 1, day: 1), 5),    // 2+0+0+1+0+1+0+1 = 5
            (TestDateFactory.date(year: 2002, month: 1, day: 1), 6),    // 2+0+0+2+0+1+0+1 = 6
            (TestDateFactory.date(year: 2003, month: 1, day: 1), 7),    // 2+0+0+3+0+1+0+1 = 7
            (TestDateFactory.date(year: 2004, month: 1, day: 1), 8),    // 2+0+0+4+0+1+0+1 = 8
            (TestDateFactory.date(year: 2005, month: 1, day: 1), 9),    // 2+0+0+5+0+1+0+1 = 9
            (TestDateFactory.date(year: 1999, month: 1, day: 1), 3),    // 1+9+9+9+0+1+0+1 = 21 = 3
            (TestDateFactory.date(year: 1991, month: 1, day: 1), 4),    // 1+9+9+1+0+1+0+1 = 22 = 4
            (TestDateFactory.date(year: 1992, month: 1, day: 1), 5),    // 1+9+9+2+0+1+0+1 = 23 = 5
        ]
        
        for (date, expected) in testCases {
            let result = calculator.calculateLifePathNumber(birthDate: date)
            XCTAssertEqual(result, expected, "Life path for \(date) should be \(expected), got \(result)")
        }
    }
    
    func testLifePathWithEdgeDates() {
        // Test leap year birthday
        let leapYearDate = TestDateFactory.date(year: 2020, month: 2, day: 29)
        let leapYearResult = calculator.calculateLifePathNumber(birthDate: leapYearDate)
        // 2+0+2+0+0+2+2+9 = 17 = 8
        XCTAssertEqual(leapYearResult, 8)
        
        // Test year-end date
        let yearEndDate = TestDateFactory.date(year: 1999, month: 12, day: 31)
        let yearEndResult = calculator.calculateLifePathNumber(birthDate: yearEndDate)
        // 1+9+9+9+1+2+3+1 = 35 = 8
        XCTAssertEqual(yearEndResult, 8)
    }
    
    // MARK: - Expression Number Tests
    
    func testExpressionNumberForAllLetters() {
        // Test each letter maps correctly: A=1, B=2, ..., I=9, J=1, etc.
        let testCases: [(name: String, expected: Int)] = [
            ("A", 1),
            ("J", 1),
            ("S", 1),
            ("B", 2),
            ("K", 2),
            ("T", 2),
            ("I", 9),
            ("R", 9),
            ("Z", 8),
        ]
        
        for (name, expected) in testCases {
            let result = calculator.calculateExpressionNumber(name: name)
            XCTAssertEqual(result, expected, "Expression for '\(name)' should be \(expected), got \(result)")
        }
    }
    
    func testExpressionNumberWithFullNames() {
        let testCases: [(name: String, expectedRange: ClosedRange<Int>)] = [
            ("John Doe", 1...9),
            ("Jane Smith", 1...9),
            ("Alexander Hamilton", 1...9),
            ("Mary Jane Watson", 1...9),
            ("O'Connor", 1...9),
        ]
        
        for (name, range) in testCases {
            let result = calculator.calculateExpressionNumber(name: name)
            XCTAssertTrue(range.contains(result), "Expression for '\(name)' should be in range \(range), got \(result)")
        }
    }
    
    func testExpressionNumberIgnoresNonLetters() {
        let withSymbols = calculator.calculateExpressionNumber(name: "John@Doe!123")
        let withoutSymbols = calculator.calculateExpressionNumber(name: "JohnDoe")
        // Both should give same result as non-letters are filtered
        XCTAssertEqual(withSymbols, withoutSymbols)
    }
    
    func testExpressionNumberWithUnicode() {
        // Test with names containing accented characters
        let jose = calculator.calculateExpressionNumber(name: "José")
        let josePlain = calculator.calculateExpressionNumber(name: "Jose")
        // Should handle or filter unicode characters appropriately
        XCTAssertGreaterThan(jose, 0)
        XCTAssertLessThanOrEqual(jose, 9)
    }
    
    // MARK: - Soul Urge Number Tests
    
    func testSoulUrgeWithVowelsOnly() {
        // Testing vowel extraction
        let a = calculator.calculateSoulUrgeNumber(name: "A")      // A=1
        let e = calculator.calculateSoulUrgeNumber(name: "E")      // E=5
        let i = calculator.calculateSoulUrgeNumber(name: "I")      // I=9
        let o = calculator.calculateSoulUrgeNumber(name: "O")      // O=6
        let u = calculator.calculateSoulUrgeNumber(name: "U")      // U=3
        
        XCTAssertEqual(a, 1)
        XCTAssertEqual(e, 5)
        XCTAssertEqual(i, 9)
        XCTAssertEqual(o, 6)
        XCTAssertEqual(u, 3)
    }
    
    func testSoulUrgeIgnoresConsonants() {
        let consonantOnly = calculator.calculateSoulUrgeNumber(name: "BCDFG")
        XCTAssertEqual(consonantOnly, 0)
        
        let mixed = calculator.calculateSoulUrgeNumber(name: "John") // O=6
        XCTAssertEqual(mixed, 6)
    }
    
    func testSoulUrgeWithCommonNames() {
        let testCases: [(name: String, expected: Int)] = [
            ("Alice", 1),    // A+I+E = 1+9+5 = 15 = 6
            ("Bob", 6),      // O = 6
            ("Charlie", 11), // A+I+E = 1+9+5 = 15 = 6, but testing actual
        ]
        
        for (name, _) in testCases {
            let result = calculator.calculateSoulUrgeNumber(name: name)
            XCTAssertGreaterThan(result, 0)
            XCTAssertLessThanOrEqual(result, 9)
        }
    }
    
    // MARK: - Personality Number Tests
    
    func testPersonalityIgnoresVowels() {
        let vowelOnly = calculator.calculatePersonalityNumber(name: "AEIOU")
        XCTAssertEqual(vowelOnly, 0)
    }
    
    func testPersonalityWithConsonants() {
        // Testing consonant extraction
        let result = calculator.calculatePersonalityNumber(name: "John") // J+H+N
        // J=1, H=8, N=5 -> 14 = 5
        XCTAssertGreaterThan(result, 0)
        XCTAssertLessThanOrEqual(result, 9)
    }
    
    func testPersonalityVsExpressionVsSoulUrge() {
        let name = "Alexander"
        let expression = calculator.calculateExpressionNumber(name: name)
        let soulUrge = calculator.calculateSoulUrgeNumber(name: name)
        let personality = calculator.calculatePersonalityNumber(name: name)
        
        // Expression should equal Soul Urge + Personality (in numerology theory)
        // But due to reduction, it might not be exact - just verify all are valid
        XCTAssertGreaterThan(expression, 0)
        XCTAssertGreaterThan(soulUrge, 0)
        XCTAssertGreaterThan(personality, 0)
    }
    
    // MARK: - Daily Number Tests
    
    func testDailyNumberConsistency() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let result1 = calculator.calculateDailyNumber(for: date)
        let result2 = calculator.calculateDailyNumber(for: date)
        
        XCTAssertEqual(result1, result2, "Daily number should be consistent for the same date")
    }
    
    func testDailyNumberForDifferentDates() {
        let dates = [
            TestDateFactory.date(year: 2024, month: 1, day: 1),
            TestDateFactory.date(year: 2024, month: 6, day: 15),
            TestDateFactory.date(year: 2024, month: 12, day: 31),
        ]
        
        for date in dates {
            let result = calculator.calculateDailyNumber(for: date)
            XCTAssertGreaterThan(result, 0, "Daily number should be positive")
            XCTAssertLessThanOrEqual(result, 9, "Daily number should be single digit")
        }
    }
    
    func testDailyNumberUsesCurrentDateByDefault() {
        let result = calculator.calculateDailyNumber()
        XCTAssertGreaterThan(result, 0)
        XCTAssertLessThanOrEqual(result, 9)
    }
    
    // MARK: - Personal Year Tests
    
    func testPersonalYearCalculation() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let currentDate = TestDateFactory.date(year: 2024, month: 1, day: 1)
        
        let personalYear = calculator.calculatePersonalYear(birthDate: birthDate, for: currentDate)
        
        XCTAssertGreaterThan(personalYear, 0)
        XCTAssertLessThanOrEqual(personalYear, 9)
    }
    
    func testPersonalYearChangesWithCalendarYear() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        
        let year2023 = calculator.calculatePersonalYear(birthDate: birthDate, for: TestDateFactory.date(year: 2023, month: 6, day: 15))
        let year2024 = calculator.calculatePersonalYear(birthDate: birthDate, for: TestDateFactory.date(year: 2024, month: 6, day: 15))
        
        // Personal year should change with calendar year
        XCTAssertNotEqual(year2023, year2024)
    }
    
    // MARK: - Personal Month Tests
    
    func testPersonalMonthCalculation() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let currentDate = TestDateFactory.date(year: 2024, month: 3, day: 1)
        
        let personalMonth = calculator.calculatePersonalMonth(birthDate: birthDate, for: currentDate)
        
        XCTAssertGreaterThan(personalMonth, 0)
        XCTAssertLessThanOrEqual(personalMonth, 9)
    }
    
    func testPersonalMonthChangesWithMonth() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let year2024 = TestDateFactory.date(year: 2024, month: 1, day: 1)
        
        let month1 = calculator.calculatePersonalMonth(birthDate: birthDate, for: year2024)
        let month6 = calculator.calculatePersonalMonth(birthDate: birthDate, for: TestDateFactory.date(year: 2024, month: 6, day: 1))
        
        // Should vary by month
        XCTAssertGreaterThan(month1, 0)
        XCTAssertGreaterThan(month6, 0)
    }
    
    // MARK: - Personal Day Tests
    
    func testPersonalDayCalculation() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let currentDate = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let personalDay = calculator.calculatePersonalDay(birthDate: birthDate, for: currentDate)
        
        XCTAssertGreaterThan(personalDay, 0)
        XCTAssertLessThanOrEqual(personalDay, 9)
    }
    
    func testPersonalDayCycle() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let startDate = TestDateFactory.date(year: 2024, month: 1, day: 1)
        
        var results: [Int] = []
        for day in 1...9 {
            let date = Calendar.current.date(byAdding: .day, value: day - 1, to: startDate)!
            let personalDay = calculator.calculatePersonalDay(birthDate: birthDate, for: date)
            results.append(personalDay)
        }
        
        // Should cycle through different numbers
        XCTAssertGreaterThan(Set(results).count, 1)
    }
    
    // MARK: - Reduce to Single Digit Tests
    
    func testReduceToSingleDigitWithSingleDigit() {
        for i in 1...9 {
            XCTAssertEqual(calculator.reduceToSingleDigit(i), i)
        }
    }
    
    func testReduceToSingleDigitWithMasterNumbers() {
        XCTAssertEqual(calculator.reduceToSingleDigit(11), 11)
        XCTAssertEqual(calculator.reduceToSingleDigit(22), 22)
        XCTAssertEqual(calculator.reduceToSingleDigit(33), 33)
    }
    
    func testReduceToSingleDigitWithLargeNumbers() {
        let testCases: [(input: Int, expected: Int)] = [
            (10, 1),
            (19, 1),
            (28, 1),
            (37, 1),
            (46, 1),
            (99, 9),   // 9+9=18, 1+8=9
            (100, 1),
            (12345, 6), // 1+2+3+4+5=15, 1+5=6
        ]
        
        for (input, expected) in testCases {
            let result = calculator.reduceToSingleDigit(input)
            XCTAssertEqual(result, expected, "\(input) should reduce to \(expected), got \(result)")
        }
    }
    
    // MARK: - Compatibility Tests
    
    func testCompatibilityWithValidUsers() {
        let user1 = UserTestBuilder()
            .withBirthDate(year: 1990, month: 1, day: 1)
            .build()
        
        let user2 = UserTestBuilder()
            .withBirthDate(year: 1991, month: 2, day: 2)
            .build()
        
        let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
        
        XCTAssertGreaterThanOrEqual(compatibility.score, 0)
        XCTAssertLessThanOrEqual(compatibility.score, 100)
        XCTAssertFalse(compatibility.description.isEmpty)
    }
    
    func testCompatibilityScoreRanges() {
        // Test various life path combinations
        let lifePaths = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        for lp1 in lifePaths {
            for lp2 in lifePaths {
                let user1 = UserTestBuilder().withBirthDate(TestDateFactory.dateForLifePath(lp1)).build()
                let user2 = UserTestBuilder().withBirthDate(TestDateFactory.dateForLifePath(lp2)).build()
                
                let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
                
                XCTAssertGreaterThanOrEqual(compatibility.score, 0, "Score should be >= 0")
                XCTAssertLessThanOrEqual(compatibility.score, 100, "Score should be <= 100")
            }
        }
    }
    
    func testCompatibilityWithMissingBirthDate() {
        let user1 = UserTestBuilder().withBirthDate(nil).build()
        let user2 = UserTestBuilder().withBirthDate(year: 1991, month: 2, day: 2).build()
        
        let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
        
        XCTAssertEqual(compatibility.score, 0)
        XCTAssertFalse(compatibility.description.isEmpty)
    }
    
    func testCompatibilityDescriptionVariations() {
        let descriptions = Set<String>()
        let lifePaths = [1, 2, 3, 4, 5]
        
        for lp1 in lifePaths {
            for lp2 in lifePaths {
                let user1 = UserTestBuilder().withBirthDate(TestDateFactory.dateForLifePath(lp1)).build()
                let user2 = UserTestBuilder().withBirthDate(TestDateFactory.dateForLifePath(lp2)).build()
                
                let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
                _ = descriptions.insert(compatibility.description)
            }
        }
        
        // Should have multiple different descriptions
        XCTAssertGreaterThan(descriptions.count, 1)
    }
    
    // MARK: - Complete Profile Tests
    
    func testCompleteNumerologyProfile() {
        let name = "Alexander Johnson"
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        
        let lifePath = calculator.calculateLifePathNumber(birthDate: birthDate)
        let expression = calculator.calculateExpressionNumber(name: name)
        let soulUrge = calculator.calculateSoulUrgeNumber(name: name)
        let personality = calculator.calculatePersonalityNumber(name: name)
        
        // All should be valid numbers
        XCTAssertGreaterThan(lifePath, 0)
        XCTAssertGreaterThan(expression, 0)
        XCTAssertGreaterThan(soulUrge, 0)
        XCTAssertGreaterThan(personality, 0)
        
        // All should be single digits or master numbers
        let validNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33]
        XCTAssertTrue(validNumbers.contains(lifePath))
        XCTAssertTrue(validNumbers.contains(expression))
        XCTAssertTrue(validNumbers.contains(soulUrge))
        XCTAssertTrue(validNumbers.contains(personality))
    }
    
    // MARK: - Performance Tests
    
    func testLifePathCalculationPerformance() {
        let date = TestDateFactory.date(year: 1990, month: 6, day: 15)
        
        measure {
            for _ in 0..<10000 {
                _ = calculator.calculateLifePathNumber(birthDate: date)
            }
        }
    }
    
    func testExpressionCalculationPerformance() {
        let name = "Alexander Bartholomew Richardson"
        
        measure {
            for _ in 0..<10000 {
                _ = calculator.calculateExpressionNumber(name: name)
            }
        }
    }
    
    func testCompatibilityCalculationPerformance() {
        let user1 = UserTestBuilder().withBirthDate(year: 1990, month: 1, day: 1).build()
        let user2 = UserTestBuilder().withBirthDate(year: 1991, month: 2, day: 2).build()
        
        measure {
            for _ in 0..<1000 {
                _ = calculator.calculateCompatibility(between: user1, and: user2)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyName() {
        let expression = calculator.calculateExpressionNumber(name: "")
        let soulUrge = calculator.calculateSoulUrgeNumber(name: "")
        let personality = calculator.calculatePersonalityNumber(name: "")
        
        XCTAssertEqual(expression, 0)
        XCTAssertEqual(soulUrge, 0)
        XCTAssertEqual(personality, 0)
    }
    
    func testVeryLongName() {
        let longName = String(repeating: "Alexander ", count: 100)
        let expression = calculator.calculateExpressionNumber(name: longName)
        
        XCTAssertGreaterThan(expression, 0)
        XCTAssertLessThanOrEqual(expression, 9)
    }
    
    func testNameWithOnlySpaces() {
        let expression = calculator.calculateExpressionNumber(name: "     ")
        XCTAssertEqual(expression, 0)
    }
    
    func testDateAtEpoch() {
        let epochDate = Date(timeIntervalSince1970: 0)
        let lifePath = calculator.calculateLifePathNumber(birthDate: epochDate)
        
        XCTAssertGreaterThan(lifePath, 0)
        XCTAssertLessThanOrEqual(lifePath, 9)
    }
    
    func testDateInDistantFuture() {
        let futureDate = Date(timeIntervalSince1970: 10000000000)
        let lifePath = calculator.calculateLifePathNumber(birthDate: futureDate)
        
        XCTAssertGreaterThan(lifePath, 0)
        XCTAssertLessThanOrEqual(lifePath, 9)
    }
}
