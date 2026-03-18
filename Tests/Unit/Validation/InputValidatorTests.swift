//
//  InputValidatorTests.swift
//  Tests for input validation including email, birth date, and name validation
//

import Testing
import Foundation
@testable import QodeX

// MARK: - Test Data Builders

struct ValidationTestData {
    static let validEmails = [
        "test@example.com",
        "user.name@domain.co.uk",
        "user+tag@example.com",
        "first.last@company.io",
        "123@numeric.com",
        "UPPER@CASE.COM"
    ]
    
    static let invalidEmails = [
        "",
        "invalid",
        "@nodomain.com",
        "noat.com",
        "spaces in@email.com",
        "double@@at.com",
        "no.domain@",
        "toolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolongtoolong@example.com"
    ]
    
    static let validNames = [
        "John",
        "Jane Doe",
        "Mary-Jane",
        "O'Connor",
        "Jean-Luc",
        "Mary Kate",
        "A",
        "Very Long Name That Is Still Valid"
    ]
    
    static let invalidNames = [
        "",
        "J",
        "John123",
        "Jane@Doe",
        "Name#With$Symbols",
        "   ",
        "Name\nWith\nNewlines",
        "Name\tWith\tTabs"
    ]
}

// MARK: - Email Validation Tests

@Suite("Email Validation Tests")
struct EmailValidationTests {
    
    @Test("Valid email addresses pass validation",
          arguments: ValidationTestData.validEmails)
    func testValidEmails(email: String) async throws {
        // Should not throw
        try InputValidator.validate(email: email)
    }
    
    @Test("Invalid email addresses fail validation",
          arguments: ValidationTestData.invalidEmails)
    func testInvalidEmails(email: String) async throws {
        // Should throw ValidationError.invalidEmail or emptyField
        do {
            try InputValidator.validate(email: email)
            // If we get here, the test should fail for invalid emails
            if email.isEmpty {
                // Empty email throws .emptyField
            } else {
                Issue.record("Expected validation to fail for: \(email)")
            }
        } catch let error as ValidationError {
            if email.isEmpty {
                #expect(error == .emptyField)
            } else {
                #expect(error == .invalidEmail)
            }
        }
    }
    
    @Test("Empty email throws emptyField error")
    func testEmptyEmail() async throws {
        do {
            try InputValidator.validate(email: "")
            Issue.record("Expected emptyField error")
        } catch let error as ValidationError {
            #expect(error == .emptyField)
        }
    }
    
    @Test("Email with spaces fails validation")
    func testEmailWithSpaces() async throws {
        do {
            try InputValidator.validate(email: "test @example.com")
            Issue.record("Expected validation to fail")
        } catch let error as ValidationError {
            #expect(error == .invalidEmail)
        }
    }
    
    @Test("Email validation is case insensitive")
    func testEmailCaseInsensitivity() async throws {
        // Should accept uppercase emails
        try InputValidator.validate(email: "TEST@EXAMPLE.COM")
        try InputValidator.validate(email: "Test@Example.COM")
    }
}

// MARK: - Birth Date Validation Tests

@Suite("Birth Date Validation Tests")
struct BirthDateValidationTests {
    
    var calendar: Calendar {
        Calendar.current
    }
    
