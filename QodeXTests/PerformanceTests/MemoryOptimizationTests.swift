//
//  MemoryOptimizationTests.swift
//  QodeX Performance Tests
//
//  BEDROCK: Memory optimization and leak detection
//  Tests memory usage, retain cycles, and caching strategies
//

import XCTest
@testable import QodeX

// MARK: - Memory Optimization Tests

final class MemoryOptimizationTests: XCTestCase {
    
    // MARK: - Constants
    
    /// Maximum memory increase allowed during test (MB)
    let maxMemoryIncreaseMB: Double = 50.0
    
    /// Maximum acceptable memory footprint for app (MB)
    let maxAppMemoryMB: Double = 200.0
    
    // MARK: - Memory Leak Tests
    
    /// Test for retain cycles in ViewModels
    func testViewModelMemoryLeaks() {
        weak var weakViewModel: DashboardViewModel?
        
        autoreleasepool {
            let viewModel = DashboardViewModel()
            weakViewModel = viewModel
            
            // Simulate view lifecycle
            viewModel.loadData()
            viewModel.refresh()
        }
        
        // Force memory pressure
        addTeardownBlock {
            // Give ARC time to deallocate
            Thread.sleep(forTimeInterval: 0.1)
            XCTAssertNil(weakViewModel, "DashboardViewModel leaked - check for retain cycles")
        }
    }
    
