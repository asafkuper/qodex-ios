//
//  AccessibleCards.swift
//  QodeX - Accessible Card Components
//  Cards with proper VoiceOver grouping and Dynamic Type support
//

import SwiftUI

// MARK: - Accessible Card
/// A card container with comprehensive accessibility support
public struct AccessibleCard<Content: View>: View {
    let title: String?
    let accessibilityLabel: String
    let accessibilityHint: String?
    let isButton: Bool
    let action: (() -> Void)?
    @ViewBuilder let content: Content
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    
    public init(
        title: String? = nil,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        isButton: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.isButton = isButton
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if isButton, let action = action {
                Button(action: {
                    QXHaptic.lightImpact()
                    action()
                }) {
                    cardContent
                        .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.98 : 1.0))
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            } else {
                cardContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isButton ? .isButton : [])
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12 * dynamicTypeSize.scale) {
            if let title = title {
                Text(title)
                    .font(.system(size: 20 * dynamicTypeSize.scale, weight: .bold))
                    .foregroundColor(QXColor.starlight)
                    .accessibilityAddTraits(.isHeader)
            }
            
            content
        }
        .padding(16 * dynamicTypeSize.scale)
        .background(
            RoundedRectangle(cornerRadius: 16 * dynamicTypeSize.scale)
                .fill(QXColor.deepVoid.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * dynamicTypeSize.scale)
                        .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Accessible Number Card
/// A card specifically for displaying numerology numbers
public struct AccessibleNumberCard: View {
    let number: Int
    let type: String
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let isMasterNumber: Bool
    let action: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    
    public init(
        number: Int,
        type: String,
        title: String,
        subtitle: String,
        color: Color = QXColor.gold,
        isSelected: Bool = false,
        isMasterNumber: Bool = false,
        action: @escaping () -> Void
    ) {
        self.number = number
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isSelected = isSelected
        self.isMasterNumber = isMasterNumber
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            QXHaptic.lightImpact()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Type label
                Text(type)
                    .font(.system(size: 11 * dynamicTypeSize.scale, weight: .semibold))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.bottom, 12 * dynamicTypeSize.scale)
                    .accessibilityLabel("\(type) Number")
                
                // Number
                Text("\(number)")
                    .font(.system(
                        size: dynamicNumberSize,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundColor(color)
                    .padding(.bottom, 4 * dynamicTypeSize.scale)
                    .accessibilityLabel("\(number)")
                
                // Title
                Text(title)
                    .font(.system(size: 13 * dynamicTypeSize.scale, weight: .medium))
                    .foregroundColor(QXColor.starlight)
                    .lineLimit(1)
                    .accessibilityLabel(title)
                
                // Master badge (if applicable)
                if isMasterNumber {
                    Text("MASTER")
                        .font(.system(size: 9 * dynamicTypeSize.scale, weight: .bold))
                        .foregroundColor(QXColor.gold)
                        .padding(.horizontal, 6 * dynamicTypeSize.scale)
                        .padding(.vertical, 2 * dynamicTypeSize.scale)
                        .background(QXColor.gold.opacity(0.1))
                        .cornerRadius(4)
                        .padding(.top, 6 * dynamicTypeSize.scale)
                        .accessibilityLabel("Master Number")
                }
            }
            .padding(20 * dynamicTypeSize.scale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20 * dynamicTypeSize.scale)
                    .fill(QXColor.deepVoid.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20 * dynamicTypeSize.scale)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.98 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type) Number \(number), \(title)")
        .accessibilityHint("Double tap to view detailed interpretation")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isSelected ? "Selected" : "")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var borderColor: Color {
        if isSelected {
            return color.opacity(0.5)
        }
        return Color.white.opacity(0.05)
    }
    
    private var dynamicNumberSize: CGFloat {
        // Scale down at larger text sizes
        switch dynamicTypeSize {
        case .accessibility3, .accessibility4, .accessibility5:
            return 28
        case .accessibility1, .accessibility2:
            return 32
        default:
            return 36
        }
    }
}

// MARK: - Accessible Insight Card
/// A card for displaying daily insights with full accessibility
public struct AccessibleInsightCard: View {
    let title: String
    let description: String
    let affirmation: String?
    let isExpandable: Bool
    let date: Date?
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isExpanded = false
    @State private var copiedAffirmation = false
    
    public init(
        title: String,
        description: String,
        affirmation: String? = nil,
        isExpandable: Bool = true,
        date: Date? = nil
    ) {
        self.title = title
        self.description = description
        self.affirmation = affirmation
        self.isExpandable = isExpandable
        self.date = date
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16 * dynamicTypeSize.scale) {
            // Header
            HStack(alignment: .center) {
                Image(systemName: "sparkles")
                    .foregroundColor(QXColor.gold)
                    .font(.system(size: 16 * dynamicTypeSize.scale))
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.system(size: 18 * dynamicTypeSize.scale, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .accessibilityLabel(title)
                
                Spacer()
                
                if isExpandable {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                        QXHaptic.lightImpact()
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(QXColor.starlight.opacity(0.6))
                            .font(.system(size: 14 * dynamicTypeSize.scale, weight: .medium))
                            .padding(8)
                            .background(Circle().fill(QXColor.starlight.opacity(0.1)))
                            .frame(width: 44 * dynamicTypeSize.scale, height: 44 * dynamicTypeSize.scale)
                    }
                    .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                    .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") details")
                }
            }
            
