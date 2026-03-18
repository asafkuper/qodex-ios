//
//  OnboardingCoordinator.swift
//  Onboarding flow coordination
//

import SwiftUI
import Combine

// MARK: - Onboarding Coordinator
@MainActor
final class OnboardingCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var navigationPath = NavigationPath()
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userBirthDate: Date?
    @Published var userName: String = ""
    @Published var isLoading = false
    @Published var error: AppError?
    
    // MARK: - Callbacks
    var onComplete: (() -> Void)?
    var onSkip: (() -> Void)?
    
    // MARK: - Dependencies
    private let container: DependencyContainer
    private weak var parent: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var canProceed: Bool {
        switch currentStep {
        case .welcome, .features:
            return true
        case .birthDate:
            return userBirthDate != nil
        case .results:
            return userBirthDate != nil
        case .complete:
            return true
        }
    }
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    // MARK: - Initialization
    init(container: DependencyContainer, parent: AppCoordinator?) {
        self.container = container
        self.parent = parent
    }
    
    // MARK: - View Factory
    func makeWelcomeStep() -> some View {
        WelcomeOnboardingStep(
            onNext: { [weak self] in self?.nextStep() },
            onSkip: { [weak self] in self?.skipOnboarding() }
        )
    }
    
    @ViewBuilder
    func view(for route: OnboardingRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeOnboardingStep(
                onNext: { [weak self] in self?.nextStep() },
                onSkip: { [weak self] in self?.skipOnboarding() }
            )
            
        case .features:
            FeaturesOnboardingStep(
                onNext: { [weak self] in self?.nextStep() },
                onBack: { [weak self] in self?.previousStep() },
                onSkip: { [weak self] in self?.skipOnboarding() }
            )
            
        case .birthDate:
            BirthDateOnboardingStep(
                birthDate: Binding(
                    get: { [weak self] in self?.userBirthDate },
                    set: { [weak self] in self?.userBirthDate = $0 }
                ),
                onNext: { [weak self] in self?.nextStep() },
                onBack: { [weak self] in self?.previousStep() }
            )
            
        case .results:
            if let birthDate = userBirthDate {
                ResultsOnboardingStep(
                    birthDate: birthDate,
                    onComplete: { [weak self] in self?.completeOnboarding() },
                    onBack: { [weak self] in self?.previousStep() }
                )
            } else {
                EmptyView()
            }
            
        case .complete:
            CompleteOnboardingStep(
                onGetStarted: { [weak self] in self?.finishOnboarding() }
            )
        }
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        
        currentStep = next
        navigate(to: route(for: next))
    }
    
    func previousStep() {
        guard let previous = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        
        currentStep = previous
        navigateBack()
    }
    
    func navigate(to route: OnboardingRoute) {
        navigationPath.append(route)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    private func route(for step: OnboardingStep) -> OnboardingRoute {
        switch step {
        case .welcome:
            return .welcome
        case .features:
            return .features
        case .birthDate:
            return .birthDate
        case .results:
            return .results
        case .complete:
            return .complete
        }
    }
    
    // MARK: - Actions
    func skipOnboarding() {
        AnalyticsManager.shared.logCustomEvent("onboarding_skipped", parameters: [
            "step": currentStep.rawValue
        ])
        
        // Save minimal profile and complete
        Task {
            await saveMinimalProfile()
            finishOnboarding()
        }
    }
    
    func completeOnboarding() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await saveUserProfile()
                AnalyticsManager.shared.logCustomEvent("onboarding_completed", parameters: [
                    "birth_date_entered": userBirthDate != nil
                ])
                
                // Move to complete step
                currentStep = .complete
                navigate(to: .complete)
            } catch {
                self.error = AppError(from: error)
            }
        }
    }
    
    func finishOnboarding() {
        onComplete?()
    }
    
    // MARK: - Profile Saving
    private func saveUserProfile() async throws {
        guard let userId = container.authService.currentUserId else {
            throw AuthError.notAuthenticated
        }
        
        let profile = UserProfileData(
            userId: userId,
            name: userName.isEmpty ? "Seeker" : userName,
            email: container.authService.currentUserEmail ?? "",
            birthDate: userBirthDate ?? Date(),
            birthTime: nil,
            timezone: TimeZone.current.identifier,
            lifePath: calculateLifePath(from: userBirthDate ?? Date()),
            createdAt: Date()
        )
        
        try await container.firebaseService.saveUserProfile(profile)
    }
    
    private func saveMinimalProfile() async {
        guard let userId = container.authService.currentUserId else { return }
        
        let profile = UserProfileData(
            userId: userId,
            name: "Seeker",
            email: container.authService.currentUserEmail ?? "",
            birthDate: Date(),
            birthTime: nil,
            timezone: TimeZone.current.identifier,
            lifePath: 1,
            createdAt: Date()
        )
        
        do {
            try await container.firebaseService.saveUserProfile(profile)
        } catch {
            print("Failed to save minimal profile: \(error)")
        }
    }
    
    private func calculateLifePath(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000
        
        var sum = day + month + year
        while sum > 9 && sum != 11 && sum != 22 && sum != 33 {
            var newSum = 0
            var n = sum
            while n > 0 {
                newSum += n % 10
                n /= 10
            }
            sum = newSum
        }
        
        return sum == 0 ? 9 : sum
    }
}

