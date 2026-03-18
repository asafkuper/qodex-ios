import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Profile & Settings Hub
struct ProfileHubView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedSection: ProfileSection = .overview
    
    enum ProfileSection {
        case overview, chart, subscription, notifications, support
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        ProfileHeaderView(user: viewModel.user)
                        
                        // Quick Stats
                        QuickStatsRow(stats: viewModel.stats)
                        
                        // Navigation Grid
                        NavigationGrid(selectedSection: $selectedSection)
                        
                        // Content based on selection
                        switch selectedSection {
                        case .overview:
                            OverviewSection(user: viewModel.user)
                        case .chart:
                            MiniChartSection(chart: viewModel.chart)
                        case .subscription:
                            SubscriptionStatusSection(subscription: viewModel.subscription)
                        case .notifications:
                            NotificationSettingsSection()
                        case .support:
                            SupportSection()
                        }
                        
                        // Danger Zone
                        DangerZoneSection()
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .environmentObject(viewModel.authManager)
        }
    }
}

// MARK: - View Model
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile
    @Published var stats: UserStats
    @Published var chart: BirthChart
    @Published var subscription: SubscriptionInfo
    @Published var authManager = AuthManager.shared
    
    init() {
        // Mock data - replace with Firebase
        self.user = UserProfile(
            id: "1",
            name: "Alexandra",
            email: "alex@example.com",
            avatar: "A",
            lifePath: 7,
            joinDate: Date().addingTimeInterval(-86400 * 30),
            streak: 12
        )
        
        self.stats = UserStats(
            daysActive: 28,
            sessionsAttended: 5,
            postsMade: 12,
            readingsCompleted: 45
        )
        
        self.chart = BirthChart(
            lifePath: 7,
            expression: 3,
            soulUrge: 6,
            personality: 9,
            birthday: 4,
            maturity: 5
        )
        
        self.subscription = SubscriptionInfo(
            tier: .initiate,
            startDate: Date().addingTimeInterval(-86400 * 15),
            renewalDate: Date().addingTimeInterval(86400 * 15),
            isActive: true,
            isYearly: true
        )
    }
}

// MARK: - Models
struct UserProfile {
    let id: String
    let name: String
    let email: String
    let avatar: String
    let lifePath: Int
    let joinDate: Date
    let streak: Int
}

struct UserStats {
    let daysActive: Int
    let sessionsAttended: Int
    let postsMade: Int
    let readingsCompleted: Int
}

struct BirthChart {
    let lifePath: Int
    let expression: Int
    let soulUrge: Int
    let personality: Int
    let birthday: Int
    let maturity: Int
}

struct SubscriptionInfo {
    let tier: MembershipTier
    let startDate: Date
    let renewalDate: Date
    let isActive: Bool
    let isYearly: Bool
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: renewalDate).day ?? 0
    }
}

struct NotificationSettings {
    var dailyQode: Bool
    var liveSessions: Bool
    var communityMentions: Bool
    var streakReminders: Bool
    var marketingEmails: Bool
}

// MARK: - Views
struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        HStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.5), .gold.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(user.avatar)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Text("Life Path \(user.lifePath)")
                        .font(.subheadline)
                        .foregroundColor(.gold)
                    
                    Text("•")
                        .foregroundColor(.secondaryText)
                    
                    Text("Member since \(user.joinDate.formatted(.dateTime.month().year()))")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(user.streak) day streak")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.2))
                )
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.gold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.deepSpace)
        )
    }
}

struct QuickStatsRow: View {
    let stats: UserStats
    
    var body: some View {
        HStack(spacing: 12) {
            StatBox(value: "\(stats.daysActive)", label: "Days")
            StatBox(value: "\(stats.sessionsAttended)", label: "Sessions")
            StatBox(value: "\(stats.postsMade)", label: "Posts")
            StatBox(value: "\(stats.readingsCompleted)", label: "Qodes")
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deepSpace)
        )
    }
}

struct NavigationGrid: View {
    @Binding var selectedSection: ProfileHubView.ProfileSection
    
    let sections: [(ProfileHubView.ProfileSection, String, String)] = [
        (.overview, "Overview", "house.fill"),
        (.chart, "My Chart", "chart.pie.fill"),
        (.subscription, "Subscription", "crown.fill"),
        (.notifications, "Notifications", "bell.fill"),
        (.support, "Support", "questionmark.circle.fill")
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(sections, id: \.0) { section, title, icon in
                NavigationButton(
                    title: title,
                    icon: icon,
                    isSelected: selectedSection == section
                ) {
                    withAnimation(.spring()) {
                        selectedSection = section
                    }
                }
            }
        }
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.gold : Color.deepSpace)
            )
        }
    }
}

