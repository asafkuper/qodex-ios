//
//  LiveSessionView.swift
//  QodeX - Premium Live Sessions
//  Reference: Apple Design Award-winning live experiences, iOS 18 Human Interface Guidelines
//

import SwiftUI
import AVKit

// MARK: - Models

/// Represents a live numerology session
struct LiveSession: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let numerologist: Numerologist
    let startTime: Date
    let endTime: Date
    let status: SessionStatus
    let thumbnailURL: String?
    let streamURL: String?
    let participants: Int
    let maxParticipants: Int
    let isPremium: Bool
    let category: SessionCategory
    let price: Double?
    var hasReminder: Bool = false
    var isFavorite: Bool = false
    
    enum SessionStatus: String, CaseIterable {
        case upcoming = "Upcoming"
        case live = "LIVE"
        case ended = "Replay"
        case scheduled = "Scheduled"
        
        var color: Color {
            switch self {
            case .live: return .red
            case .upcoming: return QXColor.gold
            case .ended: return QXColor.nebulaBlue
            case .scheduled: return QXColor.cosmicPurple
            }
        }
        
        var icon: String {
            switch self {
            case .live: return "dot.radiowaves.left.and.right"
            case .upcoming: return "calendar"
            case .ended: return "play.circle"
            case .scheduled: return "bell"
            }
        }
    }
    
    enum SessionCategory: String, CaseIterable {
        case personalReading = "Personal Reading"
        case groupWorkshop = "Group Workshop"
        case masterclass = "Masterclass"
        case qanda = "Q&A Session"
        case meditation = "Guided Meditation"
        
        var icon: String {
            switch self {
            case .personalReading: return "person.fill"
            case .groupWorkshop: return "person.3.fill"
            case .masterclass: return "graduationcap.fill"
            case .qanda: return "questionmark.bubble.fill"
            case .meditation: return "sparkles"
            }
        }
    }
    
    var isLive: Bool { status == .live }
    var isEnded: Bool { status == .ended }
    var duration: TimeInterval { endTime.timeIntervalSince(startTime) }
    
    static let mockSessions: [LiveSession] = [
        LiveSession(
            id: "1",
            title: "Monthly Cosmic Forecast",
            description: "Discover what the numbers reveal for March 2026. Personal insights for all life path numbers.",
            numerologist: Numerologist.mockNumerologists[0],
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(3600),
            status: .live,
            thumbnailURL: nil,
            streamURL: "https://example.com/stream1",
            participants: 1247,
            maxParticipants: 5000,
            isPremium: false,
            category: .groupWorkshop,
            price: nil,
            hasReminder: true
        ),
        LiveSession(
            id: "2",
            title: "Life Path 7 Deep Dive",
            description: "Unlock the mysteries of Life Path 7. Special focus on spiritual growth and intuition.",
            numerologist: Numerologist.mockNumerologists[1],
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            status: .upcoming,
            thumbnailURL: nil,
            streamURL: nil,
            participants: 0,
            maxParticipants: 100,
            isPremium: true,
            category: .masterclass,
            price: 29.99,
            hasReminder: false
        ),
        LiveSession(
            id: "3",
            title: "New Moon Numerology Ritual",
            description: "Harness the power of the new moon with sacred numerology practices.",
            numerologist: Numerologist.mockNumerologists[2],
            startTime: Date().addingTimeInterval(86400),
            endTime: Date().addingTimeInterval(90000),
            status: .scheduled,
            thumbnailURL: nil,
            streamURL: nil,
            participants: 0,
            maxParticipants: 1000,
            isPremium: true,
            category: .meditation,
            price: 19.99,
            hasReminder: true
        ),
        LiveSession(
            id: "4",
            title: "Ask Me Anything: Master Numbers",
            numerologist: Numerologist.mockNumerologists[0],
            startTime: Date().addingTimeInterval(172800),
            endTime: Date().addingTimeInterval(176400),
            status: .scheduled,
            thumbnailURL: nil,
            streamURL: nil,
            participants: 0,
            maxParticipants: 500,
            isPremium: false,
            category: .qanda,
            price: nil,
            hasReminder: false
        ),
        LiveSession(
            id: "5",
            title: "Personal Reading Showcase",
            description: "Watch a live personal numerology reading. Learn by observing real sessions.",
            numerologist: Numerologist.mockNumerologists[1],
            startTime: Date().addingTimeInterval(-86400),
            endTime: Date().addingTimeInterval(-82800),
            status: .ended,
            thumbnailURL: nil,
            streamURL: "https://example.com/replay1",
            participants: 3421,
            maxParticipants: 5000,
            isPremium: false,
            category: .personalReading,
            price: nil,
            hasReminder: false
        )
    ]
}

/// Numerologist profile
struct Numerologist: Identifiable, Equatable {
    let id: String
    let name: String
    let title: String
    let bio: String
    let avatarURL: String?
    let rating: Double
    let reviewCount: Int
    let specialties: [String]
    let isVerified: Bool
    let followerCount: Int
    
