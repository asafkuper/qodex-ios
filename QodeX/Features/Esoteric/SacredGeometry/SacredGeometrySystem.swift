//
//  SacredGeometrySystem.swift
//  QodeX - Sacred Geometry Feature Module
//
//  Sacred forms, Flower of Life, Platonic solids,
//  and personal mandala generation.
//

import Foundation
import SwiftUI

final class SacredGeometrySystem: EsotericSystem {
    static var systemName: String { "Sacred Geometry" }
    static var systemIcon: String { "hexagon.fill" }
    static var systemDescription: String { "Divine patterns, Platonic solids, and geometric meditation" }
    static var originTradition: String { "Ancient Egypt / Greece" }
    static var onboardingDuration: Int { 15 }
    static var learningCurve: LearningCurve { .intermediate }
    
    typealias CalculationResult = GeometryProfile
    typealias Interpretation = GeometryInterpretation
    typealias VisualizationData = GeometryVisualization
    
    func calculate(for blueprint: PersonalBlueprint) async throws -> GeometryProfile {
        // Determine primary sacred form from numerology
        let primaryForm = determinePrimaryForm(for: blueprint)
        
        // Calculate personal mandala
        let mandala = generatePersonalMandala(for: blueprint)
        
        // Find geometric patterns in birth date
        let patterns = findBirthPatterns(for: blueprint)
        
        // Determine elemental balance through geometry
        let elementalGeometry = calculateElementalGeometry(for: blueprint)
        
        return GeometryProfile(
            primaryForm: primaryForm,
            secondaryForms: complementaryForms(for: primaryForm),
            personalMandala: mandala,
            birthPatterns: patterns,
            elementalGeometry: elementalGeometry,
            drawingGuides: createDrawingGuides(for: primaryForm)
        )
    }
    
    func interpret(_ result: GeometryProfile, context: InterpretationContext) -> GeometryInterpretation {
        return GeometryInterpretation(
            formMeaning: "\(result.primaryForm.rawValue) represents \(formDescription(result.primaryForm))",
            meditationFocus: "Gaze upon the \(result.primaryForm.rawValue) and feel its \(result.primaryForm.element.rawValue) energy",
            practice: "Draw the \(result.primaryForm.rawValue) daily to strengthen your connection",
            affirmation: "I embody the perfect form of \(result.primaryForm.rawValue)"
        )
    }
    
    func generateVisualization(_ result: GeometryProfile, style: VisualizationStyle) -> GeometryVisualization {
        return GeometryVisualization(
            primaryForm: result.primaryForm,
            mandala: style == .detailed ? result.personalMandala : nil,
            animation: .rotate,
            colorScheme: elementColorScheme(result.primaryForm.element)
        )
    }
    
    func extractEnergySignature(from result: GeometryProfile) -> EnergySignature {
        return EnergySignature(
            timestamp: Date(),
            primaryFrequency: result.primaryForm.toFrequency(),
            harmonicFrequencies: result.secondaryForms.map { $0.toFrequency() },
            vibrationalQuality: result.primaryForm.toVibrationalQuality(),
            elementalResonance: result.elementalGeometry,
            coreNumbers: [result.primaryForm.numberOfPoints: NumericalArchetype(
                number: result.primaryForm.numberOfPoints,
                archetypeName: result.primaryForm.rawValue,
                keywords: [result.primaryForm.element.rawValue, "sacred"],
                description: formDescription(result.primaryForm),
                shadow: "",
                gift: "",
                weight: 1.0
            )],
            masterResonance: [],
            karmicIndicators: [],
            sacredForms: [result.primaryForm] + result.secondaryForms,
            geometricRatios: result.birthPatterns.compactMap { $0.ratio },
            symmetryType: result.primaryForm.toSymmetryType(),
            planetaryRulers: [],
            zodiacResonance: [],
            lunarPhase: nil,
            seasonalResonance: nil,
            sephiroticPath: [],
            hebrewLetter: nil,
            divineName: nil,
            tarotCorrespondences: [],
            playingCardCorrespondences: [],
            alchemicalStage: result.primaryForm.toAlchemicalStage(),
            recommendedOperations: [],
            polarity: result.primaryForm.element == .fire || result.primaryForm.element == .air ? .masculine : .feminine,
            modality: .fixed,
            direction: nil
        )
    }
    
