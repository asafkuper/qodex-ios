//
//  QuickActionsManager.swift
//  Home Screen Quick Actions (3D Touch / Haptic Touch)
//

import UIKit

class QuickActionsManager {
    static let shared = QuickActionsManager()
    
    enum QuickActionType: String {
        case dailyNumber = "dailyNumber"
        case meditate = "meditate"
        case journal = "journal"
        case viewChart = "viewChart"
        case liveSession = "liveSession"
    }
    
    // MARK: - Configure Quick Actions
    func configureQuickActions() {
        var actions: [UIApplicationShortcutItem] = []
        
        // Daily Number
        let dailyAction = UIApplicationShortcutItem(
            type: QuickActionType.dailyNumber.rawValue,
            localizedTitle: "Daily Number",
            localizedSubtitle: "See today's energy",
            icon: UIApplicationShortcutIcon(type: .favorite),
            userInfo: nil
        )
        actions.append(dailyAction)
        
        // Meditate
        let meditateAction = UIApplicationShortcutItem(
            type: QuickActionType.meditate.rawValue,
            localizedTitle: "Meditate",
            localizedSubtitle: "Quick 5-min session",
            icon: UIApplicationShortcutIcon(type: .play),
            userInfo: nil
        )
        actions.append(meditateAction)
        
        // Journal
        let journalAction = UIApplicationShortcutItem(
            type: QuickActionType.journal.rawValue,
            localizedTitle: "Journal",
            localizedSubtitle: "Record insights",
            icon: UIApplicationShortcutIcon(type: .compose),
            userInfo: nil
        )
        actions.append(journalAction)
        
        // Live Session
        let liveAction = UIApplicationShortcutItem(
            type: QuickActionType.liveSession.rawValue,
            localizedTitle: "Live Session",
            localizedSubtitle: "Join upcoming",
            icon: UIApplicationShortcutIcon(type: .time),
            userInfo: nil
        )
        actions.append(liveAction)
        
        UIApplication.shared.shortcutItems = actions
    }
    
    // MARK: - Update Dynamic Actions
    func updateDynamicActions() {
        var actions = UIApplication.shared.shortcutItems ?? []
        
        // Add recent calculation if available
        if let recentNumber = UserDefaults.standard.object(forKey: "recentLifePath") as? Int {
            let recentAction = UIApplicationShortcutItem(
                type: QuickActionType.viewChart.rawValue,
                localizedTitle: "My Chart",
                localizedSubtitle: "Life Path \(recentNumber)",
                icon: UIApplicationShortcutIcon(type: .contact),
                userInfo: ["lifePath": recentNumber]
            )
            actions.insert(recentAction, at: 0)
        }
        
        // Keep only top 4
        actions = Array(actions.prefix(4))
        UIApplication.shared.shortcutItems = actions
    }
    
    // MARK: - Handle Quick Action
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem, from scene: UISceneDelegate?) -> Bool {
        guard let type = QuickActionType(rawValue: shortcutItem.type) else {
            return false
        }
        
        switch type {
        case .dailyNumber:
            navigateToDailyNumber()
        case .meditate:
            navigateToMeditation()
        case .journal:
            navigateToJournal()
        case .viewChart:
            navigateToChart()
        case .liveSession:
            navigateToLiveSession()
        }
        
        return true
    }
    
    // MARK: - Navigation
    private func navigateToDailyNumber() {
        // Post notification to navigate to daily number view
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToDailyNumber"),
            object: nil
        )
    }
    
    private func navigateToMeditation() {
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToMeditation"),
            object: nil
        )
    }
    
    private func navigateToJournal() {
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToJournal"),
            object: nil
        )
    }
    
    private func navigateToChart() {
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToChart"),
            object: nil
        )
    }
    
    private func navigateToLiveSession() {
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToLiveSession"),
            object: nil
        )
    }
}

// MARK: - App Delegate Extension
extension QodeXApp {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = QuickActionsManager.shared.handleQuickAction(shortcutItem, from: nil)
        completionHandler(handled)
    }
}

// MARK: - Scene Delegate Extension
extension QodeXSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = QuickActionsManager.shared.handleQuickAction(shortcutItem, from: self)
        completionHandler(handled)
    }
}
