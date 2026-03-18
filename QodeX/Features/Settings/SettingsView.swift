//
//  SettingsView.swift
//  QodeX - Premium Settings
//  Inspired by iOS Settings, Notion
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var soundEnabled = true
    @State private var hapticEnabled = true
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
    @State private var isDeleting = false
    @State private var showNumerologySystemSheet = false
    
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var systemManager = NumerologySystemManager.shared
    
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
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.starlight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .accessibilityLabel("Settings")
                        .accessibilityHint("App settings screen")
                    
                    // Profile Section
                    ProfileSettingsSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Notifications
                    SettingsGroup(title: "Notifications") {
                        ToggleSettingRow(
                            icon: "bell.fill",
                            iconColor: .red,
                            title: "Push Notifications",
                            isOn: $notificationsEnabled
                        )
                        .accessibilityLabel("Push Notifications")
                        .accessibilityHint("Toggle to receive push notifications from the app")
                        .accessibilityValue(notificationsEnabled ? "On" : "Off")
                        
                        NavigationSettingRow(
                            icon: "clock.fill",
                            iconColor: .blue,
                            title: "Reminder Times"
                        )
                        .accessibilityLabel("Reminder Times")
                        .accessibilityHint("Double tap to configure notification reminder times")
                        
                        NavigationSettingRow(
                            icon: "envelope.fill",
                            iconColor: .green,
                            title: "Email Updates"
                        )
                        .accessibilityLabel("Email Updates")
                        .accessibilityHint("Double tap to manage email notification preferences")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Appearance
                    SettingsGroup(title: "Appearance") {
                        ToggleSettingRow(
                            icon: "moon.fill",
                            iconColor: .purple,
                            title: "Dark Mode",
                            isOn: $darkModeEnabled
                        )
                        .accessibilityLabel("Dark Mode")
                        .accessibilityHint("Toggle to switch between dark and light appearance")
                        .accessibilityValue(darkModeEnabled ? "On" : "Off")
                        
                        NavigationSettingRow(
                            icon: "textformat.size",
                            iconColor: .orange,
                            title: "Text Size"
                        )
                        .accessibilityLabel("Text Size")
                        .accessibilityHint("Double tap to adjust text size preferences")
                        
                        NavigationSettingRow(
                            icon: "globe",
                            iconColor: .cyan,
                            title: "Language"
                        )
                        .accessibilityLabel("Language")
                        .accessibilityHint("Double tap to change app language")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Numerology System
                    SettingsGroup(title: "Numerology") {
                        Button(action: { showNumerologySystemSheet = true }) {
                            HStack(spacing: 12) {
                                SettingIcon(icon: "number.circle.fill", color: .indigo)
                                    .accessibilityHidden(true)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Numerology System")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.starlight)
                                    
                                    Text(systemManager.currentSystem.rawValue)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.starlightTertiary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.starlightQuaternary)
                                    .accessibilityHidden(true)
                            }
                            .padding(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Numerology System")
                        .accessibilityHint("Double tap to change numerology calculation system. Currently using \(systemManager.currentSystem.rawValue)")
                        
                        NavigationSettingRow(
                            icon: "book.fill",
                            iconColor: .teal,
                            title: "Learn About Systems"
                        )
                        .accessibilityLabel("Learn About Systems")
                        .accessibilityHint("Double tap to learn about Pythagorean and Chaldean numerology systems")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .sheet(isPresented: $showNumerologySystemSheet) {
                        NumerologySystemSelectionSheet()
                    }
                    
                    // Sound & Haptics
                    SettingsGroup(title: "Sound & Haptics") {
                        ToggleSettingRow(
                            icon: "speaker.wave.2.fill",
                            iconColor: .pink,
                            title: "Sound Effects",
                            isOn: $soundEnabled
                        )
                        .accessibilityLabel("Sound Effects")
                        .accessibilityHint("Toggle to enable or disable app sound effects")
                        .accessibilityValue(soundEnabled ? "On" : "Off")
                        
                        ToggleSettingRow(
                            icon: "hand.tap.fill",
                            iconColor: .yellow,
                            title: "Haptic Feedback",
                            isOn: $hapticEnabled
                        )
                        .accessibilityLabel("Haptic Feedback")
                        .accessibilityHint("Toggle to enable or disable vibration feedback")
                        .accessibilityValue(hapticEnabled ? "On" : "Off")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Privacy & Security
                    SettingsGroup(title: "Privacy & Security") {
                        NavigationSettingRow(
                            icon: "lock.fill",
                            iconColor: .green,
                            title: "Privacy Settings"
                        )
                        .accessibilityLabel("Privacy Settings")
                        .accessibilityHint("Double tap to manage your privacy preferences")
                        
                        NavigationSettingRow(
                            icon: "shield.fill",
                            iconColor: .blue,
                            title: "Security"
                        )
                        .accessibilityLabel("Security")
                        .accessibilityHint("Double tap to configure security options like password and two-factor authentication")
                        
                        NavigationSettingRow(
                            icon: "arrow.down.circle.fill",
                            iconColor: .orange,
                            title: "Data Export"
                        )
                        .accessibilityLabel("Data Export")
                        .accessibilityHint("Double tap to export your data")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Support
                    SettingsGroup(title: "Support") {
                        NavigationSettingRow(
                            icon: "questionmark.circle.fill",
                            iconColor: .purple,
                            title: "Help Center"
                        )
                        .accessibilityLabel("Help Center")
                        .accessibilityHint("Double tap to view help articles and FAQs")
                        
                        NavigationSettingRow(
                            icon: "envelope.fill",
                            iconColor: .blue,
                            title: "Contact Support"
                        )
                        .accessibilityLabel("Contact Support")
                        .accessibilityHint("Double tap to get in touch with our support team")
                        
                        NavigationSettingRow(
                            icon: "star.fill",
                            iconColor: .yellow,
                            title: "Rate QodeX"
                        )
                        .accessibilityLabel("Rate QodeX")
                        .accessibilityHint("Double tap to rate the app in the App Store")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // About
                    SettingsGroup(title: "About") {
                        HStack {
                            SettingIcon(icon: "info.circle.fill", color: .gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Version")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.starlight)
                                
                                Text("1.0.0 (Build 42)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.starlightTertiary)
                            }
                            
                            Spacer()
                        }
                        .accessibilityLabel("App Version")
                        .accessibilityHint("Current version is 1.0.0, Build 42")
                        .accessibilityElement(children: .combine)
                        
                        NavigationSettingRow(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "Terms of Service"
                        )
                        .accessibilityLabel("Terms of Service")
                        .accessibilityHint("Double tap to read the terms of service")
                        
                        NavigationSettingRow(
                            icon: "hand.raised.fill",
                            iconColor: .gray,
                            title: "Privacy Policy"
                        )
                        .accessibilityLabel("Privacy Policy")
                        .accessibilityHint("Double tap to read the privacy policy")
                        
                        NavigationSettingRow(
                            icon: "doc.plaintext",
                            iconColor: .gray,
                            title: "Acknowledgments"
                        )
                        .accessibilityLabel("Acknowledgments")
                        .accessibilityHint("Double tap to view third-party licenses and acknowledgments")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Sign Out
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Sign Out")
                    .accessibilityHint("Double tap to sign out of your account")
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Delete Account
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Spacer()
                            
                            if isDeleting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                    .accessibilityLabel("Deleting account")
                                    .accessibilityHint("Please wait while your account is being deleted")
                            } else {
                                Text("Delete Account")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                    }
                    .disabled(isDeleting)
                    .accessibilityLabel("Delete Account")
                    .accessibilityHint("Double tap to permanently delete your account and all associated data")
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                    .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) { }
                            .accessibilityLabel("Cancel")
                            .accessibilityHint("Double tap to keep your account and cancel deletion")
                        Button("Delete", role: .destructive) {
                            Task {
                                await deleteAccount()
                            }
                        }
                        .accessibilityLabel("Delete")
                        .accessibilityHint("Double tap to permanently delete your account. This action cannot be undone")
                    } message: {
                        Text("This will permanently delete your account and all data. This action cannot be undone.")
                    }
                    .alert("Delete Failed", isPresented: $showDeleteError) {
                        Button("OK", role: .cancel) { }
                            .accessibilityLabel("OK")
                            .accessibilityHint("Double tap to dismiss the error message")
                    } message: {
                        Text(deleteErrorMessage)
                    }
                }
            }
        }
    }
    
    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }
        
        let result = await authManager.deleteAccount()
        
        switch result {
        case .success:
            // Account deleted - auth state listener will handle logout
            break
        case .failure(let error):
            deleteErrorMessage = error.localizedDescription
            showDeleteError = true
        }
    }
}

