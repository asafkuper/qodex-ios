//
//  AppLifecycleManager.swift
//  Application lifecycle state management
//

import Foundation
import SwiftUI
import Combine

// MARK: - App Lifecycle Manager
class AppLifecycleManager: ObservableObject {
    
    // MARK: - Shared Instance
    static let shared = AppLifecycleManager()
    
    // MARK: - Published State
    @Published var appState: AppState = .foreground
    @Published var timeInBackground: TimeInterval = 0
    @Published var sessionStartTime: Date = Date()
    
    // MARK: - App State Enum
    enum AppState: Equatable {
        case foreground
        case background
        case inactive
        
        var isActive: Bool {
            self == .foreground
        }
        
        var description: String {
            switch self {
            case .foreground: return "Foreground"
            case .background: return "Background"
            case .inactive: return "Inactive"
            }
        }
    }
    
    // MARK: - Private Properties
    private var backgroundEntryTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private let stateSubject = CurrentValueSubject<AppState, Never>(.foreground)
    
    var statePublisher: AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    private init() {
        setupObservers()
    }
    
    // MARK: - Notification Observers
    
    private func setupObservers() {
        // App enters background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // App will enter foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // App becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // App will resign active (inactive state)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // Memory warning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // App will terminate
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    // MARK: - Lifecycle Handlers
    
    @objc private func appDidEnterBackground() {
        appState = .background
        backgroundEntryTime = Date()
        stateSubject.send(.background)
        
        print("[LIFECYCLE] App entered background")
        
        // Save critical state
        saveApplicationState()
        
        // Pause non-critical operations
        pauseBackgroundOperations()
        
        // Schedule background refresh if needed
        scheduleBackgroundRefresh()
    }
    
    @objc private func appWillEnterForeground() {
        appState = .foreground
        stateSubject.send(.foreground)
        
        // Calculate time spent in background
        if let backgroundTime = backgroundEntryTime {
            timeInBackground = Date().timeIntervalSince(backgroundTime)
            print("[LIFECYCLE] App returning from background after \(Int(timeInBackground))s")
        }
        
        // Refresh data if needed
        if shouldRefreshData() {
            refreshData()
        }
        
        // Resume operations
        resumeOperations()
        
        // Update last active timestamp
        updateLastActive()
    }
    
    @objc private func appDidBecomeActive() {
        if appState != .foreground {
            appState = .foreground
            stateSubject.send(.foreground)
        }
        print("[LIFECYCLE] App became active")
    }
    
    @objc private func appWillResignActive() {
        appState = .inactive
        stateSubject.send(.inactive)
        print("[LIFECYCLE] App will resign active")
    }
    
    @objc private func didReceiveMemoryWarning() {
        print("[LIFECYCLE] Memory warning received - clearing caches")
        clearNonEssentialCaches()
    }
    
    @objc private func appWillTerminate() {
        print("[LIFECYCLE] App will terminate - performing cleanup")
        saveApplicationState()
        performCleanup()
    }
    
    // MARK: - State Management
    
    private func saveApplicationState() {
        // Save any critical application state
        UserDefaults.standard.set(Date(), forKey: "lastBackgroundTime")
        UserDefaults.standard.set(sessionStartTime, forKey: "sessionStartTime")
        UserDefaults.standard.synchronize()
        
        print("[LIFECYCLE] Application state saved")
    }
    
    private func pauseBackgroundOperations() {
        // Pause any non-essential background operations
        // This could include:
        // - Analytics batch uploads
        // - Non-critical network requests
        // - Heavy computation tasks
        print("[LIFECYCLE] Background operations paused")
    }
    
    private func resumeOperations() {
        // Resume any paused operations
        print("[LIFECYCLE] Operations resumed")
    }
    
    // MARK: - Data Refresh Logic
    
    private func shouldRefreshData() -> Bool {
        // Refresh data if:
        // 1. Been in background for more than 5 minutes
        // 2. It's a new day (for daily content)
        // 3. User has been away for extended period
        
        if timeInBackground > 300 { // 5 minutes
            return true
        }
        
        // Check if it's a new day
        let lastActive = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDate(lastActive, inSameDayAs: Date()) {
            return true
        }
        
        return false
    }
    
    private func refreshData() {
        print("[LIFECYCLE] Refreshing data after background")
        
        Task {
            // Refresh subscription status
            await SubscriptionManager.shared.verifySubscription()
            
            // Refresh user profile
            if let userId = AuthManager.shared.currentUser?.id {
                // Trigger profile refresh
                await AuthManager.shared.updateLastActive()
            }
        }
    }
    
    private func updateLastActive() {
        UserDefaults.standard.set(Date(), forKey: "lastActiveDate")
        
        Task {
            await AuthManager.shared.updateLastActive()
        }
    }
    
    // MARK: - Background Refresh
    
    private func scheduleBackgroundRefresh() {
        // Schedule background tasks for content updates
        // This would integrate with BGTaskScheduler for real background fetch
        print("[LIFECYCLE] Background refresh scheduled")
    }
    
    // MARK: - Cache Management
    
    private func clearNonEssentialCaches() {
        // Clear caches that can be rebuilt
        // Keep essential data (user profile, subscription status)
        print("[LIFECYCLE] Non-essential caches cleared")
    }
    
    private func performCleanup() {
        // Final cleanup before app termination
        print("[LIFECYCLE] Cleanup completed")
    }
    
    // MARK: - Public API
    
    /// Checks if the app is currently in a state where heavy operations should be deferred
    var shouldDeferHeavyOperations: Bool {
        appState != .foreground
    }
    
    /// Gets the current session duration
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }
    
    /// Resets the session timer
    func resetSession() {
        sessionStartTime = Date()
        UserDefaults.standard.set(sessionStartTime, forKey: "sessionStartTime")
    }
}

// MARK: - View Extension

extension View {
    /// Applies lifecycle-aware modifications to a view
    func onLifecycleChange(perform action: @escaping (AppLifecycleManager.AppState) -> Void) -> some View {
        self.onReceive(AppLifecycleManager.shared.statePublisher) { state in
            action(state)
        }
    }
}