// MARK: - Onboarding Routes
enum OnboardingRoute: Hashable {
    case welcome
    case features
    case birthDate
    case results
    case complete
}

// MARK: - Onboarding Step Views
struct WelcomeOnboardingStep: View {
    var onNext: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        OnboardingStepView(
            title: "Welcome to QodeX",
            description: "Discover the ancient wisdom of numerology and unlock insights about your life's path, purpose, and potential.",
            icon: "number.circle.fill",
            onNext: onNext,
            onSkip: onSkip,
            showSkip: true
        )
    }
}

struct FeaturesOnboardingStep: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var onSkip: () -> Void
    
    let features = [
        FeatureItem(icon: "sun.max.fill", title: "Daily Qodes", description: "Personalized daily insights based on your numbers"),
        FeatureItem(icon: "number", title: "Qode Calculator", description: "Calculate life path, expression, and soul urge numbers"),
        FeatureItem(icon: "person.3.fill", title: "Community", description: "Connect with fellow seekers on their numerology journey"),
        FeatureItem(icon: "livephoto", title: "Live Sessions", description: "Join live readings and Q&A with numerology experts")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Discover Your Numbers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("QodeX combines ancient numerology with modern insights")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ForEach(features) { feature in
                            FeatureCard(feature: feature)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Bottom button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: onNext) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
}

struct BirthDateOnboardingStep: View {
    @Binding var birthDate: Date?
    var onNext: () -> Void
    var onBack: () -> Void
    
    @State private var selectedDate = Date()
    @State private var showError = false
    
