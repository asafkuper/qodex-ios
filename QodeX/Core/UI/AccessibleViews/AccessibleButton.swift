//
//  AccessibleButton.swift
//  QodeX - Accessible Button Component
//  Supports Dynamic Type, VoiceOver, and Reduce Motion
//

import SwiftUI

// MARK: - Accessible Button
/// A fully accessible button with VoiceOver support, Dynamic Type scaling,
/// and automatic Reduce Motion compliance
public struct AccessibleButton: View {
    let title: String
    let icon: String?
    let accessibilityLabel: String
    let accessibilityHint: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    
    public enum ButtonStyle {
        case primary
        case secondary
        case gold
        case destructive
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return QXColor.deepVoid
            case .secondary: return QXColor.starlight.opacity(0.1)
            case .gold: return QXColor.gold
            case .destructive: return Color.red.opacity(0.8)
            case .ghost: return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .ghost: return QXColor.starlight
            case .gold: return QXColor.cosmicBlack
            case .destructive: return .white
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .primary: return QXColor.gold.opacity(0.3)
            case .secondary: return QXColor.starlight.opacity(0.2)
            case .gold: return Color.clear
            case .destructive: return Color.red.opacity(0.5)
            case .ghost: return QXColor.starlight.opacity(0.3)
            }
        }
    }
    
    public init(
        title: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            QXHaptic.lightImpact()
            action()
        }) {
            HStack(spacing: 8 * dynamicTypeSize.scale) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17 * dynamicTypeSize.scale))
                        .accessibilityHidden(true)
                }
                
                Text(title)
                    .font(.system(size: 17 * dynamicTypeSize.scale, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 20 * dynamicTypeSize.scale)
            .padding(.vertical, 12 * dynamicTypeSize.scale)
            .frame(minHeight: 44 * dynamicTypeSize.scale)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12 * dynamicTypeSize.scale)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12 * dynamicTypeSize.scale)
                            .stroke(style.strokeColor, lineWidth: 1)
                    )
            )
            .foregroundColor(style.foregroundColor)
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.96 : 1.0))
            .opacity(isPressed ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "Double tap to activate")
        .accessibilityAddTraits(.isButton)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onChange(of: reduceMotion) { _, _ in
            // Handle reduce motion preference change
        }
    }
}

// MARK: - Accessible Icon Button
/// An icon-only button with full accessibility support
public struct AccessibleIconButton: View {
    let icon: String
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    
    public init(
        icon: String,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            QXHaptic.lightImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20 * dynamicTypeSize.scale))
                .foregroundColor(QXColor.starlight)
                .frame(width: 44 * dynamicTypeSize.scale, height: 44 * dynamicTypeSize.scale)
                .background(
                    RoundedRectangle(cornerRadius: 12 * dynamicTypeSize.scale)
                        .fill(QXColor.deepVoid)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12 * dynamicTypeSize.scale)
                                .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                        )
                )
                .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.92 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .minimumTouchTarget()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Accessible Card Button
/// A card-style button with comprehensive accessibility
public struct AccessibleCardButton<Content: View>: View {
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    @ViewBuilder let content: Content
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    
    public init(
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            QXHaptic.mediumImpact()
            action()
        }) {
            content
                .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.98 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "Double tap to open")
        .accessibilityAddTraits(.isButton)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Accessible Toggle
/// A toggle with enhanced accessibility support
public struct AccessibleToggle: View {
    let title: String
    let accessibilityLabel: String
    let accessibilityHint: String?
    @Binding var isOn: Bool
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(
        title: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 17 * dynamicTypeSize.scale))
                .foregroundColor(QXColor.starlight)
        }
        .tint(QXColor.gold)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

// MARK: - Minimum Touch Target Modifier
extension View {
    /// Ensures minimum 44x44 touch target for accessibility (WCAG 2.5.5)
    public func minimumTouchTarget(size: CGFloat = 44) -> some View {
        self.frame(minWidth: size, minHeight: size)
    }
}

// MARK: - Preview
#Preview("Accessible Buttons") {
    VStack(spacing: 20) {
        AccessibleButton(
            title: "Primary Button",
            icon: "star.fill",
            accessibilityHint: "Double tap to perform action",
            style: .primary
        ) {}
        
        AccessibleButton(
            title: "Gold Button",
            icon: "sparkles",
            style: .gold
        ) {}
        
        AccessibleButton(
            title: "Secondary Button",
            style: .secondary
        ) {}
        
        HStack {
            AccessibleIconButton(
                icon: "heart.fill",
                accessibilityLabel: "Like",
                accessibilityHint: "Double tap to like this item"
            ) {}
            
            AccessibleIconButton(
                icon: "square.and.arrow.up",
                accessibilityLabel: "Share",
                accessibilityHint: "Double tap to share"
            ) {}
            
            AccessibleIconButton(
                icon: "bookmark",
                accessibilityLabel: "Bookmark",
                accessibilityHint: "Double tap to bookmark"
            ) {}
        }
        
        AccessibleToggle(
            title: "Enable Notifications",
            isOn: .constant(true)
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
