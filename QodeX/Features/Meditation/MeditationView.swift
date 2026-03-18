import SwiftUI
import AVFoundation
import Combine

// MARK: - Color Palette
extension Color {
    static let goldAccent = Color(hex: "#E5C158")
    static let glassWhite = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.25)
    static let deepIndigo = Color(hex: "#1a1a2e")
    static let softPurple = Color(hex: "#4a4a6a")
    static let calmingTeal = Color(hex: "#2d5a5a")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Data Models
struct MeditationCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let count: Int
}

struct MeditationSession: Identifiable {
    let id = UUID()
    let title: String
    let duration: TimeInterval
    let category: String
    let numerologyNumber: Int
    let imageName: String
    let description: String
}

struct SessionHistory: Identifiable {
    let id = UUID()
    let session: MeditationSession
    let completedDate: Date
    let durationListened: TimeInterval
}

// MARK: - View Model
class MeditationViewModel: ObservableObject {
    @Published var selectedCategory: String? = nil
    @Published var currentSession: MeditationSession? = nil
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var isShowingPlayer = false
    @Published var selectedBackgroundSound: BackgroundSound = .none
    @Published var breathingPhase: BreathingPhase = .inhale
    @Published var sessionHistory: [SessionHistory] = []
    
    var timer: Timer?
    var breathingTimer: Timer?
    
    let categories: [MeditationCategory] = [
        MeditationCategory(name: "Focus", icon: "target", color: .goldAccent, count: 12),
        MeditationCategory(name: "Sleep", icon: "moon.fill", color: .indigo, count: 8),
        MeditationCategory(name: "Anxiety", icon: "heart.fill", color: .pink, count: 15),
        MeditationCategory(name: "Stress", icon: "wind", color: .cyan, count: 10),
        MeditationCategory(name: "Energy", icon: "bolt.fill", color: .orange, count: 6),
        MeditationCategory(name: "Balance", icon: "scale.3d", color: .green, count: 9)
    ]
    
    let featuredSessions: [MeditationSession] = [
        MeditationSession(
            title: "Numerology Path 7",
            duration: 900,
            category: "Focus",
            numerologyNumber: 7,
            imageName: "meditation_7",
            description: "Deep introspection for spiritual seekers born under number 7"
        ),
        MeditationSession(
            title: "Life Path 3 Creative Flow",
            duration: 600,
            category: "Energy",
            numerologyNumber: 3,
            imageName: "meditation_3",
            description: "Unlock your creative potential with this expressive meditation"
        ),
        MeditationSession(
            title: "Master Number 11",
            duration: 1200,
            category: "Balance",
            numerologyNumber: 11,
            imageName: "meditation_11",
            description: "Connect with your higher purpose and spiritual intuition"
        )
    ]
    
    var filteredSessions: [MeditationSession] {
        if let category = selectedCategory {
            return featuredSessions.filter { $0.category == category }
        }
        return featuredSessions
    }
    
