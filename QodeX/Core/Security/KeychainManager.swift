//
//  KeychainManager.swift
//  Secure keychain storage for sensitive data
//

import Foundation
import Security

/// Keychain keys for secure storage
enum KeychainKey: String {
    case firebaseAPIKey = "com.qodex.firebaseAPIKey"
    case revenueCatAPIKey = "com.qodex.revenueCatAPIKey"
    case fcmToken = "com.qodex.fcmToken"
    case pendingDeepLink = "com.qodex.pendingDeepLink"
    case rateLimitAttempts = "com.qodex.rateLimitAttempts"
    case onboardingCompleted = "com.qodex.onboardingCompleted"
    case userName = "com.qodex.userName"
    case userAuthToken = "com.qodex.userAuthToken"
    case userRefreshToken = "com.qodex.userRefreshToken"
}

/// Secure Keychain storage manager
enum KeychainManager {
    
    // MARK: - Store Data
    
    @discardableResult
    static func store(_ data: Data, key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    @discardableResult
    static func store(_ string: String, key: KeychainKey) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return store(data, key: key)
    }
    
    @discardableResult
    static func store(_ bool: Bool, key: KeychainKey) -> Bool {
        let data = Data([bool ? 1 : 0])
        return store(data, key: key)
    }
    
    @discardableResult
    static func store<T: Codable>(_ object: T, key: KeychainKey) -> Bool {
        guard let data = try? JSONEncoder().encode(object) else { return false }
        return store(data, key: key)
    }
    
    // MARK: - Retrieve Data
    
    static func retrieve(key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    static func retrieveString(key: KeychainKey) -> String? {
        guard let data = retrieve(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func retrieveBool(key: KeychainKey) -> Bool {
        guard let data = retrieve(key: key),
              data.count == 1 else { return false }
        return data[0] == 1
    }
    
    static func retrieve<T: Codable>(_ type: T.Type, key: KeychainKey) -> T? {
        guard let data = retrieve(key: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Delete Data
    
    @discardableResult
    static func delete(key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Convenience Methods
    
    /// Retrieve API key with fallback to environment
    static func retrieveAPIKey(_ key: KeychainKey, environmentKey: String) -> String {
        // First try keychain
        if let keychainValue = retrieveString(key: key), !keychainValue.isEmpty {
            return keychainValue
        }
        
        // Fall back to environment variable
        if let envValue = ProcessInfo.processInfo.environment[environmentKey], !envValue.isEmpty {
            // Store in keychain for future use
            _ = store(envValue, key: key)
            return envValue
        }
        
        return ""
    }
    
    /// Clear all QodeX data from keychain (useful for sign out)
    static func clearAllData() {
        for key in KeychainKey.allCases {
            _ = delete(key: key)
        }
    }
}

// MARK: - KeychainKey CaseIterable
extension KeychainKey: CaseIterable {}
