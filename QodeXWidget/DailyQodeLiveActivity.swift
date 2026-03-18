import ActivityKit
import WidgetKit
import SwiftUI

struct DailyQodeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var dailyNumber: Int
        var dailyMessage: String
        var energyLevel: String
        var progress: Double
    }
    
    var name: String
}

struct DailyQodeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DailyQodeAttributes.self) { context in
            // Lock screen / banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedView(context: context)
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<DailyQodeAttributes>
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.black.gradient)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(context.state.dailyNumber)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(Color("QodeGold"))
                    
                    Text(context.state.energyLevel)
                        .font(.title2)
                }
                .frame(width: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Qode")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(context.state.dailyMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    ProgressView(value: context.state.progress)
                        .tint(Color("QodeGold"))
                        .frame(width: 150)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct DynamicIslandExpandedView: View {
    let context: ActivityViewContext<DailyQodeAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Qode")
                    .font(.headline)
                Spacer()
                Text(context.state.energyLevel)
                    .font(.title3)
            }
            
            HStack(spacing: 16) {
                Text("\(context.state.dailyNumber)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("QodeGold"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.dailyMessage)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    ProgressView(value: context.state.progress)
                        .tint(Color("QodeGold"))
                }
            }
        }
        .padding()
    }
}

struct CompactLeadingView: View {
    let context: ActivityViewContext<DailyQodeAttributes>
    
    var body: some View {
        Text("\(context.state.dailyNumber)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(Color("QodeGold"))
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<DailyQodeAttributes>
    
    var body: some View {
        Text(context.state.energyLevel)
            .font(.title3)
    }
}

struct MinimalView: View {
    let context: ActivityViewContext<DailyQodeAttributes>
    
    var body: some View {
        Text("\(context.state.dailyNumber)")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(Color("QodeGold"))
    }
}

// MARK: - Live Activity Manager

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<DailyQodeAttributes>?
    
    func startDailyQodeActivity(dailyNumber: Int, message: String, energy: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = DailyQodeAttributes(name: "Daily Qode")
        let contentState = DailyQodeAttributes.ContentState(
            dailyNumber: dailyNumber,
            dailyMessage: message,
            energyLevel: energy,
            progress: 0.0
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
        } catch {
            print("Live Activity error: \(error)")
        }
    }
    
    func updateActivity(progress: Double) {
        guard let activity = currentActivity else { return }
        
        let updatedState = DailyQodeAttributes.ContentState(
            dailyNumber: activity.contentState.dailyNumber,
            dailyMessage: activity.contentState.dailyMessage,
            energyLevel: activity.contentState.energyLevel,
            progress: progress
        )
        
        Task {
            await activity.update(using: updatedState)
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}
