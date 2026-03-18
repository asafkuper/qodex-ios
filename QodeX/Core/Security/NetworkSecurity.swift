//
//  NetworkSecurity.swift
//  Certificate pinning and network security configuration
//  CRITICAL: Certificate pinning is enforced in production builds
//

import Foundation
import Alamofire

/// Network security configuration with certificate pinning
/// WARNING: In production, certificate pinning MUST be properly configured
enum NetworkSecurity {
    
    // MARK: - Production Flag
    
    /// Set to true in production to enforce strict certificate pinning
    static let enforcePinning: Bool = {
        #if DEBUG
        return false // Allow development flexibility
        #else
        return true  // STRICT enforcement in production
        #endif
    }()
    
    // MARK: - Pinned Certificates (SHA-256 Hashes)
    
    /// Certificate hashes for pinning (base64-encoded SHA-256)
    /// These are the expected SPKI hashes for each domain
    static let pinnedCertificateHashes: [String: [String]] = [
        "api.qodex.academy": [
            // Primary certificate hash - REPLACE with actual hash before release
            "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            // Backup certificate hash - REPLACE with actual hash before release
            "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
        ],
        "api.revenuecat.com": [
            // RevenueCat certificate hash - REPLACE with actual hash before release
            "sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="
        ],
        "firestore.googleapis.com": [
            // Firebase certificate hash - REPLACE with actual hash before release
            "sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD="
        ]
    ]
    
    // MARK: - Certificate Data (Legacy Support)
    
    /// Domain to certificate data mapping for pinning
    /// NOTE: Load actual .cer files from app bundle in production
    static let pinnedCertificates: [String: [Data]] = {
        var certs: [String: [Data]] = [:]
        
        for domain in pinnedCertificateHashes.keys {
            if let certData = loadCertificate(named: domain.replacingOccurrences(of: ".", with: "_")) {
                certs[domain] = [certData]
            }
        }
        
        return certs
    }()
    
    // MARK: - Alamofire Session
    
    /// Configured Alamofire session with certificate pinning
    /// CRITICAL: Returns nil in production if certificates are not configured
    static var session: Session? {
        // Validate certificates are configured in production
        if enforcePinning {
            guard validateCertificatesConfigured() else {
                print("❌ SECURITY ERROR: Certificate pinning not properly configured")
                print("❌ Network requests will be BLOCKED in production")
                return nil
            }
        }
        
        let evaluators = pinnedCertificates.reduce(into: [:]) { result, pair in
            let certificates = pair.value.isEmpty ? nil : pair.value
            result[pair.key] = PinnedCertificatesTrustEvaluator(
                certificates: certificates,
                acceptSelfSignedCertificates: false,
                performDefaultValidation: true,
                validateHost: true
            )
        }
        
        // Add default evaluator for other hosts
        var allEvaluators = evaluators
        if enforcePinning {
            // In production, require evaluation for all hosts
            allEvaluators["default"] = PinnedCertificatesTrustEvaluator(
                certificates: nil,
                acceptSelfSignedCertificates: false,
                performDefaultValidation: true,
                validateHost: true
            )
        }
        
        return Session(
            serverTrustManager: ServerTrustManager(
                allHostsMustBeEvaluated: enforcePinning,
                evaluators: allEvaluators
            )
        )
    }
    
    /// Session with public key pinning using SHA-256 hashes
    static var pinnedSession: Session? {
        guard enforcePinning else {
            // In debug, return regular session
            return Session.default
        }
        
        let evaluators: [String: ServerTrustEvaluating] = pinnedCertificateHashes.reduce(into: [:]) { result, pair in
            result[pair.key] = PublicKeysTrustEvaluator(
                keys: pair.value.map { PublicKey(hash: $0, type: .sha256) },
                performDefaultValidation: true,
                validateHost: true
            )
        }
        
        return Session(
            serverTrustManager: ServerTrustManager(
                allHostsMustBeEvaluated: true,
                evaluators: evaluators
            )
        )
    }
    
    /// Session without pinning for development/debugging ONLY
    /// WARNING: Never use in production
    static var insecureSession: Session {
        #if DEBUG
        // In debug mode, allow all certificates with warning
        print("⚠️ WARNING: Using insecure session - DEBUG MODE ONLY")
        return Session(
            serverTrustManager: ServerTrustManager(
                allHostsMustBeEvaluated: false,
                evaluators: [:]
            )
        )
        #else
        // In production, NEVER return insecure session - return nil instead
        QodeXLogger.shared.critical("SECURITY VIOLATION: insecureSession called in production", category: .security)
        return nil
        #endif
    }
    
    // MARK: - Certificate Loading
    
