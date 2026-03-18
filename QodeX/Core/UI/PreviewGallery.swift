//
//  PreviewGallery.swift
//  SwiftUI Preview Gallery for Development
//  Shows all major UI components in one place
//

import SwiftUI

struct PreviewGallery: View {
    var body: some View {
        NavigationView {
            List {
                Section("Core Components") {
                    NavigationLink("Buttons") { ButtonGallery() }
                    NavigationLink("Cards") { CardGallery() }
                    NavigationLink("Typography") { TypographyGallery() }
                    NavigationLink("Colors") { ColorGallery() }
                }
                
                Section("Main Screens") {
                    NavigationLink("Main Tab") { MainTabView() }
                    NavigationLink("Chart") { ChartView() }
                    NavigationLink("Daily Qode") { DailyQodeView() }
                    NavigationLink("Paywall") { PaywallView() }
                }
                
                Section("Accessibility") {
                    NavigationLink("Dynamic Type") { DynamicTypeGallery() }
                    NavigationLink("Accessibility Labels") { AccessibilityGallery() }
                }
                
                Section("Animations") {
                    NavigationLink("Haptics") { HapticGallery() }
                    NavigationLink("Transitions") { TransitionGallery() }
                    NavigationLink("Loading States") { LoadingGallery() }
                }
                
                Section("Form Inputs") {
                    NavigationLink("Text Fields") { TextFieldGallery() }
                    NavigationLink("Pickers") { PickerGallery() }
                    NavigationLink("Toggles") { ToggleGallery() }
                }
            }
            .navigationTitle("Preview Gallery")
        }
    }
}

// MARK: - Component Galleries

struct ButtonGallery: View {
    var body: some View {
        VStack(spacing: 20) {
            QXButton(title: "Primary Button", icon: "star.fill", style: .gold) {}
            QXButton(title: "Secondary", icon: nil, style: .ghost) {}
            QXButton(title: "Loading...", icon: nil, style: .gold) {}
                .disabled(true)
            
            AccessibleButton(
                title: "Accessible Button",
                icon: "hand.tap.fill",
                accessibilityLabel: "Tap to continue",
                action: {}
            )
        }
        .padding()
        .navigationTitle("Buttons")
    }
}

struct CardGallery: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    VStack(alignment: .leading) {
                        Text("Glass Card")
                            .font(.headline)
                        Text("With frosted glass effect")
                            .font(.caption)
                    }
                }
                
                AccessibleCard(
                    title: "Accessible Card",
                    accessibilityLabel: "Your daily numerology reading"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Life Path: 7")
                            .font(.title2)
                        Text("The Seeker - Spiritual and analytical")
                            .font(.body)
                    }
                }
                
                // Number display cards
                NumberDisplay(number: 7, label: "Life Path", isHighlighted: true)
                NumberDisplay(number: 3, label: "Expression", isHighlighted: false)
            }
            .padding()
        }
        .navigationTitle("Cards")
    }
}

struct TypographyGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Display Large")
                        .font(QXFont.displayLarge)
                    Text("Display")
                        .font(QXFont.display)
                    Text("Headline")
                        .font(QXFont.headline)
                    Text("Title 1")
                        .font(QXFont.title1)
                    Text("Title 2")
                        .font(QXFont.title2)
                }
                
                Group {
                    Text("Body")
                        .font(QXFont.body)
                    Text("Body Small")
                        .font(QXFont.bodySmall)
                    Text("Caption")
                        .font(QXFont.caption)
                }
                
                Group {
                    Text("Scalable Title")
                        .textScale(.title)
                    Text("Scalable Body")
                        .textScale(.body)
                    Text("Scalable Caption")
                        .textScale(.caption)
                }
            }
            .padding()
        }
        .navigationTitle("Typography")
    }
}

struct ColorGallery: View {
    let colors: [(String, Color)] = [
        ("Cosmic Black", QXColor.cosmicBlack),
        ("Deep Void", QXColor.deepVoid),
        ("Starlight", QXColor.starlight),
        ("Gold", QXColor.gold),
        ("Gold Muted", QXColor.goldMuted),
        ("Cosmic Purple", QXColor.cosmicPurple),
        ("Mystic Purple", QXColor.mysticPurple),
        ("Cosmic Teal", QXColor.cosmicTeal),
        ("Nebula Blue", QXColor.nebulaBlue)
    ]
    
    var body: some View {
        List(colors, id: \.0) { name, color in
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 60, height: 60)
                
                Text(name)
                    .font(.body)
                
                Spacer()
            }
        }
        .navigationTitle("Colors")
    }
}

