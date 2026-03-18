//
//  CrashReporter.swift
//  Comprehensive crash reporting and recovery
//

import Foundation
import MetricKit
import FirebaseCrashlytics

class CrashReporter: NSObject, MXMetricManagerSubscriber {
    static let shared = CrashReporter()
    
    private let crashlytics = Crashlytics.crashlytics()
    private var breadcrumbs: [Breadcrumb] = []
    private let maxBreadcrumbs = 100
    
    // MARK: - Breadcrumb Tracking
    struct Breadcrumb {
        let message: String
        let timestamp: Date
        let category: String
        let metadata: [String: Any]?
    }
    
    func logBreadcrumb(_ message: String, category: String = "general", metadata: [String: Any]? = nil) {
        let breadcrumb = Breadcrumb(
            message: message,
            timestamp: Date(),
            category: category,
            metadata: metadata
        )
        
        breadcrumbs.append(breadcrumb)
        
        // Keep only last N breadcrumbs
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst(breadcrumbs.count - maxBreadcrumbs)
        }
        
        // Also log to Crashlytics
        crashlytics.log("[\(category)] \(message)")
    }
    
    func setUserIdentifier(_ userId: String) {
        crashlytics.setUserID(userId)
    }
    
    func setCustomValue(_ value: Any, forKey key: String) {
        crashlytics.setCustomValue(value, forKey: key)
    }
    
    // MARK: - Error Reporting
    func reportError(_ error: Error, context: String? = nil) {
        var userInfo: [String: Any] = [:]
        
        if let context = context {
            userInfo["context"] = context
        }
        
        // Add recent breadcrumbs
        let recentBreadcrumbs = breadcrumbs.suffix(20).map { breadcrumb in
            return "\(breadcrumb.timestamp): [\(breadcrumb.category)] \(breadcrumb.message)"
        }.joined(separator: "\n")
        
        userInfo["breadcrumbs"] = recentBreadcrumbs
        
        let nsError = error as NSError
        crashlytics.record(error: nsError)
        
        logBreadcrumb("Error reported: \(error.localizedDescription)", category: "error")
    }
    
    func reportNonFatalException(name: String, reason: String? = nil, stackTrace: [String]? = nil) {
        // Create custom exception model
        let exceptionModel = ExceptionModel(name: name, reason: reason ?? "")
        crashlytics.record(exceptionModel: exceptionModel)
    }
    
    // MARK: - Recovery
    func handleCrashRecovery() {
        // Check if previous session crashed
        if UserDefaults.standard.bool(forKey: "last_session_crashed") {
            logBreadcrumb("App recovering from crash", category: "recovery")
            
            // Clear sensitive data that might be in bad state
            clearPotentiallyCorruptedData()
            
            // Reset flag
            UserDefaults.standard.set(false, forKey: "last_session_crashed")
        }
        
        // Set up crash detection for this session
        UserDefaults.standard.set(true, forKey: "session_active")
    }
    
    func markSessionClean() {
        UserDefaults.standard.set(false, forKey: "session_active")
        UserDefaults.standard.set(false, forKey: "last_session_crashed")
    }
    
    private func clearPotentiallyCorruptedData() {
        // Clear any cached data that might be corrupted
        UserDefaults.standard.removeObject(forKey: "cached_daily_reading")
        UserDefaults.standard.removeObject(forKey: "last_calculation_result")
    }
    
    // MARK: - MetricKit Integration
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            // Handle crash diagnostics
            if let crashes = payload.crashDiagnostics {
                for crash in crashes {
                    reportMetricKitCrash(crash)
                }
            }
            
            // Handle CPU exception diagnostics
            if let cpuExceptions = payload.cpuExceptionDiagnostics {
                for exception in cpuExceptions {
                    reportCPUException(exception)
                }
            }
            
            // Handle disk write exception diagnostics
            if let diskWriteExceptions = payload.diskWriteExceptionDiagnostics {
                for exception in diskWriteExceptions {
                    reportDiskWriteException(exception)
                }
            }
        }
    }
    
    private func reportMetricKitCrash(_ crash: MXCrashDiagnostic) {
        let callStack = crash.callStackTree
        let exceptionType = crash.exceptionType ?? "Unknown"
        let signal = crash.signal ?? "Unknown"
        
        logBreadcrumb("Crash detected: \(exceptionType) - \(signal)", category: "crash")
        
        // Report to Crashlytics
        crashlytics.log("MetricKit crash: \(exceptionType)")
        crashlytics.log("Call stack: \(callStack)")
    }
    
    private func reportCPUException(_ exception: MXCPUExceptionDiagnostic) {
        let totalCPUTime = exception.totalCPUTime
        let totalSampledTime = exception.totalSampledTime
        
        logBreadcrumb("CPU exception: \(totalCPUTime)ms over \(totalSampledTime)s", category: "performance")
        
        // Set custom keys for tracking
        crashlytics.setCustomValue(totalCPUTime, forKey: "cpu_exception_time")
    }
    
    private func reportDiskWriteException(_ exception: MXDiskWriteExceptionDiagnostic) {
        let totalWrites = exception.totalWritesCaused
        logBreadcrumb("Disk write exception: \(totalWrites) bytes", category: "performance")
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        // Process performance metrics
        for payload in payloads {
            if let appLaunchMetrics = payload.applicationLaunchMetrics {
                let launchTime = appLaunchMetrics.histogrammedTimeToFirstDraw.averageMeasurement()
                crashlytics.setCustomValue(launchTime.doubleValue, forKey: "avg_launch_time")
            }
            
            if let cellularMetrics = payload.cellularConditionMetrics {
                // Track network conditions
            }
            
            if let cpuMetrics = payload.cpuMetrics {
                let cpuUsage = cpuMetrics.cumulativeCPUUsage
                crashlytics.setCustomValue(cpuUsage, forKey: "cpu_usage")
            }
        }
    }
    
    // MARK: - ANR Detection
    func checkForANR(mainThreadBlocked: Bool, duration: TimeInterval) {
        if mainThreadBlocked && duration > 5.0 {
            logBreadcrumb("Possible ANR detected: main thread blocked for \(duration)s", category: "anr")
            
            // Report non-fatal
            reportNonFatalException(
                name: "AppNotResponding",
                reason: "Main thread blocked for \(duration) seconds",
                stackTrace: Thread.callStackSymbols
            )
        }
    }
    
    // MARK: - Debug Helpers
    #if DEBUG
    func simulateCrash() {
        // Only available in DEBUG builds for testing Crashlytics integration
        // This is intentionally fatal for testing purposes
        fatalError("Simulated crash for testing - DEBUG only")
    }
    #else
    func simulateCrash() {
        // NO-OP in production - use log instead
        QodeXLogger.shared.warning("simulateCrash() called in production - ignoring", category: .analytics)
    }
    #endif
    
    func simulateNonFatalError() {
        let error = NSError(domain: "com.qodex.test", code: 999, userInfo: [
            NSLocalizedDescriptionKey: "Test non-fatal error"
        ])
        reportError(error, context: "Test")
    }
    #endif
}

// MARK: - Global Error Handler
func setupGlobalErrorHandling() {
    NSSetUncaughtExceptionHandler { exception in
        CrashReporter.shared.logBreadcrumb(
            "Uncaught exception: \(exception.name.rawValue) - \(exception.reason ?? "Unknown")",
            category: "crash"
        )
        
        // Save breadcrumbs for next launch
        UserDefaults.standard.set(true, forKey: "last_session_crashed")
        
        // Original exception handling continues...
    }
}
