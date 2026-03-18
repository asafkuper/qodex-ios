//
//  LocalizationManager.swift
//  Multi-language support
//

import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    // MARK: - Supported Languages
    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case portuguese = "pt"
        case italian = "it"
        case dutch = "nl"
        case russian = "ru"
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"
        case japanese = "ja"
        case korean = "ko"
        case arabic = "ar"
        case hindi = "hi"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .portuguese: return "Português"
            case .italian: return "Italiano"
            case .dutch: return "Nederlands"
            case .russian: return "Русский"
            case .chineseSimplified: return "简体中文"
            case .chineseTraditional: return "繁體中文"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .arabic: return "العربية"
            case .hindi: return "हिन्दी"
            }
        }
        
        var isRTL: Bool {
            return self == .arabic
        }
    }
    
    @Published var currentLanguage: Language = .english
    
    // MARK: - Number Names Localization
    func localizedNumberName(_ number: Int, for language: Language) -> String {
        let names: [Language: [Int: String]] = [
            .english: [
                1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five",
                6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
            ],
            .spanish: [
                1: "Uno", 2: "Dos", 3: "Tres", 4: "Cuatro", 5: "Cinco",
                6: "Seis", 7: "Siete", 8: "Ocho", 9: "Nueve"
            ],
            .french: [
                1: "Un", 2: "Deux", 3: "Trois", 4: "Quatre", 5: "Cinq",
                6: "Six", 7: "Sept", 8: "Huit", 9: "Neuf"
            ],
            .chineseSimplified: [
                1: "一", 2: "二", 3: "三", 4: "四", 5: "五",
                6: "六", 7: "七", 8: "八", 9: "九"
            ]
        ]
        
        return names[language]?[number] ?? String(number)
    }
    
    // MARK: - Vibe Descriptions
    func localizedVibe(for number: Int, language: Language) -> String {
        let vibes: [Language: [Int: String]] = [
            .english: [
                1: "Leadership & Independence",
                2: "Partnership & Harmony",
                3: "Creativity & Expression",
                4: "Stability & Foundation",
                5: "Freedom & Adventure",
                6: "Responsibility & Love",
                7: "Wisdom & Spirituality",
                8: "Power & Abundance",
                9: "Completion & Humanitarianism"
            ],
            .spanish: [
                1: "Liderazgo e Independencia",
                2: "Asociación y Armonía",
                3: "Creatividad y Expresión",
                4: "Estabilidad y Fundamento",
                5: "Libertad y Aventura",
                6: "Responsabilidad y Amor",
                7: "Sabiduría y Espiritualidad",
                8: "Poder y Abundancia",
                9: "Completitud y Humanitarismo"
            ],
            .chineseSimplified: [
                1: "领导与独立",
                2: "合作与和谐",
                3: "创造与表达",
                4: "稳定与基础",
                5: "自由与冒险",
                6: "责任与爱",
                7: "智慧与灵性",
                8: "力量与富足",
                9: "完成与人道"
            ]
        ]
        
        return vibes[language]?[number] ?? vibes[.english]?[number] ?? ""
    }
    
    // MARK: - Numerology System Variants
    func numerologySystem(for language: Language) -> NumerologySystem {
        switch language {
        case .chineseSimplified, .chineseTraditional:
            return .chinese
        case .hindi:
            return .vedic
        case .arabic:
            return .abjad
        default:
            return .pythagorean
        }
    }
    
    enum NumerologySystem {
        case pythagorean
        case chaldean
        case chinese
        case vedic
        case abjad
        case kabbalah
    }
}

// MARK: - String Extension
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}
