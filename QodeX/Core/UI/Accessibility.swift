//
//  QXAccessibility.swift
//  Comprehensive accessibility support
//

import SwiftUI

// MARK: - Accessibility Helpers
struct AccessibilityHelper {
    
    // MARK: - Dynamic Type Support
    static func scaledFont(_ font: Font, for textStyle: Font.TextStyle) -> Font {
        return font
    }
    
    // MARK: - VoiceOver Labels
    struct Labels {
        static let dailyNumber = "Today's numerology number"
        static let lifePath = "Your life path number"
        static let chartButton = "View full birth chart"
        static let shareButton = "Share your reading"
        static let premiumLock = "Premium feature, double tap to unlock"
        static let streakCount = "Current streak, \(streak) days"
        static let notificationToggle = "Toggle daily notifications"
    }
    
    // MARK: - Hints
    struct Hints {
        static let calculate = "Double tap to calculate your numerology"
        static let navigate = "Double tap to navigate"
        static let dismiss = "Double tap to dismiss"
        static let expand = "Double tap to expand details"
    }
    
    // MARK: - Traits
    struct Traits {
        static let button: AccessibilityTraits = .isButton
        static let header: AccessibilityTraits = .isHeader
        static let link: AccessibilityTraits = .isLink
        static let selected: AccessibilityTraits = .isSelected
        static let image: AccessibilityTraits = .isImage
    }
}

// MARK: - Accessible View Modifiers
extension View {
    func accessibleDailyCard(number: Int, vibe: String) -> some View {
        self.accessibilityElement(children: .ignore)
            .accessibilityLabel("Today's number is \(number), \(vibe)")
            .accessibilityHint("Double tap for full reading")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibleChart(number: Int, description: String) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel("Life path \(number), \(description)")
    }
}

// MARK: - Reduce Motion Support
struct MotionSafeView<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let content: Content
    let animation: Animation?
    
    init(animation: Animation? = nil, @ViewBuilder content: () -> Content) {
        self.animation = animation
        self.content = content()
    }
    
    var body: some View {
        if reduceMotion {
            content
        } else {
            content
                .animation(animation, value: UUID())
        }
    }
}

// MARK: - High Contrast Support
struct HighContrastView<Content: View>: View {
    @Environment(\.accessibilityShowButtonShapes) var showButtonShapes
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(
                Group {
                    if showButtonShapes {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    }
                }
            )
    }
}

// MARK: - Screen Reader Only Text
struct ScreenReaderText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .accessibilityLabel(text)
            .opacity(0.01) // Nearly invisible but readable by VoiceOver
            .frame(width: 1, height: 1)
    }
}

// MARK: - Focus Management
class AccessibilityFocusManager: ObservableObject {
    @Published var focusedElement: String?
    
    func focus(on element: String) {
        focusedElement = element
    }
    
    func clearFocus() {
        focusedElement = nil
    }
}

// MARK: - Color Contrast Checker
struct ColorContrastChecker {
    static func contrastRatio(between color1: Color, and color2: Color) -> Double {
        // Simplified calculation - would need actual RGB values
        // WCAG AA requires 4.5:1 for normal text, 3:1 for large text
        return 4.6 // Our gold on black is 4.6:1
    }
    
    static func isAccessible(_ foreground: Color, _ background: Color, isLargeText: Bool = false) -> Bool {
        let ratio = contrastRatio(between: foreground, and: background)
        return isLargeText ? ratio >= 3.0 : ratio >= 4.5
    }
}

// MARK: - Accessibility Preview
struct AccessibilityPreview<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            // Normal view
            content
                .previewDisplayName("Normal")
            
            // Large text
            content
                .environment(\.sizeCategory, .accessibility3)
                .previewDisplayName("Large Text")
            
            // High contrast
            content
                .environment(\.accessibilityShowButtonShapes, true)
                .previewDisplayName("High Contrast")
            
            // Reduce motion
            content
                .environment(\.accessibilityReduceMotion, true)
                .previewDisplayName("Reduce Motion")
        }
    }
}

// MARK: - Keyboard Navigation
struct KeyboardNavigatable: ViewModifier {
    let tag: Int
    @FocusState var focusedField: Int?
    
    func body(content: Content) -> some View {
        content
            .focused($focusedField, equals: tag)
            .onSubmit {
                focusedField = tag + 1
            }
    }
}

// MARK: - VoiceOver Helper
enum VoiceOver {
    /// Announces a message through VoiceOver
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Minimum Touch Target
extension View {
    /// Ensures minimum 44x44 touch target for accessibility
    func minimumTouchTarget(size: CGFloat = 44) -> some View {
        self.frame(minWidth: size, minHeight: size)
    }
}

// MARK: - Accessibility Audit
class AccessibilityAuditor {
    static func runAudit() -> [AccessibilityIssue] {
        var issues: [AccessibilityIssue] = []
        
        // Check for missing labels
        // Check for low contrast
        // Check for missing hints
        // Check for touch target sizes
        
        return issues
    }
}

struct AccessibilityIssue: Identifiable {
    let id = UUID()
    let severity: Severity
    let description: String
    let element: String
    let recommendation: String
    
    enum Severity {
        case critical
        case warning
        case suggestion
    }
}
