//
//  LiveActivityManager.swift
//  iOS 16.1+ Live Activities for session countdowns
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<QodeXSessionAttributes>?
    
    // MARK: - Start Live Activity
    func startSessionCountdown(sessionName: String, startDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("❌ Live Activities not enabled")
            return
        }
        
        let attributes = QodeXSessionAttributes(
            sessionName: sessionName,
            startTime: startDate
        )
        
        let initialState = QodeXSessionAttributes.ContentState(
            timeRemaining: startDate.timeIntervalSinceNow,
            status: .upcoming
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
            
            // Start updating timer
            startTimerUpdates()
            
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
    
    // MARK: - Update Activity
    func updateActivity(status: SessionStatus) {
        guard let activity = currentActivity else { return }
        
        let updatedState = QodeXSessionAttributes.ContentState(
            timeRemaining: activity.attributes.startTime.timeIntervalSinceNow,
            status: status
        )
        
        Task {
            await activity.update(using: updatedState)
        }
    }
    
    // MARK: - End Activity
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        let finalState = QodeXSessionAttributes.ContentState(
            timeRemaining: 0,
            status: .ended
        )
        
        Task {
            await activity.end(using: finalState, dismissalPolicy: .default)
            currentActivity = nil
        }
    }
    
    // MARK: - Timer Updates
    private func startTimerUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, let activity = self.currentActivity else {
                timer.invalidate()
                return
            }
            
            let timeRemaining = activity.attributes.startTime.timeIntervalSinceNow
            
            if timeRemaining <= 0 {
                self.updateActivity(status: .starting)
                timer.invalidate()
            } else {
                self.updateActivity(status: .upcoming)
            }
        }
    }
}

// MARK: - Activity Attributes
@available(iOS 16.1, *)
struct QodeXSessionAttributes: ActivityAttributes {
    public typealias ContentState = SessionStatusState
    
    let sessionName: String
    let startTime: Date
}

@available(iOS 16.1, *)
struct SessionStatusState: Codable, Hashable {
    let timeRemaining: TimeInterval
    let status: SessionStatus
}

enum SessionStatus: String, Codable {
    case upcoming
    case starting
    case live
    case ended
}

// MARK: - Live Activity Widget
@available(iOS 16.1, *)
struct QodeXLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QodeXSessionAttributes.self) { context in
            // Lock Screen / Notification Center
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "video.fill")
                        .foregroundColor(.gold)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.gold)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.sessionName)
                        .font(.caption)
                        .lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "video.fill")
                    .foregroundColor(.gold)
            } compactTrailing: {
                Text(formatTime(context.state.timeRemaining))
                    .foregroundColor(.gold)
            } minimal: {
                Image(systemName: "video.fill")
                    .foregroundColor(.gold)
            }
        }
    }
}

@available(iOS 16.1, *)
struct LiveActivityView: View {
    let context: ActivityViewContext<QodeXSessionAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundColor(.gold)
                
                Text(context.attributes.sessionName)
                    .font(.headline)
                
                Spacer()
                
                Text(formatTime(context.state.timeRemaining))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.gold)
            }
            
            ProgressView(
                value: max(0, context.state.timeRemaining),
                total: 3600 // 1 hour default
            )
            .progressViewStyle(LinearProgressViewStyle(tint: .gold))
        }
        .padding()
        .background(Color.cosmicBlack)
    }
}

func formatTime(_ interval: TimeInterval) -> String {
    let hours = Int(interval) / 3600
    let minutes = Int(interval) / 60 % 60
    let seconds = Int(interval) % 60
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
