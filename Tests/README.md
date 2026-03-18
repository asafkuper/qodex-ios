# QodeX Test Infrastructure

This directory contains the comprehensive test suite for the QodeX iOS application.

## Directory Structure

```
Tests/
├── Unit/
│   ├── Numerology/
│   │   └── NumerologyCalculatorTests.swift    # Life Path, Master Numbers, Edge Cases
│   ├── Validation/
│   │   └── InputValidatorTests.swift          # Email, Date, Name, Password Validation
│   └── Models/
│       └── UserProfileTests.swift             # User Model, Membership Tiers
├── Integration/
│   └── Firebase/
│       └── FirebaseServiceTests.swift         # Firestore CRUD, Error Handling
├── UI/
│   └── OnboardingFlowTests.swift              # UI Tests for Onboarding
└── Helpers/
    ├── MockObjects.swift                      # Mock implementations
    ├── TestDataBuilders.swift                 # Test data builders
    └── TestConfiguration.swift                # Test configuration
```

## Test Frameworks

- **Swift Testing**: Modern testing framework for unit and integration tests
- **XCTest**: Used for UI tests (required by Xcode UI Testing)
- **XCTestPlan**: Organized test execution with configurations

## Running Tests

### All Tests
```bash
xcodebuild test -scheme QodeXTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Unit Tests Only
```bash
xcodebuild test -scheme QodeXTests -destination 'platform=iOS Simulator,name=iPhone 15' -testPlan UnitTests
```

### Integration Tests Only
```bash
xcodebuild test -scheme QodeXTests -destination 'platform=iOS Simulator,name=iPhone 15' -testPlan IntegrationTests
```

### UI Tests
```bash
xcodebuild test -scheme QodeXUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### With Tuist
```bash
tuist test
```

## Test Plans

The `QodeX.xctestplan` file defines several test configurations:

- **Unit Tests**: Fast, isolated unit tests
- **Integration Tests**: Firebase and service integration tests
- **UI Tests**: Full UI flow tests
- **All Tests**: Complete test suite
- **Smoke Tests**: Critical path quick tests

## Test Coverage

### Numerology Tests
- Life Path calculation (1-9, 11, 22, 33)
- Master number preservation
- Karmic debt number handling
- Date validation (leap years, century dates)
- Expression, Soul Urge, Personality numbers
- Chart completeness validation

### Validation Tests
- Email format validation
- Birth date validation (not future, reasonable range, minimum age)
- Name validation (characters, length)
- Password strength validation
- Input sanitization (HTML, XSS)
- Rate limiting

### Firebase Tests
- User CRUD operations
- Daily Qode fetching
- Live session management
- Community posts
- Subscription status
- Error handling (network, permissions, not found)

### UI Tests
- Welcome step navigation
- Birth date input
- Life Path result display
- Personalized plan flow
- Validation at each step
- Accessibility compliance

## Mock Objects

The `MockObjects.swift` file provides:

- `MockAuthManager`: Authentication simulation
- `MockSubscriptionManager`: Subscription handling
- `MockNotificationManager`: Notification scheduling
- `MockAnalyticsManager`: Event tracking
- `MockFirebaseService`: Firestore operations
- `MockUserDefaults`: Settings storage
- `MockFileManager`: File operations

## Test Data Builders

The `TestDataBuilders.swift` file provides fluent builders:

```swift
// User builder
let user = UserTestBuilder()
    .withEmail("test@example.com")
    .withMembershipTier(.seeker)
    .withBirthDate(year: 1990, month: 6, day: 15)
    .build()

// Numerology chart builder
let chart = NumerologyChartTestBuilder()
    .withLifePath(11)
    .withExpression(2)
    .build()

// Convenience factories
let freeUser = UserTestBuilder.freeUser()
let masterUser = UserTestBuilder.masterUser()
let lifePath7User = UserTestBuilder.userWithLifePath(7)
```

## Test Tags

Tests are organized with tags for selective running:

- `@Test(.tags(.unit))` - Unit tests
- `@Test(.tags(.integration))` - Integration tests
- `@Test(.tags(.slow))` - Slow tests
- `@Test(.tags(.network))` - Network-dependent tests
- `@Test(.tags(.flaky))` - Known flaky tests

Run tagged tests:
```bash
swift test --filter "numerology"
```

## Best Practices

### 1. Test Naming
- Use descriptive test names
- Follow pattern: `test[Feature]_[Condition]_[ExpectedResult]`

### 2. Test Isolation
- Each test should be independent
- Use `setUp()` and `tearDown()` for test lifecycle
- Reset mocks between tests

### 3. Assertions
- Use Swift Testing's `#expect()` macro
- Prefer specific assertions over generic ones
- Include descriptive messages

### 4. Async Testing
- Use `async/await` for async tests
- Set appropriate timeouts
- Handle cancellation properly

### 5. Mocking
- Mock external dependencies
- Verify mock interactions when important
- Keep mocks simple and focused

## Environment Variables

- `TESTING=1` - Indicates test environment
- `FIRESTORE_EMULATOR_HOST` - Use Firebase emulator
- `VERBOSE_TESTS=1` - Enable verbose logging
- `CI=true` - CI environment detection

## CI/CD Integration

The test suite is configured for CI environments:

```yaml
# Example GitHub Actions
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme QodeXTests \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -testPlan AllTests \
      -enableCodeCoverage YES
```

## Adding New Tests

1. Create test file in appropriate directory
2. Import `@testable import QodeX`
3. Use `@Suite` for test organization
4. Use `@Test` for individual tests
5. Run tests to verify

## Troubleshooting

### Tests Not Running
- Check target membership
- Verify test plan configuration
- Clean build folder

### Firebase Tests Failing
- Check emulator is running: `firebase emulators:start`
- Verify `FIRESTORE_EMULATOR_HOST` is set

### UI Tests Flaky
- Increase timeouts
- Add stability waits
- Check for animations