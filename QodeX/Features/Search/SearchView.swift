//
//  SearchView.swift
//  QodeX - Premium Universal Search
//  Inspired by Spotlight, Instagram Search
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    
    enum SearchCategory: String, CaseIterable {
        case all = "All"
        case numbers = "Numbers"
        case articles = "Articles"
        case people = "People"
        case content = "Content"
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
            
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Category Pills
                CategoryPills(selected: $selectedCategory)
                    .padding(.top, 16)
                    .accessibilityLabel("Search categories")
                    .accessibilityHint("Select a category to filter search results")
                
                if searchText.isEmpty {
                    // Default State
                    SearchDefaultState()
                } else {
                    // Results
                    SearchResultsList(query: searchText, category: selectedCategory)
                }
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    @FocusState private isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundColor(.starlightTertiary)
                .accessibilityHidden(true)
            
            TextField("Search numbers, articles, people...", text: $text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.starlight)
                .focused($isFocused)
                .accessibilityLabel("Search field")
                .accessibilityHint("Enter text to search for numbers, articles, or people")
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.starlightTertiary)
                }
                .accessibilityLabel("Clear search")
                .accessibilityHint("Double tap to clear the current search text")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "12121A"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.goldPrimary.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isFocused ? 2 : 1)
        )
    }
}

// MARK: - Category Pills
struct CategoryPills: View {
    @Binding var selected: SearchView.SearchCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchView.SearchCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        isSelected: selected == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = category
                        }
                    }
                    .accessibilityLabel("\(category.rawValue) category filter")
                    .accessibilityHint("Double tap to filter results by \(category.rawValue.lowercased())")
                    .accessibilityValue(selected == category ? "Selected" : "Not selected")
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
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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

// MARK: - Search Default State
struct SearchDefaultState: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Recent Searches
                RecentSearchesSection()
                
                // Trending
                TrendingSection()
                
                // Popular Numbers
                PopularNumbersSection()
                
                // Discover
                DiscoverSection()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Recent Searches
struct RecentSearchesSection: View {
    let recentSearches = ["Life Path 7", "Master Numbers", "Compatibility"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.starlight)
                    .accessibilityLabel("Recent searches")
                
                Spacer()
                
                Button("Clear") {}
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.goldPrimary)
                    .accessibilityLabel("Clear recent searches")
                    .accessibilityHint("Double tap to clear all recent search history")
            }
            
            ForEach(recentSearches, id: \.self) { search in
                RecentSearchRow(query: search)
            }
        }
    }
}

struct RecentSearchRow: View {
    let query: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18))
                    .foregroundColor(.starlightTertiary)
                    .accessibilityHidden(true)
                
                Text(query)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlight)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.starlightQuaternary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Recent search: \(query)")
        .accessibilityHint("Double tap to search for \(query)")
    }
}

// MARK: - Trending Section
struct TrendingSection: View {
    let trending = [
        ("🔥", "Master Numbers Explained", "12K searches"),
        ("📈", "2026 Predictions", "8K searches"),
        ("💫", "Life Path Compatibility", "6K searches")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
                .accessibilityLabel("Trending searches")
        
            ForEach(trending, id: \.1) { item in
                TrendingRow(emoji: item.0, title: item.1, count: item.2)
            }
        }
    }
}

struct TrendingRow: View {
    let emoji: String
    let title: String
    let count: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.starlight)
                    
                    Text(count)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 16))
                    .foregroundColor(.goldPrimary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Trending: \(title), \(count)")
        .accessibilityHint("Double tap to view this trending topic")
    }
}

// MARK: - Popular Numbers
struct PopularNumbersSection: View {
    let numbers = Array(1...9)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Numbers")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
                .accessibilityLabel("Popular numbers")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(numbers, id: \.self) { number in
                    PopularNumberCard(number: number)
                }
            }
        }
    }
}

struct PopularNumberCard: View {
    let number: Int
    
    var color: Color {
        switch number {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        case 6: return .purple
        case 7: return .pink
        case 8: return .goldPrimary
        case 9: return .cyan
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Text("\(number)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(numberName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.starlightTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Number \(number), \(numberName)")
        .accessibilityHint("Double tap to learn about the meaning of number \(number)")
    }
    
    var numberName: String {
        switch number {
        case 1: return "Leader"
        case 2: return "Peacemaker"
        case 3: return "Creative"
        case 4: return "Builder"
        case 5: return "Freedom"
        case 6: return "Nurturer"
        case 7: return "Seeker"
        case 8: return "Power"
        case 9: return "Humanitarian"
        default: return ""
        }
    }
}

// MARK: - Discover Section
struct DiscoverSection: View {
    let topics = [
        ("🔮", "Numerology Basics", "Start here"),
        ("❤️", "Love Compatibility", "Find your match"),
        ("💼", "Career Paths", "Your calling"),
        ("✨", "Master Numbers", "11, 22, 33")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discover")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.starlight)
                .accessibilityLabel("Discover section")
            
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                ForEach(topics, id: \.1) { topic in
                    DiscoverCard(emoji: topic.0, title: topic.1, subtitle: topic.2)
                }
            }
        }
    }
}

struct DiscoverCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 8) {
                Text(emoji)
                    .font(.system(size: 32))
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.starlight)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.starlightTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityHint("Double tap to explore \(title)")
    }
}

// MARK: - Search Results
struct SearchResultsList: View {
    let query: String
    let category: SearchView.SearchCategory
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(0..<5) { index in
                    SearchResultRow(index: index)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .accessibilityLabel("Search results for \(query)")
    }
}

struct SearchResultRow: View {
    let index: Int
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.goldPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundColor(.goldPrimary)
                }
                .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Understanding Life Path Numbers")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.starlight)
                    
                    Text("Article • 8 min read")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.starlightQuaternary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "12121A").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Result \(index + 1): Understanding Life Path Numbers, Article, 8 minute read")
        .accessibilityHint("Double tap to open this article")
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
