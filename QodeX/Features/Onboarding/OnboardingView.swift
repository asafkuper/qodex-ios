//
//  OnboardingView.swift
//  QodeX
//
//  A world-class onboarding experience inspired by Linear, Craft, and Arc Browser
//  Glassmorphism • Cosmic Theme • Fluid Animations
//

import SwiftUI
import Combine

// MARK: - Onboarding Step Enum
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case name = 1
    case birthdate = 2
    case chartPreview = 3
    case complete = 4
    
    var title: String {
        switch self {
        case .welcome: return "Welcome to QodeX"
        case .name: return "What should we call you?"
        case .birthdate: return "When were you born?"
        case .chartPreview: return "Your Cosmic Blueprint"
        case .complete: return "You're all set"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "Discover the patterns that shape your journey through the stars."
        case .name: return "This helps us personalize your cosmic insights."
        case .birthdate: return "Your birth chart reveals your unique celestial fingerprint."
        case .chartPreview: return "Based on your birth details, this is your unique configuration."
        case .complete: return "Your cosmic journey begins now."
        }
    }
}

// MARK: - Onboarding View Model
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userName: String = ""
    @Published var birthDate: Date = Date()
    @Published var isAnimating: Bool = false
    @Published var showCelebration: Bool = false
    
    let minDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())!
    let maxDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome: return true
        case .name: return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        case .birthdate: return true
        case .chartPreview: return true
        case .complete: return true
        }
    }
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep = next
        }
        if next == .complete {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showCelebration = true
            }
        }
    }
    
    func previousStep() {
        guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1),
              prev.rawValue >= 0 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep = prev
        }
    }
    
    func goToStep(_ step: OnboardingStep) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep = step
        }
    }
    
    private func completeOnboarding() {
        // Handle onboarding completion
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var cosmicRotation: Double = 0
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // MARK: Cosmic Background
            CosmicBackground(
                rotation: $cosmicRotation,
                floatingOffset: $floatingOffset
            )
            .ignoresSafeArea()
            
            // MARK: Main Content
            VStack(spacing: 0) {
                // Progress Header
                OnboardingProgressHeader(
                    currentStep: viewModel.currentStep,
                    progress: viewModel.progress
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Step Content with Gestures
                GeometryReader { geometry in
                    ZStack {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            StepContainer(
                                step: step,
                                currentStep: viewModel.currentStep,
                                geometry: geometry
                            ) {
                                stepContent(for: step)
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                let threshold: CGFloat = 50
                                if gesture.translation.width < -threshold && viewModel.canProceed {
                                    viewModel.nextStep()
                                } else if gesture.translation.width > threshold {
                                    viewModel.previousStep()
                                }
                            }
                    )
                }
                
                // Navigation Footer
                OnboardingNavigationFooter(
                    viewModel: viewModel
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            
            // Celebration Overlay
            if viewModel.showCelebration {
                CelebrationView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                cosmicRotation = 360
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                floatingOffset = 20
            }
        }
    }
    
    @ViewBuilder
    private func stepContent(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomeStepView()
        case .name:
            NameStepView(viewModel: viewModel)
        case .birthdate:
            BirthdateStepView(viewModel: viewModel)
        case .chartPreview:
            ChartPreviewStepView(viewModel: viewModel)
        case .complete:
            CompleteStepView(viewModel: viewModel)
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    @Binding var rotation: Double
    @Binding var floatingOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Deep space gradient
            LinearGradient(
                colors: [
                    Color(hex: "0D0D1A"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated nebula effect
            GeometryReader { geo in
                ZStack {
                    // Central glow
                    RadialGradient(
                        colors: [
                            Color(hex: "E5C158").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.6
                    )
                    .offset(y: floatingOffset)
                    
                    // Floating orbs
                    ForEach(0..<5) { i in
                        FloatingOrb(
                            index: i,
                            totalCount: 5,
                            size: geo.size
                        )
                    }
                    
                    // Rotating star field
                    StarField(rotation: rotation)
                        .opacity(0.6)
                }
            }
        }
    }
}

// MARK: - Floating Orb
struct FloatingOrb: View {
    let index: Int
    let totalCount: Int
    let size: CGSize
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1
    
    var body: some View {
        let angle = (Double(index) / Double(totalCount)) * 2 * .pi
        let radius = min(size.width, size.height) * 0.35
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(hex: "E5C158").opacity(0.3 - Double(index) * 0.04),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 60
                )
            )
            .frame(width: 120, height: 120)
            .blur(radius: 20)
            .offset(x: x + offset.width, y: y + offset.height)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.5)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -30...30)
                    )
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// MARK: - Star Field
struct StarField: View {
    let rotation: Double
    
    var body: some View {
        Canvas { context, size in
            let starCount = 100
            for i in 0..<starCount {
                let angle = Double(i) / Double(starCount) * 2 * .pi + (rotation * .pi / 180)
                let distance = Double.random(in: 50...min(size.width, size.height) / 2)
                let x = size.width / 2 + cos(angle) * distance
                let y = size.height / 2 + sin(angle) * distance
                let starSize = CGFloat.random(in: 1...3)
                
                var path = Path()
                path.addEllipse(in: CGRect(x: x - starSize/2, y: y - starSize/2, width: starSize, height: starSize))
                context.fill(path, with: .color(.white.opacity(Double.random(in: 0.3...0.9))))
            }
        }
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Progress Header
struct OnboardingProgressHeader: View {
    let currentStep: OnboardingStep
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Step Indicators
            HStack(spacing: 12) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    StepIndicator(
                        step: step,
                        currentStep: currentStep
                    )
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "E5C158"),
                                    Color(hex: "F4D03F")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let step: OnboardingStep
    let currentStep: OnboardingStep
    
    private var state: StepState {
        if step.rawValue < currentStep.rawValue {
            return .completed
        } else if step.rawValue == currentStep.rawValue {
            return .current
        } else {
            return .upcoming
        }
    }
    
    enum StepState {
        case completed, current, upcoming
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 28, height: 28)
            
            if state == .completed {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            } else {
                Text("\(step.rawValue + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(foregroundColor)
            }
        }
        .overlay(
            Circle()
                .stroke(
                    state == .current ? Color(hex: "E5C158") : Color.clear,
                    lineWidth: 2
                )
                .frame(width: 32, height: 32)
        )
        .scaleEffect(state == .current ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: state)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .completed:
            return Color(hex: "E5C158")
        case .current:
            return Color.white.opacity(0.15)
        case .upcoming:
            return Color.white.opacity(0.05)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .completed:
            return .black
        case .current:
            return Color(hex: "E5C158")
        case .upcoming:
            return Color.white.opacity(0.4)
        }
    }
}