    func startSession(_ session: MeditationSession) {
        currentSession = session
        currentTime = 0
        isPlaying = true
        isShowingPlayer = true
        startTimer()
        startBreathingAnimation()
    }
    
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
            startBreathingAnimation()
        } else {
            timer?.invalidate()
            breathingTimer?.invalidate()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentTime < (self.currentSession?.duration ?? 0) {
                self.currentTime += 1
            } else {
                self.completeSession()
            }
        }
    }
    
    func startBreathingAnimation() {
        breathingTimer?.invalidate()
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 4)) {
                switch self.breathingPhase {
                case .inhale: self.breathingPhase = .hold
                case .hold: self.breathingPhase = .exhale
                case .exhale: self.breathingPhase = .inhale
                }
            }
        }
    }
    
    func completeSession() {
        timer?.invalidate()
        breathingTimer?.invalidate()
        isPlaying = false
        
        if let session = currentSession {
            let history = SessionHistory(
                session: session,
                completedDate: Date(),
                durationListened: currentTime
            )
            sessionHistory.insert(history, at: 0)
        }
    }
    
    func skipForward() {
        currentTime = min(currentTime + 15, currentSession?.duration ?? 0)
    }
    
    func skipBackward() {
        currentTime = max(currentTime - 15, 0)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum BreathingPhase {
    case inhale, hold, exhale
}

enum BackgroundSound: String, CaseIterable {
    case none = "None"
    case rain = "Rain"
    case ocean = "Ocean"
    case forest = "Forest"
    case whiteNoise = "White Noise"
    
    var icon: String {
        switch self {
        case .none: return "speaker.slash.fill"
        case .rain: return "cloud.rain.fill"
        case .ocean: return "water.waves"
        case .forest: return "leaf.fill"
        case .whiteNoise: return "waveform"
        }
    }
}

// MARK: - Main View
struct MeditationView: View {
    @StateObject private var viewModel = MeditationViewModel()
    
    var body: some View {
        ZStack {
            // Deep gradient background
            LinearGradient(
                colors: [
                    Color.deepIndigo,
                    Color.softPurple,
                    Color(hex: "#0f0f23")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    headerView
                    
                    // Featured Card
                    featuredCardView
                    
                    // Categories Grid
                    categoriesGridView
                    
                    // Session History
                    if !viewModel.sessionHistory.isEmpty {
                        historyView
                    }
                    
                    // Background Sounds
                    backgroundSoundsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Now Playing Overlay
            if viewModel.isShowingPlayer {
                NowPlayingView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Find Your Center")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Guided by numerology, tailored for you")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Profile avatar with glass effect
            Button(action: {
                // Profile action
            }) {
                ZStack {
                    Circle()
                        .fill(Color.glassWhite)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.goldAccent)
                }
            }
            .accessibilityLabel("Profile")
            .accessibilityHint("Open your profile settings")
        }
    }
    
    // MARK: - Featured Card
    private var featuredCardView: some View {
        ZStack {
            // Glass card background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.goldAccent.opacity(0.3),
                            Color.goldAccent.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.goldAccent.opacity(0.6), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            VStack(alignment: .leading, spacing: 16) {
                // Badge
                HStack {
                    Text("FEATURED")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.goldAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.goldAccent.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.goldAccent.opacity(0.4), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                    
                    // Numerology number badge
                    ZStack {
                        Circle()
                            .fill(Color.goldAccent.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Text("\(viewModel.featuredSessions.first?.numerologyNumber ?? 7)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.goldAccent)
                    }
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.featuredSessions.first?.title ?? "")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.featuredSessions.first?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                
                // Duration and play button
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.goldAccent)
                        
                        Text(viewModel.formatTime(viewModel.featuredSessions.first?.duration ?? 0))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let session = viewModel.featuredSessions.first {
                            viewModel.startSession(session)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.deepIndigo)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.goldAccent, Color(hex: "#d4a84a")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.goldAccent.opacity(0.4), radius: 15, x: 0, y: 5)
                    }
                    .accessibilityLabel("Start featured meditation")
                    .accessibilityHint("Begin playing \(viewModel.featuredSessions.first?.title ?? "the featured session")")
                }
            }
            .padding(20)
        }
        .frame(height: 240)
    }
    
    // MARK: - Categories Grid
    private var categoriesGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.categories) { category in
                    CategoryCard(category: category, isSelected: viewModel.selectedCategory == category.name) {
                        withAnimation(.spring()) {
                            if viewModel.selectedCategory == category.name {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category.name
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - History View
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Sessions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.sessionHistory.count) completed")
                    .font(.caption)
                    .foregroundColor(.goldAccent)
            }
            
            ForEach(viewModel.sessionHistory.prefix(3)) { history in
                HistoryRow(history: history, formatTime: viewModel.formatTime)
            }
        }
    }
    
    // MARK: - Background Sounds
    private var backgroundSoundsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Background Sounds")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BackgroundSound.allCases, id: \.self) { sound in
                        BackgroundSoundButton(
                            sound: sound,
                            isSelected: viewModel.selectedBackgroundSound == sound
                        ) {
                            withAnimation(.spring()) {
                                viewModel.selectedBackgroundSound = sound
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: MeditationCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? category.color.opacity(0.3) : Color.glassWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? category.color : Color.glassBorder, lineWidth: isSelected ? 2 : 1)
                        )
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? category.color : .white)
                }
                .frame(height: 60)
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? category.color : .white.opacity(0.8))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(category.name) category")
        .accessibilityHint(isSelected ? "Double tap to deselect" : "Double tap to filter sessions by \(category.name)")
        .accessibilityState(isSelected ? "selected" : "")
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let history: SessionHistory
    let formatTime: (TimeInterval) -> String
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.glassWhite, lineWidth: 3)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: CGFloat(history.durationListened / history.session.duration))
                    .stroke(Color.goldAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundColor(.goldAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(history.session.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(formatTime(history.durationListened)) • \(history.session.category)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(history.completedDate, style: .date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.glassWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Background Sound Button
struct BackgroundSoundButton: View {
    let sound: BackgroundSound
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.goldAccent.opacity(0.3) : Color.glassWhite)
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.goldAccent : Color.glassBorder, lineWidth: isSelected ? 2 : 1)
                        )
                    
                    Image(systemName: sound.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color.goldAccent : .white.opacity(0.8))
                }
                
                Text(sound.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundColor(isSelected ? Color.goldAccent : .white.opacity(0.7))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(sound.rawValue) background sound")
        .accessibilityHint(isSelected ? "Double tap to turn off background sound" : "Double tap to enable \(sound.rawValue) background sound")
    }
}

