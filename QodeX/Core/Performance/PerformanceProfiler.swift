//
//  PerformanceProfiler.swift
//  Runtime performance monitoring and optimization
//

import Foundation
import os.log

class PerformanceProfiler {
    static let shared = PerformanceProfiler()
    private let logger = Logger(subsystem: "com.qodex.app", category: "Performance")
    
    private var activeTimers: [String: Date] = [:]
    private var metrics: [String: [TimeInterval]] = [:]
    
    // MARK: - Timing
    func startTimer(_ name: String) {
        activeTimers[name] = Date()
    }
    
    func endTimer(_ name: String, log: Bool = true) -> TimeInterval? {
        guard let start = activeTimers[name] else { return nil }
        activeTimers.removeValue(forKey: name)
        
        let duration = Date().timeIntervalSince(start)
        
        // Store metric
        if metrics[name] == nil {
            metrics[name] = []
        }
        metrics[name]?.append(duration)
        
        // Log if slow
        if log && duration > 1.0 {
            logger.warning("\(name) took \(String(format: "%.3f", duration))s - consider optimization")
        }
        
        return duration
    }
    
    // MARK: - Memory Profiling
    func logMemoryUsage(context: String) {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            logger.error("Failed to get memory info")
            return
        }
        
        let usedMB = Double(info.resident_size) / 1024 / 1024
        let totalMB = Double(info.virtual_size) / 1024 / 1024
        
        logger.info("[\(context)] Memory: \(String(format: "%.1f", usedMB))MB used, \(String(format: "%.1f", totalMB))MB virtual")
        
        // Warn if high
        if usedMB > 200 {
            logger.warning("High memory usage detected: \(String(format: "%.1f", usedMB))MB")
        }
    }
    
    // MARK: - FPS Monitoring
    class FPSMonitor {
        private var displayLink: CADisplayLink?
        private var frameCount = 0
        private var lastTime: TimeInterval = 0
        var onFPSUpdate: ((Double) -> Void)?
        
        func start() {
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink?.add(to: .main, forMode: .common)
            lastTime = CACurrentMediaTime()
        }
        
        func stop() {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        @objc private func update() {
            frameCount += 1
            let currentTime = CACurrentMediaTime()
            let delta = currentTime - lastTime
            
            if delta >= 1.0 {
                let fps = Double(frameCount) / delta
                onFPSUpdate?(fps)
                frameCount = 0
                lastTime = currentTime
            }
        }
    }
    
    // MARK: - Report Generation
    func generateReport() -> PerformanceReport {
        var report = PerformanceReport()
        
        for (name, times) in metrics {
            let avg = times.reduce(0, +) / Double(times.count)
            let min = times.min() ?? 0
            let max = times.max() ?? 0
            
            report.metrics[name] = MetricStats(
                average: avg,
                min: min,
                max: max,
                count: times.count
            )
        }
        
        return report
    }
    
    func printReport() {
        let report = generateReport()
        
        print("\n📊 PERFORMANCE REPORT")
        print("=====================")
        
        for (name, stats) in report.metrics.sorted(by: { $0.value.average > $1.value.average }) {
            print("\(name):")
            print("  Average: \(String(format: "%.3f", stats.average))s")
            print("  Range: \(String(format: "%.3f", stats.min))s - \(String(format: "%.3f", stats.max))s")
            print("  Samples: \(stats.count)")
        }
    }
    
    // MARK: - Optimization Suggestions
    func getOptimizationSuggestions() -> [String] {
        var suggestions: [String] = []
        
        for (name, stats) in generateReport().metrics {
            if stats.average > 1.0 {
                suggestions.append("\(name): Consider async processing (avg: \(String(format: "%.2f", stats.average))s)")
            }
            if stats.max > stats.average * 3 {
                suggestions.append("\(name): High variance detected - check for inconsistent performance")
            }
        }
        
        return suggestions
    }
}

// MARK: - Supporting Types
struct PerformanceReport {
    var metrics: [String: MetricStats] = [:]
}

struct MetricStats {
    let average: TimeInterval
    let min: TimeInterval
    let max: TimeInterval
    let count: Int
}

// MARK: - SwiftUI Integration
struct PerformanceModifier: ViewModifier {
    let name: String
    @State private var startTime: Date?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                startTime = Date()
            }
            .onDisappear {
                if let start = startTime {
                    let duration = Date().timeIntervalSince(start)
                    if duration > 0.1 {
                        PerformanceProfiler.shared.logger.debug("\(name) visible for \(String(format: "%.3f", duration))s")
                    }
                }
            }
    }
}

extension View {
    func trackPerformance(_ name: String) -> some View {
        modifier(PerformanceModifier(name: name))
    }
}
