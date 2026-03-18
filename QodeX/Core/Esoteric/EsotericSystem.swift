//
//  EsotericSystem.swift
//  QodeX - Unified Esoteric Framework
//
//  Core protocol that all esoteric disciplines must implement.
//  This enables cross-system intelligence and unified user experience.
//

import Foundation
import SwiftUI

// MARK: - Core Protocol

/// All esoteric systems in QodeX conform to this protocol.
/// It defines the common interface that allows the app to treat
/// Numerology, Tarot, Astrology, and all other systems uniformly.
protocol EsotericSystem {
    // MARK: - System Identity
    
    /// Display name (e.g., "Tarot", "Astrology")
    static var systemName: String { get }
    
    /// SF Symbol icon name
    static var systemIcon: String { get }
    
    /// One-line description for system selection
    static var systemDescription: String { get }
    
    /// Origin tradition (e.g., "Ancient Egypt", "Medieval Kabbalah")
    static var originTradition: String { get }
    
    /// Estimated onboarding time in minutes
    static var onboardingDuration: Int { get }
    
    /// Difficulty level for learning
    static var learningCurve: LearningCurve { get }
    
    // MARK: - Associated Types
    
    /// The result type from calculations (e.g., NumerologyChart, NatalChart)
    associatedtype CalculationResult
    
    /// The interpretation type (e.g., ChartInterpretation, Reading)
    associatedtype Interpretation
    
    /// Data for visualization (e.g., ChartData, CardData)
    associatedtype VisualizationData
    
    // MARK: - Core Operations
    
    /// Calculate the user's personal data for this system
    func calculate(for blueprint: PersonalBlueprint) async throws -> CalculationResult
    
    /// Generate interpretation from calculation results
    func interpret(_ result: CalculationResult, context: InterpretationContext) -> Interpretation
    
    /// Create visualization data for UI rendering
    func generateVisualization(_ result: CalculationResult, style: VisualizationStyle) -> VisualizationData
    
    // MARK: - Cross-System Bridge
    
    /// Extract the universal energy signature from this system's results
    func extractEnergySignature(from result: CalculationResult) -> EnergySignature
    
    /// Get correspondences to other esoteric systems
    func getCorrespondences(_ signature: EnergySignature) -> [SystemCorrespondence]
    
    /// Get daily content for this system
    func getDailyContent(for blueprint: PersonalBlueprint, date: Date) -> SystemDailyContent
}

// MARK: - Supporting Types

enum LearningCurve: String, CaseIterable {
    case beginner = "Beginner"       // Can use immediately
    case intermediate = "Intermediate" // Some learning required
    case advanced = "Advanced"       // Significant study needed
    
    var description: String {
        switch self {
        case .beginner:
            return "Ready to use right away"
        case .intermediate:
            return "A few days to understand basics"
        case .advanced:
            return "Weeks of study to master"
        }
    }
}

enum VisualizationStyle {
    case minimal       // For small widgets
    case standard      // For cards and lists
    case detailed      // For full-screen views
    case interactive   // For interactive exploration
}

struct InterpretationContext {
    let focus: InterpretationFocus
    let detailLevel: DetailLevel
    let userExperience: UserExperienceLevel
    
    enum InterpretationFocus {
        case general
        case love
        case career
        case spiritual
        case health
        case timing
    }
    
    enum DetailLevel {
        case brief      // One sentence
        case standard   // Paragraph
        case detailed   // Multiple paragraphs
    }
    
    enum UserExperienceLevel {
        case beginner
        case intermediate
        case advanced
    }
}

// MARK: - System Correspondence

/// Represents a connection between two systems
struct SystemCorrespondence: Identifiable {
    let id = UUID()
    let fromSystem: String
    let toSystem: String
    let fromValue: String
    let toValue: String
    let connectionType: ConnectionType
    let significance: CorrespondenceSignificance
    let description: String
    
    enum ConnectionType {
        case direct       // One-to-one mapping
        case resonant     // Harmonious but not identical
        case challenging  // Tension-based connection
        case elemental    // Same element
        case planetary    // Same planet
        case numerical    // Same number
    }
    
