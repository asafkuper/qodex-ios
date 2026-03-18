//
//  OnboardingV3_Enhanced.swift
//  QodeX Premium Onboarding with Micro-interactions
//  Reference: Headspace, Duolingo, Robinhood onboarding patterns
//

import SwiftUI

struct OnboardingV3_Enhanced: View {
    @StateObject private var viewModel = OnboardingV3ViewModel()
    @State private var currentStep: Int = 0
    @State private var direction: SlideDirection = .forward
    @State private var showConfetti = false
    @Environment(\.dismiss) private var dismiss
    
    enum SlideDirection {
        case forward, backward
    }
    
    var body: some View {
        ZStack {
            // Animated background
            OnboardingBackground()
            
            VStack(spacing: 0) {
                // Progress bar with animated fill
                OnboardingProgressBar_Enhanced(
                    currentStep: currentStep,
                    totalSteps: 5,
                    direction: direction
                )
                .padding(.horizontal, 40)
                .padding(.top, 60)
                
                // Content with page transitions
                TabView(selection: $currentStep) {
                    WelcomeStep_Enhanced()
                        .tag(0)
                    
                    NameStep_Enhanced(viewModel: viewModel)
                        .tag(1)
                    
                    BirthDateStep_Enhanced(viewModel: viewModel)
                        .tag(2)
                    
                    IntentionStep_Enhanced(viewModel: viewModel)
                        .tag(3)
                    
                    ChartRevealStep_Enhanced(viewModel: viewModel) {
                        completeOnboarding()
                    }
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                
                // Navigation buttons
                NavigationButtons(
                    currentStep: $currentStep,
                    canProceed: canProceed(),
                    isLastStep: currentStep == 4,
                    onBack: { goBack() },
                    onNext: { goNext() }
                )
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            
            // Confetti celebration
            if showConfetti {
                ConfettiView(trigger: true)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: currentStep) { oldValue, newValue in
            direction = newValue > oldValue ? .forward : .backward
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 1: return !viewModel.name.isEmpty && viewModel.name.count >= 2
        case 2: return viewModel.birthDate != nil
        case 3: return !viewModel.intention.isEmpty
        default: return true
        }
    }
    
    private func goBack() {
        guard currentStep > 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep -= 1
        }
        QXHaptic.lightImpact()
    }
    
    private func goNext() {
        guard currentStep < 4 else {
            completeOnboarding()
            return
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep += 1
        }
        QXHaptic.stepComplete()
    }
    
    private func completeOnboarding() {
        showConfetti = true
        QXHaptic.premiumUnlock()
        
        Task {
            await viewModel.createAccount()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
}

// MARK: - Onboarding Background
struct OnboardingBackground: View {
    @State private var rotation: Double = 0
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Base color
            Color.cosmicBlack.ignoresSafeArea()
            
            // Sacred geometry rotating in background
            SacredGeometryBackground()
                .rotationEffect(.degrees(rotation))
                .opacity(0.3)
                .onAppear {
                    withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            // Gradient overlay
            RadialGradient(
                colors: [
                    QXColor.gold.opacity(pulse ? 0.1 : 0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    pulse.toggle()
                }
            }
        }
    }
}

// MARK: - Enhanced Progress Bar
struct OnboardingProgressBar_Enhanced: View {
    let currentStep: Int
    let totalSteps: Int
    let direction: OnboardingV3_Enhanced.SlideDirection
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                        
                        // Fill
                        if step <= currentStep {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [QXColor.gold, QXColor.goldGlow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * fillProgress(for: step))
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(step) * 0.05),
                                    value: currentStep
                                )
                        }
                    }
                }
                .frame(height: 4)
            }
        }
    }
    
    private func fillProgress(for step: Int) -> CGFloat {
        if step < currentStep {
            return 1.0
        } else if step == currentStep {
            return 1.0
        } else {
            return 0.0
        }
    }
}

