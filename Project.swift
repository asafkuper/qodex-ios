//
//  Project.swift
//  QodeX iOS Project Configuration
//  Use with Tuist or XcodeGen for automated project generation
//

import ProjectDescription

let project = Project(
    name: "QodeX",
    organizationName: "QodeX Academy",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
            "ENABLE_BITCODE": "NO",
            "ENABLE_TESTING_SEARCH_PATHS": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
            // Build optimizations
            "SWIFT_OPTIMIZATION_LEVEL": "-O",
            "SWIFT_COMPILATION_MODE": "wholemodule",
            "ENABLE_DEAD_CODE_STRIPPING": "YES",
            "GCC_OPTIMIZATION_LEVEL": "s", // Size optimization
            "LLVM_LTO": "YES", // Link-time optimization
            // Security
            "ENABLE_BITCODE": "NO",
            "VALIDATE_WORKSPACE": "YES",
        ],
        debug: .debug(
            name: "Debug",
            settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                "SWIFT_COMPILATION_MODE": "singlefile",
                "GCC_OPTIMIZATION_LEVEL": "0",
                "LLVM_LTO": "NO",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
                "ENABLE_TESTABILITY": "YES",
            ]
        ),
        release: .release(
            name: "Release",
            settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-O",
                "SWIFT_COMPILATION_MODE": "wholemodule",
                "GCC_OPTIMIZATION_LEVEL": "s",
                "LLVM_LTO": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "RELEASE",
                "VALIDATE_PRODUCT": "YES",
            ]
        )
    ),
    targets: [
        // Main App Target
        Target(
            name: "QodeX",
            platform: .iOS,
            product: .app,
            bundleId: "academy.qodex.app",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [.iphone, .ipad]),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false
                ],
                "UIUserInterfaceStyle": "Dark",
                "ITSAppUsesNonExemptEncryption": false,
                "NSUserTrackingUsageDescription": "This identifier will be used to deliver personalized ads.",
                "UIBackgroundModes": ["fetch", "remote-notification"]
            ]),
            sources: ["QodeX/**"],
            resources: ["QodeX/Resources/**"],
            dependencies: [
                // Firebase
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebaseStorage"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseCrashlytics"),
                
                // RevenueCat
                .external(name: "RevenueCat"),
                
                // Google Sign In
                .external(name: "GoogleSignIn"),
                
                // UI
                .external(name: "Lottie"),
                .external(name: "Kingfisher"),
                
                // Networking
                .external(name: "Alamofire"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "CODE_SIGN_IDENTITY": "iPhone Developer",
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
                    "ENABLE_BITCODE": "NO",
                ]
            )
        ),
        
        // Unit + Integration Tests Target
        Target(
            name: "QodeXTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "academy.qodex.app.tests",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: ["Tests/Resources/**"],
            dependencies: [
                .target(name: "QodeX"),
                .external(name: "FirebaseFirestore"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "CODE_SIGN_IDENTITY": "iPhone Developer",
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
                    "ENABLE_TESTING_SEARCH_PATHS": "YES",
                    "SWIFT_TESTING_ENABLED": "YES",
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG TESTING",
                ]
            )
        ),
        
        // UI Tests Target
        Target(
            name: "QodeXUITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "academy.qodex.app.uitests",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/UI/**"],
            dependencies: [
                .target(name: "QodeX")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "CODE_SIGN_IDENTITY": "iPhone Developer",
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
                ]
            )
        )
    ],
    schemes: [
        // Main App Scheme
        Scheme(
            name: "QodeX",
            buildAction: .buildAction(targets: ["QodeX"]),
            testAction: .testAction(
                targets: ["QodeXTests"],
                arguments: .init(environment: ["TESTING": "1"], launch: [:]),
                configuration: .debug,
                attachDebugger: true
            ),
            runAction: .runAction(configuration: .debug),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),
        
        // Unit Tests Scheme
        Scheme(
            name: "QodeXTests",
            buildAction: .buildAction(targets: ["QodeX", "QodeXTests"]),
            testAction: .testAction(
                targets: ["QodeXTests"],
                arguments: .init(
                    environment: [
                        "TESTING": "1",
                        "FIRESTORE_EMULATOR_HOST": "localhost:8080"
                    ],
                    launch: [:]
                ),
                configuration: .debug,
                coverage: true,
                codeCoverageTargets: ["QodeX"],
                attachDebugger: true
            )
        ),
        
        // UI Tests Scheme
        Scheme(
            name: "QodeXUITests",
            buildAction: .buildAction(targets: ["QodeX", "QodeXUITests"]),
            testAction: .testAction(
                targets: ["QodeXUITests"],
                arguments: .init(environment: ["TESTING": "1"], launch: [:]),
                configuration: .debug
            )
        )
    ],
    additionalFiles: [
        "README.md",
        "LICENSE",
        "QodeX.xctestplan",
        "fastlane/**",
        "scripts/**"
    ]
)

// MARK: - Test Plan Configurations

extension TestPlan {
    static let unitTestPlan = TestPlan(
        path: "QodeX.xctestplan",
        testTargets: ["QodeXTests"]
    )
}