//
//  CommunityView.swift
//  QodeX - Premium Community Feed
//  Inspired by Instagram, Twitter, Clubhouse
//

import SwiftUI

struct CommunityView: View {
    @State private var posts: [Post] = samplePosts
    @State private var isRefreshing = false
    @State private var showNewPostSheet = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Community")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        Button(action: { showNewPostSheet = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.starlight)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.goldPrimary.opacity(0.2))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.goldPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Create new post")
                        .accessibilityHint("Tap to create a new community post")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Create Post Card
                    CreatePostCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .onTapGesture {
                            showNewPostSheet = true
                        }
                        .accessibilityLabel("Create new post")
                        .accessibilityHint("Tap to start writing a new post")
                        .accessibilityAddTraits(.isButton)
                    
                    // Feed
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .refreshable {
                await refreshFeed()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showNewPostSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.cosmicBlack)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.goldBright, .goldPrimary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: .goldPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .accessibilityLabel("Create new post")
                    .accessibilityHint("Tap to create a new community post")
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showNewPostSheet) {
            NewPostView()
        }
    }
    
    private func refreshFeed() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isRefreshing = false
    }
}

// MARK: - Create Post Card
struct CreatePostCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.goldPrimary.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text("SJ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.starlight)
            }
            .accessibilityLabel("Your profile")
            
            Text("Share your insight...")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.starlightTertiary)
            
            Spacer()
            
            Image(systemName: "photo")
                .font(.system(size: 20))
                .foregroundColor(.goldPrimary)
                .frame(width: 44, height: 44)
                .accessibilityLabel("Add photo")
                .accessibilityHint("Tap to add a photo to your post")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Post Card
struct PostCard: View {
    let post: Post
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    
    init(post: Post) {
        self.post = post
        _likeCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Avatar with Life Path
                Button(action: {}) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(post.userColor.opacity(0.3))
                            .frame(width: 48, height: 48)
                        
                        Text(String(post.username.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        // Life Path badge
                        ZStack {
                            Circle()
                                .fill(Color(hex: "12121A"))
                                .frame(width: 20, height: 20)
                            
                            Circle()
                                .fill(Color.goldPrimary)
                                .frame(width: 14, height: 14)
                            
                            Text("\(post.lifePath)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.cosmicBlack)
                        }
                    }
                }
                .accessibilityLabel("View profile of \(post.username)")
                .accessibilityHint("Tap to view \(post.username)'s profile")
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.starlight)
                    
                    HStack(spacing: 6) {
                        Text("Life Path \(post.lifePath)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.goldPrimary)
                        
                        Text("•")
                            .foregroundColor(.starlightQuaternary)
                        
                        Text(post.timeAgo)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.starlightTertiary)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.starlightTertiary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("More options")
                .accessibilityHint("Tap to see more options for this post")
            }
            .padding(16)
            
            // Content
            Text(post.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 16)
            
            // Tags
            if !post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.goldPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.goldPrimary.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            
            // Engagement
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                        likeCount += isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isLiked ? .red : .starlightTertiary)
                            .scaleEffect(isLiked ? 1.2 : 1.0)
                        
                        Text("\(likeCount)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isLiked ? .red : .starlightTertiary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel(isLiked ? "Unlike post" : "Like post")
                .accessibilityHint("Tap to \(isLiked ? "unlike" : "like") this post")
                .accessibilityValue("\(likeCount) likes")
                
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 20))
                            .foregroundColor(.starlightTertiary)
                        
                        Text("\(post.comments)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.starlightTertiary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("View comments")
                .accessibilityHint("Tap to view and add comments")
                .accessibilityValue("\(post.comments) comments")
                
                Button(action: {}) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 20))
                        .foregroundColor(.starlightTertiary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Repost")
                .accessibilityHint("Tap to repost this post")
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.starlightTertiary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Share post")
                .accessibilityHint("Tap to share this post with others")
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "12121A").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - New Post View
struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TextEditor(text: $postText)
                        .font(.system(size: 17))
                        .foregroundColor(.starlight)
                        .background(Color.clear)
                        .padding(16)
                        .accessibilityLabel("Post content")
                        .accessibilityHint("Type your post content here")
                    
                    Spacer()
                    
                    // Tag suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["DailyReading", "LifePath7", "Spiritual", "Manifestation"], id: \.self) { tag in
                                Button(action: {
                                    postText += " #\(tag)"
                                }) {
                                    Text("#\(tag)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.goldPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.goldPrimary.opacity(0.1))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .accessibilityLabel("Add tag \(tag)")
                                .accessibilityHint("Tap to add this hashtag to your post")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.starlightTertiary)
                        .accessibilityLabel("Cancel")
                        .accessibilityHint("Tap to discard and close")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") { dismiss() }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .disabled(postText.isEmpty)
                        .accessibilityLabel("Publish post")
                        .accessibilityHint("Tap to publish your post")
                }
            }
        }
    }
}

// MARK: - Models
struct Post: Identifiable {
    let id = UUID()
    let username: String
    let lifePath: Int
    let content: String
    let timeAgo: String
    let likes: Int
    let comments: Int
    let tags: [String]
    let userColor: Color
}

let samplePosts = [
    Post(
        username: "Sarah M.",
        lifePath: 7,
        content: "Today my number is 8 and I feel the power! Manifesting abundance and career growth ✨\n\nThe energy of 8 is all about achievement and success. Time to make bold moves!",
        timeAgo: "2h ago",
        likes: 24,
        comments: 8,
        tags: ["DailyReading", "LifePath8", "Manifestation"],
        userColor: .purple
    ),
    Post(
        username: "Michael R.",
        lifePath: 3,
        content: "Can someone explain Personal Year cycles? Mine just changed to 9 and I'm feeling a major shift 🙏",
        timeAgo: "5h ago",
        likes: 12,
        comments: 15,
        tags: ["Question", "PersonalYear", "LifePath3"],
        userColor: .blue
    ),
    Post(
        username: "Emma Chen",
        lifePath: 11,
        content: "As a Master Number 11, I often feel overwhelmed by my intuition. Anyone else experience this? Would love to connect with other 11s 💫",
        timeAgo: "8h ago",
        likes: 56,
        comments: 32,
        tags: ["MasterNumber", "LifePath11", "Intuition"],
        userColor: .pink
    ),
    Post(
        username: "David K.",
        lifePath: 5,
        content: "Just hit a 30-day streak! The daily readings have become my morning ritual. So grateful for this community 🙏✨",
        timeAgo: "12h ago",
        likes: 89,
        comments: 24,
        tags: ["Milestone", "Streak", "Gratitude"],
        userColor: .green
    )
]

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .preferredColorScheme(.dark)
    }
}