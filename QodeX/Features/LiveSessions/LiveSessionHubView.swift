import SwiftUI
import Combine

// MARK: - Live Session Hub
struct LiveSessionHubView: View {
    @StateObject private var viewModel = LiveSessionViewModel()
    @State private var selectedTab: SessionTab = .upcoming
    
    enum SessionTab {
        case upcoming, recordings, mySessions
    }
    
    var body: some View {
        ZStack {
            Color.cosmicBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                LiveSessionHeader(
                    nextSession: viewModel.nextSession,
                    countdown: viewModel.countdown
                )
                
                // Tab selector
                SessionTabSelector(selectedTab: $selectedTab)
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case .upcoming:
                        UpcomingSessionsList(sessions: viewModel.upcomingSessions) { session in
                            viewModel.joinSession(session)
                        }
                    case .recordings:
                        RecordingsList(recordings: viewModel.recordings)
                    case .mySessions:
                        MySessionsView(sessions: viewModel.myRegisteredSessions)
                    }
                }
            }
        }
        .sheet(item: $viewModel.activeSession) { session in
            LiveSessionRoom(session: session)
        }
    }
}

// MARK: - View Model
class LiveSessionViewModel: ObservableObject {
    @Published var upcomingSessions: [LiveSession] = []
    @Published var recordings: [SessionRecording] = []
    @Published var myRegisteredSessions: [LiveSession] = []
    @Published var activeSession: LiveSession? = nil
    @Published var countdown: String = ""
    
    var nextSession: LiveSession? {
        upcomingSessions.first
    }
    
    private var timer: AnyCancellable?
    
    init() {
        loadSessions()
        startCountdown()
    }
    
    private func loadSessions() {
        upcomingSessions = [
            LiveSession(
                id: "1",
                title: "Decode Your Chart Live",
                description: "Bring your birth date and time for personalized chart reading with Shani.",
                startTime: Date().addingTimeInterval(86400 * 2),
                duration: 60,
                maxAttendees: 100,
                registeredAttendees: 45,
                isPremium: false,
                type: .liveReading
            ),
            LiveSession(
                id: "2",
                title: "Master Numbers Deep Dive",
                description: "Understanding 11, 22, 33 and their unique challenges and gifts.",
                startTime: Date().addingTimeInterval(86400 * 9),
                duration: 90,
                maxAttendees: 150,
                registeredAttendees: 89,
                isPremium: true,
                type: .teaching
            ),
            LiveSession(
                id: "3",
                title: "Q&A with Shani",
                description: "Open Q&A session. Ask anything about numerology, your chart, or spiritual growth.",
                startTime: Date().addingTimeInterval(86400 * 16),
                duration: 60,
                maxAttendees: 200,
                registeredAttendees: 0,
                isPremium: false,
                type: .qa
            )
        ]
        
        recordings = [
            SessionRecording(
                id: "1",
                title: "Introduction to Life Path Numbers",
                duration: 3420,
                views: 1247,
                thumbnail: "video1",
                date: Date().addingTimeInterval(-86400 * 7)
            ),
            SessionRecording(
                id: "2",
                title: "Compatibility and Relationships",
                duration: 4860,
                views: 892,
                thumbnail: "video2",
                date: Date().addingTimeInterval(-86400 * 14)
            ),
            SessionRecording(
                id: "3",
                title: "Understanding Your Pinnacles",
                duration: 3780,
                views: 654,
                thumbnail: "video3",
                date: Date().addingTimeInterval(-86400 * 21)
            )
        ]
    }
    
    private func startCountdown() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }
    
    private func updateCountdown() {
        guard let next = nextSession else {
            countdown = "No upcoming sessions"
            return
        }
        
        // Use local time for countdown
        let localTime = next.localStartTime
        let diff = localTime.timeIntervalSinceNow
        
        if diff <= 0 {
            countdown = "LIVE NOW"
        } else {
            let days = Int(diff) / 86400
            let hours = (Int(diff) % 86400) / 3600
            let minutes = (Int(diff) % 3600) / 60
            
            if days > 0 {
                countdown = "\(days)d \(hours)h \(minutes)m"
            } else if hours > 0 {
                countdown = "\(hours)h \(minutes)m"
            } else {
                countdown = "\(minutes)m"
            }
        }
    }
    
    func joinSession(_ session: LiveSession) {
        activeSession = session
    }
}

// MARK: - Models
struct LiveSession: Identifiable {
    let id: String
    let title: String
    let description: String
    let startTime: Date
    let timezone: String
    let duration: Int
    let maxAttendees: Int
    let registeredAttendees: Int
    let isPremium: Bool
    let type: SessionType
    
    var localStartTime: Date {
        // Convert server time to local time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: timezone) ?? .current
        
        let dateString = formatter.string(from: startTime)
        formatter.timeZone = .current
        return formatter.date(from: dateString) ?? startTime
    }
    
    enum SessionType {
        case liveReading, teaching, qa, workshop
        
        var icon: String {
            switch self {
            case .liveReading: return "person.wave.2"
            case .teaching: return "book.fill"
            case .qa: return "questionmark.bubble"
            case .workshop: return "hands.sparkles"
            }
        }
        
        var color: Color {
            switch self {
            case .liveReading: return .purple
            case .teaching: return .blue
            case .qa: return .green
            case .workshop: return .orange
            }
        }
    }
}

struct SessionRecording: Identifiable {
    let id: String
    let title: String
    let duration: Int
    let views: Int
    let thumbnail: String
    let date: Date
    
