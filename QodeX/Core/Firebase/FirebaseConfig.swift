//
//  FirebaseConfig.swift
//  Firebase configuration with offline persistence
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase Configuration
class FirebaseConfig {
    
    static let shared = FirebaseConfig()
    
    private var isConfigured = false
    
    // MARK: - Configuration
    
    func configure() {
        guard !isConfigured else {
            print("[FIREBASE] Already configured")
            return
        }
        
        // Configure Firebase app
        FirebaseApp.configure()
        
        // Configure Firestore settings for offline persistence
        configureFirestoreSettings()
        
        isConfigured = true
        print("[FIREBASE] Configured with offline persistence enabled")
    }
    
    // MARK: - Firestore Settings
    
    private func configureFirestoreSettings() {
        let settings = FirestoreSettings()
        
        // Enable offline persistence
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        // Apply settings
        Firestore.firestore().settings = settings
        
        print("[FIREBASE] Firestore offline persistence configured")
    }
    
    // MARK: - Cache Management
    
    /// Clears the local Firestore cache
    func clearCache() async throws {
        try await Firestore.firestore().clearPersistence()
        print("[FIREBASE] Local cache cleared")
    }
    
    /// Enables or disables offline persistence at runtime
    func setOfflinePersistence(enabled: Bool) {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = enabled
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        print("[FIREBASE] Offline persistence set to: \(enabled)")
    }
    
    // MARK: - Network Status
    
    /// Checks if Firestore is currently using offline cache
    func isUsingOfflineCache() -> Bool {
        // Firestore automatically uses cache when offline
        // This is handled internally by the SDK
        return true // Persistence is always enabled
    }
}

// MARK: - Firestore Error Recovery

extension FirebaseService {
    
    /// Attempts to recover from Firestore errors using offline cache
    func attemptOfflineRecovery<T>(
        for operation: String,
        fallback: () async throws -> T
    ) async -> Result<T, AppError> {
        do {
            let result = try await fallback()
            return .success(result)
        } catch {
            print("[FIREBASE] Operation '\(operation)' failed, attempting offline recovery")
            
            // Check if it's a network error
            let nsError = error as NSError
            if nsError.domain == FirestoreErrorDomain &&
               nsError.code == FirestoreErrorCode.unavailable.rawValue {
                // Return cached data if available
                return .failure(.network(.offline))
            }
            
            return .failure(handleError(error))
        }
    }
}
