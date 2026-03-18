//
//  OnboardingV2.swift
//  Revolutionary progressive onboarding
//

import SwiftUI

struct OnboardingV2: View {
    @StateObject private var viewModel = OnboardingV2ViewModel()
    @State private var currentStep: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.cosmicBlack.ignoresSafeArea()
            
            // Animated background
            SacredGeometryBackground()
            
            VStack {
                // Progress
                OnboardingProgressBar(currentStep: currentStep, totalSteps: 4)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                
                // Content
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    NameStep(viewModel: viewModel)
                        .tag(1)
                    
                    BirthDateStep(viewModel: viewModel)
                        .tag(2)
                    
                    IntentionStep(viewModel: viewModel)
                        .tag(3)
                    
                    ChartRevealStep(viewModel: viewModel)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < 4 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text(currentStep == 4 ? "Begin Journey" : "Continue")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.gold)
                        .cornerRadius(16)
                    }
                    .disabled(!canProceed())
                    .opacity(canProceed() ? 1 : 0.6)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 1: return !viewModel.name.isEmpty
        case 2: return viewModel.birthDate != nil
        default: return true
        }
    }
    
    private func completeOnboarding() {
        Task {
            await viewModel.createAccount()
            dismiss()
        }
    }
}

// MARK: - Steps
struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "number.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gold)
                .symbolEffect(.pulse)
            
            Text("Discover Your Numbers")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Uncover the mathematical blueprint of your soul and unlock insights about your destiny, purpose, and path.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "sparkles", text: "Calculate your core numbers")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track daily energy forecasts")
                FeatureRow(icon: "person.2.fill", text: "Connect with mentors")
                FeatureRow(icon: "shield.checkerboard", text: "Your data is private & secure")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct NameStep: View {
    @ObservedObject var viewModel: OnboardingV2ViewModel
    @FocusState private isFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("What should we call you?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your full name as it appears on your birth certificate for the most accurate numerology reading.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Full Name", text: $viewModel.name)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.deepVoid)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
            
            if !viewModel.name.isEmpty {
                Text("✓ We'll calculate your Expression & Soul Urge numbers from this")
                    .font(.caption)
                    .foregroundColor(.gold)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct BirthDateStep: View {
    @ObservedObject var viewModel: OnboardingV2ViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("When were you born?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your birth date holds the key to your Life Path number—your ultimate purpose in this lifetime.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            DatePicker(
                "Birth Date",
                selection: Binding(
                    get: { viewModel.birthDate ?? Date() },
                    set: { viewModel.birthDate = $0 }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 200)
            .padding()
            
            if let date = viewModel.birthDate {
                let lifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: date)
                Text("Life Path Preview: \(lifePath)")
                    .font(.headline)
                    .foregroundColor(.gold)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct IntentionStep: View {
    @ObservedObject var viewModel: OnboardingV2ViewModel
    
    let intentions = [
        ("Personal Growth", "leaf.fill", Color.green),
        ("Relationships", "heart.fill", Color.pink),
        ("Career", "briefcase.fill", Color.blue),
        ("Spiritual", "sparkles", Color.purple),
        ("Health", "bolt.heart.fill", Color.orange)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("What brings you here?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select your primary intention to personalize your experience.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(intentions, id: \.0) { intention in
                    Button(action: {
                        viewModel.intention = intention.0
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: intention.1)
                                .font(.system(size: 32))
                                .foregroundColor(viewModel.intention == intention.0 ? .white : intention.2)
                            
                            Text(intention.0)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(viewModel.intention == intention.0 ? intention.2 : Color.deepVoid)
                        .cornerRadius(16)
                    }
                    .foregroundColor(viewModel.intention == intention.0 ? .white : .primary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct ChartRevealStep: View {
    @ObservedObject var viewModel: OnboardingV2ViewModel
    @State private var showChart = false
    
    var body: some View {
        VStack(spacing: 30) {
            if !showChart {
                Spacer()
                
                ProgressView()
                    .scaleEffect(2)
                
                Text("Calculating your cosmic blueprint...")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
            } else {
                Spacer()
                
                let lifePath = viewModel.calculatedLifePath
                
                Text("\(lifePath)")
                    .font(.system(size: 120, weight: .thin, design: .rounded))
                    .foregroundColor(.gold)
                    .transition(.scale)
                
                Text("Your Life Path Number")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(lifePathDescription(lifePath))
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showChart = true
                    viewModel.calculatedLifePath = NumerologyCalculator().calculateLifePathNumber(
                        birthDate: viewModel.birthDate ?? Date()
                    )
                }
            }
        }
    }
    
    private func lifePathDescription(_ number: Int) -> String {
        let descriptions: [Int: String] = [
            1: "You are a natural leader, driven by independence and innovation.",
            2: "You bring harmony and balance to all your relationships.",
            3: "Creativity and self-expression are your natural gifts.",
            4: "You build strong foundations and value stability.",
            5: "Freedom and adventure fuel your spirit.",
            6: "Your nurturing nature brings healing to others.",
            7: "You seek truth and possess deep spiritual wisdom.",
            8: "You are destined for abundance and achievement.",
            9: "Your compassion serves humanity's greater good."
        ]
        return descriptions[number] ?? "Your path is uniquely yours to discover."
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gold)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps + 1, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.gold : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - ViewModel
class OnboardingV2ViewModel: ObservableObject {
    @Published var name = ""
    @Published var birthDate: Date?
    @Published var intention = ""
    @Published var calculatedLifePath = 0
    
    func createAccount() async {
        // Create account logic
        let user = QodeXUser(
            id: UUID().uuidString,
            email: "", // Will be set during auth
            fullName: name,
            birthDate: birthDate,
            membershipTier: .free
        )
        
        // Save to Firebase
        // Track analytics
        QodeXAnalytics.shared.logOnboardingStep(.completed)
    }
}
