//
//  WidgetPreviewView.swift
//  QodeX - Premium Widget Customization
//  Inspired by iOS WidgetKit, Fantastical
//

import SwiftUI

struct WidgetPreviewView: View {
    @State private var selectedSize: WidgetSize = .medium
    @State private var selectedStyle: WidgetStyle = .modern
    @State private var selectedContent: WidgetContent = .dailyNumber
    @State private var showAddInstructions = false
    
    enum WidgetSize: String, CaseIterable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
    }
    
    enum WidgetStyle: String, CaseIterable {
        case classic = "Classic"
        case modern = "Modern"
        case minimal = "Minimal"
    }
    
    enum WidgetContent: String, CaseIterable {
        case dailyNumber = "Daily Number"
        case lifePath = "Life Path"
        case compatibility = "Compatibility"
        case quote = "Daily Quote"
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Widgets")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        Button(action: { showAddInstructions = true }) {
                            Text("How to Add")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.goldPrimary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Widget Preview
                    WidgetPreviewContainer(
                        size: selectedSize,
                        style: selectedStyle,
                        content: selectedContent
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    
                    // Size Selector
                    SizeSelector(selected: $selectedSize)
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    
                    // Style Selector
                    StyleSelector(selected: $selectedStyle)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Content Selector
                    ContentSelector(selected: $selectedContent)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Info Card
                    WidgetInfoCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showAddInstructions) {
            AddWidgetInstructionsView()
        }
    }
}

// MARK: - Widget Preview Container
struct WidgetPreviewContainer: View {
    let size: WidgetPreviewView.WidgetSize
    let style: WidgetPreviewView.WidgetStyle
    let content: WidgetPreviewView.WidgetContent
    
