//
//  ChaldeanEducationalContent.swift
//  QodeX - Chaldean Numerology Educational Resources
//
//  This file contains comprehensive educational content about the Chaldean
//  numerology system for display throughout the app.
//

import SwiftUI

// MARK: - Educational Content Models

struct ChaldeanContentSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let content: String
    let subsections: [ChaldeanSubsection]?
}

struct ChaldeanSubsection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

// MARK: - Chaldean Content Repository

enum ChaldeanEducationalContent {
    
    // MARK: - Main Sections
    
    static let mainSections: [ChaldeanContentSection] = [
        ChaldeanContentSection(
            title: "Ancient Origins",
            icon: "globe",
            content: """
            The Chaldean numerology system originated in ancient Babylon (modern-day Iraq) around 4000 BCE, making it one of the oldest known forms of numerology in existence.
            
            The Chaldeans were a Semitic people who ruled Babylon from the 7th to 6th centuries BCE, though their numerological wisdom predates their political dominance by millennia. They were master astrologers, mathematicians, and mystics who believed that numbers held the key to understanding the fundamental nature of the universe.
            
            Unlike many ancient systems that faded into obscurity, Chaldean numerology has persisted through the ages, passed down through mystery schools, secret societies, and esoteric traditions. It experienced a revival in the late 19th and early 20th centuries through practitioners like Cheiro (William John Warner), who brought this ancient wisdom to the Western world.
            """,
            subsections: nil
        ),
        
        ChaldeanContentSection(
            title: "Vibration-Based Philosophy",
            icon: "waveform",
            content: """
            The fundamental difference between Chaldean and Pythagorean numerology lies in their core philosophy of how numbers relate to language.
            
            While the Pythagorean system assigns numbers alphabetically (A=1, B=2, C=3, etc.), the Chaldean system is based on the sound vibration and energetic frequency of each letter. The ancient Chaldeans believed that everything in the universe vibrates at a specific frequency, and these vibrations correspond to numerical values.
            
            This vibrational approach means that letters with similar sounds often share the same numerical value, regardless of their position in the alphabet. For example, the hard 'C' sound in 'C' and 'K' both vibrate with the energy of number 2.
            
            The Chaldeans also observed that certain combinations of sounds created specific energetic patterns, which they associated with planetary energies and cosmic forces.
            """,
            subsections: nil
        ),
        
        ChaldeanContentSection(
            title: "The Sacred Number Nine",
            icon: "9.circle.fill",
            content: """
            One of the most distinctive features of the Chaldean system is the treatment of the number 9.
            
            In Chaldean numerology, the number 9 is considered sacred and divine. It represents completion, wholeness, and the highest spiritual attainment. Because of its sacred nature, NO letters in the Chaldean alphabet are assigned the value of 9.
            
            This stands in stark contrast to the Pythagorean system, where 9 is treated like any other number (I=9, R=9).
            
            The exclusion of 9 from letter assignments reflects the Chaldean understanding that certain spiritual energies should not be invoked casually. The number 9 only appears in calculations as a result of adding other numbers together, representing the divine sum of one's actions and energies.
            
            Some Chaldean masters also associated 9 with Mars, representing divine will and spiritual warfare against ignorance.
            """,
            subsections: nil
        )
    ]
    
    // MARK: - Key Differences
    