// MARK: - Profile Settings Section
struct ProfileSettingsSection: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.goldPrimary.opacity(0.2))
                        .frame(width: 64, height: 64)
                    
                    Text("SJ")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.starlight)
                    
                    // Edit badge
                    ZStack {
                        Circle()
                            .fill(Color(hex: "12121A"))
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .fill(Color.goldPrimary)
                            .frame(width: 18, height: 18)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.cosmicBlack)
                    }
                    .offset(x: 20, y: 20)
                    .accessibilityHidden(true)
                }
                .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sarah Johnson")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    Text("sarah.j@email.com")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.starlightQuaternary)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Profile, Sarah Johnson, sarah.j at email dot com")
        .accessibilityHint("Double tap to edit your profile information")
    }
}

// MARK: - Settings Group
struct SettingsGroup<Content: View>: View {
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
                .accessibilityLabel(title)
                .accessibilityHint("Section containing \(title.lowercased()) settings")
            
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

// MARK: - Navigation Setting Row
struct NavigationSettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                SettingIcon(icon: icon, color: iconColor)
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                        .accessibilityLabel("Current value: \(value)")
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.starlightQuaternary)
                    .accessibilityHidden(true)
            }
            .padding(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Toggle Setting Row
struct ToggleSettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            SettingIcon(icon: icon, color: iconColor)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.starlight)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .goldPrimary))
                .accessibilityLabel(title)
                .accessibilityHint("Double tap to toggle \(title.lowercased())")
                .accessibilityValue(isOn ? "On" : "Off")
        }
        .padding(12)
    }
}