// MARK: - Step Container
struct StepContainer<Content: View>: View {
    let step: OnboardingStep
    let currentStep: OnboardingStep
    let geometry: GeometryProxy
    @ViewBuilder let content: Content
    
    private var offset: CGFloat {
        let stepWidth = geometry.size.width + 40
        return CGFloat(step.rawValue - currentStep.rawValue) * stepWidth
    }
    
    private var opacity: Double {
        abs(step.rawValue - currentStep.rawValue) > 1 ? 0 : 1
    }
    
    private var scale: CGFloat {
        step == currentStep ? 1 : 0.9
    }
    
    var body: some View {
        content
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(x: offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentStep)
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphismCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.7)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 30,
                x: 0,
                y: 15
            )
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = -10
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated App Icon
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            Color(hex: "E5C158").opacity(0.3 - Double(i) * 0.08),
                            lineWidth: 1
                        )
                        .frame(width: 140 + CGFloat(i) * 30, height: 140 + CGFloat(i) * 30)
                        .scaleEffect(iconScale + CGFloat(i) * 0.1)
                }
                
                // Main icon container
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "E5C158"),
                                Color(hex: "D4A818")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(iconRotation))
                    )
                    .shadow(
                        color: Color(hex: "E5C158").opacity(0.5),
                        radius: 30,
                        x: 0,
                        y: 10
                    )
            }
            .scaleEffect(iconScale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    iconScale = 1
                    iconRotation = 0
                }
            }
            
            // Text content
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Text("QodeX")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .overlay(
                        Text("QodeX")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "E5C158").opacity(0.3))
                            .offset(x: 2, y: 2)
                    )
            }
            
            Text("Discover the patterns that shape your journey through the stars. Unlock insights about your personality, relationships, and destiny.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isNameFocused: Bool
    @State private var textFieldShake: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "E5C158").opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "E5C158"))
            }
            
            // Title
            Text("What should we call you?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("This helps us personalize your cosmic insights and readings.")
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Glassmorphism Input Card
            GlassmorphismCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("YOUR NAME")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "E5C158"))
                        .tracking(1.5)
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(Color.white.opacity(0.5))
                        
                        TextField("", text: $viewModel.userName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .placeholder(when: viewModel.userName.isEmpty) {
                                Text("Enter your name")
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                            .focused($isNameFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .accessibilityLabel("Your name")
                            .accessibilityHint("Enter your full name for personalized readings")
                        
                        if !viewModel.userName.isEmpty {
                            Button {
                                viewModel.userName = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                            .accessibilityLabel("Clear name")
                            .accessibilityHint("Clear the name field")
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Rectangle()
                        .fill(
                            isNameFocused
                            ? Color(hex: "E5C158")
                            : Color.white.opacity(0.2)
                        )
                        .frame(height: 1)
                        .animation(.easeInOut(duration: 0.2), value: isNameFocused)
                }
            }
            .padding(.horizontal, 20)
            .offset(x: textFieldShake)
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Birthdate Step
struct BirthdateStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "E5C158").opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "calendar")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "E5C158"))
            }
            
            // Title
            Text("When were you born?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Your birth chart reveals your unique celestial fingerprint and cosmic influences.")
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Date Picker Card
            GlassmorphismCard {
                VStack(spacing: 16) {
                    // Zodiac sign display
                    HStack(spacing: 12) {
                        Image(systemName: zodiacIcon)
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "E5C158"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(zodiacSign)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your Sun Sign")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Date picker
                    DatePicker(
                        "",
                        selection: $viewModel.birthDate,
                        in: viewModel.minDate...viewModel.maxDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .colorMultiply(Color(hex: "E5C158"))
                    .frame(height: 180)
                    .labelsHidden()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private var zodiacSign: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: viewModel.birthDate)
        let day = calendar.component(.day, from: viewModel.birthDate)
        
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "Aries"
        case (4, 20...30), (5, 1...20): return "Taurus"
        case (5, 21...31), (6, 1...20): return "Gemini"
        case (6, 21...30), (7, 1...22): return "Cancer"
        case (7, 23...31), (8, 1...22): return "Leo"
        case (8, 23...31), (9, 1...22): return "Virgo"
        case (9, 23...30), (10, 1...22): return "Libra"
        case (10, 23...31), (11, 1...21): return "Scorpio"
        case (11, 22...30), (12, 1...21): return "Sagittarius"
        case (12, 22...31), (1, 1...19): return "Capricorn"
        case (1, 20...31), (2, 1...18): return "Aquarius"
        default: return "Pisces"
        }
    }
    
    private var zodiacIcon: String {
        switch zodiacSign {
        case "Aries": return "arrow.up.forward"
        case "Taurus": return "ant.fill"
        case "Gemini": return "person.2.fill"
        case "Cancer": return " crab.fill"
        case "Leo": return "crown.fill"
        case "Virgo": return "leaf.fill"
        case "Libra": return "scale.3d"
        case "Scorpio": return "bolt.fill"
        case "Sagittarius": return "arrow.up.forward.circle.fill"
        case "Capricorn": return "mountain.2.fill"
        case "Aquarius": return "drop.fill"
        default: return "fish.fill"
        }
    }
}