    static let mockNumerologists: [Numerologist] = [
        Numerologist(
            id: "1",
            name: "Maya Chen",
            title: "Master Numerologist",
            bio: "20+ years guiding souls through numbers. Specializing in life purpose and career alignment.",
            avatarURL: nil,
            rating: 4.9,
            reviewCount: 2847,
            specialties: ["Life Path", "Career", "Compatibility"],
            isVerified: true,
            followerCount: 125000
        ),
        Numerologist(
            id: "2",
            name: "Jonathan Rivers",
            title: "Spiritual Numerologist",
            bio: "Blending ancient wisdom with modern insights. Expert in master numbers and karmic lessons.",
            avatarURL: nil,
            rating: 4.8,
            reviewCount: 1923,
            specialties: ["Master Numbers", "Karmic Debt", "Soul Urge"],
            isVerified: true,
            followerCount: 89000
        ),
        Numerologist(
            id: "3",
            name: "Priya Sharma",
            title: "Vedic Numerologist",
            bio: "Traditional Vedic numerology meets contemporary life coaching. Transformative sessions.",
            avatarURL: nil,
            rating: 5.0,
            reviewCount: 1567,
            specialties: ["Vedic", "Name Analysis", "Business"],
            isVerified: true,
            followerCount: 67000
        )
    ]
}

/// Chat message model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let userId: String
    let username: String
    let avatarURL: String?
    let message: String
    let timestamp: Date
    let isModerator: Bool
    let isVIP: Bool
    let lifePathNumber: Int?
    
    static let mockMessages: [ChatMessage] = [
        ChatMessage(userId: "1", username: "StarSeeker", avatarURL: nil, message: "This is exactly what I needed to hear today! ✨", timestamp: Date().addingTimeInterval(-300), isModerator: false, isVIP: true, lifePathNumber: 7),
        ChatMessage(userId: "2", username: "NumberWhisperer", avatarURL: nil, message: "Can you talk about 11:11 synchronicities?", timestamp: Date().addingTimeInterval(-240), isModerator: false, isVIP: false, lifePathNumber: 11),
        ChatMessage(userId: "3", username: "Maya Chen", avatarURL: nil, message: "Great question! 11:11 is a powerful gateway...", timestamp: Date().addingTimeInterval(-180), isModerator: true, isVIP: false, lifePathNumber: nil),
        ChatMessage(userId: "4", username: "SoulPath7", avatarURL: nil, message: "Life path 7 checking in! 🙋‍♀️", timestamp: Date().addingTimeInterval(-120), isModerator: false, isVIP: false, lifePathNumber: 7),
        ChatMessage(userId: "5", username: "CosmicWanderer", avatarURL: nil, message: "The energy in this session is incredible", timestamp: Date().addingTimeInterval(-60), isModerator: false, isVIP: true, lifePathNumber: 9),
        ChatMessage(userId: "6", username: "NewBeginnings", avatarURL: nil, message: "Thank you for the guidance Maya! 💫", timestamp: Date().addingTimeInterval(-30), isModerator: false, isVIP: false, lifePathNumber: 1)
    ]
}

// MARK: - View Model

@MainActor
final class LiveSessionViewModel: ObservableObject {
    @Published var sessions: [LiveSession] = []
    @Published var selectedSession: LiveSession?
    @Published var chatMessages: [ChatMessage] = []
    @Published var isInSession = false
    @Published var isChatVisible = true
    @Published var currentTab: LiveTab = .upcoming
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var newMessage = ""
    @Published var reminderSettings = ReminderSettings.default
    @Published var speakerLayout: SpeakerLayout = .grid
    @Published var isFullscreen = false
    
    enum LiveTab: String, CaseIterable {
        case upcoming = "Upcoming"
        case live = "Live Now"
        case replays = "Replays"
        
        var icon: String {
            switch self {
            case .upcoming: return "calendar"
            case .live: return "dot.radiowaves.left.and.right"
            case .replays: return "play.circle"
            }
        }
    }
    
    enum SpeakerLayout {
        case grid      // Multiple speakers in grid
        case spotlight // One main speaker, others small
        case pip       // Picture in picture
    }
    
    init() {
        loadSessions()
        loadMockChat()
    }
    
