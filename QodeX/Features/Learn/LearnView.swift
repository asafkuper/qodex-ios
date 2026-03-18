//
//  LearnView.swift
//  QodeX - Premium Education Hub
//  Inspired by MasterClass, Duolingo
//

import SwiftUI

struct LearnView: View {
    @State private var selectedCategory: Category = .all
    @State private var searchText = ""
    
    enum Category: String, CaseIterable {
        case all = "All"
        case basics = "Basics"
        case advanced = "Advanced"
        case master = "Master"
        case video = "Video"
    }
    
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
                        Text("Learn")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.starlight)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.starlightTertiary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Daily Wisdom
                    DailyWisdomCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Category Pills
                    CategoryScrollView(selected: $selectedCategory)
                        .padding(.top, 24)
                    
                    // Featured Article
                    FeaturedArticleCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Continue Learning
                    ContinueLearningSection()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // All Lessons Grid
                    LessonsGrid()
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Daily Wisdom Card
struct DailyWisdomCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("✨")
                        .font(.system(size: 24))
                    
                    Text("Daily Wisdom")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17))
                            .foregroundColor(.starlightTertiary)
                    }
                }
                
                Text("\"The numbers are the Universal language offered by the deity to humans as confirmation of the truth.\"")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.starlight)
                    .italic()
                    .lineSpacing(4)
                
                Text("— St. Augustine")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
        }
    }
}

// MARK: - Category Scroll
struct CategoryScrollView: View {
    @Binding var selected: LearnView.Category
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LearnView.Category.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        isSelected: selected == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .cosmicBlack : .starlight)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.goldPrimary : Color.white.opacity(0.05))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Featured Article
struct FeaturedArticleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                VStack(spacing: 8) {
                    Text("🔮")
                        .font(.system(size: 48))
                    
                    Text("Master Numbers")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.starlight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("FEATURED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cosmicBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.goldPrimary)
                        )
                    
                    Text("15 min read")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Text("Understanding 11, 22, and 33: The Master Numbers")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
                
                Text("Discover the heightened spiritual significance and challenges of Master Numbers in your chart.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                    .lineLimit(2)
            }
            .padding(20)
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

// MARK: - Continue Learning
struct ContinueLearningSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Learning")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                Button("See All") {}
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.goldPrimary)
            }
            
            ProgressLessonCard(
                title: "Life Path Numbers",
                subtitle: "Lesson 3 of 7",
                progress: 0.43,
                icon: "🎯"
            )
        }
    }
}

struct ProgressLessonCard: View {
    let title: String
    let subtitle: String
    let progress: Double
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.goldPrimary.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Text(icon)
                    .font(.system(size: 32))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.starlight)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.starlightTertiary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.goldPrimary)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.goldPrimary)
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

// MARK: - Lessons Grid
struct LessonsGrid: View {
    let lessons = [
        (title: "Expression Number", duration: "8 min", icon: "✨", color: Color.blue),
        (title: "Soul Urge", duration: "10 min", icon: "💫", color: Color.purple),
        (title: "Birthday Number", duration: "6 min", icon: "🎂", color: Color.pink),
        (title: "Personal Year", duration: "12 min", icon: "📅", color: Color.green),
        (title: "Challenge Numbers", duration: "15 min", icon: "⚡", color: Color.orange),
        (title: "Pinnacle Cycles", duration: "14 min", icon: "🏔", color: Color.cyan)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Lessons")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(lessons, id: \.title) { lesson in
                    LessonCard(
                        title: lesson.title,
                        duration: lesson.duration,
                        icon: lesson.icon,
                        color: lesson.color
                    )
                }
            }
        }
    }
}

struct LessonCard: View {
    let title: String
    let duration: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.starlightTertiary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.starlight)
                    .lineLimit(1)
                
                Text(duration)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
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

// MARK: - Preview
struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
            .preferredColorScheme(.dark)
    }
}