    static let keyDifferences: [(title: String, pythagorean: String, chaldean: String, icon: String)] = [
        (
            title: "Assignment Method",
            pythagorean: "Alphabetical order: A=1, B=2, C=3, continuing sequentially through the alphabet",
            chaldean: "Vibrational energy based on sound and planetary associations",
            icon: "textformat.abc"
        ),
        (
            title: "The Number 9",
            pythagorean: "Treated normally: I=9, R=9",
            chaldean: "Sacred number - no letters assigned. Only appears through calculation.",
            icon: "9.circle"
        ),
        (
            title: "Compound Numbers",
            pythagorean: "Generally reduced to single digits (except 11, 22, 33)",
            chaldean: "All double-digit numbers (10-52) have specific meanings and interpretations",
            icon: "number"
        ),
        (
            title: "Planetary Associations",
            pythagorean: "Limited planetary connections",
            chaldean: "Each number corresponds to specific planetary energies and cosmic forces",
            icon: "globe"
        ),
        (
            title: "Name Usage",
            pythagorean: "Uses full birth certificate name",
            chaldean: "Traditionally uses most commonly used name or single name",
            icon: "person"
        ),
        (
            title: "Focus & Purpose",
            pythagorean: "Personality analysis, life purpose, and destiny",
            chaldean: "Karmic patterns, spiritual lessons, hidden influences, and business timing",
            icon: "target"
        ),
        (
            title: "Master Numbers",
            pythagorean: "11, 22, 33 considered master numbers",
            chaldean: "More nuanced approach to all compound numbers",
            icon: "crown"
        ),
        (
            title: "Best For",
            pythagorean: "Beginners, general personality readings, compatibility",
            chaldean: "Advanced users, business decisions, timing, deeper spiritual work",
            icon: "star"
        )
    ]
    
    // MARK: - Letter Values
    
    static let letterValues: [(number: Int, letters: [String], planet: String, energy: String, color: Color)] = [
        (1, ["A", "I", "J", "Q", "Y"], "Sun ☉", "Leadership, individuality, ambition, creativity", .orange),
        (2, ["B", "K", "R"], "Moon ☽", "Sensitivity, cooperation, intuition, diplomacy", .yellow),
        (3, ["C", "G", "L", "S"], "Jupiter ♃", "Creativity, expansion, optimism, self-expression", .purple),
        (4, ["D", "M", "T"], "Uranus/Rahu", "Practicality, foundation, sudden changes, individuality", .blue),
        (5, ["E", "H", "N", "X"], "Mercury ☿", "Communication, intellect, change, commerce", .green),
        (6, ["U", "V", "W"], "Venus ♀", "Love, harmony, beauty, responsibility, service", .pink),
        (7, ["O", "Z"], "Neptune/Ketu", "Spirituality, mysticism, introspection, wisdom", .indigo),
        (8, ["F", "P"], "Saturn ♄", "Karma, discipline, authority, material success", .gray),
    ]
    
    // MARK: - Compound Number Meanings (10-33)
    