    func getCorrespondences(_ signature: EnergySignature) -> [SystemCorrespondence] {
        return []
    }
    
    func getDailyContent(for blueprint: PersonalBlueprint, date: Date) -> SystemDailyContent {
        let profile = try? calculate(for: blueprint)
        let form = profile?.primaryForm ?? .flowerOfLife
        
        return SystemDailyContent(
            systemName: Self.systemName,
            date: date,
            theme: form.rawValue,
            keySymbol: "hexagon.fill",
            briefInsight: form.element.rawValue,
            detailedInsight: "Today's sacred form is the \(form.rawValue). \(formDescription(form))",
            actionSuggestion: "Spend 5 minutes gazing at or drawing the \(form.rawValue)",
            meditationPrompt: "Trace the edges of the \(form.rawValue) with your mind's eye",
            color: elementColor(form.element),
            energyLevel: .moderate
        )
    }
    
    // MARK: - Calculations
    
    private func determinePrimaryForm(for blueprint: PersonalBlueprint) -> SacredForm {
        if let lifePath = blueprint.numerologyProfile?.lifePath,
           let corr = CorrespondenceMatrix.shared.findByNumber(lifePath) {
            return corr.sacredForm
        }
        return .flowerOfLife
    }
    
    private func complementaryForms(for primary: SacredForm) -> [SacredForm] {
        switch primary {
        case .flowerOfLife:
            return [.seedOfLife, .treeOfLife, .metatronsCube]
        case .treeOfLife:
            return [.flowerOfLife, .merkaba, .cube]
        case .merkaba:
            return [.starTetrahedron, .octahedron, .flowerOfLife]
        default:
            return [.flowerOfLife, .treeOfLife]
        }
    }
    
    private func generatePersonalMandala(for blueprint: PersonalBlueprint) -> Mandala {
        let form = determinePrimaryForm(for: blueprint)
        let colors = blueprint.elementalProfile.map { profile in
            [elementColor(profile.dominant ?? .quintessence)]
        } ?? [.purple, .blue, .gold]
        
        return Mandala(
            layers: [
                MandalaLayer(form: form, color: colors[0], radius: 100),
                MandalaLayer(form: .circle, color: colors.count > 1 ? colors[1] : .white, radius: 80),
                MandalaLayer(form: .flowerOfLife, color: colors.count > 2 ? colors[2] : .gold, radius: 60)
            ],
            center: form,
            animationSpeed: 0.5
        )
    }
    
    private func findBirthPatterns(for blueprint: PersonalBlueprint) -> [GeometricPattern] {
        var patterns: [GeometricPattern] = []
        
        // Check for golden ratio in birth date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: blueprint.birthDate)
        let month = calendar.component(.month, from: blueprint.birthDate)
        
        let ratio = Double(day) / Double(month)
        if abs(ratio - 1.618) < 0.1 {
            patterns.append(GeometricPattern(
                type: .goldenRatio,
                ratio: ratio,
                significance: "Your birth date contains the golden ratio",
                source: "Birth date ratio"
            ))
        }
        
        return patterns
    }
    
    private func calculateElementalGeometry(for blueprint: PersonalBlueprint) -> ElementalBalance {
        let form = determinePrimaryForm(for: blueprint)
        
        switch form.element {
        case .fire:
            return ElementalBalance(fire: 0.5, water: 0.1, air: 0.2, earth: 0.1, quintessence: 0.1)
        case .water:
            return ElementalBalance(fire: 0.1, water: 0.5, air: 0.1, earth: 0.2, quintessence: 0.1)
        case .air:
            return ElementalBalance(fire: 0.1, water: 0.1, air: 0.5, earth: 0.1, quintessence: 0.2)
        case .earth:
            return ElementalBalance(fire: 0.1, water: 0.1, air: 0.2, earth: 0.5, quintessence: 0.1)
        default:
            return ElementalBalance(fire: 0.2, water: 0.2, air: 0.2, earth: 0.2, quintessence: 0.5)
        }
    }
    
