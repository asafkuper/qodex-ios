//
//  MainCoordinator.swift
//  Main app tabs coordination
//

import SwiftUI
import Combine

// MARK: - Main Coordinator
@MainActor
final class MainCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var selectedTab: TabRoute = .dashboard
    @Published var dashboardPath = NavigationPath()
    @Published var calculatorPath = NavigationPath()
    @Published var dailyQodePath = NavigationPath()
    @Published var communityPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    @Published var presentedSheet: MainSheetRoute?
    @Published var presentedFullScreen: MainFullScreenRoute?
    
    @Published var showPaywall = false
    @Published var paywallSource = ""
    
    // MARK: - Callbacks
    var onLogout: (() -> Void)?
    
    // MARK: - Dependencies
    private let container: DependencyContainer
    private weak var parent: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(container: DependencyContainer, parent: AppCoordinator?) {
        self.container = container
        self.parent = parent
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for subscription changes that might require paywall
        container.subscriptionService.subscriptionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                // Handle subscription status changes
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation Path Accessor
    func navigationPath(for tab: TabRoute) -> Binding<NavigationPath> {
        switch tab {
        case .dashboard:
            return Binding(
                get: { self.dashboardPath },
                set: { self.dashboardPath = $0 }
            )
        case .calculator:
            return Binding(
                get: { self.calculatorPath },
                set: { self.calculatorPath = $0 }
            )
        case .dailyQode:
            return Binding(
                get: { self.dailyQodePath },
                set: { self.dailyQodePath = $0 }
            )
        case .community:
            return Binding(
                get: { self.communityPath },
                set: { self.communityPath = $0 }
            )
        case .profile:
            return Binding(
                get: { self.profilePath },
                set: { self.profilePath = $0 }
            )
        }
    }
    
    // MARK: - Root Views
    @ViewBuilder
    func rootView(for tab: TabRoute) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
                .environmentObject(container)
                .environmentObject(self)
        case .calculator:
            CalculatorView()
                .environmentObject(container)
                .environmentObject(self)
        case .dailyQode:
            DailyQodeView_Enhanced()
                .environmentObject(container)
                .environmentObject(self)
        case .community:
            CommunityFeedView_Enhanced()
                .environmentObject(container)
                .environmentObject(self)
        case .profile:
            ProfileHubView()
                .environmentObject(container)
                .environmentObject(self)
        }
    }
    
    // MARK: - View Factory
    @ViewBuilder
    func view(for route: MainRoute) -> some View {
        switch route {
        // Birth Chart
        case .birthChart:
            InteractiveBirthChartView()
                .environmentObject(container)
        
        // Compatibility
        case .compatibility:
            CompatibilityEngineView()
                .environmentObject(container)
        
        // Journal
        case .journal:
            NumerologyJournalView()
                .environmentObject(container)
        
        // Live Sessions
        case .liveSessions:
            LiveSessionHubView()
                .environmentObject(container)
        
        // Mentorship
        case .mentorship:
            MentorshipMatchingView()
                .environmentObject(container)
        
        // Challenges
        case .challenges:
            CommunityChallengesView()
                .environmentObject(container)
        
        // AI Chat
        case .aiChat:
            AIChatView()
                .environmentObject(container)
        
        // Settings
        case .settings:
            SettingsView(coordinator: self)
        case .notificationSettings:
            NotificationCenterView()
        case .privacySettings:
            PrivacySettingsView()
        case .accountSettings:
            AccountSettingsView(coordinator: self)
        
        // Subscription
        case .subscriptionDetails:
            SubscriptionDetailsView()
                .environmentObject(container)
        
        // Library
        case .library:
            LibraryView()
                .environmentObject(container)
        
        // Admin
        case .adminDashboard:
            AdminDashboardView()
                .environmentObject(container)
        
        // Profile detail
        case .profileDetail(let userId):
            ProfileDetailView(userId: userId)
                .environmentObject(container)
        
        // Community post
        case .communityPost(let postId):
            CommunityPostDetailView(postId: postId)
                .environmentObject(container)
        }
    }
    
    // MARK: - Sheet Views
    @ViewBuilder
    func sheetView(for route: MainSheetRoute) -> some View {
        NavigationStack {
            switch route {
            case .paywall(let source):
                EnhancedPaywallView()
                    .environmentObject(container)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                dismissSheet()
                            }
                        }
                    }
            
            case .editProfile:
                EditProfileView()
                    .environmentObject(container)
            
            case .notifications:
                RemindersView()
                    .environmentObject(container)
            
            case .share(let content):
                ShareSheet(content: content)
            }
        }
    }
    
    // MARK: - Full Screen Views
    @ViewBuilder
    func fullScreenView(for route: MainFullScreenRoute) -> some View {
        switch route {
        case .onboarding:
            // Show onboarding again
            EmptyView()
        
        case .auth:
            // Show auth flow
            EmptyView()
        }
    }
    
    // MARK: - Navigation Actions
    func navigateTo(route: MainRoute, in tab: TabRoute? = nil) {
        let targetTab = tab ?? selectedTab
        
        switch targetTab {
        case .dashboard:
            dashboardPath.append(route)
        case .calculator:
            calculatorPath.append(route)
        case .dailyQode:
            dailyQodePath.append(route)
        case .community:
            communityPath.append(route)
        case .profile:
            profilePath.append(route)
        }
    }
    
    func navigateBack(in tab: TabRoute? = nil) {
        let targetTab = tab ?? selectedTab
        
        switch targetTab {
        case .dashboard:
            if !dashboardPath.isEmpty { dashboardPath.removeLast() }
        case .calculator:
            if !calculatorPath.isEmpty { calculatorPath.removeLast() }
        case .dailyQode:
            if !dailyQodePath.isEmpty { dailyQodePath.removeLast() }
        case .community:
            if !communityPath.isEmpty { communityPath.removeLast() }
        case .profile:
            if !profilePath.isEmpty { profilePath.removeLast() }
        }
    }
    
    func navigateToRoot(in tab: TabRoute? = nil) {
        let targetTab = tab ?? selectedTab
        
        switch targetTab {
        case .dashboard:
            dashboardPath.removeLast(dashboardPath.count)
        case .calculator:
            calculatorPath.removeLast(calculatorPath.count)
        case .dailyQode:
            dailyQodePath.removeLast(dailyQodePath.count)
        case .community:
            communityPath.removeLast(communityPath.count)
        case .profile:
            profilePath.removeLast(profilePath.count)
        }
    }
    
    // MARK: - Specific Navigation Helpers
    func navigateToCalculator(with birthDate: Date? = nil) {
        selectedTab = .calculator
        navigateToRoot(in: .calculator)
    }
    
    func navigateToDailyQode(for date: Date = Date()) {
        selectedTab = .dailyQode
        navigateToRoot(in: .dailyQode)
    }
    
    func navigateToProfile(userId: String? = nil) {
        if let userId = userId {
            navigateTo(route: .profileDetail(userId: userId))
        } else {
            selectedTab = .profile
            navigateToRoot(in: .profile)
        }
    }
    
    func navigateToCommunity(postId: String? = nil) {
        selectedTab = .community
        if let postId = postId {
            navigateTo(route: .communityPost(postId: postId), in: .community)
        } else {
            navigateToRoot(in: .community)
        }
    }
    
    func navigateToLiveSessions() {
        selectedTab = .dashboard
        navigateTo(route: .liveSessions, in: .dashboard)
    }
    
    func navigateToSubscription() {
        navigateTo(route: .subscriptionDetails)
    }
    
    func showPaywall(source: String) {
        paywallSource = source
        showPaywall = true
        presentedSheet = .paywall(source: source)
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        presentedFullScreen = nil
    }
    
    // MARK: - Actions
    func logout() {
        onLogout?()
    }
    
    func share(content: ShareContent) {
        presentedSheet = .share(content: content)
    }
    
    func presentEditProfile() {
        presentedSheet = .editProfile
    }
    
    func presentNotifications() {
        presentedSheet = .notifications
    }
}

