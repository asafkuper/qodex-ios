//
//  DataPrivacyView.swift
//  QodeX - Premium Data & Privacy
//  GDPR Compliant Data Export and Account Deletion
//

import SwiftUI

struct DataPrivacyView: View {
    @State private var showExportProgress = false
    @State private var exportProgress: Double = 0
    @State private var showExportComplete = false
    @State private var exportFileURL: URL?
    @State private var exportError: String?
    @State private var showExportError = false
    
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
    @State private var isDeleting = false
    
    @State private var showReauthSheet = false
    
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
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
                    Text("Data & Privacy")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.starlight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Privacy Shield
                    PrivacyShieldCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Your Data
                    YourDataSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Privacy Controls
                    PrivacyControlsSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Download Data (GDPR)
                    DownloadDataSection(
                        progress: $exportProgress,
                        isExporting: $showExportProgress,
                        onRequestDownload: requestDataExport
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Delete Account
                    DeleteAccountSection(
                        isDeleting: $isDeleting,
                        onDelete: { showDeleteConfirmation = true }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted including your profile, journal entries, community posts, and subscription history.")
        }
        .alert("Delete Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
            Button("Re-authenticate") {
                showReauthSheet = true
            }
        } message: {
            Text(deleteErrorMessage)
        }
        .alert("Export Failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportError ?? "Failed to export data. Please try again.")
        }
        .sheet(isPresented: $showExportComplete) {
            if let url = exportFileURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // MARK: - Data Export
    
    private func requestDataExport() {
        guard !showExportProgress else { return }
        
        showExportProgress = true
        exportProgress = 0
        
        // Simulate progress animation
        withAnimation(.linear(duration: 2)) {
            exportProgress = 0.3
        }
        
        Task {
            // Fetch all user data
            let result = await ExportManager.shared.exportUserDataToFile()
            
            await MainActor.run {
                withAnimation(.linear(duration: 0.5)) {
                    exportProgress = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showExportProgress = false
                    
                    switch result {
                    case .success(let url):
                        exportFileURL = url
                        showExportComplete = true
                        
                        // Log analytics
                        AnalyticsManager.shared.logEvent("data_export_completed")
                        
                    case .failure(let error):
                        exportError = error.localizedDescription
                        showExportError = true
                        
                        AnalyticsManager.shared.logEvent("data_export_failed", parameters: [
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        }
    }
    
    // MARK: - Account Deletion
    
    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }
        
        let result = await authManager.deleteAccount()
        
        switch result {
        case .success:
            // Account deleted - auth state listener will handle logout
            dismiss()
            
        case .failure(let error):
            if case .authentication(.sessionExpired) = error {
                deleteErrorMessage = "For security reasons, please sign in again before deleting your account."
                showReauthSheet = true
            } else {
                deleteErrorMessage = error.localizedDescription
            }
            showDeleteError = true
        }
    }
}

// MARK: - Privacy Shield Card
struct PrivacyShieldCard: View {
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Your Data is Protected")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.starlight)
                    
                    Text("We use industry-standard encryption and never sell your personal information. You have full control over your data with GDPR-compliant export and deletion.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.starlightSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // Badges
                HStack(spacing: 12) {
                    PrivacyBadge(icon: "lock.fill", text: "Encrypted")
                    PrivacyBadge(icon: "eye.slash.fill", text: "Private")
                    PrivacyBadge(icon: "checkmark.circle.fill", text: "GDPR")
                }
            }
        }
    }
}

struct PrivacyBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.green)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.green.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Your Data Section
struct YourDataSection: View {
    let dataTypes = [
        ("Profile Data", "Name, birthdate, Life Path", "~1 KB"),
        ("Readings History", "Daily readings & reflections", "~50 KB"),
        ("Journal Entries", "Private journal entries", "~100 KB"),
        ("Community Activity", "Posts, comments, likes", "~20 KB"),
        ("App Settings", "Preferences, notifications", "~5 KB"),
        ("Subscription", "Billing & membership status", "~2 KB")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Data")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 0) {
                ForEach(Array(dataTypes.enumerated()), id: \.element.0) { index, data in
                    DataTypeRow(
                        title: data.0,
                        description: data.1,
                        size: data.2,
                        isLast: index == dataTypes.count - 1
                    )
                }
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

struct DataTypeRow: View {
    let title: String
    let description: String
    let size: String
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.starlight)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            Spacer()
            
            Text(size)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
        .padding(16)
        .overlay(
            Group {
                if !isLast {
                    Divider()
                        .background(Color.white.opacity(0.05))
                        .padding(.leading, 16)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        )
    }
}

// MARK: - Privacy Controls Section
struct PrivacyControlsSection: View {
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    @AppStorage("crashReportsEnabled") private var crashReportsEnabled = true
    @AppStorage("personalizedContent") private var personalizedContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Controls")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 0) {
                PrivacyToggle(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Analytics",
                    description: "Help improve QodeX with usage data",
                    isOn: $analyticsEnabled
                )
                
                PrivacyToggle(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .orange,
                    title: "Crash Reports",
                    description: "Automatically send crash reports",
                    isOn: $crashReportsEnabled
                )
                
                PrivacyToggle(
                    icon: "sparkles",
                    iconColor: .purple,
                    title: "Personalized Content",
                    description: "Tailor content based on your numerology",
                    isOn: $personalizedContent
                )
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

struct PrivacyToggle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.starlight)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .goldPrimary))
        }
        .padding(16)
    }
}

// MARK: - Download Data Section (GDPR)
struct DownloadDataSection: View {
    @Binding var progress: Double
    @Binding var isExporting: Bool
    let onRequestDownload: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Download Your Data")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.starlight)
                        
                        Text("GDPR-compliant data export")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                    }
                    
                    Spacer()
                }
                
                if isExporting {
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .goldPrimary))
                        
                        Text("\(Int(progress * 100))% complete")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.starlightTertiary)
                    }
                } else {
                    Button(action: onRequestDownload) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 17))
                            
                            Text("Request Download")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.cosmicBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.goldPrimary)
                        )
                    }
                }
                
                Text("We'll prepare a JSON file with all your data including profile, journal, readings, and community activity. This may take a moment.")
                    .font(.system(size: 12))
                    .foregroundColor(.starlightTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Delete Account Section
struct DeleteAccountSection: View {
    @Binding var isDeleting: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.red)
            
            GlassCard {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Delete Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Text("Permanently delete all your data")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.starlightTertiary)
                        }
                        
                        Spacer()
                    }
                    
                    if isDeleting {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    } else {
                        Button(action: onDelete) {
                            Text("Delete My Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    Text("This will permanently delete your account, profile, journal entries, community posts, and all associated data. This action cannot be undone.")
                        .font(.system(size: 12))
                        .foregroundColor(.starlightTertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
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

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct DataPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        DataPrivacyView()
            .preferredColorScheme(.dark)
    }
}