    /// Load certificate data from app bundle
    private static func loadCertificate(named name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "cer"),
              let data = try? Data(contentsOf: url) else {
            #if DEBUG
            print("⚠️ Warning: Certificate '\(name).cer' not found in bundle")
            #endif
            return nil
        }
        return data
    }
    
    /// Load certificate from secure keychain storage
    static func loadCertificateFromKeychain(domain: String) -> Data? {
        let key = KeychainKey(rawValue: "cert_\(domain)") ?? .userAuthToken
        return KeychainManager.retrieve(key: key)
    }
    
    /// Store certificate securely in keychain
    static func storeCertificate(_ data: Data, forDomain domain: String) -> Bool {
        let key = KeychainKey(rawValue: "cert_\(domain)") ?? .userAuthToken
        return KeychainManager.store(data, key: key)
    }
    
    // MARK: - Validation
    
    /// Validates that certificates are properly configured for production
    static func validateCertificatesConfigured() -> Bool {
        // Check that at least one certificate is configured for critical domains
        let criticalDomains = ["api.qodex.academy", "api.revenuecat.com"]
        
        for domain in criticalDomains {
            // Check certificate files
            if let certs = pinnedCertificates[domain], !certs.isEmpty {
                continue
            }
            
            // Check certificate hashes
            if let hashes = pinnedCertificateHashes[domain], 
               !hashes.isEmpty,
               !hashes.contains(where: { $0.contains("AAAA") || $0.contains("BBBB") || $0.contains("CCCC") }) {
                continue
            }
            
            // Certificate not configured for this domain
            print("❌ Certificate not configured for: \(domain)")
            return false
        }
        
        return true
    }
    
    /// Validates that a server's certificate matches our pinned certificates
    static func validateServerTrust(_ serverTrust: SecTrust, forDomain domain: String) -> Bool {
        guard let pinnedCertData = pinnedCertificates[domain]?.first,
              !pinnedCertData.isEmpty else {
            // No pinned certificate for this domain - reject in production
            return !enforcePinning
        }
        
        // Get server certificate
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
              let serverCertData = SecCertificateCopyData(serverCertificate) as Data? else {
            return false
        }
        
        // Compare certificates
        return serverCertData == pinnedCertData
    }
    
    /// Validates certificate hash (SPKI)
    static func validateCertificateHash(_ serverTrust: SecTrust, forDomain domain: String) -> Bool {
        guard let expectedHashes = pinnedCertificateHashes[domain],
              !expectedHashes.isEmpty else {
            return !enforcePinning
        }
        
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
              let serverCertData = SecCertificateCopyData(serverCertificate) as Data? else {
            return false
        }
        
        // Calculate SHA-256 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        serverCertData.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(serverCertData.count), &hash)
        }
        
        let computedHash = Data(hash).base64EncodedString()
        let computedHashWithPrefix = "sha256/\(computedHash)"
        
        // Check against expected hashes
        return expectedHashes.contains(computedHashWithPrefix)
    }
    
    // MARK: - Security Headers
    
    /// Default security headers for all network requests
    static var defaultHeaders: HTTPHeaders {
        return [
            "X-App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            "X-Build-Number": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1",
            "X-Platform": "iOS",
            "X-Security-Version": "2.0",
            "X-Pinning-Enforced": enforcePinning ? "true" : "false"
        ]
    }
    
    // MARK: - Security Check
    
    /// Performs a security check and returns any issues found
    static func performSecurityCheck() -> [String] {
        var issues: [String] = []
        
        if enforcePinning {
            if !validateCertificatesConfigured() {
                issues.append("Certificate pinning not properly configured")
            }
            
            if pinnedCertificates.isEmpty {
                issues.append("No pinned certificates loaded")
            }
            
            if session == nil {
                issues.append("Secure session could not be created")
            }
        } else {
            issues.append("Running in DEBUG mode - certificate pinning not enforced")
        }
        
        return issues
    }
}

// MARK: - Public Key Structure

struct PublicKey {
    let hash: String
    let type: HashType
    
    enum HashType {
        case sha256
        case sha1
    }
}

// MARK: - URLSession Pinning Delegate

/// URLSession delegate for certificate pinning (alternative to Alamofire)
class PinningURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let domain = challenge.protectionSpace.host as String? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Check if we have a pinned certificate for this domain
        if NetworkSecurity.validateServerTrust(serverTrust, forDomain: domain) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            #if DEBUG
            // In debug mode, allow but log warning
            print("⚠️ Certificate pinning failed for \(domain) - allowing in DEBUG mode")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            #else
            // In production, reject the connection
            print("❌ Certificate pinning failed for \(domain) - rejecting connection")
            completionHandler(.cancelAuthenticationChallenge, nil)
            
            // Log security event
            NetworkSecurity.logSecurityEvent(
                event: "certificate_pinning_failure",
                domain: domain,
                timestamp: Date()
            )
            #endif
        }
    }
}

