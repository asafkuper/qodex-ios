import SwiftUI
import Combine

// MARK: - Enhanced Daily Qode View with Premium Micro-interactions
struct DailyQodeView_Enhanced: View {
    @StateObject private var viewModel = DailyQodeViewModel()
    @State private var isAnimating = false
    @State private var showDetail = false
    @State private var selectedTab = 0
    @State private var refreshID = UUID()
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            // Animated cosmic background
            CosmicBackgroundAnimated()
            
            ScrollView(showsIndicators: false) {
                RefreshControl(coordinateSpaceName: "pullToRefresh") {
                    await refreshData()
                }
                
                VStack(spacing: 28) {
                    // Date header with parallax
                    DateHeaderEnhanced()
                        .staggeredEntrance(index: 0, type: .fadeUp)
                    
                    // Main number display with enhanced interactions
                    MainNumberDisplay(
                        number: viewModel.dailyNumber,
                        isAnimating: $isAnimating,
                        onTap: { showDetail = true }
                    )
                    .staggeredEntrance(index: 1, type: .scale)
                    
                    // Insight card with glass morphism
                    InsightCardEnhanced(
                        title: viewModel.insightTitle,
                        description: viewModel.insightDescription,
                        affirmation: viewModel.affirmation
                    )
                    .staggeredEntrance(index: 2, type: .fadeUp)
                    
                    // Action buttons with haptic feedback
                    ActionButtonsRow(
                        onReadMore: { showDetail = true },
                        onShare: { shareQode() },
                        onFavorite: { toggleFavorite() }
                    )
                    .staggeredEntrance(index: 3, type: .slideLeft)
                    
                    // Weekly preview with selection states
                    WeeklyPreviewEnhanced(
                        selectedDay: viewModel.selectedDay,
                        onSelectDay: { day in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.selectedDay = day
                            }
                            QXHaptic.selection()
                        }
                    )
                    .staggeredEntrance(index: 4, type: .slideRight)
                    
                    // Energy forecast section
                    EnergyForecastCard(
                        energy: viewModel.energyLevel,
                        trend: viewModel.energyTrend
                    )
                    .staggeredEntrance(index: 5, type: .fadeUp)
                }
                .padding()
                .padding(.bottom, 100)
            }
            .coordinateSpace(name: "pullToRefresh")
            
            // Confetti celebration overlay
            if showCelebration {
                ConfettiView(trigger: true)
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showDetail) {
            QodeDetailView_Enhanced(number: viewModel.dailyNumber)
        }
        .onAppear {
            startEntranceAnimations()
        }
    }
    
    private func refreshData() async {
        QXHaptic.refreshTrigger()
        
        // Simulate refresh
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            refreshID = UUID()
            QXToastManager.shared.success("Refreshed", message: "Today's energy updated")
        }
    }
    
    private func startEntranceAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    private func shareQode() {
        QXHaptic.success()
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCelebration = false
        }
        
        QXToastManager.shared.success("Shared!", message: "Your daily Qode has been shared")
    }
    
    private func toggleFavorite() {
        QXHaptic.lightImpact()
        QXToastManager.shared.info("Added to favorites")
    }
}

// MARK: - Main Number Display
struct MainNumberDisplay: View {
    let number: Int
    @Binding var isAnimating: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var showRing = false
    
    var body: some View {
        ZStack {
            // Outer glow with breathing animation
            BreathingGlow()
                .scaleEffect(isAnimating ? 1.1 : 0.9)
            
            // Number ring (appears on press)
            if showRing {
                QXNumberRing(number: number, size: 220, showGlow: true)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Main number button
            QXPressableButton(hapticStyle: .medium, scale: 0.92) {
                onTap()
            } content: {
                ZStack {
                    // Outer circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [QXColor.deepVoid, QXColor.cosmicBlack],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .overlay(
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [QXColor.gold, QXColor.goldGlow, QXColor.gold],
                                        center: .center
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: QXColor.gold.opacity(0.4),
                            radius: 30,
                            x: 0,
                            y: 0
                        )
                    
                    // Number with counting animation
                    QXNumberCounter(
                        value: number,
                        duration: 1.5,
                        font: .system(size: 72, weight: .thin, design: .rounded),
                        color: QXColor.gold
                    )
                    
                    // Subtitle
                    VStack {
                        Spacer()
                        Text("Today's Qode")
                            .font(.caption)
                            .textCase(.uppercase)
                            .tracking(2)
                            .foregroundColor(QXColor.stardust)
                            .padding(.bottom, 20)
                    }
                }
                .frame(width: 180, height: 180)
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showRing.toggle()
                }
                QXHaptic.premiumUnlock()
            }
        }
        .frame(height: 260)
    }
}