// MARK: - Welcome Step Enhanced
struct WelcomeStep_Enhanced: View {
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showFeatures = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(QXColor.gold.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(showIcon ? 1 : 0)
                
                // Icon
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(showIcon ? 1 : 0.5)
                    .opacity(showIcon ? 1 : 0)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showIcon = true
                }
            }
            
            // Title with gradient
            GradientText(
                text: "Discover Your Numbers",
                font: .system(size: 32, weight: .bold, design: .rounded),
                gradient: LinearGradient(
                    colors: [QXColor.gold, QXColor.goldGlow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .opacity(showTitle ? 1 : 0)
            .offset(y: showTitle ? 0 : 20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showTitle = true
                    }
                }
            }
            
            // Description
            Text("Uncover the mathematical blueprint of your soul and unlock insights about your destiny, purpose, and path.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(showDescription ? 1 : 0)
                .offset(y: showDescription ? 0 : 20)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showDescription = true
                        }
                    }
                }
            
            // Features with stagger
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow_Enhanced(
                    icon: "sparkles",
                    text: "Calculate your core numbers",
                    delay: 0.6,
                    index: 0
                )
                FeatureRow_Enhanced(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Track daily energy forecasts",
                    delay: 0.6,
                    index: 1
                )
                FeatureRow_Enhanced(
                    icon: "person.2.fill",
                    text: "Connect with mentors",
                    delay: 0.6,
                    index: 2
                )
                FeatureRow_Enhanced(
                    icon: "shield.checkerboard",
                    text: "Your data is private & secure",
                    delay: 0.6,
                    index: 3
                )
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Feature Row Enhanced
struct FeatureRow_Enhanced: View {
    let icon: String
    let text: String
    let delay: Double
    let index: Int
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(QXColor.gold.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(QXColor.gold)
                    .font(.system(size: 16))
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isVisible = true
                }
            }
        }
    }
}

// MARK: - Name Step Enhanced
struct NameStep_Enhanced: View {
    @ObservedObject var viewModel: OnboardingV3ViewModel
    @FocusState private var isFocused: Bool
    @State private var isValid = false
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title with animation
            TypewriterText(text: "What should we call you?", typingSpeed: 0.04)
                .font(.title2)
                .fontWeight(.bold)
                .frame(height: 40)
            
            Text("Enter your full name as it appears on your birth certificate for the most accurate numerology reading.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Enhanced text field
            ZStack(alignment: .trailing) {
                TextField("Full Name", text: $viewModel.name)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(QXColor.deepVoid)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isFocused ? QXColor.gold : Color.clear, lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 24)
                    .focused($isFocused)
                    .onChange(of: viewModel.name) { _, newValue in
                        isValid = newValue.count >= 2
                        if isValid && !showCheckmark {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showCheckmark = true
                            }
                            QXHaptic.success()
                        } else if !isValid {
                            showCheckmark = false
                        }
                    }
                
                // Checkmark
                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(QXColor.success)
                        .padding(.trailing, 36)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Validation message
            if isValid {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                    Text("We'll calculate your Expression & Soul Urge numbers from this")
                        .font(.caption)
                }
                .foregroundColor(QXColor.gold)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

// MARK: - Birth Date Step Enhanced
struct BirthDateStep_Enhanced: View {
    @ObservedObject var viewModel: OnboardingV3ViewModel
    @State private var showPreview = false
    @State private var previewNumber: Int = 0
    
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
            
