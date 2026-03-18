import SwiftUI

struct LibraryView: View {
    @State private var selectedCategory: TeachingCategory = .all
    @State private var searchText = ""
    
    enum TeachingCategory: String, CaseIterable {
        case all = "All"
        case foundations = "Foundations"
        case advanced = "Advanced"
        case timing = "Timing"
        case relationships = "Relationships"
        case business = "Business"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: QXSpacing.lg) {
                // Header
                VStack(spacing: QXSpacing.sm) {
                    Text("Teachings")
                        .font(QXFont.displayMedium)
                        .foregroundColor(QXColor.starlight)
                    
                    Text("Wisdom from Shani")
                        .font(QXFont.body)
                        .foregroundColor(QXColor.starlight.opacity(0.6))
                }
                .padding(.top)
                
                // Search
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Categories
                CategoryScrollView(selected: $selectedCategory)
                    .padding(.bottom, QXSpacing.sm)
                
                // Featured
                FeaturedTeachingCard()
                    .padding(.horizontal)
                
                // Teaching List
                LazyVStack(spacing: QXSpacing.md) {
                    ForEach(0..<5) { _ in
                        TeachingRow()
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: QXSpacing.xxl)
            }
        }
        .background(SacredGeometryBackground())
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: QXSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(QXColor.starlight.opacity(0.5))
            
            TextField("Search teachings...", text: $text)
                .foregroundColor(QXColor.starlight)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(QXColor.starlight.opacity(0.5))
                }
            }
        }
        .padding()
        .background(QXColor.sacredGeometry)
        .cornerRadius(12)
    }
}

struct CategoryScrollView: View {
    @Binding var selected: LibraryView.TeachingCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: QXSpacing.md) {
                ForEach(LibraryView.TeachingCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        isSelected: selected == category
                    ) {
                        withAnimation(.spring()) {
                            selected = category
                        }
                    }
                }
            }
            .padding(.horizontal)
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
                .font(QXFont.caption)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? QXColor.cosmicBlack : QXColor.starlight)
                .padding(.horizontal, QXSpacing.lg)
                .padding(.vertical, QXSpacing.sm)
                .background(isSelected ? QXColor.gold : QXColor.sacredGeometry)
                .cornerRadius(20)
        }
    }
}

struct FeaturedTeachingCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: QXSpacing.md) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [QXColor.cosmicPurple, QXColor.nebulaBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay(
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("START COURSE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, QXSpacing.sm)
                        }
                    )
                
                VStack(alignment: .leading, spacing: QXSpacing.xs) {
                    Label("Featured Course", systemImage: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.gold)
                    
                    Text("The Complete QodeX Method")
                        .font(QXFont.title)
                        .foregroundColor(QXColor.starlight)
                    
                    Text("A comprehensive journey through numerology, from foundations to mastery. Learn to read the codes that shape reality.")
                        .font(QXFont.body)
                        .foregroundColor(QXColor.starlight.opacity(0.7))
                        .lineLimit(3)
                    
                    HStack(spacing: QXSpacing.lg) {
                        Label("12 hours", systemImage: "clock")
                        Label("24 lessons", systemImage: "list.number")
                        Label("Advanced", systemImage: "chart.bar")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(QXColor.starlight.opacity(0.5))
                }
            }
        }
    }
}

struct TeachingRow: View {
    var body: some View {
        HStack(spacing: QXSpacing.md) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(QXColor.sacredGeometry)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "play.fill")
                        .foregroundColor(QXColor.gold.opacity(0.7))
                )
            
            VStack(alignment: .leading, spacing: QXSpacing.xs) {
                Text("Understanding Master Numbers")
                    .font(QXFont.headline)
                    .foregroundColor(QXColor.starlight)
                
                Text("The spiritual significance of 11, 22, and 33 in your chart")
                    .font(.system(size: 14))
                    .foregroundColor(QXColor.starlight.opacity(0.6))
                    .lineLimit(2)
                
                HStack {
                    Label("45 min", systemImage: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.starlight.opacity(0.4))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(QXColor.gold)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(QXColor.deepVoid.opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(QXColor.gold.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    LibraryView()
}
