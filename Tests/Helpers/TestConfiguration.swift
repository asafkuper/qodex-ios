//
//  TestConfiguration.swift
//  Shared test configuration and utilities
//

import Foundation
import Testing

// MARK: - Test Configuration

enum TestConfiguration {
    /// Whether tests are running in CI environment
    static var isCI: Bool {
        ProcessInfo.processInfo.environment["CI"] == "true"
    }
    
    /// Whether to use Firebase emulator
    static var useFirebaseEmulator: Bool {
        ProcessInfo.processInfo.environment["FIRESTORE_EMULATOR_HOST"] != nil
    }
    
    /// Firebase emulator host
    static var firebaseEmulatorHost: String {
        ProcessInfo.processInfo.environment["FIRESTORE_EMULATOR_HOST"] ?? "localhost:8080"
    }
    
    /// Whether to enable verbose logging
    static var verboseLogging: Bool {
        ProcessInfo.processInfo.environment["VERBOSE_TESTS"] == "1"
    }
    
    /// Test timeout in seconds
    static var testTimeout: TimeInterval {
        if let timeoutStr = ProcessInfo.processInfo.environment["TEST_TIMEOUT"],
           let timeout = Double(timeoutStr) {
            return timeout
        }
        return 30.0
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var unit: Self
    @Tag static var integration: Self
    @Tag static var ui: Self
    @Tag static var slow: Self
    @Tag static var flaky: Self
    @Tag static var network: Self
    @Tag static var database: Self
    @Tag static var auth: Self
    @Tag static var numerology: Self
    @Tag static var validation: Self
}

// MARK: - Test Extensions

extension Suite {
    /// Creates a test suite with common configuration
    static func configured(
        _ name: String,
        tags: [Tag] = [],
        timeout: TimeInterval? = nil
    ) -> Self {
        return Suite(name, .serialized, tags: tags)
    }
}

// MARK: - Test Helpers

enum TestHelpers {
    /// Run an async operation with timeout
    static func withTimeout<T>(
        seconds: TimeInterval = TestConfiguration.testTimeout,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Add the actual operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TestError.timeout(seconds: seconds)
            }
            
            // Return first completed result
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    /// Retry an operation with exponential backoff
    static func retry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 0.5,
        operation: () throws -> T
    ) throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try operation()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    Thread.sleep(forTimeInterval: delay * pow(2.0, Double(attempt - 1)))
                }
            }
        }
        
        throw lastError ?? TestError.maxRetriesReached
    }
    
    /// Measure execution time of an operation
    static func measure<T>(
        name: String,
        operation: () throws -> T
    ) rethrows -> (result: T, duration: TimeInterval) {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let diff = CFAbsoluteTimeGetCurrent() - start
        
        if TestConfiguration.verboseLogging {
            print("[PERF] \(name): \(diff * 1000)ms")
        }
        
        return (result, diff)
    }
}

// MARK: - Test Errors

enum TestError: Error, CustomStringConvertible {
    case timeout(seconds: TimeInterval)
    case maxRetriesReached
    case unexpectedNil
    case invalidTestData
    case mockNotConfigured
    
    var description: String {
        switch self {
        case .timeout(let seconds):
            return "Test timed out after \(seconds) seconds"
        case .maxRetriesReached:
            return "Maximum retry attempts reached"
        case .unexpectedNil:
            return "Expected non-nil value but got nil"
        case .invalidTestData:
            return "Test data is invalid"
        case .mockNotConfigured:
            return "Mock object was not properly configured"
        }
    }
}

// MARK: - Async Test Utilities

extension Test {
    /// Run a test with timeout protection
    static func withTimeout(
        _ seconds: TimeInterval = 30,
        _ test: @escaping () async throws -> Void
    ) -> Self {
        return Test {
            try await TestHelpers.withTimeout(seconds: seconds, operation: test)
        }
    }
}

// MARK: - Assertion Helpers

func XCTAssertNotNilAsync<T>(
    _ expression: @autoclosure () async throws -> T?,
    _ message: @autoclosure () -> String = "",
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let value = try? await expression()
    #expect(value != nil, Comment(rawValue: message()), sourceLocation: sourceLocation)
}

func XCTAssertEqualAsync<T: Equatable>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let value1 = try? await expression1()
    let value2 = try? await expression2()
    #expect(value1 == value2, Comment(rawValue: message()), sourceLocation: sourceLocation)
}

// MARK: - Test Lifecycle

actor TestLifecycle {
    private var setupActions: [() async -> Void] = []
    private var teardownActions: [() async -> Void] = []
    
    func registerSetup(_ action: @escaping () async -> Void) {
        setupActions.append(action)
    }
    
    func registerTeardown(_ action: @escaping () async -> Void) {
        teardownActions.append(action)
    }
    
    func runSetup() async {
        for action in setupActions {
            await action()
        }
    }
    
    func runTeardown() async {
        for action in teardownActions {
            await action()
        }
    }
}

// MARK: - Shared Test State

@globalActor
struct TestActor {
    static let shared = TestActor()
    
    func execute<T>(_ operation: () async throws -> T) async rethrows -> T {
        return try await operation()
    }
}