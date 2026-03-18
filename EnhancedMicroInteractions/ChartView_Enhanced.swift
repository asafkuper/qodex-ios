//
//  ChartView_Enhanced.swift
//  Premium Chart Screen with Micro-interactions
//  Reference: iOS 18 HIG, Robinhood, Things 3
//

import SwiftUI

struct ChartView_Enhanced: View {
    @State private var selectedNumber: Int? = nil
    @State private var selectedCardIndex: Int? = nil
    @State private var isHeaderExpanded = true
    @State private var scrollOffset: CGFloat = 0
    @State private var showUnlockAnimation = false
    
    let coreNumbers = [
        CoreNumber(value: 7, type: .lifePath, title: "The Seeker", subtitle: "Spiritual • Analytical • Wise", color: .goldPrimary),
        CoreNumber(value: 3, type: .expression, title: "Creative", subtitle: "Artist • Communicator", color: .goldPrimary),
        CoreNumber(value: 6, type: .soulUrge, title: "Nurturing", subtitle: "Harmony • Compassion", color: .purple),
        CoreNumber(value: 9, type: .personality, title: "Humanitarian", subtitle: "Universal • Completion", color: .blue),
        CoreNumber(value: 15, type: .birthday, title: "Leadership", subtitle: "Independence • Vision", color: Color(hex: "2ECC71"))
    ]
    
    var body: some View {
        ZStack {
            // Background
            ChartBackground()
            
            ScrollView(showsIndicators: false) {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("chartScroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Header with collapse on scroll
                    ChartHeader(
                        isExpanded: $isHeaderExpanded,
                        scrollOffset: scrollOffset
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    // Hero Card - Life Path with enhanced animation
                    HeroCard_Enhanced(number: coreNumbers[0])
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .staggeredEntrance(index: 0, type: .scale)
                        .onTapGesture {
                            selectCard(at: 0)
                        }
                    
                    // Numbers grid with interactive cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(Array(coreNumbers.dropFirst().enumerated()), id: \.element.id) { index, number in
                            NumberGridCard_Enhanced(
                                number: number,
                                isSelected: selectedCardIndex == index + 1,
                                index: index
                            )
                            .onTapGesture {
                                selectCard(at: index + 1)
                            }
                            .staggeredEntrance(index: index + 1, type: .fadeUp)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Unlock banner with interaction
                    UnlockBanner_Enhanced(showAnimation: $showUnlockAnimation)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                        .staggeredEntrance(index: coreNumbers.count, type: .slideUp)
                }
            }
            .coordinateSpace(name: "chartScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHeaderExpanded = scrollOffset < 50
                }
            }
            
            // Collapsed header overlay
            if !isHeaderExpanded {
                CollapsedHeader()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Unlock celebration overlay
            if showUnlockAnimation {
                PremiumUnlockCelebration()
                    .transition(.opacity)
            }
        }
        .sheet(item: $selectedNumber) { number in
            NumberDetailSheet(number: number)
        }
    }
    
    private func selectCard(at index: Int) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCardIndex == index {
                selectedCardIndex = nil
            } else {
                selectedCardIndex = index
            }
        }
        
        // Show detail after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedNumber = coreNumbers[index].value
        }
    }
}

