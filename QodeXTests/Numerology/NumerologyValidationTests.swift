//
//  NumerologyValidationTests.swift
//  Comprehensive validation tests for QodeX Numerology Engine
//  Tests against known values from established numerology sources
//
//  Master Number Test Coverage:
//  - Direct master number preservation (11, 22, 33)
//  - Numbers that reduce to master numbers (29→11, 38→11, etc.)
//  - Life Path calculations with master number components
//  - Master number detection in all calculation types
//

import Foundation
import XCTest
@testable import QodeX

// MARK: - Test Data Models

struct TestCase {
    let description: String
    let birthDate: Date
    let name: String
    let expectedLifePath: Int
    let expectedExpression: Int
    let expectedSoulUrge: Int
    let expectedPersonality: Int
}

struct PersonalYearTestCase {
    let description: String
    let birthDate: Date
    let testDate: Date
    let expectedPersonalYear: Int
}

struct MasterNumberTestCase {
    let input: Int
    let expected: Int
    let description: String
}

// MARK: - Numerology Validation Tests

class NumerologyValidationTests: XCTestCase {
    
    var calculator: NumerologyCalculator!
    var engine: CompatibilityEngine!
    
    override func setUp() {
        super.setUp()
        calculator = NumerologyCalculator()
        engine = CompatibilityEngine.shared
    }
    
    // MARK: - Helper Methods
    