            // Enhanced date picker
            VStack {
                DatePicker(
                    "Birth Date",
                    selection: Binding(
                        get: { viewModel.birthDate ?? Date() },
                        set: { newDate in
                            viewModel.birthDate = newDate
                            updatePreview()
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(QXColor.deepVoid)
                )
                
                // Life path preview with animation
                if showPreview {
                    HStack(spacing: 12) {
                        Text("Life Path Preview:")
                            .font(.system(size: 15))
                            .foregroundColor(QXColor.stardust)
                        
                        QXNumberCounter(
                            value: previewNumber,
                            duration: 0.8,
                            font: .system(size: 24, weight: .bold, design: .rounded),
                            color: QXColor.gold
                        )
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(QXColor.gold)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(QXColor.gold.opacity(0.1))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func updatePreview() {
        guard let date = viewModel.birthDate else { return }
        let newNumber = NumerologyCalculator().calculateLifePathNumber(birthDate: date)
        
        if previewNumber != newNumber {
            previewNumber = newNumber
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showPreview = true
            }
            QXHaptic.selection()
        }
    }
}

// MARK: - Intention Step Enhanced
struct IntentionStep_Enhanced: View {
    @ObservedObject var viewModel: OnboardingV3ViewModel
    @State private var selectedIndex: Int? = nil
    
    let intentions = [
        ("Personal Growth", "leaf.fill", Color.green),
        ("Relationships", "heart.fill", Color.pink),
        ("Career", "briefcase.fill", Color.blue),
        ("Spiritual", "sparkles", Color.purple),
        ("Health", "bolt.heart.fill", Color.orange),
        ("Creativity", "paintbrush.fill", Color.cyan)
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
            
            // Grid with enhanced selection
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Array(intentions.enumerated()), id: \.offset) { index, intention in
                    let isSelected = viewModel.intention == intention.0
                    
                    QXSelectableCard(
                        isSelected: isSelected,
                        selectionColor: intention.2
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.intention = intention.0
                            selectedIndex = index
                        }
                        QXHaptic.selection()
                    } content: {
                        VStack(spacing: 12) {
                            Image(systemName: intention.1)
                                .font(.system(size: 32))
                                .foregroundColor(isSelected ? .white : intention.2)
                            
                            Text(intention.0)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isSelected ? .white : .white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Chart Reveal Step Enhanced
struct ChartRevealStep_Enhanced: View {
    @ObservedObject var viewModel: OnboardingV3ViewModel
    let onComplete: () -> Void
    
    @State private var showChart = false
    @State private var showDescription = false
    
    var body: some View {
        VStack(spacing: 30) {
            if !showChart {
                Spacer()
                
                // Loading animation
                ZStack {
                    // Outer spinning ring
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(360))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: true)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: QXColor.gold))
                }
                
                Text("Calculating your cosmic blueprint...")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
            } else {
                Spacer()
                
                // Life path reveal with celebration
                QXLifePathReveal(lifePathNumber: viewModel.calculatedLifePath) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                        showDescription = true
                    }
                }
                
                if showDescription {
                    VStack(spacing: 16) {
                        Text("Your Life Path Number")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(lifePathDescription(viewModel.calculatedLifePath))
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        // Traits
                        HStack(spacing: 8) {
                            ForEach(getTraits(for: viewModel.calculatedLifePath), id: \.self) { trait in
                                Text(trait)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(QXColor.gold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(QXColor.gold.opacity(0.15))
                                    )
                            }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            viewModel.calculatedLifePath = NumerologyCalculator().calculateLifePathNumber(
                birthDate: viewModel.birthDate ?? Date()
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showChart = true
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
    
    private func getTraits(for number: Int) -> [String] {
        let traits: [Int: [String]] = [
            1: ["Leader", "Independent"],
            2: ["Harmony", "Diplomat"],
            3: ["Creative", "Expressive"],
            4: ["Stable", "Practical"],
            5: ["Adventurous", "Free"],
            6: ["Nurturing", "Caring"],
            7: ["Wise", "Spiritual"],
            8: ["Powerful", "Abundant"],
            9: ["Compassionate", "Humanitarian"]
        ]
        return traits[number] ?? []
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    @Binding var currentStep: Int
    let canProceed: Bool
    let isLastStep: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep > 0 {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(QXColor.stardust)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(QXColor.deepVoid)
                    )
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Spacer()
            
            // Next/Complete button
            QXBouncyButton(
                title: isLastStep ? "Begin Journey" : "Continue",
                icon: isLastStep ? "sparkles" : "arrow.right"
            ) {
                onNext()
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.6)
        }
    }
}

// MARK: - View Model
class OnboardingV3ViewModel: ObservableObject {
    @Published var name = ""
    @Published var birthDate: Date?
    @Published var intention = ""
    @Published var calculatedLifePath = 0
    
    func createAccount() async {
        // Create account logic
        let user = QodeXUser(
            id: UUID().uuidString,
            email: "",
            fullName: name,
            birthDate: birthDate,
            membershipTier: .free
        )
        
        QodeXAnalytics.shared.logOnboardingStep(.completed)
    }
}

// MARK: - Preview
struct OnboardingV3_Enhanced_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingV3_Enhanced()
            .preferredColorScheme(.dark)
            .withToasts()
    }
}