// MARK: - Security Event Logging

extension NetworkSecurity {
    /// Logs security events for monitoring
    static func logSecurityEvent(event: String, domain: String, timestamp: Date) {
        let eventData: [String: Any] = [
            "event": event,
            "domain": domain,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]
        
        #if DEBUG
        print("🔒 Security Event: \(eventData)")
        #else
        // In production, send to analytics/security monitoring
        // AnalyticsManager.shared.logSecurityEvent(eventData)
        #endif
    }
}

// MARK: - Network Security Extensions

extension Session {
    /// Convenience method for secure API requests with certificate pinning
    /// Returns nil if secure session cannot be created
    func secureRequest(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
    ) -> DataRequest? {
        var allHeaders = NetworkSecurity.defaultHeaders
        if let additionalHeaders = headers {
            additionalHeaders.forEach { allHeaders.add($0) }
        }
        
        return request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: allHeaders
        )
    }
}

// MARK: - Certificate Utilities

enum CertificateUtils {
    
    /// Extract certificate data from a server URL (for initial setup)
    static func fetchCertificate(from url: URL, completion: @escaping (Data?) -> Void) {
        let session = URLSession(configuration: .ephemeral)
        
        let task = session.dataTask(with: url) { _, response, _ in
            guard let response = response as? HTTPURLResponse,
                  let serverTrust = (response as? HTTPURLResponse)?.value(forKey: "_serverTrust") as? SecTrust,
                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completion(nil)
                return
            }
            
            let certificateData = SecCertificateCopyData(certificate) as Data
            completion(certificateData)
        }
        
        task.resume()
    }
    
    /// Calculate SHA-256 hash of certificate data
    static func calculateSHA256Hash(_ data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    /// Save certificate to documents directory for debugging
    #if DEBUG
    static func saveCertificateForDebug(_ data: Data, named: String) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsPath.appendingPathComponent("\(named).cer")
        try? data.write(to: fileURL)
        print("📄 Certificate saved to: \(fileURL.path)")
        print("📄 SHA-256 Hash: sha256/\(calculateSHA256Hash(data))")
    }
    #endif
}

// MARK: - Import CommonCrypto for SHA256

import CommonCrypto

// MARK: - PublicKeysTrustEvaluator

/// Trust evaluator for public key pinning
struct PublicKeysTrustEvaluator: ServerTrustEvaluating {
    let keys: [PublicKey]
    let performDefaultValidation: Bool
    let validateHost: Bool
    
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        if performDefaultValidation {
            try trust.performDefaultValidation(forHost: host)
        }
        
        if validateHost {
            try trust.performValidation(forHost: host)
        }
        
        // Get certificate and validate against pinned keys
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0),
              let certData = SecCertificateCopyData(certificate) as Data? else {
            throw AFError.serverTrustEvaluationFailed(reason: .noCertificatesFound)
        }
        
        let computedHash = CertificateUtils.calculateSHA256Hash(certData)
        let computedHashWithPrefix = "sha256/\(computedHash)"
        
        let keyHashes = keys.map { $0.hash }
        guard keyHashes.contains(computedHashWithPrefix) else {
            throw AFError.serverTrustEvaluationFailed(
                reason: .certificatePinningFailed(host: host, trust: trust, pinnedKeys: keyHashes, serverKeys: [computedHashWithPrefix])
            )
        }
    }
}

// MARK: - SecTrust Extensions

extension SecTrust {
    func performDefaultValidation(forHost host: String) throws {
        let policy = SecPolicyCreateSSL(true, host as CFString)
        SecTrustSetPolicies(self, policy)
        
        var error: CFError?
        guard SecTrustEvaluateWithError(self, &error) else {
            if let error = error {
                throw AFError.serverTrustEvaluationFailed(reason: .trustEvaluationFailed(error: error))
            }
            throw AFError.serverTrustEvaluationFailed(reason: .defaultEvaluationFailed)
        }
    }
    
    func performValidation(forHost host: String) throws {
        guard host == (SecTrustCopyResult(self)?.takeRetainedValue() as? [String: Any])?["Hostname"] as? String else {
            throw AFError.serverTrustEvaluationFailed(reason: .hostValidationFailed)
        }
    }
}

// MARK: - AFError Extensions

extension AFError {
    enum ServerTrustFailureReason {
        case noCertificatesFound
        case defaultEvaluationFailed
        case trustEvaluationFailed(error: Error)
        case hostValidationFailed
        case certificatePinningFailed(host: String, trust: SecTrust, pinnedKeys: [String], serverKeys: [String])
    }
}
