//
//  PeriodicTableView.swift
//  QodeX
//
//  Interactive Periodic Table with Numerology & Alchemy
//  Style: Glassmorphism, Gold Accents (#E5C158), Scientific Mystical Theme
//

import SwiftUI
import SceneKit

// MARK: - Data Models

struct Element: Identifiable, Codable {
    let id = UUID()
    let atomicNumber: Int
    let symbol: String
    let name: String
    let atomicMass: Double
    let category: ElementCategory
    let group: Int
    let period: Int
    let electronConfiguration: String
    let oxidationStates: [Int]
    let physicalState: PhysicalState
    let mysticalMeaning: String
    let numerologySignificance: String
    let alchemicalProperty: AlchemicalProperty
    let crystalStructure: String
    let discoveredBy: String
    let yearDiscovered: Int
    let magicalAffinity: [MagicalAffinity]
    
    var numerologyNumber: Int {
        reduceToSingleDigit(atomicNumber)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var num = number
        while num > 9 && num != 11 && num != 22 && num != 33 {
            var sum = 0
            while num > 0 {
                sum += num % 10
                num /= 10
            }
            num = sum
        }
        return num
    }
}

enum ElementCategory: String, Codable, CaseIterable {
    case alkaliMetal = "Alkali Metal"
    case alkalineEarthMetal = "Alkaline Earth Metal"
    case transitionMetal = "Transition Metal"
    case postTransitionMetal = "Post-transition Metal"
    case metalloid = "Metalloid"
    case nonmetal = "Nonmetal"
    case halogen = "Halogen"
    case nobleGas = "Noble Gas"
    case lanthanide = "Lanthanide"
    case actinide = "Actinide"
    case unknown = "Unknown"
    
    var color: Color {
        switch self {
        case .alkaliMetal: return Color(hex: "#FF6B6B")
        case .alkalineEarthMetal: return Color(hex: "#FFE66D")
        case .transitionMetal: return Color(hex: "#E5C158") // Gold accent
        case .postTransitionMetal: return Color(hex: "#95E1D3")
        case .metalloid: return Color(hex: "#A8E6CF")
        case .nonmetal: return Color(hex: "#7FD8BE")
        case .halogen: return Color(hex: "#C7CEEA")
        case .nobleGas: return Color(hex: "#FFDAC1")
        case .lanthanide: return Color(hex: "#B4A7D6")
        case .actinide: return Color(hex: "#D5AAFF")
        case .unknown: return Color(hex: "#888888")
        }
    }
    
    var mysticalSymbol: String {
        switch self {
        case .alkaliMetal: return "🔥"
        case .alkalineEarthMetal: return "🌍"
        case .transitionMetal: return "⚔️"
        case .postTransitionMetal: return "🔧"
        case .metalloid: return "☯️"
        case .nonmetal: return "💨"
        case .halogen: return "⚡"
        case .nobleGas: return "👑"
        case .lanthanide: return "🌙"
        case .actinide: return "☢️"
        case .unknown: return "❓"
        }
    }
}

enum PhysicalState: String, Codable, CaseIterable {
    case solid = "Solid"
    case liquid = "Liquid"
    case gas = "Gas"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .solid: return "■"
        case .liquid: return "◉"
        case .gas: return "○"
        case .unknown: return "?"
        }
    }
}

enum AlchemicalProperty: String, Codable {
    case gold = "☉ Gold"
    case silver = "☽ Silver"
    case mercury = "☿ Mercury"
    case sulfur = "🜍 Sulfur"
    case salt = "🜔 Salt"
    case lead = "♄ Lead"
    case tin = "♃ Tin"
    case iron = "♂ Iron"
    case copper = "♀ Copper"
    case antimony = "🜨 Antimony"
    case arsenic = "🜺 Arsenic"
    case bismuth = "🜘 Bismuth"
    case none = "None"
    
    var color: Color {
        switch self {
        case .gold: return Color(hex: "#FFD700")
        case .silver: return Color(hex: "#C0C0C0")
        case .mercury: return Color(hex: "#E5E4E2")
        case .sulfur: return Color(hex: "#FFD700")
        case .salt: return Color.white
        case .lead: return Color(hex: "#4A4A4A")
        case .tin: return Color(hex: "#D3D3D3")
        case .iron: return Color(hex: "#B22222")
        case .copper: return Color(hex: "#B87333")
        case .antimony: return Color(hex: "#6B6B6B")
        case .arsenic: return Color(hex: "#9ACD32")
        case .bismuth: return Color(hex: "#E6E6FA")
        case .none: return Color.clear
        }
    }
}

enum MagicalAffinity: String, Codable {
    case healing = "🌿 Healing"
    case protection = "🛡️ Protection"
    case transformation = "🦋 Transformation"
    case clarity = "💎 Clarity"
    case passion = "🔥 Passion"
    case wisdom = "📚 Wisdom"
    case abundance = "💰 Abundance"
    case intuition = "🔮 Intuition"
    case strength = "💪 Strength"
    case purification = "✨ Purification"
}

// MARK: - Numerology Meanings

struct NumerologyMeanings {
    static let meanings: [Int: String] = [
        1: "Leadership, independence, new beginnings. The spark of creation.",
        2: "Balance, harmony, partnership. The dance of duality.",
        3: "Creativity, expression, joy. The divine trinity.",
        4: "Stability, foundation, order. The sacred square.",
        5: "Change, freedom, adventure. The quintessence.",
        6: "Love, nurturing, responsibility. The perfect number.",
        7: "Spirituality, mystery, wisdom. The seeker's number.",
        8: "Power, abundance, karma. The infinite loop.",
        9: "Completion, compassion, enlightenment. The crown number.",
        11: "Master number - Illumination, spiritual insight, intuition.",
        22: "Master number - The master builder, cosmic manifestation.",
        33: "Master number - Christ consciousness, ultimate service."
    ]
    
    static func meaning(for number: Int) -> String {
        meanings[number] ?? "Unknown mystical vibration"
    }
}

// MARK: - Element Data (All 118 Elements)

