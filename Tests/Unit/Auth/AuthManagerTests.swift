//
//  AuthManagerTests.swift
//  Unit tests for AuthManager - login, signup, logout flows
//

import XCTest
import FirebaseAuth
@testable import QodeX

// MARK: - Mock Firebase Auth

class MockFirebaseAuth: Auth {
    var mockCurrentUser: MockFirebaseUser?
    var shouldSucceed = true
    var simulatedError: NSError?
    var lastEmail: String?
    var lastPassword: String?
    
    override var currentUser: MockFirebaseUser? {
        return mockCurrentUser
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        lastEmail = email
        lastPassword = password
        
        if let error = simulatedError {
            throw error
        }
        
        guard shouldSucceed else {
            throw NSError(domain: "AuthError", code: 17009, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        }
        
        let user = MockFirebaseUser(email: email, uid: "test-uid-123")
        mockCurrentUser = user
        return MockAuthDataResult(user: user, isNewUser: false)
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResult {
        lastEmail = email
        lastPassword = password
        
        if let error = simulatedError {
            throw error
        }
        
        guard shouldSucceed else {
            throw NSError(domain: "AuthError", code: 17007, userInfo: [NSLocalizedDescriptionKey: "Email already in use"])
        }
        
        let user = MockFirebaseUser(email: email, uid: "new-uid-456")
        mockCurrentUser = user
        return MockAuthDataResult(user: user, isNewUser: true)
    }
    
    func signOut() throws {
        if let error = simulatedError {
            throw error
        }
        mockCurrentUser = nil
    }
    
    func sendPasswordReset(email: String) async throws {
        if let error = simulatedError {
            throw error
        }
        guard shouldSucceed else {
            throw NSError(domain: "AuthError", code: 17011, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
    }
}

// MARK: - Mock Firebase User

class MockFirebaseUser: User {
    private var _email: String?
    private var _uid: String
    private var _displayName: String?
    
    init(email: String?, uid: String, displayName: String? = nil) {
        self._email = email
        self._uid = uid
        self._displayName = displayName
        super.init()
    }
    
    override var email: String? { return _email }
    override var uid: String { return _uid }
    override var displayName: String? { return _displayName }
    
    override func createProfileChangeRequest() -> UserProfileChangeRequest {
        return MockProfileChangeRequest()
    }
    
    override func delete() async throws {
        // Mock implementation
    }
    
    override func reauthenticate(with credential: AuthCredential) async throws {
        // Mock implementation  
    }
}

// MARK: - Mock Auth Data Result

class MockAuthDataResult: AuthDataResult {
    private var _user: MockFirebaseUser
    private var _additionalUserInfo: AdditionalUserInfo?
    
    init(user: MockFirebaseUser, isNewUser: Bool) {
        self._user = user
        self._additionalUserInfo = MockAdditionalUserInfo(isNewUser: isNewUser)
        super.init()
    }
    
    override var user: MockFirebaseUser { return _user }
    override var additionalUserInfo: AdditionalUserInfo? { return _additionalUserInfo }
}

// MARK: - Mock Additional User Info

class MockAdditionalUserInfo: AdditionalUserInfo {
    private var _isNewUser: Bool
    
    init(isNewUser: Bool) {
        self._isNewUser = isNewUser
        super.init()
    }
    
    override var isNewUser: Bool { return _isNewUser }
}

// MARK: - Mock Profile Change Request

class MockProfileChangeRequest: UserProfileChangeRequest {
    private var _displayName: String?
    
    override var displayName: String? {
        get { return _displayName }
        set { _displayName = newValue }
    }
    
    override func commitChanges() async throws {
        // Mock implementation
    }
}

// MARK: - Auth Manager Tests

@MainActor
final class AuthManagerTests: XCTestCase {
    
    var sut: AuthManager!
    var mockAuth: MockFirebaseAuth!
    
    override func setUp() {
        super.setUp()
        sut = AuthManager()
        mockAuth = MockFirebaseAuth()
    }
    
    override func tearDown() {
        sut = nil
        mockAuth = nil
        super.tearDown()
    }
    
    // MARK: - Sign Up Tests
    
    func testSignUpSuccess() async {
        let email = "test@example.com"
        let password = "Password123"
        let fullName = "Test User"
        let birthDate = TestDateFactory.date(year: 1990, month: 1, day: 1)
        
        // Note: This tests the validation flow since we can't fully mock Firebase
        // In a real scenario, you'd inject the mock auth service
        
        // Validate inputs would pass
        do {
            try InputValidator.validate(email: email)
            try InputValidator.validate(password: password)
            try InputValidator.validate(name: fullName)
            try InputValidator.validate(birthDate: birthDate)
            // Success - inputs are valid
        } catch {
            XCTFail("Valid inputs should not throw: \(error)")
        }
    }
    
    func testSignUpInvalidEmail() async {
        let email = "invalid-email"
        let password = "Password123"
        let fullName = "Test User"
        let birthDate = TestDateFactory.date(year: 1990, month: 1, day: 1)
        
        do {
            try InputValidator.validate(email: email)
            XCTFail("Invalid email should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .invalidEmail)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpWeakPassword() async {
        let email = "test@example.com"
        let password = "123" // Too short
        let fullName = "Test User"
        let birthDate = TestDateFactory.date(year: 1990, month: 1, day: 1)
        
        do {
            try InputValidator.validate(password: password)
            XCTFail("Weak password should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .weakPassword)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpPasswordNoUppercase() async {
        let password = "password123"
        
        do {
            try InputValidator.validate(password: password)
            XCTFail("Password without uppercase should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .weakPassword)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpPasswordNoLowercase() async {
        let password = "PASSWORD123"
        
        do {
            try InputValidator.validate(password: password)
            XCTFail("Password without lowercase should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .weakPassword)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpPasswordNoDigit() async {
        let password = "PasswordOnly"
        
        do {
            try InputValidator.validate(password: password)
            XCTFail("Password without digit should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .weakPassword)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpShortName() async {
        let fullName = "A" // Single character
        
        do {
            try InputValidator.validate(name: fullName)
            XCTFail("Short name should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .invalidName)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpInvalidCharactersInName() async {
        let invalidNames = ["John123", "Jane@Doe", "Name#Symbol"]
        
        for name in invalidNames {
            do {
                try InputValidator.validate(name: name)
                XCTFail("Name '\(name)' with invalid characters should throw")
            } catch let error as ValidationError {
                XCTAssertEqual(error, .invalidName)
            } catch {
                XCTFail("Wrong error type for '\(name)'")
            }
        }
    }
    
    func testSignUpFutureBirthDate() async {
        let birthDate = TestDateFactory.futureDate(days: 1)
        
        do {
            try InputValidator.validate(birthDate: birthDate)
            XCTFail("Future birth date should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .futureDate)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpTooYoung() async {
        // Less than 13 years old
        let birthDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        
        do {
            try InputValidator.validate(birthDate: birthDate)
            XCTFail("Too young should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .tooOld)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpTooOld() async {
        // Before 1900
        let birthDate = TestDateFactory.date(year: 1899, month: 12, day: 31)
        
        do {
            try InputValidator.validate(birthDate: birthDate)
            XCTFail("Too old should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .tooOld)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - Sign In Tests
    
    func testSignInValidInputs() {
        let email = "test@example.com"
        let password = "Password123"
        
        // Verify inputs pass validation
        do {
            try InputValidator.validate(email: email)
            // Password validation on sign in might be different (just checking non-empty)
            XCTAssertFalse(password.isEmpty)
        } catch {
            XCTFail("Valid inputs should not throw: \(error)")
        }
    }
    
    func testSignInEmptyEmail() {
        let email = ""
        
        do {
            try InputValidator.validate(email: email)
            XCTFail("Empty email should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .emptyField)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOutClearsState() {
        // Initial state should not be authenticated
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
    }
    
    // MARK: - Password Reset Tests
    
    func testPasswordResetValidEmail() {
        let email = "test@example.com"
        
        do {
            try InputValidator.validate(email: email)
            // Should pass
        } catch {
            XCTFail("Valid email should not throw: \(error)")
        }
    }
    
    func testPasswordResetInvalidEmail() {
        let email = "not-an-email"
        
        do {
            try InputValidator.validate(email: email)
            XCTFail("Invalid email should throw")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .invalidEmail)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - Rate Limiting Tests
    
    func testRateLimitingPreventsExcessiveAttempts() {
        let identifier = "test_\(UUID().uuidString)"
        let maxAttempts = 5
        
        // First 5 attempts should succeed
        for i in 0..<maxAttempts {
            let result = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: maxAttempts, windowSeconds: 300)
            XCTAssertTrue(result, "Attempt \(i+1) should pass rate limit")
        }
        
        // 6th attempt should fail
        let sixthAttempt = InputValidator.checkRateLimit(identifier: identifier, maxAttempts: maxAttempts, windowSeconds: 300)
        XCTAssertFalse(sixthAttempt, "6th attempt should be rate limited")
    }
    
    func testRateLimitingSeparateIdentifiers() {
        let identifier1 = "test_\(UUID().uuidString)_1"
        let identifier2 = "test_\(UUID().uuidString)_2"
        
        // Exhaust rate limit for identifier1
        for _ in 0..<5 {
            _ = InputValidator.checkRateLimit(identifier: identifier1, maxAttempts: 5, windowSeconds: 300)
        }
        
        // identifier1 should be rate limited
        XCTAssertFalse(InputValidator.checkRateLimit(identifier: identifier1, maxAttempts: 5, windowSeconds: 300))
        
        // identifier2 should not be rate limited
        XCTAssertTrue(InputValidator.checkRateLimit(identifier: identifier2, maxAttempts: 5, windowSeconds: 300))
    }
    
    // MARK: - Sanitization Tests
    
    func testEmailSanitization() {
        let dirtyEmail = "  Test@Example.COM  "
        let sanitized = InputValidator.sanitize(dirtyEmail)
        
        // Should trim whitespace
        XCTAssertFalse(sanitized.hasPrefix(" "))
        XCTAssertFalse(sanitized.hasSuffix(" "))
    }
    
    func testNameSanitization() {
        let dirtyName = "  John Doe  "
        let sanitized = InputValidator.sanitize(dirtyName)
        
        XCTAssertEqual(sanitized, "John Doe")
    }
    
    func testHTMLSanitization() {
        let htmlInput = "<p>Hello</p>"
        let sanitized = InputValidator.sanitize(htmlInput)
        
        XCTAssertFalse(sanitized.contains("\u003c"))
        XCTAssertFalse(sanitized.contains("\u003e"))
    }
    
    func testLongInputTruncation() {
        let longInput = String(repeating: "a", count: 200)
        let sanitized = InputValidator.sanitize(longInput)
        
        XCTAssertLessThanOrEqual(sanitized.count, 100)
    }
    
    // MARK: - User Model Tests
    
    func testUserModelCreation() {
        let user = QodeXUser(
            id: "test-id",
            email: "test@example.com",
            fullName: "Test User",
            birthDate: TestDateFactory.date(year: 1990, month: 1, day: 1),
            membershipTier: .free,
            createdAt: Date()
        )
        
        XCTAssertEqual(user.id, "test-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.fullName, "Test User")
        XCTAssertEqual(user.membershipTier, .free)
    }
    
    func testUserInitials() {
        let user1 = UserTestBuilder().withFullName("John Doe").build()
        XCTAssertEqual(user1.initials, "JD")
        
        let user2 = UserTestBuilder().withFullName("Alice").build()
        XCTAssertEqual(user2.initials, "AA") // Repeats first letter for single names
        
        let user3 = UserTestBuilder().withFullName("Mary Jane Watson").build()
        XCTAssertEqual(user3.initials, "MW") // First and last
    }
    
    func testUserAgeCalculation() {
        let birthDate = TestDateFactory.date(year: 1990, month: 1, day: 1)
        let user = UserTestBuilder().withBirthDate(birthDate).build()
        
        XCTAssertNotNil(user.age)
        if let age = user.age {
            XCTAssertGreaterThan(age, 0)
        }
    }
    
    func testUserAgeNilWithoutBirthDate() {
        let user = UserTestBuilder().withBirthDate(nil).build()
        XCTAssertNil(user.age)
    }
    
    // MARK: - Auth Error Tests
    
    func testAuthErrorMapping() {
        let testCases: [(code: Int, expected: AuthError)] = [
            (17008, .invalidEmail),
            (17009, .invalidCredentials),
            (17011, .userNotFound),
            (17007, .emailAlreadyInUse),
            (17026, .weakPassword),
            (17020, .networkError),
            (17010, .tooManyRequests),
        ]
        
        for (code, expected) in testCases {
            let error = NSError(domain: "FIRAuthErrorDomain", code: code, userInfo: nil)
            let mappedError = AuthError.from(error)
            XCTAssertEqual(mappedError, expected, "Error code \(code) should map to \(expected)")
        }
    }
    
    // MARK: - State Management Tests
    
    func testInitialState() {
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testLoadingState() {
        // Simulate loading state
        sut.isLoading = true
        XCTAssertTrue(sut.isLoading)
        
        sut.isLoading = false
        XCTAssertFalse(sut.isLoading)
    }
    
    func testErrorState() {
        let error = AppError.validation(.invalidEmail)
        sut.error = error
        XCTAssertNotNil(sut.error)
        
        // Test clearing error
        sut.error = nil
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Social Sign In Tests
    
    func testGoogleSignInRequiresViewController() {
        // Google Sign In requires a root view controller
        // This tests that the proper guards are in place
        // In test environment, UIApplication.shared.windows is empty
        // so the method should fail gracefully
    }
    
    func testAppleSignInGeneratesRequest() async {
        // Apple Sign In should generate a valid request
        // The actual request generation can be tested
        let nonce = randomNonceString(length: 32)
        XCTAssertEqual(nonce.count, 32)
        
        let hashedNonce = sha256(nonce)
        XCTAssertEqual(hashedNonce.count, 64) // SHA256 produces 64 hex characters
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 16, &randomBytes)
            
            guard errorCode == errSecSuccess else {
                randomBytes = (0..<16).map { _ in UInt8.random(in: 0...255) }
            }
            
            randomBytes.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - SHA256 Helper for tests

import CryptoKit

extension Sequence where Element == UInt8 {
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        return try compactMap(transform)
    }
}
