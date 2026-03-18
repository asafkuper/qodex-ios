# QodeX iOS Quick Reference

## 🆕 New Systems

### 1. Logging (Replace print())

**Before:**
```swift
print("User logged in")
```

**After:**
```swift
QodeXLogger.shared.info("User logged in", category: .auth)
QodeXLogger.shared.debug("Chart data loaded", category: .ui)
QodeXLogger.shared.error("Network failed", category: .network)
```

### 2. Performance Monitoring

**Start monitoring:**
```swift
// In AppDelegate or SceneDelegate
PerformanceMonitor.shared.startMonitoring()
```

**Track view performance:**
```swift
ChartView()
    .trackPerformance("ChartView render")
    .optimizeForThermalState()
```

**Check metrics:**
```swift
if PerformanceMonitor.shared.isHighMemoryUsage {
    // Reduce memory usage
}
```

### 3. Build Configuration

**Check current config:**
```swift
BuildConfiguration.printCurrentConfiguration()
```

**Enable build cache:**
```swift
BuildCacheConfiguration.shared.enableCache()
```

**Track build time:**
```swift
BuildAnalytics.shared.startBuild()
// ... build ...
BuildAnalytics.shared.endBuild()
```

### 4. SwiftLint

**Check code:**
```bash
cd /root/.openclaw/workspace/qodex-ios
swiftlint lint
```

**Auto-fix issues:**
```bash
swiftlint autocorrect
```

**Key rules:**
- No `print()` → Use `QodeXLogger`
- No `fatalError()` → Handle errors gracefully
- No force unwrapping → Use optional binding
- Max line length: 150
- Max function length: 60 lines

---

## 📱 Platform Targets

| Platform | Target | Status |
|----------|--------|--------|
| iOS App | 17.0+ | ✅ Ready |
| App Clip | 17.0+ | ✅ Enhanced |
| Watch | 10.0+ | ✅ Ready |
| Widget | 17.0+ | ✅ Interactive |
| iMessage | 17.0+ | ✅ Ready |

---

## 🎨 New UI Components

### Dynamic Type Support
```swift
Text("Scalable Text")
    .textScale(.body)  // Automatically scales with accessibility settings
```

### Enhanced Haptics
```swift
QXHaptic.tap(style: .sacred)      // Fibonacci pattern
QXHaptic.tap(style: .celestial)   // Rising intensity
QXHaptic.premiumSuccess()          // Premium feel
QXHaptic.streakMilestone(7)       // Week milestone
```

### Accessible Components
```swift
AccessibleButton(
    title: "Continue",
    icon: "arrow.right",
    accessibilityLabel: "Proceed to next step",
    action: { /* action */ }
)

AccessibleCard(
    title: "Daily Reading",
    accessibilityLabel: "Your numerology reading for today"
) {
    // Card content
}
```

---

## 🧪 Testing

### Run Unit Tests
```bash
xcodebuild test \
  -project QodeX.xcodeproj \
  -scheme QodeX \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Snapshot Testing
```swift
// In PreviewGallery
PreviewGallery()
    .previewDevice("iPhone 16")
```

---

## 🚀 Build for Release

```bash
# Clean build
xcodebuild clean \
  -project QodeX.xcodeproj \
  -scheme QodeX

# Build release
xcodebuild build \
  -project QodeX.xcodeproj \
  -scheme QodeX \
  -configuration Release \
  -destination 'generic/platform=iOS'

# Archive for App Store
xcodebuild archive \
  -project QodeX.xcodeproj \
  -scheme QodeX \
  -configuration Release \
  -archivePath QodeX.xcarchive
```

---

## 📊 Analytics

### Build Times
```swift
// Average build time
let avgTime = BuildAnalytics.shared.averageBuildTime()
print("Average build: \(avgTime)s")
```

### Performance Metrics
```swift
// Get current metrics
if let metrics = PerformanceMonitor.shared.currentMetrics {
    print("Memory: \(metrics.memoryUsedMB)MB")
    print("CPU: \(metrics.cpuUsagePercent)%")
}
```

---

## 🔧 Debugging

### View Logs
```bash
# In Xcode Console
# Or use Console.app to view os_log messages
```

### Check for Retain Cycles
```swift
// Use weak self in closures
someService.fetch { [weak self] result in
    guard let self = self else { return }
    // Handle result
}
```

### Memory Debugging
```swift
// Check memory warnings
NotificationCenter.default.addObserver(
    forName: .qodexMemoryWarning,
    object: nil,
    queue: .main
) { _ in
    // Release heavy resources
}
```

---

## 📝 Code Style

### SwiftLint Rules
```yaml
# Key rules
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - array_init
  - closure_end_indentation
  - empty_count
  - explicit_init

line_length: 150
function_body_length: 60
cyclomatic_complexity: 10
```

### Naming Conventions
- **Classes/Structs:** `PascalCase` (e.g., `ChartView`)
- **Functions/Variables:** `camelCase` (e.g., `calculateLifePath`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Protocols:** `PascalCase` with suffix (e.g., `NumerologyService`)

---

## 🆘 Common Issues

### Issue: High Memory Usage
**Solution:**
```swift
// In AppDelegate
PerformanceMonitor.shared.startMonitoring()

// Release resources when warned
NotificationCenter.default.addObserver(
    forName: .qodexMemoryWarning,
    object: nil,
    queue: .main
) { _ in
    ImageCache.shared.clear()
    // Release other heavy resources
}
```

### Issue: Slow Build Times
**Solution:**
```bash
# Enable build cache
BuildCacheConfiguration.shared.enableCache()

# Use incremental builds
IncrementalBuildHelper.shared.recordBuild(file: path)
```

### Issue: Thermal Throttling
**Solution:**
```swift
// Automatically handled by PerformanceMonitor
// Or manually:
.viewModifier(ThermalOptimizationModifier())
```

---

## 📚 Resources

- **Full Documentation:** `/root/.openclaw/workspace/qodex-ios/BUILD_IMPROVEMENTS_COMPLETE.md`
- **Improvement Plan:** `/root/.openclaw/workspace/qodex-ios/BUILD_IMPROVEMENT_PLAN.md`
- **Build Config:** `/root/.openclaw/workspace/qodex-ios/QodeX/Core/Build/BuildConfiguration.swift`
- **Logger:** `/root/.openclaw/workspace/qodex-ios/QodeX/Core/Utils/QodeXLogger.swift`
- **Performance:** `/root/.openclaw/workspace/qodex-ios/QodeX/Core/Performance/PerformanceMonitor.swift`

---

**Quick Tip:** Run `swiftlint lint` before each commit to maintain code quality!