struct ElementData {
    static let allElements: [Element] = [
        // Period 1
        Element(atomicNumber: 1, symbol: "H", name: "Hydrogen", atomicMass: 1.008, category: .nonmetal, group: 1, period: 1, electronConfiguration: "1s¹", oxidationStates: [1, -1], physicalState: .gas, mysticalMeaning: "The primordial element of creation, representing pure potential and the spark of life.", numerologySignificance: "Number 1: The beginning of all things, pure consciousness emerging from the void.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Henry Cavendish", yearDiscovered: 1766, magicalAffinity: [.purification, .transformation]),
        
        Element(atomicNumber: 2, symbol: "He", name: "Helium", atomicMass: 4.0026, category: .nobleGas, group: 18, period: 1, electronConfiguration: "1s²", oxidationStates: [0], physicalState: .gas, mysticalMeaning: "The sun's breath, representing levity and the ethereal realm.", numerologySignificance: "Number 2: Divine balance and cosmic harmony.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Pierre Janssen", yearDiscovered: 1868, magicalAffinity: [.clarity, .intuition]),
        
        // Period 2
        Element(atomicNumber: 3, symbol: "Li", name: "Lithium", atomicMass: 6.94, category: .alkaliMetal, group: 1, period: 2, electronConfiguration: "[He] 2s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The mood balancer, bridging the gap between madness and clarity.", numerologySignificance: "Number 3: Creative expression and emotional harmony.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Johan August Arfwedson", yearDiscovered: 1817, magicalAffinity: [.healing, .clarity]),
        
        Element(atomicNumber: 4, symbol: "Be", name: "Beryllium", atomicMass: 9.0122, category: .alkalineEarthMetal, group: 2, period: 2, electronConfiguration: "[He] 2s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The emerald heart, connecting earth energy to higher realms.", numerologySignificance: "Number 4: Stable foundation and material manifestation.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Louis Nicolas Vauquelin", yearDiscovered: 1798, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 5, symbol: "B", name: "Boron", atomicMass: 10.81, category: .metalloid, group: 13, period: 2, electronConfiguration: "[He] 2s² 2p¹", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The neutron star's gift, representing resilience and purification.", numerologySignificance: "Number 5: Transformation and the quintessence of nature.", alchemicalProperty: .none, crystalStructure: "Rhombohedral", discoveredBy: "Joseph Louis Gay-Lussac", yearDiscovered: 1808, magicalAffinity: [.purification, .strength]),
        
        Element(atomicNumber: 6, symbol: "C", name: "Carbon", atomicMass: 12.011, category: .nonmetal, group: 14, period: 2, electronConfiguration: "[He] 2s² 2p²", oxidationStates: [4, 2, -4], physicalState: .solid, mysticalMeaning: "The diamond soul - the foundation of all life and consciousness.", numerologySignificance: "Number 6: Perfect balance, the hexagon of creation.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Ancient", yearDiscovered: -3750, magicalAffinity: [.wisdom, .abundance]),
        
        Element(atomicNumber: 7, symbol: "N", name: "Nitrogen", atomicMass: 14.007, category: .nonmetal, group: 15, period: 2, electronConfiguration: "[He] 2s² 2p³", oxidationStates: [5, 4, 3, 2, 1, -1, -2, -3], physicalState: .gas, mysticalMeaning: "The breath of life, representing dreams and the realm of thought.", numerologySignificance: "Number 7: Mystical wisdom and spiritual seeking.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Daniel Rutherford", yearDiscovered: 1772, magicalAffinity: [.intuition, .clarity]),
        
        Element(atomicNumber: 8, symbol: "O", name: "Oxygen", atomicMass: 15.999, category: .nonmetal, group: 16, period: 2, electronConfiguration: "[He] 2s² 2p⁴", oxidationStates: [-2], physicalState: .gas, mysticalMeaning: "The vital breath - transformation, passion, and the flame of life.", numerologySignificance: "Number 8: Infinite power and cosmic abundance.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "Carl Wilhelm Scheele", yearDiscovered: 1771, magicalAffinity: [.passion, .transformation]),
        
        Element(atomicNumber: 9, symbol: "F", name: "Fluorine", atomicMass: 18.998, category: .halogen, group: 17, period: 2, electronConfiguration: "[He] 2s² 2p⁵", oxidationStates: [-1], physicalState: .gas, mysticalMeaning: "The burning light, representing intensity and spiritual cleansing.", numerologySignificance: "Number 9: Completion and the culmination of cycles.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "André-Marie Ampère", yearDiscovered: 1810, magicalAffinity: [.purification, .strength]),
        
        Element(atomicNumber: 10, symbol: "Ne", name: "Neon", atomicMass: 20.180, category: .nobleGas, group: 18, period: 2, electronConfiguration: "[He] 2s² 2p⁶", oxidationStates: [0], physicalState: .gas, mysticalMeaning: "The cosmic messenger, illumination and divine revelation.", numerologySignificance: "Number 1 (1+0): New beginnings and pure light.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "William Ramsay", yearDiscovered: 1898, magicalAffinity: [.clarity, .intuition]),
        
        // Period 3
        Element(atomicNumber: 11, symbol: "Na", name: "Sodium", atomicMass: 22.990, category: .alkaliMetal, group: 1, period: 3, electronConfiguration: "[Ne] 3s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The moon metal - intuition, emotions, and purification.", numerologySignificance: "Master Number 11: Spiritual illumination and psychic awakening.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Humphry Davy", yearDiscovered: 1807, magicalAffinity: [.intuition, .purification]),
        
        Element(atomicNumber: 12, symbol: "Mg", name: "Magnesium", atomicMass: 24.305, category: .alkalineEarthMetal, group: 2, period: 3, electronConfiguration: "[Ne] 3s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The flame within - vitality, energy, and the spark of courage.", numerologySignificance: "Number 3: Creative energy and dynamic expression.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Joseph Black", yearDiscovered: 1755, magicalAffinity: [.strength, .passion]),
        
        Element(atomicNumber: 13, symbol: "Al", name: "Aluminium", atomicMass: 26.982, category: .postTransitionMetal, group: 13, period: 3, electronConfiguration: "[Ne] 3s² 3p¹", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The wings of lightness - freedom, flexibility, and protection.", numerologySignificance: "Number 4: Solid foundation and practical manifestation.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Hans Christian Ørsted", yearDiscovered: 1825, magicalAffinity: [.protection, .transformation]),
        
        Element(atomicNumber: 14, symbol: "Si", name: "Silicon", atomicMass: 28.085, category: .metalloid, group: 14, period: 3, electronConfiguration: "[Ne] 3s² 3p²", oxidationStates: [4, -4], physicalState: .solid, mysticalMeaning: "The valley of dreams - technology, communication, and crystalline thought.", numerologySignificance: "Number 5: Innovation and the bridge between worlds.", alchemicalProperty: .none, crystalStructure: "Diamond Cubic", discoveredBy: "Jöns Jacob Berzelius", yearDiscovered: 1824, magicalAffinity: [.clarity, .wisdom]),
        
        Element(atomicNumber: 15, symbol: "P", name: "Phosphorus", atomicMass: 30.974, category: .nonmetal, group: 15, period: 3, electronConfiguration: "[Ne] 3s² 3p³", oxidationStates: [5, 3, -3], physicalState: .solid, mysticalMeaning: "The light-bringer - illumination, knowledge, and the divine spark.", numerologySignificance: "Number 6: Harmony and the light of understanding.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "Hennig Brand", yearDiscovered: 1669, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 16, symbol: "S", name: "Sulfur", atomicMass: 32.06, category: .nonmetal, group: 16, period: 3, electronConfiguration: "[Ne] 3s² 3p⁴", oxidationStates: [6, 4, -2], physicalState: .solid, mysticalMeaning: "The brimstone of transformation - fire, alchemical change, and the soul's crucible.", numerologySignificance: "Number 7: Spiritual fire and the burning away of illusion.", alchemicalProperty: .sulfur, crystalStructure: "Orthorhombic", discoveredBy: "Ancient", yearDiscovered: -2000, magicalAffinity: [.transformation, .purification]),
        
        Element(atomicNumber: 17, symbol: "Cl", name: "Chlorine", atomicMass: 35.45, category: .halogen, group: 17, period: 3, electronConfiguration: "[Ne] 3s² 3p⁵", oxidationStates: [7, 5, 3, 1, -1], physicalState: .gas, mysticalMeaning: "The purifier - cleansing, protection, and the green flame of truth.", numerologySignificance: "Number 8: Power to cleanse and transform.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Carl Wilhelm Scheele", yearDiscovered: 1774, magicalAffinity: [.purification, .protection]),
        
        Element(atomicNumber: 18, symbol: "Ar", name: "Argon", atomicMass: 39.948, category: .nobleGas, group: 18, period: 3, electronConfiguration: "[Ne] 3s² 3p⁶", oxidationStates: [0], physicalState: .gas, mysticalMeaning: "The inactive guardian - protection through stillness and presence.", numerologySignificance: "Number 9: Completion and the wisdom of non-action.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Lord Rayleigh", yearDiscovered: 1894, magicalAffinity: [.protection, .clarity]),
        
        // Period 4
        Element(atomicNumber: 19, symbol: "K", name: "Potassium", atomicMass: 39.098, category: .alkaliMetal, group: 1, period: 4, electronConfiguration: "[Ar] 4s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The flame dancer - life force, vitality, and explosive energy.", numerologySignificance: "Number 1: New beginnings of growth and vitality.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Humphry Davy", yearDiscovered: 1807, magicalAffinity: [.passion, .strength]),
        
        Element(atomicNumber: 20, symbol: "Ca", name: "Calcium", atomicMass: 40.078, category: .alkalineEarthMetal, group: 2, period: 4, electronConfiguration: "[Ar] 4s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The bone builder - structure, foundation, and earthly strength.", numerologySignificance: "Number 2: Balance and structural harmony.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Humphry Davy", yearDiscovered: 1808, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 21, symbol: "Sc", name: "Scandium", atomicMass: 44.956, category: .transitionMetal, group: 3, period: 4, electronConfiguration: "[Ar] 3d¹ 4s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The hidden light - rare wisdom and unexpected strength.", numerologySignificance: "Number 3: Creative discovery and hidden talents.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Lars Fredrik Nilson", yearDiscovered: 1879, magicalAffinity: [.wisdom, .strength]),
        
        Element(atomicNumber: 22, symbol: "Ti", name: "Titanium", atomicMass: 47.867, category: .transitionMetal, group: 4, period: 4, electronConfiguration: "[Ar] 3d² 4s²", oxidationStates: [4, 3, 2], physicalState: .solid, mysticalMeaning: "The titan's strength - invincibility, endurance, and cosmic power.", numerologySignificance: "Master Number 22: The master builder of unbreakable foundations.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "William Gregor", yearDiscovered: 1791, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 23, symbol: "V", name: "Vanadium", atomicMass: 50.942, category: .transitionMetal, group: 5, period: 4, electronConfiguration: "[Ar] 3d³ 4s²", oxidationStates: [5, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The rainbow metal - versatility, beauty in change, and adaptability.", numerologySignificance: "Number 5: Freedom of expression and colorful transformation.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Andrés Manuel del Río", yearDiscovered: 1801, magicalAffinity: [.transformation, .abundance]),
        
        Element(atomicNumber: 24, symbol: "Cr", name: "Chromium", atomicMass: 51.996, category: .transitionMetal, group: 6, period: 4, electronConfiguration: "[Ar] 3d⁵ 4s¹", oxidationStates: [6, 3, 2], physicalState: .solid, mysticalMeaning: "The mirror of the soul - reflection, brilliance, and crystalline clarity.", numerologySignificance: "Number 6: Perfect reflection and harmonious shine.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Louis Nicolas Vauquelin", yearDiscovered: 1794, magicalAffinity: [.clarity, .protection]),
        
        Element(atomicNumber: 25, symbol: "Mn", name: "Manganese", atomicMass: 54.938, category: .transitionMetal, group: 7, period: 4, electronConfiguration: "[Ar] 3d⁵ 4s²", oxidationStates: [7, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The violet flame - spiritual power and the energy of transformation.", numerologySignificance: "Number 7: Mystical power and spiritual awakening.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Torbern Olof Bergman", yearDiscovered: 1774, magicalAffinity: [.transformation, .wisdom]),
        
        Element(atomicNumber: 26, symbol: "Fe", name: "Iron", atomicMass: 55.845, category: .transitionMetal, group: 8, period: 4, electronConfiguration: "[Ar] 3d⁶ 4s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The warrior's heart - Mars energy, strength, and the blood of the earth.", numerologySignificance: "Number 8: Power, strength, and the iron will.", alchemicalProperty: .iron, crystalStructure: "Body-Centered Cubic", discoveredBy: "Ancient", yearDiscovered: -5000, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 27, symbol: "Co", name: "Cobalt", atomicMass: 58.933, category: .transitionMetal, group: 9, period: 4, electronConfiguration: "[Ar] 3d⁷ 4s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The blue devil - depth, mystery, and the power of the unseen.", numerologySignificance: "Number 9: Completion of the transition series, cosmic depth.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Georg Brandt", yearDiscovered: 1735, magicalAffinity: [.intuition, .wisdom]),
        
        Element(atomicNumber: 28, symbol: "Ni", name: "Nickel", atomicMass: 58.693, category: .transitionMetal, group: 10, period: 4, electronConfiguration: "[Ar] 3d⁸ 4s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The old devil - resilience, endurance, and the trickster's gift.", numerologySignificance: "Number 1: New cycles of endurance and transformation.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Axel Fredrik Cronstedt", yearDiscovered: 1751, magicalAffinity: [.protection, .strength]),
        
        Element(atomicNumber: 29, symbol: "Cu", name: "Copper", atomicMass: 63.546, category: .transitionMetal, group: 11, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s¹", oxidationStates: [2, 1], physicalState: .solid, mysticalMeaning: "The goddess metal - Venus energy, love, beauty, and conducting energy.", numerologySignificance: "Number 2: Divine feminine balance and harmonious flow.", alchemicalProperty: .copper, crystalStructure: "Face-Centered Cubic", discoveredBy: "Ancient", yearDiscovered: -9000, magicalAffinity: [.healing, .abundance]),
        
        Element(atomicNumber: 30, symbol: "Zn", name: "Zinc", atomicMass: 65.38, category: .transitionMetal, group: 12, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The immune shield - protection, healing, and life sustenance.", numerologySignificance: "Number 3: Creative healing and protective energy.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Indian metallurgists", yearDiscovered: -1000, magicalAffinity: [.healing, .protection]),
        
        Element(atomicNumber: 31, symbol: "Ga", name: "Gallium", atomicMass: 69.723, category: .postTransitionMetal, group: 13, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p¹", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The liquid paradox - transformation, adaptability, and unexpected states.", numerologySignificance: "Number 4: Stable transformation and adaptive foundation.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Lecoq de Boisbaudran", yearDiscovered: 1875, magicalAffinity: [.transformation, .clarity]),
        
        Element(atomicNumber: 32, symbol: "Ge", name: "Germanium", atomicMass: 72.63, category: .metalloid, group: 14, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p²", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The crystal bridge - connecting the material and the digital, the seen and unseen.", numerologySignificance: "Number 5: Bridging worlds and technological magic.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Clemens Winkler", yearDiscovered: 1886, magicalAffinity: [.clarity, .wisdom]),
        
        Element(atomicNumber: 33, symbol: "As", name: "Arsenic", atomicMass: 74.922, category: .metalloid, group: 15, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p³", oxidationStates: [5, 3, -3], physicalState: .solid, mysticalMeaning: "The poison and cure - the double-edged sword of power and danger.", numerologySignificance: "Number 6: The paradox of harm and healing.", alchemicalProperty: .arsenic, crystalStructure: "Rhombohedral", discoveredBy: "Albertus Magnus", yearDiscovered: 1250, magicalAffinity: [.transformation, .protection]),
        
        Element(atomicNumber: 34, symbol: "Se", name: "Selenium", atomicMass: 78.96, category: .nonmetal, group: 16, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p⁴", oxidationStates: [6, 4, -2], physicalState: .solid, mysticalMeaning: "The moon's shadow - intuition, sensitivity, and the wisdom of darkness.", numerologySignificance: "Number 7: Lunar wisdom and shadow work.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Jöns Jacob Berzelius", yearDiscovered: 1817, magicalAffinity: [.intuition, .wisdom]),
        
        Element(atomicNumber: 35, symbol: "Br", name: "Bromine", atomicMass: 79.904, category: .halogen, group: 17, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p⁵", oxidationStates: [7, 5, 3, 1, -1], physicalState: .liquid, mysticalMeaning: "The liquid fire - passion, volatility, and the burning waters.", numerologySignificance: "Number 8: Passionate power and flowing energy.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Antoine Jérôme Balard", yearDiscovered: 1826, magicalAffinity: [.passion, .transformation]),
        
        Element(atomicNumber: 36, symbol: "Kr", name: "Krypton", atomicMass: 83.798, category: .nobleGas, group: 18, period: 4, electronConfiguration: "[Ar] 3d¹⁰ 4s² 4p⁶", oxidationStates: [2], physicalState: .gas, mysticalMeaning: "The hidden power - secret strength and the noble protector.", numerologySignificance: "Number 9: Hidden completion and secret wisdom.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "William Ramsay", yearDiscovered: 1898, magicalAffinity: [.protection, .clarity]),
        
        // Period 5
        Element(atomicNumber: 37, symbol: "Rb", name: "Rubidium", atomicMass: 85.468, category: .alkaliMetal, group: 1, period: 5, electronConfiguration: "[Kr] 5s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The red flame - passion, rapid transformation, and fiery intuition.", numerologySignificance: "Number 1: New passionate beginnings.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Robert Bunsen", yearDiscovered: 1861, magicalAffinity: [.passion, .intuition]),
        
        Element(atomicNumber: 38, symbol: "Sr", name: "Strontium", atomicMass: 87.62, category: .alkalineEarthMetal, group: 2, period: 5, electronConfiguration: "[Kr] 5s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The crimson light - celebration, fire magic, and joyous energy.", numerologySignificance: "Number 2: Harmonious celebration and balanced joy.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "William Cruickshank", yearDiscovered: 1787, magicalAffinity: [.abundance, .joy]),
        
        Element(atomicNumber: 39, symbol: "Y", name: "Yttrium", atomicMass: 88.906, category: .transitionMetal, group: 3, period: 5, electronConfiguration: "[Kr] 4d¹ 5s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The lunar earth - connection between earth and sky, foundation for the future.", numerologySignificance: "Number 3: Creative connection between realms.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Johan Gadolin", yearDiscovered: 1794, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 40, symbol: "Zr", name: "Zirconium", atomicMass: 91.224, category: .transitionMetal, group: 4, period: 5, electronConfiguration: "[Kr] 4d² 5s²", oxidationStates: [4], physicalState: .solid, mysticalMeaning: "The diamond twin - clarity, brilliance, and the brilliance of truth.", numerologySignificance: "Number 4: Crystal clarity and truthful foundation.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Martin Heinrich Klaproth", yearDiscovered: 1789, magicalAffinity: [.clarity, .protection]),
        
        Element(atomicNumber: 41, symbol: "Nb", name: "Niobium", atomicMass: 92.906, category: .transitionMetal, group: 5, period: 5, electronConfiguration: "[Kr] 4d⁴ 5s¹", oxidationStates: [5, 3], physicalState: .solid, mysticalMeaning: "The rainbow bridge - multiple colors, versatility, and spectral beauty.", numerologySignificance: "Number 5: Multifaceted expression and spectral magic.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Charles Hatchett", yearDiscovered: 1801, magicalAffinity: [.transformation, .abundance]),
        
        Element(atomicNumber: 42, symbol: "Mo", name: "Molybdenum", atomicMass: 95.95, category: .transitionMetal, group: 6, period: 5, electronConfiguration: "[Kr] 4d⁵ 5s¹", oxidationStates: [6, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The lead's shadow - endurance, ancient wisdom, and hidden strength.", numerologySignificance: "Number 6: Enduring harmony and ancient power.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Carl Wilhelm Scheele", yearDiscovered: 1778, magicalAffinity: [.strength, .wisdom]),
        
        Element(atomicNumber: 43, symbol: "Tc", name: "Technetium", atomicMass: 98, category: .transitionMetal, group: 7, period: 5, electronConfiguration: "[Kr] 4d⁵ 5s²", oxidationStates: [7, 6, 4], physicalState: .solid, mysticalMeaning: "The artificial star - human creation, the first synthetic, and the bridge to the future.", numerologySignificance: "Number 7: Mystical creation and synthetic magic.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carlo Perrier", yearDiscovered: 1937, magicalAffinity: [.transformation, .wisdom]),
        
        Element(atomicNumber: 44, symbol: "Ru", name: "Ruthenium", atomicMass: 101.07, category: .transitionMetal, group: 8, period: 5, electronConfiguration: "[Kr] 4d⁷ 5s¹", oxidationStates: [8, 6, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The Russian treasure - rare beauty, hardness, and noble strength.", numerologySignificance: "Number 8: Powerful rarity and noble power.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Karl Ernst Claus", yearDiscovered: 1844, magicalAffinity: [.strength, .abundance]),
        
        Element(atomicNumber: 45, symbol: "Rh", name: "Rhodium", atomicMass: 102.91, category: .transitionMetal, group: 9, period: 5, electronConfiguration: "[Kr] 4d⁸ 5s¹", oxidationStates: [4, 3, 2], physicalState: .solid, mysticalMeaning: "The rose mirror - reflective beauty, catalytic transformation, and precious rarity.", numerologySignificance: "Number 9: Reflective completion and catalytic wisdom.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "William Hyde Wollaston", yearDiscovered: 1803, magicalAffinity: [.clarity, .transformation]),
        
        Element(atomicNumber: 46, symbol: "Pd", name: "Palladium", atomicMass: 106.42, category: .transitionMetal, group: 10, period: 5, electronConfiguration: "[Kr] 4d¹⁰", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The asteroid guardian - protection, hydrogen absorption, and celestial connection.", numerologySignificance: "Number 1: New protective cycles.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "William Hyde Wollaston", yearDiscovered: 1802, magicalAffinity: [.protection, .healing]),
        
        Element(atomicNumber: 47, symbol: "Ag", name: "Silver", atomicMass: 107.87, category: .transitionMetal, group: 11, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The moon's mirror - intuition, emotional balance, and the lunar sacred.", numerologySignificance: "Number 2: Divine feminine balance and lunar harmony.", alchemicalProperty: .silver, crystalStructure: "Face-Centered Cubic", discoveredBy: "Ancient", yearDiscovered: -4000, magicalAffinity: [.intuition, .protection, .healing]),
        
        Element(atomicNumber: 48, symbol: "Cd", name: "Cadmium", atomicMass: 112.41, category: .transitionMetal, group: 12, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The yellow danger - toxic beauty, the poison within, and cautionary wisdom.", numerologySignificance: "Number 3: Creative caution and dangerous beauty.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Friedrich Stromeyer", yearDiscovered: 1817, magicalAffinity: [.protection, .wisdom]),
        
        Element(atomicNumber: 49, symbol: "In", name: "Indium", atomicMass: 114.82, category: .postTransitionMetal, group: 13, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p¹", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The indigo line - spectral vision, seeing beyond, and the third eye.", numerologySignificance: "Number 4: Visionary foundation and seeing truth.", alchemicalProperty: .none, crystalStructure: "Tetragonal", discoveredBy: "Ferdinand Reich", yearDiscovered: 1863, magicalAffinity: [.clarity, .intuition]),
        
        Element(atomicNumber: 50, symbol: "Sn", name: "Tin", atomicMass: 118.71, category: .postTransitionMetal, group: 14, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p²", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The ancient mirror - Jupiter's metal, expansion, and ancient wisdom.", numerologySignificance: "Number 5: Expansive wisdom and ancient growth.", alchemicalProperty: .tin, crystalStructure: "Tetragonal", discoveredBy: "Ancient", yearDiscovered: -3500, magicalAffinity: [.wisdom, .abundance]),
        
        Element(atomicNumber: 51, symbol: "Sb", name: "Antimony", atomicMass: 121.76, category: .metalloid, group: 15, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p³", oxidationStates: [5, 3, -3], physicalState: .solid, mysticalMeaning: "The wolf metal - wildness, the gray wolf of transformation.", numerologySignificance: "Number 6: Transformative harmony and wild wisdom.", alchemicalProperty: .antimony, crystalStructure: "Rhombohedral", discoveredBy: "Ancient", yearDiscovered: -3000, magicalAffinity: [.transformation, .protection]),
        
        Element(atomicNumber: 52, symbol: "Te", name: "Tellurium", atomicMass: 127.60, category: .metalloid, group: 16, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p⁴", oxidationStates: [6, 4, -2], physicalState: .solid, mysticalMeaning: "The earth teller - communication, crystal wisdom, and elemental speech.", numerologySignificance: "Number 7: Mystical communication and elemental wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Franz-Joseph Müller von Reichenstein", yearDiscovered: 1782, magicalAffinity: [.clarity, .wisdom]),
        
        Element(atomicNumber: 53, symbol: "I", name: "Iodine", atomicMass: 126.90, category: .halogen, group: 17, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p⁵", oxidationStates: [7, 5, 1, -1], physicalState: .solid, mysticalMeaning: "The violet vapor - thyroid wisdom, the purple haze of intuition.", numerologySignificance: "Number 8: Powerful intuition and violet vision.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Bernard Courtois", yearDiscovered: 1811, magicalAffinity: [.intuition, .healing]),
        
        Element(atomicNumber: 54, symbol: "Xe", name: "Xenon", atomicMass: 131.29, category: .nobleGas, group: 18, period: 5, electronConfiguration: "[Kr] 4d¹⁰ 5s² 5p⁶", oxidationStates: [6, 4, 2], physicalState: .gas, mysticalMeaning: "The stranger - foreign, rare, and the unknown guest.", numerologySignificance: "Number 9: Completion of the unknown and rare wisdom.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "William Ramsay", yearDiscovered: 1898, magicalAffinity: [.wisdom, .clarity]),
        
        // Period 6
        Element(atomicNumber: 55, symbol: "Cs", name: "Cesium", atomicMass: 132.91, category: .alkaliMetal, group: 1, period: 6, electronConfiguration: "[Xe] 6s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The sky blue - timekeeper, atomic precision, and celestial rhythm.", numerologySignificance: "Master Number 11: Illuminated precision and temporal mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Robert Bunsen", yearDiscovered: 1860, magicalAffinity: [.clarity, .wisdom]),
        
        Element(atomicNumber: 56, symbol: "Ba", name: "Barium", atomicMass: 137.33, category: .alkalineEarthMetal, group: 2, period: 6, electronConfiguration: "[Xe] 6s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The heavy spar - weight, the green fire, and the heavy burden.", numerologySignificance: "Number 4: Heavy foundation and weighted wisdom.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Carl Wilhelm Scheele", yearDiscovered: 1772, magicalAffinity: [.strength, .protection]),
        
        // Lanthanides 57-71
        Element(atomicNumber: 57, symbol: "La", name: "Lanthanum", atomicMass: 138.91, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 5d¹ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The hidden one - beginning of the hidden series, gateway to the rare earths.", numerologySignificance: "Number 3: Creative gateway to hidden realms.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carl Gustav Mosander", yearDiscovered: 1839, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 58, symbol: "Ce", name: "Cerium", atomicMass: 140.12, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹ 5d¹ 6s²", oxidationStates: [4, 3], physicalState: .solid, mysticalMeaning: "The asteroid's gift - abundance, the largest lanthanide, and cosmic abundance.", numerologySignificance: "Number 4: Abundant foundation and cosmic gift.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Martin Heinrich Klaproth", yearDiscovered: 1803, magicalAffinity: [.abundance, .strength]),
        
        Element(atomicNumber: 59, symbol: "Pr", name: "Praseodymium", atomicMass: 140.91, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f³ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The green twin - verdant energy, growth, and spring magic.", numerologySignificance: "Number 5: Green growth and verdant transformation.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carl Auer von Welsbach", yearDiscovered: 1885, magicalAffinity: [.healing, .abundance]),
        
        Element(atomicNumber: 60, symbol: "Nd", name: "Neodymium", atomicMass: 144.24, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁴ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The new twin - magnetic power, attraction, and rare earth magnetism.", numerologySignificance: "Number 6: Harmonious magnetism and attractive power.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carl Auer von Welsbach", yearDiscovered: 1885, magicalAffinity: [.abundance, .strength]),
        
        Element(atomicNumber: 61, symbol: "Pm", name: "Promethium", atomicMass: 145, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁵ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The fire bringer - radioactive light, Prometheus's gift, and forbidden fire.", numerologySignificance: "Number 7: Mystical fire and forbidden wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Charles D. Coryell", yearDiscovered: 1945, magicalAffinity: [.wisdom, .passion]),
        
        Element(atomicNumber: 62, symbol: "Sm", name: "Samarium", atomicMass: 150.36, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁶ 6s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The Russian mystery - named after Samarskite, rare and powerful.", numerologySignificance: "Number 8: Powerful mystery and Russian magic.", alchemicalProperty: .none, crystalStructure: "Rhombohedral", discoveredBy: "Paul-Émile Lecoq de Boisbaudran", yearDiscovered: 1879, magicalAffinity: [.strength, .wisdom]),
        
        Element(atomicNumber: 63, symbol: "Eu", name: "Europium", atomicMass: 151.96, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁷ 6s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The red beacon - the most reactive lanthanide, European unity, and rare light.", numerologySignificance: "Number 9: Completed unity and European wisdom.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Eugène-Anatole Demarçay", yearDiscovered: 1896, magicalAffinity: [.clarity, .protection]),
        
        Element(atomicNumber: 64, symbol: "Gd", name: "Gadolinium", atomicMass: 157.25, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁷ 5d¹ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The MRI master - magnetic resonance, medical magic, and healing vision.", numerologySignificance: "Master Number 11: Illuminated healing and medical mysticism.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Jean Charles Galissard de Marignac", yearDiscovered: 1880, magicalAffinity: [.healing, .clarity]),
        
        Element(atomicNumber: 65, symbol: "Tb", name: "Terbium", atomicMass: 158.93, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f⁹ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The village's secret - named after Ytterby, Swedish mystery.", numerologySignificance: "Master Number 11: Secret wisdom and village magic.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carl Gustaf Mosander", yearDiscovered: 1843, magicalAffinity: [.wisdom, .protection]),
        
        Element(atomicNumber: 66, symbol: "Dy", name: "Dysprosium", atomicMass: 162.50, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹⁰ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The hard to get - difficulty in isolation, hard-won wisdom.", numerologySignificance: "Master Number 22: Hard-won mastery and difficult achievement.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Paul-Émile Lecoq de Boisbaudran", yearDiscovered: 1886, magicalAffinity: [.strength, .wisdom]),
        
        Element(atomicNumber: 67, symbol: "Ho", name: "Holmium", atomicMass: 164.93, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹¹ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The Stockholm honor - named after Stockholm, Swedish pride.", numerologySignificance: "Master Number 22: Honored mastery and Stockholm magic.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Per Teodor Cleve", yearDiscovered: 1878, magicalAffinity: [.protection, .clarity]),
        
        Element(atomicNumber: 68, symbol: "Er", name: "Erbium", atomicMass: 167.26, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹² 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The pink rare - rose-tinted glasses, pink energy, and gentle strength.", numerologySignificance: "Master Number 22: Gentle mastery and pink wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Carl Gustaf Mosander", yearDiscovered: 1843, magicalAffinity: [.healing, .clarity]),
        
        Element(atomicNumber: 69, symbol: "Tm", name: "Thulium", atomicMass: 168.93, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹³ 6s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The northern myth - named after Thule, northern magic, and arctic mystery.", numerologySignificance: "Master Number 33: Ultimate northern wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Per Teodor Cleve", yearDiscovered: 1879, magicalAffinity: [.wisdom, .intuition]),
        
        Element(atomicNumber: 70, symbol: "Yb", name: "Ytterbium", atomicMass: 173.05, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 6s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The village end - the final Ytterby element, closing the circle.", numerologySignificance: "Master Number 22: Completed circle and village magic.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Jean Charles Galissard de Marignac", yearDiscovered: 1878, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 71, symbol: "Lu", name: "Lutetium", atomicMass: 174.97, category: .lanthanide, group: 3, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹ 6s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The Paris end - named after Paris, closing the lanthanide series.", numerologySignificance: "Master Number 22: Parisian completion and urban wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Georges Urbain", yearDiscovered: 1907, magicalAffinity: [.wisdom, .clarity]),
        
        // Continue Period 6
        Element(atomicNumber: 72, symbol: "Hf", name: "Hafnium", atomicMass: 178.49, category: .transitionMetal, group: 4, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d² 6s²", oxidationStates: [4], physicalState: .solid, mysticalMeaning: "The Copenhagen element - named after Copenhagen, Danish pride.", numerologySignificance: "Master Number 22: Copenhagen mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Dirk Coster", yearDiscovered: 1923, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 73, symbol: "Ta", name: "Tantalum", atomicMass: 180.95, category: .transitionMetal, group: 5, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d³ 6s²", oxidationStates: [5], physicalState: .solid, mysticalMeaning: "The tantalizer - named after Tantalus, eternal temptation, and corrosion resistance.", numerologySignificance: "Master Number 22: Tantalizing mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Anders Gustaf Ekeberg", yearDiscovered: 1802, magicalAffinity: [.protection, .wisdom]),
        
        Element(atomicNumber: 74, symbol: "W", name: "Tungsten", atomicMass: 183.84, category: .transitionMetal, group: 6, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d⁴ 6s²", oxidationStates: [6, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The heavy stone - wolf foam, highest melting point, and indestructible.", numerologySignificance: "Master Number 22: Indestructible mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Juan José Elhuyar", yearDiscovered: 1783, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 75, symbol: "Re", name: "Rhenium", atomicMass: 186.21, category: .transitionMetal, group: 7, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d⁵ 6s²", oxidationStates: [7, 6, 4], physicalState: .solid, mysticalMeaning: "The Rhine's gift - named after Rhine, rare and precious.", numerologySignificance: "Master Number 33: Rhine wisdom.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Ida Tacke", yearDiscovered: 1925, magicalAffinity: [.abundance, .wisdom]),
        
        Element(atomicNumber: 76, symbol: "Os", name: "Osmium", atomicMass: 190.23, category: .transitionMetal, group: 8, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d⁶ 6s²", oxidationStates: [8, 4, 3], physicalState: .solid, mysticalMeaning: "The smell - odor of danger, densest element, and heavy presence.", numerologySignificance: "Master Number 22: Dense mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Smithson Tennant", yearDiscovered: 1803, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 77, symbol: "Ir", name: "Iridium", atomicMass: 192.22, category: .transitionMetal, group: 9, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d⁷ 6s²", oxidationStates: [4, 3], physicalState: .solid, mysticalMeaning: "The rainbow - iridescent colors, rainbow bridge, and spectral beauty.", numerologySignificance: "Master Number 22: Rainbow mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Smithson Tennant", yearDiscovered: 1803, magicalAffinity: [.transformation, .clarity]),
        
        Element(atomicNumber: 78, symbol: "Pt", name: "Platinum", atomicMass: 195.08, category: .transitionMetal, group: 10, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d⁹ 6s¹", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The little silver - precious beyond gold, catalyst of transformation.", numerologySignificance: "Master Number 33: Ultimate preciousness.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Antonio de Ulloa", yearDiscovered: 1735, magicalAffinity: [.transformation, .abundance]),
        
        Element(atomicNumber: 79, symbol: "Au", name: "Gold", atomicMass: 196.97, category: .transitionMetal, group: 11, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s¹", oxidationStates: [3, 1], physicalState: .solid, mysticalMeaning: "The sun metal - perfection, enlightenment, the philosopher's stone. The ultimate symbol of purity, wealth, and spiritual attainment.", numerologySignificance: "Master Number 22: The master builder of perfection. Gold represents the pinnacle of material and spiritual achievement.", alchemicalProperty: .gold, crystalStructure: "Face-Centered Cubic", discoveredBy: "Ancient", yearDiscovered: -6000, magicalAffinity: [.abundance, .wisdom, .protection, .transformation]),
        
        Element(atomicNumber: 80, symbol: "Hg", name: "Mercury", atomicMass: 200.59, category: .transitionMetal, group: 12, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s²", oxidationStates: [2, 1], physicalState: .liquid, mysticalMeaning: "The quicksilver - transformation, fluidity, messenger of the gods. The prima materia of alchemy.", numerologySignificance: "Number 8: The infinite flow. Mercury represents the connection between worlds, the mediator between base and noble.", alchemicalProperty: .mercury, crystalStructure: "Rhombohedral", discoveredBy: "Ancient", yearDiscovered: -1500, magicalAffinity: [.transformation, .intuition, .wisdom, .clarity]),
        
        Element(atomicNumber: 81, symbol: "Tl", name: "Thallium", atomicMass: 204.38, category: .postTransitionMetal, group: 13, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p¹", oxidationStates: [3, 1], physicalState: .solid, mysticalMeaning: "The green shoot - deadly beauty, the poison that shines.", numerologySignificance: "Number 3: Deadly creativity.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "William Crookes", yearDiscovered: 1861, magicalAffinity: [.protection, .wisdom]),
        
        Element(atomicNumber: 82, symbol: "Pb", name: "Lead", atomicMass: 207.2, category: .postTransitionMetal, group: 14, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p²", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The heavy father - Saturn's metal, weight of the world, the prima materia to be transformed.", numerologySignificance: "Number 1: New beginnings from heavy foundations.", alchemicalProperty: .lead, crystalStructure: "Face-Centered Cubic", discoveredBy: "Ancient", yearDiscovered: -7000, magicalAffinity: [.protection, .transformation, .strength]),
        
        Element(atomicNumber: 83, symbol: "Bi", name: "Bismuth", atomicMass: 208.98, category: .postTransitionMetal, group: 15, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p³", oxidationStates: [5, 3], physicalState: .solid, mysticalMeaning: "The rainbow square - geometric beauty, rainbow crystals, and stable transformation.", numerologySignificance: "Master Number 11: Geometric illumination.", alchemicalProperty: .bismuth, crystalStructure: "Rhombohedral", discoveredBy: "Claude François Geoffroy", yearDiscovered: 1753, magicalAffinity: [.transformation, .clarity, .protection]),
        
        Element(atomicNumber: 84, symbol: "Po", name: "Polonium", atomicMass: 209, category: .postTransitionMetal, group: 16, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁴", oxidationStates: [4, 2], physicalState: .solid, mysticalMeaning: "The Polish star - Marie Curie's gift, radioactive honor, and deadly brilliance.", numerologySignificance: "Number 4: Radioactive foundation.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "Marie Curie", yearDiscovered: 1898, magicalAffinity: [.passion, .wisdom]),
        
        Element(atomicNumber: 85, symbol: "At", name: "Astatine", atomicMass: 210, category: .metalloid, group: 17, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁵", oxidationStates: [5, 3, 1, -1], physicalState: .solid, mysticalMeaning: "The unstable - rarity itself, the rarest naturally occurring element.", numerologySignificance: "Number 6: Unstable harmony.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Dale R. Corson", yearDiscovered: 1940, magicalAffinity: [.intuition, .transformation]),
        
        Element(atomicNumber: 86, symbol: "Rn", name: "Radon", atomicMass: 222, category: .nobleGas, group: 18, period: 6, electronConfiguration: "[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁶", oxidationStates: [2], physicalState: .gas, mysticalMeaning: "The glowing - radioactive gas, the breath of danger, hidden threat.", numerologySignificance: "Number 6: Glowing harmony.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Friedrich Ernst Dorn", yearDiscovered: 1900, magicalAffinity: [.protection, .wisdom]),
        
        // Period 7
        Element(atomicNumber: 87, symbol: "Fr", name: "Francium", atomicMass: 223, category: .alkaliMetal, group: 1, period: 7, electronConfiguration: "[Rn] 7s¹", oxidationStates: [1], physicalState: .solid, mysticalMeaning: "The French rarity - most unstable naturally occurring element, fleeting existence.", numerologySignificance: "Master Number 22: Fleeting mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Marguerite Perey", yearDiscovered: 1939, magicalAffinity: [.transformation, .intuition]),
        
        Element(atomicNumber: 88, symbol: "Ra", name: "Radium", atomicMass: 226, category: .alkalineEarthMetal, group: 2, period: 7, electronConfiguration: "[Rn] 7s²", oxidationStates: [2], physicalState: .solid, mysticalMeaning: "The ray - glowing with life force, the light that kills, beauty and danger.", numerologySignificance: "Master Number 22: Luminous mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Marie Curie", yearDiscovered: 1898, magicalAffinity: [.healing, .passion]),
        
        // Actinides 89-103
        Element(atomicNumber: 89, symbol: "Ac", name: "Actinium", atomicMass: 227, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 6d¹ 7s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The ray starter - beginning of the actinide series, radioactive dawn.", numerologySignificance: "Master Number 22: Radioactive dawn.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Friedrich Oskar Giesel", yearDiscovered: 1902, magicalAffinity: [.transformation, .wisdom]),
        
        Element(atomicNumber: 90, symbol: "Th", name: "Thorium", atomicMass: 232.04, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 6d² 7s²", oxidationStates: [4], physicalState: .solid, mysticalMeaning: "The thunder - named after Thor, nuclear power, and ancient energy.", numerologySignificance: "Master Number 33: Thunder mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Jöns Jacob Berzelius", yearDiscovered: 1828, magicalAffinity: [.strength, .protection]),
        
        Element(atomicNumber: 91, symbol: "Pa", name: "Protactinium", atomicMass: 231.04, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f² 6d¹ 7s²", oxidationStates: [5], physicalState: .solid, mysticalMeaning: "The first ray - parent of actinium, radioactive ancestor.", numerologySignificance: "Number 4: Ancestral foundation.", alchemicalProperty: .none, crystalStructure: "Tetragonal", discoveredBy: "Kasimir Fajans", yearDiscovered: 1913, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 92, symbol: "U", name: "Uranium", atomicMass: 238.03, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f³ 6d¹ 7s²", oxidationStates: [6, 4, 3], physicalState: .solid, mysticalMeaning: "The cosmic - named after Uranus, atomic power, the destroyer and creator.", numerologySignificance: "Number 2: Cosmic balance.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Martin Heinrich Klaproth", yearDiscovered: 1789, magicalAffinity: [.transformation, .strength, .wisdom]),
        
        Element(atomicNumber: 93, symbol: "Np", name: "Neptunium", atomicMass: 237, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f⁴ 6d¹ 7s²", oxidationStates: [7, 6, 5, 4, 3], physicalState: .solid, mysticalMeaning: "The sea god - first transuranic element, beyond nature, human creation.", numerologySignificance: "Master Number 33: Created mastery.", alchemicalProperty: .none, crystalStructure: "Orthorhombic", discoveredBy: "Edwin McMillan", yearDiscovered: 1940, magicalAffinity: [.transformation, .wisdom]),
        
        Element(atomicNumber: 94, symbol: "Pu", name: "Plutonium", atomicMass: 244, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f⁶ 7s²", oxidationStates: [7, 6, 5, 4, 3], physicalState: .solid, mysticalMeaning: "The underworld - named after Pluto, death and power, the destroyer of worlds.", numerologySignificance: "Master Number 22: Underworld mastery.", alchemicalProperty: .none, crystalStructure: "Monoclinic", discoveredBy: "Glenn T. Seaborg", yearDiscovered: 1940, magicalAffinity: [.transformation, .strength]),
        
        Element(atomicNumber: 95, symbol: "Am", name: "Americium", atomicMass: 243, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f⁷ 7s²", oxidationStates: [6, 5, 4, 3], physicalState: .solid, mysticalMeaning: "The American - named after the Americas, smoke detector magic, everyday alchemy.", numerologySignificance: "Master Number 33: American mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Glenn T. Seaborg", yearDiscovered: 1944, magicalAffinity: [.protection, .clarity]),
        
        Element(atomicNumber: 96, symbol: "Cm", name: "Curium", atomicMass: 247, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f⁷ 6d¹ 7s²", oxidationStates: [4, 3], physicalState: .solid, mysticalMeaning: "The Curie legacy - named after Marie and Pierre Curie, scientific honor.", numerologySignificance: "Master Number 33: Scientific mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Glenn T. Seaborg", yearDiscovered: 1944, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 97, symbol: "Bk", name: "Berkelium", atomicMass: 247, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f⁹ 7s²", oxidationStates: [4, 3], physicalState: .solid, mysticalMeaning: "The Berkeley - named after Berkeley, California, university magic.", numerologySignificance: "Master Number 22: Academic mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Glenn T. Seaborg", yearDiscovered: 1949, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 98, symbol: "Cf", name: "Californium", atomicMass: 251, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹⁰ 7s²", oxidationStates: [4, 3, 2], physicalState: .solid, mysticalMeaning: "The California - named after California, golden state, neutron source.", numerologySignificance: "Master Number 22: Golden mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Glenn T. Seaborg", yearDiscovered: 1950, magicalAffinity: [.abundance, .wisdom]),
        
        Element(atomicNumber: 99, symbol: "Es", name: "Einsteinium", atomicMass: 252, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹¹ 7s²", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The Einstein - named after Albert Einstein, genius element, relativity's child.", numerologySignificance: "Master Number 33: Genius mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Albert Ghiorso", yearDiscovered: 1952, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 100, symbol: "Fm", name: "Fermium", atomicMass: 257, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹² 7s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The Fermi - named after Enrico Fermi, nuclear pioneer, reactor's father.", numerologySignificance: "Master Number 22: Nuclear mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Albert Ghiorso", yearDiscovered: 1952, magicalAffinity: [.transformation, .wisdom]),
        
        Element(atomicNumber: 101, symbol: "Md", name: "Mendelevium", atomicMass: 258, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹³ 7s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The Mendeleev - named after Dmitri Mendeleev, periodic table's father.", numerologySignificance: "Master Number 22: Periodic mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Albert Ghiorso", yearDiscovered: 1955, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 102, symbol: "No", name: "Nobelium", atomicMass: 259, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 7s²", oxidationStates: [3, 2], physicalState: .solid, mysticalMeaning: "The Nobel - named after Alfred Nobel, peace and explosives, prize element.", numerologySignificance: "Master Number 22: Prize mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 1966, magicalAffinity: [.abundance, .wisdom]),
        
        Element(atomicNumber: 103, symbol: "Lr", name: "Lawrencium", atomicMass: 266, category: .actinide, group: 3, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 7s² 7p¹", oxidationStates: [3], physicalState: .solid, mysticalMeaning: "The Lawrence - named after Ernest Lawrence, cyclotron creator, accelerator's father.", numerologySignificance: "Master Number 22: Accelerator mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal", discoveredBy: "Albert Ghiorso", yearDiscovered: 1961, magicalAffinity: [.transformation, .wisdom]),
        
        // Continue Period 7
        Element(atomicNumber: 104, symbol: "Rf", name: "Rutherfordium", atomicMass: 267, category: .transitionMetal, group: 4, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d² 7s²", oxidationStates: [4], physicalState: .solid, mysticalMeaning: "The Rutherford - named after Ernest Rutherford, nuclear physics father.", numerologySignificance: "Master Number 22: Nuclear mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 1964, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 105, symbol: "Db", name: "Dubnium", atomicMass: 268, category: .transitionMetal, group: 5, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d³ 7s²", oxidationStates: [5, 4, 3], physicalState: .solid, mysticalMeaning: "The Dubna - named after Dubna, Russia, joint element, collaboration.", numerologySignificance: "Master Number 22: Collaboration mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 1967, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 106, symbol: "Sg", name: "Seaborgium", atomicMass: 269, category: .transitionMetal, group: 6, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁴ 7s²", oxidationStates: [6, 5, 4, 3, 0], physicalState: .solid, mysticalMeaning: "The Seaborg - named after Glenn T. Seaborg, transuranic creator.", numerologySignificance: "Master Number 22: Transuranic mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Lawrence Berkeley National Laboratory", yearDiscovered: 1974, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 107, symbol: "Bh", name: "Bohrium", atomicMass: 270, category: .transitionMetal, group: 7, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁵ 7s²", oxidationStates: [7, 5, 4, 3], physicalState: .solid, mysticalMeaning: "The Bohr - named after Niels Bohr, quantum father, atomic model.", numerologySignificance: "Master Number 22: Quantum mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1981, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 108, symbol: "Hs", name: "Hassium", atomicMass: 269, category: .transitionMetal, group: 8, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁶ 7s²", oxidationStates: [8, 6, 5, 4, 3, 2], physicalState: .solid, mysticalMeaning: "The Hesse - named after Hesse, Germany, German state, superheavy.", numerologySignificance: "Master Number 22: Superheavy mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1984, magicalAffinity: [.strength, .wisdom]),
        
        Element(atomicNumber: 109, symbol: "Mt", name: "Meitnerium", atomicMass: 278, category: .unknown, group: 9, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁷ 7s²", oxidationStates: [9, 8, 6, 4, 3, 1], physicalState: .solid, mysticalMeaning: "The Meitner - named after Lise Meitner, nuclear fission mother, overlooked genius.", numerologySignificance: "Master Number 22: Overlooked mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1982, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 110, symbol: "Ds", name: "Darmstadtium", atomicMass: 281, category: .unknown, group: 10, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁸ 7s²", oxidationStates: [8, 6, 4, 2, 0], physicalState: .solid, mysticalMeaning: "The Darmstadt - named after Darmstadt, Germany, German city, superheavy.", numerologySignificance: "Master Number 22: City mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1994, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 111, symbol: "Rg", name: "Roentgenium", atomicMass: 282, category: .unknown, group: 11, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d⁹ 7s²", oxidationStates: [5, 3, 1, -1], physicalState: .solid, mysticalMeaning: "The Röntgen - named after Wilhelm Röntgen, X-rays, invisible light.", numerologySignificance: "Master Number 33: Invisible mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1994, magicalAffinity: [.clarity, .wisdom]),
        
        Element(atomicNumber: 112, symbol: "Cn", name: "Copernicium", atomicMass: 285, category: .transitionMetal, group: 12, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s²", oxidationStates: [2, 1, 0], physicalState: .gas, mysticalMeaning: "The Copernicus - named after Nicolaus Copernicus, heliocentric revolution.", numerologySignificance: "Master Number 22: Revolutionary mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "Gesellschaft für Schwerionenforschung", yearDiscovered: 1996, magicalAffinity: [.wisdom, .clarity]),
        
        Element(atomicNumber: 113, symbol: "Nh", name: "Nihonium", atomicMass: 286, category: .unknown, group: 13, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p¹", oxidationStates: [3, 1], physicalState: .solid, mysticalMeaning: "The Japan - named after Japan, Nihon, first Japanese element.", numerologySignificance: "Master Number 22: Japanese mastery.", alchemicalProperty: .none, crystalStructure: "Hexagonal Close-Packed", discoveredBy: "RIKEN", yearDiscovered: 2004, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 114, symbol: "Fl", name: "Flerovium", atomicMass: 289, category: .postTransitionMetal, group: 14, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p²", oxidationStates: [6, 4, 2, 1, 0], physicalState: .solid, mysticalMeaning: "The Flerov - named after Flerov Laboratory, Russian lab, superheavy island.", numerologySignificance: "Master Number 22: Laboratory mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 1998, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 115, symbol: "Mc", name: "Moscovium", atomicMass: 290, category: .unknown, group: 15, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p³", oxidationStates: [3, 1], physicalState: .solid, mysticalMeaning: "The Moscow - named after Moscow, Russian capital, superheavy.", numerologySignificance: "Master Number 22: Capital mastery.", alchemicalProperty: .none, crystalStructure: "Body-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 2003, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 116, symbol: "Lv", name: "Livermorium", atomicMass: 293, category: .unknown, group: 16, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁴", oxidationStates: [4, 2, -2], physicalState: .solid, mysticalMeaning: "The Livermore - named after Lawrence Livermore Laboratory, American lab.", numerologySignificance: "Master Number 22: American mastery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 2000, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 117, symbol: "Ts", name: "Tennessine", atomicMass: 294, category: .unknown, group: 17, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁵", oxidationStates: [5, 3, 1, -1], physicalState: .solid, mysticalMeaning: "The Tennessee - named after Tennessee, American state, Russian collaboration.", numerologySignificance: "Master Number 22: Collaboration mastery.", alchemicalProperty: .none, crystalStructure: "Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 2010, magicalAffinity: [.wisdom, .transformation]),
        
        Element(atomicNumber: 118, symbol: "Og", name: "Oganesson", atomicMass: 294, category: .unknown, group: 18, period: 7, electronConfiguration: "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁶", oxidationStates: [6, 4, 2, 1, 0, -1], physicalState: .solid, mysticalMeaning: "The Oganessian - named after Yuri Oganessian, element hunter, final element.", numerologySignificance: "Master Number 33: Ultimate mastery. The completion of the periodic table, the crown of elemental discovery.", alchemicalProperty: .none, crystalStructure: "Face-Centered Cubic", discoveredBy: "Joint Institute for Nuclear Research", yearDiscovered: 2002, magicalAffinity: [.wisdom, .transformation, .clarity])
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ViewModel

class PeriodicTableViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: ElementCategory?
    @Published var selectedState: PhysicalState?
    @Published var showAlchemicalOnly = false
    @Published var selectedElement: Element?
    
    var filteredElements: [Element] {
        ElementData.allElements.filter { element in
            let matchesSearch = searchText.isEmpty ||
                element.name.localizedCaseInsensitiveContains(searchText) ||
                element.symbol.localizedCaseInsensitiveContains(searchText) ||
                "\(element.atomicNumber)".contains(searchText)
            
            let matchesCategory = selectedCategory == nil || element.category == selectedCategory
            let matchesState = selectedState == nil || element.physicalState == selectedState
            let matchesAlchemical = !showAlchemicalOnly || element.alchemicalProperty != .none
            
            return matchesSearch && matchesCategory && matchesState && matchesAlchemical
        }
    }
    
    var alchemicalElements: [Element] {
        ElementData.allElements.filter { $0.alchemicalProperty != .none }
    }
}

// MARK: - 3D Atom Visualization

struct Atom3DView: UIViewRepresentable {
    let atomicNumber: Int
    let symbol: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createAtomScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createAtomScene()
    }
    
    private func createAtomScene() -> SCNScene {
        let scene = SCNScene()
        
        // Nucleus
        let nucleusGeometry = SCNSphere(radius: 0.5)
        nucleusGeometry.firstMaterial?.diffuse.contents = UIColor(hex: "#E5C158")
        nucleusGeometry.firstMaterial?.emission.contents = UIColor(hex: "#E5C158")
        nucleusGeometry.firstMaterial?.emission.intensity = 0.5
        let nucleusNode = SCNNode(geometry: nucleusGeometry)
        scene.rootNode.addChildNode(nucleusNode)
        
        // Electron shells
        let shells = min(7, (atomicNumber + 1) / 2 + 1)
        
        for shell in 1...shells {
            let radius = CGFloat(shell) * 1.2
            let electronsInShell = min(2 * shell * shell, max(0, atomicNumber - 2 * (shell - 1) * (shell - 1)))
            
            // Orbital ring
            let ringGeometry = SCNTorus(ringRadius: radius, pipeRadius: 0.02)
            ringGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
            let ringNode = SCNNode(geometry: ringGeometry)
            ringNode.eulerAngles.x = Float.random(in: 0...Float.pi)
            ringNode.eulerAngles.y = Float.random(in: 0...Float.pi)
            
            // Animation for ring
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: Double(shell) * 3)
            let repeatAction = SCNAction.repeatForever(rotateAction)
            ringNode.runAction(repeatAction)
            
            scene.rootNode.addChildNode(ringNode)
            
            // Electrons
            for i in 0..<electronsInShell {
                let angle = (2.0 * Double.pi * Double(i)) / Double(electronsInShell)
                let electronGeometry = SCNSphere(radius: 0.15)
                electronGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
                electronGeometry.firstMaterial?.emission.contents = UIColor.cyan
                electronGeometry.firstMaterial?.emission.intensity = 0.8
                
                let electronNode = SCNNode(geometry: electronGeometry)
                electronNode.position = SCNVector3(
                    Float(cos(angle) * Double(radius)),
                    0,
                    Float(sin(angle) * Double(radius))
                )
                
                ringNode.addChildNode(electronNode)
            }
        }
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 15)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// MARK: - Main View

struct PeriodicTableView: View {
    @StateObject private var viewModel = PeriodicTableViewModel()
    @State private var showDetail = false
    @State private var selectedElement: Element?
    @Namespace private var animation
    
    private let goldAccent = Color(hex: "#E5C158")
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(hex: "#1a1a2e"),
                    Color(hex: "#16213e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search & Filters
                searchAndFilterView
                
                // Alchemical Highlight
                if viewModel.showAlchemicalOnly {
                    alchemicalBanner
                }
                
                // Periodic Table Grid
                periodicTableGrid
            }
        }
        .sheet(item: $selectedElement) { element in
            ElementDetailView(element: element)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("PERIODIC TABLE")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(goldAccent)
                .shadow(color: goldAccent.opacity(0.5), radius: 10, x: 0, y: 0)
            
            Text("118 Elements • Numerology • Alchemy")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Search & Filter
    
    private var searchAndFilterView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(goldAccent)
                TextField("Search elements...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Clear search")
                    .accessibilityHint("Double tap to clear the search text")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(goldAccent.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Category Filter
                    Menu {
                        Button("All Categories") { viewModel.selectedCategory = nil }
                        ForEach(ElementCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) { viewModel.selectedCategory = category }
                        }
                    } label: {
                        FilterChip(
                            title: viewModel.selectedCategory?.rawValue ?? "Category",
                            icon: viewModel.selectedCategory?.mysticalSymbol ?? "⚗️",
                            isSelected: viewModel.selectedCategory != nil,
                            color: viewModel.selectedCategory?.color ?? goldAccent
                        )
                    }
                    
                    // State Filter
                    Menu {
                        Button("All States") { viewModel.selectedState = nil }
                        ForEach(PhysicalState.allCases, id: \.self) { state in
                            Button(state.rawValue) { viewModel.selectedState = state }
                        }
                    } label: {
                        FilterChip(
                            title: viewModel.selectedState?.rawValue ?? "State",
                            icon: viewModel.selectedState?.icon ?? "◯",
                            isSelected: viewModel.selectedState != nil,
                            color: .cyan
                        )
                    }
                    
                    // Alchemy Toggle
                    Button(action: { viewModel.showAlchemicalOnly.toggle() }) {
                        FilterChip(
                            title: "Alchemy",
                            icon: "☿",
                            isSelected: viewModel.showAlchemicalOnly,
                            color: goldAccent
                        )
                    }
                    .accessibilityLabel("Alchemy filter")
                    .accessibilityHint(viewModel.showAlchemicalOnly ? "Double tap to show all elements" : "Double tap to show only alchemical elements")
                    
                    // Clear Filters
                    if viewModel.selectedCategory != nil || viewModel.selectedState != nil || viewModel.showAlchemicalOnly {
                        Button(action: {
                            viewModel.selectedCategory = nil
                            viewModel.selectedState = nil
                            viewModel.showAlchemicalOnly = false
                        }) {
                            FilterChip(
                                title: "Clear",
                                icon: "✕",
                                isSelected: false,
                                color: .red
                            )
                        }
                        .accessibilityLabel("Clear all filters")
                        .accessibilityHint("Double tap to clear all active filters")
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Alchemical Banner
    
    private var alchemicalBanner: some View {
        HStack(spacing: 15) {
            ForEach(viewModel.alchemicalElements) { element in
                Button(action: {
                    selectedElement = element
                }) {
                    VStack {
                        Text(element.symbol)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(element.alchemicalProperty.color)
                        Text(element.alchemicalProperty.rawValue.split(separator: " ").first.map(String.init) ?? "")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(element.alchemicalProperty.color.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(element.alchemicalProperty.color, lineWidth: 2)
                            )
                    )
                }
                .accessibilityLabel("\(element.name), \(element.alchemicalProperty.rawValue)")
                .accessibilityHint("Double tap to view details about this alchemical element")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(goldAccent.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Periodic Table Grid
    
    private var periodicTableGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 18), spacing: 2) {
                ForEach(1...118, id: \.self) { atomicNumber in
                    if let element = ElementData.allElements.first(where: { $0.atomicNumber == atomicNumber }) {
                        ElementCell(element: element, isHighlighted: viewModel.filteredElements.contains(where: { $0.atomicNumber == atomicNumber }))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedElement = element
                                }
                            }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(4)
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .foregroundColor(isSelected ? color : .white)
        .accessibilityLabel("\(title) filter")
        .accessibilityHint(isSelected ? "Double tap to deselect \(title)" : "Double tap to select \(title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Element Cell

struct ElementCell: View {
    let element: Element
    let isHighlighted: Bool
    
    private let goldAccent = Color(hex: "#E5C158")
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 4)
                .fill(element.category.color.opacity(isHighlighted ? 0.9 : 0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            element.alchemicalProperty != .none ? goldAccent : element.category.color,
                            lineWidth: element.alchemicalProperty != .none ? 2 : 0.5
                        )
                )
            
            // Alchemical glow
            if element.alchemicalProperty != .none {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(goldAccent.opacity(0.5), lineWidth: 1)
                    .blur(radius: 3)
            }
            
            // Content
            VStack(spacing: 1) {
                HStack {
                    Text("\(element.atomicNumber)")
                        .font(.system(size: 6, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                
                Text(element.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Text(element.name)
                    .font(.system(size: 4))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(2)
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(isHighlighted ? 1 : 0.3)
        .scaleEffect(isHighlighted ? 1 : 0.9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(element.name), symbol \(element.symbol), atomic number \(element.atomicNumber)")
        .accessibilityHint(element.alchemicalProperty != .none ? "Alchemical element. Double tap to view details" : "Double tap to view element details")
    }
}

// MARK: - Element Detail View

struct ElementDetailView: View {
    let element: Element
    @Environment(\.dismiss) private var dismiss
    
    private let goldAccent = Color(hex: "#E5C158")
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(hex: "#1a1a2e"),
                    element.category.color.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // 3D Atom
                    atomVisualization
                    
                    // Properties
                    propertiesSection
                    
                    // Numerology
                    numerologySection
                    
                    // Mystical Meaning
                    mysticalSection
                    
                    // Alchemy
                    if element.alchemicalProperty != .none {
                        alchemySection
                    }
                }
                .padding()
            }
        }
        .overlay(closeButton, alignment: .topTrailing)
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Symbol Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [element.category.color, element.category.color.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: element.category.color.opacity(0.5), radius: 20, x: 0, y: 0)
                
                if element.alchemicalProperty != .none {
                    Circle()
                        .stroke(goldAccent, lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .shadow(color: goldAccent.opacity(0.8), radius: 10, x: 0, y: 0)
                }
                
                VStack {
                    Text(element.symbol)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(element.atomicNumber)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Name
            Text(element.name)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            // Category Badge
            HStack(spacing: 8) {
                Text(element.category.mysticalSymbol)
                Text(element.category.rawValue)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(element.category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(element.category.color.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(element.category.color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .blur(radius: 0.5)
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Atom Visualization
    
    private var atomVisualization: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "atom")
                    .foregroundColor(goldAccent)
                Text("ATOMIC STRUCTURE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(goldAccent)
                Spacer()
            }
            
            Atom3DView(atomicNumber: element.atomicNumber, symbol: element.symbol)
                .frame(height: 250)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(goldAccent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Properties Section
    
    private var propertiesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(goldAccent)
                Text("PROPERTIES")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(goldAccent)
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                PropertyCard(title: "Atomic Mass", value: String(format: "%.3f", element.atomicMass), icon: "scalemass.fill", color: .cyan)
                PropertyCard(title: "Electron Config", value: element.electronConfiguration, icon: "ellipsis.circle.fill", color: .purple)
                PropertyCard(title: "Crystal", value: element.crystalStructure, icon: "diamond.fill", color: .pink)
                PropertyCard(title: "Discovered", value: "\(element.yearDiscovered > 0 ? element.yearDiscovered : -element.yearDiscovered) \(element.yearDiscovered > 0 ? "CE" : "BCE")", icon: "calendar", color: .orange)
                PropertyCard(title: "Physical State", value: element.physicalState.rawValue, icon: element.physicalState == .solid ? "cube.fill" : element.physicalState == .liquid ? "drop.fill" : "wind", color: .blue)
                PropertyCard(title: "Oxidation", value: element.oxidationStates.map { String($0) }.joined(separator: ", "), icon: "plusminus.circle.fill", color: .green)
            }
            
            if element.discoveredBy != "Ancient" {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    Text("Discovered by: \(element.discoveredBy)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Numerology Section
    
    private var numerologySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "number.circle.fill")
                    .foregroundColor(goldAccent)
                Text("NUMEROLOGY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(goldAccent)
                Spacer()
            }
            
            HStack(spacing: 20) {
                // Atomic Number
                VStack {
                    Text("\(element.atomicNumber)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Atomic #")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(goldAccent)
                
                // Numerology Number
                ZStack {
                    Circle()
                        .fill(goldAccent.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Text("\(element.numerologyNumber)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(goldAccent)
                }
                
                VStack(alignment: .leading) {
                    Text("Soul Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(NumerologyMeanings.meaning(for: element.numerologyNumber).prefix(40) + "...")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Text(element.numerologySignificance)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(goldAccent.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(goldAccent.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(goldAccent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Mystical Section
    
    private var mysticalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("MYSTICAL SIGNIFICANCE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Spacer()
            }
            
            Text(element.mysticalMeaning)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Magical Affinities
            FlowLayout(spacing: 8) {
                ForEach(element.magicalAffinity, id: \.self) { affinity in
                    Text(affinity.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Alchemy Section
    
    private var alchemySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(element.alchemicalProperty.color)
                Text("ALCHEMICAL PROPERTY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(element.alchemicalProperty.color)
                Spacer()
            }
            
            HStack(spacing: 16) {
                Text(element.alchemicalProperty.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(element.alchemicalProperty.color)
                
                Spacer()
                
                // Alchemical symbol
                ZStack {
                    Circle()
                        .fill(element.alchemicalProperty.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(String(element.alchemicalProperty.rawValue.prefix(1)))
                        .font(.system(size: 30))
                        .foregroundColor(element.alchemicalProperty.color)
                }
            }
            
            if element.symbol == "Au" {
                Text("The Sun • Perfection • Enlightenment")
                    .font(.caption)
                    .foregroundColor(goldAccent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(goldAccent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(goldAccent.opacity(0.5), lineWidth: 1)
                            )
                    )
            } else if element.symbol == "Ag" {
                Text("The Moon • Intuition • Purification")
                    .font(.caption)
                    .foregroundColor(.silver)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    )
            } else if element.symbol == "Hg" {
                Text("The Messenger • Transformation • Fluidity")
                    .font(.caption)
                    .foregroundColor(.cyan)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cyan.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(element.alchemicalProperty.color.opacity(0.5), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Close Button
    
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.6))
                .padding()
        }
        .accessibilityLabel("Close element detail")
        .accessibilityHint("Double tap to close the element detail view")
    }
}

// MARK: - Property Card

struct PropertyCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Spacer()
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Silver Color Extension

extension Color {
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
}

// MARK: - Preview

struct PeriodicTableView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodicTableView()
            .preferredColorScheme(.dark)
    }
}