// MARK: - Chart Preview Step
struct ChartPreviewStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var chartRotation: Double = 0
    @State private var pulseScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Title
            Text("Your Cosmic Blueprint")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Based on your birth details, this is your unique celestial configuration.")
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Animated Chart Preview
            ZStack {
                // Outer rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            Color(hex: "E5C158").opacity(0.2 - Double(i) * 0.05),
                            lineWidth: 1
                        )
                        .frame(width: 200 + CGFloat(i) * 40, height: 200 + CGFloat(i) * 40)
                        .rotationEffect(.degrees(chartRotation * Double(i + 1) * 0.5))
                }
                
                // Central chart
                ZStack {
                    // Background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "1A1A2E"),
                                    Color(hex: "0D0D1A")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                    
                    // Chart segments
                    ChartSegments()
                        .stroke(Color(hex: "E5C158").opacity(0.6), lineWidth: 1)
                        .frame(width: 180, height: 180)
                    
                    // Planets
                    ForEach(0..<5) { i in
                        PlanetDot(index: i, total: 5)
                    }
                    
                    // Center star
                    Circle()
                        .fill(Color(hex: "E5C158"))
                        .frame(width: 12, height: 12)
                        .shadow(color: Color(hex: "E5C158").opacity(0.8), radius: 10)
                        .scaleEffect(pulseScale)
                }
                .frame(width: 200, height: 200)
            }
            .onAppear {
                withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                    chartRotation = 360
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                }
            }
            
            // Chart details
            VStack(spacing: 12) {
                DetailRow(icon: "sun.max.fill", title: "Sun Sign", value: "Leo")
                DetailRow(icon: "moon.fill", title: "Moon Sign", value: "Cancer")
                DetailRow(icon: "arrow.up", title: "Rising", value: "Libra")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Chart Segments
struct ChartSegments: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<12 {
            let angle = Double(i) / 12 * 2 * .pi - .pi / 2
            let endX = center.x + cos(angle) * radius
            let endY = center.y + sin(angle) * radius
            path.move(to: center)
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        
        // Add concentric circles
        for i in 1...3 {
            let r = radius * CGFloat(i) / 3
            path.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        }
        
        return path
    }
}

