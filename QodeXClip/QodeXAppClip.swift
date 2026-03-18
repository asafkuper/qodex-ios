//
//  QodeXAppClip.swift
//  Lightweight app clip for instant experiences
//

import SwiftUI

@main
struct QodeXAppClip: App {
    @UIApplicationDelegateAdaptor(AppClipDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppClipRootView()
        }
    }
}

class AppClipDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase for App Clip (limited)
        return true
    }
    
    func application(_ application: UIApplication, 
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Handle App Clip invocation
        if let incomingURL = userActivity.webpageURL {
            return handleAppClipURL(incomingURL)
        }
        return false
    }
    
    private func handleAppClipURL(_ url: URL) -> Bool {
        // Parse App Clip URL
        // https://appclip.qodex.academy/calculate?name=John&date=1990-01-01
        return true
    }
}

// MARK: - App Clip Root View
struct AppClipRootView: View {
    @State private var showFullAppPrompt = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gold)
                    
                    Text("QodeX")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Discover Your Numbers")
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Quick Calculator
                QuickCalculatorCard()
                
                // Sample Reading
                SampleReadingCard()
                
                Spacer()
                
                // Upgrade prompt
                Button(action: { showFullAppPrompt = true }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Get the Full App")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gold)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showFullAppPrompt) {
                    FullAppPromptView()
                }
            }
        }
    }
}

// MARK: - Quick Calculator Card
struct QuickCalculatorCard: View {
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var showResult = false
    @State private var lifePath = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Calculation")
                .font(.headline)
            
            TextField("Your Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
            
            Button(action: calculate) {
                Text("Calculate")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gold)
                    .cornerRadius(12)
            }
            
            if showResult {
                VStack(spacing: 8) {
                    Text("Your Life Path Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(lifePath)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.gold)
                    
                    Text(lifePathDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private var lifePathDescription: String {
        let descriptions: [Int: String] = [
            1: "The Leader - Independent & ambitious",
            2: "The Diplomat - Cooperative & intuitive",
            3: "The Creative - Expressive & optimistic",
            4: "The Builder - Practical & disciplined",
            5: "The Freedom Seeker - Adventurous",
            6: "The Nurturer - Responsible & caring",
            7: "The Seeker - Analytical & spiritual",
            8: "The Powerhouse - Ambitious & authoritative",
            9: "The Humanitarian - Compassionate"
        ]
        return descriptions[lifePath] ?? "Unique path"
    }
    
    private func calculate() {
        let calculator = NumerologyCalculator()
        lifePath = calculator.calculateLifePathNumber(birthDate: birthDate)
        showResult = true
    }
}

// MARK: - Sample Reading Card
struct SampleReadingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sample Daily Reading")
                    .font(.headline)
                
                Spacer()
                
                Text("Today")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gold.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 16) {
                Text("8")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.gold)
                    .frame(width: 60, height: 60)
                    .background(Color.gold.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Power & Abundance")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("A day for financial decisions and taking charge...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Full App Prompt
struct FullAppPromptView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "app.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gold)
                
                Text("Unlock Everything")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "number.circle.fill", text: "Complete Numerology Chart")
                    FeatureRow(icon: "sparkles", text: "Daily Energy Forecasts")
                    FeatureRow(icon: "person.2.fill", text: "AI Mentorship Matching")
                    FeatureRow(icon: "bubble.left.fill", text: "Spiritual Community")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Personal Growth Tracking")
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    // Open App Store
                    if let url = URL(string: "https://apps.apple.com/app/id123456789") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Download Full App")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gold)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gold)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

// MARK: - App Clip Configuration
/*
 App Clip Entitlements:
 - 10MB size limit
 - No background processing
 - Limited Firebase features
 - No push notifications (can use ephemeral)
 
 Associated Domains:
 - appclips:appclip.qodex.academy
 
 Invocation Methods:
 1. NFC Tags
 2. QR Codes
 3. Safari Banner
 4. Messages
 5. Maps
 */
