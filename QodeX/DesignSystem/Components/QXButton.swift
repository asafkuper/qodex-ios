import SwiftUI

struct QXButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case ghost
        case gold
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: QXSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .accessibilityHidden(true) // Icon is decorative
                }
                Text(title)
                    .font(QXFont.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, QXSpacing.md)
            .padding(.horizontal, QXSpacing.lg)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .ghost ? 1 : 0)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .accessibleButton(label: title, hint: "Double tap to \(title.lowercased())")
        .minimumTouchTarget()
        .animation(.easeOut(duration: 0.15), value: isPressed)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return QXColor.cosmicPurple
        case .secondary: return QXColor.sacredGeometry
        case .ghost: return Color.clear
        case .gold: return QXColor.gold
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .gold: return QXColor.starlight
        case .ghost: return QXColor.gold
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .ghost: return QXColor.gold.opacity(0.5)
        default: return Color.clear
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Number Display
struct NumberDisplay: View {
    let number: Int
    let label: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: QXSpacing.xs) {
            Text("\(number)")
                .font(.system(size: isHighlighted ? 64 : 48, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? QXColor.gold : QXColor.starlight)
                .shadow(color: isHighlighted ? QXColor.gold.opacity(0.5) : .clear, radius: isHighlighted ? 20 : 0)
            
            Text(label)
                .font(QXFont.caption)
                .foregroundColor(QXColor.starlight.opacity(0.6))
                .textCase(.uppercase)
        }
        .frame(minWidth: 80)
    }
}

#Preview {
    ZStack {
        SacredGeometryBackground()
        
        VStack(spacing: QXSpacing.lg) {
            GlassCard {
                VStack(spacing: QXSpacing.md) {
                    NumberDisplay(number: 7, label: "Life Path", isHighlighted: true)
                    NumberDisplay(number: 3, label: "Expression", isHighlighted: false)
                }
            }
            
            QXButton(title: "Enter the Circle", icon: "sparkles", style: .gold) {}
            QXButton(title: "Learn More", icon: nil, style: .ghost) {}
        }
        .padding()
    }
}
