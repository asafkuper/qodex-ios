//
//  EnhancedAppClip.swift
//  QodeX App Clip - Full Featured Lightweight Experience
//

import SwiftUI

// MARK: - Enhanced App Clip Experience
struct EnhancedAppClipRootView: View {
    @StateObject private var calculator = AppClipCalculator()
    @State private var selectedTab = 0
    @State private var showFullAppPrompt = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Quick Calculate
            QuickCalculateView(calculator: calculator)
                .tabItem {
                    Label("Calculate", systemImage: "number.circle.fill")
                }
                .tag(0)
            
            // Tab 2: Daily Number
            DailyNumberClipView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(1)
            
            // Tab 3: Learn
            LearnNumbersView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(2)
        }
        .accentColor(.gold)
        .overlay(
            FullAppBanner(showPrompt: $showFullAppPrompt)
                .padding(.bottom, 80)
            , alignment: .bottom
        )
    }
}

// MARK: - Quick Calculate View
struct QuickCalculateView: View {
    @ObservedObject var calculator: AppClipCalculator
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var showResult = false
    
    let numberMeanings: [Int: String] = [
        1: "Leader • Independent • Innovative",
        2: "Diplomat • Intuitive • Harmonious",
        3: "Creative • Communicative • Optimistic",
        4: "Practical • Disciplined • Reliable",
        5: "Adventurous • Flexible • Freedom-loving",
        6: "Nurturing • Responsible • Family-oriented",
        7: "Analytical • Spiritual • Seeker of truth",
        8: "Ambitious • Powerful • Material success",
        9: "Compassionate • Humanitarian • Completion"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gold)
                    
                    Text("Life Path Calculator")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Input Section
                VStack(spacing: 16) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.name)
                            .accessibilityLabel("Enter your full name")
                    }
                    
                    // Birth Date Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("",
                                  selection: $birthDate,
                                  displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(height: 150)
                            .accessibilityLabel("Select your birth date")
                    }
                }
                .padding(.horizontal)
                
                // Calculate Button
                Button(action: calculate) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Calculate My Number")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.gold)
                    .cornerRadius(16)
                }
                .disabled(name.isEmpty)
                .padding(.horizontal)
                
                // Result Card
                if showResult, let lifePath = calculator.lifePathNumber {
                    ResultCard(
                        lifePath: lifePath,
                        meaning: numberMeanings[lifePath] ?? "Unique path",
                        name: name
                    )
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func calculate() {
        calculator.calculateLifePath(from: birthDate)
        withAnimation(.spring()) {
            showResult = true
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Result Card
struct ResultCard: View {
    let lifePath: Int
    let meaning: String
    let name: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Number Display
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.gold.opacity(0.3), .gold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("\(lifePath)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.gold)
            }
            
            VStack(spacing: 8) {
                Text("\(name)'s Life Path")
                    .font(.headline)
                
                Text(meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Share Button
            ShareLink(item: "My Life Path Number is \(lifePath)! Discover yours with QodeX.") {
                Label("Share Result", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Daily Number View
struct DailyNumberClipView: View {
    @State private var universalDay = Calendar.current.component(.day, from: Date()) % 9 + 1
    
    let dayMeanings: [Int: (theme: String, advice: String)] = [
        1: ("New Beginnings", "Start something new today. Take the lead."),
        2: ("Cooperation", "Work with others. Trust your intuition."),
        3: ("Creativity", "Express yourself. Socialize and enjoy."),
        4: ("Stability", "Build foundations. Organize and plan."),
        5: ("Change", "Embrace freedom. Try something different."),
        6: ("Responsibility", "Focus on family. Create harmony."),
        7: ("Reflection", "Go within. Seek knowledge and truth."),
        8: ("Power", "Take charge. Focus on goals and success."),
        9: ("Completion", "Let go of what no longer serves you.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Today's Universal Day")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(Date(), style: .date)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Daily Number Card
                if let meaning = dayMeanings[universalDay] {
                    VStack(spacing: 20) {
                        // Large Number
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.gold, .purple, .blue, .gold],
                                        center: .center
                                    )
                                    .opacity(0.2)
                                )
                                .frame(width: 140, height: 140)
                            
                            Text("\(universalDay)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.gold, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        
                        VStack(spacing: 12) {
                            Text(meaning.theme)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(meaning.advice)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
                    )
                    .padding(.horizontal)
                }
                
                // Mini Reading
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Guidance")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    GuidanceRow(icon: "sunrise.fill", color: .orange, title: "Morning", text: "Start with intention")
                    GuidanceRow(icon: "sun.max.fill", color: .yellow, title: "Afternoon", text: "Take inspired action")
                    GuidanceRow(icon: "moon.fill", color: .purple, title: "Evening", title: "Reflect and release")
                }
                .padding(.vertical)
                
                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - Guidance Row
struct GuidanceRow: View {
    let icon: String
    let color: Color
    let title: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Learn Numbers View
struct LearnNumbersView: View {
    let numbers = Array(1...9)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Discover Numerology")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Each number carries unique energy and meaning")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(numbers, id: \.self) { number in
                        NumberLearnCard(number: number)
                    }
                }
                .padding(.horizontal)
                
                // CTA
                VStack(spacing: 12) {
                    Text("Want your complete chart?")
                        .font(.headline)
                    
                    Text("The full app includes personalized daily readings, compatibility analysis, and more.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Number Learn Card
struct NumberLearnCard: View {
    let number: Int
    
    let titles: [Int: String] = [
        1: "Leader", 2: "Diplomat", 3: "Creative",
        4: "Builder", 5: "Adventurer", 6: "Nurturer",
        7: "Seeker", 8: "Powerhouse", 9: "Humanitarian"
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.gold)
            
            Text(titles[number] ?? "")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Full App Banner
struct FullAppBanner: View {
    @Binding var showPrompt: Bool
    
    var body: some View {
        Button(action: { showPrompt = true }) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock Full Experience")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Daily readings • Full chart • Widgets")
                        .font(.caption)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
            }
            .foregroundColor(.black)
            .padding()
            .background(
                LinearGradient(
                    colors: [.gold, .orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .gold.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}

// MARK: - Calculator View Model
class AppClipCalculator: ObservableObject {
    @Published var lifePathNumber: Int?
    
    func calculateLifePath(from birthDate: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return
        }
        
        // Calculate life path number
        let sum = reduceToSingleDigit(day) + reduceToSingleDigit(month) + reduceToSingleDigit(year)
        lifePathNumber = reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 {
            n = String(n).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return n == 0 ? 1 : n
    }
}

// MARK: - Preview
#Preview("Enhanced App Clip") {
    EnhancedAppClipRootView()
}
