//
//  Coordinator.swift
//  Navigation coordination protocol
//

import SwiftUI
import Combine

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    associatedtype Route
    
    var parent: Coordinator? { get set }
    var childCoordinators: [any Coordinator] { get set }
    var navigationController: UINavigationController? { get set }
    
    func start()
    func navigate(to route: Route)
    func navigateBack()
    func navigateToRoot()
    func finish()
    
    func addChild(_ coordinator: any Coordinator)
    func removeChild(_ coordinator: any Coordinator)
    func removeFromParent()
}

// MARK: - Default Coordinator Implementations
extension Coordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parent = self
    }
    
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func removeFromParent() {
        parent?.removeChild(self)
    }
    
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func navigateToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func finish() {
        removeFromParent()
        navigationController = nil
    }
}

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    // Auth routes
    case welcome
    case signIn
    case signUp
    case forgotPassword
    
    // Onboarding routes
    case onboarding(step: OnboardingStep)
    case birthDateEntry
    
    // Main tab routes
    case dashboard
    case calculator
    case dailyQode
    case community
    case profile
    
    // Feature routes
    case birthChart
    case compatibility
    case journal
    case liveSessions
    case mentorship
    case challenges
    case aiChat
    
    // Subscription routes
    case paywall(source: String)
    case subscriptionDetails
    
    // Settings routes
    case settings
    case notificationsSettings
    case privacySettings
    case accountSettings
    
    // Admin routes
    case adminDashboard
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Sign Up"
        case .forgotPassword:
            return "Reset Password"
        case .onboarding:
            return "Getting Started"
        case .birthDateEntry:
            return "Your Birth Date"
        case .dashboard:
            return "Dashboard"
        case .calculator:
            return "Calculator"
        case .dailyQode:
            return "Daily Qode"
        case .community:
            return "Community"
        case .profile:
            return "Profile"
        case .birthChart:
            return "Birth Chart"
        case .compatibility:
            return "Compatibility"
        case .journal:
            return "Journal"
        case .liveSessions:
            return "Live Sessions"
        case .mentorship:
            return "Mentorship"
        case .challenges:
            return "Challenges"
        case .aiChat:
            return "AI Chat"
        case .paywall:
            return "Premium"
        case .subscriptionDetails:
            return "Subscription"
        case .settings:
            return "Settings"
        case .notificationsSettings:
            return "Notifications"
        case .privacySettings:
            return "Privacy"
        case .accountSettings:
            return "Account"
        case .adminDashboard:
            return "Admin"
        }
    }
}

// MARK: - Onboarding Step
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case features
    case birthDate
    case results
    case complete
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to QodeX"
        case .features:
            return "Discover Your Numbers"
        case .birthDate:
            return "Enter Your Birth Date"
        case .results:
            return "Your Numerology"
        case .complete:
            return "You're All Set!"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Unlock the secrets hidden in your birth date"
        case .features:
            return "Explore daily insights, compatibility, and more"
        case .birthDate:
            return "This helps us calculate your unique numbers"
        case .results:
            return "Discover what the numbers reveal about you"
        case .complete:
            return "Start your journey of self-discovery"
        }
    }
}

// MARK: - Tab Routes
enum TabRoute: Int, CaseIterable {
    case dashboard = 0
    case calculator
    case dailyQode
    case community
    case profile
    
    var icon: String {
        switch self {
        case .dashboard:
            return "house"
        case .calculator:
            return "number"
        case .dailyQode:
            return "sun.max"
        case .community:
            return "person.3"
        case .profile:
            return "person.circle"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .dashboard:
            return "house.fill"
        case .calculator:
            return "number.fill"
        case .dailyQode:
            return "sun.max.fill"
        case .community:
            return "person.3.fill"
        case .profile:
            return "person.circle.fill"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard:
            return "Home"
        case .calculator:
            return "Calculate"
        case .dailyQode:
            return "Daily"
        case .community:
            return "Community"
        case .profile:
            return "Profile"
        }
    }
}

// MARK: - Navigation State
class NavigationState: ObservableObject {
    @Published var currentRoute: AppRoute?
    @Published var presentedRoute: AppRoute?
    @Published var navigationPath = NavigationPath()
    
