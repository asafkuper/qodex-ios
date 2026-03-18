import SwiftUI

// MARK: - Accessibility Labels

enum AccessibilityLabels {
    // Numbers
    static let lifePathNumber = "Your Life Path Number %d, button, double tap to view detailed interpretation"
    static let expressionNumber = "Your Expression Number %d, represents your natural talents"
    static let soulUrgeNumber = "Your Soul Urge Number %d, your inner desires"
    static let birthdayNumber = "Your Birthday Number %d, special gift"
    static let masterNumber = "Master Number %d, powerful spiritual energy"
    
    // Actions
    static let calculateButton = "Calculate your numbers, button"
    static let shareButton = "Share your results, button"
    static let saveButton = "Save to favorites, button"
    static let settingsButton = "Open settings, button"
    static let backButton = "Go back, button"
    
    // Navigation
    static let homeTab = "Home tab, showing your daily guidance"
    static let calculatorTab = "Calculator tab, discover your numbers"
    static let communityTab = "Community tab, connect with others"
    static let profileTab = "Profile tab, your account settings"
    
    // Content
    static let dailyQodeCard = "Today's Daily Qode, %@"
    static let compatibilityResult = "Compatibility score %d percent with %@"
    static let loading = "Loading, please wait"
    static let error = "Error occurred, %@"
}

// MARK: - Accessible View Modifiers

struct AccessibleNumberView: View {
    let number: Int
    let type: NumberType
    let size: CGFloat
    
    enum NumberType {
        case lifePath
        case expression
        case soulUrge
        case birthday
        case daily
        
        var label: String {
            switch self {
            case .lifePath: return "Life Path"
            case .expression: return "Expression"
            case .soulUrge: return "Soul Urge"
            case .birthday: return "Birthday"
            case .daily: return "Daily Qode"
            }
        }
    }
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: size, weight: .bold, design: .rounded))
            .accessibilityLabel("\(type.label) Number \(number)")
            .accessibilityHint("Double tap to learn more about this number")
            .accessibilityAddTraits(.isButton)
    }
}

struct AccessibleButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    let hint: String?
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let image = systemImage {
                    Image(systemName: image)
                }
                Text(title)
            }
        }
        .accessibilityLabel(title)
        .accessibilityHint(hint ?? "")
    }
}

struct AccessibleCard<Content: View>: View {
    let title: String
    let content: Content
    let hint: String?
    
    init(title: String, hint: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.hint = hint
        self.content = content()
    }
    
    var body: some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Dynamic Type Support

struct ScalableText: View {
    let text: String
    let font: Font
    let weight: Font.Weight
    
    var body: some View {
        Text(text)
            .font(font.weight(weight))
            .minimumScaleFactor(0.5)
            .lineLimit(nil)
    }
}

// MARK: - Reduce Motion Support

struct ConditionalAnimation<Content: View>: View {
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
                .animation(animation, value: true)
        }
    }
}

// MARK: - Accessibility Audit Helper

class AccessibilityAuditor {
    static let shared = AccessibilityAuditor()
    
    func auditView(_ view: AnyView, name: String) -> [AccessibilityIssue] {
        var issues: [AccessibilityIssue] = []
        
        // Check for minimum touch target (44pt)
        // Check for color contrast
        // Check for VoiceOver labels
        // Check for Dynamic Type support
        
        return issues
    }
    
    func runFullAudit() -> AccessibilityReport {
        return AccessibilityReport(
            date: Date(),
            score: 0,
            issues: [],
            recommendations: []
        )
    }
}

struct AccessibilityIssue: Identifiable {
    let id = UUID()
    let severity: Severity
    let description: String
    let recommendation: String
    
    enum Severity {
        case critical, high, medium, low
    }
}

struct AccessibilityReport {
    let date: Date
    let score: Int
    let issues: [AccessibilityIssue]
    let recommendations: [String]
}

// MARK: - View Extensions

extension View {
    func accessibleNumber(_ number: Int, type: AccessibleNumberView.NumberType) -> some View {
        self.accessibilityLabel("\(type.label) Number \(number)")
    }
    
    func accessibleButton(hint: String) -> some View {
        self.accessibilityHint(hint)
    }
    
    func accessibleCard(title: String, hint: String? = nil) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(hint ?? "")
    }
}
