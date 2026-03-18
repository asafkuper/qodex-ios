//
//  OnboardingFlowV2.swift
//  QodeX Premium Onboarding
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Enhanced Onboarding Flow

struct OnboardingFlowV2: View {
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var birthDate = Date()
    @State private var birthTime: Date?
    @State private var showTimePicker = false
    @State private var lifePathNumber: Int?
    @State private var hasCompletedOnboarding = false
    @State private var navigationDirection: PageTransitionContainer.PageDirection = .forward
    @State private var isKeyboardVisible = false
    
    private let totalSteps = 5
    
    var body: some View {
        ZStack {
            // Background with mesh gradient effect
            OnboardingBackground()
            
            VStack(spacing: 0) {
                // Progress bar with premium animation
                PremiumProgressBar(current: currentStep, total: totalSteps)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .fadeIn(delay: 0.1)
                
                // Content with smooth transitions
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    NameStep(name: $userName)
                        .tag(1)
                    
                    BirthDateStep(date: $birthDate, showTimePicker: $showTimePicker)
                        .tag(2)
                    
                    BirthTimeStep(date: $birthTime, showPicker: $showTimePicker)
                        .tag(3)
                    
                    ResultsStep(lifePath: calculateLifePath())
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(QXAnimation.pageTransition, value: currentStep)
                
                // Navigation footer
                NavigationFooter(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    canProceed: canProceed(),
                    onNext: { advanceStep() },
                    onBack: { goBack() }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .fadeIn(delay: 0.2)
            }
        }
        .fullScreenCover(isPresented: $hasCompletedOnboarding) {
            MainTabView()
                .transition(.zoom)
        }
        .onChange(of: currentStep) { oldValue, newValue in
            navigationDirection = newValue > oldValue ? .forward : .backward
            // Haptic feedback on step change
            QXHaptic.stepComplete()
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 0: return true
        case 1: return !userName.trimmingCharacters(in: .whitespaces).isEmpty && userName.count >= 2
        case 2: return isValidBirthDate(birthDate)
        case 3: return true
        case 4: return true
        default: return false
        }
    }
    
    private func advanceStep() {
        guard canProceed() else {
            QXHaptic.error()
            return
        }
        
        if currentStep < totalSteps - 1 {
            withAnimation(QXAnimation.pageTransition) {
                currentStep += 1
            }
            // Announce step change for VoiceOver
            VoiceOver.announce("Step \(currentStep + 1) of \(totalSteps)")
        } else {
            completeOnboarding()
        }
    }
    
    private func goBack() {
        guard currentStep > 0 else { return }
        withAnimation(QXAnimation.pageTransition) {
            currentStep -= 1
        }
    }
    
    private func isValidBirthDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Not in future
        if date > now {
            return false
        }
        
        // Not more than 120 years ago
        if let age = calendar.dateComponents([.year], from: date, to: now).year, age > 120 {
            return false
        }
        
        // At least 13 years old
        if let age = calendar.dateComponents([.year], from: date, to: now).year, age < 13 {
            return false
        }
        
        return true
    }
    
    private func completeOnboarding() {
        QXHaptic.premiumUnlock()
        
        // Save onboarding completion securely in Keychain
        _ = KeychainManager.store(true, key: .onboardingCompleted)
        _ = KeychainManager.store(userName, key: .userName)
        
        // Small delay for haptic to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hasCompletedOnboarding = true
        }
    }
    
    private func calculateLifePath() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        guard let day = components.day,
              let month = components.month,
              let year = components.year else { return 1 }
        
        return NumerologyCalculator.shared.calculateLifePath(
            day: day, month: month, year: year
        )
    }
}

// MARK: - Premium Progress Bar

