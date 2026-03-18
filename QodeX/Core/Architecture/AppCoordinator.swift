//
//  AppCoordinator.swift
//  Main app flow coordination
//

import SwiftUI
import Combine
import UIKit

// MARK: - App Coordinator
@MainActor
final class AppCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var currentFlow: AppFlow = .splash
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var needsPaywall = false
    
    // MARK: - Child Coordinators
    var onboardingCoordinator: OnboardingCoordinator?
    var mainCoordinator: MainCoordinator?
    var authCoordinator: AuthCoordinator?
    
    // MARK: - Dependencies
    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(container: DependencyContainer = .shared) {
        self.container = container
        setupBindings()
        checkInitialState()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Listen for authentication state
        container.authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthStateChange(state)
            }
            .store(in: &cancellables)
        
        // Check onboarding state
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    private func checkInitialState() {
        // Determine initial flow
        if container.authService.isAuthenticated {
            isAuthenticated = true
            currentFlow = .main
        } else {
            currentFlow = .auth
        }
    }
    
    // MARK: - Auth State Handling
    private func handleAuthStateChange(_ state: AuthState) {
        switch state {
        case .authenticated:
            isAuthenticated = true
            if hasCompletedOnboarding {
                transition(to: .main)
            } else {
                transition(to: .onboarding)
            }
            
        case .unauthenticated:
            isAuthenticated = false
            transition(to: .auth)
            
        case .needsOnboarding:
            transition(to: .onboarding)
            
        case .needsPaywall:
            needsPaywall = true
        }
    }
    
    // MARK: - Flow Transitions
    func transition(to flow: AppFlow) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFlow = flow
        }
        
        switch flow {
        case .onboarding:
            startOnboarding()
        case .main:
            startMainFlow()
        case .auth:
            startAuthFlow()
        default:
            break
        }
    }
    
    // MARK: - Start Flows
    func start() {
        // Initial flow is determined by checkInitialState
    }
    
    private func startOnboarding() {
        let coordinator = OnboardingCoordinator(
            container: container,
            parent: self
        )
        coordinator.onComplete = { [weak self] in
            self?.hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self?.transition(to: .main)
        }
        onboardingCoordinator = coordinator
    }
    
    private func startMainFlow() {
        let coordinator = MainCoordinator(
            container: container,
            parent: self
        )
        coordinator.onLogout = { [weak self] in
            self?.handleLogout()
        }
        mainCoordinator = coordinator
    }
    
    private func startAuthFlow() {
        let coordinator = AuthCoordinator(
            container: container,
            parent: self
        )
        coordinator.onAuthenticated = { [weak self] in
            self?.isAuthenticated = true
            if self?.hasCompletedOnboarding == true {
                self?.transition(to: .main)
            } else {
                self?.transition(to: .onboarding)
            }
        }
        authCoordinator = coordinator
    }
    
    // MARK: - Actions
    func handleLogout() {
        Task {
            do {
                try await container.authService.signOut()
                hasCompletedOnboarding = false
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                transition(to: .auth)
            } catch {
                ErrorHandler.shared.handle(error, context: .authentication)
            }
        }
    }
    
    func showPaywall(source: String) {
        needsPaywall = true
    }
    
    func dismissPaywall() {
        needsPaywall = false
    }
    
    // MARK: - Deep Link Handling
    func handleDeepLink(_ url: URL) {
        guard let deepLink = DeepLinkRoute(url: url) else { return }
        
        switch deepLink {
        case .calculator(let birthDate):
            if currentFlow == .main, let coordinator = mainCoordinator {
                coordinator.navigateToCalculator(with: birthDate)
            }
        case .dailyQode(let date):
            if currentFlow == .main, let coordinator = mainCoordinator {
                coordinator.navigateToDailyQode(for: date)
            }
        case .profile(let userId):
            if currentFlow == .main, let coordinator = mainCoordinator {
                coordinator.navigateToProfile(userId: userId)
            }
        case .community(let postId):
            if currentFlow == .main, let coordinator = mainCoordinator {
                coordinator.navigateToCommunity(postId: postId)
            }
        case .subscription:
            if currentFlow == .main, let coordinator = mainCoordinator {
                coordinator.navigateToSubscription()
            }
        case .paywall:
            showPaywall(source: "deep_link")
        }
    }
    
    // MARK: - Push Notification Handling
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "daily_qode":
            if currentFlow == .main {
                mainCoordinator?.navigateToDailyQode(for: Date())
            }
        case "live_session":
            if currentFlow == .main {
                mainCoordinator?.navigateToLiveSessions()
            }
        case "subscription":
            showPaywall(source: "notification")
        default:
            break
        }
    }
}

// MARK: - App Flow Enum
enum AppFlow {
    case splash
    case auth
    case onboarding
    case main
}

