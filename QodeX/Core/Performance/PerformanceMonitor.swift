//
//  PerformanceMonitor.swift
//  Performance monitoring and optimization for QodeX
//

import Foundation
import SwiftUI
import os.log

// MARK: - Performance Metrics
struct PerformanceMetrics {
    let timestamp: Date
    let memoryUsedMB: Double
    let cpuUsagePercent: Double
    let batteryLevel: Double
    let thermalState: ProcessInfo.ThermalState
    let launchTime: TimeInterval?
    let frameDrops: Int
    let networkLatency: TimeInterval?
}

// MARK: - Performance Monitor
final class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var currentMetrics: PerformanceMetrics?
    @Published var isHighMemoryUsage = false
    @Published var isThermalThrottling = false
    
    private var timer: Timer?
    private let logger = QodeXLogger.shared
    private var frameDropCount = 0
    private var lastFrameTime: CFTimeInterval = 0
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        // Monitor every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.collectMetrics()
        }
        
        // Monitor thermal state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateChanged),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
        
        // Monitor memory pressure
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(memoryPressureChanged),
            name: NSNotification.Name("NSProcessInfoMemoryPressureNotification"),
            object: nil
        )
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Metric Collection
    
    private func collectMetrics() {
        let metrics = PerformanceMetrics(
            timestamp: Date(),
            memoryUsedMB: getMemoryUsage(),
            cpuUsagePercent: getCPUUsage(),
            batteryLevel: getBatteryLevel(),
            thermalState: ProcessInfo.processInfo.thermalState,
            launchTime: nil,
            frameDrops: frameDropCount,
            networkLatency: nil
        )
        
        DispatchQueue.main.async {
            self.currentMetrics = metrics
            self.checkThresholds(metrics)
        }
        
        // Log metrics in debug mode
        #if DEBUG
        logger.debug("Memory: \(String(format: "%.1f", metrics.memoryUsedMB))MB | CPU: \(String(format: "%.1f", metrics.cpuUsageUsagePercent))% | Thermal: \(metrics.thermalState.description)", category: .performance)
        #endif
    }
    
    // MARK: - Threshold Checking
    
    private func checkThresholds(_ metrics: PerformanceMetrics) {
        // Check memory
        if metrics.memoryUsedMB > 500 { // 500MB threshold
            if !isHighMemoryUsage {
                isHighMemoryUsage = true
                logger.warning("High memory usage detected: \(String(format: "%.1f", metrics.memoryUsedMB))MB", category: .performance)
                handleHighMemory()
            }
        } else {
            isHighMemoryUsage = false
        }
        
        // Check thermal state
        switch metrics.thermalState {
        case .serious, .critical:
            if !isThermalThrottling {
                isThermalThrottling = true
                logger.warning("Thermal throttling active: \(metrics.thermalState.description)", category: .performance)
                handleThermalThrottling()
            }
        default:
            isThermalThrottling = false
        }
    }
    
    // MARK: - Memory Management
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / 1024 / 1024
    }
    
    private func handleHighMemory() {
        // Clear non-essential caches
        URLCache.shared.removeAllCachedResponses()
        
        // Post notification for views to release heavy resources
        NotificationCenter.default.post(name: .qodexMemoryWarning, object: nil)
    }
    
    // MARK: - CPU Monitoring
    
    private func getCPUUsage() -> Double {
        var info = task_thread_times_info()
        var count = mach_msg_type_number_t(THREAD_TIMES_INFO_COUNT)
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(THREAD_TIMES_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return 0 }
        
        // Calculate CPU percentage (simplified)
        let totalTime = info.user_time.seconds + info.system_time.seconds
        return Double(totalTime) / 100.0 // Approximate
    }
    
    // MARK: - Battery Monitoring
    
    private func getBatteryLevel() -> Double {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Double(UIDevice.current.batteryLevel * 100)
    }
    
    // MARK: - Frame Drop Monitoring
    
    func trackFrame() {
        let currentTime = CACurrentMediaTime()
        let delta = currentTime - lastFrameTime
        
        // If frame took longer than 16.67ms (60fps), count as dropped
        if delta > 0.01667 {
            frameDropCount += 1
        }
        
        lastFrameTime = currentTime
    }
    
    // MARK: - Thermal Handling
    
    @objc private func thermalStateChanged() {
        let state = ProcessInfo.processInfo.thermalState
        logger.info("Thermal state changed to: \(state.description)", category: .performance)
        
        if state == .serious || state == .critical {
            handleThermalThrottling()
        }
    }
    
    private func handleThermalThrottling() {
        // Reduce animations
        withAnimation(.none) {
            // Notify views to reduce visual effects
            NotificationCenter.default.post(name: .qodexReduceVisualEffects, object: nil)
        }
    }
    
    @objc private func memoryPressureChanged() {
        logger.warning("Memory pressure notification received", category: .performance)
        handleHighMemory()
    }
    
    // MARK: - Performance Optimization
    
    func optimizeForLowPowerMode() {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled else { return }
        
        logger.info("Low power mode enabled - optimizing performance", category: .performance)
        
        // Disable non-essential features
        UserDefaults.standard.set(false, forKey: "enable_parallax")
        UserDefaults.standard.set(false, forKey: "enable_particles")
        UserDefaults.standard.set(false, forKey: "enable_live_backgrounds")
    }
}

// MARK: - Thermal State Extension
extension ProcessInfo.ThermalState {
    var description: String {
        switch self {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let qodexMemoryWarning = Notification.Name("qodex_memory_warning")
    static let qodexReduceVisualEffects = Notification.Name("qodex_reduce_visual_effects")
}

// MARK: - View Extension for Performance
extension View {
    func trackPerformance(_ name: String) -> some View {
        let startTime = CACurrentMediaTime()
        
        return self.onAppear {
            let duration = CACurrentMediaTime() - startTime
            PerformanceMonitor.shared.logPerformance(operation: name, duration: duration)
        }
    }
    
    func optimizeForThermalState() -> some View {
        self.modifier(ThermalOptimizationModifier())
    }
}

// MARK: - Thermal Optimization Modifier
struct ThermalOptimizationModifier: ViewModifier {
    @ObservedObject private var monitor = PerformanceMonitor.shared
    
    func body(content: Content) -> some View {
        content
            .animation(monitor.isThermalThrottling ? .none : .default, value: monitor.isThermalThrottling)
            .environment(\.reduceMotion, monitor.isThermalThrottling)
    }
}

// MARK: - Environment Key
private struct ReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var reduceMotion: Bool {
        get { self[ReduceMotionKey.self] }
        set { self[ReduceMotionKey.self] = newValue }
    }
}

// Import for task_info
import MachO
import Darwin