    enum CorrespondenceSignificance: Int {
        minor = 1
        moderate = 2
        strong = 3
        primary = 4
    }
}

// MARK: - System Daily Content

/// Content generated daily for each system
struct SystemDailyContent {
    let systemName: String
    let date: Date
    let theme: String
    let keySymbol: String  // SF Symbol name
    let briefInsight: String
    let detailedInsight: String
    let actionSuggestion: String
    let meditationPrompt: String?
    let color: Color
    let energyLevel: EnergyLevel
    
    enum EnergyLevel: String {
        case veryLow = "Very Low"
        case low = "Low"
        case neutral = "Neutral"
        case high = "High"
        case veryHigh = "Very High"
        
        var color: Color {
            switch self {
            case .veryLow: return .gray
            case .low: return .blue
            case .neutral: return .green
            case .high: return .orange
            case .veryHigh: return .red
            }
        }
    }
}

// MARK: - System Registry

/// Central registry of all available esoteric systems
class EsotericSystemRegistry {
    static let shared = EsotericSystemRegistry()
    
    private var systems: [String: AnyEsotericSystem] = [:]
    
    func register<S: EsotericSystem>(_ system: S) {
        systems[S.systemName] = AnyEsotericSystem(system)
    }
    
    func getSystem(named name: String) -> AnyEsotericSystem? {
        return systems[name]
    }
    
    var allSystems: [AnyEsotericSystem] {
        Array(systems.values)
    }
    
    var enabledSystems: [AnyEsotericSystem] {
        // Filter based on user preferences
        allSystems.filter { $0.isEnabled }
    }
}

// MARK: - Type Erasure

/// Type-erased wrapper for EsotericSystem protocol
struct AnyEsotericSystem {
    private let _systemName: () -> String
    private let _systemIcon: () -> String
    private let _systemDescription: () -> String
    private let _originTradition: () -> String
    private let _learningCurve: () -> LearningCurve
    private let _calculate: (PersonalBlueprint) async throws -> Any
    private let _extractEnergySignature: (Any) -> EnergySignature
    private let _getDailyContent: (PersonalBlueprint, Date) -> SystemDailyContent
    
    var isEnabled: Bool = true  // From user preferences
    
    init<S: EsotericSystem>(_ system: S) {
        _systemName = { S.systemName }
        _systemIcon = { S.systemIcon }
        _systemDescription = { S.systemDescription }
        _originTradition = { S.originTradition }
        _learningCurve = { S.learningCurve }
        _calculate = { blueprint in
            try await system.calculate(for: blueprint)
        }
        _extractEnergySignature = { result in
            guard let typedResult = result as? S.CalculationResult else {
                // Return a neutral signature instead of crashing on type mismatch
                return EnergySignature.neutral
            }
            return system.extractEnergySignature(from: typedResult)
        }
        _getDailyContent = { blueprint, date in
            system.getDailyContent(for: blueprint, date: date)
        }
    }
    
    var systemName: String { _systemName() }
    var systemIcon: String { _systemIcon() }
    var systemDescription: String { _systemDescription() }
    var originTradition: String { _originTradition() }
    var learningCurve: LearningCurve { _learningCurve() }
    
    func calculate(for blueprint: PersonalBlueprint) async throws -> Any {
        return try await _calculate(blueprint)
    }
    
    func extractEnergySignature(from result: Any) -> EnergySignature {
        return _extractEnergySignature(result)
    }
    
    func getDailyContent(for blueprint: PersonalBlueprint, date: Date) -> SystemDailyContent {
        return _getDailyContent(blueprint, date)
    }
}

// MARK: - System Status

/// Tracks user's progress with each system
struct SystemStatus {
    let systemName: String
    let isUnlocked: Bool
    let isEnabled: Bool
    let discoveryProgress: Double  // 0.0 - 1.0
    let lastUsed: Date?
    let favoriteAspect: String?
    let proficiencyLevel: ProficiencyLevel
    
    enum ProficiencyLevel: String {
        case novice = "Novice"
        case apprentice = "Apprentice"
        case adept = "Adept"
        case master = "Master"
    }
}
