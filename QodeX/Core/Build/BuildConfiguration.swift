//
//  BuildConfiguration.swift
//  Build optimization settings and compiler flags
//

import Foundation

// MARK: - Build Configuration
enum BuildConfiguration {
    case debug
    case release
    case testing
    
    static var current: BuildConfiguration {
        #if DEBUG
        return .debug
        #elseif TESTING
        return .testing
        #else
        return .release
        #endif
    }
    
    // MARK: - Compiler Optimization Flags
    
    var swiftCompilerFlags: [String] {
        switch self {
        case .debug:
            return [
                "-Onone",                          // No optimization for faster builds
                "-DDEBUG",
                "-enable-assertions",
                "-enable-testing"
            ]
        case .release:
            return [
                "-O",                             // Full optimization
                "-whole-module-optimization",     // WMO for better performance
                "-enable-bridging-pch",           // Precompiled headers
                "-enforce-exclusivity=checked",   // Performance safety
                "-emit-objc-header",              // For mixed projects
                "-cross-module-optimization"      // Cross-module optimizations
            ]
        case .testing:
            return [
                "-Onone",
                "-enable-testing",
                "-DDEBUG",
                "-DTESTING"
            ]
        }
    }
    
    var linkerFlags: [String] {
        switch self {
        case .release:
            return [
                "-Wl,-dead_strip",                // Remove dead code
                "-Wl,-no_exported_symbols",       // Reduce binary size
                "-Wl,-x"                          // Strip local symbols
            ]
        default:
            return []
        }
    }
    
    // MARK: - Build Settings
    
    var buildSettings: [String: String] {
        var settings: [String: String] = [
            // Swift Version
            "SWIFT_VERSION": "6.0",
            "SWIFT_STDLIB": "swiftCore",
            
            // Code Signing
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "CODE_SIGN_STYLE": "Automatic",
            
            // Deployment
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "TARGETED_DEVICE_FAMILY": "1,2", // iPhone, iPad
            
            // Bitcode (disabled for modern apps)
            "ENABLE_BITCODE": "NO",
            
            // Testing
            "ENABLE_TESTING_SEARCH_PATHS": "YES",
            
            // Sandbox
            "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
            
            // Parallel builds
            "BUILD_ACTIVE_RESOURCES_ONLY": "YES"
        ]
        
        switch self {
        case .debug:
            settings.merge([
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                "SWIFT_COMPILATION_MODE": "singlefile",
                "GCC_OPTIMIZATION_LEVEL": "0",
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "ENABLE_TESTABILITY": "YES",
                "ONLY_ACTIVE_ARCH": "YES"
            ]) { (_, new) in new }
            
        case .release:
            settings.merge([
                "SWIFT_OPTIMIZATION_LEVEL": "-O",
                "SWIFT_COMPILATION_MODE": "wholemodule",
                "GCC_OPTIMIZATION_LEVEL": "s", // Size optimization
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "ENABLE_TESTABILITY": "NO",
                "ONLY_ACTIVE_ARCH": "NO",
                "VALIDATE_PRODUCT": "YES",
                "DEPLOYMENT_POSTPROCESSING": "YES",
                "STRIP_INSTALLED_PRODUCT": "YES",
                "STRIP_STYLE": "all",
                "COPY_PHASE_STRIP": "YES"
            ]) { (_, new) in new }
            
        case .testing:
            settings.merge([
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                "ENABLE_TESTABILITY": "YES",
                "ONLY_ACTIVE_ARCH": "YES"
            ]) { (_, new) in new }
        }
        
        return settings
    }
    
    // MARK: - Performance Settings
    
    var performanceSettings: [String: String] {
        switch self {
        case .release:
            return [
                // ARC Optimizations
                "CLANG_ENABLE_OBJC_ARC": "YES",
                "CLANG_ENABLE_OBJC_WEAK": "YES",
                
                // Linker optimizations
                "LD_NO_PIE": "NO",
                "LD_RUNPATH_SEARCH_PATHS": "@executable_path/Frameworks",
                
                // Dead code stripping
                "DEAD_CODE_STRIPPING": "YES",
                "LLVM_LTO": "YES", // Link-time optimization
                
                // Asset optimization
                "ASSETCATALOG_COMPILER_OPTIMIZATION": "space",
                
                // Compression
                "COMPRESS_PNG_FILES": "YES",
                "STRIP_PNG_TEXT": "YES"
            ]
        default:
            return [
                "CLANG_ENABLE_OBJC_ARC": "YES",
                "CLANG_ENABLE_OBJC_WEAK": "YES"
            ]
        }
    }
}