    var body: some View {
        VStack(spacing: 16) {
            // Phone Frame
            ZStack {
                // Phone outline
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(hex: "1a1a1a"))
                    .frame(width: 280, height: 580)
                    .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
                
                // Screen
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(hex: "0A0A0F"))
                    .frame(width: 260, height: 560)
                
                // Home Screen Content
                VStack(spacing: 0) {
                    // Status Bar
                    HStack {
                        Text("9:41")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "wifi")
                                .font(.system(size: 12))
                            Image(systemName: "battery.100")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.starlight)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // App Icons Grid (simplified)
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem()], spacing: 16) {
                        ForEach(0..<8) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.goldPrimary.opacity(0.3))
                                .frame(width: 56, height: 56)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // The Widget
                    widgetPreview
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    Spacer()
                }
                .frame(width: 260, height: 560)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            
            Text("Preview")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
    }
    
    @ViewBuilder
    var widgetPreview: some View {
        switch size {
        case .small:
            SmallWidgetPreview(style: style, content: content)
                .frame(width: 160, height: 160)
        case .medium:
            MediumWidgetPreview(style: style, content: content)
                .frame(width: 340, height: 160)
        case .large:
            LargeWidgetPreview(style: style, content: content)
                .frame(width: 340, height: 340)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetPreview: View {
    let style: WidgetPreviewView.WidgetStyle
    let content: WidgetPreviewView.WidgetContent
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(widgetBackground)
            
            VStack(spacing: 8) {
                Text("QODE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.goldPrimary)
                
                Text("8")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.starlight)
                
                Text("Power & Abundance")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.starlightTertiary)
                    .lineLimit(1)
            }
            .padding(12)
        }
    }
    
    var widgetBackground: some View {
        switch style {
        case .classic:
            return LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .modern:
            return LinearGradient(
                colors: [Color.goldPrimary.opacity(0.2), Color(hex: "0A0A0F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            return Color(hex: "12121A")
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetPreview: View {
    let style: WidgetPreviewView.WidgetStyle
    let content: WidgetPreviewView.WidgetContent
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(widgetBackground)
            
            HStack(spacing: 16) {
                // Number
                VStack(spacing: 4) {
                    Text("Today's Number")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.starlightTertiary)
                    
                    Text("8")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.goldPrimary)
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Power & Abundance")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    Text("Focus on career and financial decisions today")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        TimePill(time: "9:00 AM")
                        TimePill(time: "2:00 PM")
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
    
    var widgetBackground: some View {
        switch style {
        case .classic:
            return LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .modern:
            return LinearGradient(
                colors: [Color.goldPrimary.opacity(0.15), Color(hex: "0A0A0F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            return Color(hex: "12121A")
        }
    }
}

// MARK: - Large Widget
struct LargeWidgetPreview: View {
    let style: WidgetPreviewView.WidgetStyle
    let content: WidgetPreviewView.WidgetContent
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(widgetBackground)
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("QODE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.goldPrimary)
                    
                    Spacer()
                    
                    Text("Friday, March 13")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                // Main content
                HStack(spacing: 20) {
                    // Number circle
                    ZStack {
                        Circle()
                            .stroke(Color.goldPrimary.opacity(0.3), lineWidth: 3)
                            .frame(width: 100, height: 100)
                        
                        Text("8")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.starlight)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Power & Abundance")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Text("Today's energy brings opportunities for financial growth and career advancement.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.starlightSecondary)
                            .lineLimit(3)
                        
                        HStack(spacing: 8) {
                            TimePill(time: "9:00 AM")
                            TimePill(time: "2:00 PM")
                            TimePill(time: "7:00 PM")
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
    }
    
    var widgetBackground: some View {
        switch style {
        case .classic:
            return LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .modern:
            return LinearGradient(
                colors: [Color.goldPrimary.opacity(0.12), Color(hex: "0A0A0F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            return Color(hex: "12121A")
        }
    }
}

// MARK: - Time Pill
struct TimePill: View {
    let time: String
    
    var body: some View {
        Text(time)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.goldPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.goldPrimary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Size Selector
struct SizeSelector: View {
    @Binding var selected: WidgetPreviewView.WidgetSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                ForEach(WidgetPreviewView.WidgetSize.allCases, id: \.self) { size in
                    SizeButton(
                        size: size,
                        isSelected: selected == size
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = size
                        }
                    }
                }
            }
        }
    }
}

struct SizeButton: View {
    let size: WidgetPreviewView.WidgetSize
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch size {
        case .small: return "square"
        case .medium: return "rectangle"
        case .large: return "rectangle.portrait"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .goldPrimary : .starlightTertiary)
                
                Text(size.rawValue)
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

// MARK: - Style Selector
struct StyleSelector: View {
    @Binding var selected: WidgetPreviewView.WidgetStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Style")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            HStack(spacing: 12) {
                ForEach(WidgetPreviewView.WidgetStyle.allCases, id: \.self) { style in
                    StyleButton(
                        style: style,
                        isSelected: selected == style
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = style
                        }
                    }
                }
            }
        }
    }
}

struct StyleButton: View {
    let style: WidgetPreviewView.WidgetStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(style.rawValue)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .cosmicBlack : .starlight)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.goldPrimary : Color.white.opacity(0.05))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Content Selector
struct ContentSelector: View {
    @Binding var selected: WidgetPreviewView.WidgetContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.starlight)
            
            VStack(spacing: 8) {
                ForEach(WidgetPreviewView.WidgetContent.allCases, id: \.self) { content in
                    ContentRow(
                        content: content,
                        isSelected: selected == content
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = content
                        }
                    }
                }
            }
        }
    }
}

struct ContentRow: View {
    let content: WidgetPreviewView.WidgetContent
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch content {
        case .dailyNumber: return "sun.max.fill"
        case .lifePath: return "person.fill"
        case .compatibility: return "heart.fill"
        case .quote: return "quote.bubble.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .goldPrimary : .starlightTertiary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Color.goldPrimary.opacity(0.1) : Color.white.opacity(0.05))
                    )
                
                Text(content.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .starlight : .starlightSecondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.goldPrimary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.goldPrimary.opacity(0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.goldPrimary.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Widget Info Card
struct WidgetInfoCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.goldPrimary)
                    
                    Text("Pro Tip")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                }
                
                Text("Add multiple widgets to your home screen for quick access to different insights throughout your day.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

// MARK: - Add Widget Instructions
struct AddWidgetInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Step 1
                    InstructionStep(
                        number: 1,
                        title: "Long Press Home Screen",
                        description: "Press and hold on an empty area of your home screen until apps jiggle.",
                        icon: "hand.tap.fill"
                    )
                    
                    // Step 2
                    InstructionStep(
                        number: 2,
                        title: "Tap the Plus Button",
                        description: "Tap the + button in the top-left corner to add a widget.",
                        icon: "plus.circle.fill"
                    )
                    
                    // Step 3
                    InstructionStep(
                        number: 3,
                        title: "Find QodeX",
                        description: "Scroll down and select QodeX from the list of apps.",
                        icon: "magnifyingglass"
                    )
                    
                    // Step 4
                    InstructionStep(
                        number: 4,
                        title: "Choose Your Widget",
                        description: "Select the size and style you prefer, then tap Add Widget.",
                        icon: "checkmark.circle.fill"
                    )
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Add Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.goldPrimary)
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Number
            ZStack {
                Circle()
                    .fill(Color.goldPrimary)
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.cosmicBlack)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.goldPrimary.opacity(0.5))
        }
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

// MARK: - Preview
struct WidgetPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPreviewView()
            .preferredColorScheme(.dark)
    }
}