// MARK: - Planet Dot
struct PlanetDot: View {
    let index: Int
    let total: Int
    
    var body: some View {
        let angle = Double(index) / Double(total) * 2 * .pi
        let distance: CGFloat = 60 + CGFloat(index) * 15
        let x = cos(angle) * distance
        let y = sin(angle) * distance
        
        Circle()
            .fill(Color(hex: "E5C158"))
            .frame(width: 8, height: 8)
            .offset(x: x, y: y)
            .shadow(color: Color(hex: "E5C158").opacity(0.6), radius: 4)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "E5C158"))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Complete Step
struct CompleteStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                // Ripple effect
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color(hex: "E5C158").opacity(0.3 - Double(i) * 0.08), lineWidth: 2)
                        .frame(width: 100 + CGFloat(i) * 40, height: 100 + CGFloat(i) * 40)
                        .scaleEffect(scale)
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "E5C158"),
                                Color(hex: "D4A818")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.black)
                    )
                    .shadow(
                        color: Color(hex: "E5C158").opacity(0.5),
                        radius: 30
                    )
                    .scaleEffect(scale)
            }
            
            // Text
            VStack(spacing: 12) {
                Text("You're all set, \(viewModel.userName.isEmpty ? "Explorer" : viewModel.userName)!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Your cosmic journey begins now. Explore your birth chart, daily insights, and personalized guidance.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            
            // Features preview
            VStack(spacing: 16) {
                FeatureItem(icon: "chart.pie.fill", text: "Detailed Birth Chart")
                FeatureItem(icon: "sun.horizon.fill", text: "Daily Cosmic Insights")
                FeatureItem(icon: "heart.fill", text: "Compatibility Readings")
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

// MARK: - Feature Item
struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "E5C158"))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(hex: "E5C158").opacity(0.15))
                )
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Navigation Footer
struct OnboardingNavigationFooter: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Back button
            if viewModel.currentStep != .welcome {
                Button {
                    viewModel.previousStep()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Back")
                .accessibilityHint("Go to previous step")
            }
            
            // Continue button
            Button {
                viewModel.nextStep()
            } label: {
                HStack(spacing: 8) {
                    Text(buttonTitle)
                        .font(.system(size: 18, weight: .semibold))
                    
                    if viewModel.currentStep != .complete {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "E5C158"),
                            Color(hex: "F4D03F")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(
                    color: Color(hex: "E5C158").opacity(0.4),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1 : 0.6)
            .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed)
            .accessibilityLabel(buttonTitle)
            .accessibilityHint(accessibilityHintForStep)
        }
    }
    
    private var buttonTitle: String {
        switch viewModel.currentStep {
        case .welcome: return "Get Started"
        case .name: return "Continue"
        case .birthdate: return "Generate Chart"
        case .chartPreview: return "Continue"
        case .complete: return "Enter QodeX"
        }
    }
    
    private var accessibilityHintForStep: String {
        switch viewModel.currentStep {
        case .welcome: return "Begin your QodeX journey"
        case .name: return "Proceed to birth date entry"
        case .birthdate: return "Generate your numerology chart"
        case .chartPreview: return "Continue to complete onboarding"
        case .complete: return "Start using QodeX"
        }
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var context = context
                    context.translateBy(x: particle.x, y: particle.y)
                    context.rotate(by: .degrees(particle.rotation))
                    
                    let rect = CGRect(x: -particle.size/2, y: -particle.size/2, width: particle.size, height: particle.size)
                    context.fill(Path(rect), with: .color(particle.color))
                }
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles() {
        let colors: [Color] = [
            Color(hex: "E5C158"),
            Color(hex: "F4D03F"),
            Color(hex: "FFF8DC"),
            Color.white
        ]
        
        particles = (0..<100).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                velocityY: CGFloat.random(in: 2...5),
                velocityX: CGFloat.random(in: -1...1),
                rotationSpeed: Double.random(in: -5...5)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].velocityY
                particles[i].x += particles[i].velocityX
                particles[i].rotation += particles[i].rotationSpeed
                
                if particles[i].y > UIScreen.main.bounds.height {
                    particles[i].y = -20
                    particles[i].x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                }
            }
        }
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotation: Double
    var velocityY: CGFloat
    var velocityX: CGFloat
    var rotationSpeed: Double
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extension for Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}
