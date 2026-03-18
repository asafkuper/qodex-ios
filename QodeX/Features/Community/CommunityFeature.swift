//
//  CommunityFeature.swift
//  Social features for QodeX
//

import SwiftUI
import FirebaseFirestore

struct CommunityFeedView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var selectedTab: CommunityTab = .discussions
    
    enum CommunityTab {
        case discussions
        case liveSessions
        case mentors
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CommunityHeader(selectedTab: $selectedTab)
            
            // Content
            TabView(selection: $selectedTab) {
                DiscussionsView()
                    .tag(CommunityTab.discussions)
                
                LiveSessionsView()
                    .tag(CommunityTab.liveSessions)
                
                MentorsView()
                    .tag(CommunityTab.mentors)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.cosmicBlack)
    }
}

// MARK: - Discussions
struct DiscussionsView: View {
    @StateObject private var viewModel = DiscussionsViewModel()
    @State private var newPostText = ""
    @State private var showNewPost = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Create Post Card
                Button(action: { showNewPost = true }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Share your insight...")
                        Spacer()
                    }
                    .padding()
                    .background(Color.deepVoid)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Create new post")
                .accessibilityHint("Tap to create a new discussion post")
                .sheet(isPresented: $showNewPost) {
                    NewPostView()
                }
                
                // Pinned Topics
                if !viewModel.pinnedTopics.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.pinnedTopics) { topic in
                                PinnedTopicCard(topic: topic)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Feed
                ForEach(viewModel.posts) { post in
                    PostCard(post: post)
                }
            }
            .padding()
        }
    }
}

struct PostCard: View {
    let post: CommunityPost
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Button(action: {}) {
                    AvatarView(initials: post.authorInitials, color: post.authorColor)
                }
                .accessibilityLabel("View profile of \(post.authorName)")
                .accessibilityHint("Tap to view \(post.authorName)'s profile")
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading) {
                    Text(post.authorName)
                        .font(.headline)
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(post.authorName), posted \(post.timeAgo)")
                
                Spacer()
                
                TopicBadge(topic: post.topic)
            }
            
            // Content
            Text(post.content)
                .font(.body)
            
            // Interaction
            HStack(spacing: 24) {
                Button(action: { isLiked.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel(isLiked ? "Unlike post" : "Like post")
                .accessibilityHint("Tap to \(isLiked ? "unlike" : "like") this post")
                .accessibilityValue("\(post.likes + (isLiked ? 1 : 0)) likes")
                
                Button(action: { showComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("\(post.comments)")
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("View comments")
                .accessibilityHint("Tap to view and add comments")
                .accessibilityValue("\(post.comments) comments")
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Share post")
                .accessibilityHint("Tap to share this post with others")
                
                Spacer()
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.deepVoid)
        .cornerRadius(16)
    }
}

// MARK: - Live Sessions
struct LiveSessionsView: View {
    @StateObject private var viewModel = LiveSessionsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Next Live Session (Hero)
                if let nextSession = viewModel.nextSession {
                    NextSessionCard(session: nextSession)
                }
                
                // Upcoming
                Text("Upcoming Sessions")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(viewModel.upcomingSessions) { session in
                    SessionRow(session: session)
                }
                
                // Past Recordings
                if !viewModel.pastSessions.isEmpty {
                    Text("Recordings")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(viewModel.pastSessions) { session in
                        RecordingRow(session: session)
                    }
                }
            }
            .padding()
        }
    }
}

