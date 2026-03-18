//
//  AccessibleText.swift
//  QodeX - Accessible Text Components
//  Full Dynamic Type support with proper scaling
//

import SwiftUI

// MARK: - Accessible Text
/// A text view that properly supports all 7 Dynamic Type sizes (XS to XXXL)
/// and responds correctly to accessibility settings
public struct AccessibleText: View {
    let text: String
    let textStyle: Font.TextStyle
    let weight: Font.Weight
    let color: Color
    let lineLimit: Int?
    let alignment: TextAlignment
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(
        _ text: String,
        textStyle: Font.TextStyle = .body,
        weight: Font.Weight = .regular,
        color: Color = QXColor.starlight,
        lineLimit: Int? = nil,
        alignment: TextAlignment = .leading
    ) {
        self.text = text
        self.textStyle = textStyle
        self.weight = weight
        self.color = color
        self.lineLimit = lineLimit
        self.alignment = alignment
    }
    
    public var body: some View {
        Text(text)
            .font(.system(size: baseSize * dynamicTypeSize.scale, weight: weight))
            .foregroundColor(color)
            .lineLimit(lineLimit)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var baseSize: CGFloat {
        switch textStyle {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .subheadline: return 15
        case .body: return 17
        case .callout: return 16
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}

// MARK: - Accessible Title
/// Styled title text with proper Dynamic Type scaling
public struct AccessibleTitle: View {
    let text: String
    let level: TitleLevel
    let color: Color
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public enum TitleLevel {
        case display  // 34pt base
        case h1       // 28pt base
        case h2       // 22pt base
        case h3       // 20pt base
        case h4       // 17pt base
        
        var baseSize: CGFloat {
            switch self {
            case .display: return 34
            case .h1: return 28
            case .h2: return 22
            case .h3: return 20
            case .h4: return 17
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .display: return .bold
            case .h1, .h2: return .bold
            case .h3: return .semibold
            case .h4: return .semibold
            }
        }
        
        var isHeader: Bool {
            return true
        }
    }
    
    public init(_ text: String, level: TitleLevel = .h1, color: Color = QXColor.starlight) {
        self.text = text
        self.level = level
        self.color = color
    }
    
    public var body: some View {
        Text(text)
            .font(.system(size: level.baseSize * dynamicTypeSize.scale, weight: level.weight))
            .foregroundColor(color)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(level.isHeader ? .isHeader : [])
    }
}

// MARK: - Accessible Number Display
/// Large number display optimized for accessibility
/// Includes proper labels for screen readers
public struct AccessibleNumberDisplay: View {
    let number: Int
    let title: String
    let subtitle: String?
    let color: Color
    let isMasterNumber: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        number: Int,
        title: String,
        subtitle: String? = nil,
        color: Color = QXColor.gold,
        isMasterNumber: Bool = false,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil
    ) {
        self.number = number
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isMasterNumber = isMasterNumber
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
    public var body: some View {
        VStack(spacing: 8 * dynamicTypeSize.scale) {
            // Number
            Text("\(number)")
                .font(.system(
                    size: dynamicSize * dynamicTypeSize.scale,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundColor(isMasterNumber ? QXColor.gold : color)
                .shadow(
                    color: isMasterNumber ? QXColor.gold.opacity(0.5) : .clear,
                    radius: isMasterNumber ? 15 : 0
                )
                .accessibilityLabel("\(number)")
            
            // Title
            Text(title)
                .font(.system(size: 17 * dynamicTypeSize.scale, weight: .semibold))
                .foregroundColor(QXColor.starlight)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel(title)
            
            // Subtitle (optional)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 13 * dynamicTypeSize.scale))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .accessibilityLabel(subtitle)
            }
            
            // Master Number Badge
            if isMasterNumber {
                Text("MASTER")
                    .font(.system(size: 10 * dynamicTypeSize.scale, weight: .bold))
                    .foregroundColor(QXColor.gold)
                    .padding(.horizontal, 8 * dynamicTypeSize.scale)
                    .padding(.vertical, 4 * dynamicTypeSize.scale)
                    .background(QXColor.gold.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityLabel("Master Number")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel ?? "\(title) Number \(number)")
        .accessibilityHint(accessibilityHint)
    }
    
    private var dynamicSize: CGFloat {
        // Scale down at larger text sizes to prevent truncation
        switch dynamicTypeSize {
        case .accessibility3, .accessibility4, .accessibility5:
            return 48
        case .accessibility1, .accessibility2:
            return 56
        default:
            return 72
        }
    }
}

// MARK: - Accessible Label Value Pair
/// A label-value pair optimized for VoiceOver
public struct AccessibleLabelValue: View {
    let label: String
    let value: String
    let alignment: HorizontalAlignment
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(
        label: String,
        value: String,
        alignment: HorizontalAlignment = .leading
    ) {
        self.label = label
        self.value = value
        self.alignment = alignment
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: 4 * dynamicTypeSize.scale) {
            Text(label)
                .font(.system(size: 13 * dynamicTypeSize.scale))
                .foregroundColor(QXColor.starlight.opacity(0.6))
                .accessibilityLabel(label)
            
            Text(value)
                .font(.system(size: 17 * dynamicTypeSize.scale, weight: .medium))
                .foregroundColor(QXColor.starlight)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(value)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Screen Reader Only Text
/// Text that is only visible to screen readers
public struct ScreenReaderOnly: View {
    let text: String
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .opacity(0.01)
            .frame(width: 1, height: 1)
            .accessibilityLabel(text)
    }
}

// MARK: - Accessible Scroll View
/// Scroll view with proper accessibility support for overflow content
public struct AccessibleScrollView<Content: View>: View {
    let showsIndicators: Bool
    let accessibilityLabel: String?
    @ViewBuilder let content: Content
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(
        showsIndicators: Bool = false,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            content
                .padding(.bottom, 50) // Extra padding for large text
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Dynamic Type Scale Helper (Extended)
extension DynamicTypeSize {
    /// Returns true if using an accessibility size (larger than XXXLarge)
    var isAccessibilitySize: Bool {
        switch self {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if content should use compact layout
    var needsCompactLayout: Bool {
        switch self {
        case .accessibility3, .accessibility4, .accessibility5:
            return true
        default:
            return false
        }
    }
}

// MARK: - Preview
#Preview("Accessible Text") {
    ScrollView {
        VStack(spacing: 20) {
            Group {
                AccessibleTitle("Display Title", level: .display)
                AccessibleTitle("H1 Title", level: .h1)
                AccessibleTitle("H2 Title", level: .h2)
                AccessibleTitle("H3 Title", level: .h3)
            }
            
            Divider()
            
            Group {
                AccessibleText("Body text with Dynamic Type support", textStyle: .body)
                AccessibleText("Headline text", textStyle: .headline, weight: .semibold)
                AccessibleText("Caption text", textStyle: .caption, color: QXColor.starlight.opacity(0.6))
            }
            
            Divider()
            
            AccessibleNumberDisplay(
                number: 7,
                title: "Life Path",
                subtitle: "Your journey's purpose",
                isMasterNumber: false
            )
            
            AccessibleNumberDisplay(
                number: 11,
                title: "Expression",
                subtitle: "Natural talents",
                isMasterNumber: true
            )
            
            Divider()
            
            AccessibleLabelValue(
                label: "Current Streak",
                value: "15 days"
            )
            
            ScreenReaderOnly("This text is only for screen readers")
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
