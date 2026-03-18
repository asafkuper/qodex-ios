//
//  NumberDetailView.swift
//  QodeX - Premium Number Detail
//  Inspired by Apple Health, Astrology apps
//

import SwiftUI

struct NumberDetailView: View {
    let number: NumerologyNumber
    @State private var isBookmarked = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background with gradient based on number
            number.color.opacity(0.1)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Hero Section
                    HeroSection(number: number, scrollOffset: scrollOffset)
                    
                    // Content
                    VStack(spacing: 24) {
                        // Description
                        DescriptionCard(number: number)
                        
                        // Karmic Debt Section (if applicable)
                        if let karmicDebt = number.karmicDebtDetails {
                            KarmicDebtSection(karmicDebt: karmicDebt)
                        }
                        
                        // Traits
                        TraitsSection(number: number)
                        
                        // Famous People
                        FamousPeopleSection(number: number)
                        
                        // Compatibility
                        CompatibilitySection(number: number)
                        
                        // Career Paths
                        CareerSection(number: number)
                        
                        // Relationships
                        RelationshipsSection(number: number)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            // Navigation bar
            VStack {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.starlight)
                    }
                    
                    Spacer()
                    
                    Text(number.type.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { isBookmarked.toggle() }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 20))
                                .foregroundColor(isBookmarked ? .goldPrimary : .starlight)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.starlight)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 12)
                .background(
                    Color(hex: "0A0A0F")
                        .opacity(min(1, max(0, -scrollOffset / 200)))
                )
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    let number: NumerologyNumber
    let scrollOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            number.color.opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(y: -50)
            
            VStack(spacing: 16) {
                // Large number
                Text("\(number.value)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [number.color.opacity(0.8), number.color],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: number.color.opacity(0.5), radius: 30, x: 0, y: 0)
                    .scaleEffect(max(0.5, 1 + scrollOffset / 500))
                    .opacity(max(0, 1 + scrollOffset / 200))
                
                // Title
                Text(number.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.starlight)
                
                // Keywords
                Text(number.keywords.joined(separator: " • "))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 100)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Description Card
struct DescriptionCard: View {
    let number: NumerologyNumber
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(number.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: number.color, radius: 10, x: 0, y: 0)
                    
                    Text("About Life Path \(number.value)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(number.color)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(number.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(6)
            }
        }
    }
}

// MARK: - Karmic Debt Section
struct KarmicDebtSection: View {
    let karmicDebt: KarmicDebtInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Karmic Debt \(karmicDebt.number)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("The \(karmicDebt.name)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.starlightSecondary)
                }
                
                Spacer()
                
                // Element badge
                HStack(spacing: 4) {
                    Image(systemName: elementIcon)
                        .font(.system(size: 12))
                    Text(karmicDebt.element)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }
            
            Divider()
                .background(Color.orange.opacity(0.3))
            
            // Core Lesson
            VStack(alignment: .leading, spacing: 8) {
                Text("Core Lesson")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(karmicDebt.coreLesson)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlight)
                    .lineSpacing(4)
            }
            
            // Past Life Pattern
            VStack(alignment: .leading, spacing: 8) {
                Text("Past Life Pattern")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.starlightTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(karmicDebt.pastLifePattern)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(4)
            }
            
            // How to Overcome
            VStack(alignment: .leading, spacing: 12) {
                Text("How to Overcome")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.green)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(karmicDebt.howToOvercome, id: \.self) { step in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text(step)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.starlightSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            // Shadow Aspects
            VStack(alignment: .leading, spacing: 12) {
                Text("Shadow Aspects")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                FlowLayout(spacing: 8) {
                    ForEach(karmicDebt.shadowAspects, id: \.self) { aspect in
                        ShadowTag(text: aspect)
                    }
                }
            }
            
            // Growth Opportunities
            VStack(alignment: .leading, spacing: 12) {
                Text("Growth Opportunities")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.purple)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(karmicDebt.growthOpportunities, id: \.self) { opportunity in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(.purple)
                            
                            Text(opportunity)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.starlightSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            // Tarot Connection
            HStack(spacing: 8) {
                Image(systemName: "suit.club.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.starlightTertiary)
                
                Text("Tarot: \(karmicDebt.tarotCard)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.starlightTertiary)
            }
            
            // Affirmation
            VStack(alignment: .leading, spacing: 8) {
                Text("Affirmation")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text("\"\(karmicDebt.affirmation)\"")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundColor(.goldPrimary)
                    .italic()
                    .lineSpacing(4)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.goldPrimary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A0F05"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var elementIcon: String {
        switch karmicDebt.element {
        case "Fire": return "flame.fill"
        case "Water": return "drop.fill"
        case "Air": return "wind"
        case "Earth": return "leaf.fill"
        default: return "circle.fill"
        }
    }
}

struct ShadowTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.starlightSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.red.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Traits Section
struct TraitsSection: View {
    let number: NumerologyNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traits")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                TraitCard(title: "Strengths", traits: number.strengths, color: .green)
                TraitCard(title: "Challenges", traits: number.challenges, color: .orange)
            }
        }
    }
}