    static let compoundMeanings: [(number: Int, title: String, meaning: String, keyword: String, nature: String)] = [
        (10, "The Wheel of Fortune", "Symbolizes honor, faith, and confidence. Represents the rise and fall in life. Considered a lucky number that brings success through one's own efforts and natural abilities.", "Fortune", "Lucky"),
        (11, "The Lion", "Hidden dangers and hidden enemies. Great mental powers but they must be used wisely. Trials and treachery from others. A number of tests and spiritual mastery.", "Mastery", "Warning"),
        (12, "The Sacrifice", "Suffering and anxiety, often sacrifice for others. Can indicate victimization by others' plans or being a scapegoat. Learning the lesson of selfless service.", "Sacrifice", "Karmic"),
        (13, "The Rebirth", "Powerful but dangerous. Transformation through upheaval. Symbolizes change and regeneration. Not unlucky as commonly believed, but indicates major life transitions.", "Transformation", "Powerful"),
        (14, "The Movement", "Lucky for dealings with money and business. Represents risk-taking and change. Indicates natural business ability and success through adaptability.", "Commerce", "Lucky"),
        (15, "The Magician", "Strong occult and psychic influences. Power over others through charm and magnetism. Can indicate eloquence and the ability to influence masses.", "Enchantment", "Magical"),
        (16, "The Shattered Citadel", "Fall from pride and position. Destruction of ego through painful lessons. Warning of sudden calamity if pride is not checked. Ultimate spiritual growth through humility.", "Fall", "Karmic"),
        (17, "The Star of the Magi", "Highly spiritual, psychic gifts, superior intelligence. Victory over obstacles through spiritual power. This number bestows peace and happiness in the later years.", "Spirituality", "Blessed"),
        (18, "The Materialism", "War, strife, deception. Success comes through mental struggle. Danger from being overly materialistic. Spiritual wealth brings true happiness.", "Struggle", "Testing"),
        (19, "The Prince of Heaven", "Universal love, rising above adversity. Victory and success assured. This is a highly fortunate number indicating rise in life and happiness.", "Victory", "Fortunate"),
        (20, "The Awakening", "New purpose, judgment, awakening. Represents partnerships and change. Indicates a new cycle beginning with new responsibilities.", "Judgment", "New Beginnings"),
        (21, "The Crown of the Magi", "Success after struggle, honors, elevation in life. Universal triumph over obstacles. This number promises success in all undertakings.", "Triumph", "Victorious"),
        (22, "The Fool", "Blindness to reality, foolishness, lack of foresight. Caution is needed in all dealings. Represents learning through mistakes and false steps.", "Caution", "Learning"),
        (23, "The Royal Star of the Lion", "Most fortunate number offering protection from accidents and dangers. Success in all endeavors, divine favor and guidance. This is considered the luckiest of all numbers.", "Protection", "Most Fortunate"),
        (24, "The Love", "Love, beauty, artistic success, fortunate in love and business. Promises help from superiors and those in power. A number of harmony and happiness.", "Harmony", "Lucky"),
        (25, "The Discrimination", "Strength through experience, wise discernment. Gains through investigation and research. Indicates recovery from illnesses and wise judgment.", "Wisdom", "Insightful"),
        (26, "The Disappointment", "Grave warnings for the future. Danger through bad advice, partnership failures. Caution in all dealings, especially financial and legal.", "Warning", "Caution"),
        (27, "The Scepter", "Commanding power, authority, leadership. Success through bold action and determination. Indicates rise to high position through merit.", "Authority", "Power"),
        (28, "The Uncertainty", "Contradictory, threat of loss through law or conflict. Trust carefully and verify all agreements. Not favorable for partnerships.", "Risk", "Uncertain"),
        (29, "The Grace", "Warnings of trials and tribulations. Must rely on intuition and inner wisdom. Indicates assistance from invisible forces when faith is strong.", "Trials", "Spiritual"),
        (30, "The Faith", "Thoughtful deduction, mental superiority, devotion to duty. Reliable and trustworthy. Indicates deep thinking and philosophical nature.", "Devotion", "Reliable"),
        (31, "The Child", "Innocence, purity, trust. Living in thought rather than action. May indicate delayed development or staying young at heart.", "Innocence", "Youthful"),
        (32, "The Transport", "Magical number of communication, transportation, travel. Quick success in social and business ventures. Favorable for media and communications.", "Communication", "Quick Success"),
        (33, "The Blessing", "Blessing of the divine, spiritual teacher, master healer. Great responsibility comes with this number. Indicates protection and guidance from higher powers.", "Blessing", "Divine")
    ]
    
    // MARK: - When to Use Chaldean
    
    static let whenToUse: [(title: String, description: String, icon: String)] = [
        (
            title: "Deep Spiritual Insights",
            description: "When you seek to understand deeper spiritual patterns, karmic lessons, and soul-level influences that shape your life journey.",
            icon: "sparkles"
        ),
        (
            title: "Business Decisions",
            description: "The Chaldean system excels at determining favorable business names, timing for launches, and understanding commercial vibrations.",
            icon: "briefcase"
        ),
        (
            title: "Karmic Understanding",
            description: "To uncover past life influences, recurring patterns, and spiritual debts that need to be addressed in this lifetime.",
            icon: "clock.arrow.circlepath"
        ),
        (
            title: "Hidden Personality Aspects",
            description: "When the Pythagorean reading doesn't seem to match your inner experience, Chaldean reveals hidden and secret influences.",
            icon: "eye.slash"
        ),
        (
            title: "Timing and Cycles",
            description: "Chaldean numerology provides detailed insights into favorable timing for major life decisions and transitions.",
            icon: "calendar"
        ),
        (
            title: "Esoteric Work",
            description: "For advanced spiritual practitioners, occultists, and those working with deeper metaphysical principles.",
            icon: "star.circle"
        )
    ]
    
