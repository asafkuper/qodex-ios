//
//  OnboardingFlow.swift
//  QodeX Onboarding with Improved Skip UX
//

import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var canSkip = false
    @State private var skipOpacity = 0.0
    
    var body: some View {
        ZStack {
            QXColor.cosmicBlack.ignoresSafeArea()
            
            switch viewModel.currentStep {
            case .welcome:
                WelcomeStep(viewModel: viewModel)
            case .birthDate:
                BirthDateStep(viewModel: viewModel)
            case .firstResult:
                FirstResultStep(viewModel: viewModel)
            case .personalizedPlan:
                PersonalizedPlanStep(viewModel: viewModel)
            }
            
            // Skip button overlay - appears after 2 seconds
            if viewModel.currentStep == .welcome {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            skipAnimation()
                        }) {
                            HStack(spacing: 4) {
                                Text("Skip")
                                    .font(.system(size: 15, weight: .medium))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(QXColor.starlight.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .opacity(skipOpacity)
                        .animation(.easeInOut(duration: 0.5), value: skipOpacity)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                    
                    Spacer()
                }
                .onAppear {
                    // Enable skip after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        canSkip = true
                        skipOpacity = 1.0
                    }
                }
            }
        }
    }
    
    private func skipAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.skipToEnd()
        }
        QXHaptic.lightImpact()
    }
}

