//
//  AdminDashboardView.swift
//  Shani's Admin Panel for managing the app
//

import SwiftUI
import Charts

struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                QodeXColors.cosmicBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        adminHeader
                        
                        // Key Metrics
                        metricsGrid
                        
                        // Revenue Chart
                        revenueSection
                        
                        // User Growth
                        userGrowthSection
                        
                        // Recent Activity
                        activitySection
                        
                        // Quick Actions
                        quickActions
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var adminHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back, Shani")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text("QodeX is thriving today")
                    .font(QodeXTypography.body)
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            // Live indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("LIVE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCard(
                title: "Total Users",
                value: "\(viewModel.totalUsers)",
                change: "+12%",
                isPositive: true,
                icon: "person.3",
                color: QodeXColors.gold
            )
            
            MetricCard(
                title: "Active Today",
                value: "\(viewModel.activeToday)",
                change: "+8%",
                isPositive: true,
                icon: "flame",
                color: QodeXColors.cosmicTeal
            )
            
            MetricCard(
                title: "MRR",
                value: "$",
                change: "+23%",
                isPositive: true,
                icon: "dollarsign.circle",
                color: QodeXColors.mysticPurple
            )
            
            MetricCard(
                title: "Churn Rate",
                value: "\(viewModel.churnRate)%",
                change: "-2%",
                isPositive: true,
                icon: "arrow.down.circle",
                color: Color.red
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var revenueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Revenue")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Picker("Period", selection: $viewModel.revenuePeriod) {
                    Text("7D").tag(7)
                    Text("30D").tag(30)
                    Text("90D").tag(90)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            .padding(.horizontal, 20)
            
            // Revenue Chart
            Chart(viewModel.revenueData) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Revenue", point.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [QodeXColors.gold.opacity(0.3), QodeXColors.gold.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Revenue", point.amount)
                )
                .foregroundStyle(QodeXColors.gold)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 200)
            .padding(20)
            .background(QodeXColors.deepVoid)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    private var userGrowthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("User Growth by Tier")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                TierGrowthCard(tier: .seeker, count: viewModel.seekerCount, color: QodeXColors.gold)
                TierGrowthCard(tier: .initiate, count: viewModel.initiateCount, color: QodeXColors.mysticPurple)
                TierGrowthCard(tier: .master, count: viewModel.masterCount, color: QodeXColors.cosmicTeal)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Button("View All") {}
                    .font(QodeXTypography.caption)
                    .foregroundStyle(QodeXColors.gold)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentActivity) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                AdminActionRow(icon: "video.badge.plus", title: "Schedule Live Session", color: QodeXColors.mysticPurple)
                AdminActionRow(icon: "book.closed", title: "Upload New Teaching", color: QodeXColors.gold)
                AdminActionRow(icon: "bell.badge", title: "Send Push Notification", color: QodeXColors.cosmicTeal)
                AdminActionRow(icon: "envelope", title: "Email All Members", color: QodeXColors.stardust)
                AdminActionRow(icon: "chart.bar", title: "View Detailed Analytics", color: QodeXColors.gold)
            }
            .background(QodeXColors.deepVoid)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                
                Spacer()
                
                Text(change)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isPositive ? Color.green : Color.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((isPositive ? Color.green : Color.red).opacity(0.2))
                    .cornerRadius(6)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text(title)
                .font(QodeXTypography.caption)
                .foregroundStyle(QodeXColors.stardust)
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

struct TierGrowthCard: View {
    let tier: MembershipTier
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(tier.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(QodeXColors.stardust)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)
            
            // Mini progress bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * 0.6)
                        , alignment: .leading
                    )
            }
            .frame(height: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let activity: AdminActivity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(activity.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activity.icon)
                    .foregroundStyle(activity.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .font(.system(size: 14))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text(activity.timeAgo)
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

struct AdminActionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(QodeXColors.stardust)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Model

class AdminViewModel: ObservableObject {
    @Published var totalUsers = 2847
    @Published var activeToday = 423
    @Published var mrr = 28450
    @Published var churnRate = 4.2
    @Published var revenuePeriod = 7
    
    @Published var seekerCount = 1847
    @Published var initiateCount = 756
    @Published var masterCount = 244
    
    @Published var revenueData: [RevenuePoint] = []
    @Published var recentActivity: [AdminActivity] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Generate mock revenue data
        let calendar = Calendar.current
        revenueData = (0..<30).map { day in
            RevenuePoint(
                date: calendar.date(byAdding: .day, value: -day, to: Date())!,
                amount: Double.random(in: 800...1500)
            )
        }.reversed()
        
        // Mock activities
        recentActivity = [
            AdminActivity(description: "New Master tier subscriber: Sarah K.", timeAgo: "2 min ago", icon: "crown.fill", color: QodeXColors.gold),
            AdminActivity(description: "Live session 'Master Numbers' ended", timeAgo: "15 min ago", icon: "video.fill", color: QodeXColors.mysticPurple),
            AdminActivity(description: "New teaching uploaded: 'Decoding Cycles'", timeAgo: "1 hour ago", icon: "book.closed", color: QodeXColors.cosmicTeal),
            AdminActivity(description: "Community post flagged for review", timeAgo: "2 hours ago", icon: "exclamationmark.triangle", color: Color.red),
        ]
    }
}

struct RevenuePoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct AdminActivity: Identifiable {
    let id = UUID()
    let description: String
    let timeAgo: String
    let icon: String
    let color: Color
}

// MARK: - Preview

#Preview {
    AdminDashboardView()
}