// MARK: - Now Playing View
struct NowPlayingView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            // Gradient overlay
            RadialGradient(
                colors: [
                    Color.goldAccent.opacity(0.15),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // Breathing animation circle
                BreathingAnimationView(
                    phase: viewModel.breathingPhase,
                    isPlaying: viewModel.isPlaying
                )
                .frame(height: 280)
                
                // Session info
                VStack(spacing: 8) {
                    Text(viewModel.currentSession?.title ?? "")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Life Path \(viewModel.currentSession?.numerologyNumber ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.goldAccent)
                    
                    Text(viewModel.currentSession?.description ?? "")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.goldAccent, Color(hex: "#d4a84a")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: CGFloat(viewModel.currentTime / (viewModel.currentSession?.duration ?? 1)) * geometry.size.width,
                                    height: 6
                                )
                            
                            // Progress knob
                            Circle()
                                .fill(Color.goldAccent)
                                .frame(width: 16, height: 16)
                                .shadow(color: Color.goldAccent.opacity(0.5), radius: 10, x: 0, y: 0)
                                .offset(
                                    x: CGFloat(viewModel.currentTime / (viewModel.currentSession?.duration ?? 1)) * geometry.size.width - 8
                                )
                        }
                    }
                    .frame(height: 16)
                    
                    HStack {
                        Text(viewModel.formatTime(viewModel.currentTime))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(viewModel.formatTime((viewModel.currentSession?.duration ?? 0) - viewModel.currentTime))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 30)
                
                // Controls
                HStack(spacing: 40) {
                    // Skip backward
                    PlayerControlButton(icon: "gobackward.15", size: 28) {
                        viewModel.skipBackward()
                    }
                    .accessibilityLabel("Skip backward 15 seconds")
                    .accessibilityHint("Rewind the meditation by 15 seconds")
                    
                    // Play/Pause
                    Button(action: { viewModel.togglePlayback() }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.goldAccent, Color(hex: "#d4a84a")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.goldAccent.opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.deepIndigo)
                        }
                    }
                    .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
                    .accessibilityHint(viewModel.isPlaying ? "Pause the meditation" : "Resume the meditation")
                    
                    // Skip forward
                    PlayerControlButton(icon: "goforward.15", size: 28) {
                        viewModel.skipForward()
                    }
                    .accessibilityLabel("Skip forward 15 seconds")
                    .accessibilityHint("Fast forward the meditation by 15 seconds")
                }
                
                // Background sound selector
                HStack(spacing: 20) {
                    ForEach(BackgroundSound.allCases.prefix(4), id: \.self) { sound in
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.selectedBackgroundSound = sound
                            }
                        }) {
                            Image(systemName: sound.icon)
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.selectedBackgroundSound == sound ? Color.goldAccent : .white.opacity(0.5))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(viewModel.selectedBackgroundSound == sound ? Color.goldAccent.opacity(0.2) : Color.clear)
                                )
                        }
                        .accessibilityLabel("\(sound.rawValue) background sound")
                        .accessibilityHint(viewModel.selectedBackgroundSound == sound ? "Currently selected, double tap to deselect" : "Double tap to enable \(sound.rawValue) background sound")
                    }
                }
                
                Spacer()
                
                // Close button
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.isShowingPlayer = false
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.glassWhite)
                                .overlay(
                                    Circle()
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                }
                .padding(.bottom, 30)
                .accessibilityLabel("Close player")
                .accessibilityHint("Close the meditation player and return to the meditation list")
            }
        }
    }
}

// MARK: - Player Control Button
struct PlayerControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.glassWhite)
                        .overlay(
                            Circle()
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Breathing Animation View
struct BreathingAnimationView: View {
    let phase: BreathingPhase
    let isPlaying: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        Color.goldAccent.opacity(0.3 - Double(index) * 0.08),
                        lineWidth: 2
                    )
                    .frame(width: 150 + CGFloat(index) * 40, height: 150 + CGFloat(index) * 40)
                    .scaleEffect(scale)
                    .opacity(opacity - Double(index) * 0.15)
            }
            
            // Main breathing circle
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.goldAccent.opacity(0.4),
                                Color.goldAccent.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.goldAccent, Color.goldAccent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.goldAccent.opacity(0.5), radius: 20, x: 0, y: 0)
                
                // Breathing text
                VStack(spacing: 4) {
                    Text(breathingText)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("\(Int(breathingTimer))s")
                        .font(.caption)
                        .foregroundColor(.goldAccent)
                }
            }
            .scaleEffect(scale)
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: phase) { _ in
            updateAnimation()
        }
        .onChange(of: isPlaying) { playing in
            if playing {
                startAnimation()
            }
        }
    }
    
    private var breathingText: String {
        switch phase {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        }
    }
    
    private var breathingTimer: CGFloat {
        switch phase {
        case .inhale: return 4
        case .hold: return 4
        case .exhale: return 4
        }
    }
    
    private func startAnimation() {
        updateAnimation()
    }
    
    private func updateAnimation() {
        withAnimation(.easeInOut(duration: 4)) {
            switch phase {
            case .inhale:
                scale = 1.3
                opacity = 1.0
            case .hold:
                scale = 1.3
                opacity = 0.8
            case .exhale:
                scale = 1.0
                opacity = 0.6
            }
        }
    }
}

// MARK: - Preview
struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationView()
            .preferredColorScheme(.dark)
    }
}