struct OverviewSection: View {
    let user: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.headline)
            
            InfoRow(icon: "envelope.fill", label: "Email", value: user.email)
            InfoRow(icon: "calendar", label: "Birth Date", value: "March 15, 1990")
            InfoRow(icon: "clock", label: "Birth Time", value: "7:30 AM")
            InfoRow(icon: "location.fill", label: "Timezone", value: "EST (New York)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gold)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

struct MiniChartSection: View {
    let chart: BirthChart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Core Numbers")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: InteractiveBirthChartView()) {
                    Text("View Full Chart")
                        .font(.caption)
                        .foregroundColor(.gold)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MiniNumberCard(number: chart.lifePath, title: "Life Path", color: .gold)
                MiniNumberCard(number: chart.expression, title: "Expression", color: .purple)
                MiniNumberCard(number: chart.soulUrge, title: "Soul Urge", color: .pink)
                MiniNumberCard(number: chart.personality, title: "Personality", color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct MiniNumberCard: View {
    let number: Int
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SubscriptionStatusSection: View {
    let subscription: SubscriptionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subscription")
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(isActive: subscription.isActive)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.gold)
                    
                    Text(subscription.tier.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                InfoRow(icon: "calendar", label: "Started", value: subscription.startDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(icon: "arrow.clockwise", label: "Renews", value: "\(subscription.daysRemaining) days")
                InfoRow(icon: "creditcard", label: "Billing", value: subscription.isYearly ? "Yearly" : "Monthly")
            }
            
            Button(action: {}) {
                Text("Manage Subscription")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.gold)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct StatusBadge: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 6, height: 6)
            
            Text(isActive ? "Active" : "Expired")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isActive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
        )
        .foregroundColor(isActive ? .green : .red)
    }
}

struct NotificationSettingsSection: View {
    @AppStorage("notifications_dailyQode") private var dailyQode = true
    @AppStorage("notifications_liveSessions") private var liveSessions = true
    @AppStorage("notifications_communityMentions") private var communityMentions = true
    @AppStorage("notifications_streakReminders") private var streakReminders = true
    @AppStorage("notifications_marketingEmails") private var marketingEmails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Preferences")
                .font(.headline)
            
            VStack(spacing: 0) {
                ToggleRow(icon: "sparkles", title: "Daily Qode", isOn: $dailyQode)
                    .accessibilityLabel("Daily Qode notifications")
                    .accessibilityHint("Receive daily numerology insights")
                Divider().background(Color.white.opacity(0.1))
                ToggleRow(icon: "video.fill", title: "Live Sessions", isOn: $liveSessions)
                    .accessibilityLabel("Live session notifications")
                    .accessibilityHint("Get reminded about upcoming live sessions")
                Divider().background(Color.white.opacity(0.1))
                ToggleRow(icon: "bubble.left.fill", title: "Community Mentions", isOn: $communityMentions)
                    .accessibilityLabel("Community mention notifications")
                    .accessibilityHint("Be notified when someone mentions you")
                Divider().background(Color.white.opacity(0.1))
                ToggleRow(icon: "flame.fill", title: "Streak Reminders", isOn: $streakReminders)
                    .accessibilityLabel("Streak reminders")
                    .accessibilityHint("Reminders to maintain your daily streak")
                Divider().background(Color.white.opacity(0.1))
                ToggleRow(icon: "envelope.fill", title: "Marketing Emails", isOn: $marketingEmails)
                    .accessibilityLabel("Marketing emails")
                    .accessibilityHint("Receive promotional content and updates")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gold)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .gold))
        }
        .padding(.vertical, 8)
    }
}

struct SupportSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Help & Support")
                .font(.headline)
            
            VStack(spacing: 0) {
                SupportRow(icon: "questionmark.circle", title: "FAQ")
                Divider().background(Color.white.opacity(0.1))
                SupportRow(icon: "envelope", title: "Contact Support")
                Divider().background(Color.white.opacity(0.1))
                SupportRow(icon: "book", title: "Privacy Policy")
                Divider().background(Color.white.opacity(0.1))
                SupportRow(icon: "doc.text", title: "Terms of Service")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct SupportRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gold)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .padding(.vertical, 12)
        }
    }
}

struct DangerZoneSection: View {
    @State private var showSignOutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                Button(action: { showSignOutConfirmation = true }) {
                    HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("Sign Out")
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                
                Button(action: { showDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Account")
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                do {
                    try authManager.signOut()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        Task {
            do {
                // Delete user data from Firestore
                try await Firestore.firestore().collection("users").document(user.uid).delete()
                
                // Delete Firebase Auth account
                try await user.delete()
                
                // Sign out
                try authManager.signOut()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileHubView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHubView()
            .preferredColorScheme(.dark)
    }
}
