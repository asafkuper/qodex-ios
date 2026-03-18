//
//  ScreenTimeIntegration.swift
//  iOS Screen Time API integration for parental controls
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

@available(iOS 15.0, *)
class ScreenTimeIntegration {
    static let shared = ScreenTimeIntegration()
    
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    // MARK: - Request Authorization
    func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
    }
    
    // MARK: - Focus Mode Integration
    func enableFocusMode() {
        // Shield distracting apps during meditation/reading
        let distractions = ShieldConfiguration(
            blockedApplications: [
                // Social media apps would be shielded
                // Only during QodeX sessions
            ],
            blockedCategories: [
                .socialNetworking
            ]
        )
        store.shield.applications = distractions.blockedApplications
        store.shield.applicationCategories = .specific(distractions.blockedCategories ?? [])
    }
    
    func disableFocusMode() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
    
    // MARK: - App Usage Tracking
    func trackSessionUsage(sessionType: SessionType, duration: TimeInterval) {
        // Log usage for Screen Time reports
        let activity = DeviceActivityName("qodex.\(sessionType.rawValue)")
        
        // This would integrate with Screen Time dashboard
        // Showing time spent in app for meditation, learning, etc.
    }
    
    enum SessionType: String {
        case meditation = "meditation"
        case reading = "reading"
        case community = "community"
        case liveSession = "liveSession"
    }
    
    // MARK: - Daily Limits
    func setDailyLimit(minutes: Int) {
        // Set daily usage limit for the app
        // When exceeded, show gentle reminder
    }
    
    // MARK: - Schedule Do Not Disturb
    func scheduleMeditationFocus(startHour: Int, endHour: Int) {
        // Automatically enable focus mode during meditation hours
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: 0),
            intervalEnd: DateComponents(hour: endHour, minute: 0),
            repeats: true,
            warningTime: nil
        )
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(
                DeviceActivityName("qodex.meditationFocus"),
                during: schedule
            )
        } catch {
            print("❌ Failed to schedule focus: \(error)")
        }
    }
}

// MARK: - Screen Time Widget
@available(iOS 16.0, *)
struct ScreenTimeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.qodex.screentime",
            provider: ScreenTimeProvider()
        ) { entry in
            ScreenTimeWidgetView(entry: entry)
        }
        .configurationDisplayName("QodeX Time")
        .description("Track your spiritual practice time")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

@available(iOS 16.0, *)
struct ScreenTimeEntry: TimelineEntry {
    let date: Date
    let minutesToday: Int
    let goalMinutes: Int
}

@available(iOS 16.0, *)
struct ScreenTimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScreenTimeEntry {
        ScreenTimeEntry(date: Date(), minutesToday: 30, goalMinutes: 60)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScreenTimeEntry) -> Void) {
        let minutes = UserDefaults.standard.integer(forKey: "qodexMinutesToday")
        completion(ScreenTimeEntry(date: Date(), minutesToday: minutes, goalMinutes: 60))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScreenTimeEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
            completion(timeline)
        }
    }
}

@available(iOS 16.0, *)
struct ScreenTimeWidgetView: View {
    let entry: ScreenTimeEntry
    
    var body: some View {
        VStack {
            Text("\(entry.minutesToday)m")
                .font(.headline)
                .foregroundColor(.gold)
            
            ProgressView(
                value: Double(entry.minutesToday),
                total: Double(entry.goalMinutes)
            )
            .progressViewStyle(CircularProgressViewStyle(tint: .gold))
            .scaleEffect(0.8)
        }
    }
}
