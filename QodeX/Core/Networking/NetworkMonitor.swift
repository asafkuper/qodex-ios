//
//  NetworkMonitor.swift
//  Comprehensive network monitoring and offline support
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive: Bool = false
    @Published var isConstrained: Bool = false
    
    private let monitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path: path)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionStatus(path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained
        
        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        
        // Log for analytics
        if !isConnected {
            CrashReporter.shared.logBreadcrumb("Network disconnected", category: "network")
        }
    }
    
    // MARK: - Network Adaptations
    func shouldSyncLargeData() -> Bool {
        return isConnected && !isExpensive
    }
    
    func shouldAutoPlayVideo() -> Bool {
        return isConnected && connectionType == .wifi
    }
    
    func shouldPrefetchContent() -> Bool {
        return isConnected && !isExpensive && !isConstrained
    }
}

// MARK: - Offline Queue
class OfflineQueue {
    static let shared = OfflineQueue()
    
    private var pendingOperations: [OfflineOperation] = []
    private let queueKey = "offline_queue"
    
    struct OfflineOperation: Codable {
        let id: String
        let type: OperationType
        let data: Data
        let timestamp: Date
        let retryCount: Int
        
        enum OperationType: String, Codable {
            case calculation
            case journalEntry
            case communityPost
            case analyticsEvent
        }
    }
    
    func enqueue(operation: OfflineOperation) {
        pendingOperations.append(operation)
        saveQueue()
        
        CrashReporter.shared.logBreadcrumb(
            "Queued offline operation: \(operation.type)",
            category: "offline"
        )
    }
    
    func processQueue() {
        guard NetworkMonitor.shared.isConnected else { return }
        
        let operations = pendingOperations
        pendingOperations.removeAll()
        
        for operation in operations {
            processOperation(operation)
        }
        
        saveQueue()
    }
    
    private func processOperation(_ operation: OfflineOperation) {
        // Process based on type
        switch operation.type {
        case .calculation:
            // Retry calculation
            break
        case .journalEntry:
            // Save journal entry
            break
        case .communityPost:
            // Post to community
            break
        case .analyticsEvent:
            // Log analytics
            break
        }
    }
    
    private func saveQueue() {
        if let data = try? JSONEncoder().encode(pendingOperations) {
            UserDefaults.standard.set(data, forKey: queueKey)
        }
    }
    
    private func loadQueue() {
        guard let data = UserDefaults.standard.data(forKey: queueKey),
              let operations = try? JSONDecoder().decode([OfflineOperation].self, from: data) else {
            return
        }
        pendingOperations = operations
    }
}

// MARK: - Retry Policy
struct RetryPolicy {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    
    func delay(forAttempt attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        return min(exponentialDelay, maxDelay)
    }
    
    static let standard = RetryPolicy(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 60.0
    )
    
    static let aggressive = RetryPolicy(
        maxRetries: 5,
        baseDelay: 0.5,
        maxDelay: 30.0
    )
}