// MARK: - Breathing Glow
struct BreathingGlow: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        QXColor.gold.opacity(opacity),
                        QXColor.gold.opacity(0),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 140
                )
            )
            .frame(width: 280, height: 280)
            .blur(radius: 20)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    scale = 1.15
                    opacity = 0.5
                }
            }
            .scaleEffect(scale)
    }
}

// MARK: - Enhanced Date Header
struct DateHeaderEnhanced: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 6) {
            Text(Date().formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 15, weight: .medium))
                .textCase(.uppercase)
                .tracking(3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [QXColor.gold, QXColor.goldGlow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(Date().formatted(.dateTime.day().month(.wide).year()))
                .font(.system(size: 13))
                .foregroundColor(QXColor.stardust)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            Capsule()
                .fill(QXColor.deepVoid.opacity(0.5))
                .overlay(
                    Capsule()
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Enhanced Insight Card
struct InsightCardEnhanced: View {
    let title: String
    let description: String
    let affirmation: String
    
    @State private var isExpanded = false
    @State private var copiedAffirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with icon
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(QXColor.gold)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                    QXHaptic.lightImpact()
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(QXColor.stardust)
                        .font(.system(size: 14, weight: .medium))
                        .padding(8)
                        .background(Circle().fill(QXColor.starlight.opacity(0.1)))
                }
            }
            
            // Description
            Text(description)
                .font(.system(size: 15))
                .foregroundColor(QXColor.stardust)
                .lineSpacing(4)
                .lineLimit(isExpanded ? nil : 3)
            
            if isExpanded {
                Divider()
                    .background(QXColor.gold.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Affirmation section
                HStack(spacing: 12) {
                    Image(systemName: "quote.opening")
                        .foregroundColor(QXColor.gold)
                        .font(.system(size: 20))
                    
                    Text(affirmation)
                        .font(.system(size: 15, weight: .medium))
                        .italic()
                        .foregroundColor(QXColor.gold)
                        .lineSpacing(3)
                    
                    Spacer()
                    
                    Button(action: {
                        UIPasteboard.general.string = affirmation
                        copiedAffirmation = true
                        QXHaptic.success()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedAffirmation = false
                        }
                    }) {
                        Image(systemName: copiedAffirmation ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundColor(copiedAffirmation ? QXColor.success : QXColor.stardust)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(QXColor.gold.opacity(0.1))
                )
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                QXColor.gold.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(QXColor.gold.opacity(0.15), lineWidth: 1)
            }
        )
    }
}

// MARK: - Action Buttons Row
struct ActionButtonsRow: View {
    let onReadMore: () -> Void
    let onShare: () -> Void
    let onFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Read More Button
            QXBouncyButton(title: "Read More", icon: "book.fill") {
                onReadMore()
            }
            .frame(maxWidth: .infinity)
            
            // Share Button
            ActionIconButton(icon: "square.and.arrow.up", action: onShare)
            
            // Favorite Button
            ActionIconButton(icon: "heart", action: onFavorite)
        }
    }
}

// MARK: - Action Icon Button
struct ActionIconButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(QXColor.deepVoid)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .pressGesture { pressing in
            isPressed = pressing
            if pressing {
                QXHaptic.lightImpact()
            }
        }
    }
}

// MARK: - Weekly Preview Enhanced
struct WeeklyPreviewEnhanced: View {
    let selectedDay: Date
    let onSelectDay: (Date) -> Void
    
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    let numbers = [5, 6, 7, 8, 9, 1, 2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View Calendar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(QXColor.gold)
                }
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    let isSelected = index == 2
                    DayPreviewEnhanced(
                        day: days[index],
                        number: numbers[index],
                        isSelected: isSelected
                    )
                    .onTapGesture {
                        QXHaptic.selection()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Day Preview Enhanced
struct DayPreviewEnhanced: View {
    let day: String
    let number: Int
    let isSelected: Bool
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 10) {
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? QXColor.gold : QXColor.stardust)
            
            Text("\(number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? QXColor.gold : .white)
                .frame(width: 40, height: 40)
                .background(
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(QXColor.gold.opacity(0.2))
                            
                            Circle()
                                .stroke(QXColor.gold, lineWidth: 1.5)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                        }
                    }
                )
                .scaleEffect(scale)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Energy Forecast Card
struct EnergyForecastCard: View {
    let energy: Int
    let trend: Trend
    
