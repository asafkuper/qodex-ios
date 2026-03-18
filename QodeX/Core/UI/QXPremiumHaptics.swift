//
//  QXPremiumHaptics.swift
//  QodeX Premium Haptic Feedback System
//  Reference: iOS 18 Human Interface Guidelines - Haptics
//

import SwiftUI
import UIKit

// MARK: - Enhanced Haptic Feedback Types
public enum QXHaptic {
    
    // MARK: - Impact Feedback
    
    /// Light impact for subtle interactions
    public static func lightImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact for standard interactions
    public static func mediumImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact for strong interactions
    public static func heavyImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact for gentle interactions
    public static func softImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Rigid impact for mechanical feedback
    public static func rigidImpact() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback for value changes
    public static func selection() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback for positive outcomes
    public static func success() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback for cautionary outcomes
    public static func warning() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error feedback for negative outcomes
    public static func error() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Complex Patterns
    
    /// Success pattern with two light taps
    public static func successDouble() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        light.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            light.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Success pattern with escalating intensity
    public static func successPattern() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        
        // Build up
        softImpact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lightImpact()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            mediumImpact()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            success()
        }
    }
    
    /// Heartbeat pattern for urgent notifications
    public static func heartbeat() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let medium = UIImpactFeedbackGenerator(style: .medium)
        medium.prepare()
        
        medium.impactOccurred(intensity: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            medium.impactOccurred(intensity: 0.8)
        }
    }
    
    /// Scroll pattern for continuous feedback
    public static func scrollTick() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
    
    /// Premium upgrade pattern - build up and release
    public static func premiumUnlock() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let success = UINotificationFeedbackGenerator()
        
        heavy.prepare()
        success.prepare()
        
        // Build up anticipation
        heavy.impactOccurred(intensity: 0.3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            heavy.impactOccurred(intensity: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            heavy.impactOccurred(intensity: 0.7)
        }
        
        // Release
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            success.notificationOccurred(.success)
        }
        
        // Echo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            heavy.impactOccurred(intensity: 0.3)
        }
    }
    
    /// Onboarding step completion
    public static func stepComplete() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        light.impactOccurred(intensity: 0.6)
    }
    
    /// Payment confirmation
    public static func paymentConfirmed() {
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
    
    /// Streak milestone celebration
    public static func streakMilestone() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        
        // Rapid fire celebration taps
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                light.impactOccurred(intensity: 0.5 + Double(i) * 0.1)
            }
        }
        
        // Final success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            success()
        }
    }
    
    /// Button press with confirmation
    public static func buttonPress() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        rigidImpact()
    }
    
    /// Card selection
    public static func cardSelection() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        softImpact()
    }
    
    /// Number count tick
    public static func countTick() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
    
    /// Number count completion
    public static func countComplete() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        mediumImpact()
    }
    
    /// Swipe success
    public static func swipeSuccess() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        lightImpact()
    }
    
    /// Pull to refresh trigger
    public static func refreshTrigger() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        mediumImpact()
    }
    
    /// Peek/Preview pop
    public static func peekPop() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        rigidImpact()
    }
    
    // MARK: - Generic Trigger
    
    public enum FeedbackType {
        case light, medium, heavy, soft, rigid
        case selection
        case success, warning, error
    }
    
    public static func trigger(_ type: FeedbackType) {
        switch type {
        case .light: lightImpact()
        case .medium: mediumImpact()
        case .heavy: heavyImpact()
        case .soft: softImpact()
        case .rigid: rigidImpact()
        case .selection: selection()
        case .success: success()
        case .warning: warning()
        case .error: error()
        }
    }
    
    // MARK: - Accessibility
    
    /// Announces via accessibility if reduce motion is enabled
    public static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - View Extensions
public extension View {
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
}

// MARK: - Haptic Button Style
public struct HapticButtonStyle: ButtonStyle {
    let style: QXHaptic.FeedbackType
    
    public init(style: QXHaptic.FeedbackType = .medium) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    QXHaptic.trigger(style)
                }
            }
    }
}

// MARK: - Haptic Manager
@MainActor
public class HapticManager: ObservableObject {
    public static let shared = HapticManager()
    
    @Published public var isHapticsEnabled = true
    
    private init() {
        isHapticsEnabled = !UIAccessibility.isReduceMotionEnabled
    }
    
    /// Triggers a haptic if enabled
    public func trigger(_ haptic: @escaping () -> Void) {
        guard isHapticsEnabled else { return }
        haptic()
    }
    
    /// Plays a custom pattern
    public func playPattern(_ pattern: [HapticEvent]) {
        guard isHapticsEnabled else { return }
        
        for (index, event) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + event.delay) {
                event.feedback()
            }
        }
    }
}

// MARK: - Haptic Event
public struct HapticEvent {
    public let delay: TimeInterval
    public let feedback: () -> Void
    
    public init(delay: TimeInterval, feedback: @escaping () -> Void) {
        self.delay = delay
        self.feedback = feedback
    }
    
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, delay: TimeInterval, intensity: CGFloat = 1.0) -> HapticEvent {
        HapticEvent(delay: delay) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred(intensity: intensity)
        }
    }
    
    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType, delay: TimeInterval) -> HapticEvent {
        HapticEvent(delay: delay) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
    
    public static func selection(delay: TimeInterval) -> HapticEvent {
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

public extension EnvironmentValues {
    var hapticManager: HapticManager {
        get { self[HapticManagerKey.self] }
        set { self[HapticManagerKey.self] = newValue }
    }
}

// MARK: - Preview
#Preview("Haptic Demo") {
    VStack(spacing: 20) {
        Button("Light Impact") { QXHaptic.lightImpact() }
        Button("Medium Impact") { QXHaptic.mediumImpact() }
        Button("Heavy Impact") { QXHaptic.heavyImpact() }
        Button("Selection") { QXHaptic.selection() }
        Button("Success") { QXHaptic.success() }
        Button("Success Pattern") { QXHaptic.successPattern() }
        Button("Premium Unlock") { QXHaptic.premiumUnlock() }
        Button("Streak Milestone") { QXHaptic.streakMilestone() }
    }
    .padding()
    .background(Color.cosmicBlack)
    .foregroundColor(.gold)
}