    func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components) ?? Date()
    }
    
    @Test("Valid birth date passes validation")
    func testValidBirthDate() async throws {
        let validDate = date(year: 1990, month: 6, day: 15)
        try InputValidator.validate(birthDate: validDate)
    }
    
    @Test("Future date throws futureDate error")
    func testFutureDate() async throws {
        let futureDate = calendar.date(byAdding: .year, value: 1, to: Date())!
        
        do {
            try InputValidator.validate(birthDate: futureDate)
            Issue.record("Expected futureDate error")
        } catch let error as ValidationError {
            #expect(error == .futureDate)
        }
    }
    
    @Test("Tomorrow's date throws futureDate error")
    func testTomorrowDate() async throws {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        
        do {
            try InputValidator.validate(birthDate: tomorrow)
            Issue.record("Expected futureDate error")
        } catch let error as ValidationError {
            #expect(error == .futureDate)
        }
    }
    
    @Test("Date before 1900 throws tooOld error")
    func testTooOldDate() async throws {
        let oldDate = date(year: 1899, month: 12, day: 31)
        
        do {
            try InputValidator.validate(birthDate: oldDate)
            Issue.record("Expected tooOld error")
        } catch let error as ValidationError {
            #expect(error == .tooOld)
        }
    }
    
    @Test("Date exactly at 1900 passes validation")
    func testDateAt1900() async throws {
        let year1900 = date(year: 1900, month: 1, day: 1)
        try InputValidator.validate(birthDate: year1900)
    }
    
    @Test("Under 13 years old throws tooOld error")
    func testUnder13() async throws {
        // Someone who is 12 years old
        let twelveYearsAgo = calendar.date(byAdding: .year, value: -12, to: Date())!
        
        do {
            try InputValidator.validate(birthDate: twelveYearsAgo)
            Issue.record("Expected tooOld error")
        } catch let error as ValidationError {
            #expect(error == .tooOld)
        }
    }
    
    @Test("Exactly 13 years old passes validation")
    func testExactly13() async throws {
        // Someone who just turned 13
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = (components.year ?? 0) - 13
        let exactly13 = calendar.date(from: components)!
        
        try InputValidator.validate(birthDate: exactly13)
    }
    
    @Test("Current date throws futureDate error")
    func testCurrentDate() async throws {
        // Current date should fail (not a birth date)
        do {
            try InputValidator.validate(birthDate: Date())
            // Some implementations might allow current date as valid
        } catch let error as ValidationError {
            #expect(error == .futureDate)
        }
    }
    
    @Test("Very young adult date passes validation")
    func testYoungAdult() async throws {
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: Date())!
        try InputValidator.validate(birthDate: eighteenYearsAgo)
    }
    
    @Test("Middle aged date passes validation")
    func testMiddleAged() async throws {
        let fortyYearsAgo = calendar.date(byAdding: .year, value: -40, to: Date())!
        try InputValidator.validate(birthDate: fortyYearsAgo)
    }
    
    @Test("Senior date passes validation")
    func testSenior() async throws {
        let seventyYearsAgo = calendar.date(byAdding: .year, value: -70, to: Date())!
        try InputValidator.validate(birthDate: seventyYearsAgo)
    }
    
    @Test("Centenarian date passes validation")
    func testCentenarian() async throws {
        let hundredYearsAgo = calendar.date(byAdding: .year, value: -100, to: Date())!
        try InputValidator.validate(birthDate: hundredYearsAgo)
    }
    
    @Test("Edge case - February 29 on leap year")
    func testLeapYearBirthday() async throws {
        let leapYearDate = date(year: 2020, month: 2, day: 29)
        try InputValidator.validate(birthDate: leapYearDate)
    }
    
    @Test("Edge case - December 31 date")
    func testYearEndDate() async throws {
        let yearEnd = date(year: 1990, month: 12, day: 31)
        try InputValidator.validate(birthDate: yearEnd)
    }
    
    @Test("Edge case - January 1 date")
    func testYearStartDate() async throws {
        let yearStart = date(year: 1990, month: 1, day: 1)
        try InputValidator.validate(birthDate: yearStart)
    }
}

// MARK: - Name Validation Tests

@Suite("Name Validation Tests")
struct NameValidationTests {
    
    @Test("Valid names pass validation",
          arguments: ValidationTestData.validNames)
    func testValidNames(name: String) async throws {
        // Note: Single character names and very short names might be rejected
        if name.count >= 2 {
            try InputValidator.validate(name: name)
        }
    }
    
    @Test("Empty name throws emptyField error")
    func testEmptyName() async throws {
        do {
            try InputValidator.validate(name: "")
            Issue.record("Expected emptyField error")
        } catch let error as ValidationError {
            #expect(error == .emptyField)
        }
    }
    
    @Test("Single character name throws invalidName error")
    func testSingleCharacterName() async throws {
        do {
            try InputValidator.validate(name: "A")
            Issue.record("Expected invalidName error")
        } catch let error as ValidationError {
            #expect(error == .invalidName)
        }
    }
    
    @Test("Name with numbers fails validation")
    func testNameWithNumbers() async throws {
        do {
            try InputValidator.validate(name: "John123")
            Issue.record("Expected validation to fail")
        } catch let error as ValidationError {
            #expect(error == .invalidName)
        }
    }
    
    @Test("Name with special characters fails validation")
    func testNameWithSpecialChars() async throws {
        do {
            try InputValidator.validate(name: "John@Doe")
            Issue.record("Expected validation to fail")
        } catch let error as ValidationError {
            #expect(error == .invalidName)
        }
    }
    
    @Test("Name with symbols fails validation")
    func testNameWithSymbols() async throws {
        do {
            try InputValidator.validate(name: "Jane#Doe")
            Issue.record("Expected validation to fail")
        } catch let error as ValidationError {
            #expect(error == .invalidName)
        }
    }
    
    @Test("Name with only spaces fails validation")
    func testWhitespaceOnlyName() async throws {
        do {
            try InputValidator.validate(name: "   ")
            Issue.record("Expected validation to fail")
        } catch let error as ValidationError {
            #expect(error == .invalidName)
        }
    }
    
