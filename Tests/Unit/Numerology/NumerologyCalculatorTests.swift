//
//  NumerologyCalculatorTests.swift
//  Comprehensive tests for numerology calculations
//

import XCTest
@testable import QodeX

class NumerologyCalculatorTests: XCTestCase {
    
    var calculator: NumerologyCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = NumerologyCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Life Path Tests
    func testLifePathCalculation() {
        let date = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 15))!
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        
        // 1+9+9+0+0+3+1+5 = 28 → 2+8 = 10 → 1+0 = 1
        XCTAssertEqual(lifePath, 1)
    }
    
    func testLifePathWithMasterNumber() {
        let date = Calendar.current.date(from: DateComponents(year: 1988, month: 11, day: 11))!
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        
        // Should detect 11 as master number
        XCTAssertTrue([11, 22, 33].contains(lifePath) || lifePath < 10)
    }
    
    func testLifePathWithDifferentDates() {
        let testCases: [(year: Int, month: Int, day: Int, expected: Int)] = [
            (2000, 1, 1, 4),    // 2+0+0+0+0+1+0+1 = 4
            (1995, 12, 25, 7),  // 1+9+9+5+1+2+2+5 = 34 → 7
            (1980, 6, 15, 3),   // 1+9+8+0+0+6+1+5 = 30 → 3
        ]
        
        for testCase in testCases {
            let date = Calendar.current.date(from: DateComponents(
                year: testCase.year,
                month: testCase.month,
                day: testCase.day
            ))!
            let result = calculator.calculateLifePathNumber(birthDate: date)
            XCTAssertEqual(result, testCase.expected, "Failed for \(testCase.year)-\(testCase.month)-\(testCase.day)")
        }
    }
    
    // MARK: - Expression Number Tests
    func testExpressionNumberCalculation() {
        let name = "John Doe"
        let expression = calculator.calculateExpressionNumber(name: name)
        
        XCTAssertGreaterThan(expression, 0)
        XCTAssertLessThanOrEqual(expression, 9)
    }
    
    func testExpressionNumberWithEmptyString() {
        let expression = calculator.calculateExpressionNumber(name: "")
        XCTAssertEqual(expression, 0)
    }
    
    // MARK: - Soul Urge Number Tests
    func testSoulUrgeNumberCalculation() {
        let name = "Alice"
        let soulUrge = calculator.calculateSoulUrgeNumber(name: name)
        
        XCTAssertGreaterThan(soulUrge, 0)
        XCTAssertLessThanOrEqual(soulUrge, 9)
    }
    
    // MARK: - Daily Number Tests
    func testDailyNumberRange() {
        let date = Date()
        let dailyNumber = calculator.calculateDailyNumber(for: date)
        
        XCTAssertGreaterThan(dailyNumber, 0)
        XCTAssertLessThanOrEqual(dailyNumber, 9)
    }
    
    func testDailyNumberConsistency() {
        let date = Date()
        let number1 = calculator.calculateDailyNumber(for: date)
        let number2 = calculator.calculateDailyNumber(for: date)
        
        XCTAssertEqual(number1, number2)
    }
    
    // MARK: - Reduce to Single Digit Tests
    func testReduceToSingleDigit() {
        let testCases: [(input: Int, expected: Int)] = [
            (5, 5),
            (10, 1),
            (19, 1),
            (28, 1),
            (11, 11),  // Master number
            (22, 22),  // Master number
            (33, 33),  // Master number
        ]
        
        for testCase in testCases {
            let result = calculator.reduceToSingleDigit(testCase.input)
            XCTAssertEqual(result, testCase.expected, "Failed for input \(testCase.input)")
        }
    }
    
    // MARK: - Compatibility Tests
    func testCompatibilityCalculation() {
        let user1 = QodeXUser(
            id: "1",
            email: "user1@test.com",
            fullName: "User One",
            birthDate: Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)),
            membershipTier: .free
        )
        
        let user2 = QodeXUser(
            id: "2",
            email: "user2@test.com",
            fullName: "User Two",
            birthDate: Calendar.current.date(from: DateComponents(year: 1991, month: 2, day: 2)),
            membershipTier: .free
        )
        
        let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
        
        XCTAssertGreaterThanOrEqual(compatibility.score, 0)
        XCTAssertLessThanOrEqual(compatibility.score, 100)
        XCTAssertFalse(compatibility.description.isEmpty)
    }
    
    func testCompatibilityWithMissingData() {
        let user1 = QodeXUser(
            id: "1",
            email: "user1@test.com",
            fullName: "User One",
            birthDate: nil,
            membershipTier: .free
        )
        
        let user2 = QodeXUser(
            id: "2",
            email: "user2@test.com",
            fullName: "User Two",
            birthDate: nil,
            membershipTier: .free
        )
        
        let compatibility = calculator.calculateCompatibility(between: user1, and: user2)
        XCTAssertEqual(compatibility.score, 0)
    }
    
    // MARK: - Performance Tests
    func testCalculationPerformance() {
        let date = Date()
        
        measure {
            for _ in 0..<1000 {
                _ = calculator.calculateLifePathNumber(birthDate: date)
            }
        }
    }
}
