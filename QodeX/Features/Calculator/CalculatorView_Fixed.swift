//
//  CalculatorView.swift
//  Fixed version with validation and loading states
//

import SwiftUI

struct CalculatorView: View {
    @State private var birthDate = Date()
    @State private var fullName = ""
    @State private var showResults = false
    @State private var loadingState: LoadingState = .idle
    @State private var validationError: String?
    @State private var calculatedNumbers: QodeNumbers?
    
    private let engine = CompatibilityEngine.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                headerSection
                
                // Input Section
                inputSection
                
                // Validation Error
                if let error = validationError {
                    ErrorBanner(message: error)
                }
                
                // Calculate Button
                calculateButton
                
                // Results
                if showResults, let numbers = calculatedNumbers {
                    resultsSection(numbers: numbers)
                }
            }
            .padding(.vertical, 20)
        }
        .loadingState(loadingState)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Qode Calculator")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text("Discover your energetic blueprint")
                .font(.system(size: 16))
                .foregroundStyle(QodeXColors.stardust)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 24) {
            // Birth Date
            VStack(alignment: .leading, spacing: 8) {
                Text("BIRTH DATE")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(QodeXColors.stardust)
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(16)
                .background(QodeXColors.deepVoid)
                .cornerRadius(12)
                .colorMultiply(QodeXColors.gold)
                .onChange(of: birthDate) { _ in
                    validateBirthDate()
                }
            }
            .padding(.horizontal, 20)
            
            // Full Name
            VStack(alignment: .leading, spacing: 8) {
                Text("FULL NAME AT BIRTH")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(QodeXColors.stardust)
                
                TextField("Enter your full name", text: $fullName)
                    .textFieldStyle(QodeXTextFieldStyle())
                    .onChange(of: fullName) { _ in
                        validateName()
                    }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var calculateButton: some View {
        Button(action: calculate) {
            HStack {
                if loadingState.isLoading {
                    ProgressView()
                        .tint(QodeXColors.cosmicBlack)
                } else {
                    Image(systemName: "sparkles")
                    Text("Decode My Qode")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundStyle(QodeXColors.cosmicBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [QodeXColors.gold, QodeXColors.goldGlow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(loadingState.isLoading || fullName.isEmpty)
        .padding(.horizontal, 20)
    }
    
    private func resultsSection(numbers: QodeNumbers) -> some View {
        VStack(spacing: 16) {
            QodeResultCard(
                number: numbers.lifePath,
                title: "Life Path Number",
                description: "The Seeker. Deeply analytical and introspective.",
                color: QodeXColors.mysticPurple
            )
            
            QodeResultCard(
                number: numbers.expression,
                title: "Expression Number",
                description: "The Creative. Self-expression and communication.",
                color: QodeXColors.cosmicTeal
            )
            
            QodeResultCard(
                number: numbers.soulUrge,
                title: "Soul Urge Number",
                description: "The Humanitarian. Your heart yearns to serve.",
                color: QodeXColors.gold
            )
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Validation
    
    private func validateBirthDate() {
        do {
            try InputValidator.validate(birthDate: birthDate)
            validationError = nil
        } catch {
            validationError = (error as? ValidationError)?.errorDescription
        }
    }
    
    private func validateName() {
        do {
            try InputValidator.validate(name: fullName)
            validationError = nil
        } catch {
            validationError = (error as? ValidationError)?.errorDescription
        }
    }
    
    // MARK: - Calculation
    
    private func calculate() {
        // Validate
        do {
            try InputValidator.validate(birthDate: birthDate)
            try InputValidator.validate(name: fullName)
        } catch {
            validationError = (error as? ValidationError)?.errorDescription
            return
        }
        
        // Check rate limit
        guard InputValidator.checkRateLimit(identifier: "calculation", maxAttempts: 10) else {
            validationError = "Too many attempts. Please try again later."
            return
        }
        
        // Calculate
        loadingState = .loading
        
        Task {
            do {
                let sanitizedName = InputValidator.sanitize(fullName)
                let chart = engine.calculateFullChart(for: birthDate, fullName: sanitizedName)
                
                await MainActor.run {
                    calculatedNumbers = QodeNumbers(
                        lifePath: chart.lifePath,
                        expression: chart.expression,
                        soulUrge: chart.soulUrge
                    )
                    showResults = true
                    loadingState = .success
                    
                    // Analytics
                    AnalyticsManager.shared.logQodeCalculated(
                        lifePath: chart.lifePath,
                        expression: chart.expression,
                        soulUrge: chart.soulUrge
                    )
                }
            } catch {
                await MainActor.run {
                    loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct QodeNumbers {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(QodeXColors.pureWhite)
            
            Spacer()
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

struct QodeResultCard: View {
    let number: Int
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 64, height: 64)
                    
                    Text("\(number)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Text("Core Number")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.stardust)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(QodeXColors.moonlight)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(QodeXColors.deepVoid)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    CalculatorView()
}
