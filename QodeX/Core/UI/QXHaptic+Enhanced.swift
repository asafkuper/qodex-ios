//
//  QXHaptic+Enhanced.swift
//  Enhanced Haptic Feedback System
//

import SwiftUI
import CoreHaptics

// MARK: - Enhanced Haptic Engine
class QXHapticEngine {
    static let shared = QXHapticEngine()
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    /// Custom haptic pattern for premium feel
    func playPremiumSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            // Fallback to standard haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        let decayIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let decayEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [decayIntensity, sharpness],
            relativeTime: 0.1,
            duration: 0.2
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event, decayEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    /// Sacred geometry-inspired haptic pattern
    func playSacredPattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            return
        }
        
        // Fibonacci-inspired timing: 0, 1, 1, 2, 3, 5
        let timings: [TimeInterval] = [0, 0.1, 0.2, 0.4, 0.7, 1.2]
        var events: [CHHapticEvent] = []
        
        for (index, time) in timings.enumerated() {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(0.9 - (Double(index) * 0.1))
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: 0.6
            )
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: time
            )
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    /// Celestial alignment haptic
    func playCelestialAlignment() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            return
        }
        
        // Rising intensity pattern
        var events: [CHHapticEvent] = []
        for i in 0...<5 {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(0.3 + (Double(i) * 0.15))
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: 0.5
            )
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: Double(i) * 0.15
            )
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Silent fail for haptics
        }
    }
}

// MARK: - Enhanced Haptic Modifiers
struct HapticTapModifier: ViewModifier {
    let style: QXHaptic.TapStyle
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                QXHaptic.tap(style: style)
            }
    }
}

extension View {
    func hapticTap(_ style: QXHaptic.TapStyle = .light) -> some View {
        modifier(HapticTapModifier(style: style))
    }
}

// MARK: - Enhanced QXHaptic
extension QXHaptic {
    enum TapStyle {
        case light
        case medium
        case heavy
        case sacred
        case celestial
    }
    
    static func tap(style: TapStyle = .light) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .sacred:
            QXHapticEngine.shared.playSacredPattern()
        case .celestial:
            QXHapticEngine.shared.playCelestialAlignment()
        }
    }
    
    /// Premium success with custom pattern
    static func premiumSuccess() {
        QXHapticEngine.shared.playPremiumSuccess()
    }
    
    /// Streak milestone celebration
    static func streakMilestone(_ days: Int) {
        // Different patterns for different milestones
        switch days {
        case 7:
            // Week milestone
            QXHapticEngine.shared.playSacredPattern()
        case 30:
            // Month milestone
            QXHapticEngine.shared.playCelestialAlignment()
        case 100:
            // Century milestone
            playPremiumSuccess()
        default:
            mediumImpact()
        }
    }
}

// MARK: - Preview
#Preview("Haptic Test") {
    VStack(spacing: 20) {
        Button("Light Tap") { QXHaptic.tap(style: .light) }
        Button("Sacred Pattern") { QXHaptic.tap(style: .sacred) }
        Button("Celestial") { QXHaptic.tap(style: .celestial) }
        Button("Premium Success") { QXHaptic.premiumSuccess() }
        Button("7-Day Streak") { QXHaptic.streakMilestone(7) }
        Button("30-Day Streak") { QXHaptic.streakMilestone(30) }
    }
    .padding()
}
