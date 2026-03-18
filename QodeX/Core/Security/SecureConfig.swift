//
//  SecureConfig.swift
//  Secure configuration management
//

import Foundation

/// Manages sensitive configuration without hardcoding
enum SecureConfig {
    
    // MARK: - Firebase
    
    static var firebaseAPIKey: String {
        #if DEBUG
        // Development: Use environment variable
        if let envKey = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        // Fall back to plist for development only
        return Bundle.main.object(forInfoDictionaryKey: "FIREBASE_API_KEY") as? String ?? ""
        #else
        // Production: Use Keychain for secure storage
        if let keychainKey = KeychainManager.retrieveString(key: .firebaseAPIKey), !keychainKey.isEmpty {
            return keychainKey
        }
        // If not in keychain, try environment (for first run)
        if let envKey = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"], !envKey.isEmpty {
            // Store in keychain for future use
            _ = KeychainManager.store(envKey, key: .firebaseAPIKey)
            return envKey
        }
        return ""
        #endif
    }
    
    static var firebaseProjectID: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"] ??
               Bundle.main.object(forInfoDictionaryKey: "FIREBASE_PROJECT_ID") as? String ?? ""
        #else
        if let keychainValue = KeychainManager.retrieveString(key: .firebaseAPIKey), !keychainValue.isEmpty {
            return keychainValue
        }
        if let envValue = ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"], !envValue.isEmpty {
            _ = KeychainManager.store(envValue, key: .firebaseAPIKey)
            return envValue
        }
        return ""
        #endif
    }
    
    // MARK: - RevenueCat
    
    static var revenueCatAPIKey: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"] ??
               Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String ?? ""
        #else
        if let keychainValue = KeychainManager.retrieveString(key: .revenueCatAPIKey), !keychainValue.isEmpty {
            return keychainValue
        }
        if let envValue = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"], !envValue.isEmpty {
            _ = KeychainManager.store(envValue, key: .revenueCatAPIKey)
            return envValue
        }
        return ""
        #endif
    }
    
    // MARK: - Google Sign In
    
    static var googleClientID: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"] ??
               Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String ?? ""
        #else
        // Google Client ID is typically public, but we can still use Keychain for consistency
        if let keychainValue = KeychainManager.retrieveString(key: KeychainKey(rawValue: "com.qodex.googleClientID")), !keychainValue.isEmpty {
            return keychainValue
        }
        if let envValue = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"], !envValue.isEmpty {
            _ = KeychainManager.store(envValue, key: KeychainKey(rawValue: "com.qodex.googleClientID"))
            return envValue
        }
        return ""
        #endif
    }
    
    // MARK: - Validation
    
    static func validateConfiguration() -> [String] {
        var missingConfigs: [String] = []
        
        if firebaseAPIKey.isEmpty {
            missingConfigs.append("FIREBASE_API_KEY")
        }
        
        if revenueCatAPIKey.isEmpty {
            missingConfigs.append("REVENUECAT_API_KEY")
        }
        
        #if DEBUG
        if !missingConfigs.isEmpty {
            print("⚠️ Missing configurations: \(missingConfigs.joined(separator: ", "))")
        }
        #endif
        
        return missingConfigs
    }
    
    // MARK: - Secure Storage
    
    /// Pre-loads API keys from environment into Keychain for production
    static func preloadKeysToKeychain() {
        #if !DEBUG
        if let firebaseKey = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"], !firebaseKey.isEmpty {
            _ = KeychainManager.store(firebaseKey, key: .firebaseAPIKey)
        }
        
        if let revenueCatKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"], !revenueCatKey.isEmpty {
            _ = KeychainManager.store(revenueCatKey, key: .revenueCatAPIKey)
        }
        
        if let googleClientID = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"], !googleClientID.isEmpty {
            _ = KeychainManager.store(googleClientID, key: KeychainKey(rawValue: "com.qodex.googleClientID"))
        }
        #endif
    }
}

// MARK: - Build Configuration

enum BuildConfiguration {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isRelease: Bool {
        !isDebug
    }
    
    static var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    static var isAppStore: Bool {
        !isDebug && !isTestFlight
    }
}

// MARK: - Debug Logging

func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let filename = (file as NSString).lastPathComponent
    print("[DEBUG] \(filename):\(line) - \(function): \(message)")
    #endif
}

func logError(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    let filename = (file as NSString).lastPathComponent
    if let error = error {
        print("[ERROR] \(filename):\(line) - \(function): \(message) - \(error.localizedDescription)")
    } else {
        print("[ERROR] \(filename):\(line) - \(function): \(message)")
    }
}
