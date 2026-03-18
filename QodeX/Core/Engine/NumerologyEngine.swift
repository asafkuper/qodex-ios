import Foundation

/// Core engine for all numerology calculations
/// Handles Life Path, Expression, Soul Urge, and Birthday numbers
/// with proper Master Number preservation (11, 22, 33)
public final class NumerologyEngine {
    
    // MARK: - Types
    
    /// Master numbers that should not be reduced
    public static let masterNumbers: Set<Int> = [11, 22, 33]
    
    /// Result of a numerology calculation
    public struct NumberResult {
        public let value: Int
        public let isMasterNumber: Bool
        public let calculationSteps: [String]
        
        public init(value: Int, calculationSteps: [String]) {
            self.value = value
            self.isMasterNumber = Self.isMasterNumber(value)
            self.calculationSteps = calculationSteps
        }
        
        public static func isMasterNumber(_ value: Int) -> Bool {
            return NumerologyEngine.masterNumbers.contains(value)
        }
    }
    
    // MARK: - Life Path Number
    
    /// Calculate Life Path Number from birth date
    /// Sum all digits of birth date and reduce to single digit (unless Master Number)
    public static func calculateLifePath(birthDate: Date) -> NumberResult {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return NumberResult(value: 0, calculationSteps: ["Error: Invalid date"])
        }
        
        var steps: [String] = []
        steps.append("Life Path Calculation:")
        steps.append("Date: \(day)/\(month)/\(year)")
        
        // Sum day digits
        let daySum = digitSum(day)
        steps.append("Day \(day) → \(daySum)")
        
        // Sum month digits
        let monthSum = digitSum(month)
        steps.append("Month \(month) → \(monthSum)")
        
        // Sum year digits
        let yearSum = digitSum(year)
        steps.append("Year \(year) → \(yearSum)")
        
        // Total sum
        let total = daySum + monthSum + yearSum
        steps.append("Sum: \(daySum) + \(monthSum) + \(yearSum) = \(total)")
        
        // Final reduction
        let finalValue = reduceToSingleDigit(total, preserveMasterNumbers: true)
        steps.append("Final reduction: \(total) → \(finalValue)")
        
        if masterNumbers.contains(finalValue) {
            steps.append("Master Number \(finalValue) preserved!")
        }
        
