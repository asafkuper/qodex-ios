import SwiftUI

// MARK: - Enhanced Community Feed
struct CommunityFeedView: View {
    @StateObject private var viewModel = CommunityFeedViewModel()
    @State private var newPostText = ""
    @State private var selectedFilter: PostFilter = .all
    @FocusState private var isInputFocused: Bool
    
    enum PostFilter: String, CaseIterable {
        case all = "All"
        case discussions = "Discussions"
        case insights = "Insights"
        case questions = "Questions"
    }
    
    var body: some View {
        ZStack {
            Color.cosmicBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                CommunityHeader(selectedFilter: $selectedFilter)
                
                // Content based on state
                ZStack {
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        // Loading skeleton
                        LoadingFeedView()
                    } else if let error = viewModel.error {
                        // Error state
                        ErrorFeedView(error: error) {
                            viewModel.loadPosts()
                        }
                    } else if viewModel.posts.isEmpty {
                        // Empty state
                        EmptyFeedView()
                    } else {
                        // Feed
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredPosts(for: selectedFilter)) { post in
                                    CommunityPostCard(post: post)
                                        .onAppear {
                                            if post == viewModel.posts.last {
                                                viewModel.loadMore()
                                            }
                                        }
                                }
                                
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
                
                // Input area
                PostInputArea(
                    text: $newPostText,
                    isFocused: _isInputFocused,
                    onSend: { sendPost() }
                )
            }
        }
    }
    
    private func sendPost() {
        guard !newPostText.isEmpty else { return }
        viewModel.createPost(content: newPostText)
        newPostText = ""
        isInputFocused = false
    }
}

// MARK: - View Model
class CommunityFeedViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []
    @Published var isLoading = false
    
    init() {
        loadPosts()
    }
    
    func loadPosts() {
        // Mock data
        posts = [
            CommunityPost(
                id: "1",
                author: PostAuthor(name: "Sarah M.", lifePath: 7, avatar: "S"),
                content: "Just discovered I'm a Life Path 7! The accuracy is mind-blowing. Anyone else feel like they were reading their private journal?",
                timestamp: Date().addingTimeInterval(-3600),
                likes: 24,
                comments: 8,
                tags: ["Life Path 7", "Discovery"]
            ),
            CommunityPost(
                id: "2",
                author: PostAuthor(name: "Michael R.", lifePath: 3, avatar: "M"),
                content: "Today's Daily Qode really resonated with me. The affirmation about creativity flowing freely came right when I needed it. ✨",
                timestamp: Date().addingTimeInterval(-7200),
                likes: 42,
                comments: 12,
                tags: ["Daily Qode", "Creativity"]
            ),
            CommunityPost(
                id: "3",
                author: PostAuthor(name: "Emma L.", lifePath: 9, avatar: "E"),
                content: "Question for the community: How do you balance the 9's urge to serve everyone with the need for self-care? Struggling with burnout. 💭",
                timestamp: Date().addingTimeInterval(-10800),
                likes: 56,
                comments: 23,
                tags: ["Question", "Life Path 9", "Self-Care"]
            ),
            CommunityPost(
                id: "4",
                author: PostAuthor(name: "David K.", lifePath: 8, avatar: "D"),
                content: "Shani's live session yesterday on Master Numbers was incredible. So much clarity about why I've always felt 'different.'",
                timestamp: Date().addingTimeInterval(-14400),
                likes: 89,
                comments: 31,
                tags: ["Live Session", "Master Numbers"]
            )
        ]
    }
    
    func loadMore() {
        // Pagination logic
    }
    
    func createPost(content: String) {
        let newPost = CommunityPost(
            id: UUID().uuidString,
            author: PostAuthor(name: "You", lifePath: 7, avatar: "Y"),
            content: content,
            timestamp: Date(),
            likes: 0,
            comments: 0,
            tags: []
        )
        posts.insert(newPost, at: 0)
    }
}

// MARK: - Models
struct CommunityPost: Identifiable, Equatable {
    let id: String
    let author: PostAuthor
    let content: String
    let timestamp: Date
    var likes: Int
    var comments: Int
    let tags: [String]
    
    static func == (lhs: CommunityPost, rhs: CommunityPost) -> Bool {
        lhs.id == rhs.id
    }
}

struct PostAuthor {
    let name: String
    let lifePath: Int
    let avatar: String
}

// MARK: - Views
struct CommunityHeader: View {
    @Binding var selectedFilter: CommunityFeedView.PostFilter
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Community")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundColor(.gold)
                        .overlay(
                            Badge(count: 3)
                                .offset(x: 8, y: -8)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CommunityFeedView.PostFilter.allCases, id: \.self) { filter in
                        FilterTab(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
        }
        .background(Color.deepSpace)
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.gold : Color.white.opacity(0.1))
                )
        }
    }
}

struct Badge: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 18, height: 18)
            .background(Color.red)
            .clipShape(Circle())
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author row
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.5),
                                    Color.gold.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(post.author.avatar)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("Life Path \(post.author.lifePath)")
                            .font(.caption)
                            .foregroundColor(.gold)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        
                        Text(post.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondaryText)
                }
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.white)
                .lineSpacing(4)
            
            // Tags
            if !post.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.gold.opacity(0.1))
                            )
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Actions
            HStack(spacing: 24) {
                ActionButton(
                    icon: isLiked ? "heart.fill" : "heart",
                    count: post.likes + (isLiked ? 1 : 0),
                    color: isLiked ? .red : .secondaryText
                ) {
                    withAnimation(.spring()) {
                        isLiked.toggle()
                    }
                }
                
                ActionButton(
                    icon: "bubble.right",
                    count: post.comments,
                    color: .secondaryText
                ) {
                    showComments = true
                }
                
                ActionButton(
                    icon: "square.and.arrow.up",
                    count: nil,
                    color: .secondaryText
                ) {}
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showComments) {
            CommentsSheet(post: post)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let count: Int?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption)
                }
            }
            .foregroundColor(color)
        }
    }
}

struct PostInputArea: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Share your insights...", text: $text, axis: .vertical)
                .focused($isFocused)
                .lineLimit(1...4)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.deepSpace)
                )
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? .gray : .gold)
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(Color.cosmicBlack)
    }
}

struct CommentsSheet: View {
    let post: CommunityPost
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Original post (mini)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(post.author.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Life Path \(post.author.lifePath)")
                            .font(.caption)
                            .foregroundColor(.gold)
                    }
                    
                    Text(post.content)
                        .font(.body)
                        .lineLimit(3)
                }
                .padding()
                .background(Color.deepSpace)
                .cornerRadius(12)
                .padding()
                
                Divider()
                
                // Comments list
                List {
                    ForEach(0..<5) { i in
                        CommentRow(
                            author: "User \(i + 1)",
                            content: "This really resonated with me! Thanks for sharing.",
                            time: "\(i + 1)h ago"
                        )
                    }
                }
                .listStyle(.plain)
                
                // Input
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .padding(12)
                        .background(Color.deepSpace)
                        .cornerRadius(20)
                    
                    Button("Post") {
                        // Post comment
                        newComment = ""
                    }
                    .foregroundColor(.gold)
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .background(Color.cosmicBlack.ignoresSafeArea())
        }
    }
}

struct CommentRow: View {
    let author: String
    let content: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gold.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(author.prefix(1)))
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(author)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct CommunityFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityFeedView()
            .preferredColorScheme(.dark)
    }
}