struct NextSessionCard: View {
    let session: LiveSession
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // Live Badge
            HStack {
                if session.isLive {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("LIVE NOW")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(20)
                    .accessibilityLabel("Live now")
                } else {
                    Text("STARTING IN")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                TierBadge(tier: session.requiredTier)
            }
            
            // Content
            Text(session.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(session.description)
                .font(.body)
                .foregroundColor(.gray)
            
            // Countdown or Join
            if session.isLive {
                Button("Join Live Session") {}
                    .buttonStyle(QXPrimaryButtonStyle())
                    .accessibilityLabel("Join live session")
                    .accessibilityHint("Tap to join the live session now")
            } else {
                Text(formatDuration(timeRemaining))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.gold)
                    .accessibilityLabel("Time remaining: \(formatDuration(timeRemaining))")
                
                Button("Remind Me") {}
                    .buttonStyle(QXSecondaryButtonStyle())
                    .accessibilityLabel("Set reminder")
                    .accessibilityHint("Tap to get notified when this session starts")
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.deepVoid, Color.deepVoid.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gold.opacity(0.3), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            timeRemaining = session.startDate.timeIntervalSinceNow
        }
    }
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Community Header
struct CommunityHeader: View {
    @Binding var selectedTab: CommunityFeedView.CommunityTab
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "Discussions", tab: .discussions, selectedTab: $selectedTab)
            TabButton(title: "Live", tab: .liveSessions, selectedTab: $selectedTab)
            TabButton(title: "Mentors", tab: .mentors, selectedTab: $selectedTab)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct TabButton: View {
    let title: String
    let tab: CommunityFeedView.CommunityTab
    @Binding var selectedTab: CommunityFeedView.CommunityTab
    
    var isSelected: Bool { tab == selectedTab }
    
    var body: some View {
        Button(action: { selectedTab = tab }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .gold : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? Color.gold.opacity(0.1) : Color.clear
                )
                .cornerRadius(8)
        }
        .accessibilityLabel("\(title) tab")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to switch to \(title.lowercased())")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let initials: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 44, height: 44)
            
            Text(initials)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .accessibilityLabel("User avatar")
    }
}

// MARK: - Models
struct CommunityPost: Identifiable {
    let id: String
    let authorName: String
    let authorInitials: String
    let authorColor: Color
    let content: String
    let topic: String
    let likes: Int
    let comments: Int
    let timestamp: Date
    
    var timeAgo: String {
        // Calculate time ago
        return "2h ago"
    }
}

struct LiveSession: Identifiable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let isLive: Bool
    let requiredTier: MembershipTier
    let hostName: String
}

struct Topic: Identifiable {
    let id: String
    let title: String
}

struct PinnedTopicCard: View {
    let topic: Topic
    
    var body: some View {
        Button(action: {}) {
            Text(topic.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gold.opacity(0.1))
                .cornerRadius(20)
        }
        .accessibilityLabel("Topic: \(topic.title)")
        .accessibilityHint("Tap to view posts in this topic")
    }
}

struct SessionRow: View {
    let session: LiveSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                Text("Host: \(session.hostName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.gold)
                    .frame(width: 44, height: 44)
                    .background(Color.gold.opacity(0.1))
                    .cornerRadius(8)
            }
            .accessibilityLabel("Remind me about \(session.title)")
            .accessibilityHint("Tap to set a reminder for this session")
        }
        .padding()
        .background(Color.deepVoid)
        .cornerRadius(12)
    }
}

struct RecordingRow: View {
    let session: LiveSession
    
    var body: some View {
        HStack {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.gold)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                Text("Recording")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.deepVoid)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recording of \(session.title)")
        .accessibilityHint("Tap to play this recording")
        .accessibilityAddTraits(.isButton)
    }
}

struct TopicBadge: View {
    let topic: String
    
    var body: some View {
        Text(topic)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.gold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gold.opacity(0.1))
            .cornerRadius(8)
    }
}

struct TierBadge: View {
    let tier: MembershipTier
    
    var body: some View {
        Text(tier.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.gold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gold.opacity(0.2))
            .cornerRadius(4)
    }
}

enum MembershipTier: String {
    case free = "FREE"
    case premium = "PREMIUM"
    case pro = "PRO"
}

// MARK: - Button Styles
struct QXPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.gold, .gold.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct QXSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.gold.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gold.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// Placeholder views
struct MentorsView: View {
    var body: some View {
        Text("Mentors")
    }
}

// MARK: - ViewModels
class CommunityViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []
    
    func loadPosts() {
        // Load from Firestore
    }
}

class DiscussionsViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []
    @Published var pinnedTopics: [Topic] = []
}

class LiveSessionsViewModel: ObservableObject {
    @Published var nextSession: LiveSession?
    @Published var upcomingSessions: [LiveSession] = []
    @Published var pastSessions: [LiveSession] = []
}