struct DynamicTypeGallery: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Current Size: \(String(describing: dynamicTypeSize))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Group {
                    Text("Title (Scaled)")
                        .textScale(.title)
                    
                    Text("Body text that scales with Dynamic Type settings for better accessibility")
                        .textScale(.body)
                    
                    Text("Caption text")
                        .textScale(.caption)
                }
                
                Divider()
                
                AccessibleButton(
                    title: "Scaled Button",
                    icon: "star.fill",
                    accessibilityLabel: "Rate this",
                    action: {}
                )
                
                AccessibleCard(
                    title: "Scaled Card",
                    accessibilityLabel: "Test card"
                ) {
                    Text("This card and its contents scale with Dynamic Type settings")
                        .textScale(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Dynamic Type")
    }
}

struct AccessibilityGallery: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Accessibility Labels Demo")
                    .font(.headline)
                
                // Good example
                VStack(alignment: .leading) {
                    Text("✅ Good: Descriptive label")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                    }
                    .accessibilityLabel("Add to favorites")
                    .accessibilityHint("Double tap to save this reading")
                }
                
                // Accessible container
                AccessibleContainer(
                    accessibilityLabel: "Daily numerology reading",
                    accessibilityHint: "Swipe up to read more"
                ) {
                    VStack(alignment: .leading) {
                        Text("Life Path 7")
                            .font(.headline)
                        Text("Today brings spiritual insights")
                            .font(.body)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Accessibility")
    }
}

struct HapticGallery: View {
    var body: some View {
        List {
            Section("Standard") {
                Button("Light Impact") { QXHaptic.tap(style: .light) }
                Button("Medium Impact") { QXHaptic.tap(style: .medium) }
                Button("Heavy Impact") { QXHaptic.tap(style: .heavy) }
            }
            
            Section("Premium") {
                Button("Sacred Pattern") { QXHaptic.tap(style: .sacred) }
                Button("Celestial") { QXHaptic.tap(style: .celestial) }
                Button("Premium Success") { QXHaptic.premiumSuccess() }
            }
            
            Section("Milestones") {
                Button("7-Day Streak") { QXHaptic.streakMilestone(7) }
                Button("30-Day Streak") { QXHaptic.streakMilestone(30) }
                Button("100-Day Streak") { QXHaptic.streakMilestone(100) }
            }
        }
        .navigationTitle("Haptics")
    }
}

struct TransitionGallery: View {
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            if !showDetail {
                Button("Show Detail") {
                    withAnimation(.spring()) {
                        showDetail = true
                    }
                }
            } else {
                VStack {
                    Text("Detail View")
                        .font(.title)
                    
                    Button("Dismiss") {
                        withAnimation(.spring()) {
                            showDetail = false
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .navigationTitle("Transitions")
    }
}

struct LoadingGallery: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Activity indicator
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            // Skeleton loading
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .frame(width: 200)
            }
            .opacity(isLoading ? 0.6 : 1)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isLoading)
            
            Button(isLoading ? "Stop Loading" : "Start Loading") {
                isLoading.toggle()
            }
        }
        .padding()
        .navigationTitle("Loading")
    }
}

struct TextFieldGallery: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var number = ""
    
    var body: some View {
        Form {
            Section("Standard") {
                TextField("Name", text: $text1)
                TextField("Email", text: $text2)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }
            
            Section("Number") {
                TextField("Life Path Number", text: $number)
                    .keyboardType(.numberPad)
            }
            
            Section("Secure") {
                SecureField("Password", text: $text1)
            }
        }
        .navigationTitle("Text Fields")
    }
}

struct PickerGallery: View {
    @State private var selectedNumber = 7
    @State private var selectedDate = Date()
    
    var body: some View {
        Form {
            Section("Number Picker") {
                Picker("Life Path", selection: $selectedNumber) {
                    ForEach(1...<10) { number in
                        Text("\(number)").tag(number)
                    }
                }
            }
            
            Section("Date Picker") {
                DatePicker("Birth Date", selection: $selectedDate, displayedComponents: .date)
            }
        }
        .navigationTitle("Pickers")
    }
}

struct ToggleGallery: View {
    @State private var isOn1 = true
    @State private var isOn2 = false
    
    var body: some View {
        Form {
            Toggle("Notifications", isOn: $isOn1)
            Toggle("Dark Mode", isOn: $isOn2)
        }
        .navigationTitle("Toggles")
    }
}

// MARK: - Preview
#Preview("Preview Gallery") {
    PreviewGallery()
}