    func loadSessions() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.sessions = LiveSession.mockSessions
            self?.isLoading = false
        }
    }
    
    func loadMockChat() {
        chatMessages = ChatMessage.mockMessages
    }
    
    func joinSession(_ session: LiveSession) {
        selectedSession = session
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isInSession = true
        }
    }
    
    func leaveSession() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isInSession = false
            selectedSession = nil
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let message = ChatMessage(
            userId: "current",
            username: "You",
            avatarURL: nil,
            message: newMessage,
            timestamp: Date(),
            isModerator: false,
            isVIP: true,
            lifePathNumber: 7
        )
        
        chatMessages.append(message)
        newMessage = ""
    }
    
    func toggleReminder(for session: LiveSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].hasReminder.toggle()
        }
    }
    
    func toggleFavorite(for session: LiveSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].isFavorite.toggle()
        }
    }
    
    func sessions(for tab: LiveTab) -> [LiveSession] {
        switch tab {
        case .upcoming:
            return sessions.filter { $0.status == .upcoming || $0.status == .scheduled }
        case .live:
            return sessions.filter { $0.status == .live }
        case .replays:
            return sessions.filter { $0.status == .ended }
        }
    }
    
    func upcomingSessions(for date: Date) -> [LiveSession] {
        sessions.filter { 
            $0.status == .upcoming || $0.status == .scheduled 
        }.filter {
            Calendar.current.isDate($0.startTime, inSameDayAs: date)
        }
    }
}

// MARK: - Reminder Settings

struct ReminderSettings: Equatable {
    var enabled: Bool
    var minutesBefore: Int
    var pushNotification: Bool
    var emailNotification: Bool
    var calendarSync: Bool
    
    static let `default` = ReminderSettings(
        enabled: true,
        minutesBefore: 15,
        pushNotification: true,
        emailNotification: false,
        calendarSync: true
    )
}

// MARK: - Main View

struct LiveSessionView: View {
    @StateObject private var viewModel = LiveSessionViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isInSession, let session = viewModel.selectedSession {
                LivePlayerView(viewModel: viewModel, session: session)
                    .transition(.move(edge: .bottom))
            } else {
                LiveHubView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.isInSession)
    }
}

// MARK: - Live Hub View (Main Listing)

struct LiveHubView: View {
    @ObservedObject var viewModel: LiveSessionViewModel
    @State private var showingSchedule = false
    @State private var showingReminders = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                QXColor.cosmicBlack.ignoresSafeArea()
                
                // Gradient accents
                GeometryReader { geo in
                    Circle()
                        .fill(QXColor.gold.opacity(0.1))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: -100, y: -100)
                    
                    Circle()
                        .fill(QXColor.cosmicPurple.opacity(0.08))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: geo.size.width - 150, y: geo.size.height * 0.4)
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                        
                        // Live Now Banner (if any live sessions)
                        if !viewModel.sessions(for: .live).isEmpty {
                            liveNowBanner
                        }
                        
                        // Tab selector
                        tabSelector
                            .padding(.top, 24)
                        
                        // Content based on tab
                        contentSection
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSchedule) {
                ScheduleCalendarView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingReminders) {
                ReminderSettingsView(settings: $viewModel.reminderSettings)
            }
        }
    }
    
    // MARK: Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Sessions")
                        .font(QXFont.displayMedium)
                        .foregroundStyle(QXColor.starlight)
                    
                    Text("Connect with master numerologists in real-time")
                        .font(QXFont.body)
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                }
                
                Spacer()
                
                // Calendar/Schedule button
                Button(action: { showingSchedule = true }) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundStyle(QXColor.gold)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(QXColor.deepVoid)
                                .overlay(
                                    Circle()
                                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .pressable()
                
                // Reminder settings button
                Button(action: { showingReminders = true }) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 20))
                        .foregroundStyle(QXColor.gold)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(QXColor.deepVoid)
                                .overlay(
                                    Circle()
                                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .pressable()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: Live Now Banner
    
    private var liveNowBanner: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text("LIVE NOW")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.15))
                )
                
                Spacer()
                
                Text("\(viewModel.sessions(for: .live).count) session\(viewModel.sessions(for: .live).count == 1 ? "" : "s")")
                    .font(QXFont.caption)
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Featured live session
            if let liveSession = viewModel.sessions(for: .live).first {
                LiveSessionCard(session: liveSession, isFeatured: true) {
                    viewModel.joinSession(liveSession)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    // MARK: Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(LiveSessionViewModel.LiveTab.allCases, id: \.self) { tab in
                TabButton(
                    title: tab.rawValue,
                    icon: tab.icon,
                    isSelected: viewModel.currentTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.currentTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: Content Section
    
    @ViewBuilder
    private var contentSection: some View {
        let sessions = viewModel.sessions(for: viewModel.currentTab)
        
        if sessions.isEmpty {
            EmptyStateView(for: viewModel.currentTab)
                .padding(.top, 60)
        } else {
            VStack(spacing: 16) {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    LiveSessionCard(session: session) {
                        viewModel.joinSession(session)
                    }
                    .staggered(index: index, baseDelay: 0.05)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(isSelected ? QXColor.cosmicBlack : QXColor.starlight)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? QXColor.gold : QXColor.deepVoid)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? QXColor.gold : QXColor.starlight.opacity(0.1), lineWidth: 1)
            )
        }
        .pressable()
    }
}

