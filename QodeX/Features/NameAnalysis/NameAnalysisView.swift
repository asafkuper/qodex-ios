//
//  NameAnalysisView.swift
//  QodeX - Premium Name Numerology Analysis
//  Reference: Mystic numerology traditions, Astrology Zone
//

import SwiftUI

// MARK: - Name Analysis View
struct NameAnalysisView: View {
    @State private var name: String = ""
    @State private var isAnalyzed: Bool = false
    @State private var showSaveConfirmation: Bool = false
    @State private var savedAnalyses: [SavedAnalysis] = []
    
    // Computed properties for numerology calculations
    private var letterValues: [(letter: String, value: Int, isVowel: Bool)] {
        calculateLetterValues(for: name)
    }
    
    private var vowels: [(letter: String, value: Int)] {
        letterValues.filter { $0.isVowel }.map { ($0.letter, $0.value) }
    }
    
    private var consonants: [(letter: String, value: Int)] {
        letterValues.filter { !$0.isVowel }.map { ($0.letter, $0.value) }
    }
    
    private var expressionNumber: Int {
        reduceToSingleDigit(letterValues.reduce(0) { $0 + $1.value })
    }
    
    private var soulUrgeNumber: Int {
        reduceToSingleDigit(vowels.reduce(0) { $0 + $1.value })
    }
    
    private var personalityNumber: Int {
        reduceToSingleDigit(consonants.reduce(0) { $0 + $1.value })
    }
    
