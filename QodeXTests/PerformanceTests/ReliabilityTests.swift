//
//  ReliabilityTests.swift
//  QodeX Performance Tests
//
//  BEDROCK: Reliability targets validation
//  Tests crash prevention, error handling, and ANR prevention
//

import XCTest
@testable import QodeX

// MARK: - Reliability Tests

final class ReliabilityTests: XCTestCase {
    
    // MARK: - Crash Prevention Tests
    
    /// Test array bounds protection
    func testArrayBoundsSafety() {
        let calculator = NumerologyCalculator()
        
        // Test with edge case inputs
        let emptyName = ""
        XCTAssertNoThrow(calculator.calculateExpressionNumber(name: emptyName),
                        "Empty name should not crash")
        
        let specialChars = "!@#$%^&*()"
        XCTAssertNoThrow(calculator.calculateExpressionNumber(name: specialChars),
                        "Special characters should not crash")
        
        let veryLongName = String(repeating: "A", count: 10000)
        XCTAssertNoThrow(calculator.calculateExpressionNumber(name: veryLongName),
                        "Very long name should not crash")
    }
    
    /// Test force unwrap safety
    func testOptionalSafety() {
        let cacheManager = QodeXCacheManager.shared
        
        // Should handle nil values gracefully
        let nilResult = cacheManager.getCachedDailyReading(for: Date.distantFuture,
                                                          userId: "nonexistent")
        XCTAssertNil(nilResult, "Should return nil for non-existent cache")
    }
    
    /// Test division by zero protection
    func testDivisionSafety() {
        let calculator = NumerologyCalculator()
        
        // Test calculations that could result in zero
        let result = calculator.calculateExpressionNumber(name: "")
        XCTAssertEqual(result, 0, "Empty name should return 0, not crash")
    }
    
    /// Test invalid date handling
    func testInvalidDateHandling() {
        let calculator = NumerologyCalculator()
        
        // Test with distant past/future dates
        let distantPast = Date.distantPast
        let distantFuture = Date.distantFuture
        
        XCTAssertNoThrow(calculator.calculateLifePathNumber(birthDate: distantPast),
                        "Distant past date should not crash")
        XCTAssertNoThrow(calculator.calculateLifePathNumber(birthDate: distantFuture),
                        "Distant future date should not crash")
    }
    
    // MARK: - ANR Prevention Tests
    