// MARK: - Live Session Card

struct LiveSessionCard: View {
    let session: LiveSession
    var isFeatured: Bool = false
    let onJoin: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onJoin) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail / Video Preview Area
                ZStack(alignment: .topLeading) {
                    // Background gradient
                    LinearGradient(
                        colors: [QXColor.deepVoid, QXColor.sacredGeometry],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: isFeatured ? 200 : 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Decorative elements
                    GeometryReader { geo in
                        Circle()
                            .fill(QXColor.gold.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .blur(radius: 30)
                            .offset(x: geo.size.width - 60, y: -20)
                        
                        // Pattern overlay
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(QXColor.starlight.opacity(0.03))
                            .offset(x: geo.size.width / 2 - 40, y: 30)
                    }
                    
                    // Status Badge
                    HStack(spacing: 6) {
                        if session.status == .live {
                            LivePulsingDot()
                        }
                        Image(systemName: session.status.icon)
                            .font(.system(size: 12))
                        Text(session.status.rawValue)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(session.status == .live ? .red : QXColor.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        GlassCapsule()
                    )
                    .padding(12)
                    
                    // Premium badge
                    if session.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                            Text("PREMIUM")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(QXColor.cosmicBlack)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(QXColor.gold)
                        )
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                    
                    // Category icon
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: session.category.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(QXColor.gold)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(QXColor.cosmicBlack.opacity(0.8))
                                        .overlay(
                                            Circle()
                                                .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(12)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    // Title & Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(QXColor.starlight)
                            .lineLimit(2)
                        
                        Text(session.category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(QXColor.gold)
                    }
                    
                    // Description
                    if let description = session.description {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(QXColor.starlight.opacity(0.6))
                            .lineLimit(2)
                            .lineSpacing(2)
                    }
                    
                    // Numerologist
                    HStack(spacing: 10) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(QXColor.sacredGeometry)
                                .frame(width: 36, height: 36)
                            
                            Text(String(session.numerologist.name.prefix(1)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(QXColor.gold)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(session.numerologist.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(QXColor.starlight)
                                
                                if session.numerologist.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(QXColor.gold)
                                }
                            }
                            
                            Text(session.numerologist.title)
                                .font(.system(size: 12))
                                .foregroundStyle(QXColor.starlight.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                    
                    // Time & Participants
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(session.startTime, style: .date)
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 12))
                            if session.status == .live {
                                Text("\(session.participants) watching")
                            } else {
                                Text("\(session.maxParticipants) max")
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                        
                        Spacer()
                    }
                    
                    // Join Button
                    HStack(spacing: 12) {
                        Button(action: onJoin) {
                            HStack(spacing: 8) {
                                Image(systemName: session.status == .ended ? "play.fill" : "video.fill")
                                Text(buttonTitle)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(QXColor.cosmicBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                LinearGradient(
                                    colors: [QXColor.gold, QXColor.goldMuted],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .pressable()
                        
                        // Price or Free badge
                        if let price = session.price {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(QXColor.gold)
                                .frame(width: 80, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(QXColor.gold.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        } else {
                            Text("FREE")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(QXColor.cosmicTeal)
                                .frame(width: 60, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(QXColor.cosmicTeal.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QXColor.deepVoid.opacity(0.6))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(QXColor.gold.opacity(isHovered ? 0.4 : 0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(color: .black.opacity(isHovered ? 0.3 : 0.15), radius: isHovered ? 30 : 20, x: 0, y: isHovered ? 15 : 10)
        }
        .buttonStyle(.plain)
        .onHover { hovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovered
            }
        }
    }
    
    private var buttonTitle: String {
        switch session.status {
        case .live: return "Join Live"
        case .upcoming, .scheduled: return "Set Reminder"
        case .ended: return "Watch Replay"
        }
    }
}

// MARK: - Live Pulsing Dot

struct LivePulsingDot: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.3))
                .frame(width: isPulsing ? 16 : 8, height: isPulsing ? 16 : 8)
            
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Glass Capsule

struct GlassCapsule: View {
    var body: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(QXColor.starlight.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let tab: LiveSessionViewModel.LiveTab
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(QXColor.gold.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(QXColor.gold)
            }
            
            Text(title)
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
            
            Text(message)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }
    
    private var icon: String {
        switch tab {
        case .upcoming: return "calendar.badge.clock"
        case .live: return "dot.radiowaves.left.and.right"
        case .replays: return "play.circle"
        }
    }
    
    private var title: String {
        switch tab {
        case .upcoming: return "No Upcoming Sessions"
        case .live: return "No Live Sessions"
        case .replays: return "No Replays Yet"
        }
    }
    
    private var message: String {
        switch tab {
        case .upcoming:
            return "Check back soon for new sessions with our master numerologists."
        case .live:
            return "There are no live sessions at the moment. Browse upcoming sessions to set reminders."
        case .replays:
            return "Past session recordings will appear here. Join live sessions to be part of the experience."
        }
    }
}

// MARK: - Live Player View

struct LivePlayerView: View {
    @ObservedObject var viewModel: LiveSessionViewModel
    let session: LiveSession
    
    @State private var chatOffset: CGFloat = 0
    @State private var isShowingParticipants = false
    @State private var isShowingSettings = false
    
    var body: some View {
        ZStack {
            QXColor.cosmicBlack.ignoresSafeArea()
            
            // Video/Speaker Area
            VStack(spacing: 0) {
                // Main video area with speaker grid
                SpeakerGridView(
                    layout: viewModel.speakerLayout,
                    session: session
                )
                .frame(maxHeight: viewModel.isChatVisible ? nil : .infinity)
                
                // Chat section (collapsible)
                if viewModel.isChatVisible {
                    ChatPanelView(viewModel: viewModel)
                        .frame(height: 300)
                }
            }
            
            // Overlay controls
            VStack {
                // Top controls bar
                playerTopBar
                
                Spacer()
                
                // Bottom controls
                playerBottomBar
            }
            .padding(.top, Device.hasNotch ? 44 : 20)
            .padding(.bottom, Device.hasNotch ? 34 : 20)
        }
        .ignoresSafeArea()
    }
    
    // MARK: Top Bar
    
    private var playerTopBar: some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: { viewModel.leaveSession() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(QXColor.cosmicBlack.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    LivePulsingDot()
                    Text("\(session.participants) watching")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Participants button
            Button(action: { isShowingParticipants = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 14))
                    Text("\(session.participants)")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(QXColor.cosmicBlack.opacity(0.8))
                        .background(.ultraThinMaterial)
                )
            }
            
            // More options
            Button(action: { isShowingSettings = true }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(QXColor.cosmicBlack.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: Bottom Bar
    
    private var playerBottomBar: some View {
        HStack(spacing: 20) {
            // Chat toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.isChatVisible.toggle()
                }
            }) {
                Image(systemName: viewModel.isChatVisible ? "bubble.left.fill" : "bubble.left")
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.isChatVisible ? QXColor.gold : QXColor.starlight)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(QXColor.cosmicBlack.opacity(0.8))
                            .background(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(viewModel.isChatVisible ? QXColor.gold.opacity(0.5) : Color.clear, lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            // Layout toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    switch viewModel.speakerLayout {
                    case .grid: viewModel.speakerLayout = .spotlight
                    case .spotlight: viewModel.speakerLayout = .pip
                    case .pip: viewModel.speakerLayout = .grid
                    }
                }
            }) {
                Image(systemName: layoutIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(QXColor.starlight)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(QXColor.cosmicBlack.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
            }
            
            // Leave button
            Button(action: { viewModel.leaveSession() }) {
                HStack(spacing: 8) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 18))
                    Text("Leave")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var layoutIcon: String {
        switch viewModel.speakerLayout {
        case .grid: return "square.grid.2x2"
        case .spotlight: return "rectangle.inset.filled"
        case .pip: return "pip"
        }
    }
}

// MARK: - Speaker Grid View

struct SpeakerGridView: View {
    let layout: LiveSessionViewModel.SpeakerLayout
    let session: LiveSession
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Main speaker / Video
                switch layout {
                case .grid:
                    gridLayout(size: geo.size)
                case .spotlight:
                    spotlightLayout(size: geo.size)
                case .pip:
                    pipLayout(size: geo.size)
                }
            }
        }
    }
    
    private func gridLayout(size: CGSize) -> some View {
        let columns = session.category == .groupWorkshop ? 2 : 1
        let rows = session.category == .groupWorkshop ? 2 : 1
        
        return VStack(spacing: 8) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<columns, id: \.self) { col in
                        SpeakerCell(
                            numerologist: session.numerologist,
                            isMain: row == 0 && col == 0,
                            size: CGSize(
                                width: (size.width - CGFloat(columns - 1) * 8) / CGFloat(columns),
                                height: (size.height - CGFloat(rows - 1) * 8) / CGFloat(rows)
                            )
                        )
                    }
                }
            }
        }
        .padding(8)
    }
    
    private func spotlightLayout(size: CGSize) -> some View {
        VStack(spacing: 8) {
            // Main speaker - takes most space
            SpeakerCell(
                numerologist: session.numerologist,
                isMain: true,
                size: CGSize(width: size.width - 16, height: size.height * 0.7)
            )
            
            // Secondary speakers in row
            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    SpeakerCell(
                        numerologist: session.numerologist,
                        isMain: false,
                        size: CGSize(width: (size.width - 32) / 3, height: size.height * 0.3 - 16)
                    )
                }
            }
        }
        .padding(8)
    }
    
    private func pipLayout(size: CGSize) -> some View {
        ZStack {
            // Main video area
            SpeakerCell(
                numerologist: session.numerologist,
                isMain: true,
                size: CGSize(width: size.width - 16, height: size.height - 16)
            )
            
            // PIP window
            SpeakerCell(
                numerologist: session.numerologist,
                isMain: false,
                size: CGSize(width: 120, height: 160)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(20)
        }
    }
}

// MARK: - Speaker Cell

struct SpeakerCell: View {
    let numerologist: Numerologist
    let isMain: Bool
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [QXColor.deepVoid, QXColor.sacredGeometry],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative pattern
            VStack(spacing: 20) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(QXColor.gold.opacity(0.2))
                        .frame(width: isMain ? 100 : 50, height: isMain ? 100 : 50)
                    
                    Circle()
                        .stroke(QXColor.gold.opacity(0.3), lineWidth: 2)
                        .frame(width: isMain ? 110 : 55, height: isMain ? 110 : 55)
                    
                    Text(String(numerologist.name.prefix(1)))
                        .font(.system(size: isMain ? 40 : 20, weight: .bold))
                        .foregroundStyle(QXColor.gold)
                }
                
                if isMain {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text(numerologist.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(QXColor.starlight)
                            
                            if numerologist.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(QXColor.gold)
                            }
                        }
                        
                        Text(numerologist.title)
                            .font(.system(size: 14))
                            .foregroundStyle(QXColor.starlight.opacity(0.6))
                    }
                    
                    // Audio indicator
                    AudioVisualizer()
                }
            }
            
            // Speaking indicator border
            if isMain {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(QXColor.gold.opacity(0.3), lineWidth: 2)
            }
            
            // Mute indicator (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(QXColor.gold)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(QXColor.cosmicBlack.opacity(0.8))
                        )
                }
            }
            .padding(12)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Audio Visualizer