    var body: some View {
        ZStack {
            // Deep cosmic background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Name Input
                    nameInputSection
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    
                    if isAnalyzed && !name.isEmpty {
                        // Letter-by-letter breakdown
                        letterBreakdownSection
                            .padding(.horizontal, 20)
                            .padding(.top, 32)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Vowel/Consonant Analysis
                        vowelConsonantSection
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Core Numbers
                        coreNumbersSection
                            .padding(.horizontal, 20)
                            .padding(.top, 32)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Alphabet Chart
                        alphabetChartSection
                            .padding(.horizontal, 20)
                            .padding(.top, 32)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Educational Info
                        educationalSection
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            
            // Save Confirmation Overlay
            if showSaveConfirmation {
                saveConfirmationOverlay
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnalyzed)
        .dismissKeyboardOnTap()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name Analysis")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.starlightPrimary)
                
                Text("Discover the numerology within your name")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            Spacer()
            
            if isAnalyzed {
                Button(action: saveAnalysis) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.goldPrimary.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .stroke(Color.goldPrimary.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
    }
    
    // MARK: - Name Input Section
    private var nameInputSection: some View {
        VStack(spacing: 20) {
            // Input field with glass effect
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cosmicBlackElevated.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                HStack(spacing: 12) {
                    Image(systemName: "textformat")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.goldPrimary)
                    
                    TextField("Enter your full name", text: $name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.starlightPrimary)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .onSubmit {
                            withAnimation {
                                isAnalyzed = true
                            }
                        }
                    
                    if !name.isEmpty {
                        Button(action: {
                            name = ""
                            isAnalyzed = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.starlightTertiary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .frame(height: 64)
            
            // Analyze Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isAnalyzed = true
                }
                QXHaptic.mediumImpact()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text("Analyze Name")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.cosmicBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.goldBright, .goldPrimary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .goldPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .disabled(name.isEmpty)
            .opacity(name.isEmpty ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Letter Breakdown Section
    private var letterBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Letter-by-Letter Breakdown",
                subtitle: "Each letter carries a numerical vibration"
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(letterValues.enumerated()), id: \.offset) { index, item in
                        LetterCard(
                            letter: item.letter,
                            value: item.value,
                            isVowel: item.isVowel,
                            delay: Double(index) * 0.05
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Vowel/Consonant Section
    private var vowelConsonantSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Sound Analysis",
                subtitle: "Vowels reveal your inner self, consonants your outer expression"
            )
            
            HStack(spacing: 12) {
                // Vowels Card
                SoundTypeCard(
                    title: "Vowels",
                    subtitle: "Soul's Voice",
                    letters: vowels,
                    color: Color(hex: "FF6B9D"),
                    icon: "heart.fill",
                    delay: 0
                )
                
                // Consonants Card
                SoundTypeCard(
                    title: "Consonants",
                    subtitle: "Outer Expression",
                    letters: consonants,
                    color: Color(hex: "4ECDC4"),
                    icon: "person.fill",
                    delay: 0.1
                )
            }
        }
    }
    
    // MARK: - Core Numbers Section
    private var coreNumbersSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "Core Numbers",
                subtitle: "The three pillars of your name numerology"
            )
            
            VStack(spacing: 16) {
                // Expression Number
                NumberCard(
                    title: "Expression Number",
                    number: expressionNumber,
                    subtitle: "Your natural talents and abilities",
                    description: expressionMeaning(for: expressionNumber),
                    color: .goldPrimary,
                    icon: "sparkles",
                    delay: 0
                )
                
                // Soul Urge Number
                NumberCard(
                    title: "Soul Urge Number",
                    number: soulUrgeNumber,
                    subtitle: "Your innermost desires and motivations",
                    description: soulUrgeMeaning(for: soulUrgeNumber),
                    color: Color(hex: "FF6B9D"),
                    icon: "heart.fill",
                    delay: 0.1
                )
                
                // Personality Number
                NumberCard(
                    title: "Personality Number",
                    number: personalityNumber,
                    subtitle: "How others perceive you",
                    description: personalityMeaning(for: personalityNumber),
                    color: Color(hex: "4ECDC4"),
                    icon: "person.2.fill",
                    delay: 0.2
                )
            }
        }
    }
    
    // MARK: - Alphabet Chart Section
    private var alphabetChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Pythagorean Chart",
                subtitle: "The ancient system of letter-to-number correspondence"
            )
            
            VStack(spacing: 12) {
                ForEach(alphabetRows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.letter) { item in
                            ChartCell(
                                letter: item.letter,
                                value: item.value,
                                isHighlighted: name.uppercased().contains(item.letter)
                            )
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cosmicBlackElevated.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Educational Section
    private var educationalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Understanding Your Numbers",
                subtitle: "The wisdom behind the calculations"
            )
            
            VStack(spacing: 12) {
                EducationCard(
                    title: "How It Works",
                    content: "Each letter in your name corresponds to a number (1-9) using the Pythagorean system. These numbers are reduced to single digits (except master numbers 11, 22, 33) to reveal your core numerological profile.",
                    icon: "lightbulb.fill",
                    color: .goldPrimary
                )
                
                EducationCard(
                    title: "Expression Number",
                    content: "Calculated from all letters in your full name, this number reveals your natural strengths, talents, and the path you're meant to walk in this lifetime.",
                    icon: "sparkles",
                    color: Color(hex: "9B59B6")
                )
                
                EducationCard(
                    title: "Soul Urge Number",
                    content: "Derived from the vowels in your name, this number exposes your deepest desires, inner cravings, and what truly motivates you at a soul level.",
                    icon: "heart.fill",
                    color: Color(hex: "FF6B9D")
                )
                
                EducationCard(
                    title: "Personality Number",
                    content: "Found through the consonants, this number indicates how you present yourself to the world and the first impression you make on others.",
                    icon: "theatermasks.fill",
                    color: Color(hex: "4ECDC4")
                )
            }
        }
    }
    
    // MARK: - Save Confirmation Overlay
    private var saveConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showSaveConfirmation = false
                    }
                }
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.goldPrimary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.goldPrimary)
                }
                
                Text("Analysis Saved")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlightPrimary)
                
                Text("Your name analysis has been saved to your collection.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation {
                        showSaveConfirmation = false
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.cosmicBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.goldPrimary)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.cosmicBlackElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.goldPrimary.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(40)
        }
        .transition(.opacity)
    }
    
    // MARK: - Helper Methods
    private func saveAnalysis() {
        let analysis = SavedAnalysis(
            id: UUID(),
            name: name,
            expressionNumber: expressionNumber,
            soulUrgeNumber: soulUrgeNumber,
            personalityNumber: personalityNumber,
            date: Date()
        )
        savedAnalyses.append(analysis)
        
        withAnimation {
            showSaveConfirmation = true
        }
        QXHaptic.success()
    }
    
    private func calculateLetterValues(for name: String) -> [(String, Int, Bool)] {
        let pythagoreanChart: [Character: Int] = [
            "A": 1, "J": 1, "S": 1,
            "B": 2, "K": 2, "T": 2,
            "C": 3, "L": 3, "U": 3,
            "D": 4, "M": 4, "V": 4,
            "E": 5, "N": 5, "W": 5,
            "F": 6, "O": 6, "X": 6,
            "G": 7, "P": 7, "Y": 7,
            "H": 8, "Q": 8, "Z": 8,
            "I": 9, "R": 9
        ]
        
        let vowels: Set<Character> = ["A", "E", "I", "O", "U"]
        
        return name.uppercased().compactMap { char in
            guard let value = pythagoreanChart[char] else { return nil }
            let isVowel = vowels.contains(char)
            return (String(char), value, isVowel)
        }
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 && result != 11 && result != 22 && result != 33 {
            result = String(result).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return result == 0 ? 1 : result
    }
    
    private var alphabetRows: [[(letter: String, value: Int)]] {
        [
            [("A", 1), ("B", 2), ("C", 3), ("D", 4), ("E", 5), ("F", 6), ("G", 7), ("H", 8), ("I", 9)],
            [("J", 1), ("K", 2), ("L", 3), ("M", 4), ("N", 5), ("O", 6), ("P", 7), ("Q", 8), ("R", 9)],
            [("S", 1), ("T", 2), ("U", 3), ("V", 4), ("W", 5), ("X", 6), ("Y", 7), ("Z", 8)]
        ]
    }
    
    // MARK: - Number Meanings
    private func expressionMeaning(for number: Int) -> String {
        let meanings = [
            1: "Leadership, independence, innovation",
            2: "Cooperation, diplomacy, sensitivity",
            3: "Creativity, communication, joy",
            4: "Stability, practicality, hard work",
            5: "Freedom, adventure, versatility",
            6: "Responsibility, nurturing, harmony",
            7: "Analysis, spirituality, wisdom",
            8: "Power, success, material abundance",
            9: "Compassion, humanitarianism, completion",
            11: "Intuition, illumination, spiritual insight (Master Number)",
            22: "Master builder, practical idealism (Master Number)",
            33: "Master teacher, compassionate guidance (Master Number)"
        ]
        return meanings[number] ?? "Unique spiritual journey"
    }
    
    private func soulUrgeMeaning(for number: Int) -> String {
        let meanings = [
            1: "Desire to lead and be independent",
            2: "Longing for peace and partnership",
            3: "Yearning for creative self-expression",
            4: "Need for order and stability",
            5: "Craving freedom and new experiences",
            6: "Desire to serve and nurture others",
            7: "Seeking truth and inner wisdom",
            8: "Drive for success and recognition",
            9: "Urge to help humanity and heal",
            11: "Deep intuitive and spiritual needs (Master Number)",
            22: "Vision to create lasting legacy (Master Number)",
            33: "Calling to uplift and teach others (Master Number)"
        ]
        return meanings[number] ?? "Deep spiritual desires"
    }
    
    private func personalityMeaning(for number: Int) -> String {
        let meanings = [
            1: "Confident, ambitious, natural leader",
            2: "Gentle, diplomatic, easy-going",
            3: "Charming, creative, social butterfly",
            4: "Reliable, organized, trustworthy",
            5: "Dynamic, adventurous, magnetic",
            6: "Caring, responsible, family-oriented",
            7: "Mysterious, intellectual, reserved",
            8: "Authoritative, professional, capable",
            9: "Warm, compassionate, charismatic",
            11: "Inspiring, intuitive, spiritual presence (Master Number)",
            22: "Visionary, powerful, influential (Master Number)",
            33: "Nurturing, wise, beloved by many (Master Number)"
        ]
        return meanings[number] ?? "Unique and intriguing presence"
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlightPrimary)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.starlightTertiary)
        }
    }
}

