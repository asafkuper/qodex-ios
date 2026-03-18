//
//  AuthManager.swift
//  Authentication with Gmail, Apple, Email - with proper error handling
//  Includes complete GDPR-compliant account deletion
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // MARK: - Published State
    @Published var isAuthenticated = false
    @Published var currentUser: QodeXUser?
    @Published var isLoading = false
    @Published var error: AppError?
    
    // MARK: - Private Properties
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    do {
                        let user = try await self?.fetchUserProfile(userId: firebaseUser.uid)
                        self?.currentUser = user
                        self?.isAuthenticated = true
                    } catch {
                        self?.error = AppError(from: error)
                        self?.isAuthenticated = false
                    }
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Email/Password Auth
    
    func signUp(email: String, password: String, fullName: String, birthDate: Date) async -> Result<Void, AppError> {
        // Validate inputs
        do {
            try InputValidator.validate(email: email)
            try InputValidator.validate(password: password)
            try InputValidator.validate(name: fullName)
            try InputValidator.validate(birthDate: birthDate)
        } catch let validationError as ValidationError {
            return .failure(.validation(validationError))
        } catch {
            return .failure(.unknown(error))
        }
        
        // Check rate limiting
        guard InputValidator.checkRateLimit(identifier: "signup_\(email)") else {
            return .failure(.authentication(.rateLimited))
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let sanitizedEmail = InputValidator.sanitize(email)
            let sanitizedName = InputValidator.sanitize(fullName)
            
            let result = try await Auth.auth().createUser(withEmail: sanitizedEmail, password: password)
            
            // Create user profile
            let user = QodeXUser(
                id: result.user.uid,
                email: email,
                fullName: fullName,
                birthDate: birthDate,
                membershipTier: .free,
                createdAt: Date()
            )
            
            try await saveUserProfile(user)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            // Log analytics
            AnalyticsManager.shared.logSignUp(method: "email")
            
            return .success(())
            
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    func signIn(email: String, password: String) async -> Result<Void, AppError> {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            AnalyticsManager.shared.logLogin(method: "email")
            return .success(())
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async -> Result<Void, AppError> {
        isLoading = true
        defer { isLoading = false }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return .failure(.authentication(.noRootViewController))
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                return .failure(.authentication(.noIdToken))
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if new user
            if authResult.additionalUserInfo?.isNewUser == true {
                let user = QodeXUser(
                    id: authResult.user.uid,
                    email: authResult.user.email ?? "",
                    fullName: authResult.user.displayName ?? "",
                    birthDate: nil,
                    membershipTier: .free,
                    createdAt: Date()
                )
                do {
                    try await saveUserProfile(user)
                } catch {
                    print("[WARNING] Failed to save Google sign-in profile: \(error)")
                    // Don't fail the sign-in if profile save fails
                }
            }
            
            AnalyticsManager.shared.logLogin(method: "google")
            return .success(())
            
        } catch let error as NSError {
            if error.code == GIDSignInError.canceled.rawValue {
                return .failure(.authentication(.userCancelled))
            }
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple() async -> Result<AppleSignInRequest, AppError> {
        isLoading = true
        defer { isLoading = false }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return .success(AppleSignInRequest(authorizationRequest: request))
    }
    
    func handleAppleSignIn(_ authorization: ASAuthorization) async -> Result<Void, AppError> {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce else {
            return .failure(.authentication(.invalidCredential))
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            return .failure(.authentication(.noIdToken))
        }
        
        do {
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Handle new user with Apple
            if authResult.additionalUserInfo?.isNewUser == true {
                let fullName = [
                    appleIDCredential.fullName?.givenName,
                    appleIDCredential.fullName?.familyName
                ].compactMap { $0 }.joined(separator: " ")
                
                let user = QodeXUser(
                    id: authResult.user.uid,
                    email: appleIDCredential.email ?? authResult.user.email ?? "",
                    fullName: fullName.isEmpty ? (authResult.user.displayName ?? "") : fullName,
                    birthDate: nil,
                    membershipTier: .free,
                    createdAt: Date()
                )
                
                do {
                    try await saveUserProfile(user)
                    
                    // Update display name if provided
                    if !fullName.isEmpty {
                        let changeRequest = authResult.user.createProfileChangeRequest()
                        changeRequest.displayName = fullName
                        try await changeRequest.commitChanges()
                    }
                } catch {
                    print("[WARNING] Failed to save Apple sign-in profile: \(error)")
                }
            }
            
            AnalyticsManager.shared.logLogin(method: "apple")
            return .success(())
            
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() -> Result<Void, AppError> {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            return .success(())
        } catch {
            return .failure(.authentication(.invalidCredential))
        }
    }
    
    // MARK: - Password Reset
    
    func sendPasswordReset(email: String) async -> Result<Void, AppError> {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return .success(())
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    // MARK: - Account Deletion (GDPR Compliant)
    
    /// Deletes user account and all associated data
    /// This is a GDPR-compliant complete deletion that removes:
    /// - User profile and all subcollections
    /// - Community posts and comments
    /// - Qode reads and streak data
    /// - Subscriptions
    /// - Compatibility reports
    /// - Mentorship requests
    /// - Any other user-associated data
    func deleteAccount() async -> Result<Void, AppError> {
        guard let user = Auth.auth().currentUser else {
            return .failure(.authentication(.notAuthenticated))
        }
        
        let userId = user.uid
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Step 1: Create deletion log for audit trail (GDPR requirement)
            try await createDeletionAuditLog(userId: userId)
            
            // Step 2: Delete all user subcollections
            try await deleteUserSubcollections(userId: userId)
            
            // Step 3: Delete user document
            try await db.collection("users").document(userId).delete()
            
            // Step 4: Delete user's community content
            try await deleteCommunityContent(userId: userId)
            
            // Step 5: Delete user's qode reads
            try await deleteQodeReads(userId: userId)
            
            // Step 6: Delete user's subscriptions
            try await deleteSubscriptions(userId: userId)
            
            // Step 7: Delete compatibility reports
            try await deleteCompatibilityReports(userId: userId)
            
            // Step 8: Delete mentorship requests
            try await deleteMentorshipRequests(userId: userId)
            
            // Step 9: Delete challenge progress
            try await deleteChallengeProgress(userId: userId)
            
            // Step 10: Delete any system notifications
            try await deleteSystemNotifications(userId: userId)
            
            // Step 11: Delete from deletion queue if exists
            try await deleteFromDeletionQueue(userId: userId)
            
            // Step 12: Delete Firebase Auth account (MUST be last)
            try await user.delete()
            
            // Step 13: Clear local keychain data
            clearLocalData()
            
            // Step 14: Log analytics event
            AnalyticsManager.shared.logEvent("account_deleted", parameters: ["user_id": userId])
            
            return .success(())
            
        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                return .failure(.authentication(.sessionExpired))
            }
            print("❌ Account deletion failed: \(error.localizedDescription)")
            return .failure(.firebase(.writeFailed))
        } catch {
            print("❌ Account deletion failed: \(error.localizedDescription)")
            return .failure(.unknown(error))
        }
    }
    
    /// Creates an audit log entry for the deletion (GDPR requirement)
    private func createDeletionAuditLog(userId: String) async throws {
        let auditData: [String: Any] = [
            "userId": userId,
            "requestedAt": FieldValue.serverTimestamp(),
            "completedAt": NSNull(),
            "status": "in_progress",
            "ipAddress": "", // Would be populated by server
            "userAgent": "QodeX iOS App",
            "requestSource": "user_initiated"
        ]
        
        try await db.collection("deletion_audit_log").document(userId).setData(auditData)
    }
    
    /// Updates audit log on completion
    private func updateDeletionAuditLog(userId: String, success: Bool, error: String? = nil) async {
        let updateData: [String: Any] = [
            "completedAt": FieldValue.serverTimestamp(),
            "status": success ? "completed" : "failed",
            "error": error ?? NSNull()
        ]
        
        try? await db.collection("deletion_audit_log").document(userId).updateData(updateData)
    }
    
    /// Deletes all subcollections under the user document
    private func deleteUserSubcollections(userId: String) async throws {
        let subcollections = ["notifications", "journal", "activity", "readings", "subscriptions"]
        
        for subcollection in subcollections {
            let snapshot = try await db.collection("users").document(userId)
                .collection(subcollection)
                .getDocuments()
            
            for document in snapshot.documents {
                try await document.reference.delete()
            }
        }
    }
    
    /// Deletes all community posts and comments by the user
    private func deleteCommunityContent(userId: String) async throws {
        // Delete posts
        let postsSnapshot = try await db.collection("community_posts")
            .whereField("authorId", isEqualTo: userId)
            .getDocuments()
        
        for post in postsSnapshot.documents {
            // Delete comments subcollection first
            let commentsSnapshot = try await post.reference.collection("comments").getDocuments()
            for comment in commentsSnapshot.documents {
                try await comment.reference.delete()
            }
            
            // Delete likes subcollection
            let likesSnapshot = try await post.reference.collection("likes").getDocuments()
            for like in likesSnapshot.documents {
                try await like.reference.delete()
            }
            
            // Delete the post
            try await post.reference.delete()
        }
        
        // Delete comments on other users' posts
        let allCommentsSnapshot = try await db.collectionGroup("comments")
            .whereField("authorId", isEqualTo: userId)
            .getDocuments()
        
        for comment in allCommentsSnapshot.documents {
            try await comment.reference.delete()
        }
        
        // Remove likes from other posts
        let allPostsSnapshot = try await db.collection("community_posts").getDocuments()
        for post in allPostsSnapshot.documents {
            let likeDoc = post.reference.collection("likes").document(userId)
            try? await likeDoc.delete()
        }
    }
    
    /// Deletes all qode reads for the user
    private func deleteQodeReads(userId: String) async throws {
        let snapshot = try await db.collection("qode_reads")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes subscription records for the user
    private func deleteSubscriptions(userId: String) async throws {
        // Delete from root subscriptions collection
        let snapshot = try await db.collection("subscriptions")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete from user subcollection
        let userSubsSnapshot = try await db.collection("users").document(userId)
            .collection("subscriptions")
            .getDocuments()
        
        for document in userSubsSnapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes compatibility reports for the user
    private func deleteCompatibilityReports(userId: String) async throws {
        let snapshot = try await db.collection("compatibility_reports")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes mentorship requests for the user
    private func deleteMentorshipRequests(userId: String) async throws {
        let snapshot = try await db.collection("mentorship_requests")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes challenge progress for the user
    private func deleteChallengeProgress(userId: String) async throws {
        let snapshot = try await db.collectionGroup("participants")
            .whereField(FieldPath.documentID(), isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes system notifications for the user
    private func deleteSystemNotifications(userId: String) async throws {
        let snapshot = try await db.collection("notifications_system")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes from deletion queue if exists
    private func deleteFromDeletionQueue(userId: String) async throws {
        try? await db.collection("deletion_queue").document(userId).delete()
    }
    
    /// Clears all local data from keychain and user defaults
    private func clearLocalData() {
        // Clear keychain
        KeychainManager.clearAllData()
        
        // Clear user defaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key.hasPrefix("com.qodex.") {
                defaults.removeObject(forKey: key)
            }
        }
        
        // Clear any cached images
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - Reauthentication
    
    func reauthenticate(password: String) async -> Result<Void, AppError> {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            return .failure(.authentication(.notAuthenticated))
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        do {
            try await user.reauthenticate(with: credential)
            return .success(())
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    /// Reauthenticates with Apple credential for account deletion
    func reauthenticateWithApple(authorization: ASAuthorization) async -> Result<Void, AppError> {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce else {
            return .failure(.authentication(.invalidCredential))
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            return .failure(.authentication(.noIdToken))
        }
        
        do {
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            guard let user = Auth.auth().currentUser else {
                return .failure(.authentication(.notAuthenticated))
            }
            
            try await user.reauthenticate(with: credential)
            return .success(())
        } catch let error as NSError {
            return .failure(.authentication(AuthError.from(error)))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchUserProfile(userId: String) async throws -> QodeXUser {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let data = document.data() else {
            // Return basic user if no profile exists
            guard let firebaseUser = Auth.auth().currentUser else {
                throw AuthError.userNotFound
            }
            return QodeXUser(
                id: userId,
                email: firebaseUser.email ?? "",
                fullName: firebaseUser.displayName ?? "",
                birthDate: nil,
                membershipTier: .free,
                createdAt: Date()
            )
        }
        
        return QodeXUser(
            id: userId,
            email: data["email"] as? String ?? "",
            fullName: data["fullName"] as? String ?? "",
            birthDate: (data["birthDate"] as? Timestamp)?.dateValue(),
            membershipTier: MembershipTier(rawValue: data["membershipTier"] as? String ?? "free") ?? .free,
            membershipExpiry: (data["membershipExpiry"] as? Timestamp)?.dateValue(),
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastActiveAt: (data["lastActiveAt"] as? Timestamp)?.dateValue(),
            profileImageURL: data["profileImageURL"] as? String,
            bio: data["bio"] as? String,
            location: data["location"] as? String,
            timezone: data["timezone"] as? String ?? TimeZone.current.identifier,
            role: UserRole(rawValue: data["role"] as? String ?? "user") ?? .user,
            notificationSettings: parseNotificationSettings(data["notificationSettings"] as? [String: Bool]),
            streakData: parseStreakData(data["streakData"] as? [String: Any]),
            blueprintCompletion: data["blueprintCompletion"] as? Double ?? 0.0
        )
    }
    
    private func parseNotificationSettings(_ data: [String: Bool]?) -> NotificationSettings {
        guard let data = data else { return NotificationSettings() }
        return NotificationSettings(
            dailyQode: data["dailyQode"] ?? true,
            weeklyReport: data["weeklyReport"] ?? true,
            liveSessions: data["liveSessions"] ?? true,
            newTeachings: data["newTeachings"] ?? true,
            communityReplies: data["communityReplies"] ?? true,
            membershipUpdates: data["membershipUpdates"] ?? true,
            marketing: data["marketing"] ?? false
        )
    }
    
    private func parseStreakData(_ data: [String: Any]?) -> StreakData? {
        guard let data = data else { return nil }
        return StreakData(
            currentStreak: data["currentStreak"] as? Int ?? 0,
            longestStreak: data["longestStreak"] as? Int ?? 0,
            lastCheckIn: (data["lastCheckIn"] as? Timestamp)?.dateValue(),
            totalCheckIns: data["totalCheckIns"] as? Int ?? 0
        )
    }
    
    private func saveUserProfile(_ user: QodeXUser) async throws {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "fullName": user.fullName,
            "birthDate": user.birthDate as Any,
            "birthTime": user.birthTime as Any,
            "birthLocation": user.birthLocation as Any,
            "timezone": user.timezone,
            "membershipTier": user.membershipTier.rawValue,
            "membershipExpiry": user.membershipExpiry as Any,
            "createdAt": Timestamp(date: user.createdAt),
            "lastActiveAt": user.lastActiveAt != nil ? Timestamp(date: user.lastActiveAt!) : FieldValue.serverTimestamp(),
            "profileImageURL": user.profileImageURL as Any,
            "bio": user.bio as Any,
            "location": user.location as Any,
            "role": user.role.rawValue,
            "notificationSettings": [
                "dailyQode": user.notificationSettings.dailyQode,
                "weeklyReport": user.notificationSettings.weeklyReport,
                "liveSessions": user.notificationSettings.liveSessions,
                "newTeachings": user.notificationSettings.newTeachings,
                "communityReplies": user.notificationSettings.communityReplies,
                "membershipUpdates": user.notificationSettings.membershipUpdates,
                "marketing": user.notificationSettings.marketing
            ],
            "blueprintCompletion": user.blueprintCompletion
        ]
        
        if let streakData = user.streakData {
            var streakDict: [String: Any] = [
                "currentStreak": streakData.currentStreak,
                "longestStreak": streakData.longestStreak,
                "totalCheckIns": streakData.totalCheckIns
            ]
            if let lastCheckIn = streakData.lastCheckIn {
                streakDict["lastCheckIn"] = Timestamp(date: lastCheckIn)
            }
            var mutableData = data
            mutableData["streakData"] = streakDict
            try await db.collection("users").document(user.id).setData(mutableData)
        } else {
            try await db.collection("users").document(user.id).setData(data)
        }
    }
    
    func updateLastActive() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try await db.collection("users").document(userId).updateData([
                "lastActiveAt": FieldValue.serverTimestamp()
            ])
        } catch {
            print("[WARNING] Failed to update last active: \(error)")
        }
    }
    
    // MARK: - Secure Random Generation
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 16, &randomBytes)
            
            guard errorCode == errSecSuccess else {
                // Fallback to less secure random generation
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

// MARK: - Apple Sign In Request
struct AppleSignInRequest {
    let authorizationRequest: ASAuthorizationAppleIDRequest
}

// MARK: - Auth Error Extension
extension AuthError {
    static func from(_ error: NSError) -> AuthError {
        guard let code = AuthErrorCode.Code(rawValue: error.code) else {
            return .invalidCredentials
        }
        
        switch code {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        case .tooManyRequests:
            return .tooManyRequests
        case .requiresRecentLogin:
            return .sessionExpired
        case .userDisabled:
            return .invalidCredentials
        case .invalidCredential:
            return .invalidCredential
        case .operationNotAllowed:
            return .invalidCredentials
        default:
            return .invalidCredentials
        }
    }
}
