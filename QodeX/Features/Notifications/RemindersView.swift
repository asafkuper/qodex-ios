//
//  RemindersView.swift
//  User-configurable reminders & notification settings
//

import SwiftUI

struct RemindersView: View {
    @StateObject private var viewModel = RemindersViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Enable/Disable All
                    masterToggle
                    
                    // Reminder Types
                    remindersList
                    
                    // Quiet Hours
                    quietHoursSection
                    
                    // Advanced
                    advancedSection
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stay Connected")
                .font(QodeXTypography.title)
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text("Choose when and how you want to be notified")
                .font(QodeXTypography.body)
                .foregroundStyle(QodeXColors.stardust)
        }
        .padding(.horizontal, 20)
    }
    
    private var masterToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("All Notifications")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text(notificationManager.isAuthorized ? "Enabled" : "Disabled")
                    .font(QodeXTypography.caption)
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.allNotificationsEnabled)
                .tint(QodeXColors.gold)
                .onChange(of: viewModel.allNotificationsEnabled) { enabled in
                    if enabled {
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                }
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var remindersList: some View {
        VStack(spacing: 16) {
            // Daily Qode
            ReminderCard(
                icon: "sparkles",
                iconColor: QodeXColors.gold,
                title: "Daily Qode",
                description: "Get your daily numerology insight",
                isEnabled: $viewModel.dailyQodeEnabled,
                time: $viewModel.dailyQodeTime
            )
            
            // Live Sessions
            ReminderCard(
                icon: "video.fill",
                iconColor: QodeXColors.mysticPurple,
                title: "Live Sessions",
                description: "15 minutes before sessions start",
                isEnabled: $viewModel.liveSessionEnabled
            )
            
            // Personal Sessions (Master tier only)
            if viewModel.userTier == .master {
                ReminderCard(
                    icon: "person.fill",
                    iconColor: QodeXColors.cosmicTeal,
                    title: "Personal Sessions",
                    description: "1 hour and 15 minutes before your 1:1",
                    isEnabled: $viewModel.personalSessionEnabled
                )
            }
            
            // Weekly Report
            ReminderCard(
                icon: "chart.bar.fill",
                iconColor: QodeXColors.gold,
                title: "Weekly Report",
                description: "Every Sunday with your week in review",
                isEnabled: $viewModel.weeklyReportEnabled
            )
            
            // Meditation
            ReminderCard(
                icon: "moon.fill",
                iconColor: QodeXColors.mysticPurple,
                title: "Meditation Practice",
                description: "Daily reminder for your spiritual practice",
                isEnabled: $viewModel.meditationEnabled,
                time: $viewModel.meditationTime
            )
            
            // Community Activity
            ReminderCard(
                icon: "bubble.left.fill",
                iconColor: QodeXColors.cosmicTeal,
                title: "Community Replies",
                description: "When someone responds to your posts",
                isEnabled: $viewModel.communityRepliesEnabled
            )
            
            // New Teachings
            ReminderCard(
                icon: "book.closed.fill",
                iconColor: QodeXColors.gold,
                title: "New Teachings",
                description: "When Shani releases new content",
                isEnabled: $viewModel.newTeachingsEnabled
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var quietHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiet Hours")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                Toggle("Enable Quiet Hours", isOn: $viewModel.quietHoursEnabled)
                    .tint(QodeXColors.gold)
                    .padding(16)
                
                if viewModel.quietHoursEnabled {
                    Divider()
                        .background(QodeXColors.starlight.opacity(0.3))
                        .padding(.horizontal, 16)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From")
                                .font(QodeXTypography.caption)
                                .foregroundStyle(QodeXColors.stardust)
                            
                            DatePicker("", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorMultiply(QodeXColors.gold)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundStyle(QodeXColors.stardust)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("To")
                                .font(QodeXTypography.caption)
                                .foregroundStyle(QodeXColors.stardust)
                            
                            DatePicker("", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorMultiply(QodeXColors.gold)
                        }
                    }
                    .padding(16)
                }
            }
            .background(QodeXColors.deepVoid)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                NavigationLink(destination: NotificationHistoryView()) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(QodeXColors.gold)
                            .frame(width: 24)
                        
                        Text("Notification History")
                            .font(.system(size: 16))
                            .foregroundStyle(QodeXColors.pureWhite)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(QodeXColors.stardust)
                    }
                    .padding(16)
                }
                
                Divider()
                    .background(QodeXColors.starlight.opacity(0.3))
                    .padding(.horizontal, 16)
                
                Button(action: {
                    notificationManager.clearBadge()
                }) {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundStyle(QodeXColors.gold)
                            .frame(width: 24)
                        
                        Text("Clear Badge Count")
                            .font(.system(size: 16))
                            .foregroundStyle(QodeXColors.pureWhite)
                        
                        Spacer()
                        
                        if notificationManager.unreadCount > 0 {
                            Text("\(notificationManager.unreadCount)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(QodeXColors.cosmicBlack)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(QodeXColors.gold)
                                .cornerRadius(10)
                        }
                    }
                    .padding(16)
                }
            }
            .background(QodeXColors.deepVoid)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Reminder Card