struct AudioVisualizer: View {
    @State private var bars: [CGFloat] = [0.3, 0.5, 0.8, 0.6, 0.4]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<bars.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(QXColor.gold)
                    .frame(width: 4, height: 20 * bars[index])
                    .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(Double(index) * 0.1), value: bars[index])
            }
        }
        .frame(height: 20)
        .onAppear {
            // Simulate audio levels
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                bars = bars.map { _ in CGFloat.random(in: 0.2...1.0) }
            }
        }
    }
}

// MARK: - Chat Panel View

struct ChatPanelView: View {
    @ObservedObject var viewModel: LiveSessionViewModel
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Text("Live Chat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("\(viewModel.chatMessages.count) messages")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(QXColor.deepVoid)
            
            Divider()
                .background(QXColor.starlight.opacity(0.1))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.chatMessages) { message in
                            ChatMessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: viewModel.chatMessages.count) { _ in
                    scrollToBottom()
                }
            }
            
            Divider()
                .background(QXColor.starlight.opacity(0.1))
            
            // Input area
            chatInput
        }
        .background(
            QXColor.deepVoid.opacity(0.95)
                .overlay(.ultraThinMaterial)
        )
    }
    
    private func scrollToBottom() {
        if let lastMessage = viewModel.chatMessages.last {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private var chatInput: some View {
        HStack(spacing: 12) {
            // Life path badge
            HStack(spacing: 4) {
                Text("LP: 7")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(QXColor.gold)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(QXColor.gold.opacity(0.15))
            )
            
            TextField("Send a message...", text: $viewModel.newMessage)
                .font(.system(size: 15))
                .foregroundStyle(QXColor.starlight)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(QXColor.sacredGeometry)
                )
            
            Button(action: { viewModel.sendMessage() }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.newMessage.isEmpty ? QXColor.starlight.opacity(0.3) : QXColor.gold)
            }
            .disabled(viewModel.newMessage.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Chat Message Row

struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 32, height: 32)
                
                Text(String(message.username.prefix(1)))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(QXColor.cosmicBlack)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(message.username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(nameColor)
                    
                    if message.isModerator {
                        Text("MOD")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(QXColor.cosmicBlack)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(QXColor.gold)
                            )
                    }
                    
                    if message.isVIP {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(QXColor.gold)
                    }
                    
                    if let lp = message.lifePathNumber {
                        HStack(spacing: 2) {
                            Text("\(lp)")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(QXColor.gold)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .stroke(QXColor.gold.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundStyle(QXColor.starlight.opacity(0.4))
                }
                
                Text(message.message)
                    .font(.system(size: 14))
                    .foregroundStyle(QXColor.starlight.opacity(0.9))
                    .lineSpacing(2)
            }
        }
    }
    
    private var avatarColor: Color {
        if message.isModerator {
            return QXColor.gold
        }
        let colors: [Color] = [QXColor.cosmicPurple, QXColor.nebulaBlue, QXColor.goldMuted]
        return colors[abs(message.userId.hashValue) % colors.count]
    }
    
    private var nameColor: Color {
        if message.isModerator {
            return QXColor.gold
        }
        return QXColor.starlight
    }
}

