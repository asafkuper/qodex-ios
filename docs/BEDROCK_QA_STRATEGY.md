# QodeX iOS - QA Strategy & Testing Framework

**Document Owner:** BEDROCK (Test Lead / Product)  
**Version:** 1.0  
**Date:** March 16, 2026  
**Status:** IN PROGRESS

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Untested Critical Paths](#untested-critical-paths)
3. [Test Cases for Core Features](#test-cases-for-core-features)
4. [UI Testing Strategy](#ui-testing-strategy)
5. [QA Process Documentation](#qa-process-documentation)
6. [Test Coverage Matrix](#test-coverage-matrix)
7. [CI/CD Integration](#cicd-integration)
8. [Appendix](#appendix)

---

## Executive Summary

### Current State Assessment

| Metric | Value | Target | Gap |
|--------|-------|--------|-----|
| Total Swift Files | 188 | - | - |
| Test Files | 16 | 50+ | -34 |
| Unit Test Coverage | ~85% (core) | 90% | -5% |
| Integration Tests | 1 | 10+ | -9 |
| UI Tests | 1 | 15+ | -14 |
| Performance Tests | 0 | 5+ | -5 |

### Critical Risk Areas

1. **High Risk:** Esoteric calculation systems (Astrology, Tarot, Kabbalah) lack comprehensive test coverage
2. **High Risk:** Premium feature gating based on membership tiers is untested
3. **Medium Risk:** Offline mode and data synchronization not tested
4. **Medium Risk:** UI/UX flows across 40+ feature views have no automated coverage
5. **Low Risk:** Core numerology calculations are well-tested

### Testing Philosophy

> **"Trust the math, verify the experience, secure the data."**

QodeX combines esoteric mathematics with premium content delivery. Our testing strategy must ensure:
- Mathematical accuracy of all esoteric calculations
- Secure handling of user data and payments
- Seamless premium experience for paid users
- Graceful degradation in offline scenarios

---

## Untested Critical Paths

### 1. Esoteric Calculation Systems (Priority: CRITICAL)

#### 1.1 Astrology System
**Files:** `AstrologyCalculator.swift`, `EphemerisService.swift`, `SiderealAstrologyView.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Birth chart calculation | ❌ None | HIGH | Create comprehensive test suite |
| Planet position calculations | ❌ None | HIGH | Test against known ephemeris data |
| House system calculations | ❌ None | HIGH | Validate Placidus/Whole house systems |
| Transit calculations | ❌ None | MEDIUM | Test date-based transits |
| Aspect calculations | ❌ None | MEDIUM | Test conjunction, opposition, trine, etc. |

**Missing Test Cases:**
```swift
// Required tests for AstrologyCalculator
testBirthChartCalculation() // Verify sun, moon, ascendant
testPlanetPositions() // Against JPL ephemeris data
testHouseSystemAccuracy() // Placidus vs Whole Sign
testTransitTiming() // Verify date calculations
testAspectPatterns() // Grand trine, T-square detection
```

#### 1.2 Tarot System
**Files:** `TarotSystem.swift`, `TarotMinorArcanaIntegration.swift`, `TarotView.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Card drawing randomness | ❌ None | MEDIUM | Verify uniform distribution |
| Spread layout generation | ❌ None | MEDIUM | Test Celtic Cross, 3-card spreads |
| Interpretation matching | ❌ None | MEDIUM | Test card-meaning mapping |
| Reversed card logic | ❌ None | LOW | Test reversal probability |

#### 1.3 Kabbalah System
**Files:** `KabbalahSystem.swift`, `KabbalahView.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Tree of Life path calculations | ❌ None | MEDIUM | Test pathworking algorithms |
| Hebrew letter numerology | ❌ None | MEDIUM | Validate gematria calculations |
| Sefirot attributions | ❌ None | LOW | Test planetary correspondences |

#### 1.4 Sacred Geometry System
**Files:** `SacredGeometrySystem.swift`, `SacredGeometryView.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Shape generation algorithms | ❌ None | MEDIUM | Test Flower of Life, Metatron's Cube |
| Mathematical proportions | ❌ None | MEDIUM | Verify golden ratio calculations |
| AR visualization | ❌ None | HIGH | Test ARKit integration |

### 2. Premium Feature Gating (Priority: CRITICAL)

**Files:** `SubscriptionManager.swift`, `PaywallView.swift`, `EnhancedPaywallView.swift`

| Feature | Free | Seeker | Initiate | Master | Tested? |
|---------|------|--------|----------|--------|---------|
| Life Path Calculator | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daily Qode | ✅ | ✅ | ✅ | ✅ | ✅ |
| Astrology | ❌ | ✅ | ✅ | ✅ | ❌ |
| Tarot | ❌ | ✅ | ✅ | ✅ | ❌ |
| Kabbalah | ❌ | ❌ | ✅ | ✅ | ❌ |
| Sacred Geometry | ❌ | ❌ | ✅ | ✅ | ❌ |
| Frequency Work | ❌ | ❌ | ✅ | ✅ | ❌ |
| Alchemy | ❌ | ❌ | ✅ | ✅ | ❌ |
| Mentorship | ❌ | ❌ | ❌ | ✅ | ❌ |
| 1:1 Sessions | ❌ | ❌ | ❌ | ✅ | ❌ |

**Missing Test Cases:**
```swift
// Required tests for Premium Gating
testAstrologyLockedForFreeUsers()
testAstrologyUnlockedForSeekerPlus()
testMentorshipLockedForNonMaster()
testFeatureAccessAfterSubscriptionExpiry()
testFeatureAccessAfterRestore()
testPaywallPresentationOnLockedFeature()
```

### 3. Data Synchronization (Priority: HIGH)

**Files:** `iCloudSyncManager.swift`, `FirebaseService.swift`, `BackgroundTaskManager.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| iCloud sync conflict resolution | ❌ None | HIGH | Test last-write-wins strategy |
| Firestore offline caching | ⚠️ Partial | MEDIUM | Test cache staleness |
| Background sync scheduling | ❌ None | MEDIUM | Test BGTaskScheduler integration |
| Multi-device sync | ❌ None | HIGH | Test concurrent updates |

### 4. View Models & UI State (Priority: HIGH)

**Files:** 40+ View files with embedded state management

| View | State Complexity | Tested? | Risk |
|------|------------------|---------|------|
| `OnboardingFlow.swift` | HIGH | ⚠️ Partial | MEDIUM |
| `CalculatorView.swift` | MEDIUM | ❌ None | MEDIUM |
| `DailyQodeView_Enhanced.swift` | HIGH | ❌ None | HIGH |
| `CommunityFeedView_Enhanced.swift` | HIGH | ❌ None | HIGH |
| `ProfileHubView.swift` | MEDIUM | ❌ None | MEDIUM |
| `MentorshipMatchingView.swift` | HIGH | ❌ None | HIGH |
| `AIChatView.swift` | MEDIUM | ❌ None | MEDIUM |
| `TarotView.swift` | MEDIUM | ❌ None | MEDIUM |

**Recommendation:** Refactor to MVVM pattern and create ViewModel tests

### 5. Security Components (Priority: HIGH)

**Files:** `SecurityManager.swift`, `KeychainManager.swift`, `BiometricAuth.swift`, `NetworkSecurity.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Keychain operations | ❌ None | HIGH | Test CRUD operations |
| Biometric authentication | ❌ None | MEDIUM | Test Face ID/Touch ID flows |
| Certificate pinning | ❌ None | HIGH | Test SSL pinning |
| Jailbreak detection | ❌ None | MEDIUM | Test detection algorithms |

### 6. AI & ML Components (Priority: MEDIUM)

**Files:** `CoreMLPredictions.swift`, `CoreMLPersonalization.swift`, `SmartReplyGenerator.swift`

| Component | Coverage | Risk | Action Required |
|-----------|----------|------|-----------------|
| Prediction model loading | ❌ None | MEDIUM | Test model availability |
| Personalization engine | ❌ None | MEDIUM | Test recommendation accuracy |
| Smart reply generation | ❌ None | LOW | Test response relevance |

### 7. Performance Critical Paths (Priority: MEDIUM)

| Path | Current Test | Target | Action |
|------|--------------|--------|--------|
| Numerology calculation (10k iterations) | ⚠️ Basic | < 100ms | Add benchmark |
| Chart rendering (complex geometries) | ❌ None | 60 FPS | Add performance test |
| Firestore query (large datasets) | ❌ None | < 500ms | Add integration test |
| Image caching (memory pressure) | ❌ None | No crashes | Add memory test |

---

## Test Cases for Core Features

### 1. Numerology Calculator (✅ Already Well Tested)

**Existing Coverage:** `NumerologyCalculatorComprehensiveTests.swift`

| Test Case | Status | Notes |
|-----------|--------|-------|
| Life Path calculation (1-9, 11, 22, 33) | ✅ | 30+ test cases |
| Expression number from name | ✅ | All letters tested |
| Soul Urge from vowels | ✅ | Edge cases covered |
| Personality from consonants | ✅ | Unicode support |
| Daily number calculation | ✅ | Date-based |
| Personal Year/Month/Day | ✅ | Temporal calculations |
| Compatibility scoring | ✅ | Pair-wise testing |

**Additional Tests Needed:**
```swift
// Edge Cases for Numerology
testLifePathWithInvalidDate() // 02/30/2020
testLifePathWithYearZero() // Edge of Gregorian calendar
testUnicodeNameHandling() // é, ñ, Chinese characters
testVeryLongName() // Performance with 1000+ characters
testEmptyName() // Graceful handling
```

### 2. Authentication Flow (✅ Well Tested)

**Existing Coverage:** `AuthManagerTests.swift`

| Test Case | Status | Notes |
|-----------|--------|-------|
| Email/Password sign up | ✅ | Validation tested |
| Email/Password sign in | ✅ | Error handling |
| Password reset | ✅ | Flow verified |
| Social sign-in (Google) | ⚠️ Mock only | Needs integration test |
| Social sign-in (Apple) | ⚠️ Mock only | Needs integration test |
| Session persistence | ✅ | Token refresh |
| Rate limiting | ✅ | Brute force protection |

### 3. Subscription Management (✅ Well Tested)

**Existing Coverage:** `SubscriptionManagerTests.swift`

| Test Case | Status | Notes |
|-----------|--------|-------|
| Tier comparison | ✅ | Feature matrix |
| Purchase flow | ⚠️ Mock only | Needs sandbox test |
| Restore purchases | ✅ | Transaction restore |
| Expiry handling | ✅ | Grace period logic |
| Upgrade/downgrade | ❌ None | Proration testing |

### 4. Onboarding Flow (⚠️ Partially Tested)

**Existing Coverage:** `OnboardingFlowTests.swift` (UI only)

| Test Case | Status | Priority |
|-----------|--------|----------|
| Welcome screen display | ✅ | - |
| Birthdate input validation | ⚠️ Basic | HIGH |
| Life Path calculation display | ✅ | - |
| Personalized plan generation | ❌ None | HIGH |
| Skip onboarding flow | ❌ None | MEDIUM |
| Return to previous step | ❌ None | MEDIUM |
| Progress persistence | ❌ None | HIGH |

**Test Implementation:**
```swift
@Suite("Onboarding Flow Tests")
struct OnboardingFlowTests {
    
    @Test("Birth date validation - minimum age")
    func testMinimumAgeValidation() async throws {
        let thirteenYearsAgo = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
        let twelveYearsAgo = Calendar.current.date(byAdding: .year, value: -12, to: Date())!
        
        #expect(InputValidator.isValidBirthDate(thirteenYearsAgo) == true)
        #expect(InputValidator.isValidBirthDate(twelveYearsAgo) == false)
    }
    
    @Test("Life Path displays correctly after calculation")
    func testLifePathDisplay() async throws {
        // Test that calculated Life Path matches displayed value
        let birthDate = Date(timeIntervalSince1970: 641596800) // 1990-05-15
        let expectedLifePath = 3
        let calculatedLifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
        
        #expect(calculatedLifePath == expectedLifePath)
    }
    
    @Test("Onboarding progress is saved")
    func testProgressPersistence() {
        let manager = OnboardingManager()
        manager.completeStep(.birthDate)
        
        // Simulate app restart
        let newManager = OnboardingManager()
        #expect(newManager.completedSteps.contains(.birthDate))
    }
}
```

### 5. Daily Qode System (❌ Not Tested)

**New Test Suite Required:** `DailyQodeTests.swift`

```swift
@Suite("Daily Qode System")
struct DailyQodeTests {
    
    // MARK: - Content Generation
    
    @Test("Daily Qode is generated for each Life Path")
    func testDailyQodeGeneration() async throws {
        let service = DailyQodeService()
        let today = Date()
        
        for lifePath in 1...9 {
            let qode = try await service.fetchDailyQode(for: today, lifePath: lifePath)
            #expect(qode != nil)
            #expect(qode.lifePathSpecificContent[String(lifePath)] != nil)
        }
    }
    
    @Test("Daily Qode changes each day")
    func testDailyRotation() async throws {
        let service = DailyQodeService()
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: 1, to: date1)!
        
        let qode1 = try await service.fetchDailyQode(for: date1, lifePath: 5)
        let qode2 = try await service.fetchDailyQode(for: date2, lifePath: 5)
        
        #expect(qode1.id != qode2.id)
    }
    
    @Test("Read status is tracked correctly")
    func testReadStatusTracking() async throws {
        let service = DailyQodeService()
        let userId = "test-user-123"
        let date = Date()
        
        try await service.markAsRead(userId: userId, date: date)
        let isRead = try await service.isRead(userId: userId, date: date)
        
        #expect(isRead == true)
    }
    
    @Test("Offline mode serves cached Qode")
    func testOfflineCaching() async throws {
        let service = DailyQodeService()
        let networkMonitor = NetworkMonitor.shared
        
        // Pre-fetch with network
        let qode = try await service.fetchDailyQode(for: Date(), lifePath: 7)
        
        // Simulate offline
        networkMonitor.simulateOffline()
        
        // Should still return cached Qode
        let cachedQode = try await service.fetchDailyQode(for: Date(), lifePath: 7)
        #expect(cachedQode.id == qode.id)
    }
}
```

### 6. Community System (❌ Not Tested)

**New Test Suite Required:** `CommunitySystemTests.swift`

```swift
@Suite("Community System")
struct CommunitySystemTests {
    
    @Test("Post creation with valid content")
    func testPostCreation() async throws {
        let service = CommunityService()
        let userId = "test-user"
        let content = "Test post content"
        
        let post = try await service.createPost(userId: userId, content: content)
        #expect(post.content == content)
        #expect(post.authorId == userId)
    }
    
    @Test("Post creation blocked for inappropriate content")
    func testContentModeration() async throws {
        let service = CommunityService()
        let content = "Inappropriate content here"
        
        await #expect(throws: ValidationError.inappropriateContent) {
            try await service.createPost(userId: "test", content: content)
        }
    }
    
    @Test("Like functionality")
    func testPostLike() async throws {
        let service = CommunityService()
        let postId = "test-post-123"
        let userId = "test-user"
        
        let initialLikes = try await service.getLikeCount(postId: postId)
        try await service.likePost(userId: userId, postId: postId)
        let newLikes = try await service.getLikeCount(postId: postId)
        
        #expect(newLikes == initialLikes + 1)
    }
    
    @Test("Pagination works correctly")
    func testPostPagination() async throws {
        let service = CommunityService()
        
        let page1 = try await service.fetchPosts(limit: 10, cursor: nil)
        let page2 = try await service.fetchPosts(limit: 10, cursor: page1.cursor)
        
        #expect(page1.posts.count == 10)
        #expect(page2.posts.count > 0)
        #expect(Set(page1.posts).isDisjoint(with: Set(page2.posts)))
    }
}
```

### 7. Astrology Calculations (❌ Not Tested)

**New Test Suite Required:** `AstrologyCalculatorTests.swift`

```swift
@Suite("Astrology Calculations")
struct AstrologyCalculatorTests {
    let calculator = AstrologyCalculator()
    
    // Test data: Known birth chart (Albert Einstein: 1879-03-14)
    let einsteinBirthDate = TestDateFactory.date(year: 1879, month: 3, day: 14, hour: 11, minute: 30)
    let einsteinLocation = GeoLocation(latitude: 48.4011, longitude: 9.9876) // Ulm, Germany
    
    @Test("Sun sign calculation")
    func testSunSign() {
        let chart = calculator.calculateBirthChart(
            birthDate: einsteinBirthDate,
            location: einsteinLocation
        )
        #expect(chart.sunSign == .pisces)
    }
    
    @Test("Moon sign calculation")
    func testMoonSign() {
        let chart = calculator.calculateBirthChart(
            birthDate: einsteinBirthDate,
            location: einsteinLocation
        )
        // Moon was in Sagittarius
        #expect(chart.moonSign == .sagittarius)
    }
    
    @Test("Ascendant calculation")
    func testAscendant() {
        let chart = calculator.calculateBirthChart(
            birthDate: einsteinBirthDate,
            location: einsteinLocation
        )
        // Ascendant was approximately Cancer
        #expect(chart.ascendant == .cancer)
    }
    
    @Test("House cusp calculations")
    func testHouseCusps() {
        let chart = calculator.calculateBirthChart(
            birthDate: einsteinBirthDate,
            location: einsteinLocation
        )
        #expect(chart.houses.count == 12)
        #expect(chart.houses[0].cusp > 0 && chart.houses[0].cusp < 360)
    }
    
    @Test("Aspect calculations")
    func testAspects() {
        let chart = calculator.calculateBirthChart(
            birthDate: einsteinBirthDate,
            location: einsteinLocation
        )
        let aspects = calculator.calculateAspects(in: chart)
        
        // Should find major aspects
        let hasConjunction = aspects.contains { $0.type == .conjunction }
        let hasOpposition = aspects.contains { $0.type == .opposition }
        let hasTrine = aspects.contains { $0.type == .trine }
        
        #expect(hasConjunction || hasOpposition || hasTrine)
    }
}
```

### 8. Tarot System (❌ Not Tested)

**New Test Suite Required:** `TarotSystemTests.swift`

```swift
@Suite("Tarot System")
struct TarotSystemTests {
    let tarot = TarotSystem()
    
    @Test("Card deck contains 78 cards")
    func testDeckSize() {
        let deck = tarot.createDeck()
        #expect(deck.cards.count == 78)
    }
    
    @Test("Major Arcana contains 22 cards")
    func testMajorArcana() {
        let majorArcana = tarot.majorArcana
        #expect(majorArcana.count == 22)
        #expect(majorArcana[0].name == "The Fool")
        #expect(majorArcana[21].name == "The World")
    }
    
    @Test("Card drawing is random")
    func testRandomDrawing() {
        var draws: [TarotCard] = []
        for _ in 0..<100 {
            draws.append(tarot.drawCard())
        }
        
        // Expect variety in draws
        let uniqueCards = Set(draws.map { $0.id })
        #expect(uniqueCards.count > 10) // Should draw different cards
    }
    
    @Test("Three card spread layout")
    func testThreeCardSpread() {
        let spread = tarot.generateSpread(type: .threeCard)
        #expect(spread.positions.count == 3)
        #expect(spread.positions[0].meaning == "Past")
        #expect(spread.positions[1].meaning == "Present")
        #expect(spread.positions[2].meaning == "Future")
    }
    
    @Test("Celtic Cross spread layout")
    func testCelticCrossSpread() {
        let spread = tarot.generateSpread(type: .celticCross)
        #expect(spread.positions.count == 10)
    }
    
    @Test("Reversed cards appear at expected rate")
    func testReversalRate() {
        var reversedCount = 0
        let totalDraws = 1000
        
        for _ in 0..<totalDraws {
            let card = tarot.drawCard(includeReversals: true)
            if card.isReversed {
                reversedCount += 1
            }
        }
        
        let reversalRate = Double(reversedCount) / Double(totalDraws)
        // Expected ~50% reversal rate
        #expect(reversalRate > 0.4 && reversalRate < 0.6)
    }
}
```

---

## UI Testing Strategy

### 1. Testing Pyramid

```
        /\
       /  \
      / UI \          10% - Critical flows
     /------\         (XCUITest)
    /        \
   /Integration\      20% - Service integration
  /--------------\     (XCTest + Mock)
 /                \
/     Unit Tests   \   70% - Business logic
/--------------------\  (Swift Testing)
```

### 2. UI Test Coverage Plan

| Flow | Priority | Tests Needed | Estimated Time |
|------|----------|--------------|----------------|
| Onboarding | P0 | 8 | 4h |
| Calculator | P0 | 6 | 3h |
| Daily Qode | P0 | 5 | 2.5h |
| Paywall/Purchase | P0 | 10 | 5h |
| Profile Management | P1 | 6 | 3h |
| Community | P1 | 8 | 4h |
| Astrology | P1 | 5 | 3h |
| Tarot | P1 | 4 | 2h |
| Settings | P2 | 4 | 2h |
| Journal | P2 | 3 | 1.5h |

### 3. UI Test Implementation

**File:** `Tests/UI/CompleteUserFlowTests.swift`

```swift
import XCTest

final class CompleteUserFlowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()
    }
    
    // MARK: - Onboarding Flow
    
    func testCompleteOnboardingFlow() {
        // Welcome screen
        XCTAssertTrue(app.staticTexts["Welcome to QodeX"].waitForExistence(timeout: 5))
        app.buttons["Begin Your Journey"].tap()
        
        // Birth date input
        XCTAssertTrue(app.datePickers["birthDatePicker"].waitForExistence(timeout: 5))
        app.datePickers["birthDatePicker"].tap()
        // Select date: March 15, 1990
        app.pickerWheels.element(boundBy: 0].adjust(toPickerWheelValue: "March")
        app.pickerWheels.element(boundBy: 1].adjust(toPickerWheelValue: "15")
        app.pickerWheels.element(boundBy: 2].adjust(toPickerWheelValue: "1990")
        app.buttons["Continue"].tap()
        
        // Life Path result
        XCTAssertTrue(app.staticTexts["Your Life Path Number"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1"].exists) // 03/15/1990 = 1
        app.buttons["See Your Personalized Plan"].tap()
        
        // Personalized plan / Paywall
        XCTAssertTrue(app.staticTexts["Unlock Your Full Potential"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Calculator Flow
    
    func testCalculatorWithDifferentInputs() {
        // Skip onboarding if needed
        skipOnboardingIfNeeded()
        
        // Navigate to Calculator tab
        app.tabBars.buttons["Qode"].tap()
        
        // Enter name
        let nameField = app.textFields["fullNameField"]
        nameField.tap()
        nameField.typeText("John Doe")
        
        // Enter birth date
        app.datePickers["birthDatePicker"].tap()
        app.pickerWheels.element(boundBy: 0].adjust(toPickerWheelValue: "June")
        app.pickerWheels.element(boundBy: 1].adjust(toPickerWheelValue: "15")
        app.pickerWheels.element(boundBy: 2].adjust(toPickerWheelValue: "1985")
        
        // Calculate
        app.buttons["Calculate"].tap()
        
        // Verify results appear
        XCTAssertTrue(app.staticTexts["Life Path Number"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Expression Number"].exists)
        XCTAssertTrue(app.staticTexts["Soul Urge Number"].exists)
    }
    
    // MARK: - Daily Qode Flow
    
    func testDailyQodeFlow() {
        skipOnboardingIfNeeded()
        
        // Navigate to Home/Daily Qode
        app.tabBars.buttons["Home"].tap()
        
        // Verify Daily Qode is displayed
        XCTAssertTrue(app.staticTexts["Today's Qode"].waitForExistence(timeout: 5))
        
        // Test share functionality
        app.buttons["shareButton"].tap()
        XCTAssertTrue(app.sheets["Share"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        
        // Test save/bookmark
        app.buttons["bookmarkButton"].tap()
        // Verify bookmark state changed
        XCTAssertTrue(app.buttons["bookmarkButton"].isSelected)
    }
    
    // MARK: - Subscription Flow
    
    func testPaywallPresentationAndDismissal() {
        skipOnboardingIfNeeded()
        
        // Navigate to a premium feature (Astrology)
        app.tabBars.buttons["Teachings"].tap()
        app.buttons["Astrology"].tap()
        
        // Paywall should appear for free user
        XCTAssertTrue(app.staticTexts["Unlock Astrology"].waitForExistence(timeout: 5))
        
        // Test dismissal
        app.buttons["Not Now"].tap()
        
        // Should return to previous screen
        XCTAssertTrue(app.staticTexts["Teachings"].waitForExistence(timeout: 5))
    }
    
    func testSubscriptionTierSelection() {
        // Navigate to paywall
        navigateToPaywall()
        
        // Test tier selection
        app.buttons["Seeker Monthly"].tap()
        XCTAssertTrue(app.buttons["Seeker Monthly"].isSelected)
        
        app.buttons["Initiate Annual"].tap()
        XCTAssertTrue(app.buttons["Initiate Annual"].isSelected)
        
        // Test purchase button (would be mocked in UI test)
        app.buttons["Start Your Journey"].tap()
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        skipOnboardingIfNeeded()
        
        // Verify all tabs have accessibility labels
        let tabs = ["Home", "Qode", "Teachings", "Circle", "Profile"]
        for tab in tabs {
            let tabButton = app.tabBars.buttons[tab]
            XCTAssertTrue(tabButton.exists, "Tab \(tab) should exist")
            XCTAssertNotNil(tabButton.label, "Tab \(tab) should have accessibility label")
        }
    }
    
    func testDynamicTypeSupport() {
        // Set large text size
        app.launchEnvironment = ["UI_TEST_DYNAMIC_TYPE": "UICTContentSizeCategoryAccessibilityXXL"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Verify content is still accessible
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Today's Qode"].exists)
        
        // Verify no text truncation/clipping
        let qodeText = app.staticTexts["qodeContentText"]
        XCTAssertTrue(qodeText.isHittable)
    }
    
    // MARK: - Offline Mode
    
    func testOfflineBehavior() {
        skipOnboardingIfNeeded()
        
        // Enable airplane mode (would use a mock or network conditioning)
        enableAirplaneMode()
        
        // Try to load content
        app.tabBars.buttons["Home"].tap()
        
        // Should show cached content or offline message
        let offlineMessage = app.staticTexts["You're offline"]
        let cachedContent = app.staticTexts["Today's Qode"]
        
        XCTAssertTrue(offlineMessage.exists || cachedContent.exists)
    }
    
    // MARK: - Helper Methods
    
    private func skipOnboardingIfNeeded() {
        if app.buttons["Begin Your Journey"].exists {
            // Complete onboarding quickly
            app.buttons["Begin Your Journey"].tap()
            app.datePickers["birthDatePicker"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Skip for Now"].tap()
        }
    }
    
    private func navigateToPaywall() {
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Teachings"].tap()
        app.buttons["Astrology"].tap()
    }
    
    private func enableAirplaneMode() {
        // In real implementation, use network conditioning or mock
        // XCUIDevice.shared.press(.home)
        // ... toggle airplane mode via Control Center
    }
}
```

### 4. Snapshot Testing

**File:** `Tests/Snapshot/SnapshotTests.swift`

```swift
import XCTest
import SnapshotTesting
@testable import QodeX

final class SnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Use dark mode for consistent snapshots
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }
    
    func testOnboardingWelcomeScreen() {
        let view = OnboardingWelcomeStep()
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testCalculatorView() {
        let view = CalculatorView_Previews.previews
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testDailyQodeView() {
        let view = DailyQodeView_Previews.previews
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testPaywallView() {
        let view = PaywallView_Previews.previews
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testProfileView() {
        let view = ProfileView_Previews.previews
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
```

---

## QA Process Documentation

### 1. QA Workflow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Developer │───▶│   Unit Test │───▶│   PR Opened │───▶│  CI Checks  │
│   Completes │    │    Locally  │    │             │    │   (Automated)│
│    Feature  │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                │
                                                                ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Feature   │◀───│   Bug Fix   │◀───│  QA Manual  │◀───│  Automated  │
│   Merged    │    │   & Verify  │    │   Testing   │    │    Pass     │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### 2. Release Checklist

#### Pre-Release QA (2 weeks before)

- [ ] All unit tests passing (85%+ coverage)
- [ ] All integration tests passing
- [ ] UI automation suite passing on 3 device sizes
- [ ] Accessibility audit completed (VoiceOver)
- [ ] Performance benchmarks met
- [ ] Security scan completed (no hardcoded secrets)
- [ ] Localization verified (all supported languages)
- [ ] Dark mode verified
- [ ] Dynamic Type (accessibility text sizes) verified

#### Release Candidate Testing (1 week before)

- [ ] Smoke test on physical devices (iPhone SE, 15, 15 Pro Max)
- [ ] Battery usage test (1 hour typical use < 10%)
- [ ] Memory leak test (Instruments)
- [ ] Network condition testing (slow, offline, airplane mode)
- [ ] Subscription purchase flow (sandbox)
- [ ] Push notification delivery
- [ ] Background app refresh
- [ ] App Store review guidelines compliance

#### Final Validation (Day of release)

- [ ] Version number incremented
- [ ] Release notes finalized
- [ ] App Store screenshots current
- [ ] App Store description updated
- [ ] Privacy policy link verified
- [ ] Support URL verified
- [ ] Build uploaded and processing
- [ ] Beta group notified

### 3. Bug Severity Definitions

| Severity | Definition | Response Time | Example |
|----------|------------|---------------|---------|
| **P0 - Critical** | App crash, data loss, security breach | Fix in 24h | Crash on launch, payment charged but not recorded |
| **P1 - High** | Core feature broken, workaround difficult | Fix in 3 days | Life Path calculation wrong, can't complete onboarding |
| **P2 - Medium** | Feature degraded, workaround available | Fix in 1 week | Slow loading, minor UI glitches |
| **P3 - Low** | Cosmetic, enhancement request | Fix in next sprint | Color mismatch, typo |

### 4. Test Environments

| Environment | Purpose | Data |
|-------------|---------|------|
| **Unit Test** | Fast business logic validation | Mock data |
| **Integration** | Service interaction testing | Firebase emulator |
| **UI Local** | View behavior validation | Stubbed data |
| **Staging** | Pre-release validation | Production-like |
| **Beta (TestFlight)** | User acceptance testing | Production data |
| **Production** | Live user monitoring | Real data |

### 5. Regression Testing Schedule

| Frequency | Scope | Duration |
|-----------|-------|----------|
| **Per PR** | Affected unit tests | < 2 minutes |
| **Daily** | Full unit test suite | ~5 minutes |
| **Weekly** | Integration + UI smoke tests | ~30 minutes |
| **Pre-Release** | Full regression suite | ~4 hours |
| **Post-Release** | Critical path monitoring | Continuous |

---

## Test Coverage Matrix

### Current vs Target Coverage

| Module | Current | Target | Gap | Priority |
|--------|---------|--------|-----|----------|
| Numerology Calculator | 90% | 95% | -5% | P2 |
| Auth Manager | 85% | 90% | -5% | P2 |
| Subscription Manager | 85% | 90% | -5% | P2 |
| Cache Manager | 80% | 85% | -5% | P2 |
| Notification Manager | 85% | 90% | -5% | P2 |
| Input Validator | 90% | 95% | -5% | P2 |
| Date Extensions | 85% | 90% | -5% | P2 |
| String Extensions | 85% | 90% | -5% | P2 |
| Astrology Calculator | 0% | 85% | -85% | **P0** |
| Tarot System | 0% | 80% | -80% | **P0** |
| Kabbalah System | 0% | 75% | -75% | **P1** |
| Sacred Geometry | 0% | 75% | -75% | **P1** |
| Firebase Service | 20% | 80% | -60% | **P0** |
| View Models | 0% | 75% | -75% | **P1** |
| UI Components | 0% | 60% | -60% | **P1** |
| Security Manager | 0% | 90% | -90% | **P0** |
| **OVERALL** | **~45%** | **80%** | **-35%** | - |

---

## CI/CD Integration

### GitHub Actions Workflow

**File:** `.github/workflows/qa-pipeline.yml`

```yaml
name: QA Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.2'
      
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme QodeX \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -testPlan UnitTests \
            -enableCodeCoverage YES \
            -derivedDataPath DerivedData
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: DerivedData/Build/ProfileData/*/Coverage.profdata
          fail_ci_if_error: true

  integration-tests:
    runs-on: macos-14
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Firebase Emulator
        run: |
          npm install -g firebase-tools
          firebase emulators:start --only firestore &
          sleep 10
      
      - name: Run Integration Tests
        run: |
          xcodebuild test \
            -scheme QodeX \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -testPlan IntegrationTests
        env:
          FIRESTORE_EMULATOR_HOST: localhost:8080

  ui-tests:
    runs-on: macos-14
    needs: unit-tests
    strategy:
      matrix:
        device: ['iPhone 15', 'iPhone SE (3rd generation)', 'iPad Pro (12.9-inch)']
    steps:
      - uses: actions/checkout@v4
      
      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme QodeXUITests \
            -destination 'platform=iOS Simulator,name=${{ matrix.device }}' \
            -testPlan UITests

  snapshot-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Snapshot Tests
        run: |
          xcodebuild test \
            -scheme QodeX \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -testPlan SnapshotTests
      
      - name: Upload Snapshots
        uses: actions/upload-artifact@v4
        with:
          name: snapshots
          path: Tests/Snapshot/__Snapshots__

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Security Scan
        run: |
          # Check for hardcoded secrets
          grep -r "api_key\|password\|secret" --include="*.swift" . || true
          
          # Run SwiftLint security rules
          swiftlint lint --reporter github-actions-logging
```

### Test Plans

**File:** `QodeX.xctestplan`

```json
{
  "configurations": [
    {
      "name": "Unit Tests",
      "options": {
        "testExecutionOrdering": "random",
        "codeCoverage": true
      },
      "testTargets": [
        {
          "target": "QodeXTests",
          "tests": [
            "NumerologyCalculatorComprehensiveTests",
            "AuthManagerTests",
            "SubscriptionManagerTests",
            "CacheManagerTests",
            "NotificationManagerTests",
            "InputValidatorTests",
            "DateExtensionsTests",
            "StringExtensionsTests"
          ]
        }
      ]
    },
    {
      "name": "Integration Tests",
      "options": {
        "testExecutionOrdering": "random"
      },
      "testTargets": [
        {
          "target": "QodeXTests",
          "tests": ["FirebaseServiceTests"]
        }
      ]
    },
    {
      "name": "UI Tests",
      "options": {
        "testExecutionOrdering": "random",
        "testTimeouts": {
          "default": 120
        }
      },
      "testTargets": [
        {
          "target": "QodeXUITests",
          "tests": ["CompleteUserFlowTests"]
        }
      ]
    }
  ]
}
```

---

## Appendix

### A. Test Data Reference

#### Life Path Test Data

| Birth Date | Expected Life Path | Notes |
|------------|-------------------|-------|
| 1990-03-15 | 1 | 1+9+9+0+0+3+1+5 = 28 → 10 → 1 |
| 2000-01-01 | 4 | 2+0+0+0+0+1+0+1 = 4 |
| 1995-12-25 | 7 | 1+9+9+5+1+2+2+5 = 34 → 7 |
| 1980-06-15 | 3 | 1+9+8+0+0+6+1+5 = 30 → 3 |
| 1975-11-11 | 8 | 1+9+7+5+1+1+1+1 = 26 → 8 |
| 1988-11-11 | 3 | 1+9+8+8+1+1+1+1 = 30 → 3 |
| 1999-01-01 | 3 | 1+9+9+9+0+1+0+1 = 30 → 3 |
| 2020-02-29 | 8 | 2+0+2+0+0+2+2+9 = 17 → 8 (leap year) |

#### Test User Profiles

```swift
struct TestUsers {
    static let freeUser = UserTestBuilder()
        .withEmail("free@example.com")
        .withMembershipTier(.free)
        .build()
    
    static let seekerUser = UserTestBuilder()
        .withEmail("seeker@example.com")
        .withMembershipTier(.seeker)
        .withSubscriptionExpiry(Date().addingTimeInterval(30*24*60*60))
        .build()
    
    static let masterUser = UserTestBuilder()
        .withEmail("master@example.com")
        .withMembershipTier(.master)
        .build()
    
    static let expiredUser = UserTestBuilder()
        .withEmail("expired@example.com")
        .withMembershipTier(.seeker)
        .withSubscriptionExpiry(Date().addingTimeInterval(-7*24*60*60))
        .build()
}
```

### B. Testing Tools & Libraries

| Tool | Purpose | Version |
|------|---------|---------|
| XCTest | Unit & UI testing | Built-in |
| Swift Testing | Modern unit testing | Built-in (Xcode 15+) |
| SnapshotTesting | UI regression testing | 1.15+ |
| Firebase Emulator | Local backend testing | Latest |
| SwiftLint | Code quality | 0.54+ |
| Slather | Code coverage | 2.8+ |
| Fastlane | Automation | 2.219+ |

### C. File Organization

```
Tests/
├── Unit/
│   ├── Numerology/
│   │   ├── NumerologyCalculatorTests.swift
│   │   └── NumerologyCalculatorComprehensiveTests.swift
│   ├── Auth/
│   │   └── AuthManagerTests.swift
│   ├── Subscription/
│   │   └── SubscriptionManagerTests.swift
│   ├── Esoteric/
│   │   ├── AstrologyCalculatorTests.swift ⭐ NEW
│   │   ├── TarotSystemTests.swift ⭐ NEW
│   │   └── KabbalahSystemTests.swift ⭐ NEW
│   ├── Cache/
│   │   └── CacheManagerTests.swift
│   ├── Notifications/
│   │   └── NotificationManagerTests.swift
│   ├── Validation/
│   │   └── InputValidatorTests.swift
│   ├── Models/
│   │   └── UserProfileTests.swift
│   ├── Security/
│   │   ├── KeychainManagerTests.swift ⭐ NEW
│   │   └── BiometricAuthTests.swift ⭐ NEW
│   └── Extensions/
│       ├── DateExtensionsTests.swift
│       └── StringExtensionsTests.swift
├── Integration/
│   ├── Firebase/
│   │   └── FirebaseServiceTests.swift
│   ├── RevenueCat/
│   │   └── PurchaseFlowTests.swift ⭐ NEW
│   └── Sync/
│       └── iCloudSyncTests.swift ⭐ NEW
├── UI/
│   ├── OnboardingFlowTests.swift
│   └── CompleteUserFlowTests.swift ⭐ NEW
├── Snapshot/
│   └── SnapshotTests.swift
├── Performance/
│   ├── NumerologyPerformanceTests.swift ⭐ NEW
│   └── ChartRenderingTests.swift ⭐ NEW
└── Helpers/
    ├── MockObjects.swift
    ├── TestDataBuilders.swift
    └── TestConfiguration.swift
```

### D. Key Contacts

| Role | Responsibility | Contact |
|------|----------------|---------|
| Test Lead (BEDROCK) | QA strategy, test planning | @bedrock |
| Dev Lead | Test implementation support | @sage |
| Product Owner | Feature priority, acceptance criteria | @product |
| Security Lead | Security testing oversight | @security |

---

**Document History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-16 | BEDROCK | Initial QA strategy document |

---

*"Quality is not an act, it is a habit." - Aristotle*