    private let minDate = Calendar.current.date(from: DateComponents(year: 1900))!
    private let maxDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 12) {
                    Text("When were you born?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your birth date reveals your Life Path number and personal numerology chart")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date picker
                DatePicker(
                    "Birth Date",
                    selection: $selectedDate,
                    in: minDate...maxDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 200)
                .padding()
                
                if showError {
                    InlineErrorView(
                        message: "Please select a valid birth date",
                        onRetry: nil
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Continue button
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        // Validate date
                        do {
                            try InputValidator.validate(birthDate: selectedDate)
                            birthDate = selectedDate
                            onNext()
                        } catch {
                            withAnimation {
                                showError = true
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
        }
    }
}

struct ResultsOnboardingStep: View {
    let birthDate: Date
    var onComplete: () -> Void
    var onBack: () -> Void
    
    private var lifePath: Int {
        calculateLifePath(from: birthDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Life Path Display
                    VStack(spacing: 16) {
                        Text("Your Life Path Number")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 3)
                                .frame(width: 150, height: 150)
                            
                            Text("\(lifePath)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                        
                        Text(lifePathTitle(for: lifePath))
                            .font(.title2)
                            .fontWeight(.bold)
                            
                        Text(lifePathDescription(for: lifePath))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Quick insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Strengths")
                            .font(.headline)
                        
                        ForEach(lifePathStrengths(for: lifePath), id: \.self) { strength in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(strength)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Complete button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: onComplete) {
                    Text("Explore More")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func calculateLifePath(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000
        
        var sum = day + month + year
        while sum > 9 && sum != 11 && sum != 22 && sum != 33 {
            var newSum = 0
            var n = sum
            while n > 0 {
                newSum += n % 10
                n /= 10
            }
            sum = newSum
        }
        
        return sum == 0 ? 9 : sum
    }
    
    private func lifePathTitle(for number: Int) -> String {
        let titles = [
            1: "The Leader",
            2: "The Peacemaker",
            3: "The Creative",
            4: "The Builder",
            5: "The Adventurer",
            6: "The Nurturer",
            7: "The Seeker",
            8: "The Powerhouse",
            9: "The Humanitarian",
            11: "The Intuitive",
            22: "The Master Builder",
            33: "The Master Teacher"
        ]
        return titles[number] ?? "The Seeker"
    }
    
    private func lifePathDescription(for number: Int) -> String {
        let descriptions = [
            1: "You are a natural born leader with strong independence and ambition.",
            2: "You have a gift for diplomacy and bringing people together in harmony.",
            3: "Creativity and self-expression flow naturally through you.",
            4: "You build solid foundations and bring order to chaos.",
            5: "Freedom and adventure call to your restless spirit.",
            6: "You have a deep responsibility to nurture and care for others.",
            7: "Your analytical mind seeks truth and deeper understanding.",
            8: "You have the ability to manifest abundance and achieve great success.",
            9: "You are here to serve humanity and complete spiritual cycles.",
            11: "You possess heightened intuition and spiritual insight.",
            22: "You have the potential to turn dreams into reality on a large scale.",
            33: "You are called to guide and teach others with compassion."
        ]
        return descriptions[number] ?? "Your unique journey is unfolding."
    }
    
    private func lifePathStrengths(for number: Int) -> [String] {
        let strengths: [Int: [String]] = [
            1: ["Leadership", "Independence", "Innovation", "Determination"],
            2: ["Diplomacy", "Cooperation", "Sensitivity", "Patience"],
            3: ["Creativity", "Communication", "Optimism", "Self-expression"],
            4: ["Organization", "Practicality", "Loyalty", "Hard work"],
            5: ["Adaptability", "Versatility", "Courage", "Freedom-loving"],
            6: ["Responsibility", "Nurturing", "Balance", "Protective"],
            7: ["Analysis", "Intuition", "Perfectionism", "Wisdom"],
            8: ["Ambition", "Authority", "Efficiency", "Organization"],
            9: ["Compassion", "Generosity", "Artistic talent", "Tolerance"],
            11: ["Intuition", "Spiritual insight", "Inspiration", "Sensitivity"],
            22: ["Practical idealism", "Leadership", "Vision", "Achievement"],
            33: ["Compassion", "Guidance", "Healing", "Self-sacrifice"]
        ]
        return strengths[number] ?? ["Unique perspective", "Inner strength", "Growth potential"]
    }
}

struct CompleteOnboardingStep: View {
    var onGetStarted: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 0 : 1)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
            }
            
            VStack(spacing: 12) {
                Text("You're All Set!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your numerology journey begins now. Explore your daily insights, calculate compatibility, and discover what the numbers reveal about you.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Helper Views
struct OnboardingStepView: View {
    let title: String
    let description: String
    let icon: String
    var onNext: () -> Void
    var onSkip: (() -> Void)?
    var showSkip: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 32) {
                Image(systemName: icon)
                    .font(.system(size: 100))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Bottom buttons
            VStack(spacing: 16) {
                Button(action: onNext) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                
                if showSkip, let onSkip = onSkip {
                    Button(action: onSkip) {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct FeatureCard: View {
    let feature: FeatureItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 50, height: 50)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