// MARK: - Schedule Calendar View

struct ScheduleCalendarView: View {
    @ObservedObject var viewModel: LiveSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                QXColor.cosmicBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom calendar header
                    calendarHeader
                    
                    // Days of week
                    daysOfWeekHeader
                    
                    // Calendar grid
                    calendarGrid
                        .padding(.top, 16)
                    
                    Divider()
                        .background(QXColor.starlight.opacity(0.1))
                        .padding(.vertical, 20)
                    
                    // Sessions for selected date
                    sessionsForDate
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(QXColor.gold)
                }
            }
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(QXColor.gold)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(QXColor.starlight)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(QXColor.gold)
            }
        }
        .padding(.top, 20)
    }
    
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 20)
    }
    
    private var calendarGrid: some View {
        let days = daysInMonth()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasEvents: hasEvents(on: date),
                        isToday: Calendar.current.isDateInToday(date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            selectedDate = date
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }
    
    private var sessionsForDate: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sessions on \(selectedDate, style: .date)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(QXColor.starlight)
                
                Spacer()
                
                Text("\(viewModel.upcomingSessions(for: selectedDate).count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QXColor.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(QXColor.gold.opacity(0.15))
                    )
            }
            
            if viewModel.upcomingSessions(for: selectedDate).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundStyle(QXColor.gold.opacity(0.5))
                    
                    Text("No sessions scheduled")
                        .font(.system(size: 16))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.upcomingSessions(for: selectedDate)) { session in
                        ScheduleSessionRow(session: session)
                    }
                }
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let daysInMonth = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasEvents(on date: Date) -> Bool {
        !viewModel.upcomingSessions(for: date).isEmpty
    }
    
    private func previousMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    let isToday: Bool
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(.system(size: 16, weight: isSelected || isToday ? .bold : .regular))
            .foregroundStyle(textColor)
            .frame(width: 40, height: 40)
            .background(
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(QXColor.gold)
                    } else if isToday {
                        Circle()
                            .stroke(QXColor.gold, lineWidth: 1.5)
                    }
                }
            )
            .overlay(
                Circle()
                    .fill(hasEvents ? QXColor.gold : Color.clear)
                    .frame(width: 6, height: 6)
                    .offset(y: 12)
            )
    }
    
    private var textColor: Color {
        if isSelected {
            return QXColor.cosmicBlack
        }
        return QXColor.starlight
    }
}

