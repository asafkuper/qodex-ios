//
//  ExportView.swift
//  QodeX - Premium Export & Share
//  Inspired by Instagram Stories, Canva
//

import SwiftUI

struct ExportView: View {
    @State private var selectedFormat: ExportFormat = .story
    @State private var selectedTheme: ShareTheme = .gold
    @State private var showNumbers = true
    @State private var showQuote = true
    
    enum ExportFormat: String, CaseIterable {
        case story = "Story"
        case post = "Post"
        case wallpaper = "Wallpaper"
        case pdf = "PDF"
    }
    
    enum ShareTheme: String, CaseIterable {
        case gold = "Gold"
        case cosmic = "Cosmic"
        case minimal = "Minimal"
        case gradient = "Gradient"
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Export")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.starlight)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Share")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.goldPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Preview
                ExportPreview(
                    format: selectedFormat,
                    theme: selectedTheme,
                    showNumbers: showNumbers,
                    showQuote: showQuote
                )
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Format Selector
                FormatSelector(selected: $selectedFormat)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // Theme Selector
                ThemeSelector(selected: $selectedTheme)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // Options
                OptionsSection(
                    showNumbers: $showNumbers,
                    showQuote: $showQuote
                )
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Export Buttons
                ExportButtons()
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Export Preview
struct ExportPreview: View {
    let format: ExportView.ExportFormat
    let theme: ExportView.ShareTheme
    let showNumbers: Bool
    let showQuote: Bool
    
    var body: some View {
        ZStack {
            // Phone frame
            RoundedRectangle(cornerRadius: 40)
                .fill(Color(hex: "1a1a1a"))
                .frame(width: format == .story ? 200 : 280, height: format == .story ? 356 : 373)
                .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
            
            // Content
            previewContent
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }
    
    @ViewBuilder
    var previewContent: some View {
        ZStack {
            // Background
            themeBackground
            
            VStack(spacing: 20) {
                // Logo
                Text("QODE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.goldPrimary)
                
                if showNumbers {
                    // Number
                    Text("8")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.goldBright, .goldPrimary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .goldPrimary.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                
                // Title
                Text("Power & Abundance")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.starlight)
                
                if showQuote {
                    // Quote
                    Text("\"I am worthy of abundance and success.\"")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.starlightSecondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Handle
                Text("@sarahj")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.starlightTertiary)
            }
            .padding(24)
        }
        .frame(width: format == .story ? 180 : 260, height: format == .story ? 340 : 355)
    }
    
    @ViewBuilder
    var themeBackground: some View {
        switch theme {
        case .gold:
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color.goldPrimary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cosmic:
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color.purple.opacity(0.2), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            Color(hex: "12121A")
        case .gradient:
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.3), .goldPrimary.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Format Selector
struct FormatSelector: View {
    @Binding var selected: ExportView.ExportFormat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Format")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 8) {
                ForEach(ExportView.ExportFormat.allCases, id: \.self) { format in
                    FormatButton(
                        format: format,
                        isSelected: selected == format
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = format
                        }
                    }
                }
            }
        }
    }
}

struct FormatButton: View {
    let format: ExportView.ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch format {
        case .story: return "iphone"
        case .post: return "square"
        case .wallpaper: return "photo"
        case .pdf: return "doc"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .goldPrimary : .starlightTertiary)
                
                Text(format.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .goldPrimary : .starlightTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.goldPrimary.opacity(0.1) : Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.goldPrimary.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Theme Selector
struct ThemeSelector: View {
    @Binding var selected: ExportView.ShareTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                ForEach(ExportView.ShareTheme.allCases, id: \.self) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: selected == theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = theme
                        }
                    }
                }
            }
        }
    }
}

struct ThemeButton: View {
    let theme: ExportView.ShareTheme
    let isSelected: Bool
    let action: () -> Void
    
    var colors: [Color] {
        switch theme {
        case .gold: return [.goldPrimary, .goldBright]
        case .cosmic: return [.purple, .blue]
        case .minimal: return [.gray, .white]
        case .gradient: return [.purple, .blue, .goldPrimary]
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Theme preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Options Section
struct OptionsSection: View {
    @Binding var showNumbers: Bool
    @Binding var showQuote: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 0) {
                ToggleRow(title: "Show Numbers", isOn: $showNumbers)
                ToggleRow(title: "Show Daily Quote", isOn: $showQuote)
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

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.starlight)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .goldPrimary))
        }
        .padding(16)
    }
}

// MARK: - Export Buttons
struct ExportButtons: View {
    var body: some View {
        VStack(spacing: 12) {
            // Instagram
            ExportButton(
                title: "Share to Instagram",
                icon: "camera.fill",
                color: .purple,
                action: {}
            )
            
            // Save
            ExportButton(
                title: "Save to Photos",
                icon: "photo",
                color: .blue,
                action: {}
            )
            
            // PDF
            ExportButton(
                title: "Export as PDF",
                icon: "doc",
                color: .goldPrimary,
                action: {}
            )
        }
    }
}

struct ExportButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.1))
                    )
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 16))
                    .foregroundColor(.starlightQuaternary)
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
            .preferredColorScheme(.dark)
    }
}