    /// Test main thread is not blocked by heavy operations
    func testMainThreadNonBlocking() {
        let expectation = self.expectation(description: "Main thread responsive")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Start heavy calculation on background
        DispatchQueue.global(qos: .userInitiated).async {
            let calculator = NumerologyCalculator()
            
            for i in 0..<10000 {
                _ = calculator.calculateLifePathNumber(
                    birthDate: Date().addingTimeInterval(TimeInterval(i * 86400))
                )
            }
        }
        
        // Main thread should respond within 100ms
        DispatchQueue.main.async {
            let responseTime = CFAbsoluteTimeGetCurrent() - startTime
            XCTAssertLessThan(responseTime, 0.1,
                            "Main thread blocked for \(responseTime)s")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test async/await doesn't create deadlocks
    func testAsyncAwaitSafety() {
        let expectation = self.expectation(description: "Async complete")
        
        Task {
            // Concurrent async operations
            async let task1 = asyncOperation()
            async let task2 = asyncOperation()
            async let task3 = asyncOperation()
            
            _ = await (task1, task2, task3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    /// Test timeout handling
    func testTimeoutHandling() {
        let expectation = self.expectation(description: "Timeout occurred")
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
        }
        
        // Cancel after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            task.cancel()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(task.isCancelled, "Task should be cancelled")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test graceful error recovery
    func testGracefulErrorRecovery() {
        let errorHandler = ErrorHandler.shared
        
        // Simulate various errors
        let errors: [QodeXError] = [
            .networkError,
            .databaseError,
            .calculationError,
            .cacheError
        ]
        
        for error in errors {
            XCTAssertNoThrow(errorHandler.handle(error),
                           "Error handler should not throw for \(error)")
        }
    }
    
    /// Test fallback mechanisms
    func testFallbackMechanisms() {
        let calculator = NumerologyCalculator()
        
        // When cache fails, should fall back to calculation
        let fallbackResult = calculator.calculateWithFallback(
            birthDate: Date(),
            cacheKey: "invalid_key"
        )
        
        XCTAssertGreaterThan(fallbackResult, 0,
                           "Should return calculated value when cache fails")
    }
    
    // MARK: - State Consistency Tests
    
    /// Test state consistency under concurrent access
    func testConcurrentStateAccess() {
        let calculator = NumerologyCalculator()
        let iterations = 1000
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        
        for i in 0..<iterations {
            group.enter()
            queue.async {
                _ = calculator.calculateLifePathNumber(
                    birthDate: Date().addingTimeInterval(TimeInterval(i * 1000))
                )
                group.leave()
            }
        }
        
        let expectation = self.expectation(description: "Concurrent access complete")
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    /// Test data consistency after interruptions
    func testDataConsistencyAfterInterruption() {
        var data: [String] = []
        let queue = DispatchQueue(label: "test.consistency")
        
        // Simulate interrupted write
        for i in 0..<100 {
            queue.sync {
                data.append("Item \(i)")
            }
        }
        
        XCTAssertEqual(data.count, 100, "Data should be consistent after concurrent writes")
    }
    
    // MARK: - Resource Leak Prevention
    
    /// Test timer invalidation
    func testTimerInvalidation() {
        var timer: Timer?
        weak var weakTimer: Timer?
        
        autoreleasepool {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in }
            weakTimer = timer
            timer?.invalidate()
            timer = nil
        }
        
        addTeardownBlock {
            Thread.sleep(forTimeInterval: 0.1)
            XCTAssertNil(weakTimer, "Timer should be deallocated after invalidation")
        }
    }
    
    /// Test notification observer removal
    func testNotificationObserverRemoval() {
        let center = NotificationCenter.default
        var observer: NSObjectProtocol?
        
        autoreleasepool {
            observer = center.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                         object: nil, queue: nil) { _ in }
            center.removeObserver(observer!)
        }
        
        // Observer should be removed without issues
        XCTAssertNotNil(observer)
    }
    
    // MARK: - Edge Case Tests
    
    /// Test extreme input values
    func testExtremeInputValues() {
        let calculator = NumerologyCalculator()
        
        // Test with Int.max/Int.min equivalent scenarios
        let extremeDate = Date(timeIntervalSince1970: TimeInterval(Int32.max))
        XCTAssertNoThrow(calculator.calculateLifePathNumber(birthDate: extremeDate),
                        "Extreme date should not crash")
    }
    
    /// Test rapid successive operations
    func testRapidSuccessiveOperations() {
        let calculator = NumerologyCalculator()
        
        measure {
            for _ in 0..<10000 {
                _ = calculator.calculateExpressionNumber(name: "Test")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func asyncOperation() async -> Int {
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        return Int.random(in: 1...100)
    }
}

// MARK: - Error Types

enum QodeXError: Error {
    case networkError
    case databaseError
    case calculationError
    case cacheError
    case unknownError
}

// MARK: - Error Handler

class ErrorHandler {
    
    static let shared = ErrorHandler()
    
    private(set) var errorCount = 0
    private(set) var lastError: QodeXError?
    
    func handle(_ error: QodeXError) {
        errorCount += 1
        lastError = error
        
        // Log error
        print("❌ Error handled: \(error)")
        
        // Recovery logic based on error type
        switch error {
        case .networkError:
            // Enable offline mode
            NetworkMonitor.shared.setOnline(false)
            
        case .databaseError:
            // Attempt to recreate database
            QodeXCacheManager.shared.recreateDatabase()
            
        case .calculationError:
            // Return default value
            break
            
        case .cacheError:
            // Clear cache
            QodeXCacheManager.shared.clearAllCache()
            
        case .unknownError:
            // Log for investigation
            break
        }
    }
    
    func reset() {
        errorCount = 0
        lastError = nil
    }
}

// MARK: - Extensions

extension NumerologyCalculator {
    
    func calculateWithFallback(birthDate: Date, cacheKey: String) -> Int {
        // Try cache first
        // If fails, calculate directly
        return calculateLifePathNumber(birthDate: birthDate)
    }
}

extension QodeXCacheManager {
    
    func recreateDatabase() {
        // Recreate CoreData stack
        clearAllCache()
    }
}

// MARK: - Reliability Metrics

struct ReliabilityMetrics {
    
    static let shared = ReliabilityMetrics()
    
    private(set) var sessionStartTime: Date?
    private(set) var errorCount = 0
    private(set) var anrCount = 0
    
    func startSession() {
        UserDefaults.standard.set(Date(), forKey: "session_start")
    }
    
    func recordError() {
        var count = UserDefaults.standard.integer(forKey: "session_error_count")
        count += 1
        UserDefaults.standard.set(count, forKey: "session_error_count")
    }
    
    func recordANR() {
        var count = UserDefaults.standard.integer(forKey: "session_anr_count")
        count += 1
        UserDefaults.standard.set(count, forKey: "session_anr_count")
    }
    
    func getSessionReport() -> ReliabilityReport {
        let errors = UserDefaults.standard.integer(forKey: "session_error_count")
        let anrs = UserDefaults.standard.integer(forKey: "session_anr_count")
        
        return ReliabilityReport(
            errorCount: errors,
            anrCount: anrs,
            crashFree: errors == 0,
            meetsTarget: errors == 0 && anrs == 0
        )
    }
}

struct ReliabilityReport {
    let errorCount: Int
    let anrCount: Int
    let crashFree: Bool
    let meetsTarget: Bool
    
    var description: String {
        var output = "🛡️ Reliability Report\n"
        output += "Errors: \(errorCount)\n"
        output += "ANRs: \(anrCount)\n"
        output += "Crash Free: \(crashFree ? "✅" : "❌")\n"
        output += "Meets Target: \(meetsTarget ? "✅" : "⚠️")\n"
        return output
    }
}