struct TraitCard: View {
    let title: String
    let traits: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(traits, id: \.self) { trait in
                    HStack(spacing: 8) {
                        Image(systemName: title == "Strengths" ? "plus" : "minus")
                            .font(.system(size: 10))
                            .foregroundColor(color)
                        
                        Text(trait)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.starlightSecondary)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Famous People Section
struct FamousPeopleSection: View {
    let number: NumerologyNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Famous Life Path \(number.value)s")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(number.famousPeople, id: \.self) { person in
                        FamousPersonCard(name: person)
                    }
                }
            }
        }
    }
}

struct FamousPersonCard: View {
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.goldPrimary.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.starlight)
                )
            
            Text(name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.starlight)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

// MARK: - Compatibility Section
struct CompatibilitySection: View {
    let number: NumerologyNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compatibility")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                CompatibilityCard(title: "Most Compatible", numbers: number.mostCompatible, color: .green)
                CompatibilityCard(title: "Challenging", numbers: number.challenging, color: .orange)
            }
        }
    }
}

struct CompatibilityCard: View {
    let title: String
    let numbers: [Int]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            HStack(spacing: 8) {
                ForEach(numbers, id: \.self) { num in
                    Text("\(num)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
    }
}

// MARK: - Career Section
struct CareerSection: View {
    let number: NumerologyNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ideal Career Paths")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            FlowLayout(spacing: 8) {
                ForEach(number.careers, id: \.self) { career in
                    CareerTag(text: career)
                }
            }
        }
    }
}

struct CareerTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.starlight)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.goldPrimary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Relationships Section
struct RelationshipsSection: View {
    let number: NumerologyNumber
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 8, height: 8)
                    
                    Text("In Relationships")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.pink)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(number.relationships)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(6)
            }
        }
    }
}

// MARK: - Models
struct NumerologyNumber {
    let value: Int
    let type: NumberType
    let title: String
    let keywords: [String]
    let description: String
    let strengths: [String]
    let challenges: [String]
    let famousPeople: [String]
    let mostCompatible: [Int]
    let challenging: [Int]
    let careers: [String]
    let relationships: String
    let color: Color
    let karmicDebtDetails: KarmicDebtInfo?  // Optional karmic debt information
    
    enum NumberType: String {
        case lifePath = "Life Path"
        case expression = "Expression"
        case soulUrge = "Soul Urge"
        case personality = "Personality"
    }
}

/// Karmic Debt information for display in NumberDetailView
struct KarmicDebtInfo {
    let number: Int
    let reducesTo: Int
    let name: String
    let pastLifePattern: String
    let coreLesson: String
    let howToOvercome: [String]
    let shadowAspects: [String]
    let growthOpportunities: [String]
    let affirmation: String
    let element: String
    let tarotCard: String
}