    var cancellables = Set<AnyCancellable>()
    
    func navigate(to route: AppRoute) {
        currentRoute = route
        navigationPath.append(route)
    }
    
    func present(_ route: AppRoute) {
        presentedRoute = route
    }
    
    func dismiss() {
        presentedRoute = nil
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func goToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}

// MARK: - Router Protocol (SwiftUI-native)
protocol Router: ObservableObject {
    associatedtype Route: Hashable
    
    var navigationPath: NavigationPath { get set }
    var sheetRoute: Route? { get set }
    var fullScreenRoute: Route? { get set }
    
    func push(_ route: Route)
    func pop()
    func popToRoot()
    func present(_ route: Route)
    func dismiss()
    func presentFullScreen(_ route: Route)
    func dismissFullScreen()
}

// MARK: - Default Router Implementation
class BaseRouter<Route: Hashable>: Router {
    @Published var navigationPath = NavigationPath()
    @Published var sheetRoute: Route?
    @Published var fullScreenRoute: Route?
    
    func push(_ route: Route) {
        navigationPath.append(route)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func present(_ route: Route) {
        sheetRoute = route
    }
    
    func dismiss() {
        sheetRoute = nil
    }
    
    func presentFullScreen(_ route: Route) {
        fullScreenRoute = route
    }
    
    func dismissFullScreen() {
        fullScreenRoute = nil
    }
}

// MARK: - View Factory Protocol
protocol ViewFactory {
    associatedtype Route
    func makeView(for route: Route) -> AnyView
}

// MARK: - Navigation Transitions
enum NavigationTransition {
    case push
    case modal
    case fullScreen
    case bottomSheet
    
    var transition: AnyTransition {
        switch self {
        case .push:
            return .move(edge: .trailing)
        case .modal:
            return .opacity.combined(with: .move(edge: .bottom))
        case .fullScreen:
            return .opacity
        case .bottomSheet:
            return .move(edge: .bottom)
        }
    }
}

// MARK: - Coordinator Factory
protocol CoordinatorFactory {
    func makeAppCoordinator(navigationController: UINavigationController?) -> AppCoordinator
    func makeOnboardingCoordinator(navigationController: UINavigationController?, parent: AppCoordinator?) -> OnboardingCoordinator
    func makeMainCoordinator(navigationController: UINavigationController?, parent: AppCoordinator?) -> MainCoordinator
}

// MARK: - UIKit to SwiftUI Bridge
class HostingController<Content: View>: UIHostingController<Content> {
    var onDisappear: (() -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
    }
}

// MARK: - Navigation Helpers
extension View {
    func withNavigationDestinations(
        for routes: [AppRoute],
        @ViewBuilder destination: @escaping (AppRoute) -> some View
    ) -> some View {
        self.navigationDestination(for: AppRoute.self) { route in
            destination(route)
        }
    }
}

// MARK: - Deep Link Handling
protocol DeepLinkHandler {
    func canHandle(_ url: URL) -> Bool
    func handle(_ url: URL, from coordinator: AppCoordinator)
}

enum DeepLinkRoute {
    case calculator(birthDate: Date?)
    case dailyQode(date: Date)
    case profile(userId: String?)
    case community(postId: String?)
    case subscription
    case paywall
    
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return nil
        }
        
        switch host {
        case "calculator":
            // qodex://calculator?birthDate=1990-01-01
            let date = components.queryItems?.first(where: { $0.name == "birthDate" })?.value
                .flatMap { Self.parseDate($0) }
            self = .calculator(birthDate: date)
        case "dailyqode":
            // qodex://dailyqode?date=2024-03-11
            let date = components.queryItems?.first(where: { $0.name == "date" })?.value
                .flatMap { Self.parseDate($0) } ?? Date()
            self = .dailyQode(date: date)
        case "profile":
            // qodex://profile?id=user123
            let userId = components.queryItems?.first(where: { $0.name == "id" })?.value
            self = .profile(userId: userId)
        case "community":
            // qodex://community?id=post123
            let postId = components.queryItems?.first(where: { $0.name == "id" })?.value
            self = .community(postId: postId)
        case "subscription":
            self = .subscription
        case "paywall":
            self = .paywall
        default:
            return nil
        }
    }
    
    private static func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
