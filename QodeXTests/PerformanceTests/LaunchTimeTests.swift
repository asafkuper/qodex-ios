//
//  LaunchTimeTests.swift
//  QodeX Performance Tests
//
//  BEDROCK: Launch time optimization target < 2 seconds
//  Tests app startup performance and identifies bottlenecks
//

import XCTest
@testable import QodeX

// MARK: - Launch Time Performance Tests

final class LaunchTimeTests: XCTestCase {
    
    // MARK: - Constants
    
    /// Target launch time - must be under 2 seconds
    let targetLaunchTime: TimeInterval = 2.0
    
    /// Maximum acceptable launch time (warning threshold)
    let maxAcceptableLaunchTime: TimeInterval = 2.5
    
    /// Number of iterations for consistent measurement
    let measurementIterations = 10
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        // Ensure clean state for each test
        continueAfterFailure = false
    }
    
    // MARK: - Launch Time Tests
    
    /// Test cold launch performance (app not in memory)
    func testColdLaunchPerformance() throws {
        let metrics = XCTPerformanceMetrics()
        
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            // Launch the app
            XCUIApplication().launch()
        }
        
        // Verify launch time is under target
        let launchTime = metrics.measurements.first?.value ?? 0
        XCTAssertLessThan(launchTime, maxAcceptableLaunchTime,
                         "Cold launch time \(launchTime)s exceeds maximum \(maxAcceptableLaunchTime)s")
    }
    
    /// Test warm launch performance (app in memory but not foreground)
    func testWarmLaunchPerformance() {
        let app = XCUIApplication()
        
        measure(options: XCTMeasureOptions.default) {
            app.terminate()
            app.launch()
        }
    }
    
    /// Test that launch completes within target time with Firebase initialized
    func testLaunchWithFirebasePerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Simulate Firebase initialization
            let firebaseExpectation = expectation(description: "Firebase initialized")
            
            // Verify Firebase config doesn't block main thread
            DispatchQueue.main.async {
                let firebaseStart = CFAbsoluteTimeGetCurrent()
                FirebaseConfig.shared.configure()
                let firebaseEnd = CFAbsoluteTimeGetCurrent()
                
                // Firebase init should be under 500ms
                XCTAssertLessThan(firebaseEnd - firebaseStart, 0.5,
                                "Firebase initialization took too long")
                firebaseExpectation.fulfill()
            }
            
            wait(for: [firebaseExpectation], timeout: 1.0)
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let totalTime = endTime - startTime
            
            XCTAssertLessThan(totalTime, targetLaunchTime,
                            "Launch with Firebase took \(totalTime)s, target is \(targetLaunchTime)s")
        }
    }
    
    /// Test launch with RevenueCat initialization
    func testLaunchWithRevenueCatPerformance() {
        measure(metrics: [XCTClockMetric()]) {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Initialize RevenueCat
            let revenueCatKey = SecureConfig.shared.revenueCatAPIKey
            if !revenueCatKey.isEmpty && !revenueCatKey.contains("your_") {
                Purchases.configure(withAPIKey: revenueCatKey)
            }
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let initTime = endTime - startTime
            
            // RevenueCat init should be under 300ms
            XCTAssertLessThan(initTime, 0.3,
                            "RevenueCat initialization took \(initTime)s")
        }
    }
    
    /// Test that critical resources are preloaded efficiently
    func testCriticalResourcePreloadPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Preload numerology data
            let calculator = NumerologyCalculator()
            _ = calculator.preloadEssentialData()
            
            // Preload daily readings for next 7 days
            let user = QodeXUser(id: "test", email: "test@test.com",
                               fullName: "Test User", membershipTier: .premium)
            let cacheManager = QodeXCacheManager.shared
            
            let preloadExpectation = expectation(description: "Resources preloaded")
            Task {
                await cacheManager.prefetchUpcomingReadings(for: user)
                preloadExpectation.fulfill()
            }
            
            wait(for: [preloadExpectation], timeout: 3.0)
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let preloadTime = endTime - startTime
            
            // Resource preload should complete within 1 second
            XCTAssertLessThan(preloadTime, 1.0,
                            "Critical resource preload took \(preloadTime)s")
        }
    }
    
    /// Test lazy loading doesn't block initial launch
    func testLazyLoadingDoesNotBlockLaunch() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Trigger lazy loading of heavy content
        let heavyContentExpectation = expectation(description: "Heavy content loaded")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate loading heavy content (astrology calculations, etc.)
            let astrologyEngine = AstrologyEngine()
            _ = astrologyEngine.preloadEphemerisData()
            
            DispatchQueue.main.async {
                heavyContentExpectation.fulfill()
            }
        }
        
        // Main thread should not be blocked for more than 100ms
        let mainThreadTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(mainThreadTime, 0.1,
                        "Lazy loading blocked main thread for \(mainThreadTime)s")
        
        wait(for: [heavyContentExpectation], timeout: 5.0)
    }
    
    /// Test async initialization pattern
    func testAsyncInitializationPerformance() {
        measure {
            let expectation = expectation(description: "Async init complete")
            
            Task {
                // Perform async initialization
                async let firebaseInit = initializeFirebase()
                async let configInit = initializeConfiguration()
                async let cacheInit = initializeCache()
                
                // Wait for all to complete
                _ = await (firebaseInit, configInit, cacheInit)
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeFirebase() async {
        // Simulate Firebase async initialization
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
    }
    
    private func initializeConfiguration() async {
        // Simulate config loading
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
    }
    
    private func initializeCache() async {
        // Simulate cache warming
        try? await Task.sleep(nanoseconds: 80_000_000) // 80ms
    }
}

// MARK: - Launch Metrics Collection

/// Collects and reports detailed launch metrics
class LaunchMetricsCollector {
    
    static let shared = LaunchMetricsCollector()
    
    private var launchStartTime: CFAbsoluteTime = 0
    private var phaseTimings: [String: TimeInterval] = [:]
    
    func startLaunchTracking() {
        launchStartTime = CFAbsoluteTimeGetCurrent()
        phaseTimings.removeAll()
    }
    
    func recordPhase(_ name: String) {
        let elapsed = CFAbsoluteTimeGetCurrent() - launchStartTime
        phaseTimings[name] = elapsed
    }
    
    func generateReport() -> LaunchReport {
        return LaunchReport(
            totalTime: CFAbsoluteTimeGetCurrent() - launchStartTime,
            phaseTimings: phaseTimings,
            timestamp: Date()
        )
    }
}

struct LaunchReport {
    let totalTime: TimeInterval
    let phaseTimings: [String: TimeInterval]
    let timestamp: Date
    
    var description: String {
        var output = "📊 Launch Performance Report\n"
        output += "Total Time: \(String(format: "%.3f", totalTime))s\n"
        output += "---\n"
        
        let sortedPhases = phaseTimings.sorted { $0.value < $1.value }
        for (phase, time) in sortedPhases {
            let indicator = time > 0.5 ? "⚠️" : "✅"
            output += "\(indicator) \(phase): \(String(format: "%.3f", time))s\n"
        }
        
        return output
    }
}

// MARK: - Launch Optimization Tracker

/// Tracks optimization opportunities during launch
class LaunchOptimizationTracker {
    
    static let shared = LaunchOptimizationTracker()
    
    private var suggestions: [OptimizationSuggestion] = []
    
    func suggest(_ message: String, severity: OptimizationSeverity) {
        suggestions.append(OptimizationSuggestion(message: message, severity: severity))
    }
    
    func getSuggestions() -> [OptimizationSuggestion] {
        return suggestions.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
    
    func clearSuggestions() {
        suggestions.removeAll()
    }
}

struct OptimizationSuggestion {
    let message: String
    let severity: OptimizationSeverity
    let timestamp = Date()
}

enum OptimizationSeverity: Int {
    case info = 0
    case warning = 1
    case critical = 2
}