            // Date (if provided)
            if let date = date {
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.system(size: 13 * dynamicTypeSize.scale))
                    .foregroundColor(QXColor.starlight.opacity(0.5))
                    .accessibilityLabel("Date: \(date.formatted(date: .long, time: .omitted))")
            }
            
            // Description
            Text(description)
                .font(.system(size: 15 * dynamicTypeSize.scale))
                .foregroundColor(QXColor.starlight.opacity(0.8))
                .lineSpacing(4 * dynamicTypeSize.scale)
                .lineLimit(isExpanded ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(description)
            
            // Affirmation section (shown when expanded)
            if isExpanded, let affirmation = affirmation {
                Divider()
                    .background(QXColor.gold.opacity(0.3))
                    .padding(.vertical, 4 * dynamicTypeSize.scale)
                
                HStack(spacing: 12 * dynamicTypeSize.scale) {
                    Image(systemName: "quote.opening")
                        .foregroundColor(QXColor.gold)
                        .font(.system(size: 20 * dynamicTypeSize.scale))
                        .accessibilityHidden(true)
                    
                    Text(affirmation)
                        .font(.system(size: 15 * dynamicTypeSize.scale, weight: .medium))
                        .italic()
                        .foregroundColor(QXColor.gold)
                        .lineSpacing(3 * dynamicTypeSize.scale)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Affirmation: \(affirmation)")
                    
                    Spacer()
                    
                    Button(action: {
                        UIPasteboard.general.string = affirmation
                        copiedAffirmation = true
                        QXHaptic.success()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedAffirmation = false
                        }
                    }) {
                        Image(systemName: copiedAffirmation ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14 * dynamicTypeSize.scale))
                            .foregroundColor(copiedAffirmation ? QXColor.success : QXColor.starlight.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(copiedAffirmation ? "Copied" : "Copy affirmation")
                    .accessibilityHint("Double tap to copy affirmation to clipboard")
                }
                .padding(.vertical, 8 * dynamicTypeSize.scale)
                .padding(.horizontal, 12 * dynamicTypeSize.scale)
                .background(
                    RoundedRectangle(cornerRadius: 12 * dynamicTypeSize.scale)
                        .fill(QXColor.gold.opacity(0.1))
                )
            }
        }
        .padding(20 * dynamicTypeSize.scale)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20 * dynamicTypeSize.scale)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20 * dynamicTypeSize.scale)
                    .fill(
                        LinearGradient(
                            colors: [QXColor.gold.opacity(0.05), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20 * dynamicTypeSize.scale)
                    .stroke(QXColor.gold.opacity(0.15), lineWidth: 1)
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(isExpandable ? "tap to expand" : "")")
        .accessibilityHint(isExpandable ? "Double tap to expand and view affirmation" : "")
    }
}

// MARK: - Accessible Progress Card
/// A card showing progress with proper accessibility for VoiceOver
public struct AccessibleProgressCard: View {
    let title: String
    let progress: Double
    let subtitle: String
    let action: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(
        title: String,
        progress: Double,
        subtitle: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.progress = progress
        self.subtitle = subtitle
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12 * dynamicTypeSize.scale) {
                Text(title)
                    .font(.system(size: 17 * dynamicTypeSize.scale, weight: .semibold))
                    .foregroundColor(QXColor.starlight)
                    .lineLimit(2)
                    .accessibilityLabel(title)
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(QXColor.sacredGeometry)
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [QXColor.gold, QXColor.goldGlow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress, height: 4)
                            .accessibilityHidden(true)
                    }
                }
                .frame(height: 4)
                .accessibilityLabel("Progress: \(Int(progress * 100)) percent complete")
                
                Text(subtitle)
                    .font(.system(size: 13 * dynamicTypeSize.scale))
                    .foregroundColor(QXColor.gold)
                    .accessibilityLabel(subtitle)
            }
            .padding(16 * dynamicTypeSize.scale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16 * dynamicTypeSize.scale)
                    .fill(QXColor.deepVoid.opacity(0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(Int(progress * 100)) percent complete, \(subtitle)")
        .accessibilityHint("Double tap to continue learning")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
#Preview("Accessible Cards") {
    ScrollView {
        VStack(spacing: 20) {
            AccessibleCard(
                title: "Example Card",
                accessibilityLabel: "Example card with content"
            ) {
                Text("This is the card content")
                    .foregroundColor(QXColor.starlight)
            }
            
            AccessibleNumberCard(
                number: 7,
                type: "Life Path",
                title: "The Seeker",
                subtitle: "Spiritual • Analytical",
                isSelected: false,
                isMasterNumber: false
            ) {}
            
            AccessibleNumberCard(
                number: 11,
                type: "Expression",
                title: "Illuminator",
                subtitle: "Intuitive • Visionary",
                isSelected: true,
                isMasterNumber: true
            ) {}
            
            AccessibleInsightCard(
                title: "Today's Energy",
                description: "The number 8 carries the vibration of abundance and power. Today, notice where you hold yourself back from receiving.",
                affirmation: "I am open to receiving abundance in all forms."
            )
            
            AccessibleProgressCard(
                title: "The Life Path Numbers",
                progress: 0.7,
                subtitle: "70% complete"
            ) {}
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