// MARK: - Auth State
enum AuthState {
    case authenticated
    case unauthenticated
    case needsOnboarding
    case needsPaywall
}

// MARK: - App Root View
struct AppRootView: View {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var errorHandler = ErrorHandler.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    init(container: DependencyContainer = .shared) {
        _coordinator = StateObject(wrappedValue: AppCoordinator(container: container))
    }
    
    var body: some View {
        ZStack {
            // Main content based on current flow
            currentFlowView
            
            // Global overlays
            VStack {
                OfflineBanner()
                    .padding(.top, 8)
                Spacer()
            }
        }
        .withErrorHandling()
        .sheet(isPresented: $coordinator.needsPaywall) {
            PaywallContainerView(source: "app")
        }
    }
    
    @ViewBuilder
    private var currentFlowView: some View {
        switch coordinator.currentFlow {
        case .splash:
            SplashView()
            
        case .auth:
            if let authCoordinator = coordinator.authCoordinator {
                AuthFlowContainer(coordinator: authCoordinator)
            } else {
                SplashView()
            }
            
        case .onboarding:
            if let onboardingCoordinator = coordinator.onboardingCoordinator {
                OnboardingFlowContainer(coordinator: onboardingCoordinator)
            } else {
                SplashView()
            }
            
        case .main:
            if let mainCoordinator = coordinator.mainCoordinator {
                MainTabContainer(coordinator: mainCoordinator)
            } else {
                SplashView()
            }
        }
    }
}

// MARK: - Container Views
struct AuthFlowContainer: View {
    @ObservedObject var coordinator: AuthCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.makeWelcomeView()
                .navigationDestination(for: AuthRoute.self) { route in
                    coordinator.view(for: route)
                }
        }
    }
}

struct OnboardingFlowContainer: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.makeWelcomeStep()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    coordinator.view(for: route)
                }
        }
    }
}

struct MainTabContainer: View {
    @ObservedObject var coordinator: MainCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(TabRoute.allCases, id: \.self) { tab in
                NavigationStack(path: $coordinator.navigationPath(for: tab)) {
                    coordinator.rootView(for: tab)
                        .navigationDestination(for: MainRoute.self) { route in
                            coordinator.view(for: route)
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            coordinator.sheetView(for: sheet)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { screen in
            coordinator.fullScreenView(for: screen)
        }
    }
}

struct PaywallContainerView: View {
    let source: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EnhancedPaywallView()
    }
}

// MARK: - Splash View
struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0)
                
                Text("QodeX")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0)
                    .offset(y: isAnimating ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Auth Coordinator
@MainActor
final class AuthCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    var onAuthenticated: (() -> Void)?
    
    private let container: DependencyContainer
    private weak var parent: AppCoordinator?
    
    init(container: DependencyContainer, parent: AppCoordinator?) {
        self.container = container
        self.parent = parent
    }
    
    // MARK: - View Factory
    func makeWelcomeView() -> some View {
        WelcomeView(
            onSignIn: { [weak self] in self?.navigate(to: .signIn) },
            onSignUp: { [weak self] in self?.navigate(to: .signUp) }
        )
    }
    
    @ViewBuilder
    func view(for route: AuthRoute) -> some View {
        switch route {
        case .signIn:
            SignInView(
                onSignIn: { [weak self] in self?.onAuthenticated?() },
                onForgotPassword: { [weak self] in self?.navigate(to: .forgotPassword) },
                onBack: { [weak self] in self?.navigateBack() }
            )
            .environmentObject(container)
            
        case .signUp:
            SignUpView(
                onSignUp: { [weak self] in self?.onAuthenticated?() },
                onBack: { [weak self] in self?.navigateBack() }
            )
            .environmentObject(container)
            
        case .forgotPassword:
            ForgotPasswordView(
                onBack: { [weak self] in self?.navigateBack() }
            )
            .environmentObject(container)
        }
    }
    
    // MARK: - Navigation
    func navigate(to route: AuthRoute) {
        navigationPath.append(route)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// MARK: - Auth Routes
enum AuthRoute: Hashable {
    case signIn
    case signUp
    case forgotPassword
}

// MARK: - Placeholder Views (to be replaced with actual implementations)
struct WelcomeView: View {
    var onSignIn: () -> Void
    var onSignUp: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "number.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
            
            Text("Welcome to QodeX")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Discover the numbers that shape your destiny")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onSignUp) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                
                Button(action: onSignIn) {
                    Text("I already have an account")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

struct SignInView: View {
    var onSignIn: () -> Void
    var onForgotPassword: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        Text("Sign In View")
    }
}

struct SignUpView: View {
    var onSignUp: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        Text("Sign Up View")
    }
}

struct ForgotPasswordView: View {
    var onBack: () -> Void
    
    var body: some View {
        Text("Forgot Password View")
    }
}