    private func createDrawingGuides(for form: SacredForm) -> [DrawingStep] {
        // Return step-by-step drawing instructions
        return [
            DrawingStep(number: 1, instruction: "Begin at the center", visualGuide: "center_point"),
            DrawingStep(number: 2, instruction: "Draw the first circle", visualGuide: "circle_1"),
            DrawingStep(number: 3, instruction: "Add surrounding circles", visualGuide: "circles_6")
        ]
    }
    
    // MARK: - Helpers
    
    private func formDescription(_ form: SacredForm) -> String {
        switch form {
        case .circle:
            return "The circle represents unity, wholeness, and the infinite."
        case .flowerOfLife:
            return "The Flower of Life contains the blueprint of all creation."
        case .treeOfLife:
            return "The Tree of Life maps the path from matter to spirit."
        case .merkaba:
            return "The Merkaba is the chariot of ascension and light body activation."
        case .tetrahedron:
            return "The tetrahedron represents fire and the balance of opposites."
        case .cube:
            return "The cube represents earth and stable manifestation."
        case .octahedron:
            return "The octahedron represents air and the heart of compassion."
        case .dodecahedron:
            return "The dodecahedron represents ether and divine thought."
        case .icosahedron:
            return "The icosahedron represents water and emotional flow."
        default:
            return "Sacred geometry reveals the patterns underlying all existence."
        }
    }
    
    private func elementColor(_ element: Element) -> Color {
        switch element {
        case .fire: return .red
        case .water: return .blue
        case .air: return .yellow
        case .earth: return .green
        case .quintessence: return .purple
        case .void: return .black
        }
    }
    
    private func elementColorScheme(_ element: Element) -> [Color] {
        switch element {
        case .fire: return [.red, .orange, .yellow]
        case .water: return [.blue, .cyan, .indigo]
        case .air: return [.yellow, .white, .lightGray]
        case .earth: return [.green, .brown, .gray]
        case .quintessence: return [.purple, .gold, .white]
        case .void: return [.black, .gray, .white]
        }
    }
}

// MARK: - Supporting Types

struct GeometryProfile {
    let primaryForm: SacredForm
    let secondaryForms: [SacredForm]
    let personalMandala: Mandala
    let birthPatterns: [GeometricPattern]
    let elementalGeometry: ElementalBalance
    let drawingGuides: [DrawingStep]
}

struct GeometryInterpretation {
    let formMeaning: String
    let meditationFocus: String
    let practice: String
    let affirmation: String
}

struct GeometryVisualization {
    let primaryForm: SacredForm
    let mandala: Mandala?
    let animation: AnimationType
    let colorScheme: [Color]
    
    enum AnimationType {
        case rotate
        case pulse
        case breathe
        case bloom
    }
}

struct Mandala {
    let layers: [MandalaLayer]
    let center: SacredForm
    let animationSpeed: Double
}

struct MandalaLayer {
    let form: SacredForm
    let color: Color
    let radius: CGFloat
}

struct GeometricPattern {
    let type: PatternType
    let ratio: Double
    let significance: String
    let source: String
    
    enum PatternType {
        case goldenRatio
        case fibonacci
        case vesicaPiscis
        case flowerOfLife
        case metatronsCube
    }
}

struct DrawingStep {
    let number: Int
    let instruction: String
    let visualGuide: String
}

// Additional Sacred Forms
extension SacredForm {
    static let starTetrahedron = SacredForm.merkaba  // Alias
    
    func toFrequency() -> Double {
        switch self {
        case .tetrahedron: return 396
        case .cube: return 417
        case .octahedron: return 528
        case .dodecahedron: return 639
        case .icosahedron: return 741
        case .merkaba: return 852
        case .sphere: return 963
        default: return 432
        }
    }
    
    func toAlchemicalStage() -> AlchemicalStage? {
        switch self {
        case .tetrahedron: return .calcination
        case .cube: return .conjunction
        case .octahedron: return .distillation
        case .dodecahedron: return .fermentation
        case .icosahedron: return .dissolution
        case .merkaba: return .coagulation
        default: return nil
        }
    }
}