// MARK: - Chart Background
struct ChartBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "0d0d14")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated mesh gradient
            RadialGradient(
                colors: [
                    Color.goldPrimary.opacity(animateGradient ? 0.08 : 0.05),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Subtle grid pattern
            GridPattern()
                .opacity(0.03)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Grid Pattern
struct GridPattern: View {
    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 40
            
            // Draw vertical lines
            for x in stride(from: 0, to: size.width, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white), lineWidth: 0.5)
            }
            
            // Draw horizontal lines
            for y in stride(from: 0, to: size.height, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - Chart Header
struct ChartHeader: View {
    @Binding var isExpanded: Bool
    let scrollOffset: CGFloat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Chart")
                    .font(.system(size: isExpanded ? 28 : 20, weight: .bold))
                    .foregroundColor(.starlight)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                
                if isExpanded {
                    Text("5 Core Numbers")
                        .font(.system(size: 15))
                        .foregroundColor(.starlightTertiary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            Spacer()
            
            // Settings button with press effect
            MagneticButton(strength: 15) {
                QXHaptic.lightImpact()
            } content: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.starlightTertiary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Settings")
        }
    }
}

// MARK: - Collapsed Header
struct CollapsedHeader: View {
    var body: some View {
        HStack {
            Text("Your Chart")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Enhanced Hero Card
struct HeroCard_Enhanced: View {
    let number: CoreNumber
    
    @State private var isPressed = false
    @State private var showGlow = false
    
    var body: some View {
        QXPressableButton(hapticStyle: .medium, scale: 0.97) {
            // Action
        } content: {
            ZStack {
                // Gradient background with shimmer
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(0.2),
                                Color.goldPrimary.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shimmering(active: true)
                
                // Glow orb
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(showGlow ? 0.3 : 0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .offset(x: 80, y: -80)
                    .blur(radius: 20)
                
                // Border with gradient
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.goldPrimary.opacity(0.4), Color.goldPrimary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Label badge
                    HStack {
                        Text(number.type.rawValue + " Number")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "B8954C"))
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Spacer()
                        
                        // Crown icon for primary number
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.goldPrimary)
                    }
                    .padding(.bottom, 16)
                    
                    HStack(spacing: 20) {
                        // Number with counting animation
                        QXNumberCounter(
                            value: number.value,
                            duration: 1.2,
                            font: .system(size: 64, weight: .bold, design: .rounded),
                            color: Color.goldPrimary
                        )
                        .shadow(color: Color.goldPrimary.opacity(0.3), radius: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(number.title)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.starlight)
                            
                            Text(number.subtitle)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.starlightTertiary)
                        }
                        
                        Spacer()
                        
                        // Expand indicator
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.goldPrimary)
                            .opacity(0.6)
                    }
                }
                .padding(28)
            }
        }
        .frame(height: 160)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

// MARK: - Enhanced Number Grid Card
struct NumberGridCard_Enhanced: View {
    let number: CoreNumber
    let isSelected: Bool
    let index: Int
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        QXPressableButton(hapticStyle: .light, scale: 0.95) {
            // Action
        } content: {
            ZStack {
                // Background with selection state
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected 
                            ? number.color.opacity(0.15)
                            : Color(hex: "12121A").opacity(0.6)
                    )
                
                // Top highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                
                // Selection glow
                if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(number.color.opacity(0.6), lineWidth: 2)
                        .shadow(color: number.color.opacity(0.4), radius: 15, x: 0, y: 0)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(number.type.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.starlightTertiary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(number.color)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 12)
                    
                    QXNumberCounter(
                        value: number.value,
                        duration: 0.8 + Double(index) * 0.1,
                        font: .system(size: 36, weight: .bold, design: .rounded),
                        color: number.color
                    )
                    .padding(.bottom, 4)
                    
                    Text(number.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.starlightSecondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 140)
        .scaleEffect(scale)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onChange(of: isSelected) { _, selected in
            if selected {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.02
                    rotation = 2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        rotation = 0
                    }
                }
            } else {
                scale = 1.0
            }
        }
    }
}

// MARK: - Enhanced Unlock Banner
struct UnlockBanner_Enhanced: View {
    @Binding var showAnimation: Bool
    @State private var isPressed = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        QXPressableButton(hapticStyle: .medium, scale: 0.97) {
            showAnimation = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showAnimation = false
            }
        } content: {
            HStack(spacing: 16) {
                // Animated icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.goldPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text("✦")
                        .font(.system(size: 24))
                        .foregroundColor(Color.goldPrimary)
                        .rotationEffect(.degrees(isPressed ? 180 : 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPressed)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock 5 More Numbers")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.goldPrimary)
                    
                    Text("See your complete blueprint")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.starlightTertiary)
                }
                
                Spacer()
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.goldPrimary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.goldPrimary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.goldPrimary.opacity(0.12),
                                Color.goldPrimary.opacity(0.03)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 1.5,
                            dash: [8, 6]
                        )
                    )
                    .foregroundColor(Color.goldPrimary.opacity(0.4))
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                progress = 1
            }
        }
    }
}

// MARK: - Number Detail Sheet
struct NumberDetailSheet: View {
    let number: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Number reveal
                    QXLifePathReveal(lifePathNumber: number)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Your \(number) Energy")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(QodeInsights.fullDescriptions[number] ?? "")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                        
                        // Traits section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Traits")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(getTraits(for: number), id: \.self) { trait in
                                    TraitBadge(text: trait)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Number Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getTraits(for number: Int) -> [String] {
        let traits: [Int: [String]] = [
            1: ["Leadership", "Independence", "Innovation", "Ambition"],
            2: ["Cooperation", "Diplomacy", "Sensitivity", "Intuition"],
            3: ["Creativity", "Expression", "Optimism", "Social"],
            4: ["Stability", "Practicality", "Discipline", "Organization"],
            5: ["Freedom", "Adaptability", "Adventure", "Change"],
            6: ["Harmony", "Responsibility", "Nurturing", "Service"],
            7: ["Wisdom", "Analysis", "Spirituality", "Introspection"],
            8: ["Power", "Success", "Authority", "Material Wealth"],
            9: ["Compassion", "Humanitarian", "Completion", "Universal Love"]
        ]
        return traits[number] ?? []
    }
}

// MARK: - Trait Badge
struct TraitBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(QXColor.gold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(QXColor.gold.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview
struct ChartView_Enhanced_Previews: PreviewProvider {
    static var previews: some View {
        ChartView_Enhanced()
            .preferredColorScheme(.dark)
            .withToasts()
    }
}
