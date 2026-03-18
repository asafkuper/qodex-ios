//
//  TipKitIntegration.swift
//  iOS 17+ TipKit for contextual tips
//

import SwiftUI
import TipKit

@available(iOS 17.0, *)
struct DailyNumberTip: Tip {
    var title: Text {
        Text("Discover Your Daily Energy")
    }
    
    var message: Text? {
        Text("Check your daily number each morning for personalized guidance.")
    }
    
    var image: Image? {
        Image(systemName: "number.circle.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasCheckedDailyNumber) {
                $0 == false
            }
        ]
    }
    
    @Parameter
    static var hasCheckedDailyNumber: Bool = false
}

@available(iOS 17.0, *)
struct StreakTip: Tip {
    var title: Text {
        Text("Build Your Streak")
    }
    
    var message: Text? {
        Text("Check in daily to build your streak and unlock achievements.")
    }
    
    var image: Image? {
        Image(systemName: "flame.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$streakCount) {
                $0 < 3
            }
        ]
    }
    
    @Parameter
    static var streakCount: Int = 0
}

@available(iOS 17.0, *)
struct MentorshipTip: Tip {
    var title: Text {
        Text("Connect with a Mentor")
    }
    
    var message: Text? {
        Text("Get personalized guidance from numerology experts.")
    }
    
    var image: Image? {
        Image(systemName: "person.2.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasViewedMentorship) {
                $0 == false
            },
            #Rule(Self.$daysSinceSignup) {
                $0 >= 3
            }
        ]
    }
    
    @Parameter
    static var hasViewedMentorship: Bool = false
    
    @Parameter
    static var daysSinceSignup: Int = 0
}

@available(iOS 17.0, *)
struct CommunityTip: Tip {
    var title: Text {
        Text("Join the Community")
    }
    
    var message: Text? {
        Text("Share insights and connect with like-minded seekers.")
    }
    
    var image: Image? {
        Image(systemName: "bubble.left.and.bubble.right.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasPostedInCommunity) {
                $0 == false
            },
            #Rule(Self.$appOpens) {
                $0 >= 5
            }
        ]
    }
    
    @Parameter
    static var hasPostedInCommunity: Bool = false
    
    @Parameter
    static var appOpens: Int = 0
}

@available(iOS 17.0, *)
struct UpgradeTip: Tip {
    var title: Text {
        Text("Unlock Full Insights")
    }
    
    var message: Text? {
        Text("Upgrade to see all 9 of your core numerology numbers.")
    }
    
    var image: Image? {
        Image(systemName: "star.circle.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isFreeUser) {
                $0 == true
            },
            #Rule(Self.$daysActive) {
                $0 >= 7
            }
        ]
    }
    
    @Parameter
    static var isFreeUser: Bool = true
    
    @Parameter
    static var daysActive: Int = 0
}

// MARK: - Tip Presentation View
@available(iOS 17.0, *)
struct TipView<Content: View>: View {
    let tip: any Tip
    let content: Content
    
    init(tip: any Tip, @ViewBuilder content: () -> Content) {
        self.tip = tip
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TipView(tip)
            content
        }
    }
}

// MARK: - Tip Configuration
@available(iOS 17.0, *)
class TipKitConfiguration {
    static func configure() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
    
    static func resetAllTips() {
        Tips.resetDatastore()
    }
    
    static func markParameter(<T> parameter: Tips.Parameter<T>,
                               value: T) {
        parameter.withValue(value)
    }
}