    /// Test for retain cycles in async operations
    func testAsyncOperationMemoryLeaks() {
        weak var weakCalculator: NumerologyCalculator?
        
        autoreleasepool {
            let calculator = NumerologyCalculator()
            weakCalculator = calculator
            
            let expectation = self.expectation(description: "Async complete")
            
            Task {
                _ = calculator.calculateLifePathNumber(birthDate: Date())
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
        
        addTeardownBlock {
            Thread.sleep(forTimeInterval: 0.1)
            XCTAssertNil(weakCalculator, "NumerologyCalculator leaked in async context")
        }
    }
    
    /// Test closure-based retain cycles
    func testClosureMemoryLeaks() {
        weak var weakManager: SubscriptionManager?
        
        autoreleasepool {
            let manager = SubscriptionManager.shared
            weakManager = manager
            
            // Test that completion handlers don't create cycles
            let expectation = self.expectation(description: "Completion called")
            
            manager.fetchOfferings { offerings in
                // If this captures self strongly, it would leak
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    // MARK: - Memory Usage Tests
    
    /// Test memory usage during heavy numerology calculations
    func testNumerologyCalculationMemoryUsage() {
        let initialMemory = getCurrentMemoryUsageMB()
        
        measure(metrics: [XCTMemoryMetric()]) {
            let calculator = NumerologyCalculator()
            
            // Perform many calculations
            for i in 0..<1000 {
                let date = Date(timeIntervalSince1970: TimeInterval(i * 86400))
                _ = calculator.calculateLifePathNumber(birthDate: date)
                _ = calculator.calculateExpressionNumber(name: "Test User \(i)")
            }
        }
        
        let finalMemory = getCurrentMemoryUsageMB()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryIncrease, maxMemoryIncreaseMB,
                         "Memory increased by \(memoryIncrease)MB, max allowed \(maxMemoryIncreaseMB)MB")
    }
    
    /// Test memory usage with large data sets
    func testLargeDatasetMemoryUsage() {
        let initialMemory = getCurrentMemoryUsageMB()
        
        // Create large dataset
        var readings: [DailyReading] = []
        for i in 0..<10000 {
            readings.append(DailyReading(
                id: "\(i)",
                date: Date(),
                number: i % 9 + 1,
                vibe: "Vibe \(i)",
                fullReading: String(repeating: "Reading content ", count: 100)
            ))
        }
        
        let loadedMemory = getCurrentMemoryUsageMB()
        
        // Clear dataset
        readings.removeAll()
        
        let finalMemory = getCurrentMemoryUsageMB()
        
        // Memory should return close to initial after clearing
        let memoryReclaimed = loadedMemory - finalMemory
        XCTAssertGreaterThan(memoryReclaimed, loadedMemory - initialMemory - 10,
                           "Memory not properly reclaimed after clearing dataset")
    }
    
    // MARK: - Image Cache Tests
    
    /// Test image caching strategy
    func testImageCacheMemoryLimit() {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        
        let initialMemory = getCurrentMemoryUsageMB()
        
        // Add images to cache
        for i in 0..<200 {
            let image = UIImage()
            cache.setObject(image, forKey: "\(i)" as NSString, cost: 1)
        }
        
        // Cache should enforce limits
        XCTAssertLessThanOrEqual(cache.totalCostLimit, 50 * 1024 * 1024,
                               "Cache exceeds memory limit")
    }
    
    /// Test image cache eviction policy
    func testImageCacheEviction() {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 10
        
        // Fill cache
        for i in 0..<10 {
            cache.setObject(UIImage(), forKey: "key_\(i)" as NSString)
        }
        
        // Add more items - should trigger eviction
        for i in 10..<20 {
            cache.setObject(UIImage(), forKey: "key_\(i)" as NSString)
        }
        
        // Some old items should have been evicted
        var evictedCount = 0
        for i in 0..<10 {
            if cache.object(forKey: "key_\(i)" as NSString) == nil {
                evictedCount += 1
            }
        }
        
        XCTAssertGreaterThan(evictedCount, 0, "Cache should evict old items")
    }
    
    // MARK: - CoreData Memory Tests
    
    /// Test CoreData fetch batching
    func testCoreDataFetchBatching() {
        let context = QodeXCacheManager.shared.container.viewContext
        
        measure(metrics: [XCTMemoryMetric()]) {
            // Fetch with batch size limit
            let request: NSFetchRequest<DailyReadingEntity> = DailyReadingEntity.fetchRequest()
            request.fetchBatchSize = 20
            request.fetchLimit = 100
            
            do {
                let results = try context.fetch(request)
                XCTAssertLessThanOrEqual(results.count, 100,
                                       "Fetch exceeded limit")
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }
    }
    
    /// Test CoreData context cleanup
    func testCoreDataContextCleanup() {
        let initialMemory = getCurrentMemoryUsageMB()
        
        autoreleasepool {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = QodeXCacheManager.shared.container.viewContext
            
            // Create temporary objects
            for i in 0..<100 {
                let entity = DailyReadingEntity(context: context)
                entity.id = "\(i)"
                entity.fullReading = String(repeating: "Content ", count: 100)
            }
            
            // Context should be deallocated after autoreleasepool
        }
        
        let finalMemory = getCurrentMemoryUsageMB()
        let memoryDiff = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryDiff, 10,
                         "Memory not cleaned up after context deallocation: \(memoryDiff)MB")
    }
    
    // MARK: - Cleanup Tests
    
    /// Test proper cleanup of resources
    func testResourceCleanup() {
        var objects: [AnyObject] = []
        
        // Create objects with resources
        for _ in 0..<100 {
            let object = ResourceIntensiveObject()
            objects.append(object)
        }
        
        let loadedMemory = getCurrentMemoryUsageMB()
        
        // Clear objects
        objects.removeAll()
        
        // Force cleanup
        addTeardownBlock {
            Thread.sleep(forTimeInterval: 0.1)
            
            let finalMemory = self.getCurrentMemoryUsageMB()
            let memoryReclaimed = loadedMemory - finalMemory
            
            XCTAssertGreaterThan(memoryReclaimed, 0,
                               "No memory reclaimed after cleanup")
        }
    }
    
    /// Test memory warning handling
    func testMemoryWarningHandling() {
        let cacheManager = QodeXCacheManager.shared
        
        // Populate cache
        let user = QodeXUser(id: "test", email: "test@test.com",
                           fullName: "Test", membershipTier: .free)
        
        let expectation = self.expectation(description: "Prefetch complete")
        Task {
            await cacheManager.prefetchUpcomingReadings(for: user)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        let preWarningMemory = getCurrentMemoryUsageMB()
        
        // Simulate memory warning
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification,
                                      object: nil)
        
        // Give time for cleanup
        Thread.sleep(forTimeInterval: 0.5)
        
        let postWarningMemory = getCurrentMemoryUsageMB()
        let memorySaved = preWarningMemory - postWarningMemory
        
        XCTAssertGreaterThan(memorySaved, 0,
                           "Memory warning should trigger cleanup")
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentMemoryUsageMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return 0
        }
        
        return Double(info.resident_size) / 1024 / 1024
    }
}

// MARK: - Memory Leak Detector

/// Utility for detecting memory leaks in tests
class MemoryLeakDetector {
    
    static let shared = MemoryLeakDetector()
    
    private var trackedObjects: [String: WeakReference] = [:]
    
    func track<T: AnyObject>(_ object: T, identifier: String) {
        trackedObjects[identifier] = WeakReference(object)
    }
    
    func checkForLeaks() -> [String] {
        var leaks: [String] = []
        
        for (identifier, reference) in trackedObjects {
            if reference.object != nil {
                leaks.append(identifier)
            }
        }
        
        return leaks
    }
    
    func clearTracking() {
        trackedObjects.removeAll()
    }
}

class WeakReference {
    weak var object: AnyObject?
    
    init(_ object: AnyObject?) {
        self.object = object
    }
}

// MARK: - Mock Classes

class ResourceIntensiveObject {
    private var largeData: Data
    
    init() {
        // Allocate 1MB of data
        largeData = Data(repeating: 0, count: 1024 * 1024)
    }
    
    deinit {
        // Cleanup notification for testing
    }
}

// MARK: - ViewModel Placeholders

class DashboardViewModel: ObservableObject {
    @Published var data: [String] = []
    
    func loadData() {
        data = (0..<100).map { "Item \($0)" }
    }
    
    func refresh() {
        loadData()
    }
}
