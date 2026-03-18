//
//  QodeXWatchApp.swift
//  watchOS companion app
//

import SwiftUI

@main
struct QodeXWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
    }
}

class WatchDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Setup watch connectivity
        WatchConnectivityManager.shared.setup()
    }
}

// MARK: - Root View
struct WatchRootView: View {
    @StateObject private var viewModel = WatchViewModel()
    
    var body: some View {
        TabView {
            DailyNumberView()
                .tabItem {
                    Label("Today", systemImage: "number.circle")
                }
            
            QuickMeditationView()
                .tabItem {
                    Label("Meditate", systemImage: "sparkles")
                }
            
            StreakView()
                .tabItem {
                    Label("Streak", systemImage: "flame")
                }
        }
    }
}

// MARK: - Daily Number View
struct DailyNumberView: View {
    @State private var dailyNumber = 7
    @State private var vibe = "Spiritual Growth"
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Today's Number")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(dailyNumber)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.gold)
            
            Text(vibe)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("View on iPhone") {
                // Handoff to iPhone
            }
            .buttonStyle(.borderedProminent)
            .tint(.gold)
        }
        .padding()
        .onAppear {
            loadDailyNumber()
        }
    }
    
    private func loadDailyNumber() {
        // Get from WatchConnectivity or calculate locally
        let calculator = NumerologyCalculator()
        dailyNumber = calculator.calculateDailyNumber(for: Date())
    }
}

// MARK: - Quick Meditation View
struct QuickMeditationView: View {
    @State private var isMeditating = false
    @State private var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if isMeditating {
                // Meditation in progress
                ZStack {
                    Circle()
                        .stroke(Color.gold.opacity(0.3), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / 60)
                        .stroke(Color.gold, lineWidth: 8)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(timeRemaining)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
                
                Button("Stop") {
                    isMeditating = false
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                // Selection
                Text("Quick Meditation")
                    .font(.headline)
                
                List {
                    Button("1 Minute") { startMeditation(seconds: 60) }
                    Button("3 Minutes") { startMeditation(seconds: 180) }
                    Button("5 Minutes") { startMeditation(seconds: 300) }
                }
            }
        }
        .onReceive(timer) { _ in
            if isMeditating && timeRemaining > 0 {
                timeRemaining -= 1
                
                // Haptic feedback every 10 seconds
                if timeRemaining % 10 == 0 {
                    WKInterfaceDevice.current().play(.click)
                }
            } else if timeRemaining == 0 {
                isMeditating = false
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
    
    private func startMeditation(seconds: Int) {
        timeRemaining = seconds
        isMeditating = true
    }
}

// MARK: - Streak View
struct StreakView: View {
    @State private var streak = 7
    @State private var weeklyProgress: [Bool] = [true, true, true, true, true, false, false]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("\(streak)")
                    .font(.system(size: 40, weight: .bold))
                
                Text("day streak")
                    .font(.caption)
            }
            
            // Weekly circles
            HStack(spacing: 4) {
                ForEach(0..<7) { index in
                    Circle()
                        .fill(weeklyProgress[index] ? Color.gold : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            
            Spacer()
            
            if !weeklyProgress[5] {
                Button("Check In") {
                    // Record check-in
                }
                .buttonStyle(.borderedProminent)
                .tint(.gold)
            }
        }
        .padding()
    }
}

// MARK: - Watch Complication
struct QodeXComplicationView: View {
    @State private var dailyNumber = 7
    
    var body: some View {
        Text("\(dailyNumber)")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.gold)
    }
}

// MARK: - Watch ViewModel
class WatchViewModel: ObservableObject {
    @Published var dailyNumber = 0
    @Published var vibe = ""
    @Published var streak = 0
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Load from WatchConnectivity
        let calculator = NumerologyCalculator()
        dailyNumber = calculator.calculateDailyNumber(for: Date())
    }
}

// MARK: - Watch Connectivity
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    
    func setup() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // Receive data from iPhone
        DispatchQueue.main.async {
            if let number = userInfo["dailyNumber"] as? Int {
                // Update UI
            }
        }
    }
}

import WatchConnectivity
