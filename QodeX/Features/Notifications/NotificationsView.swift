//
//  NotificationsView.swift
//  QodeX - Premium Notification Preferences
//  Inspired by iOS Settings, Instagram
//

import SwiftUI

struct NotificationsView: View {
    @State private var dailyReadingEnabled = true
    @State private var powerHoursEnabled = true
    @State private var compatibilityAlerts = true
    @State private var communityActivity = true
    @State private var liveSessions = true
    @State private var marketingEmails = false
    
    @State private var dailyReadingTime = Date()
    @State private var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22))!
    @State private var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 8))!
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    Text("Notifications")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.starlight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Main Toggles
                    NotificationGroup(title: "Essential") {
                        NotificationToggle(
                            icon: "sun.max.fill",
                            iconColor: .goldPrimary,
                            title: "Daily Reading",
                            subtitle: "Your personalized daily number",
                            isOn: $dailyReadingEnabled
                        )
                        
                        if dailyReadingEnabled {
                            TimePickerRow(title: "Delivery Time", date: $dailyReadingTime)
                        }
                        
                        NotificationToggle(
                            icon: "clock.fill",
                            iconColor: .blue,
                            title: "Power Hours",
                            subtitle: "Optimal times based on your Life Path",
                            isOn: $powerHoursEnabled
                        )
                        
                        NotificationToggle(
                            icon: "heart.fill",
                            iconColor: .pink,
                            title: "Compatibility Alerts",
                            subtitle: "When friends update their charts",
                            isOn: $compatibilityAlerts
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Social
                    NotificationGroup(title: "Social") {
                        NotificationToggle(
                            icon: "person.3.fill",
                            iconColor: .purple,
                            title: "Community Activity",
                            subtitle: "Likes, comments, and mentions",
                            isOn: $communityActivity
                        )
                        
                        NotificationToggle(
                            icon: "video.fill",
                            iconColor: .red,
                            title: "Live Sessions",
                            subtitle: "When experts go live",
                            isOn: $liveSessions
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Quiet Hours
                    NotificationGroup(title: "Quiet Hours") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.indigo)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.indigo.opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Do Not Disturb")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.starlight)
                                    
                                    Text("Pause all notifications")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.starlightTertiary)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("From")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.starlightTertiary)
                                    
                                    DatePicker("", selection: $quietHoursStart, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorMultiply(.goldPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("To")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.starlightTertiary)
                                    
                                    DatePicker("", selection: $quietHoursEnd, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorMultiply(.goldPrimary)
                                }
                            }
                        }
                        .padding(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Marketing
                    NotificationGroup(title: "Other") {
                        NotificationToggle(
                            icon: "envelope.fill",
                            iconColor: .gray,
                            title: "Marketing Emails",
                            subtitle: "Tips, offers, and updates",
                            isOn: $marketingEmails
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Notification Group
struct NotificationGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.starlightTertiary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

// MARK: - Notification Toggle
struct NotificationToggle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlight)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .goldPrimary))
        }
        .padding(12)
    }
}

// MARK: - Time Picker Row
struct TimePickerRow: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.starlight)
            
            Spacer()
            
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorMultiply(.goldPrimary)
        }
        .padding(12)
        .background(Color.goldPrimary.opacity(0.05))
    }
}

// MARK: - Preview
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .preferredColorScheme(.dark)
    }
}