// MARK: - Main Routes
enum MainRoute: Hashable {
    // Features
    case birthChart
    case compatibility
    case journal
    case liveSessions
    case mentorship
    case challenges
    case aiChat
    
    // Settings
    case settings
    case notificationSettings
    case privacySettings
    case accountSettings
    
    // Subscription
    case subscriptionDetails
    
    // Library
    case library
    
    // Admin
    case adminDashboard
    
    // Profile
    case profileDetail(userId: String)
    
    // Community
    case communityPost(postId: String)
}

// MARK: - Sheet Routes
enum MainSheetRoute: Identifiable {
    case paywall(source: String)
    case editProfile
    case notifications
    case share(content: ShareContent)
    
    var id: String {
        switch self {
        case .paywall(let source):
            return "paywall-\(source)"
        case .editProfile:
            return "editProfile"
        case .notifications:
            return "notifications"
        case .share(let content):
            return "share-\(content.id)"
        }
    }
}

// MARK: - Full Screen Routes
enum MainFullScreenRoute: Identifiable {
    case onboarding
    case auth
    
    var id: String {
        switch self {
        case .onboarding:
            return "onboarding"
        case .auth:
            return "auth"
        }
    }
}

// MARK: - Share Content
struct ShareContent: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let url: URL?
    let image: UIImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShareContent, rhs: ShareContent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Placeholder Views (to be replaced with actual implementations)
