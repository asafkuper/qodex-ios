// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QodeX",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        // Firebase
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // RevenueCat
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0"),
        
        // Google Sign In
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        
        // UI
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "QodeX",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            path: "QodeX"
        )
    ]
)