// MARK: - Schedule Session Row

struct ScheduleSessionRow: View {
    let session: LiveSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Time
            VStack(spacing: 4) {
                Text(session.startTime, style: .time)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(QXColor.starlight)
            }
            .frame(width: 60)
            
            // Divider line
            VStack(spacing: 0) {
                Circle()
                    .fill(QXColor.gold)
                    .frame(width: 10, height: 10)
                
                Rectangle()
                    .fill(QXColor.starlight.opacity(0.2))
                    .frame(width: 2)
            }
            
            // Session info
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(session.numerologist.name)
                        .font(.system(size: 13))
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                    
                    if session.isPremium {
                        HStack(spacing: 2) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                            Text("PREMIUM")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(QXColor.gold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(QXColor.gold.opacity(0.15))
                        )
                    }
                }
            }
            
            Spacer()
            
            // Reminder button
            Button(action: {}) {
                Image(systemName: session.hasReminder ? "bell.fill" : "bell")
                    .font(.system(size: 18))
                    .foregroundStyle(session.hasReminder ? QXColor.gold : QXColor.starlight.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(QXColor.deepVoid)
        )
    }
}

// MARK: - Reminder Settings View

struct ReminderSettingsView: View {
    @Binding var settings: ReminderSettings
    @Environment(\.dismiss) var dismiss
    
    let timeOptions = [5, 15, 30, 60]
    