// MARK: - Setting Icon
struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
    }
}

// MARK: - Numerology System Selection Sheet
struct NumerologySystemSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var systemManager = NumerologySystemManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.indigo)
                            
                            Text("Numerology System")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.starlight)
                            
                            Text("Choose your preferred calculation method")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.starlightTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // System Options
                        VStack(spacing: 12) {
                            ForEach(NumerologySystem.allCases) { system in
                                SystemSelectionCard(
                                    system: system,
                                    isSelected: systemManager.currentSystem == system
                                ) {
                                    systemManager.currentSystem = system
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Comparison Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("System Comparison")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.starlight)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ComparisonRow(
                                    title: "Origin",
                                    pythagorean: "Ancient Greece (6th century BCE)",
                                    chaldean: "Ancient Babylon (~4000 BCE)"
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ComparisonRow(
                                    title: "Method",
                                    pythagorean: "Alphabetical order (A=1, B=2, etc.)",
                                    chaldean: "Sound vibration & planetary energy"
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ComparisonRow(
                                    title: "Focus",
                                    pythagorean: "Personality & life purpose",
                                    chaldean: "Karmic patterns & spirituality"
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ComparisonRow(
                                    title: "Best For",
                                    pythagorean: "Beginners, general readings",
                                    chaldean: "Advanced users, business decisions"
                                )
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "12121A").opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Learn More Button
                        NavigationLink(destination: ChaldeanEducationView()) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                Text("Learn More About Chaldean System")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.indigo)
                            .padding(.vertical, 12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.indigo)
                }
            }
        }
    }
}

