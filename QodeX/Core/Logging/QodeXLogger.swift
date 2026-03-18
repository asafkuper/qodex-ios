import Foundation
import OSLog

// MARK: - Log Categories

/// Log categories for organized logging throughout the app
public enum LogCategory: String, CaseIterable {
    case numerology = "Numerology"
    case networking = "Networking"
    case ui = "UI"
    case lifecycle = "Lifecycle"
    case analytics = "Analytics"
    case authentication = "Auth"
    case database = "Database"
    case performance = "Performance"
    case subscription = "Subscription"
    case general = "General"
}

// MARK: - QodeX Logger

/// Centralized logging system using OSLog with categorized logging support
/// 
/// Usage:
/// ```swift
/// QodeXLogger.numerology.info("Calculating Life Path for user")
/// QodeXLogger.networking.error("Request failed: \(error)")
/// QodeXLogger.performance.measure("Calculation time") { ... }
/// ```
public struct QodeXLogger {
    
    // MARK: - Shared Loggers
    
    public static let numerology = QodeXLogger(category: .numerology)
    public static let networking = QodeXLogger(category: .networking)
    public static let ui = QodeXLogger(category: .ui)
    public static let lifecycle = QodeXLogger(category: .lifecycle)
    public static let analytics = QodeXLogger(category: .analytics)
    public static let authentication = QodeXLogger(category: .authentication)
    public static let database = QodeXLogger(category: .database)
    public static let performance = QodeXLogger(category: .performance)
    public static let subscription = QodeXLogger(category: .subscription)
    public static let general = QodeXLogger(category: .general)
    
    // MARK: - Properties
    
    private let logger: Logger
    private let category: LogCategory
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.qodex.app"
    
    // MARK: - Initialization
    
    public init(category: LogCategory) {
        self.category = category
        self.logger = Logger(subsystem: Self.subsystem, category: category.rawValue)
    }
    
    // MARK: - Logging Levels
    
    /// Log a debug message - use for detailed diagnostic information
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.debug("[\(source):\(line)] \(function) → \(message)")
    }
    
    /// Log an info message - use for general information
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.info("[\(source):\(line)] \(message)")
    }
    
    /// Log a notice - use for important but non-error events
    public func notice(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.notice("[\(source):\(line)] \(message)")
    }
    
    /// Log a warning - use for potential issues
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.warning("⚠️ [\(source):\(line)] \(message)")
    }
    
    /// Log an error - use for actual errors
    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.error("❌ [\(source):\(line)] \(function) → \(message)")
    }
    
    /// Log a critical error - use for severe issues requiring immediate attention
    public func critical(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.critical("🚨 [\(source):\(line)] \(function) → \(message)")
    }
    
    // MARK: - Error Logging with QodeXError
    
    /// Log a QodeXError with full context
    public func logError(
        _ error: QodeXError,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        let errorMessage = """
        ❌ ERROR [\(source):\(line)]
        Function: \(function)
        Type: \(String(describing: error))
        Description: \(error.localizedDescription)
        Failure Reason: \(error.failureReason ?? "N/A")
        Recovery: \(error.recoverySuggestion ?? "N/A")
        """
        logger.error("\(errorMessage)")
    }
    
    // MARK: - Performance Logging
    
    /// Measure execution time of a block and log it
    @discardableResult
    public func measure<T>(
        _ operationName: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        threshold: TimeInterval = 1.0,
        operation: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let source = Self.sourceFile(file)
        
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            let icon = timeElapsed > threshold ? "⚠️" : "✓"
            logger.info("\(icon) [\(source):\(line)] \(operationName): \(String(format: "%.4f", timeElapsed))s")
        }
        
        return try operation()
    }
    
    /// Measure execution time of an async block and log it
    @discardableResult
    public func measureAsync<T>(
        _ operationName: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        threshold: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let source = Self.sourceFile(file)
        
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            let icon = timeElapsed > threshold ? "⚠️" : "✓"
            logger.info("\(icon) [\(source):\(line)] \(operationName): \(String(format: "%.4f", timeElapsed))s")
        }
        
        return try await operation()
    }
    
    // MARK: - Event Logging
    
    /// Log a user action or event
    public func event(
        _ eventName: String,
        parameters: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        var message = "📊 [\(source):\(line)] Event: \(eventName)"
        
        if let params = parameters, !params.isEmpty {
            let paramString = params.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            message += " | Parameters: [\(paramString)]"
        }
        
        logger.info("\(message)")
    }
    
    /// Log state changes
    public func stateChange(
        from: String,
        to: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = Self.sourceFile(file)
        logger.info("🔄 [\(source):\(line)] State: \(from) → \(to)")
    }
    
    // MARK: - Private Helpers
    
    private static func sourceFile(_ file: String) -> String {
        (file as NSString).lastPathComponent
    }
}

// MARK: - Convenience Extensions

public extension QodeXLogger {
    /// Log numerology calculation details
    static func logCalculation(
        type: String,
        input: String,
        result: Int,
        isMasterNumber: Bool,
        steps: [String] = []
    ) {
        let masterIndicator = isMasterNumber ? " ⭐ MASTER NUMBER" : ""
        var message = "🧮 \(type): \(input) =\u003e \(result)\(masterIndicator)"
        
        if !steps.isEmpty {
            message += "\nSteps: \(steps.joined(separator: " → "))"
        }
        
        numerology.info(message)
    }
    
    /// Log API request details
    static func logRequest(
        method: String,
        endpoint: String,
        statusCode: Int? = nil,
        error: Error? = nil
    ) {
        if let error = error {
            networking.error("\(method) \(endpoint) FAILED: \(error.localizedDescription)")
        } else if let status = statusCode {
            let icon = (200...299).contains(status) ? "✓" : "⚠️"
            networking.info("\(icon) \(method) \(endpoint) - Status: \(status)")
        } else {
            networking.debug("→ \(method) \(endpoint)")
        }
    }
    
    /// Log UI navigation
    static func logNavigation(
        from: String,
        to: String,
        trigger: String = "user"
    ) {
        ui.info("🔄 Navigation: \(from) → \(to) (trigger: \(trigger))")
    }
    
    /// Log view lifecycle events
    static func logLifecycle(
        view: String,
        event: LifecycleEvent
    ) {
        let icon = event.icon
        lifecycle.info("\(icon) \(view) \(event.rawValue)")
    }
    
    /// Log startup performance
    static func logStartupTime(_ time: TimeInterval) {
        let icon = time < 2.0 ? "✓" : "⚠️"
        performance.info("\(icon) Cold start time: \(String(format: "%.3f", time))s")
    }
}

// MARK: - Lifecycle Event

public enum LifecycleEvent: String {
    case appear = "appeared"
    case disappear = "disappeared"
    case load = "loaded"
    case unload = "unloaded"
    case initialize = "initialized"
    case deinitialize = "deinitialized"
    
    var icon: String {
        switch self {
        case .appear: return "👁"
        case .disappear: return "🙈"
        case .load: return "📦"
        case .unload: return "🗑"
        case .initialize: return "🚀"
        case .deinitialize: return "💀"
        }
    }
}

// MARK: - View Extension for Lifecycle Logging

import SwiftUI

public extension View {
    /// Automatically log view lifecycle events
    func logLifecycle(_ viewName: String, enabled: Bool = true) -> some View {
        guard enabled else { return self }
        
        return self
            .onAppear {
                QodeXLogger.logLifecycle(view: viewName, event: .appear)
            }
            .onDisappear {
                QodeXLogger.logLifecycle(view: viewName, event: .disappear)
            }
    }
}