// MARK: - Build Cache Configuration
struct BuildCacheConfiguration {
    static let shared = BuildCacheConfiguration()
    
    var isCacheEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "build_cache_enabled")
    }
    
    func enableCache() {
        UserDefaults.standard.set(true, forKey: "build_cache_enabled")
        
        // Set environment variables for build cache
        setenv("XCODE_BUILD_CACHE", "1", 1)
        setenv("XCCACHE_DIR", "\(NSHomeDirectory())/.xccache", 1)
    }
    
    func clearCache() {
        let cacheDir = "\(NSHomeDirectory())/.xccache"
        try? FileManager.default.removeItem(atPath: cacheDir)
    }
}

// MARK: - Incremental Build Helper
struct IncrementalBuildHelper {
    static let shared = IncrementalBuildHelper()
    
    private let buildManifestPath: String
    
    init() {
        buildManifestPath = "\(NSHomeDirectory())/.qodex/build_manifest.json"
    }
    
    func shouldRebuild(file: String) -> Bool {
        guard let manifest = loadManifest() else { return true }
        
        let currentHash = hashOfFile(at: file)
        let lastHash = manifest[file]
        
        return currentHash != lastHash
    }
    
    func recordBuild(file: String) {
        var manifest = loadManifest() ?? [:]
        manifest[file] = hashOfFile(at: file)
        saveManifest(manifest)
    }
    
    private func loadManifest() -> [String: String]? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: buildManifestPath)),
              let manifest = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return nil
        }
        return manifest
    }
    
    private func saveManifest(_ manifest: [String: String]) {
        let dir = (buildManifestPath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        
        if let data = try? JSONSerialization.data(withJSONObject: manifest) {
            try? data.write(to: URL(fileURLWithPath: buildManifestPath))
        }
    }
    
    private func hashOfFile(at path: String) -> String {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return ""
        }
        return data.base64EncodedString().prefix(16).description
    }
}

// MARK: - Build Analytics
final class BuildAnalytics {
    static let shared = BuildAnalytics()
    
    private var buildStartTime: Date?
    private var phaseStartTime: Date?
    
    func startBuild() {
        buildStartTime = Date()
        QodeXLogger.shared.info("Build started", category: .app)
    }
    
    func startPhase(_ name: String) {
        phaseStartTime = Date()
        QodeXLogger.shared.debug("Build phase started: \(name)", category: .app)
    }
    
    func endPhase(_ name: String) {
        guard let start = phaseStartTime else { return }
        let duration = Date().timeIntervalSince(start)
        QodeXLogger.shared.info("Build phase '\(name)' completed in \(String(format: "%.2f", duration))s", category: .app)
    }
    
    func endBuild() {
        guard let start = buildStartTime else { return }
        let duration = Date().timeIntervalSince(start)
        QodeXLogger.shared.info("Build completed in \(String(format: "%.2f", duration))s", category: .app)
        
        // Store build time for analysis
        var buildTimes = UserDefaults.standard.array(forKey: "qodex_build_times") as? [Double] ?? []
        buildTimes.append(duration)
        if buildTimes.count > 20 { buildTimes.removeFirst() }
        UserDefaults.standard.set(buildTimes, forKey: "qodex_build_times")
    }
    
    func averageBuildTime() -> TimeInterval {
        let buildTimes = UserDefaults.standard.array(forKey: "qodex_build_times") as? [Double] ?? []
        guard !buildTimes.isEmpty else { return 0 }
        return buildTimes.reduce(0, +) / Double(buildTimes.count)
    }
}

// MARK: - Usage Example
extension BuildConfiguration {
    static func printCurrentConfiguration() {
        let config = BuildConfiguration.current
        print("Build Configuration: \(config)")
        print("Swift Flags: \(config.swiftCompilerFlags.joined(separator: ", "))")
        print("Average Build Time: \(String(format: "%.1f", BuildAnalytics.shared.averageBuildTime()))s")
    }
}