// Sample data for Life Path 7
let sampleNumber = NumerologyNumber(
    value: 7,
    type: .lifePath,
    title: "The Seeker",
    keywords: ["Spiritual", "Analytical", "Wise", "Introspective", "Mystical"],
    description: "Life Path 7s are the truth seekers of numerology. You have a deep need to understand the mysteries of life and the universe. Your analytical mind combined with your spiritual nature makes you a natural philosopher and researcher. You excel at digging beneath the surface to find hidden truths.",
    strengths: ["Analytical", "Intuitive", "Wise", "Perceptive", "Truth-seeker"],
    challenges: ["Isolated", "Perfectionist", "Secretive", "Overthinking"],
    famousPeople: ["Leonardo da Vinci", "Princess Diana", "Marilyn Monroe", "John F. Kennedy"],
    mostCompatible: [1, 4, 7],
    challenging: [3, 5, 9],
    careers: ["Researcher", "Scientist", "Philosopher", "Psychologist", "Writer", "IT Specialist"],
    relationships: "As a 7, you need a partner who respects your need for solitude and intellectual pursuits. You're most compatible with someone who can engage in deep conversations and give you space when needed. Trust is essential, as you tend to be private about your inner world.",
    color: .purple,
    karmicDebtDetails: nil  // Life Path 7 doesn't have karmic debt (16 reduces to 7 but this is regular 7)
)

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
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
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Sample Karmic Debt Number (for testing)
let sampleKarmicDebt13 = KarmicDebtInfo(
    number: 13,
    reducesTo: 4,
    name: "The Phoenix",
    pastLifePattern: "Misuse of power, laziness, taking shortcuts, abusing authority",
    coreLesson: "Work with the material world through discipline. Find joy in process, not just results.",
    howToOvercome: [
        "Embrace process over outcome",
        "Practice patience when tempted by shortcuts",
        "Rebuild with grace when things fall apart",
        "Develop consistent daily discipline"
    ],
    shadowAspects: [
        "Constant sense that work is burdensome",
        "Seeking shortcuts that lead to setbacks",
        "Giving up before completion",
        "Feeling that life is harder for you"
    ],
    growthOpportunities: [
        "Exceptional ability to rebuild after loss",
        "Deep satisfaction from sustained effort",
        "Natural talent for transforming obstacles",
        "Becoming a beacon of resilience"
    ],
    affirmation: "I embrace the process. My dedication transforms obstacles into stepping stones. Through fire, I am reborn stronger.",
    element: "Fire",
    tarotCard: "Death (XIII)"
)

let sampleKarmicDebtNumber = NumerologyNumber(
    value: 4,
    type: .lifePath,
    title: "The Builder (13/4)",
    keywords: ["Disciplined", "Resilient", "Transformative", "Hardworking", "Phoenix"],
    description: "Life Path 13/4 is the Phoenix path - you have extraordinary ability to rise from ashes and transform through difficulty. Your journey involves mastering the material world through authentic effort, learning that sustainable success comes from dedication, not shortcuts.",
    strengths: ["Resilient", "Hardworking", "Transformative", "Disciplined", "Persevering"],
    challenges: ["Workaholic tendencies", "Impatience with process", "Fear of failure", "Burdened by responsibility"],
    famousPeople: ["Oprah Winfrey", "Steve Jobs", "J.K. Rowling", "Robert Downey Jr."],
    mostCompatible: [1, 4, 7, 8],
    challenging: [3, 5, 9],
    careers: ["Crisis Manager", "Turnaround Specialist", "Project Manager", "Restoration Expert", "Recovery Coach"],
    relationships: "In relationships, you experience cycles of destruction and rebirth. You need a partner who respects your work ethic and supports your transformations.",
    color: .orange,
    karmicDebtDetails: sampleKarmicDebt13
)

// MARK: - Preview
struct NumberDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NumberDetailView(number: sampleNumber)
                .preferredColorScheme(.dark)
                .previewDisplayName("Regular Number (7)")
            
            NumberDetailView(number: sampleKarmicDebtNumber)
                .preferredColorScheme(.dark)
                .previewDisplayName("Karmic Debt (13/4)")
        }
    }
}
