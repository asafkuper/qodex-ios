//
//  DateExtensionsTests.swift
//  Unit tests for Date extensions - age calculation, formatting
//

import XCTest
@testable import QodeX

// MARK: - Date Extension Tests

final class DateExtensionsTests: XCTestCase {
    
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }
    
    override func tearDown() {
        calendar = nil
        super.tearDown()
    }
    
    // MARK: - Age Calculation Tests
    
    func testAgeCalculation() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        let now = Date()
        
        let components = calendar.dateComponents([.year], from: birthDate, to: now)
        let age = components.year!
        
        XCTAssertGreaterThan(age, 0)
        XCTAssertEqual(age, 34) // As of 2024
    }
    
    func testAgeCalculationExactBirthday() {
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let components = calendar.dateComponents([.month, .day], from: now)
        
        var birthComponents = DateComponents()
        birthComponents.year = currentYear - 25
        birthComponents.month = components.month
        birthComponents.day = components.day
        
        let birthDate = calendar.date(from: birthComponents)!
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        
        XCTAssertEqual(ageComponents.year, 25)
    }
    
    func testAgeCalculationBeforeBirthday() {
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        // Birth date is next month (hasn't happened yet this year)
        var birthComponents = DateComponents()
        birthComponents.year = currentYear - 25
        birthComponents.month = currentMonth + 1
        if birthComponents.month! > 12 {
            birthComponents.month = 1
            birthComponents.year = currentYear - 24
        }
        birthComponents.day = 15
        
        let birthDate = calendar.date(from: birthComponents)!
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        
        // Age should be 24 (birthday hasn't occurred this year)
        XCTAssertEqual(ageComponents.year, 24)
    }
    
    func testAgeCalculationAfterBirthday() {
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        // Birth date was last month (already happened this year)
        var birthComponents = DateComponents()
        birthComponents.year = currentYear - 25
        birthComponents.month = currentMonth - 1
        if birthComponents.month! < 1 {
            birthComponents.month = 12
            birthComponents.year = currentYear - 26
        }
        birthComponents.day = 15
        
        let birthDate = calendar.date(from: birthComponents)!
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        
        // Age should be 25 (birthday already occurred this year)
        XCTAssertEqual(ageComponents.year, 25)
    }
    
    func testAgeCalculationNewborn() {
        let birthDate = Date()
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        
        XCTAssertEqual(components.year, 0)
    }
    
    func testAgeCalculationCentenarian() {
        let birthDate = TestDateFactory.date(year: 1920, month: 1, day: 1)
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        
        XCTAssertGreaterThanOrEqual(components.year!, 100)
    }
    
    func testAgeCalculationLeapYearBirthday() {
        // Born on Feb 29, 2020
        let birthDate = TestDateFactory.date(year: 2020, month: 2, day: 29)
        
        // In non-leap year, age should still calculate correctly
        let now = TestDateFactory.date(year: 2024, month: 3, day: 1)
        let components = calendar.dateComponents([.year], from: birthDate, to: now)
        
        XCTAssertEqual(components.year, 4)
    }
    
    // MARK: - Date Formatting Tests
    
    func testDateFormattingShort() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains("15") || formatted.contains("3"))
    }
    
    func testDateFormattingMedium() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testDateFormattingLong() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testDateFormattingFull() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
        // Full style should include day name
        XCTAssertTrue(formatted.contains("day") || formatted.contains("Friday"))
    }
    
    func testCustomDateFormat() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formatted = formatter.string(from: date)
        XCTAssertEqual(formatted, "2024-03-15")
    }
    
    func testCustomDateFormatWithTime() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14, minute: 30)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let formatted = formatter.string(from: date)
        XCTAssertEqual(formatted, "2024-03-15 14:30")
    }
    
    func testISO8601Formatting() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14, minute: 30)
        
        let formatter = ISO8601DateFormatter()
        let formatted = formatter.string(from: date)
        
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains("2024"))
        
        // Parse it back
        let parsed = formatter.date(from: formatted)
        XCTAssertNotNil(parsed)
    }
    
    // MARK: - Relative Date Formatting Tests
    
    func testRelativeDateFormattingToday() {
        let today = Date()
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let formatted = formatter.localizedString(for: today, relativeTo: today)
        XCTAssertTrue(formatted.contains("now") || formatted.contains("today"))
    }
    
    func testRelativeDateFormattingYesterday() {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let formatted = formatter.localizedString(for: yesterday, relativeTo: Date())
        XCTAssertTrue(formatted.contains("yesterday") || formatted.contains("day"))
    }
    
    func testRelativeDateFormattingTomorrow() {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let formatted = formatter.localizedString(for: tomorrow, relativeTo: Date())
        XCTAssertTrue(formatted.contains("tomorrow") || formatted.contains("day"))
    }
    
    func testRelativeDateFormattingNextWeek() {
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())!
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let formatted = formatter.localizedString(for: nextWeek, relativeTo: Date())
        XCTAssertFalse(formatted.isEmpty)
    }
    
    // MARK: - Date Components Tests
    
    func testDateComponentsExtraction() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14, minute: 30)
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }
    
    func testStartOfDay() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14, minute: 30)
        let startOfDay = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testEndOfDay() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14, minute: 30)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: date))!
        
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endOfDay)
        XCTAssertEqual(endComponents.hour, 23)
        XCTAssertEqual(endComponents.minute, 59)
        XCTAssertEqual(endComponents.second, 59)
    }
    
    // MARK: - Date Comparison Tests
    
    func testDateComparisonSameDay() {
        let date1 = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 10)
        let date2 = TestDateFactory.date(year: 2024, month: 3, day: 15, hour: 14)
        
        let isSameDay = calendar.isDate(date1, inSameDayAs: date2)
        XCTAssertTrue(isSameDay)
    }
    
    func testDateComparisonDifferentDay() {
        let date1 = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let date2 = TestDateFactory.date(year: 2024, month: 3, day: 16)
        
        let isSameDay = calendar.isDate(date1, inSameDayAs: date2)
        XCTAssertFalse(isSameDay)
    }
    
    func testDateOrdering() {
        let earlier = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let later = TestDateFactory.date(year: 2024, month: 3, day: 16)
        
        XCTAssertTrue(earlier < later)
        XCTAssertTrue(later > earlier)
        XCTAssertFalse(earlier > later)
    }
    
    func testDateEquality() {
        let date1 = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let date2 = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        XCTAssertEqual(date1, date2)
    }
    
    // MARK: - Date Arithmetic Tests
    
    func testAddingDays() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let newDate = calendar.date(byAdding: .day, value: 5, to: date)!
        
        let components = calendar.dateComponents([.year, .month, .day], from: newDate)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 20)
    }
    
    func testAddingMonths() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let newDate = calendar.date(byAdding: .month, value: 3, to: date)!
        
        let components = calendar.dateComponents([.year, .month, .day], from: newDate)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15)
    }
    
    func testAddingYears() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let newDate = calendar.date(byAdding: .year, value: 5, to: date)!
        
        let components = calendar.dateComponents([.year, .month, .day], from: newDate)
        XCTAssertEqual(components.year, 2029)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 15)
    }
    
    func testDateDifferenceInDays() {
        let start = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let end = TestDateFactory.date(year: 2024, month: 3, day: 20)
        
        let components = calendar.dateComponents([.day], from: start, to: end)
        XCTAssertEqual(components.day, 5)
    }
    
    func testDateDifferenceInMonths() {
        let start = TestDateFactory.date(year: 2024, month: 1, day: 15)
        let end = TestDateFactory.date(year: 2024, month: 6, day: 15)
        
        let components = calendar.dateComponents([.month], from: start, to: end)
        XCTAssertEqual(components.month, 5)
    }
    
    // MARK: - Edge Cases
    
    func testEndOfMonthTransition() {
        let jan31 = TestDateFactory.date(year: 2024, month: 1, day: 31)
        let feb29 = calendar.date(byAdding: .month, value: 1, to: jan31)!
        
        let components = calendar.dateComponents([.month, .day], from: feb29)
        // Feb 2024 is a leap year
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 29)
    }
    
    func testYearBoundary() {
        let dec31 = TestDateFactory.date(year: 2023, month: 12, day: 31)
        let jan1 = calendar.date(byAdding: .day, value: 1, to: dec31)!
        
        let components = calendar.dateComponents([.year, .month, .day], from: jan1)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
    }
    
    func testDaylightSavingTimeTransition() {
        // Test dates around DST transition
        let beforeDST = TestDateFactory.date(year: 2024, month: 3, day: 9, hour: 12)
        let afterDST = calendar.date(byAdding: .day, value: 2, to: beforeDST)!
        
        // Just verify the date calculation works
        XCTAssertNotNil(afterDST)
        
        let components = calendar.dateComponents([.day], from: beforeDST, to: afterDST)
        XCTAssertEqual(components.day, 2)
    }
    
    // MARK: - Time Zone Tests
    
    func testTimeZoneConversion() {
        let utc = TimeZone(identifier: "UTC")!
        let est = TimeZone(identifier: "America/New_York")!
        
        var components = DateComponents()
        components.timeZone = utc
        components.year = 2024
        components.month = 3
        components.day = 15
        components.hour = 12
        
        let utcDate = calendar.date(from: components)!
        
        var estCalendar = calendar
        estCalendar.timeZone = est
        
        let estComponents = estCalendar.dateComponents([.hour], from: utcDate)
        // 12:00 UTC = 07:00 or 08:00 EST depending on DST
        XCTAssertTrue(estComponents.hour == 7 || estComponents.hour == 8)
    }
    
    // MARK: - Date Interval Tests
    
    func testDateInterval() {
        let start = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let end = TestDateFactory.date(year: 2024, month: 3, day: 20)
        
        let interval = DateInterval(start: start, end: end)
        
        XCTAssertEqual(interval.duration, 5 * 24 * 60 * 60, accuracy: 1)
        XCTAssertTrue(interval.contains(TestDateFactory.date(year: 2024, month: 3, day: 17)))
        XCTAssertFalse(interval.contains(TestDateFactory.date(year: 2024, month: 3, day: 25)))
    }
    
    // MARK: - Date Components String Tests
    
    func testWeekdayName() {
        let friday = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        let weekdayName = formatter.string(from: friday)
        XCTAssertEqual(weekdayName, "Friday")
    }
    
    func testMonthName() {
        let march = TestDateFactory.date(year: 2024, month: 3, day: 15)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        let monthName = formatter.string(from: march)
        XCTAssertEqual(monthName, "March")
    }
    
    // MARK: - Performance Tests
    
    func testAgeCalculationPerformance() {
        let birthDate = TestDateFactory.date(year: 1990, month: 6, day: 15)
        
        measure {
            for _ in 0..<10000 {
                _ = calendar.dateComponents([.year], from: birthDate, to: Date())
            }
        }
    }
    
    func testDateFormattingPerformance() {
        let date = TestDateFactory.date(year: 2024, month: 3, day: 15)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        measure {
            for _ in 0..<10000 {
                _ = formatter.string(from: date)
            }
        }
    }
}
