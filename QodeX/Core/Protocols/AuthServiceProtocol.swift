//
//  AuthServiceProtocol.swift
//  Authentication service protocol
//

import Foundation
import Combine
import FirebaseAuth

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol: AnyObject {
    // MARK: - Publishers
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    
    // MARK: - Properties
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
    var currentUserEmail: String? { get }
    var currentUser: User? { get }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, fullName: String) async throws
    func signOut() async throws
    func sendPasswordReset(email: String) async throws
    func deleteAccount() async throws
    func reauthenticate(password: String) async throws
    
    // MARK: - OAuth Methods
    func signInWithGoogle() async throws
    func signInWithApple(authorization: Any) async throws
    
    // MARK: - User Management
    func updateProfile(displayName: String?, photoURL: URL?) async throws
    func updateEmail(_ email: String) async throws
    func updatePassword(_ password: String) async throws
    func getIDToken(forceRefresh: Bool) async throws -> String
    
    // MARK: - Verification
    func sendEmailVerification() async throws
    func reloadUser() async throws
}

// MARK: - Auth Service Protocol Extension
extension AuthServiceProtocol {
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func getIDToken(forceRefresh: Bool = false) async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notAuthenticated
        }
        return try await user.getIDTokenResult(forcingRefresh: forceRefresh).token
    }
}

// MARK: - User Model Protocol
protocol UserProtocol: Identifiable, Codable {
    var id: String { get }
    var email: String { get }
    var fullName: String { get }
    var birthDate: Date? { get }
    var membershipTier: MembershipTier { get }
    var createdAt: Date { get }
    var lastActiveAt: Date? { get }
    
    var initials: String { get }
    var age: Int? { get }
    var lifePathNumber: Int? { get }
}

// MARK: - User Model Extension
extension QodeXUser: UserProtocol {
    var lifePathNumber: Int? {
        guard let birthDate = birthDate else { return nil }
        return calculateLifePath(from: birthDate)
    }
}

private func calculateLifePath(from date: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .month, .year], from: date)
    
    let day = components.day ?? 1
    let month = components.month ?? 1
    let year = components.year ?? 2000
    
    var sum = day + month + year
    while sum > 9 && sum != 11 && sum != 22 && sum != 33 {
        var newSum = 0
        var n = sum
        while n > 0 {
            newSum += n % 10
            n /= 10
        }
        sum = newSum
    }
    
    return sum == 0 ? 9 : sum
}

// MARK: - Auth State
enum AuthState: Equatable {
    case authenticated(user: UserInfo)
    case unauthenticated
    case loading
    
    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }
}

struct UserInfo: Equatable {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    let emailVerified: Bool
    
    init(from user: User) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL?.absoluteString
        self.emailVerified = user.isEmailVerified
    }
}

// MARK: - Auth Result
enum AuthResult<T> {
    case success(T)
    case failure(AuthError)
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    var error: AuthError? {
        if case .failure(let error) = self { return error }
        return nil
    }
}

// MARK: - OAuth Credential
struct OAuthCredential {
    let providerID: String
    let idToken: String?
    let accessToken: String?
    let rawNonce: String?
    
    init(providerID: String, idToken: String?, accessToken: String?, rawNonce: String? = nil) {
        self.providerID = providerID
        self.idToken = idToken
        self.accessToken = accessToken
        self.rawNonce = rawNonce
    }
}

// MARK: - Apple Sign In Result
struct AppleSignInResult {
    let userID: String
    let email: String?
    let fullName: PersonNameComponents?
    let authorizationCode: String?
    let identityToken: String?
    
    var emailToUse: String {
        email ?? ""
    }
    
    var displayName: String {
        guard let name = fullName else { return "" }
        return "\(name.givenName ?? "") \(name.familyName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Auth Validation
protocol AuthValidator {
    func validateEmail(_ email: String) throws
    func validatePassword(_ password: String) throws
    func validateName(_ name: String) throws
}

extension AuthValidator {
    func validateEmail(_ email: String) throws {
        guard !email.isEmpty else {
            throw ValidationError.emptyField(fieldName: "Email")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            throw ValidationError.invalidEmail
        }
    }
    
    func validatePassword(_ password: String) throws {
        guard password.count >= 8 else {
            throw ValidationError.tooShort(minLength: 8)
        }
        
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        guard hasUppercase && hasLowercase && hasDigit else {
            throw ValidationError.invalidPassword
        }
    }
    
    func validateName(_ name: String) throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyField(fieldName: "Name")
        }
        
        guard name.count >= 2 else {
            throw ValidationError.tooShort(minLength: 2)
        }
        
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "-'"))
        let nameCharacters = CharacterSet(charactersIn: name)
        
        guard allowedCharacters.isSuperset(of: nameCharacters) else {
            throw ValidationError.invalidName
        }
    }
}