struct ReminderCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    var time: Binding<Date>?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.2))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Text(description)
                        .font(QodeXTypography.caption)
                        .foregroundStyle(QodeXColors.stardust)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .tint(QodeXColors.gold)
            }
            .padding(16)
            
            if isEnabled, let time = time {
                Divider()
                    .background(QodeXColors.starlight.opacity(0.3))
                    .padding(.horizontal, 16)
                
                HStack {
                    Text("Reminder Time")
                        .font(.system(size: 14))
                        .foregroundStyle(QodeXColors.stardust)
                    
                    Spacer()
                    
                    DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorMultiply(QodeXColors.gold)
                }
                .padding(16)
            }
        }
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

// MARK: - Notification History

struct NotificationHistoryView: View {
    @StateObject private var viewModel = NotificationHistoryViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            List {
                ForEach(viewModel.groupedNotifications.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(date).font(QodeXTypography.caption)) {
                        ForEach(viewModel.groupedNotifications[date] ?? []) { notification in
                            NotificationRow(notification: notification)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.delete(notification)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notificationManager.fetchNotifications()
        }
    }
}

struct NotificationRow: View {
    let notification: QodeXNotification
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon based on type
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text(notification.body)
                    .font(QodeXTypography.caption)
                    .foregroundStyle(QodeXColors.stardust)
                    .lineLimit(2)
                
                Text(timeAgo)
                    .font(.system(size: 11))
                    .foregroundStyle(QodeXColors.stardust)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(QodeXColors.gold)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(QodeXColors.deepVoid)
    }
    
    private var iconName: String {
        switch notification.type {
        case .dailyQode: return "sparkles"
        case .liveSession: return "video.fill"
        case .communityReply: return "bubble.left.fill"
        case .newTeaching: return "book.closed.fill"
        case .personalSession: return "person.fill"
        case .weeklyReport: return "chart.bar.fill"
        case .membershipExpiry: return "exclamationmark.triangle.fill"
        case .specialOffer: return "gift.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .dailyQode: return QodeXColors.gold
        case .liveSession: return QodeXColors.mysticPurple
        case .communityReply: return QodeXColors.cosmicTeal
        case .newTeaching: return QodeXColors.gold
        case .personalSession: return QodeXColors.cosmicTeal
        case .weeklyReport: return QodeXColors.gold
        case .membershipExpiry: return .red
        case .specialOffer: return QodeXColors.mysticPurple
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
}

// MARK: - View Models

class RemindersViewModel: ObservableObject {
    @Published var allNotificationsEnabled = true
    @Published var dailyQodeEnabled = true
    @Published var dailyQodeTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    @Published var liveSessionEnabled = true
    @Published var personalSessionEnabled = true
    @Published var weeklyReportEnabled = true
    @Published var meditationEnabled = false
    @Published var meditationTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))!
    @Published var communityRepliesEnabled = true
    @Published var newTeachingsEnabled = true
    @Published var quietHoursEnabled = false
    @Published var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0))!
    @Published var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!
    
    var userTier: MembershipTier = .master // Would come from subscription manager
}

class NotificationHistoryViewModel: ObservableObject {
    @Published var notifications: [QodeXNotification] = []
    
    var groupedNotifications: [String: [QodeXNotification]] {
        Dictionary(grouping: notifications) { notification in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: notification.createdAt)
        }
    }
    
    func delete(_ notification: QodeXNotification) async {
        // Delete from Firestore
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        RemindersView()
            .environmentObject(NotificationManager.shared)
    }
}