    // MARK: - Famous Practitioners
    
    static let famousPractitioners: [(name: String, origin: String, contribution: String)] = [
        (
            name: "Cheiro (William John Warner)",
            origin: "Ireland (1866-1936)",
            contribution: "The most famous numerologist of the modern era. Counted kings, queens, and presidents among his clients. Authored 'Cheiro's Book of Numbers' which remains a classic reference."
        ),
        (
            name: "Dr. Julian St. Aubyn",
            origin: "Britain (20th century)",
            contribution: "British numerologist and author who documented traditional Chaldean methods and their applications in modern contexts."
        ),
        (
            name: "Ancient Chaldean Priests",
            origin: "Babylon (4000+ BCE)",
            contribution: "The original practitioners who developed this system in the temples of Babylon, using it for royal counsel and predicting the fate of nations."
        ),
        (
            name: "Pythagoras",
            origin: "Greece (570-495 BCE)",
            contribution: "While known for the Pythagorean system, he studied with Chaldean masters in Egypt and Babylon, incorporating their wisdom into his teachings."
        )
    ]
    
    // MARK: - Comparison Table Data
    
    static let comparisonTable: [(category: String, pythagorean: String, chaldean: String)] = [
        ("Origin", "Ancient Greece, 6th century BCE", "Ancient Babylon, ~4000 BCE"),
        ("Philosophy", "Mathematical order and harmony", "Sound vibration and planetary energy"),
        ("Letter Assignment", "Sequential (A=1, B=2, C=3...)", "Vibrational groups based on sound"),
        ("Number 9 Treatment", "Normal value (I=9, R=9)", "Sacred - no letters assigned"),
        ("Compound Numbers", "Reduce to single digits", "10-52 all have meanings"),
        ("Best For", "Beginners, personality analysis", "Advanced work, business, spirituality"),
        ("Name to Use", "Full birth certificate name", "Commonly used name"),
        ("Master Numbers", "11, 22, 33", "More nuanced compound meanings"),
        ("Focus", "Conscious personality, destiny", "Karma, subconscious, hidden influences")
    ]
}

// MARK: - View Components for Educational Content

struct ChaldeanContentCard: View {
    let section: ChaldeanContentSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: section.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                
                Text(section.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
            }
            
            Text(section.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(4)
            
            if let subsections = section.subsections {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(subsections) { subsection in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subsection.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.starlight)
                            
                            Text(subsection.content)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.starlightTertiary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct CompoundNumberCard: View {
    let meaning: (number: Int, title: String, meaning: String, keyword: String, nature: String)
    
    var natureColor: Color {
        switch meaning.nature {
        case "Lucky", "Fortunate", "Blessed", "Most Fortunate":
            return .green
        case "Warning", "Caution", "Testing", "Karmic":
            return .orange
        case "Powerful", "Magical":
            return .purple
        case "Victorious", "Triumph":
            return .blue
        default:
            return .indigo
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(meaning.number)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.starlight)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meaning.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.starlight)
                    
                    HStack(spacing: 8) {
                        Text(meaning.keyword)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(natureColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(natureColor.opacity(0.2))
                            )
                        
                        Text(meaning.nature)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.starlightTertiary)
                    }
                }
                
                Spacer()
            }
            
            Text(meaning.meaning)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Color Extension for Educational Views

extension Color {
    static let starlightSecondary = Color.white.opacity(0.8)
}