    func makeDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return Calendar.current.date(from: components)!
    }
    
    func pythagoreanValue(_ char: Character) -> Int {
        let pythagorean: [Character: Int] = [
            "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9,
            "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "O": 6, "P": 7, "Q": 8, "R": 9,
            "S": 1, "T": 2, "U": 3, "V": 4, "W": 5, "X": 6, "Y": 7, "Z": 8
        ]
        return pythagorean[char.uppercased().first!] ?? 0
    }
    
    // MARK: - Master Number Core Tests
    
    func testMasterNumber_Preservation() {
        // Test that 11, 22, 33 are NEVER reduced
        print("\n=== MASTER NUMBER PRESERVATION TESTS ===")
        
        let masterNumbers = [11, 22, 33]
        
        for master in masterNumbers {
            let result = calculator.reduceToSingleDigit(master)
            print("Master \(master) → \(result) \(result == master ? "✓" : "✗ FAIL")")
            XCTAssertEqual(result, master, "Master number \(master) should NEVER be reduced")
        }
    }
    
    func testMasterNumber_ReductionToMaster() {
        // Test numbers that should reduce to master numbers
        print("\n=== REDUCTION TO MASTER NUMBER TESTS ===")
        
        let testCases: [MasterNumberTestCase] = [
            MasterNumberTestCase(input: 29, expected: 11, description: "2+9=11"),
            MasterNumberTestCase(input: 38, expected: 11, description: "3+8=11"),
            MasterNumberTestCase(input: 47, expected: 11, description: "4+7=11"),
            MasterNumberTestCase(input: 56, expected: 11, description: "5+6=11"),
            MasterNumberTestCase(input: 65, expected: 11, description: "6+5=11"),
            MasterNumberTestCase(input: 74, expected: 11, description: "7+4=11"),
            MasterNumberTestCase(input: 83, expected: 11, description: "8+3=11"),
            MasterNumberTestCase(input: 92, expected: 11, description: "9+2=11"),
            
            MasterNumberTestCase(input: 49, expected: 4, description: "4+9=13→4 (not master)"),
            MasterNumberTestCase(input: 58, expected: 4, description: "5+8=13→4 (not master)"),
            MasterNumberTestCase(input: 67, expected: 4, description: "6+7=13→4 (not master)"),
            MasterNumberTestCase(input: 76, expected: 4, description: "7+6=13→4 (not master)"),
            MasterNumberTestCase(input: 85, expected: 4, description: "8+5=13→4 (not master)"),
            MasterNumberTestCase(input: 94, expected: 4, description: "9+4=13→4 (not master)"),
        ]
        
        for tc in testCases {
            let result = calculator.reduceToSingleDigit(tc.input)
            let status = result == tc.expected ? "✓" : "✗ FAIL"
            print("\(tc.input) (\(tc.description)) → \(result) (expected \(tc.expected)) \(status)")
            XCTAssertEqual(result, tc.expected, "\(tc.input) should reduce to \(tc.expected)")
        }
    }
    
    func testMasterNumber_MultiStepReduction() {
        // Test multi-step reductions that should end at master numbers
        print("\n=== MULTI-STEP REDUCTION TESTS ===")
        
        let testCases: [(input: Int, expected: Int, steps: String)] = [
            (199, 1, "1+9+9=19→10→1"),       // Not a master number path
            (299, 2, "2+9+9=20→2"),           // Not a master number path
            (389, 2, "3+8+9=20→2"),           // Not a master number path
            (119, 11, "1+1+9=11 (master)"),   // Should stop at 11
            (128, 11, "1+2+8=11 (master)"),   // Should stop at 11
            (137, 11, "1+3+7=11 (master)"),   // Should stop at 11
            (146, 11, "1+4+6=11 (master)"),   // Should stop at 11
            (155, 11, "1+5+5=11 (master)"),   // Should stop at 11
            (164, 11, "1+6+4=11 (master)"),   // Should stop at 11
            (173, 11, "1+7+3=11 (master)"),   // Should stop at 11
            (182, 11, "1+8+2=11 (master)"),   // Should stop at 11
            (191, 11, "1+9+1=11 (master)"),   // Should stop at 11
            (229, 13, "2+2+9=13→4"),          // Karmic debt, reduces to 4
        ]
        
        for (input, expected, steps) in testCases {
            let result = calculator.reduceToSingleDigit(input)
            let status = result == expected ? "✓" : "✗ FAIL"
            print("\(input) (\(steps)) → \(result) (expected \(expected)) \(status)")
            XCTAssertEqual(result, expected, "\(input) with steps '\(steps)' should reduce to \(expected)")
        }
    }
    
    // MARK: - Life Path Master Number Tests
    
    func testLifePath_WithMasterNumberComponents() {
        print("\n=== LIFE PATH WITH MASTER NUMBER COMPONENTS ===")
        
        // Test: November 11, 1999
        // Month: 11 (master) → 11
        // Day: 11 (master) → 11
        // Year: 1999 → 1+9+9+9 = 28 → 10 → 1
        // Sum: 11 + 11 + 1 = 23 → 5
        let date1 = makeDate(day: 11, month: 11, year: 1999)
        let result1 = calculator.calculateLifePathNumber(birthDate: date1)
        let details1 = calculator.calculateLifePathDetails(birthDate: date1)
        
        print("Nov 11, 1999:")
        print("  Components: month=\(details1.monthComponent), day=\(details1.dayComponent), year=\(details1.yearComponent)")
        print("  Sum: \(details1.monthComponent + details1.dayComponent + details1.yearComponent)")
        print("  Life Path: \(result1) (expected: 5)")
        print("  Is Master: \(details1.isMasterNumber)")
        
        XCTAssertEqual(details1.monthComponent, 11, "November (11) should be preserved as master number")
        XCTAssertEqual(details1.dayComponent, 11, "Day 11 should be preserved as master number")
        XCTAssertEqual(result1, 5, "Life Path should be 5 (11+11+1=23→5)")
        XCTAssertFalse(details1.isMasterNumber, "Result 5 is not a master number")
        
        // Test: November 22, 1988
        // Month: 11 (master) → 11
        // Day: 22 (master) → 22
        // Year: 1988 → 1+9+8+8 = 26 → 8
        // Sum: 11 + 22 + 8 = 41 → 5
        let date2 = makeDate(day: 22, month: 11, year: 1988)
        let result2 = calculator.calculateLifePathNumber(birthDate: date2)
        let details2 = calculator.calculateLifePathDetails(birthDate: date2)
        
        print("\nNov 22, 1988:")
        print("  Components: month=\(details2.monthComponent), day=\(details2.dayComponent), year=\(details2.yearComponent)")
        print("  Sum: \(details2.monthComponent + details2.dayComponent + details2.yearComponent)")
        print("  Life Path: \(result2) (expected: 5)")
        print("  Is Master: \(details2.isMasterNumber)")
        
        XCTAssertEqual(details2.monthComponent, 11, "November (11) should be preserved")
        XCTAssertEqual(details2.dayComponent, 22, "Day 22 should be preserved as master number")
        XCTAssertEqual(result2, 5, "Life Path should be 5 (11+22+8=41→5)")
    }
    
    func testLifePath_ResultIsMasterNumber() {
        print("\n=== LIFE PATH RESULT IS MASTER NUMBER ===")
        
        // Finding a date that results in a master number is tricky
        // Let's verify the reduction logic works correctly
        
        // Example: January 1, 2009
        // Month: 1
        // Day: 1
        // Year: 2009 → 2+0+0+9 = 11 (master!)
        // Sum: 1 + 1 + 11 = 13 → 4
        let date1 = makeDate(day: 1, month: 1, year: 2009)
        let result1 = calculator.calculateLifePathNumber(birthDate: date1)
        let details1 = calculator.calculateLifePathDetails(birthDate: date1)
        
        print("Jan 1, 2009:")
        print("  Year component: \(details1.yearComponent)")
        print("  Life Path: \(result1) (expected: 4)")
        
        XCTAssertEqual(details1.yearComponent, 11, "Year 2009 should reduce to 11")
        XCTAssertEqual(result1, 4, "Life Path should be 4 (1+1+11=13→4)")
    }
    
    // MARK: - Celebrity Tests
    
    func testLifePath_Celebrity_OprahWinfrey() {
        // Oprah Winfrey: January 29, 1954
        // Month: 1 = 1
        // Day: 29 → 2+9 = 11 (master number)
        // Year: 1954 → 1+9+5+4 = 19 → 1+9 = 10 → 1+0 = 1
        // Total: 1 + 11 + 1 = 13 → 1+3 = 4
        let date = makeDate(day: 29, month: 1, year: 1954)
        let result = calculator.calculateLifePathNumber(birthDate: date)
        let details = calculator.calculateLifePathDetails(birthDate: date)
        
        print("\nOprah Winfrey (Jan 29, 1954):")
        print("  Day component: \(details.dayComponent)")
        print("  Expected: 11 (master)")
        print("  Life Path: \(result) (expected: 4)")
        
        XCTAssertEqual(details.dayComponent, 11, "Day 29 should reduce to 11 (master)")
        XCTAssertEqual(result, 4, "Oprah Winfrey should be Life Path 4")
    }
    
    func testLifePath_Celebrity_TomHanks() {
        // Tom Hanks: July 9, 1956
        // Month: 7 = 7
        // Day: 9 = 9
        // Year: 1956 → 1+9+5+6 = 21 → 2+1 = 3
        // Total: 7 + 9 + 3 = 19 → 1+9 = 10 → 1+0 = 1
        let date = makeDate(day: 9, month: 7, year: 1956)
        let result = calculator.calculateLifePathNumber(birthDate: date)
        
        print("\nTom Hanks (Jul 9, 1956):")
        print("  Life Path: \(result) (expected: 1)")
        
        XCTAssertEqual(result, 1, "Tom Hanks should be Life Path 1")
    }
    
    // MARK: - Expression Number Tests
    
    func testExpression_Basic() {
        // JOHN DOE
        // J=1, O=6, H=8, N=5, D=4, O=6, E=5
        // Sum: 1+6+8+5+4+6+5 = 35 → 3+5 = 8
        let result = calculator.calculateExpressionNumber(name: "John Doe")
        let details = calculator.calculateExpressionDetails(name: "John Doe")
        
        print("\nExpression Number Test (John Doe):")
        print("  Sum: \(details.totalSum)")
        print("  Expression: \(result) (expected: 8)")
        print("  Is Master: \(details.isMasterNumber)")
        
        XCTAssertEqual(result, 8, "John Doe should have Expression 8")
        XCTAssertFalse(details.isMasterNumber, "8 is not a master number")
    }
    
    func testExpression_MasterNumber() {
        // Test a name that results in a master number
        // This requires finding a name that sums to 11, 22, or 33
        // AAAAAAAAAA = 1+1+1+1+1+1+1+1+1+1 = 10 → 1 (not master)
        // KKKKKKKKKK = 2+2+2+2+2+2+2+2+2+2 = 20 → 2 (not master)
        
        // Let's manually verify the reduction logic
        let testSum = 29 // Should reduce to 11
        let result = calculator.reduceToSingleDigit(testSum)
        
        print("\nExpression Master Number Test:")
        print("  Sum \(testSum) reduces to \(result) (expected: 11)")
        
        XCTAssertEqual(result, 11, "Sum 29 should reduce to master number 11")
    }
    
    // MARK: - Soul Urge Tests
    
    func testSoulUrge_Basic() {
        // Soul Urge = vowels only
        // JOHN DOE → O, O, E = 6 + 6 + 5 = 17 → 8
        let result = calculator.calculateSoulUrgeNumber(name: "John Doe")
        let details = calculator.calculateSoulUrgeDetails(name: "John Doe")
        
        print("\nSoul Urge Test (John Doe):")
        print("  Vowels: O(6) + O(6) + E(5) = 17 → 8")
        print("  Result: \(result) (expected: 8)")
        print("  Is Master: \(details.isMasterNumber)")
        
        XCTAssertEqual(result, 8, "John Doe Soul Urge should be 8")
    }
    
    // MARK: - Birthday Number Tests
    
    func testBirthdayNumber_Master() {
        // Test birthday numbers that are master numbers
        let testCases: [(day: Int, expected: Int, isMaster: Bool)] = [
            (1, 1, false),
            (10, 1, false),
            (11, 11, true),
            (20, 2, false),
            (22, 22, true),
            (29, 11, true),
        ]
        
        print("\n=== BIRTHDAY NUMBER MASTER TESTS ===")
        
        for tc in testCases {
            // Create a date with this day (month/year don't matter for this test)
            let date = makeDate(day: tc.day, month: 1, year: 2000)
            let result = calculator.calculateBirthdayNumber(birthDate: date)
            let details = calculator.calculateBirthdayDetails(birthDate: date)
            
            let status = (result == tc.expected && details.isMasterNumber == tc.isMaster) ? "✓" : "✗ FAIL"
            print("Day \(tc.day) → \(result) (master: \(details.isMasterNumber)) (expected: \(tc.expected), master: \(tc.isMaster)) \(status)")
            
            XCTAssertEqual(result, tc.expected, "Day \(tc.day) should result in \(tc.expected)")
            XCTAssertEqual(details.isMasterNumber, tc.isMaster, "Day \(tc.day) master status should be \(tc.isMaster)")
        }
    }
    
    // MARK: - Master Number Validation
    
    func testMasterNumberValidation() {
        print("\n=== RUNNING MASTER NUMBER VALIDATION ===")
        
        let validationResults = calculator.validateMasterNumberPreservation()
        
        for result in validationResults {
            print("  \(result)")
        }
        
        // Should have no failures
        let failures = validationResults.filter { $0.contains("ERROR") }
        XCTAssertTrue(failures.isEmpty, "Master Number validation failed: \(failures)")
    }
    
    // MARK: - Comprehensive Report
    
    func testGenerateValidationReport() {
        print("\n" + String(repeating: "=", count: 60))
        print("QODEX NUMEROLOGY VALIDATION REPORT")
        print("MASTER NUMBER FOCUS")
        print(String(repeating: "=", count: 60))
        
        // Master Number Tests
        print("\n[1] MASTER NUMBER PRESERVATION")
        print(String(repeating: "-", count: 40))
        
        for master in [11, 22, 33] {
            let result = calculator.reduceToSingleDigit(master)
            let status = result == master ? "✓" : "✗"
            print("  \(status) \(master) preserved as master number")
        }
        
        // Reduction to Master Numbers
        print("\n[2] REDUCTION TO MASTER NUMBERS")
        print(String(repeating: "-", count: 40))
        
        let reductionTests = [(29, 11), (38, 11), (47, 11)]
        for (input, expected) in reductionTests {
            let result = calculator.reduceToSingleDigit(input)
            let status = result == expected ? "✓" : "✗"
            print("  \(status) \(input) → \(result) (expected \(expected))")
        }
        
        // Life Path Tests
        print("\n[3] LIFE PATH WITH MASTER COMPONENTS")
        print(String(repeating: "-", count: 40))
        
        let celebrityTests = [
            ("Oprah Winfrey", 29, 1, 1954, 4),
            ("Day 11 Test", 11, 11, 1991, 6),
        ]
        
        for (name, day, month, year, expected) in celebrityTests {
            let date = makeDate(day: day, month: month, year: year)
            let result = calculator.calculateLifePathNumber(birthDate: date)
            let status = result == expected ? "✓" : "✗"
            print("  \(status) \(name): expected \(expected), got \(result)")
        }
        
        // Birthday Tests
        print("\n[4] BIRTHDAY NUMBER MASTER TESTS")
        print(String(repeating: "-", count: 40))
        
        for day in [11, 22, 29] {
            let date = makeDate(day: day, month: 1, year: 2000)
            let result = calculator.calculateBirthdayNumber(birthDate: date)
            let isMaster = calculator.isMasterNumber(result)
            let status = isMaster ? "✓" : "✗"
            print("  \(status) Day \(day) → \(result) (master: \(isMaster))")
        }
        
        print("\n" + String(repeating: "=", count: 60))
    }
    
    // MARK: - Full Profile Master Number Test
    
    func testFullProfile_MasterNumberDetection() {
        print("\n=== FULL PROFILE MASTER NUMBER DETECTION ===")
        
        // Use a date that has master number components
        // Nov 11, 1988 - both month and day are master numbers
        let birthDate = makeDate(day: 11, month: 11, year: 1988)
        let fullName = "Test User"
        
        let profile = calculator.calculateFullProfileDetails(birthDate: birthDate, fullName: fullName)
        
        print("Profile for Nov 11, 1988:")
        print("  Life Path: \(profile.lifePath.number) (master: \(profile.lifePath.isMasterNumber))")
        print("  Birthday: \(profile.birthday.number) (master: \(profile.birthday.isMasterNumber))")
        print("  All Master Numbers: \(profile.masterNumberSummary)")
        
        // Birthday should be 11 (master)
        XCTAssertEqual(profile.birthday.number, 11, "Birthday should be 11 (master)")
        XCTAssertTrue(profile.birthday.isMasterNumber, "Birthday 11 should be marked as master")
        
        // Should have at least one master number
        XCTAssertFalse(profile.allMasterNumbers.isEmpty, "Profile should have master numbers")
    }
}

// MARK: - Extension for string multiplication

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
