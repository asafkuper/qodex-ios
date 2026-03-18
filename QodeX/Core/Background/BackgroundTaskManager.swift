//
//  BackgroundTaskManager.swift
//  Background fetch, refresh, and processing
//

import Foundation
import BackgroundTasks

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let taskIdentifiers = [
        "com.qodex.dailyRefresh",
        "com.qodex.dataSync",
        "com.qodex.analyticsUpload",
        "com.qodex.contentPrefetch"
    ]
    
    // MARK: - Register Tasks
    func registerTasks() {
        for identifier in taskIdentifiers {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: identifier,
                using: nil
            ) { [weak self] task in
                self?.handleBackgroundTask(task)
            }
        }
    }
    
    // MARK: - Schedule Tasks
    func scheduleDailyRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.qodex.dailyRefresh")
        request.earliestBeginDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Scheduled daily refresh")
        } catch {
            print("❌ Failed to schedule: \(error)")
        }
    }
    
    func scheduleDataSync() {
        let request = BGProcessingTaskRequest(identifier: "com.qodex.dataSync")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Failed to schedule sync: \(error)")
        }
    }
    
    func scheduleContentPrefetch() {
        let request = BGProcessingTaskRequest(identifier: "com.qodex.contentPrefetch")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true // Only on charger to save battery
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Failed to schedule prefetch: \(error)")
        }
    }
    
    // MARK: - Handle Tasks
    private func handleBackgroundTask(_ task: BGTask) {
        switch task.identifier {
        case "com.qodex.dailyRefresh":
            handleDailyRefresh(task: task as! BGAppRefreshTask)
        case "com.qodex.dataSync":
            handleDataSync(task: task as! BGProcessingTask)
        case "com.qodex.analyticsUpload":
            handleAnalyticsUpload(task: task as! BGProcessingTask)
        case "com.qodex.contentPrefetch":
            handleContentPrefetch(task: task as! BGProcessingTask)
        default:
            task.setTaskCompleted(success: false)
        }
    }
    
    private func handleDailyRefresh(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        // Calculate today's number
        let calculateOperation = BlockOperation {
            let calculator = NumerologyCalculator()
            let dailyNumber = calculator.calculateDailyNumber(for: Date())
            
            // Cache the result
            UserDefaults.standard.set(dailyNumber, forKey: "cachedDailyNumber")
            UserDefaults.standard.set(Date(), forKey: "lastDailyRefresh")
            
            // Schedule notification
            Task {
                await self.scheduleDailyNotification(number: dailyNumber)
            }
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        calculateOperation.completionBlock = {
            task.setTaskCompleted(success: !calculateOperation.isCancelled)
        }
        
        queue.addOperation(calculateOperation)
        
        // Schedule next refresh
        scheduleDailyRefresh()
    }
    
    private func handleDataSync(task: BGProcessingTask) {
        Task {
            do {
                // Sync any pending data
                try await syncPendingCalculations()
                try await syncUserActivity()
                try await uploadOfflineAnalytics()
                
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Data sync failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    private func handleAnalyticsUpload(task: BGProcessingTask) {
        Task {
            do {
                try await AnalyticsBackupManager.shared.uploadPendingEvents()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    private func handleContentPrefetch(task: BGProcessingTask) {
        Task {
            guard let user = AuthManager.shared.currentUser else {
                task.setTaskCompleted(success: false)
                return
            }
            
            // Pre-fetch upcoming content
            await QodeXCacheManager.shared.prefetchUpcomingReadings(for: user)
            
            // Download teachings for offline
            await prefetchTeachings(for: user)
            
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: - Helper Methods
    private func scheduleDailyNotification(number: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Today's Number: \(number)"
        content.body = getVibeDescription(for: number)
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "daily-\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func getVibeDescription(for number: Int) -> String {
        let vibes = ["", "New Beginnings", "Partnership", "Creativity", "Foundation", "Freedom", "Harmony", "Wisdom", "Abundance", "Completion"]
        return vibes[number] ?? "Spiritual Growth"
    }
    
    private func syncPendingCalculations() async throws {
        // Sync any calculations done offline
    }
    
    private func syncUserActivity() async throws {
        // Sync activity logs
    }
    
    private func uploadOfflineAnalytics() async throws {
        // Upload cached analytics
    }
    
    private func prefetchTeachings(for user: QodeXUser) async {
        // Download teachings based on user's life path
    }
}

// MARK: - Analytics Backup Manager
class AnalyticsBackupManager {
    static let shared = AnalyticsBackupManager()
    
    private var pendingEvents: [AnalyticsEvent] = []
    
    func queueEvent(_ event: AnalyticsEvent) {
        pendingEvents.append(event)
        
        // Persist to disk
        savePendingEvents()
    }
    
    func uploadPendingEvents() async throws {
        guard !pendingEvents.isEmpty else { return }
        
        // Upload to Firebase
        // Clear pending events on success
        pendingEvents.removeAll()
        savePendingEvents()
    }
    
    private func savePendingEvents() {
        // Save to UserDefaults or file
    }
}

struct AnalyticsEvent: Codable {
    let name: String
    let parameters: [String: String]
    let timestamp: Date
}