    var durationFormatted: String {
        let minutes = duration / 60
        let hours = minutes / 60
        let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
}

// MARK: - Views
struct LiveSessionHeader: View {
    let nextSession: LiveSession?
    let countdown: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Sessions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Learn with Shani in real-time")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                // Live indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.2))
                )
            }
            
            // Next session card
            if let session = nextSession {
                NextSessionCard(session: session, countdown: countdown)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.deepSpace, Color.cosmicBlack],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct NextSessionCard: View {
    let session: LiveSession
    let countdown: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(session.type.color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: session.type.icon)
                    .font(.title3)
                    .foregroundColor(session.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Session")
                    .font(.caption)
                    .foregroundColor(.gold)
                    .textCase(.uppercase)
                
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(countdown, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(countdown == "LIVE NOW" ? .red : .gold)
                    
                    Text("•")
                        .foregroundColor(.secondaryText)
                    
                    Label("\(session.registeredAttendees)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Remind Me")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.gold)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SessionTabSelector: View {
    @Binding var selectedTab: LiveSessionHubView.SessionTab
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Upcoming",
                isSelected: selectedTab == .upcoming
            ) {
                selectedTab = .upcoming
            }
            
            TabButton(
                title: "Recordings",
                isSelected: selectedTab == .recordings
            ) {
                selectedTab = .recordings
            }
            
            TabButton(
                title: "My Sessions",
                isSelected: selectedTab == .mySessions
            ) {
                selectedTab = .mySessions
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? Color.gold.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
    }
}

struct UpcomingSessionsList: View {
    let sessions: [LiveSession]
    let onJoin: (LiveSession) -> Void
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(sessions) { session in
                UpcomingSessionCard(session: session) {
                    onJoin(session)
                }
            }
        }
        .padding()
    }
}

struct UpcomingSessionCard: View {
    let session: LiveSession
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Type badge
                HStack(spacing: 4) {
                    Image(systemName: session.type.icon)
                        .font(.caption2)
                    Text(session.type.name)
                        .font(.caption)
                }
                .foregroundColor(session.type.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(session.type.color.opacity(0.2))
                )
                
                Spacer()
                
                if session.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                        Text("Premium")
                            .font(.caption)
                    }
                    .foregroundColor(.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.gold.opacity(0.2))
                    )
                }
            }
            
            Text(session.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(session.description)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(2)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack {
                // Date/time
                VStack(alignment: .leading, spacing: 4) {
                    Label(
                        session.startTime.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    
                    Label(
                        session.startTime.formatted(date: .omitted, time: .shortened),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                // Attendees
                VStack(alignment: .trailing, spacing: 4) {
                    Label("\(session.registeredAttendees)/\(session.maxAttendees)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(Color.gold)
                                .frame(
                                    width: geometry.size.width * CGFloat(session.registeredAttendees) / CGFloat(session.maxAttendees),
                                    height: 4
                                )
                                .cornerRadius(2)
                        }
                    }
                    .frame(width: 80, height: 4)
                }
            }
            
            Button(action: onJoin) {
                Text("Register")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.gold)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct RecordingsList: View {
    let recordings: [SessionRecording]
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(recordings) { recording in
                RecordingCard(recording: recording)
            }
        }
        .padding()
    }
}

struct RecordingCard: View {
    let recording: SessionRecording
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 120, height: 80)
                
                Image(systemName: "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recording.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label(recording.durationFormatted, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    
                    Label("\(recording.views)", systemImage: "eye")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Text(recording.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "arrow.down.circle")
                    .font(.title3)
                    .foregroundColor(.gold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct MySessionsView: View {
    let sessions: [LiveSession]
    
    var body: some View {
        VStack(spacing: 24) {
            if sessions.isEmpty {
                EmptyMySessionsView()
            } else {
                UpcomingSessionsList(sessions: sessions) { _ in }
            }
        }
        .padding()
    }
}

struct EmptyMySessionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.gold.opacity(0.5))
            
            Text("No sessions yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Register for upcoming sessions to see them here.")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: {}) {
                Text("Browse Sessions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.gold)
                    )
            }
            .padding(.top, 8)
        }
        .padding(32)
    }
}

struct LiveSessionRoom: View {
    let session: LiveSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Video placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    VStack(spacing: 16) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.gold.opacity(0.5))
                        
                        Text("Live Session Room")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Connecting...")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                // Chat area
                ChatArea()
            }
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Leave") { dismiss() }
                    .foregroundColor(.red)
            }
        }
    }
}

struct ChatArea: View {
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<5) { i in
                        ChatMessageView(
                            author: "User \(i + 1)",
                            message: "This is so insightful!",
                            isMe: i == 0
                        )
                    }
                }
                .padding()
            }
            
            // Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $message)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gold)
                }
            }
            .padding()
            .background(Color.deepSpace)
        }
    }
}

struct ChatMessageView: View {
    let author: String
    let message: String
    let isMe: Bool
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                if !isMe {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(.gold)
                }
                
                Text(message)
                    .font(.body)
                    .foregroundColor(isMe ? .black : .white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isMe ? Color.gold : Color.white.opacity(0.1))
                    )
            }
            
            if !isMe { Spacer() }
        }
    }
}

// MARK: - Preview
struct LiveSessionHubView_Previews: PreviewProvider {
    static var previews: some View {
        LiveSessionHubView()
            .preferredColorScheme(.dark)
    }
}
