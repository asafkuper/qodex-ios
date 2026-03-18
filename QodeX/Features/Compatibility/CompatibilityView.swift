//
//  CompatibilityView.swift
//  QodeX - Premium Compatibility Matching
//  Inspired by dating apps, astrology apps
//

import SwiftUI

struct CompatibilityView: View {
    @State private var person1: Person = Person(name: "You", lifePath: 7, color: .purple)
    @State private var person2: Person = Person(name: "Partner", lifePath: 3, color: .blue)
    @State private var compatibilityScore: Int = 85
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Compatibility")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.starlight)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.goldPrimary.opacity(0.2))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Comparison Header
                    ComparisonHeader(person1: person1, person2: person2)
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    
                    // Score Ring
                    ScoreRing(score: compatibilityScore)
                        .padding(.top, 40)
                    
                    // Compatibility Verdict
                    VerdictCard(score: compatibilityScore)
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    
                    // Breakdown
                    BreakdownSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Strengths
                    StrengthsSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Famous Couples
                    FamousCouplesSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Person Model
struct Person {
    let name: String
    let lifePath: Int
    let color: Color
}

// MARK: - Comparison Header
struct ComparisonHeader: View {
    let person1: Person
    let person2: Person
    
    var body: some View {
        HStack(spacing: 20) {
            // Person 1
            PersonAvatar(person: person1)
            
            // Heart
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text("💕")
                    .font(.system(size: 32))
            }
            
            // Person 2
            PersonAvatar(person: person2)
        }
    }
}

struct PersonAvatar: View {
    let person: Person
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(person.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Text(String(person.name.prefix(1)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.starlight)
                
                // Life Path badge
                ZStack {
                    Circle()
                        .fill(Color(hex: "12121A"))
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .fill(person.color)
                        .frame(width: 22, height: 22)
                    
                    Text("\(person.lifePath)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.starlight)
                }
            }
            
            Text(person.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.starlight)
            
            Text("Life Path \(person.lifePath)")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.starlightTertiary)
        }
    }
}

// MARK: - Score Ring
struct ScoreRing: View {
    let score: Int
    @State private var animatedScore: Int = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(animatedScore) / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.goldPrimary.opacity(0.5),
                            Color.goldPrimary,
                            Color.goldBright
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.5), value: animatedScore)
            
            // Score
            VStack(spacing: 4) {
                Text("\(animatedScore)%")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.goldBright, .goldPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Match")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.starlightTertiary)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animatedScore = score
            }
        }
    }
}

// MARK: - Verdict Card
struct VerdictCard: View {
    let score: Int
    
    var verdict: String {
        switch score {
        case 90...100: return "Soulmate Connection"
        case 80..<90: return "Highly Compatible"
        case 70..<80: return "Good Match"
        case 60..<70: return "Challenging but Growth"
        default: return "Lessons to Learn"
        }
    }
    
    var description: String {
        switch score {
        case 90...100: 
            return "A rare and powerful connection. Your numbers align in harmony, creating a bond that feels destined."
        case 80..<90: 
            return "Strong compatibility with natural understanding. You complement each other's strengths beautifully."
        case 70..<80: 
            return "Good foundation with some differences to navigate. These differences can actually strengthen your bond."
        case 60..<70: 
            return "Different energies that require patience and compromise. Growth comes through understanding."
        default: 
            return "Challenging pairing that offers important life lessons. Success requires conscious effort."
        }
    }
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.goldPrimary)
                        .frame(width: 8, height: 8)
                        .shadow(color: .goldPrimary, radius: 10, x: 0, y: 0)
                    
                    Text("Compatibility Analysis")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(verdict)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.starlight)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }
}

// MARK: - Breakdown Section
struct BreakdownSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compatibility Breakdown")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 12) {
                BreakdownRow(title: "Communication", score: 90, icon: "💬")
                BreakdownRow(title: "Emotional", score: 75, icon: "❤️")
                BreakdownRow(title: "Spiritual", score: 95, icon: "✨")
                BreakdownRow(title: "Practical", score: 80, icon: "🏠")
            }
        }
    }
}

struct BreakdownRow: View {
    let title: String
    let score: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.starlight)
                    
                    Spacer()
                    
                    Text("\(score)%")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(score >= 80 ? .green : score >= 60 ? .goldPrimary : .orange)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                score >= 80 ? Color.green :
                                score >= 60 ? Color.goldPrimary :
                                Color.orange
                            )
                            .frame(width: geometry.size.width * CGFloat(score) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
    }
}

// MARK: - Strengths Section
struct StrengthsSection: View {
    let strengths = [
        "Deep spiritual connection",
        "Intellectual stimulation",
        "Mutual respect for independence",
        "Creative problem-solving together"
    ]
    
    let challenges = [
        "Different communication styles",
        "Need for personal space",
        "Varying social needs"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Relationship Dynamics")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                DynamicsCard(title: "Strengths", items: strengths, color: .green)
                DynamicsCard(title: "Challenges", items: challenges, color: .orange)
            }
        }
    }
}

struct DynamicsCard: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: title == "Strengths" ? "plus" : "minus")
                            .font(.system(size: 10))
                            .foregroundColor(color)
                            .padding(.top, 4)
                        
                        Text(item)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.starlightSecondary)
                            .lineLimit(2)
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

// MARK: - Famous Couples
struct FamousCouplesSection: View {
    let couples = [
        (names: "John \& Yoko", paths: "7 + 3", result: "Soulmates"),
        (names: "Barack \& Michelle", paths: "4 + 1", result: "Power Couple")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Famous 7 + 3 Couples")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 12) {
                ForEach(couples, id: \.names) { couple in
                    FamousCoupleRow(couple: couple)
                }
            }
        }
    }
}

struct FamousCoupleRow: View {
    let couple: (names: String, paths: String, result: String)
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.goldPrimary.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Text("💕")
                    .font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(couple.names)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Text(couple.paths)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            Spacer()
            
            Text(couple.result)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.goldPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.goldPrimary.opacity(0.1))
                )
        }
        .padding(16)
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

// MARK: - Preview
struct CompatibilityView_Previews: PreviewProvider {
    static var previews: some View {
        CompatibilityView()
            .preferredColorScheme(.dark)
    }
}
