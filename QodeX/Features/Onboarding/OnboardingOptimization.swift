//
//  OnboardingOptimization.swift
//  Streamlined onboarding based on top app benchmarks
//

import SwiftUI

// MARK: - Optimized Onboarding Flow
// Benchmark: Headspace (2 min to value), Duolingo (gamified), Calm (visual)

struct OptimizedOnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep: OnboardingStep = .welcome
    @State private var progress: Double = 0.0
    
    enum OnboardingStep: CaseIterable {
        case welcome
        case name
        case birthDate
        case intention
        case lifePathReveal
        
        var progressValue: Double {
            switch self {
            case .welcome: return 0.0
            case .name: return 0.25
            case .birthDate: return 0.5
            case .intention: return 0.75
            case .lifePathReveal: return 1.0
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .gold))
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            // Content
            ZStack {
                switch currentStep {
                case .welcome:
                    WelcomeStepView(onContinue: { advance(to: .name) })
                case .name:
                    NameStepView(
                        name: $viewModel.name,
                        onContinue: { advance(to: .birthDate) },
                        onSkip: { skipToReveal() }
                    )
                case .birthDate:
                    BirthDateStepView(
                        birthDate: $viewModel.birthDate,
                        onContinue: { advance(to: .intention) },
                        onBack: { goBack(to: .name) }
                    )
                case .intention:
                    IntentionStepView(
                        selectedIntention: $viewModel.intention,
                        onContinue: { advance(to: .lifePathReveal) },
                        onBack: { goBack(to: .birthDate) }
                    )
                case .lifePathReveal:
                    LifePathRevealView(
                        lifePath: viewModel.calculatedLifePath,
                        onComplete: { completeOnboarding() }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(Color.cosmicBlack)
    }
    
    private func advance(to step: OnboardingStep) {
        withAnimation {
            currentStep = step
            progress = step.progressValue
        }
        
        // Haptic feedback
        HapticStyle.light.trigger()
    }
    
    private func goBack(to step: OnboardingStep) {
        withAnimation {
            currentStep = step
            progress = step.progressValue
        }
    }
    
    private func skipToReveal() {
        // Calculate with demo data
        viewModel.calculateDemoLifePath()
        advance(to: .lifePathReveal)
    }
    
    private func completeOnboarding() {
        Task {
            await viewModel.saveUser()
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    let onContinue: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated logo
            ZStack {
                Circle()
                    .stroke(Color.gold.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)
                
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gold)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 12) {
                Text("Discover Your Numbers")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Unlock the mathematical blueprint of your soul in under 2 minutes")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "sparkles", text: "Calculate your 5 core numbers")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Daily energy forecasts")
                FeatureRow(icon: "person.2.fill", text: "AI-powered mentorship")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onContinue) {
                    HStack {
                        Text("Get Started")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gold)
                    .cornerRadius(16)
                }
                .buttonStyle(PressableButtonStyle())
                
                Text("Free to start • No credit card required")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Binding var name: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    @FocusState private isFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("What's your name?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your full name for the most accurate numerology reading")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 8) {
                TextField("Full Name", text: $name)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.deepVoid)
                    .cornerRadius(12)
                    .focused($isFocused)
                    .submitLabel(.continue)
                    .onSubmit {
                        if !name.isEmpty {
                            onContinue()
                        }
                    }
                
                if !name.isEmpty {
                    Label("We'll calculate your Expression number from this", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gold)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray : Color.gold)
                        .cornerRadius(16)
                }
                .disabled(name.isEmpty)
                .buttonStyle(PressableButtonStyle())
                
                Button("Skip for now", action: onSkip)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

// MARK: - Birth Date Step
struct BirthDateStepView: View {
    @Binding var birthDate: Date
    let onContinue: () -> Void
    let onBack: () -> Void
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("When were you born?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your birth date reveals your Life Path number—your ultimate purpose")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: { showDatePicker = true }) {
                VStack(spacing: 8) {
                    Text(formattedDate(birthDate))
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .foregroundColor(.gold)
                    
                    Text("Tap to change")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(24)
                .background(Color.deepVoid)
                .cornerRadius(16)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(date: $birthDate, isPresented: $showDatePicker)
            }
            
            if let preview = calculatePreview() {
                VStack(spacing: 4) {
                    Text("Life Path Preview")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text("\(preview)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.gold)
                    }
                }
                .padding()
                .background(Color.gold.opacity(0.1))
                .cornerRadius(12)
                .transition(.scale)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.headline)
                        .foregroundColor(.gold)
                        .frame(width: 56, height: 56)
                        .background(Color.deepVoid)
                        .cornerRadius(16)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gold)
                        .cornerRadius(16)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func calculatePreview() -> Int? {
        return NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
}

// MARK: - Supporting Views
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

struct DatePickerSheet: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Birth Date",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button("Done") {
                    isPresented = false
                }
                .buttonStyle(QXPrimaryButtonStyle())
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - View Model
class OnboardingViewModel: ObservableObject {
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var intention = ""
    @Published var calculatedLifePath = 0
    
    func calculateDemoLifePath() {
        calculatedLifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
    }
    
    func saveUser() async {
        // Save to Firebase
    }
}