struct PremiumProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(QXColor.starlight.opacity(0.2))
                    .frame(height: 4)
                
                // Progress fill with gradient
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(current + 1) / CGFloat(total),
                        height: 4
                    )
                    .animation(QXAnimation.easeInOut, value: current)
                
                // Step indicators
                HStack(spacing: 0) {
                    ForEach(0..<total, id: \.self) { index in
                        Circle()
                            .fill(index <= current ? QXColor.gold : QXColor.starlight.opacity(0.3))
                            .frame(width: 44, height: 44) // Increased for accessibility
                            .scaleEffect(index == current ? 1.3 : 1.0)
                            .animation(QXAnimation.spring, value: current)
                            .overlay(
                                Circle()
                                    .stroke(index == current ? QXColor.gold : Color.clear, lineWidth: 2)
                            )
                            .accessibilityLabel("Step \(index + 1)")
                            .accessibilityValue(index <= current ? "Completed" : "Not completed")
                            .accessibilityHint(index == current ? "Current step" : "")
                            
                        if index < total - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 44) // Increased height for accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Step \(current + 1) of \(total)")
    }
}

// MARK: - Onboarding Background

struct OnboardingBackground: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    QXColor.cosmicBlack,
                    QXColor.deepVoid,
                    QXColor.cosmicBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated sacred geometry - respects Reduce Motion
            if !UIAccessibility.isReduceMotionEnabled {
                GeometryReader { geo in
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(QXColor.gold.opacity(0.05), lineWidth: 1)
                            .frame(width: geo.size.width * 1.5, height: geo.size.width * 1.5)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 120).repeatForever(autoreverses: false), value: isAnimating)
                        
                        // Middle ring
                        Circle()
                            .stroke(QXColor.gold.opacity(0.08), lineWidth: 1)
                            .frame(width: geo.size.width, height: geo.size.width)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .rotationEffect(.degrees(isAnimating ? -360 : 0))
                            .animation(.linear(duration: 90).repeatForever(autoreverses: false), value: isAnimating)
                        
                        // Inner ring with dashes
                        Circle()
                            .stroke(QXColor.gold.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [10, 10]))
                            .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .rotationEffect(.degrees(isAnimating ? 180 : 0))
                            .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: isAnimating)
                    }
                }
                .blur(radius: 20)
                .accessibilityHidden(true) // Decorative element
            } else {
                // Static background for accessibility
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .stroke(QXColor.gold.opacity(0.05), lineWidth: 1)
                            .frame(width: geo.size.width, height: geo.size.width)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                }
                .blur(radius: 20)
                .accessibilityHidden(true)
            }
        }
        .onAppear { 
            if !UIAccessibility.isReduceMotionEnabled {
                isAnimating = true 
            }
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    @State private var isAnimating = false
    @State private var showSignIn = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated logo with premium effects - respects Reduce Motion
            ZStack {
                if !UIAccessibility.isReduceMotionEnabled {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [QXColor.gold.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .opacity(isAnimating ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Outer rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(QXColor.gold.opacity(0.3 - Double(i) * 0.08), lineWidth: 1)
                            .frame(width: 200 + CGFloat(i * 35), height: 200 + CGFloat(i * 35))
                            .scaleEffect(isAnimating ? 1.0 : 0.95)
                            .opacity(isAnimating ? 0.6 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .delay(Double(i) * 0.3)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                
                // Center icon - always visible, but animates conditionally
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .applyIf(!UIAccessibility.isReduceMotionEnabled) {
                        $0.rotationEffect(.degrees(isAnimating ? 360 : 0))
                         .animation(
                             Animation.linear(duration: 20)
                                 .repeatForever(autoreverses: false),
                             value: isAnimating
                         )
                    }
                    .accessibilityLabel("QodeX logo")
                    .accessibilityAddTraits(.isImage)
            }
            .onAppear { 
                if !UIAccessibility.isReduceMotionEnabled {
                    isAnimating = true 
                }
            }
            
            // Text with staggered animation
            VStack(spacing: 16) {
                Text("Welcome to QodeX")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                    .accessibilityAddTraits(.isHeader)
                    .slideUp(delay: 0.1)
                
                Text("Decode your energetic matrix and discover the blueprint you were born with.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .slideUp(delay: 0.2)
            }
            
            Spacer()
            
            // Sign in option
            Button(action: { 
                QXHaptic.lightImpact()
                showSignIn = true 
            }) {
                Text("Already have an account? ")
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                +
                Text("Sign In")
                    .foregroundColor(QXColor.gold)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .padding(.bottom, 20)
            .fadeIn(delay: 0.4)
        }
        .sheet(isPresented: $showSignIn) {
            AuthFlowView()
        }
    }
}

// MARK: - Name Step

struct NameStep: View {
    @Binding var name: String
    @FocusState private var isFocused: Bool
    @State private var showGreeting = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("What's your name?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                
                Text("We'll personalize your experience.")
                    .font(.system(size: 16))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
            }
            .slideUp(delay: 0)
            
            // Input field with premium styling
            VStack(spacing: 12) {
                TextField("", text: $name)
                    .focused($isFocused)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(QXColor.deepVoid.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        name.isEmpty ? QXColor.starlight.opacity(0.2) : QXColor.gold.opacity(0.5),
                                        lineWidth: name.isEmpty ? 1 : 2
                                    )
                            )
                    )
                    .onChange(of: name) { _, newValue in
                        showGreeting = !newValue.isEmpty && newValue.count >= 2
                        if newValue.count == 1 {
                            QXHaptic.selection()
                        }
                    }
                    .onAppear { 
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isFocused = true
                        }
                    }
                
                // Animated greeting
                if showGreeting {
                    Text("Hello, \(name) ✨")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(QXColor.gold)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            QXHaptic.successDouble()
                        }
                }
            }
            .padding(.horizontal, 24)
            .slideUp(delay: 0.1)
            
            Spacer()
        }
    }
}

