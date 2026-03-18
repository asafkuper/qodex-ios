//
//  SecurityManager.swift
//  Encryption, keychain, and certificate pinning
//

import Foundation
import CryptoKit
import Security

class SecurityManager {
    static let shared = SecurityManager()
    private let keychain = KeychainManager.shared
    
    // MARK: - Data Encryption
    func encrypt(_ data: Data, using key: SymmetricKey? = nil) throws -> (ciphertext: Data, nonce: Data)? {
        let encryptionKey = key ?? generateKey()
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
            return (sealedBox.combined!, encryptionKey.withUnsafeBytes { Data($0) })
        } catch {
            print("❌ Encryption failed: \(error)")
            return nil
        }
    }
    
    func decrypt(_ combinedData: Data, using key: SymmetricKey) throws -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("❌ Decryption failed: \(error)")
            return nil
        }
    }
    
    func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    // MARK: - Secure Storage
    func securelyStore(_ data: Data, forKey key: String) throws {
        // Encrypt before storing
        guard let (ciphertext, encryptionKey) = try encrypt(data) else {
            throw SecurityError.encryptionFailed
        }
        
        // Store encrypted data
        try keychain.store(ciphertext, service: "com.qodex.data", account: key)
        
        // Store encryption key separately
        try keychain.store(encryptionKey, service: "com.qodex.keys", account: "\(key)-key")
    }
    
    func securelyRetrieve(forKey key: String) throws -> Data? {
        // Retrieve encrypted data
        guard let ciphertext = try keychain.retrieve(service: "com.qodex.data", account: key) else {
            return nil
        }
        
        // Retrieve encryption key
        guard let keyData = try keychain.retrieve(service: "com.qodex.keys", account: "\(key)-key") else {
            return nil
        }
        
        let symmetricKey = SymmetricKey(data: keyData)
        return try decrypt(ciphertext, using: symmetricKey)
    }
    
    // MARK: - Certificate Pinning
    func validateCertificate(_ certificate: SecCertificate, forHost host: String) -> Bool {
        // Get expected certificate hash
        guard let expectedHash = getExpectedCertificateHash(for: host) else {
            return false
        }
        
        // Calculate certificate hash
        guard let certificateData = SecCertificateCopyData(certificate) as Data? else {
            return false
        }
        
        let hash = SHA256.hash(data: certificateData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString == expectedHash
    }
    
    private func getExpectedCertificateHash(for host: String) -> String? {
        let pinnedCertificates: [String: String] = [
            "api.qodex.academy": "a1b2c3d4e5f6...",
            "firestore.googleapis.com": "b2c3d4e5f6g7..."
        ]
        return pinnedCertificates[host]
    }
    
    // MARK: - Biometric Authentication
    func authenticateWithBiometrics(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - Secure Random
    func generateSecureRandom(length: Int) -> Data? {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            print("❌ Failed to generate secure random bytes: \(status)")
            return nil
        }
        return Data(bytes)
    }
    
    // MARK: - Hashing
    func hashPassword(_ password: String, salt: String) -> String {
        let data = Data((password + salt).utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func verifyPassword(_ password: String, against hash: String, salt: String) -> Bool {
        return hashPassword(password, salt: salt) == hash
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    static let shared = KeychainManager()
    
    func store(_ data: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecurityError.keychainError(status)
        }
    }
    
    func retrieve(service: String, account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw SecurityError.keychainError(status)
        }
        
        return result as? Data
    }
    
    func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityError.keychainError(status)
        }
    }
}

// MARK: - Errors
enum SecurityError: Error {
    case encryptionFailed
    case decryptionFailed
    case keychainError(OSStatus)
    case biometricNotAvailable
    case certificateValidationFailed
}

// MARK: - URLSession Delegate for Certificate Pinning
class SecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = certificateChain.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let host = challenge.protectionSpace.host
        
        if SecurityManager.shared.validateCertificate(certificate, forHost: host) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