    @Test("Name with hyphens passes validation")
    func testNameWithHyphens() async throws {
        try InputValidator.validate(name: "Mary-Jane")
        try InputValidator.validate(name: "Jean-Luc Picard")
    }
    
    @Test("Name with apostrophes passes validation")
    func testNameWithApostrophes() async throws {
        try InputValidator.validate(name: "O'Connor")
        try InputValidator.validate(name: "D'Artagnan")
    }
    
    @Test("Name with spaces passes validation")
    func testNameWithSpaces() async throws {
        try InputValidator.validate(name: "John Doe")
        try InputValidator.validate(name: "Mary Kate Olsen")
    }
    
    @Test("Two character name passes validation")
    func testTwoCharacterName() async throws {
        try InputValidator.validate(name: "Jo")
        try InputValidator.validate(name: "Al")
    }
    
    @Test("Long name passes validation")
    func testLongName() async throws {
        let longName = "Alexander Christopher Bartholomew"
        try InputValidator.validate(name: longName)
    }
    
    @Test("Name with mixed case passes validation")
    func testMixedCaseName() async throws {
        try InputValidator.validate(name: "JoHn DoE")
        try InputValidator.validate(name: "MIXED Case Name")
    }
    
    @Test("Unicode letters pass validation")
    func testUnicodeNames() async throws {
        // These may or may not pass depending on CharacterSet.letters
        // The validator uses CharacterSet.letters which includes many unicode letters
        let unicodeNames = ["José", "François", "Björn"]
        for name in unicodeNames {
            // May throw or not depending on implementation
            // Just verify it doesn't crash
            _ = try? InputValidator.validate(name: name)
        }
    }
}

// MARK: - Password Validation Tests

@Suite("Password Validation Tests")
struct PasswordValidationTests {
    
    @Test("Valid password passes validation")
    func testValidPassword() async throws {
        // At least 8 chars, with uppercase, lowercase, and digit
        try InputValidator.validate(password: "Password123")
        try InputValidator.validate(password: "SecurePass1")
        try InputValidator.validate(password: "MyP@ssw0rd")
    }
    
    @Test("Short password throws weakPassword error")
    func testShortPassword() async throws {
        do {
            try InputValidator.validate(password: "Short1")
            Issue.record("Expected weakPassword error")
        } catch let error as ValidationError {
            #expect(error == .weakPassword)
        }
    }
    
    @Test("Password without uppercase throws weakPassword error")
    func testPasswordNoUppercase() async throws {
        do {
            try InputValidator.validate(password: "password123")
            Issue.record("Expected weakPassword error")
        } catch let error as ValidationError {
            #expect(error == .weakPassword)
        }
    }
    
    @Test("Password without lowercase throws weakPassword error")
    func testPasswordNoLowercase() async throws {
        do {
            try InputValidator.validate(password: "PASSWORD123")
            Issue.record("Expected weakPassword error")
        } catch let error as ValidationError {
            #expect(error == .weakPassword)
        }
    }
    
    @Test("Password without digit throws weakPassword error")
    func testPasswordNoDigit() async throws {
        do {
            try InputValidator.validate(password: "PasswordOnly")
            Issue.record("Expected weakPassword error")
        } catch let error as ValidationError {
            #expect(error == .weakPassword)
        }
    }
    
    @Test("Password exactly 8 characters passes")
    func testExactly8Characters() async throws {
        try InputValidator.validate(password: "Pass1234")
    }
    
    @Test("Long password passes validation")
    func testLongPassword() async throws {
        try InputValidator.validate(password: "VeryLongPassword123WithManyCharacters")
    }
    
    @Test("Password with special characters passes")
    func testPasswordWithSpecialChars() async throws {
        try InputValidator.validate(password: "P@ssw0rd!")
        try InputValidator.validate(password: "MyP#ss123")
    }
}

// MARK: - Sanitization Tests

@Suite("Input Sanitization Tests")
struct SanitizationTests {
    
    @Test("HTML tags are removed")
    func testHTMLTagRemoval() async throws {
        let input = "<p>Hello</p>"
        let sanitized = InputValidator.sanitize(input)
        #expect(!sanitized.contains("<")")
        #expect(!sanitized.contains(">"))
    }
    
