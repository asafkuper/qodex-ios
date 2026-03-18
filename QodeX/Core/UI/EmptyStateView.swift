//
//  EmptyStateView.swift
//  QodeX Premium Empty States
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Premium Empty State View

struct PremiumEmptyStateView: View {
    let type: EmptyStateType
    let action: (() -> Void)?
    
    enum EmptyStateType {
        case noData
        case noSearchResults(query: String)
        case noInternet
        case noNotifications
        case noFavorites
        case noJournal
        case noCommunity
        case noTeachings
        case noSubscription
        case custom(icon: String, title: String, message: String, accentColor: Color)
    }
    
    init(type: EmptyStateType, action: (() -> Void)? = nil) {
        self.type = type
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated illustration
            illustration
                .padding(.bottom, 8)
            
            // Title
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(QXColor.starlight)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(QXColor.starlight.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            // Action button
            if let action = action {
                Button(action: {
                    QXHaptic.mediumImpact()
                    action()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: actionIcon)
                        Text(actionTitle)
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(QXColor.cosmicBlack)
                    .frame(width: 220, height: 52)
                    .background(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(26)
                }
                .padding(.top, 8)
                .pressAnimation()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QXColor.cosmicBlack.ignoresSafeArea())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
    
    // MARK: - Illustration
    
    @ViewBuilder
    private var illustration: some View {
        switch type {
        case .noData, .noSearchResults:
            SearchIllustration()
        case .noInternet:
            OfflineIllustration()
        case .noNotifications:
            NotificationsIllustration()
        case .noFavorites:
            FavoritesIllustration()
        case .noJournal:
            JournalIllustration()
        case .noCommunity:
            CommunityIllustration()
        case .noTeachings:
            TeachingsIllustration()
        case .noSubscription:
            SubscriptionIllustration()
        case .custom(let icon, _, _, let color):
            CustomIllustration(icon: icon, color: color)
        }
    }
    
    // MARK: - Content
    
    private var title: String {
        switch type {
        case .noData: return "Nothing Here Yet"
        case .noSearchResults: return "No Results Found"
        case .noInternet: return "You're Offline"
        case .noNotifications: return "All Caught Up"
        case .noFavorites: return "No Favorites"
        case .noJournal: return "Start Your Journey"
        case .noCommunity: return "Be the First"
        case .noTeachings: return "Coming Soon"
        case .noSubscription: return "Unlock More"
        case .custom(_, let title, _, _): return title
        }
    }
    
    private var message: String {
        switch type {
        case .noData: 
            return "This space is waiting for your content. Create something amazing!"
        case .noSearchResults(let query): 
            return "We couldn't find anything matching \"\(query)\". Try different keywords."
        case .noInternet: 
            return "Check your connection and try again. Your cosmic insights are waiting."
        case .noNotifications: 
            return "You're all caught up! We'll notify you when something important happens."
        case .noFavorites: 
            return "Mark your favorite teachings and insights to find them quickly later."
        case .noJournal: 
            return "Your numerology journal is a sacred space. Begin with your first reflection."
        case .noCommunity: 
            return "Start a discussion and connect with fellow seekers on their spiritual journey."
        case .noTeachings: 
            return "New content is being prepared. Great wisdom takes time to develop."
        case .noSubscription: 
            return "Upgrade to Inner Circle for unlimited access to all teachings and features."
        case .custom(_, _, let message, _): return message
        }
    }
    
    private var actionTitle: String {
        switch type {
        case .noData: return "Create New"
        case .noSearchResults: return "Clear Search"
        case .noInternet: return "Try Again"
        case .noNotifications: return "Settings"
        case .noFavorites: return "Explore"
        case .noJournal: return "Write Entry"
        case .noCommunity: return "Start Discussion"
        case .noTeachings: return "Browse Library"
        case .noSubscription: return "Upgrade Now"
        case .custom: return "Action"
        }
    }
    
    private var actionIcon: String {
        switch type {
        case .noData: return "plus"
        case .noSearchResults: return "xmark"
        case .noInternet: return "arrow.clockwise"
        case .noNotifications: return "gearshape"
        case .noFavorites: return "compass"
        case .noJournal: return "square.and.pencil"
        case .noCommunity: return "bubble.left"
        case .noTeachings: return "books.vertical"
        case .noSubscription: return "crown.fill"
        case .custom: return "arrow.right"
        }
    }
}

// MARK: - Illustrations

struct SearchIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Magnifying glass
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.gold)
                .rotationEffect(.degrees(isAnimating ? 10 : -10))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            // Decorative dots
            ForEach(0..<3) { i in
                Circle()
                    .fill(QXColor.gold.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(Double(i) * .pi * 2 / 3) * 55,
                        y: sin(Double(i) * .pi * 2 / 3) * 55
                    )
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .delay(Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct OfflineIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // WiFi icon with slash
            ZStack {
                Image(systemName: "wifi")
                    .font(.system(size: 50))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundStyle(QXColor.gold)
                    .opacity(isAnimating ? 1 : 0.7)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            // Signal waves
            ForEach(0..<2) { i in
                ArcShape(startAngle: -60, endAngle: 60)
                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 2)
                    .frame(width: 100 + CGFloat(i * 20), height: 100 + CGFloat(i * 20))
                    .rotationEffect(.degrees(180))
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.3 : 0.1)
                    .animation(
                        .easeInOut(duration: 2)
                            .delay(Double(i) * 0.3)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct NotificationsIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Bell
            Image(systemName: "bell.slash")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.gold)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            // Check mark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(QXColor.cosmicTeal)
                .background(Circle().fill(QXColor.cosmicBlack))
                .offset(x: 30, y: 30)
        }
        .onAppear { isAnimating = true }
    }
}

struct FavoritesIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Heart outline
            Image(systemName: "heart")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.starlight.opacity(0.5))
            
            // Plus
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(QXColor.gold)
                .background(Circle().fill(QXColor.cosmicBlack))
                .offset(x: 25, y: -25)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear { isAnimating = true }
    }
}

