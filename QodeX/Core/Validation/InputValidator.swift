//
//  InputValidator.swift
//  Input validation for security and UX
//

import Foundation

enum ValidationError: LocalizedError {
    case emptyField
    case invalidEmail
    case weakPassword
    case futureDate
    case tooOld
    case invalidName
    case invalidCharacter
    
    var errorDescription: String? {
        switch self {
        case .emptyField: return "This field cannot be empty"
        case .invalidEmail: return "Please enter a valid email address"
        case .weakPassword: return "Password must be at least 8 characters with uppercase, lowercase, and number"
        case .futureDate: return "Birth date cannot be in the future"
        case .tooOld: return "Please enter a valid birth date"
        case .invalidName: return "Name can only contain letters and spaces"
        case .invalidCharacter: return "Contains invalid characters"
        }
    }
}

struct InputValidator {
    
    // MARK: - Email Validation
    
    static func validate(email: String) throws {
        guard !email.isEmpty else {
            throw ValidationError.emptyField
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            throw ValidationError.invalidEmail
        }
    }
    
    // MARK: - Password Validation
    
    static func validate(password: String) throws {
        guard password.count >= 8 else {
            throw ValidationError.weakPassword
        }
        
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        guard hasUppercase && hasLowercase && hasDigit else {
            throw ValidationError.weakPassword
        }
    }
    
    // MARK: - Birth Date Validation
    
    static func validate(birthDate: Date) throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if future date
        guard birthDate <= now else {
            throw ValidationError.futureDate
        }
        
        // Check if too old (before 1900)
        let year = calendar.component(.year, from: birthDate)
        guard year >= 1900 else {
            throw ValidationError.tooOld
        }
        
        // Check if too young (under 13)
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        guard age >= 13 else {
            throw ValidationError.tooOld
        }
    }
    
    // MARK: - Name Validation
    
    static func validate(name: String) throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyField
        }
        
        guard name.count >= 2 else {
            throw ValidationError.invalidName
        }
        
        // Allow letters, spaces, hyphens, apostrophes
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "-'"))
        let nameCharacters = CharacterSet(charactersIn: name)
        
        guard allowedCharacters.isSuperset(of: nameCharacters) else {
            throw ValidationError.invalidName
        }
    }
    
    // MARK: - Sanitization
    
    static func sanitize(_ input: String) -> String {
        // Remove HTML tags
        var sanitized = input.replacingOccurrences(of: "<[^>]+", with: "", options: .regularExpression)
        
        // Trim whitespace
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Limit length
        if sanitized.count > 100 {
            sanitized = String(sanitized.prefix(100))
        }
        
        return sanitized
    }
    
    // MARK: - Rate Limiting Check
    
    /// Rate limiting data stored securely in Keychain
    private struct RateLimitData: Codable {
        let attempts: [Date]
        
        var isEmpty: Bool { attempts.isEmpty }
    }
    
    static func checkRateLimit(identifier: String, maxAttempts: Int = 5, windowSeconds: TimeInterval = 300) -> Bool {
        let key = KeychainKey.rateLimitAttempts
        let now = Date()
        
        // Get all rate limit data from keychain
        var allRateLimits: [String: RateLimitData] = KeychainManager.retrieve([String: RateLimitData].self, key: key) ?? [:]
        
        // Get existing attempts for this identifier
        let existingData = allRateLimits[identifier]
        let attempts = existingData?.attempts ?? []
        
        // Filter to recent attempts
        let recentAttempts = attempts.filter { now.timeIntervalSince($0) < windowSeconds }
        
        // Check if limit exceeded
        guard recentAttempts.count < maxAttempts else {
            return false
        }
        
        // Add new attempt
        var updatedAttempts = recentAttempts
        updatedAttempts.append(now)
        
        // Update keychain
        allRateLimits[identifier] = RateLimitData(attempts: updatedAttempts)
        _ = KeychainManager.store(allRateLimits, key: key)
        
        return true
    }
    
    /// Clear rate limit data for a specific identifier
    static func clearRateLimit(identifier: String) {
        let key = KeychainKey.rateLimitAttempts
        var allRateLimits: [String: RateLimitData] = KeychainManager.retrieve([String: RateLimitData].self, key: key) ?? [:]
        allRateLimits.removeValue(forKey: identifier)
        _ = KeychainManager.store(allRateLimits, key: key)
    }
    
    /// Clear all rate limit data
    static func clearAllRateLimits() {
        _ = KeychainManager.delete(key: .rateLimitAttempts)
    }
}

// MARK: - View Extension for Validation

import SwiftUI

extension View {
    func validatedInput(
        text: Binding<String>,
        validator: @escaping (String) throws -> Void,
        error: Binding<String?>
    ) -> some View {
        self.onChange(of: text.wrappedValue) { newValue in
            do {
                try validator(newValue)
                error.wrappedValue = nil
            } catch let validationError as ValidationError {
                error.wrappedValue = validationError.errorDescription
            } catch {
                error.wrappedValue = "Invalid input"
            }
        }
    }
}
