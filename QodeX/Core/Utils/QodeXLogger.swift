//
//  QodeXLogger.swift
//  Unified logging system for QodeX
//  Replaces print() statements with proper logging
//

import Foundation
import os.log

// MARK: - Log Levels
enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

// MARK: - Logger Categories
enum LogCategory: String {
    case app = "App"
    case auth = "Auth"
    case network = "Network"
    case database = "Database"
    case ui = "UI"
    case analytics = "Analytics"
    case performance = "Performance"
    case security = "Security"
    case lifecycle = "Lifecycle"
    case numerology = "Numerology"
    
    var osLog: OSLog {
        return OSLog(subsystem: "academy.qodex.app", category: self.rawValue)
    }
}

// MARK: - QodeX Logger
final class QodeXLogger {
    static let shared = QodeXLogger()
    
    private let isDebugMode: Bool
    private let queue = DispatchQueue(label: "com.qodex.logger", qos: .utility)
    
    private init() {
        #if DEBUG
        self.isDebugMode = true
        #else
        self.isDebugMode = false
        #endif
    }
    
    // MARK: - Logging Methods
    
    func log(
        _ message: String,
        level: LogLevel = .info,
        category: LogCategory = .app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(category.rawValue)] \(fileName):\(line) - \(function): \(message)"
        
        // Log to OSLog
        os_log(
            "%{public}@",
            log: category.osLog,
            type: level.osLogType,
            logMessage
        )
        
        // In debug mode, also print to console
        if isDebugMode {
            print(logMessage)
        }
        
        // Store critical errors for crash reporting
        if level == .critical || level == .error {
            queue.async {
                self.storeError(message: message, level: level, category: category)
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    func debug(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Performance Logging
    
    func logPerformance(
        operation: String,
        duration: TimeInterval,
        category: LogCategory = .performance
    ) {
        let message = "\(operation) completed in \(String(format: "%.3f", duration))s"
        log(message, level: .debug, category: category)
    }
    
    func logMemoryUsage() {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            error("Failed to get memory usage", category: .performance)
            return
        }
        
        let usedMB = Double(info.resident_size) / 1024 / 1024
        let totalMB = Double(info.virtual_size) / 1024 / 1024
        
        log("Memory: \(String(format: "%.1f", usedMB))MB used / \(String(format: "%.1f", totalMB))MB virtual", 
            level: .debug, 
            category: .performance)
    }
    
    // MARK: - Private Methods
    
    private func storeError(message: String, level: LogLevel, category: LogCategory) {
        // Store last 100 errors in UserDefaults for crash reporting
        let errorEntry: [String: Any] = [
            "message": message,
            "level": level.rawValue,
            "category": category.rawValue,
            "timestamp": Date().iso8601
        ]
        
        var errors = UserDefaults.standard.array(forKey: "qodex_recent_errors") as? [[String: Any]] ?? []
        errors.append(errorEntry)
        
        // Keep only last 100
        if errors.count > 100 {
            errors.removeFirst(errors.count - 100)
        }
        
        UserDefaults.standard.set(errors, forKey: "qodex_recent_errors")
    }
}

// MARK: - View Logger Extension
extension View {
    func logLifecycle(_ message: String, level: LogLevel = .debug) -> some View {
        QodeXLogger.shared.log(message, level: level, category: .lifecycle)
        return self
    }
}

// MARK: - Date Extension
extension Date {
    var iso8601: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

// Import for task_info
import MachO

// MARK: - Migration Helper
// Use this to gradually migrate from print() to QodeXLogger
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let message = items.map { String(describing: $0) }.joined(separator: separator)
    Swift.print(message, terminator: terminator)
    
    // Also log to our system in debug mode
    QodeXLogger.shared.debug("Legacy print: \(message)")
    #endif
}
