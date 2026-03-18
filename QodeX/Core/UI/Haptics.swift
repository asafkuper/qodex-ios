//
//  Haptics.swift
//  QodeX Haptic Feedback System
//  Reference: iOS 18 Human Interface Guidelines - Haptics
//

import SwiftUI
import UIKit

// MARK: - Haptic Feedback Types

/// Consistent haptic feedback presets for the entire app
enum QXHaptic {
    // MARK: - Impact Feedback
    
    /// Light impact for subtle interactions
    /// Use for: selection changes, light button presses
    static func lightImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact for standard interactions
    /// Use for: button presses, toggles, confirmations
    static func mediumImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact for strong interactions
    /// Use for: errors, deletions, important actions
    static func heavyImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact for gentle interactions
    /// Use for: scroll snaps, subtle state changes
    static func softImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Rigid impact for mechanical feedback
    /// Use for: slider adjustments, precise controls
    static func rigidImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback for value changes
    /// Use for: picker selection, segment control changes
    static func selection() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback for positive outcomes
    /// Use for: completion, success messages, achievements
    static func success() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback for cautionary outcomes
    /// Use for: validation warnings, partial failures
    static func warning() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error feedback for negative outcomes
    /// Use for: errors, failures, deletions
    static func error() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Complex Patterns
    
    /// Success pattern with two light taps
    static func successDouble() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        light.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            light.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Heartbeat pattern for urgent notifications
    static func heartbeat() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let medium = UIImpactFeedbackGenerator(style: .medium)
        medium.prepare()
        
        medium.impactOccurred(intensity: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            medium.impactOccurred(intensity: 0.8)
        }
    }
    
    /// Scroll pattern for continuous feedback
    static func scrollTick() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
    
    /// Premium upgrade pattern
    static func premiumUnlock() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let success = UINotificationFeedbackGenerator()
        
        heavy.prepare()
        success.prepare()
        
        // Build up
        heavy.impactOccurred(intensity: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heavy.impactOccurred(intensity: 0.6)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            success.notificationOccurred(.success)
        }
    }
    
    /// Onboarding step completion
    static func stepComplete() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        light.impactOccurred(intensity: 0.6)
    }
    
    /// Payment confirmation
    static func paymentConfirmed() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let success = UINotificationFeedbackGenerator()
        
        heavy.prepare()
        success.prepare()
        
        heavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            success.notificationOccurred(.success)
        }
    }
    
    // MARK: - Accessibility
    
    /// Announces via accessibility if reduce motion is enabled
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - View Extensions

extension View {
    /// Adds light impact haptic on tap
    func hapticLightOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                QXHaptic.lightImpact()
            }
        )
    }
    
    /// Adds medium impact haptic on tap
    func hapticMediumOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                QXHaptic.mediumImpact()
            }
        )
    }
    
    /// Adds success haptic on tap
    func hapticSuccessOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                QXHaptic.success()
            }
        )
    }
    
    /// Adds selection haptic on value change
    func hapticSelectionOnChange<T: Equatable>(of value: T) -> some View {
        self.onChange(of: value) { _, _ in
            QXHaptic.selection()
        }
    }
    
    /// Adds haptic feedback for button style
    func hapticButton(style: QXHaptic.ButtonStyle = .medium) -> some View {
        self.buttonStyle(HapticButtonStyle(style: style))
    }
}

// MARK: - Haptic Button Style

extension QXHaptic {
    enum ButtonStyle {
        case light, medium, heavy, success
    }
}

struct HapticButtonStyle: ButtonStyle {
    let style: QXHaptic.ButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    switch style {
                    case .light: QXHaptic.lightImpact()
                    case .medium: QXHaptic.mediumImpact()
                    case .heavy: QXHaptic.heavyImpact()
                    case .success: QXHaptic.success()
                    }
                }
            }
    }
}

// MARK: - Haptic Manager

/// Manages complex haptic sequences and state
@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @Published var isHapticsEnabled = true
    
    private init() {
        // Check accessibility settings
        isHapticsEnabled = !UIAccessibility.isReduceMotionEnabled
    }
    
    /// Triggers a haptic if enabled
    func trigger(_ haptic: @escaping () -> Void) {
        guard isHapticsEnabled else { return }
        haptic()
    }
    
    /// Plays a custom pattern
    func playPattern(_ pattern: [HapticEvent]) {
        guard isHapticsEnabled else { return }
        
        for (index, event) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + event.delay) {
                event.feedback()
            }
        }
    }
}

// MARK: - Haptic Event

struct HapticEvent {
    let delay: TimeInterval
    let feedback: () -> Void
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, delay: TimeInterval, intensity: CGFloat = 1.0) -> HapticEvent {
        HapticEvent(delay: delay) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred(intensity: intensity)
        }
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType, delay: TimeInterval) -> HapticEvent {
        HapticEvent(delay: delay) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
    
    static func selection(delay: TimeInterval) -> HapticEvent {
        HapticEvent(delay: delay) {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

// MARK: - Environment Value

private struct HapticManagerKey: EnvironmentKey {
    static let defaultValue = HapticManager.shared
}

extension EnvironmentValues {
    var hapticManager: HapticManager {
        get { self[HapticManagerKey.self] }
        set { self[HapticManagerKey.self] = newValue }
    }
}

// MARK: - Preview

#Preview("Haptic Demo") {
    VStack(spacing: 16) {
        Button("Light Impact") { QXHaptic.lightImpact() }
        Button("Medium Impact") { QXHaptic.mediumImpact() }
        Button("Heavy Impact") { QXHaptic.heavyImpact() }
        Button("Selection") { QXHaptic.selection() }
        Button("Success") { QXHaptic.success() }
        Button("Warning") { QXHaptic.warning() }
        Button("Error") { QXHaptic.error() }
        Button("Premium Unlock") { QXHaptic.premiumUnlock() }
        Button("Payment Confirmed") { QXHaptic.paymentConfirmed() }
    }
    .padding()
    .background(Color.cosmicBlack)
    .foregroundColor(.gold)
}