        return NumberResult(value: finalValue, calculationSteps: steps)
    }
    
    // MARK: - Expression Number
    
    /// Calculate Expression Number from full birth name
    /// Uses Pythagorean numerology chart
    public static func calculateExpression(name: String) -> NumberResult {
        var steps: [String] = []
        steps.append("Expression Number Calculation:")
        steps.append("Name: \(name)")
        
        let uppercased = name.uppercased()
        var total = 0
        var letterValues: [String] = []
        
        for char in uppercased {
            if let value = letterValue(char) {
                total += value
                letterValues.append("\(char)=\(value)")
            }
        }
        
        steps.append("Letter values: \(letterValues.joined(separator: ", "))")
        steps.append("Total: \(total)")
        
        let finalValue = reduceToSingleDigit(total, preserveMasterNumbers: true)
        steps.append("Final reduction: \(total) → \(finalValue)")
        
        if masterNumbers.contains(finalValue) {
            steps.append("Master Number \(finalValue) preserved!")
        }
        
        return NumberResult(value: finalValue, calculationSteps: steps)
    }
    
    // MARK: - Soul Urge Number
    
    /// Calculate Soul Urge (Heart's Desire) Number from vowels in name
    public static func calculateSoulUrge(name: String) -> NumberResult {
        var steps: [String] = []
        steps.append("Soul Urge Number Calculation:")
        steps.append("Name: \(name)")
        
        let uppercased = name.uppercased()
        var total = 0
        var vowelValues: [String] = []
        
        for char in uppercased {
            if isVowel(char) {
                if let value = letterValue(char) {
                    total += value
                    vowelValues.append("\(char)=\(value)")
                }
            }
        }
        
        steps.append("Vowel values: \(vowelValues.joined(separator: ", "))")
        steps.append("Total: \(total)")
        
        let finalValue = reduceToSingleDigit(total, preserveMasterNumbers: true)
        steps.append("Final reduction: \(total) → \(finalValue)")
        
        if masterNumbers.contains(finalValue) {
            steps.append("Master Number \(finalValue) preserved!")
        }
        
        return NumberResult(value: finalValue, calculationSteps: steps)
    }
    
    // MARK: - Birthday Number
    
    /// Calculate Birthday Number from day of birth only
    public static func calculateBirthday(birthDate: Date) -> NumberResult {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: birthDate)
        
        guard let day = components.day else {
            return NumberResult(value: 0, calculationSteps: ["Error: Invalid date"])
        }
        
        var steps: [String] = []
        steps.append("Birthday Number Calculation:")
        steps.append("Day of birth: \(day)")
        
        // Birthday number is simply the reduced day
        // Master numbers 11 and 22 are valid for birthday
        let finalValue: Int
        if masterNumbers.contains(day) {
            finalValue = day
            steps.append("Master Number \(day) preserved!")
        } else {
            finalValue = reduceToSingleDigit(day, preserveMasterNumbers: true)
            steps.append("Reduction: \(day) → \(finalValue)")
        }
        
        return NumberResult(value: finalValue, calculationSteps: steps)
    }
    
    // MARK: - Helper Methods
    
    /// Get numerology value for a letter using Pythagorean system
    /// A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8, I=9
    /// J=1, K=2, L=3, M=4, N=5, O=6, P=7, Q=8, R=9
    /// S=1, T=2, U=3, V=4, W=5, X=6, Y=7, Z=8
    public static func letterValue(_ letter: Character) -> Int? {
        let uppercase = letter.uppercased()
        guard let scalar = uppercase.unicodeScalars.first else { return nil }
        let ascii = Int(scalar.value)
        
        // A=65 in ASCII, so A=1, B=2, etc.
        if ascii >= 65 && ascii <= 90 {
            let position = ascii - 64 // A=1, B=2, ..., Z=26
            // Wrap around: 1-9, 1-9, 1-8
            let value = ((position - 1) % 9) + 1
            return value
        }
        
        return nil
    }
    
    /// Check if a character is a vowel (including Y as vowel when appropriate)
    /// For Soul Urge: A, E, I, O, U (and sometimes Y)
    public static func isVowel(_ letter: Character) -> Bool {
        let vowels: Set<Character> = ["A", "E", "I", "O", "U"]
        return vowels.contains(letter.uppercased().first ?? " ")
    }
    
    /// Calculate digit sum of a number (e.g., 1990 → 1+9+9+0 = 19 → 1+9 = 10 → 1+0 = 1)
    public static func digitSum(_ number: Int) -> Int {
        var sum = 0
        var n = abs(number)
        
        while n > 0 {
            sum += n % 10
            n /= 10
        }
        
        return sum
    }
    
    /// Reduce a number to a single digit, optionally preserving master numbers
    /// - Parameters:
    ///   - number: The number to reduce
    ///   - preserveMasterNumbers: If true, stops at 11, 22, or 33
    /// - Returns: Reduced value (1-9) or master number (11, 22, 33)
    public static func reduceToSingleDigit(_ number: Int, preserveMasterNumbers: Bool = true) -> Int {
        var result = abs(number)
        
        while result > 9 {
            // Check for master numbers before reducing
            if preserveMasterNumbers && masterNumbers.contains(result) {
                return result
            }
            result = digitSum(result)
        }
        
        return result
    }
    
    /// Get all digits of a number as an array
    public static func digits(_ number: Int) -> [Int] {
        var result: [Int] = []
        var n = abs(number)
        
        if n == 0 {
            return [0]
        }
        
        while n > 0 {
            result.insert(n % 10, at: 0)
            n /= 10
        }
        
        return result
    }
    
    /// Calculate the numerical value of a string (for names, words, etc.)
    public static func stringValue(_ string: String) -> Int {
        var total = 0
        for char in string.uppercased() {
            if let value = letterValue(char) {
                total += value
            }
        }
        return total
    }
    
    // MARK: - Validation
    
    /// Validate if a date is reasonable for numerology calculation
    public static func isValidBirthDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        
        guard let year = components.year else { return false }
        
        // Reasonable range: 1900 to current year
        let currentYear = calendar.component(.year, from: Date())
        return year >= 1900 && year <= currentYear
    }
    
    /// Check if a calculated value is a master number
    public static func isMasterNumber(_ value: Int) -> Bool {
        return masterNumbers.contains(value)
    }
}

// MARK: - Convenience Extensions

public extension NumerologyEngine.NumberResult {
    /// Short description of the number
    var description: String {
        if isMasterNumber {
            return "\(value) (Master Number)"
        }
        return "\(value)"
    }
    
    /// Formatted calculation trace
    var calculationTrace: String {
        return calculationSteps.joined(separator: "\n")
    }
}