// MARK: - System Selection Card
struct SystemSelectionCard: View {
    let system: NumerologySystem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.indigo.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: system == .pythagorean ? "triangle.fill" : "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .indigo : .gray)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(system.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    Text(system.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.indigo)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.indigo.opacity(0.1) : Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    let title: String
    let pythagorean: String
    let chaldean: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.starlightTertiary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pythagorean")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.indigo)
                    Text(pythagorean)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.starlight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chaldean")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.purple)
                    Text(chaldean)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.starlight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Chaldean Education View
struct ChaldeanEducationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "1a0a2e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Hero Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Text("𒀭")
                                .font(.system(size: 48))
                        }
                        
                        Text("Chaldean Numerology")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                            .multilineTextAlignment(.center)
                        
                        Text("The Ancient Babylonian System")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    .padding(.top, 20)
                    
                    // Content Sections
                    VStack(spacing: 24) {
                        // Origin Section
                        EducationSection(
                            icon: "globe",
                            title: "Ancient Origins",
                            content: "Originating in ancient Babylon (modern-day Iraq) around 4000 BCE, the Chaldean system is one of the oldest known forms of numerology. The Chaldeans were master astrologers, mathematicians, and mystics who believed that numbers held the key to understanding the universe."
                        )
                        
                        // Philosophy Section
                        EducationSection(
                            icon: "waveform",
                            title: "Vibration-Based Philosophy",
                            content: "Unlike the Pythagorean system which assigns numbers alphabetically, Chaldean numerology is based on the sound vibration and energy of each letter. The ancient Chaldeans believed that everything in the universe vibrates at a specific frequency, and these vibrations correspond to numerical values."
                        )
                        
                        // Key Differences
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                
                                Text("Key Differences")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.starlight)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                DifferenceRow(
                                    number: "1",
                                    title: "Sound-Based",
                                    description: "Letters assigned by vibrational energy, not alphabetical position"
                                )
                                
                                DifferenceRow(
                                    number: "2",
                                    title: "Sacred Nine",
                                    description: "No letters assigned to 9 - it's reserved for divine energy"
                                )
                                
                                DifferenceRow(
                                    number: "3",
                                    title: "Compound Numbers",
                                    description: "Special meanings for double-digit numbers (10-52)"
                                )
                                
                                DifferenceRow(
                                    number: "4",
                                    title: "Planetary Links",
                                    description: "Each number corresponds to planetary energy"
                                )
                                
                                DifferenceRow(
                                    number: "5",
                                    title: "More Mystical",
                                    description: "Considered more spiritual and occult than Pythagorean"
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "12121A").opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Letter Values
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "textformat.abc")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                
                                Text("Chaldean Letter Values")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.starlight)
                            }
                            
                            VStack(spacing: 8) {
                                LetterValueRow(number: 1, letters: "A, I, J, Q, Y", planet: "Sun ☉")
                                LetterValueRow(number: 2, letters: "B, K, R", planet: "Moon ☽")
                                LetterValueRow(number: 3, letters: "C, G, L, S", planet: "Jupiter ♃")
                                LetterValueRow(number: 4, letters: "D, M, T", planet: "Uranus ♅")
                                LetterValueRow(number: 5, letters: "E, H, N, X", planet: "Mercury ☿")
                                LetterValueRow(number: 6, letters: "U, V, W", planet: "Venus ♀")
                                LetterValueRow(number: 7, letters: "O, Z", planet: "Neptune ♆")
                                LetterValueRow(number: 8, letters: "F, P", planet: "Saturn ♄")
                                
                                HStack {
                                    Text("9")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.goldPrimary)
                                        .frame(width: 32)
                                    
                                    Text("(Sacred - no letters)")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.starlightTertiary)
                                    
                                    Spacer()
                                    
                                    Text("Mars ♂ (Divine)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.goldPrimary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "12121A").opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        
                        // When to Use
                        EducationSection(
                            icon: "lightbulb.fill",
                            title: "When to Use Chaldean",
                            content: "• When seeking deeper spiritual insights\n• For understanding karmic patterns\n• When making important business decisions\n• For understanding hidden personality aspects\n• When the Pythagorean system doesn't seem to 'fit'\n• For advanced esoteric work"
                        )
                        
                        // Famous Practitioners
                        EducationSection(
                            icon: "person.2.fill",
                            title: "Famous Practitioners",
                            content: "• Cheiro (William John Warner) - Ireland's most famous numerologist\n• Dr. Julian St. Aubyn - British author and numerologist\n• Various mystery schools and esoteric traditions\n• Used in ancient Babylonian royal courts"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("About Chaldean")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Education Section
struct EducationSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
            }
            
            Text(content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Difference Row
struct DifferenceRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.purple)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
        }
    }
}

// MARK: - Letter Value Row
struct LetterValueRow: View {
    let number: Int
    let letters: String
    let planet: String
    
    var body: some View {
        HStack {
            Text("\(number)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.starlight)
                .frame(width: 32)
            
            Text(letters)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.starlight)
                .frame(minWidth: 100, alignment: .leading)
            
            Spacer()
            
            Text(planet)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
        .padding(.vertical, 6)
    }
}
