//
//  QXTextField.swift
//  QodeX Design System Component
//

import SwiftUI

struct QXTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil
    var error: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: QXSpacing.xs) {
            if let icon = icon {
                HStack(spacing: QXSpacing.sm) {
                    Image(systemName: icon)
                        .foregroundColor(QXColor.gold)
                    Text(title)
                        .font(QXFont.caption)
                        .foregroundColor(QXColor.starlight.opacity(0.6))
                }
            } else {
                Text(title)
                    .font(QXFont.caption)
                    .foregroundColor(QXColor.starlight.opacity(0.6))
            }
            
            if isSecure {
                SecureField("", text: $text)
                    .textFieldStyle(QXTextFieldStyle())
                    .keyboardType(keyboardType)
            } else {
                TextField("", text: $text)
                    .textFieldStyle(QXTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct QXTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_self>) -> some View {
        configuration
            .padding(QXSpacing.md)
            .background(QXColor.deepVoid)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(QXColor.starlight)
    }
}

// MARK: - Validation

enum ValidationError: Error {
    case invalidEmail
    case weakPassword
    case emptyField
    case invalidDate
    
    var message: String {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and number"
        case .emptyField:
            return "This field is required"
        case .invalidDate:
            return "Please enter a valid date"
        }
    }
}

struct InputValidator {
    static func validate(email: String) throws {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        guard predicate.evaluate(with: email) else {
            throw ValidationError.invalidEmail
        }
    }
    
    static func validate(password: String) throws {
        guard password.count >= 8,
              password.range(of: "[A-Z]", options: .regularExpression) != nil,
              password.range(of: "[a-z]", options: .regularExpression) != nil,
              password.range(of: "[0-9]", options: .regularExpression) != nil else {
            throw ValidationError.weakPassword
        }
    }
    
    static func validate(name: String) throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyField
        }
    }
    
    static func validate(birthDate: Date) throws {
        let calendar = Calendar.current
        let now = Date()
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        guard age >= 13 && age <= 120 else {
            throw ValidationError.invalidDate
        }
    }
    
    static func sanitize(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static var rateLimits: [String: Date] = [:]
    
    static func checkRateLimit(identifier: String, cooldown: TimeInterval = 60) -> Bool {
        let now = Date()
        if let lastAttempt = rateLimits[identifier],
           now.timeIntervalSince(lastAttempt) < cooldown {
            return false
        }
        rateLimits[identifier] = now
        return true
    }
}
