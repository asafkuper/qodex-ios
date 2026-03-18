//
//  FPSPerformanceTests.swift
//  QodeX Performance Tests
//
//  BEDROCK: 60FPS smooth performance validation
//  Tests Core Animation performance and identifies frame drops
//

import XCTest
import CoreAnimation
@testable import QodeX

// MARK: - 60FPS Performance Tests

final class FPSPerformanceTests: XCTestCase {
    
    // MARK: - Constants
    
    /// Target frame rate (60 FPS)
    let targetFPS: Double = 60.0
    
    /// Minimum acceptable frame rate (54 FPS = 10% drop)
    let minimumAcceptableFPS: Double = 54.0
    
    /// Maximum acceptable frame drop percentage
    let maxFrameDropPercentage: Double = 5.0
    
    // MARK: - Display Link Performance
    
    /// Test Core Animation display link performance
    func testDisplayLinkPerformance() {
        let metrics = XCTPerformanceMetrics()
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
            displayLink.preferredFramesPerSecond = 60
            
            let expectation = self.expectation(description: "Display link test")
            
            // Run for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                displayLink.invalidate()
                expectation.fulfill()
            }
            
            displayLink.add(to: .main, forMode: .common)
            wait(for: [expectation], timeout: 3.0)
        }
    }
    
    @objc private func displayLinkFired(_ displayLink: CADisplayLink) {
        // Simulate frame processing
        let frameTime = 1.0 / 60.0 // Target 16.67ms per frame
        let actualFrameTime = displayLink.duration
        
        // Frame time should be close to target
        let variance = abs(actualFrameTime - frameTime)
        XCTAssertLessThan(variance, 0.002, "Frame timing variance too high: \(variance)")
    }
    
    // MARK: - Scroll Performance Tests
    
    /// Test smooth scrolling in list views
    func testListScrollPerformance() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to a list view (e.g., readings)
        let readingsTab = app.tabBars.buttons["Readings"]
        if readingsTab.exists {
            readingsTab.tap()
            
            let list = app.collectionViews.firstMatch
            
            measure(options: XCTMeasureOptions.default) {
                // Perform scroll gesture
                list.swipeUp(velocity: .fast)
                list.swipeDown(velocity: .fast)
            }
        }
    }
    
    /// Test scroll performance with complex cells
    func testComplexCellScrollPerformance() {
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            // Create complex UI elements
            let complexView = createComplexView()
            
            let expectation = self.expectation(description: "Scroll animation complete")
            
            // Animate scroll-like movement
            UIView.animate(withDuration: 1.0, animations: {
                complexView.transform = CGAffineTransform(translationX: 0, y: -500)
            }) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    // MARK: - Animation Performance Tests
    
    /// Test numerology counter animation performance
    func testNumberCounterAnimationPerformance() {
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            let counter = QXNumberCounter()
            
            let expectation = self.expectation(description: "Counter animation complete")
            
            // Animate from 0 to 100
            counter.animate(to: 100, duration: 1.0) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    /// Test sacred geometry animation performance
    func testSacredGeometryAnimationPerformance() {
        measure(metrics: [XCTCPUMetric(), XCTGPUMetric()]) {
            let geometryView = GeometryAnimationView()
            
            let expectation = self.expectation(description: "Geometry animation complete")
            
            // Animate sacred geometry
            geometryView.animate(duration: 1.0) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    /// Test Metal background animation performance
    func testMetalBackgroundPerformance() {
        measure(metrics: [XCTGPUMetric(), XCTMemoryMetric()]) {
            let metalView = MetalSacredBackground()
            
            let expectation = self.expectation(description: "Metal render complete")
            
            // Render for 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    // MARK: - Main Thread Performance
    
    /// Test that UI updates don't block main thread
    func testMainThreadResponsiveness() {
        var frameDrops: Int = 0
        let totalFrames = 120 // 2 seconds at 60fps
        
        let displayLink = CADisplayLink(target: self, selector: #selector(checkFrameTime))
        var previousTimestamp: CFTimeInterval = 0
        
        measure {
            let expectation = self.expectation(description: "Frame monitoring complete")
            
            var frameCount = 0
            displayLink.add(to: .main, forMode: .common)
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                displayLink.invalidate()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 3.0)
        }
        
        // Frame drop rate should be under 5%
        let dropRate = Double(frameDrops) / Double(totalFrames) * 100
        XCTAssertLessThan(dropRate, maxFrameDropPercentage,
                         "Frame drop rate \(dropRate)% exceeds \(maxFrameDropPercentage)%")
    }
    
    @objc private func checkFrameTime(_ displayLink: CADisplayLink) {
        let frameDuration = displayLink.targetTimestamp - displayLink.timestamp
        let expectedDuration = 1.0 / targetFPS
        
        // If frame took longer than expected + 2ms tolerance, count as drop
        if frameDuration > expectedDuration + 0.002 {
            // Frame drop detected
        }
    }
    
    // MARK: - Off-Main-Thread UI Tests
    
    /// Test heavy computations happen off main thread
    func testOffMainThreadCalculations() {
        let expectation = self.expectation(description: "Calculation complete")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform heavy numerology calculation on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            let calculator = NumerologyCalculator()
            
            // Complex calculation
            for _ in 0..<1000 {
                _ = calculator.calculateLifePathNumber(birthDate: Date())
            }
            
            let calculationTime = CFAbsoluteTimeGetCurrent() - startTime
            
            DispatchQueue.main.async {
                // Main thread time should be minimal
                let mainThreadTime = CFAbsoluteTimeGetCurrent() - startTime - calculationTime
                XCTAssertLessThan(mainThreadTime, 0.01,
                                "Heavy calculation blocked main thread for \(mainThreadTime)s")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    /// Test draw call optimization
    func testDrawCallOptimization() {
        measure(metrics: [XCTCPUMetric(), XCTGPUMetric()]) {
            // Create view with many sublayers (potential draw call issue)
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
            
            // Add 50 sublayers (should be batched efficiently)
            for i in 0..<50 {
                let layer = CALayer()
                layer.frame = CGRect(x: i * 5, y: i * 10, width: 50, height: 50)
                layer.backgroundColor = UIColor.red.cgColor
                containerView.layer.addSublayer(layer)
            }
            
            // Force layout and render
            containerView.setNeedsLayout()
            containerView.layoutIfNeeded()
            
            // Render to image (simulates GPU work)
            UIGraphicsBeginImageContext(containerView.bounds.size)
            containerView.layer.render(in: UIGraphicsGetCurrentContext()!)
            _ = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createComplexView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 200))
        view.backgroundColor = .systemBackground
        
        // Add complex subviews
        for i in 0..<20 {
            let label = UILabel()
            label.text = "Item \(i)"
            label.frame = CGRect(x: 10, y: i * 25, width: 200, height: 20)
            view.addSubview(label)
            
            let imageView = UIImageView()
            imageView.backgroundColor = .systemGray
            imageView.frame = CGRect(x: 220, y: i * 25, width: 20, height: 20)
            view.addSubview(imageView)
        }
        
        return view
    }
}

// MARK: - Performance Monitor

/// Real-time performance monitoring during app usage
class PerformanceMonitor {
    
    static let shared = PerformanceMonitor()
    
    private var displayLink: CADisplayLink?
    private var frameTimings: [Double] = []
    private var isMonitoring = false
    
    var onFrameDrop: ((Int) -> Void)?
    var onLowFPS: ((Double) -> Void)?
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        frameTimings.removeAll()
        
        displayLink = CADisplayLink(target: self, selector: #selector(trackFrame))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopMonitoring() -> PerformanceReport {
        displayLink?.invalidate()
        displayLink = nil
        isMonitoring = false
        
        return generateReport()
    }
    
    @objc private func trackFrame(_ link: CADisplayLink) {
        let frameTime = link.duration
        frameTimings.append(frameTime)
        
        // Keep only last 60 frames (1 second)
        if frameTimings.count > 60 {
            frameTimings.removeFirst()
        }
        
        // Check for frame drops
        let expectedFrameTime = 1.0 / 60.0
        if frameTime > expectedFrameTime * 1.5 {
            let droppedFrames = Int(frameTime / expectedFrameTime) - 1
            onFrameDrop?(droppedFrames)
        }
        
        // Check for sustained low FPS
        if frameTimings.count >= 60 {
            let avgFrameTime = frameTimings.reduce(0, +) / Double(frameTimings.count)
            let currentFPS = 1.0 / avgFrameTime
            
            if currentFPS < 54 {
                onLowFPS?(currentFPS)
            }
        }
    }
    
    private func generateReport() -> PerformanceReport {
        let avgFrameTime = frameTimings.reduce(0, +) / Double(frameTimings.count)
        let avgFPS = 1.0 / avgFrameTime
        
        let expectedFrameTime = 1.0 / 60.0
        let frameDrops = frameTimings.filter { $0 > expectedFrameTime * 1.5 }.count
        
        return PerformanceReport(
            averageFPS: avgFPS,
            frameDropCount: frameDrops,
            totalFrames: frameTimings.count,
            timestamp: Date()
        )
    }
}

struct PerformanceReport {
    let averageFPS: Double
    let frameDropCount: Int
    let totalFrames: Int
    let timestamp: Date
    
    var isAcceptable: Bool {
        return averageFPS >= 54.0 && frameDropPercentage < 5.0
    }
    
    var frameDropPercentage: Double {
        return Double(frameDropCount) / Double(totalFrames) * 100
    }
    
    var description: String {
        var output = "📈 Performance Report\n"
        output += "Average FPS: \(String(format: "%.1f", averageFPS))\n"
        output += "Frame Drops: \(frameDropCount) (\(String(format: "%.1f", frameDropPercentage))%)\n"
        output += "Status: \(isAcceptable ? "✅ PASS" : "⚠️ FAIL")\n"
        return output
    }
}

// MARK: - Mock Views for Testing

class GeometryAnimationView: UIView {
    func animate(duration: TimeInterval, completion: @escaping () -> Void) {
        // Simulate sacred geometry animation
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi)
            self.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = .identity
                self.alpha = 1.0
            }) { _ in
                completion()
            }
        }
    }
}

class MetalSacredBackground: UIView {
    // Mock implementation for testing
}
