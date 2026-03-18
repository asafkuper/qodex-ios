//
//  NotificationBadgeView.swift
//  In-app notification center badge
//

import SwiftUI

struct NotificationBadgeView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QodeXColors.gold)
                .frame(width: 20, height: 20)
            
            Text(min(count, 99), format: .number)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(QodeXColors.cosmicBlack)
        }
        .opacity(count > 0 ? 1 : 0)
        .scaleEffect(count > 0 ? 1 : 0.5)
        .animation(.spring(response: 0.3), value: count)
    }
}

struct NotificationBellButton: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showNotificationCenter = false
    
    var body: some View {
        Button(action: { showNotificationCenter = true }) {
            ZStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                NotificationBadgeView(count: notificationManager.unreadCount)
                    .offset(x: 8, y: -8)
            }
        }
        .sheet(isPresented: $showNotificationCenter) {
            NotificationCenterView()
        }
    }
}

struct NotificationCenterView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                QodeXColors.cosmicBlack.ignoresSafeArea()
                
                List {
                    ForEach(groupedNotifications.keys.sorted(by: >), id: \.self) { date in
                        Section(header: sectionHeader(date)) {
                            ForEach(groupedNotifications[date] ?? []) { notification in
                                NotificationListItem(notification: notification)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            // Delete
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        if !notification.isRead {
                                            Button {
                                                Task {
                                                    await markAsRead(notification)
                                                }
                                            } label: {
                                                Label("Read", systemImage: "envelope.open")
                                            }
                                            .tint(QodeXColors.gold)
                                        }
                                    }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
                if notificationManager.notifications.isEmpty {
                    EmptyNotificationsView()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(QodeXColors.gold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notificationManager.unreadCount > 0 {
                        Button("Mark All Read") {
                            Task {
                                await markAllAsRead()
                            }
                        }
                        .foregroundStyle(QodeXColors.gold)
                    }
                }
            }
        }
        .task {
            await notificationManager.fetchNotifications()
        }
    }
    
    private var groupedNotifications: [String: [QodeXNotification]] {
        Dictionary(grouping: notificationManager.notifications) { notification in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: notification.createdAt)
        }
    }
    
    private func sectionHeader(_ date: String) -> some View {
        Text(date)
            .font(QodeXTypography.caption)
            .foregroundStyle(QodeXColors.stardust)
            .textCase(nil)
    }
    
    private func markAsRead(_ notification: QodeXNotification) async {
        if let id = notification.id {
            await notificationManager.markAsRead(notificationId: id)
        }
    }
    
    private func markAllAsRead() async {
        for notification in notificationManager.notifications where !notification.isRead {
            if let id = notification.id {
                await notificationManager.markAsRead(notificationId: id)
            }
        }
    }
}

struct NotificationListItem: View {
    let notification: QodeXNotification
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.isRead ? .regular : .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Spacer()
                    
                    Text(timeString)
                        .font(.system(size: 11))
                        .foregroundStyle(QodeXColors.stardust)
                }
                
                Text(notification.body)
                    .font(.system(size: 13))
                    .foregroundStyle(QodeXColors.stardust)
                    .lineLimit(2)
                
                if let actionText = actionButtonText {
                    Text(actionText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(QodeXColors.gold)
                        .padding(.top, 4)
                }
            }
            
            if !notification.isRead {
                Circle()
                    .fill(QodeXColors.gold)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
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
    
    private var iconBackground: Color {
        iconColor.opacity(0.15)
    }
    
    private var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
    
    private var actionButtonText: String? {
        switch notification.type {
        case .dailyQode: return "View My Qode →"
        case .liveSession: return "Join Live →"
        case .newTeaching: return "Start Learning →"
        case .personalSession: return "Prepare for Session →"
        default: return nil
        }
    }
    
    private func handleTap() {
        // Handle navigation based on notification type
        NotificationCenter.default.post(
            name: .handleNotificationTap,
            object: notification
        )
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(QodeXColors.starlight.opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Text("No Notifications")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text("You're all caught up! We'll notify you when something important happens.")
                .font(QodeXTypography.body)
                .foregroundStyle(QodeXColors.stardust)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let handleNotificationTap = Notification.Name("handleNotificationTap")
}

// MARK: - Preview

#Preview {
    NotificationCenterView()
        .environmentObject(NotificationManager.shared)
}