    enum Trend {
        case rising, falling, stable
        
        var icon: String {
            switch self {
            case .rising: return "arrow.up.forward"
            case .falling: return "arrow.down.forward"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .rising: return QXColor.success
            case .falling: return QXColor.warning
            case .stable: return QXColor.stardust
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Energy icon
            ZStack {
                Circle()
                    .fill(QXColor.gold.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20))
                    .foregroundColor(QXColor.gold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Energy Forecast")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(energy)% • High vibrational day")
                    .font(.system(size: 13))
                    .foregroundColor(QXColor.stardust)
            }
            
            Spacer()
            
            // Trend indicator
            HStack(spacing: 4) {
                Image(systemName: trend.icon)
                    .font(.system(size: 12, weight: .bold))
                Text("12%")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(trend.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(trend.color.opacity(0.15))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid.opacity(0.6))
        )
    }
}

// MARK: - Enhanced Qode Detail View
struct QodeDetailView_Enhanced: View {
    let number: Int
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Number header with animation
                    QXLifePathReveal(lifePathNumber: number) {
                        // Completion callback
                    }
                    
                    // Tab selector
                    Picker("", selection: $selectedTab) {
                        Text("Today").tag(0)
                        Text("Week").tag(1)
                        Text("Month").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedTab) { _, _ in
                        QXHaptic.selection()
                    }
                    
                    // Content based on tab
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(title: "Today's Energy")
                        
                        Text(QodeInsights.fullDescriptions[number] ?? "")
                            .font(.body)
                            .foregroundColor(QXColor.stardust)
                            .lineSpacing(6)
                        
                        SectionHeader(title: "Best Activities")
                        
                        ActivityList_Enhanced(activities: QodeInsights.activities[number] ?? [])
                        
                        SectionHeader(title: "Things to Avoid")
                        
                        ActivityList_Enhanced(
                            activities: QodeInsights.avoidances[number] ?? [],
                            isNegative: true
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Daily Qode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(QXColor.gold)
                }
            }
            .background(QXColor.cosmicBlack.ignoresSafeArea())
        }
    }
}

// MARK: - Activity List Enhanced
struct ActivityList_Enhanced: View {
    let activities: [String]
    var isNegative: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(activities.enumerated()), id: \.element) { index, activity in
                HStack(spacing: 12) {
                    Image(systemName: isNegative ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(isNegative ? QXColor.warning : QXColor.success)
                        .font(.system(size: 18))
                    
                    Text(activity)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isNegative ? QXColor.warning.opacity(0.05) : QXColor.success.opacity(0.05))
                )
                .padding(.bottom, 8)
                .staggeredTransition(index: index, delay: 0.05)
            }
        }
    }
}

// MARK: - Cosmic Background Animated
struct CosmicBackgroundAnimated: View {
    @State private var starOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [QXColor.cosmicBlack, QXColor.deepVoid],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated stars
            GeometryReader { geo in
                ForEach(0..<50) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height) + starOffset
                        )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                    starOffset = 100
                }
            }
            
            // Nebula effect
            RadialGradient(
                colors: [QXColor.gold.opacity(0.05), Color.clear],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Refresh Control
struct RefreshControl: View {
    let coordinateSpaceName: String
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .named(coordinateSpaceName)).minY
            
            if offset > 0 || isRefreshing {
                HStack {
                    Spacer()
                    
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: QXColor.gold))
                                .scaleEffect(1.2)
                        } else {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(QXColor.gold)
                                .rotationEffect(.degrees(min(Double(offset) * 2, 180)))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(QXColor.deepVoid)
                    )
                    
                    Spacer()
                }
                .frame(height: max(0, offset))
                .onChange(of: offset) { _, newValue in
                    progress = newValue / 100
                    
                    if newValue > 100 && !isRefreshing {
                        isRefreshing = true
                        
                        Task {
                            await onRefresh()
                            isRefreshing = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct DailyQodeView_Enhanced_Previews: PreviewProvider {
    static var previews: some View {
        DailyQodeView_Enhanced()
            .preferredColorScheme(.dark)
            .withToasts()
    }
}