struct JournalIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Book
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.gold)
                .rotationEffect(.degrees(isAnimating ? 3 : -3))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
            
            // Sparkles
            ForEach(0..<3) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 16))
                    .foregroundStyle(QXColor.goldGlow)
                    .offset(
                        x: [35, -30, 20][i],
                        y: [-20, 25, -35][i]
                    )
                    .opacity(isAnimating ? [1, 0.5, 0.8][i] : 0.3)
                    .animation(
                        .easeInOut(duration: 1.2)
                            .delay(Double(i) * 0.3)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct CommunityIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // People
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.gold)
            
            // Chat bubble
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 24))
                .foregroundStyle(QXColor.cosmicTeal)
                .background(Circle().fill(QXColor.cosmicBlack))
                .offset(x: 30, y: -20)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear { isAnimating = true }
    }
}

struct TeachingsIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Hourglass / loading
            Image(systemName: "hourglass")
                .font(.system(size: 50))
                .foregroundStyle(QXColor.gold)
                .rotationEffect(.degrees(isAnimating ? 180 : 0))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
            
            // Glow effect
            Circle()
                .fill(QXColor.gold.opacity(0.1))
                .frame(width: 100, height: 100)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .opacity(isAnimating ? 0.5 : 0.2)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear { isAnimating = true }
    }
}

struct SubscriptionIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            // Crown
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            // Sparkle decorations
            ForEach(0..<4) { i in
                Image(systemName: "sparkle.fill")
                    .font(.system(size: [20, 16, 14, 18][i]))
                    .foregroundStyle(QXColor.goldGlow)
                    .offset(
                        x: [40, -35, 25, -20][i],
                        y: [-30, 25, 35, -35][i]
                    )
                    .opacity(isAnimating ? [1, 0.6, 0.8, 0.5][i] : 0.2)
                    .animation(
                        .easeInOut(duration: 1)
                            .delay(Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct CustomIllustration: View {
    let icon: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(QXColor.starlight.opacity(0.2))
                .frame(width: 140, height: 140)
            
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(color)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Arc Shape Helper

struct ArcShape: Shape {
    let startAngle: Double
    let endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Pre-configured Empty States

extension PremiumEmptyStateView {
    static func noSearchResults(query: String, action: @escaping () -> Void) -> some View {
        PremiumEmptyStateView(type: .noSearchResults(query: query), action: action)
    }
    
    static func noInternet(retry: @escaping () -> Void) -> some View {
        PremiumEmptyStateView(type: .noInternet, action: retry)
    }
    
    static func noJournalEntries(action: @escaping () -> Void) -> some View {
        PremiumEmptyStateView(type: .noJournal, action: action)
    }
    
    static func noCommunityPosts(action: @escaping () -> Void) -> some View {
        PremiumEmptyStateView(type: .noCommunity, action: action)
    }
    
    static func noNotifications() -> some View {
        PremiumEmptyStateView(type: .noNotifications, action: nil)
    }
    
    static func custom(icon: String, title: String, message: String, color: Color = QXColor.gold, action: (() -> Void)? = nil) -> some View {
        PremiumEmptyStateView(type: .custom(icon: icon, title: title, message: message, accentColor: color), action: action)
    }
}

// MARK: - Preview

#Preview("Empty States") {
    TabView {
        PremiumEmptyStateView(type: .noData)
            .tabItem { Text("No Data") }
        
        PremiumEmptyStateView(type: .noSearchResults(query: "spiritual"))
            .tabItem { Text("Search") }
        
        PremiumEmptyStateView(type: .noInternet)
            .tabItem { Text("Offline") }
        
        PremiumEmptyStateView(type: .noNotifications)
            .tabItem { Text("Notifications") }
        
        PremiumEmptyStateView(type: .noJournal)
            .tabItem { Text("Journal") }
        
        PremiumEmptyStateView(type: .noCommunity)
            .tabItem { Text("Community") }
        
        PremiumEmptyStateView(type: .noSubscription)
            .tabItem { Text("Subscription") }
    }
    .preferredColorScheme(.dark)
}