    var body: some View {
        NavigationView {
            ZStack {
                QXColor.cosmicBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header illustration
                    ZStack {
                        Circle()
                            .fill(QXColor.gold.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(QXColor.gold)
                    }
                    .padding(.top, 20)
                    
                    Text("Reminder Settings")
                        .font(QXFont.displayMedium)
                        .foregroundStyle(QXColor.starlight)
                        .padding(.top, 20)
                    
                    Text("Never miss a live session with your favorite numerologists")
                        .font(QXFont.body)
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    
                    // Settings list
                    VStack(spacing: 20) {
                        // Enable reminders toggle
                        SettingRow(
                            icon: "bell.fill",
                            title: "Enable Reminders",
                            color: QXColor.gold
                        ) {
                            Toggle("", isOn: $settings.enabled)
                                .labelsHidden()
                                .tint(QXColor.gold)
                        }
                        
                        if settings.enabled {
                            // Time before selector
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notify me before session starts")
                                    .font(.system(size: 15))
                                    .foregroundStyle(QXColor.starlight)
                                
                                HStack(spacing: 8) {
                                    ForEach(timeOptions, id: \.self) { minutes in
                                        TimeOptionButton(
                                            minutes: minutes,
                                            isSelected: settings.minutesBefore == minutes
                                        ) {
                                            settings.minutesBefore = minutes
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(QXColor.deepVoid)
                            )
                            
                            // Notification types
                            VStack(spacing: 0) {
                                SettingRow(
                                    icon: "app.badge.fill",
                                    title: "Push Notifications",
                                    color: QXColor.cosmicPurple
                                ) {
                                    Toggle("", isOn: $settings.pushNotification)
                                        .labelsHidden()
                                        .tint(QXColor.gold)
                                }
                                
                                Divider()
                                    .background(QXColor.starlight.opacity(0.1))
                                
                                SettingRow(
                                    icon: "envelope.fill",
                                    title: "Email Notifications",
                                    color: QXColor.nebulaBlue
                                ) {
                                    Toggle("", isOn: $settings.emailNotification)
                                        .labelsHidden()
                                        .tint(QXColor.gold)
                                }
                                
                                Divider()
                                    .background(QXColor.starlight.opacity(0.1))
                                
                                SettingRow(
                                    icon: "calendar.badge.plus",
                                    title: "Sync to Calendar",
                                    color: QXColor.goldMuted
                                ) {
                                    Toggle("", isOn: $settings.calendarSync)
                                        .labelsHidden()
                                        .tint(QXColor.gold)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(QXColor.deepVoid)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: { dismiss() }) {
                        Text("Save Settings")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(QXColor.cosmicBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [QXColor.gold, QXColor.goldMuted],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Setting Row

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                )
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(QXColor.starlight)
            
            Spacer()
            
            content
        }
    }
}

// MARK: - Time Option Button

struct TimeOptionButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? QXColor.cosmicBlack : QXColor.starlight)
                .frame(width: 60, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? QXColor.gold : QXColor.sacredGeometry)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? QXColor.gold : QXColor.starlight.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Replay List View

struct ReplayListView: View {
    @ObservedObject var viewModel: LiveSessionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: true) {}
                FilterChip(title: "Masterclasses", isSelected: false) {}
                FilterChip(title: "Q&A", isSelected: false) {}
                FilterChip(title: "Readings", isSelected: false) {}
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Replay grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.sessions(for: .replays)) { session in
                        ReplayCard(session: session)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? QXColor.cosmicBlack : QXColor.starlight)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? QXColor.gold : QXColor.deepVoid)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : QXColor.starlight.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Replay Card

struct ReplayCard: View {
    let session: LiveSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Thumbnail
            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [QXColor.deepVoid, QXColor.sacredGeometry],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Image(systemName: "play.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(QXColor.gold)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(QXColor.cosmicBlack.opacity(0.8))
                            .overlay(
                                Circle()
                                    .stroke(QXColor.gold.opacity(0.5), lineWidth: 2)
                            )
                    )
                
                // Duration badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("45:32")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.7))
                            )
                    }
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                    .lineLimit(2)
                
                Text(session.numerologist.name)
                    .font(.system(size: 12))
                    .foregroundStyle(QXColor.starlight.opacity(0.6))
                
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "eye")
                            .font(.system(size: 10))
                        Text("\(session.participants)")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                    
                    Text("•")
                        .foregroundStyle(QXColor.starlight.opacity(0.3))
                    
                    Text("2 days ago")
                        .font(.system(size: 11))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - Device Helper

enum Device {
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }
}

// MARK: - QXHaptic Helper

enum QXHaptic {
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - QXAnimation Helper

enum QXAnimation {
    static func withAccessibility(_ animation: Animation) -> Animation {
        // Respect accessibility settings
        animation
    }
}

// MARK: - Press Animation Modifier

struct PressAnimationModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                        QXHaptic.lightImpact()
                    }
            )
    }
}

extension View {
    func pressAnimation() -> some View {
        modifier(PressAnimationModifier())
    }
}

// MARK: - Preview

#Preview("Live Session Hub") {
    LiveSessionView()
        .preferredColorScheme(.dark)
}

#Preview("Live Player") {
    LivePlayerView(
        viewModel: LiveSessionViewModel(),
        session: LiveSession.mockSessions[0]
    )
    .preferredColorScheme(.dark)
}

#Preview("Schedule Calendar") {
    ScheduleCalendarView(viewModel: LiveSessionViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Reminder Settings") {
    ReminderSettingsView(settings: .constant(ReminderSettings.default))
        .preferredColorScheme(.dark)
}

#Preview("Chat Message") {
    VStack {
        ChatMessageRow(message: ChatMessage.mockMessages[0])
        ChatMessageRow(message: ChatMessage.mockMessages[2])
    }
    .padding()
    .background(QXColor.deepVoid)
    .preferredColorScheme(.dark)
}