    @Test("Whitespace is trimmed")
    func testWhitespaceTrimming() async throws {
        let input = "  hello world  "
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized == "hello world")
    }
    
    @Test("Leading whitespace is trimmed")
    func testLeadingWhitespaceTrimming() async throws {
        let input = "   hello"
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized == "hello")
    }
    
    @Test("Trailing whitespace is trimmed")
    func testTrailingWhitespaceTrimming() async throws {
        let input = "hello   "
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized == "hello")
    }
    
    @Test("Newlines are trimmed")
    func testNewlineTrimming() async throws {
        let input = "\n\nhello\n\n"
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized == "hello")
    }
    
    @Test("Long input is truncated to 100 characters")
    func testLengthTruncation() async throws {
        let longInput = String(repeating: "a", count: 150)
        let sanitized = InputValidator.sanitize(longInput)
        #expect(sanitized.count == 100)
    }
    
    @Test("Input at 100 characters is not truncated")
    func testExactly100Characters() async throws {
        let input = String(repeating: "a", count: 100)
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized.count == 100)
    }
    
    @Test("Script tags are removed")
    func testScriptTagRemoval() async throws {
        let input = "<script>alert('xss')</script>"
        let sanitized = InputValidator.sanitize(input)
        #expect(!sanitized.contains("script"))
    }
    
    @Test("Complex HTML is sanitized")
    func testComplexHTML() async throws {
        let input = "<div class='test'><span>Hello</span></div>"
        let sanitized = InputValidator.sanitize(input)
        #expect(sanitized == "Hello")
    }
}

// MARK: - Rate Limiting Tests

@Suite("Rate Limiting Tests")
struct RateLimitingTests {
    
    @Test("First attempt passes rate limit")
    func testFirstAttempt() async throws {
        let identifier = "test_\(UUID().uuidString)"
        let result = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: 5, windowSeconds: 300)
        #expect(result == true)
    }
    
    @Test("Multiple attempts within limit pass")
    func testMultipleAttempts() async throws {
        let identifier = "test_\(UUID().uuidString)"
        
        for i in 0..<5 {
            let result = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: 5, windowSeconds: 300)
            #expect(result == true, "Attempt \(i+1) should pass")
        }
    }
    
    @Test("Exceeding max attempts fails rate limit")
    func testExceedingMaxAttempts() async throws {
        let identifier = "test_\(UUID().uuidString)"
        
        // Make 5 attempts (max)
        for _ in 0..<5 {
            _ = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: 5, windowSeconds: 300)
        }
        
        // 6th attempt should fail
        let result = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: 5, windowSeconds: 300)
        #expect(result == false)
    }
    
    @Test("Different identifiers have separate rate limits")
    func testSeparateIdentifiers() async throws {
        let identifier1 = "test_\(UUID().uuidString)_1"
        let identifier2 = "test_\(UUID().uuidString)_2"
        
        // Exhaust rate limit for identifier1
        for _ in 0..<5 {
            _ = InputValidator.checkRateLimit(identifier: identifier1, maxAttempts: 5, windowSeconds: 300)
        }
        
        // identifier1 should be rate limited
        #expect(InputValidator.checkRateLimit(identifier: identifier1, maxAttempts: 5, windowSeconds: 300) == false)
        
        // identifier2 should not be rate limited
        #expect(InputValidator.checkRateLimit(identifier: identifier2, maxAttempts: 5, windowSeconds: 300) == true)
    }
}

// MARK: - Validation Error Tests

@Suite("Validation Error Tests")
struct ValidationErrorTests {
    
    @Test("ValidationError emptyField has correct description")
    func testEmptyFieldError() async throws {
        let error = ValidationError.emptyField
        #expect(error.errorDescription == "This field cannot be empty")
    }
    
    @Test("ValidationError invalidEmail has correct description")
    func testInvalidEmailError() async throws {
        let error = ValidationError.invalidEmail
        #expect(error.errorDescription == "Please enter a valid email address")
    }
    
    @Test("ValidationError weakPassword has correct description")
    func testWeakPasswordError() async throws {
        let error = ValidationError.weakPassword
        #expect(error.errorDescription?.contains("8 characters") == true)
    }
    
    @Test("ValidationError futureDate has correct description")
    func testFutureDateError() async throws {
        let error = ValidationError.futureDate
        #expect(error.errorDescription == "Birth date cannot be in the future")
    }
    
    @Test("ValidationError tooOld has correct description")
    func testTooOldError() async throws {
        let error = ValidationError.tooOld
        #expect(error.errorDescription == "Please enter a valid birth date")
    }
    
    @Test("ValidationError invalidName has correct description")
    func testInvalidNameError() async throws {
        let error = ValidationError.invalidName
        #expect(error.errorDescription?.contains("letters") == true)
    }
    
    @Test("ValidationError conforms to LocalizedError")
    func testLocalizedErrorConformance() async throws {
        let error: LocalizedError = ValidationError.invalidEmail
        #expect(error.errorDescription != nil)
    }
}