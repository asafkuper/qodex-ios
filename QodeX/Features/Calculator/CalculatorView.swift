import SwiftUI

struct CalculatorView: View {
    @State private var birthDate = Date()
    @State private var fullName = ""
    @State private var showResults = false
    @State private var calculatedNumbers: QodeNumbers?
    
    var body: some View {
        ScrollView {
            VStack(spacing: QXSpacing.xl) {
                // Header
                VStack(spacing: QXSpacing.sm) {
                    Text("Qode Calculator")
                        .font(QXFont.displayMedium)
                        .foregroundColor(QXColor.starlight)
                        .accessibilityLabel("Qode Calculator")
                        .accessibilityHint("Numerology calculator to discover your energetic blueprint")
                    
                    Text("Discover your energetic blueprint")
                        .font(QXFont.body)
                        .foregroundColor(QXColor.starlight.opacity(0.6))
                        .accessibilityLabel("Discover your energetic blueprint")
                }
                .padding(.top)
                
                // Input Section
                GlassCard {
                    VStack(spacing: QXSpacing.lg) {
                        // Birth Date
                        VStack(alignment: .leading, spacing: QXSpacing.sm) {
                            Text("Birth Date")
                                .font(QXFont.headline)
                                .foregroundColor(QXColor.starlight)
                                .accessibilityLabel("Birth Date")
                            
                            DatePicker(
                                "",
                                selection: $birthDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .colorMultiply(QXColor.gold)
                            .labelsHidden()
                            .accessibilityLabel("Birth Date Picker")
                            .accessibilityHint("Select your birth date for numerology calculation")
                        }
                        
                        Divider()
                            .background(QXColor.gold.opacity(0.2))
                        
                        // Full Name
                        VStack(alignment: .leading, spacing: QXSpacing.sm) {
                            Text("Full Birth Name")
                                .font(QXFont.headline)
                                .foregroundColor(QXColor.starlight)
                                .accessibilityLabel("Full Birth Name")
                            
                            TextField("As written on birth certificate", text: $fullName)
                                .textFieldStyle(QodeXTextFieldStyle())
                                .textInputAutocapitalization(.words)
                                .accessibilityLabel("Full Birth Name Input")
                                .accessibilityHint("Enter your full birth name as written on your birth certificate")
                        }
                        
                        QXButton(
                            title: "Decode My Qode",
                            icon: "sparkles",
                            style: .gold
                        ) {
                            calculateQode()
                        }
                        .disabled(fullName.isEmpty)
                        .opacity(fullName.isEmpty ? 0.6 : 1)
                        .accessibilityLabel("Decode My Qode")
                        .accessibilityHint("Calculate your numerology numbers based on your birth date and name")
                    }
                }
                .padding(.horizontal)
                
                // Results Section
                if let numbers = calculatedNumbers {
                    ResultsView(numbers: numbers)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: QXSpacing.xxl)
            }
        }
        .background(SacredGeometryBackground())
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func calculateQode() {
        // Simplified calculation for demo
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        let lifePath = calculateLifePath(day: components.day ?? 1, month: components.month ?? 1, year: components.year ?? 2000)
        let expression = calculateExpressionNumber(from: fullName)
        let soulUrge = calculateSoulUrge(from: fullName)
        let personality = calculatePersonality(from: fullName)
        
        calculatedNumbers = QodeNumbers(
            lifePath: lifePath,
            expression: expression,
            soulUrge: soulUrge,
            personality: personality,
            birthday: components.day ?? 1,
            personalYear: calculatePersonalYear(currentYear: calendar.component(.year, from: Date()), birthMonth: components.month ?? 1, birthDay: components.day ?? 1)
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showResults = true
        }
    }
    
    private func calculateLifePath(day: Int, month: Int, year: Int) -> Int {
        let sum = reduceToSingleDigit(day) + reduceToSingleDigit(month) + reduceToSingleDigit(year)
        return reduceToSingleDigit(sum)
    }
    
    private func calculateExpressionNumber(from name: String) -> Int {
        let sum = name.lowercased().unicodeScalars
            .filter { $0.isLetter }
            .reduce(0) { sum, char in
                sum + (Int(char.value) - 96)
            }
        return reduceToSingleDigit(sum)
    }
    
    private func calculateSoulUrge(from name: String) -> Int {
        let vowels = "aeiou"
        let sum = name.lowercased().unicodeScalars
            .filter { vowels.contains(String($0)) }
            .reduce(0) { sum, char in
                sum + (Int(char.value) - 96)
            }
        return reduceToSingleDigit(sum)
    }
    
    private func calculatePersonality(from name: String) -> Int {
        let vowels = "aeiou"
        let sum = name.lowercased().unicodeScalars
            .filter { !vowels.contains(String($0)) && $0.isLetter }
            .reduce(0) { sum, char in
                sum + (Int(char.value) - 96)
            }
        return reduceToSingleDigit(sum)
    }
    
    private func calculatePersonalYear(currentYear: Int, birthMonth: Int, birthDay: Int) -> Int {
        let sum = reduceToSingleDigit(currentYear) + reduceToSingleDigit(birthMonth) + reduceToSingleDigit(birthDay)
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 && n != 11 && n != 22 && n != 33 {
            n = String(n).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return n == 0 ? 1 : n
    }
}

struct QodeNumbers {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let birthday: Int
    let personalYear: Int
}

struct ResultsView: View {
    let numbers: QodeNumbers
    
    var body: some View {
        VStack(spacing: QXSpacing.lg) {
            Text("Your Qode Matrix")
                .font(QXFont.title)
                .foregroundColor(QXColor.starlight)
                .accessibilityLabel("Your Qode Matrix")
                .accessibilityHint("Your calculated numerology results")
            
            // Core Numbers Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: QXSpacing.md) {
                NumberCard(
                    number: numbers.lifePath,
                    title: "Life Path",
                    description: "Your journey's purpose",
                    isMaster: [11, 22, 33].contains(numbers.lifePath)
                )
                .accessibilityLabel("Life Path Number \(numbers.lifePath)")
                .accessibilityHint("Your life's purpose and journey path")
                
                NumberCard(
                    number: numbers.expression,
                    title: "Expression",
                    description: "Your natural talents",
                    isMaster: [11, 22, 33].contains(numbers.expression)
                )
                .accessibilityLabel("Expression Number \(numbers.expression)")
                .accessibilityHint("Your natural talents and abilities")
                
                NumberCard(
                    number: numbers.soulUrge,
                    title: "Soul Urge",
                    description: "Your heart's desire",
                    isMaster: [11, 22, 33].contains(numbers.soulUrge)
                )
                .accessibilityLabel("Soul Urge Number \(numbers.soulUrge)")
                .accessibilityHint("Your inner desires and motivations")
                
                NumberCard(
                    number: numbers.personality,
                    title: "Personality",
                    description: "How others see you",
                    isMaster: [11, 22, 33].contains(numbers.personality)
                )
                .accessibilityLabel("Personality Number \(numbers.personality)")
                .accessibilityHint("How others perceive you")
            }
            
            // Additional Numbers
            HStack(spacing: QXSpacing.lg) {
                SmallNumberCard(number: numbers.birthday, title: "Birth Day")
                    .accessibilityLabel("Birth Day Number \(numbers.birthday)")
                    .accessibilityHint("Your birth day number")
                
                SmallNumberCard(number: numbers.personalYear, title: "Personal Year")
                    .accessibilityLabel("Personal Year Number \(numbers.personalYear)")
                    .accessibilityHint("Your current personal year number")
            }
            
            // Save Button
            QXButton(title: "Save to Profile", icon: "arrow.down.circle", style: .secondary) {}
                .accessibilityLabel("Save to Profile")
                .accessibilityHint("Save these numerology results to your profile")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(QXColor.deepVoid.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct NumberCard: View {
    let number: Int
    let title: String
    let description: String
    let isMaster: Bool
    
    var body: some View {
        VStack(spacing: QXSpacing.sm) {
            Text("\(number)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(isMaster ? QXColor.gold : QXColor.starlight)
                .shadow(color: isMaster ? QXColor.gold.opacity(0.5) : .clear, radius: isMaster ? 15 : 0)
                .accessibilityLabel("\(number)")
            
            Text(title)
                .font(QXFont.headline)
                .foregroundColor(QXColor.starlight)
                .accessibilityLabel(title)
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(QXColor.starlight.opacity(0.5))
                .multilineTextAlignment(.center)
                .accessibilityLabel(description)
            
            if isMaster {
                Text("MASTER")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(QXColor.gold)
                    .padding(.horizontal, QXSpacing.sm)
                    .padding(.vertical, QXSpacing.xs)
                    .background(QXColor.gold.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityLabel("Master Number")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(QXColor.sacredGeometry.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isMaster ? QXColor.gold.opacity(0.4) : QXColor.gold.opacity(0.1), lineWidth: isMaster ? 2 : 1)
        )
    }
}

struct SmallNumberCard: View {
    let number: Int
    let title: String
    
    var body: some View {
        VStack(spacing: QXSpacing.xs) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(QXColor.starlight)
                .accessibilityLabel("\(number)")
            
            Text(title)
                .font(QXFont.caption)
                .foregroundColor(QXColor.starlight.opacity(0.6))
                .accessibilityLabel(title)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(QXColor.sacredGeometry.opacity(0.3))
        .cornerRadius(12)
    }
}

struct QodeXTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_self._Label>) -> some View {
        configuration
            .padding(QXSpacing.md)
            .background(QXColor.sacredGeometry)
            .cornerRadius(12)
            .foregroundColor(QXColor.starlight)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    CalculatorView()
}
