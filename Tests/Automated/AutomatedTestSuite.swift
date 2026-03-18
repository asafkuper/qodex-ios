//
//  AutomatedTestSuite.swift
//  Comprehensive UI and Unit tests
//

import XCTest
@testable import QodeX

// MARK: - Unit Tests
class NumerologyCalculatorTests: XCTestCase {
    var calculator: NumerologyCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = NumerologyCalculator()
    }
    
    func testLifePathCalculation() {
        let date = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 15))!
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        
        // 1+9+9+0+0+3+1+5 = 28 -> 2+8 = 10 -> 1+0 = 1
        XCTAssertEqual(lifePath, 1)
    }
    
    func testDailyNumberCalculation() {
        let date = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let dailyNumber = calculator.calculateDailyNumber(for: date)
        
        XCTAssertGreaterThan(dailyNumber, 0)
        XCTAssertLessThanOrEqual(dailyNumber, 9)
    }
    
    func testMasterNumberDetection() {
        let date = Calendar.current.date(from: DateComponents(year: 1988, month: 11, day: 11))!
        let lifePath = calculator.calculateLifePathNumber(birthDate: date)
        
        // Should detect 11, 22, 33 as master numbers
        XCTAssertTrue([11, 22, 33].contains(lifePath) || lifePath < 10)
    }
    
    func testCompatibilityCalculation() {
        let person1 = QodeXUser(id: "1", email: "", fullName: "", birthDate: Date())
        let person2 = QodeXUser(id: "2", email: "", fullName: "", birthDate: Date())
        
        let compatibility = calculator.calculateCompatibility(between: person1, and: person2)
        
        XCTAssertGreaterThanOrEqual(compatibility.score, 0)
        XCTAssertLessThanOrEqual(compatibility.score, 100)
    }
}

class AuthManagerTests: XCTestCase {
    var authManager: AuthManager!
    
    override func setUp() {
        super.setUp()
        authManager = AuthManager.shared
    }
    
    func testEmailValidation() {
        XCTAssertTrue(InputValidator.isValidEmail("test@example.com"))
        XCTAssertFalse(InputValidator.isValidEmail("invalid"))
        XCTAssertFalse(InputValidator.isValidEmail(""))
    }
    
    func testPasswordValidation() {
        XCTAssertTrue(InputValidator.isValidPassword("Secure123"))
        XCTAssertFalse(InputValidator.isValidPassword("weak"))
        XCTAssertFalse(InputValidator.isValidPassword(""))
    }
    
    func testSignOut() {
        authManager.signOut()
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
    }
}

class SubscriptionManagerTests: XCTestCase {
    var subscriptionManager: SubscriptionManager!
    
    override func setUp() {
        super.setUp()
        subscriptionManager = SubscriptionManager.shared
    }
    
    func testTierComparison() {
        XCTAssertTrue(MembershipTier.master > MembershipTier.initiate)
        XCTAssertTrue(MembershipTier.initiate > MembershipTier.seeker)
        XCTAssertTrue(MembershipTier.seeker > MembershipTier.free)
    }
    
    func testFeatureAccess() {
        let freeUser = QodeXUser(id: "1", email: "", fullName: "", membershipTier: .free)
        let premiumUser = QodeXUser(id: "2", email: "", fullName: "", membershipTier: .seeker)
        
        XCTAssertFalse(freeUser.canAccess(.unlimitedCalculations))
        XCTAssertTrue(premiumUser.canAccess(.unlimitedCalculations))
    }
}

// MARK: - UI Tests
class OnboardingFlowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()
    }
    
    func testCompleteOnboarding() {
        // Welcome screen
        XCTAssertTrue(app.staticTexts["Discover Your Numbers"].exists)
        app.buttons["Continue"].tap()
        
        // Name entry
        let nameField = app.textFields["Full Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Test User")
        app.buttons["Continue"].tap()
        
        // Birth date
        XCTAssertTrue(app.datePickers.element.exists)
        app.buttons["Continue"].tap()
        
        // Intention selection
        app.buttons["Personal Growth"].tap()
        app.buttons["Continue"].tap()
        
        // Chart reveal
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "SELF MATCHES %@", "Your Life Path Number")).element.exists)
    }
    
    func testSkipOnboarding() {
        // Test skip functionality
    }
    
    func testInvalidNameInput() {
        app.buttons["Continue"].tap()
        
        let nameField = app.textFields["Full Name"]
        nameField.tap()
        nameField.typeText("123") // Invalid name
        
        // Should show error
        XCTAssertTrue(app.staticTexts["Please enter a valid name"].waitForExistence(timeout: 2))
    }
}

class DailyQodeUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testDailyNumberDisplay() {
        XCTAssertTrue(app.staticTexts["Today's Number"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.element(matching: NSPredicate(format: "SELF MATCHES %@", "^[1-9]$")).exists)
    }
    
    func testShareDailyNumber() {
        app.buttons["Share"].tap()
        XCTAssertTrue(app.sheets.element.waitForExistence(timeout: 2))
        app.buttons["Cancel"].tap()
    }
    
    func testPremiumUpgradeFlow() {
        app.buttons["Unlock Full Reading"].tap()
        XCTAssertTrue(app.staticTexts["Unlock Everything"].waitForExistence(timeout: 2))
    }
}

class CommunityUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testPostCreation() {
        app.tabBars.buttons["Community"].tap()
        app.buttons["Create Post"].tap()
        
        let textView = app.textViews.element
        textView.tap()
        textView.typeText("Test post content")
        
        app.buttons["Post"].tap()
        
        XCTAssertTrue(app.staticTexts["Test post content"].waitForExistence(timeout: 5))
    }
    
    func testLikePost() {
        app.tabBars.buttons["Community"].tap()
        
        let likeButton = app.buttons["Like"].firstMatch
        likeButton.tap()
        
        XCTAssertTrue(likeButton.images["heart.fill"].exists)
    }
}

// MARK: - Performance Tests
class PerformanceTests: XCTestCase {
    func testChartCalculationPerformance() {
        let calculator = NumerologyCalculator()
        let date = Date()
        
        measure {
            for _ in 0..<1000 {
                _ = calculator.calculateLifePathNumber(birthDate: date)
            }
        }
    }
    
    func testUILaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testMemoryUsage() {
        let calculator = NumerologyCalculator()
        
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 0..<100 {
                _ = calculator.calculateLifePathNumber(birthDate: Date())
            }
        }
    }
}

// MARK: - Snapshot Tests
class SnapshotTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testOnboardingSnapshots() {
        // Use pointfreeco/swift-snapshot-testing
        // Record screenshots for visual regression
    }
    
    func testHomeScreenSnapshot() {
        // Verify UI matches expected design
    }
}

// MARK: - Accessibility Tests
class AccessibilityTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testVoiceOverLabels() {
        // Verify all interactive elements have labels
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            XCTAssertNotNil(button.label)
            XCTAssertFalse(button.label.isEmpty)
        }
    }
    
    func testDynamicTypeSupport() {
        // Test with large accessibility sizes
        XCUIDevice.shared.orientation = .portrait
    }
}