struct WelcomeStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var animate = false
    @State private var showSkipHint = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                        .frame(width: 120 + CGFloat(i * 40), height: 120 + CGFloat(i * 40))
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(Double(i) * 0.5), value: animate)
                }
                
                HexagonShape()
                    .stroke(QXColor.gold, lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Text("Q")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(QXColor.gold)
            }
            .onAppear { animate = true }
            
            VStack(spacing: 16) {
                Text("Discover Your Qode")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(QXColor.starlight)
                
                Text("Decode the energetic patterns that shape your life")
                    .font(.system(size: 16))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Progress indicator showing this is skippable
            HStack(spacing: 8) {
                Circle()
                    .fill(QXColor.gold)
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(QXColor.starlight.opacity(0.3))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(QXColor.starlight.opacity(0.3))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(QXColor.starlight.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            
            Spacer()
            
            // Primary CTA
            Button(action: { viewModel.nextStep() }) {
                HStack(spacing: 8) {
                    Text("Begin Your Journey")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                }
                .foregroundStyle(QXColor.cosmicBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(QXColor.gold)
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            
            // Secondary option - Skip hint
            HStack(spacing: 4) {
                Text("Or")
                    .font(.system(size: 14))
                    .foregroundStyle(QXColor.starlight.opacity(0.4))
                
                Button(action: { viewModel.skipToEnd() }) {
                    Text("skip intro")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QXColor.gold.opacity(0.7))
                        .underline()
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct BirthDateStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showValidation = false
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressBar(progress: 0.3, color: QXColor.gold)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Text("When were you born?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(QXColor.starlight)
            
            Text("Your birth date reveals your Life Path number")
                .font(.system(size: 15))
                .foregroundStyle(QXColor.starlight.opacity(0.6))
            
            DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorMultiply(QXColor.gold)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(QXColor.deepVoid.opacity(0.5))
                )
                .padding(.horizontal, 20)
            
            // Age validation feedback
            if let age = viewModel.age {
                if age >= 13 {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(QXColor.success)
                        Text("Age: \(age) years")
                            .font(.system(size: 14))
                            .foregroundStyle(QXColor.starlight.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(QXColor.success.opacity(0.1))
                    .cornerRadius(20)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("You must be at least 13 years old")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                }
                .foregroundStyle(QXColor.cosmicBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: viewModel.isValidBirthDate ? [QXColor.gold, QXColor.goldGlow] : [QXColor.starlight.opacity(0.3), QXColor.starlight.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .disabled(!viewModel.isValidBirthDate)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

struct FirstResultStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                // Animated rings
                Circle()
                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(QXColor.gold.opacity(0.1))
                    .frame(width: 150, height: 150)
                
                Text("\(viewModel.lifePathNumber)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
            }
            .onAppear { isAnimating = true }
            
            VStack(spacing: 12) {
                Text("You are a Life Path \(viewModel.lifePathNumber)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(QXColor.starlight)
                
                Text(viewModel.lifePathName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(QXColor.gold)
                
                Text(viewModel.lifePathDescription)
                    .font(.system(size: 15))
                    .foregroundStyle(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut.delay(0.3), value: isAnimating)
            
            // Social proof
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                Text("Join 2,800+ seekers who discovered their Qode")
                    .font(.system(size: 13))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
            .padding(.top, 20)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeOut.delay(0.5), value: isAnimating)
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                HStack(spacing: 8) {
                    Text("See Your Full Chart")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                }
                .foregroundStyle(QXColor.cosmicBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: QXColor.gold.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 30)
            .animation(.easeOut.delay(0.6), value: isAnimating)
        }
    }
}

struct PersonalizedPlanStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Your Personalized Journey")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(QXColor.starlight)
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                BenefitRow(
                    icon: "number.circle.fill",
                    text: "Daily Qode insights",
                    color: QXColor.gold,
                    delay: 0.1
                )
                BenefitRow(
                    icon: "book.closed.fill",
                    text: "Personalized teachings",
                    color: QXColor.cosmicPurple,
                    delay: 0.2
                )
                BenefitRow(
                    icon: "person.2.fill",
                    text: "Community of seekers",
                    color: QXColor.nebulaBlue,
                    delay: 0.3
                )
                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Weekly numerology reports",
                    color: QXColor.cosmicTeal,
                    delay: 0.4
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    NotificationCenter.default.post(name: .onboardingComplete, object: nil)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Start Free Trial")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.cosmicBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: QXColor.gold.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                Button(action: {
                    NotificationCenter.default.post(name: .onboardingComplete, object: nil)
                }) {
                    Text("Continue with Limited Access")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeOut.delay(0.3)) {
                isAnimating = true
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(QXColor.starlight)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(QXColor.gold)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(QXColor.deepVoid)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut.delay(delay)) {
                isVisible = true
            }
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(QXColor.sacredGeometry)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var birthDate = Date()
    
    var lifePathNumber: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        let sum = (components.day ?? 1) + (components.month ?? 1) + (components.year ?? 2000)
        return reduceToSingleDigit(sum)
    }
    
    var lifePathName: String {
        let names = [
            1: "The Leader",
            2: "The Peacemaker",
            3: "The Creative",
            4: "The Builder",
            5: "The Freedom Seeker",
            6: "The Nurturer",
            7: "The Seeker",
            8: "The Powerhouse",
            9: "The Humanitarian"
        ]
        return names[lifePathNumber] ?? "Unknown"
    }
    
    var lifePathDescription: String {
        let descriptions = [
            1: "You have a natural gift for leadership and innovation. Your path is about forging new trails and taking initiative.",
            2: "You are a natural diplomat with an innate ability to create harmony. Your path is about cooperation and partnership.",
            3: "You bring creativity and joy to everything you do. Your path is about self-expression and inspiring others.",
            4: "You are the foundation builder, bringing structure and order. Your path is about creating lasting systems.",
            5: "You thrive on change and adventure. Your path is about experiencing life fully and embracing freedom.",
            6: "You are the heart of any community, nurturing and caring. Your path is about service and creating beauty.",
            7: "You possess deep wisdom and seek truth. Your path is about spiritual growth and inner knowledge.",
            8: "You have the power to manifest abundance. Your path is about mastering the material world.",
            9: "You are here to serve humanity. Your path is about compassion and leaving the world better."
        ]
        return descriptions[lifePathNumber] ?? "Your unique path holds special wisdom."
    }
    
    var age: Int? {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    var isValidBirthDate: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Not in future
        if birthDate > now { return false }
        
        // Not more than 120 years ago
        if let age = calendar.dateComponents([.year], from: birthDate, to: now).year, age > 120 {
            return false
        }
        
        // At least 13 years old
        if let age = calendar.dateComponents([.year], from: birthDate, to: now).year, age < 13 {
            return false
        }
        
        return true
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .birthDate
        case .birthDate:
            if isValidBirthDate {
                currentStep = .firstResult
            }
        case .firstResult:
            currentStep = .personalizedPlan
        case .personalizedPlan:
            break
        }
    }
    
    func skipToEnd() {
        // Skip directly to results or personalized plan
        currentStep = .personalizedPlan
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 {
            var sum = 0
            var temp = n
            while temp > 0 {
                sum += temp % 10
                temp /= 10
            }
            n = sum
        }
        return max(1, n) // Ensure we never return 0
    }
}

enum OnboardingStep {
    case welcome, birthDate, firstResult, personalizedPlan
}

// MARK: - Hexagon Shape

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.25))
        path.addLine(to: CGPoint(x: width, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.75))
        path.addLine(to: CGPoint(x: 0, y: height * 0.25))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let onboardingComplete = Notification.Name("onboardingComplete")
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingFlow()
        .preferredColorScheme(.dark)
}