struct SettingsView: View {
    let coordinator: MainCoordinator
    
    var body: some View {
        List {
            Section("Account") {
                NavigationLink("Account Settings", value: MainRoute.accountSettings)
                NavigationLink("Notifications", value: MainRoute.notificationSettings)
                NavigationLink("Privacy", value: MainRoute.privacySettings)
            }
            
            Section("Subscription") {
                NavigationLink("Manage Subscription", value: MainRoute.subscriptionDetails)
            }
            
            Section {
                Button("Log Out", role: .destructive) {
                    coordinator.logout()
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section {
                Toggle("Analytics", isOn: .constant(true))
                Toggle("Crash Reporting", isOn: .constant(true))
            }
            
            Section {
                Button("Export My Data") {}
                Button("Delete Account", role: .destructive) {}
            }
        }
        .navigationTitle("Privacy")
    }
}

struct AccountSettingsView: View {
    let coordinator: MainCoordinator
    
    var body: some View {
        List {
            Section("Profile") {
                Button("Edit Profile") {
                    coordinator.presentEditProfile()
                }
                Button("Change Password") {}
            }
            
            Section {
                Button("Log Out", role: .destructive) {
                    coordinator.logout()
                }
            }
        }
        .navigationTitle("Account")
    }
}

struct SubscriptionDetailsView: View {
    var body: some View {
        Text("Subscription Details")
            .navigationTitle("Subscription")
    }
}

struct ProfileDetailView: View {
    let userId: String
    
    var body: some View {
        Text("Profile: \(userId)")
            .navigationTitle("Profile")
    }
}

struct CommunityPostDetailView: View {
    let postId: String
    
    var body: some View {
        Text("Post: \(postId)")
            .navigationTitle("Post")
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Edit Profile")
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct ShareSheet: View {
    let content: ShareContent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Share")
                .font(.headline)
                .padding()
            
            Text(content.title)
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .padding()
        }
    }
}

// MARK: - Compatibility Engine View Placeholder
struct CompatibilityEngineView: View {
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        Text("Compatibility Engine")
            .navigationTitle("Compatibility")
    }
}

// MARK: - Community Challenges View Placeholder
struct CommunityChallengesView: View {
    var body: some View {
        Text("Community Challenges")
            .navigationTitle("Challenges")
    }
}