// MARK: - Birth Date Step

struct BirthDateStep: View {
    @Binding var date: Date
    @Binding var showTimePicker: Bool
    @State private var showValidation = false
    
    private var isValidDate: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        if date > now { return false }
        if let age = calendar.dateComponents([.year], from: date, to: now).year, age > 120 { return false }
        if let age = calendar.dateComponents([.year], from: date, to: now).year, age < 13 { return false }
        
        return true
    }
    
    private var age: Int? {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("When were you born?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                
                Text("Your birth date reveals your Life Path number.")
                    .font(.system(size: 16))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
            }
            .slideUp(delay: 0)
            
            // Date picker with premium styling
            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorMultiply(QXColor.gold)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.5))
            )
            .padding(.horizontal, 20)
            .slideUp(delay: 0.1)
            .onChange(of: date) { _, _ in
                QXHaptic.selection()
            }
            
            // Age indicator
            if let age = age {
                if age >= 13 {
                    Text("Age: \(age) years")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(QXColor.gold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(QXColor.gold.opacity(0.1))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("You must be at least 13 years old")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Time option
            Button(action: { 
                QXHaptic.lightImpact()
                showTimePicker = true 
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                    Text("Add birth time for precision (optional)")
                        .font(.subheadline)
                }
                .foregroundColor(QXColor.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(QXColor.gold.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

// MARK: - Birth Time Step

struct BirthTimeStep: View {
    @Binding var date: Date?
    @Binding var showPicker: Bool
    @State private var skipPressed = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("What time were you born?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                
                Text("This enhances your chart accuracy.")
                    .font(.system(size: 16))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
            }
            .slideUp(delay: 0)
            
            // Time picker
            DatePicker(
                "",
                selection: Binding(
                    get: { date ?? Date() },
                    set: { date = $0 }
                ),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorMultiply(QXColor.gold)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.5))
            )
            .padding(.horizontal, 20)
            .slideUp(delay: 0.1)
            .onChange(of: date) { _, _ in
                QXHaptic.selection()
            }
            
            // Skip option
            Button(action: { 
                QXHaptic.lightImpact()
                skipPressed = true
                showPicker = false 
            }) {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundColor(QXColor.starlight.opacity(0.5))
                    .underline()
            }
            .opacity(skipPressed ? 0.5 : 1)
            
            Spacer()
        }
    }
}

// MARK: - Results Step

struct ResultsStep: View {
    let lifePath: Int
    @State private var isAnimating = false
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Your Life Path Number")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(QXColor.starlight.opacity(0.7))
                .fadeIn(delay: 0)
            
            // Number reveal with premium animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [QXColor.gold.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 80,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1 : 0.5)
                    .animation(.easeOut(duration: 1), value: isAnimating)
                
                // Ring animation
                Circle()
                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.6 : 0.2)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                // Number
                Text("\(lifePath)")
                    .font(.system(size: 140, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isAnimating ? 1 : 0.3)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(
                        QXAnimation.emphasis.delay(0.3),
                        value: isAnimating
                    )
            }
            .frame(height: 280)
            
            // Description with stagger
            VStack(spacing: 12) {
                Text(LifePathDescriptions.titles[lifePath] ?? "")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(QXColor.starlight)
                    .multilineTextAlignment(.center)
                
                Text(LifePathDescriptions.short[lifePath] ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 30)
            .animation(
                .easeOut.delay(0.6),
                value: isAnimating
            )
            
            // Sparkle decorations
            if isAnimating {
                HStack(spacing: 40) {
                    ForEach(0..<3) { i in
                        Image(systemName: "sparkle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(QXColor.gold)
                            .opacity(0.6)
                            .animation(
                                .easeInOut(duration: 1)
                                    .delay(0.8 + Double(i) * 0.1)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
            QXHaptic.premiumUnlock()
        }
    }
}

// MARK: - Navigation Footer

struct NavigationFooter: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    QXHaptic.lightImpact()
                    onBack()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(QXColor.starlight)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(QXColor.starlight.opacity(0.1))
                                .overlay(
                                    Circle()
                                        .stroke(QXColor.starlight.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .accessibleButton(label: "Back", hint: "Go to previous step")
                .minimumTouchTarget()
                .pressAnimation()
            }
            
            // Next/Complete button
            Button(action: {
                if canProceed {
                    QXHaptic.mediumImpact()
                    onNext()
                } else {
                    QXHaptic.error()
                }
            }) {
                HStack(spacing: 8) {
                    Text(currentStep == totalSteps - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 17, weight: .semibold))
                    
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .accessibilityHidden(true)
                    }
                }
                .foregroundColor(QXColor.cosmicBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: canProceed ? [QXColor.gold, QXColor.goldGlow] : [QXColor.starlight.opacity(0.3), QXColor.starlight.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(
                    color: canProceed ? QXColor.gold.opacity(0.3) : .clear,
                    radius: 10, x: 0, y: 4
                )
            }
            .disabled(!canProceed)
            .accessibleButton(
                label: currentStep == totalSteps - 1 ? "Get Started" : "Continue",
                hint: canProceed ? "Proceed to next step" : "Please complete the current step first"
            )
            .minimumTouchTarget()
            .pressAnimation()
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
}
                )
            }
            .disabled(!canProceed)
            .pressAnimation()
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
}

// MARK: - Data

struct LifePathDescriptions {
    static let titles: [Int: String] = [
        1: "The Leader",
        2: "The Peacemaker",
        3: "The Creator",
        4: "The Builder",
        5: "The Freedom Seeker",
        6: "The Nurturer",
        7: "The Seeker",
        8: "The Powerhouse",
        9: "The Humanitarian",
        11: "The Intuitive",
        22: "The Master Builder",
        33: "The Master Teacher"
    ]
    
    static let short: [Int: String] = [
        1: "You are a natural-born leader with the drive and determination to achieve great things.",
        2: "You have a gift for bringing people together and creating harmony in any situation.",
        3: "Your creative energy and self-expression bring joy and inspiration to the world.",
        4: "You build solid foundations and turn dreams into reality through hard work.",
        5: "You thrive on freedom, adventure, and embracing life's endless possibilities.",
        6: "Your nurturing heart creates beauty and harmony wherever you go.",
        7: "You possess deep wisdom and a natural connection to spiritual truth.",
        8: "You have the power to manifest abundance and achieve material success.",
        9: "You are here to serve humanity and leave the world better than you found it."
    ]
}

// MARK: - Preview

#Preview("Onboarding Flow") {
    OnboardingFlowV2()
        .preferredColorScheme(.dark)
}
