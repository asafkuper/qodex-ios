//
//  QodeXApp.swift
//  QodeX Inner Circle
//
//  A premium numerology membership experience
//

import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct QodeXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var lifecycleManager = AppLifecycleManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(subscriptionManager)
                .environmentObject(lifecycleManager)
                .environmentObject(networkMonitor)
                .preferredColorScheme(.dark)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase with offline persistence
        FirebaseConfig.shared.configure()
        
        // Initialize RevenueCat with secure configuration
        let revenueCatKey = SecureConfig.shared.revenueCatAPIKey
        if !revenueCatKey.isEmpty && !revenueCatKey.contains("your_") {
            Purchases.configure(withAPIKey: revenueCatKey)
        } else {
            print("⚠️ RevenueCat not configured - add REVENUECAT_API_KEY to Info.plist or environment")
        }
        
        // Configure appearance
        configureAppearance()
        
        return true
    }
    
    private func configureAppearance() {
        // Navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(QXColor.cosmicBlack)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(QXColor.deepVoid)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// ContentView is defined in ContentView.swift