struct LetterCard: View {
    let letter: String
    let value: Int
    let isVowel: Bool
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(letter)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.starlightPrimary)
            
            Text("\(value)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isVowel ? Color(hex: "FF6B9D") : Color(hex: "4ECDC4"))
        }
        .frame(width: 56, height: 72)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cosmicBlackElevated.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isVowel ? Color(hex: "FF6B9D").opacity(0.3) : Color(hex: "4ECDC4").opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

struct SoundTypeCard: View {
    let title: String
    let subtitle: String
    let letters: [(letter: String, value: Int)]
    let color: Color
    let icon: String
    let delay: Double
    
    @State private var isVisible = false
    
    var sum: Int {
        letters.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.starlightPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
            }
            
            if letters.isEmpty {
                Text("No \(title.lowercased()) in name")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightQuaternary)
                    .padding(.vertical, 8)
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(letters, id: \.letter) { item in
                        HStack(spacing: 2) {
                            Text(item.letter)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("\(item.value)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.15))
                        )
                        .foregroundColor(.starlightPrimary)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    Text("Sum: \(sum)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.starlightSecondary)
                    
                    Spacer()
                    
                    Text("→ \(reduceToSingleDigit(sum))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cosmicBlackElevated.opacity(0.5))
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 && result != 11 && result != 22 && result != 33 {
            result = String(result).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return result == 0 ? 1 : result
    }
}

struct NumberCard: View {
    let title: String
    let number: Int
    let subtitle: String
    let description: String
    let color: Color
    let icon: String
    let delay: Double
    
    @State private var isVisible = false
    @State private var animatedNumber = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.starlightPrimary)
                }
                
                Spacer()
                
                // Number Badge
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .fill(color.opacity(0.4))
                        .frame(width: 40, height: 40)
                    
                    Text("\(animatedNumber)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.starlightPrimary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cosmicBlackElevated.opacity(0.5))
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
            
            // Animate number counting
            let duration = 0.8
            let steps = 20
            let stepDuration = duration / Double(steps)
            
            for i in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + (Double(i) * stepDuration)) {
                    animatedNumber = (number * i) / steps
                }
            }
        }
    }
}

struct ChartCell: View {
    let letter: String
    let value: Int
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(letter)
                .font(.system(size: 14, weight: isHighlighted ? .bold : .medium))
            
            Text("\(value)")
                .font(.system(size: 11, weight: .semibold))
        }
        .frame(width: 36, height: 44)
        .foregroundColor(isHighlighted ? .goldPrimary : .starlightTertiary)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color.goldPrimary.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHighlighted ? Color.goldPrimary.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

struct EducationCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.starlightPrimary)
                
                Text(content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cosmicBlackElevated.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

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
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
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
                
                if x + size.width > maxWidth && x > 0 {
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

// MARK: - Saved Analysis Model
struct SavedAnalysis: Identifiable, Codable {
    let id: UUID
    let name: String
    let expressionNumber: Int
    let soulUrgeNumber: Int
    let personalityNumber: Int
    let date: Date
}

// MARK: - Haptic Helper
enum QXHaptic {
    static func lightImpact() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    static func mediumImpact() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    static func success() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
}

// MARK: - Preview
struct NameAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NameAnalysisView()
            .preferredColorScheme(.dark)
    }
}
