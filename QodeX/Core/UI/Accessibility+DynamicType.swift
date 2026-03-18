//
//  Accessibility+DynamicType.swift
//  Dynamic Type Support for QodeX
//  Implements iOS 18 accessibility standards
//

import SwiftUI

// MARK: - Scaled Font Extension
extension View {
    /// Applies Dynamic Type scaling to a font
    func scaledFont(_ font: Font, textStyle: Font.TextStyle = .body) -> some View {
        self.font(font)
            .textScale(textStyle)
    }
}

// MARK: - Text Scale Modifier
struct TextScaleModifier: ViewModifier {
    let textStyle: Font.TextStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    func body(content: Content) -> some View {
        content
            .font(getScaledFont())
    }
    
    private func getScaledFont() -> Font {
        // Define base fonts for each text style
        switch textStyle {
        case .largeTitle:
            return .system(size: 34 * dynamicTypeSize.scale, weight: .bold)
        case .title:
            return .system(size: 28 * dynamicTypeSize.scale, weight: .bold)
        case .title2:
            return .system(size: 22 * dynamicTypeSize.scale, weight: .bold)
        case .title3:
            return .system(size: 20 * dynamicTypeSize.scale, weight: .semibold)
        case .headline:
            return .system(size: 17 * dynamicTypeSize.scale, weight: .semibold)
        case .subheadline:
            return .system(size: 15 * dynamicTypeSize.scale, weight: .regular)
        case .body:
            return .system(size: 17 * dynamicTypeSize.scale, weight: .regular)
        case .callout:
            return .system(size: 16 * dynamicTypeSize.scale, weight: .regular)
        case .footnote:
            return .system(size: 13 * dynamicTypeSize.scale, weight: .regular)
        case .caption:
            return .system(size: 12 * dynamicTypeSize.scale, weight: .regular)
        case .caption2:
            return .system(size: 11 * dynamicTypeSize.scale, weight: .regular)
        @unknown default:
            return .system(size: 17 * dynamicTypeSize.scale, weight: .regular)
        }
    }
}

extension View {
    func textScale(_ textStyle: Font.TextStyle) -> some View {
        modifier(TextScaleModifier(textStyle: textStyle))
    }
}

// MARK: - Dynamic Type Size Scale Helper
extension DynamicTypeSize {
    var scale: CGFloat {
        switch self {
        case .xSmall: return 0.82
        case .small: return 0.88
        case .medium: return 0.94
        case .large: return 1.0
        case .xLarge: return 1.06
        case .xxLarge: return 1.12
        case .xxxLarge: return 1.18
        case .accessibility1: return 1.24
        case .accessibility2: return 1.36
        case .accessibility3: return 1.48
        case .accessibility4: return 1.64
        case .accessibility5: return 1.88
        @unknown default: return 1.0
        }
    }
}

// MARK: - Accessible Container
struct AccessibleContainer<Content: View>: View {
    let content: Content
    let accessibilityLabel: String
    let accessibilityHint: String?
    
    init(
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
    var body: some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint ?? "")
    }
}

// MARK: - Accessible Button
struct AccessibleButton: View {
    let title: String
    let icon: String?
    let accessibilityLabel: String
    let action: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17 * dynamicTypeSize.scale))
                }
                Text(title)
                    .font(.system(size: 17 * dynamicTypeSize.scale, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12 * dynamicTypeSize.scale)
            .frame(minHeight: 44 * dynamicTypeSize.scale)
            .background(QXColor.gold)
            .foregroundColor(QXColor.cosmicBlack)
            .cornerRadius(12)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to activate")
    }
}

// MARK: - Accessible Card
struct AccessibleCard<Content: View>: View {
    let content: Content
    let title: String
    let accessibilityLabel: String
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(
        title: String,
        accessibilityLabel: String,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.title = title
        self.accessibilityLabel = accessibilityLabel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12 * dynamicTypeSize.scale) {
            Text(title)
                .font(.system(size: 20 * dynamicTypeSize.scale, weight: .bold))
                .foregroundColor(QXColor.starlight)
            
            content
        }
        .padding(16 * dynamicTypeSize.scale)
        .background(QXColor.deepVoid.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Dynamic Spacing Values
enum AccessibleSpacing {
    static func xs(_ size: DynamicTypeSize) -> CGFloat { 4 * size.scale }
    static func sm(_ size: DynamicTypeSize) -> CGFloat { 8 * size.scale }
    static func md(_ size: DynamicTypeSize) -> CGFloat { 16 * size.scale }
    static func lg(_ size: DynamicTypeSize) -> CGFloat { 24 * size.scale }
    static func xl(_ size: DynamicTypeSize) -> CGFloat { 32 * size.scale }
}

// MARK: - Preview
#Preview("Dynamic Type Sizes") {
    Group {
        ForEach([DynamicTypeSize.large, .xxLarge, .accessibility3], id: \.self) { size in
            VStack(spacing: 16) {
                Text("Title Text")
                    .textScale(.title)
                
                Text("Body text that scales with Dynamic Type settings")
                    .textScale(.body)
                
                AccessibleButton(
                    title: "Accessible Button",
                    icon: "star.fill",
                    accessibilityLabel: "Rate this feature",
                    action: {}
                )
            }
            .padding()
            .environment(\.dynamicTypeSize, size)
            .previewDisplayName("\(size)")
        }
    }
}
