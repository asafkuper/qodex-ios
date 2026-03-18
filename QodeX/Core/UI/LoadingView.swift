//
//  LoadingView.swift
//  QodeX Premium Loading States
//  Reference: iOS 18 Human Interface Guidelines
//

import SwiftUI

// MARK: - Loading States Enum

enum LoadingState {
    case idle
    case loading
    case success
    case error(Error)
    case empty
    
    var isLoading: Bool {
        self == .loading
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var isEmpty: Bool {
        self == .empty
    }
}

// MARK: - Premium Loading View

struct PremiumLoadingView: View {
    let message: String
    let style: LoadingStyle
    
    enum LoadingStyle {
        case `default`
        case shimmer
        case pulse
        case progress(Double)
        case custom(AnyView)
    }
    
    init(message: String = "Loading...", style: LoadingStyle = .default) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 20) {
            loadingIndicator
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(QXColor.starlight)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        switch style {
        case .default:
            ProgressView()
                .scaleEffect(1.5)
                .tint(QXColor.gold)
        
        case .shimmer:
            ShimmerLoadingView()
        
        case .pulse:
            PulseLoadingView()
        
        case .progress(let value):
            CircularProgressView(progress: value)
        
        case .custom(let view):
            view
        }
    }
}

// MARK: - Shimmer Loading View

struct ShimmerLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(QXColor.starlight.opacity(0.3))
                .frame(width: 60, height: 60)
            
            // Shimmer effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            QXColor.gold.opacity(0.5),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Center icon
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(QXColor.gold)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Pulse Loading View

struct PulseLoadingView: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(QXColor.gold.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                    .frame(width: 50 + CGFloat(i * 20), height: 50 + CGFloat(i * 20))
                    .scaleEffect(pulse ? 1.2 : 0.8)
                    .opacity(pulse ? 0.2 : 0.6)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .delay(Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: pulse
                    )
            }
            
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundColor(QXColor.gold)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(QXColor.starlight.opacity(0.3), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [QXColor.gold, QXColor.goldGlow, QXColor.gold],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: animatedProgress)
            
            // Percentage text
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(QXColor.gold)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}

// MARK: - Skeleton Loading

struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isLoading {
                        ZStack {
                            // Base overlay
                            Color.deepVoid.opacity(0.7)
                            
                            // Shimmer effect
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    Color.white.opacity(0.1),
                                    .clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geo.size.width * 2)
                            .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                            .onAppear {
                                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                    phase = 1
                                }
                            }
                        }
                        .mask(content)
                    }
                }
            )
            .redacted(reason: isLoading ? .placeholder : [])
    }
}

extension View {
    /// Applies skeleton loading effect
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}

// MARK: - Skeleton Placeholder Views

struct SkeletonCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(QXColor.starlight.opacity(0.3))
            .frame(height: 120)
            .skeleton(isLoading: true)
    }
}

struct SkeletonText: View {
    let lines: Int
    
    init(lines: Int = 1) {
        self.lines = lines
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<lines, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(QXColor.starlight.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: i == lines - 1 ? 0.6 : 1.0, alignment: .leading)
            }
        }
        .skeleton(isLoading: true)
    }
}

struct SkeletonAvatar: View {
    let size: CGFloat
    
    init(size: CGFloat = 60) {
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(QXColor.starlight.opacity(0.3))
            .frame(width: size, height: size)
            .skeleton(isLoading: true)
    }
}

// MARK: - Loading State Modifier

struct LoadingStateModifier: ViewModifier {
    let state: LoadingState
    let onRetry: (() -> Void)?
    let emptyView: AnyView?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(state == .loading ? 0.3 : 1)
                .disabled(state == .loading)
            
            switch state {
            case .loading:
                PremiumLoadingView()
            
            case .error(let error):
                ErrorStateView(error: error, retry: onRetry)
            
            case .empty:
                emptyView ?? AnyView(
                    EmptyStateView(
                        icon: "tray",
                        title: "No Data",
                        message: "There's nothing here yet."
                    )
                )
            
            default:
                EmptyView()
            }
        }
    }
}

extension View {
    /// Manages loading, error, and empty states
    func loadingState(
        _ state: LoadingState,
        onRetry: (() -> Void)? = nil,
        emptyView: AnyView? = nil
    ) -> some View {
        modifier(LoadingStateModifier(
            state: state,
            onRetry: onRetry,
            emptyView: emptyView
        ))
    }
}

// MARK: - Pull to Refresh

struct PullToRefreshModifier: ViewModifier {
    let onRefresh: () async -> Void
    @State private var isRefreshing = false
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                isRefreshing = true
                QXHaptic.mediumImpact()
                await onRefresh()
                isRefreshing = false
                QXHaptic.success()
            }
    }
}

extension View {
    /// Adds pull-to-refresh with haptic feedback
    func pullToRefresh(onRefresh: @escaping () async -> Void) -> some View {
        modifier(PullToRefreshModifier(onRefresh: onRefresh))
    }
}

// MARK: - Progress Bar

struct PremiumProgressBar: View {
    let progress: Double
    let style: Style
    
    enum Style {
        case linear
        case rounded
        case gradient
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: style == .linear ? 2 : 4)
                    .fill(QXColor.starlight.opacity(0.3))
                    .frame(height: style == .linear ? 4 : 8)
                
                // Progress
                RoundedRectangle(cornerRadius: style == .linear ? 2 : 4)
                    .fill(progressFill)
                    .frame(width: geometry.size.width * progress, height: style == .linear ? 4 : 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: style == .linear ? 4 : 8)
    }
    
    private var progressFill: some ShapeStyle {
        switch style {
        case .linear, .rounded:
            return QXColor.gold
        case .gradient:
            return LinearGradient(
                colors: [QXColor.gold, QXColor.goldGlow],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Dot Loading Indicator

struct DotLoadingIndicator: View {
    @State private var isAnimating = false
    let color: Color
    
    init(color: Color = QXColor.gold) {
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Preview

#Preview("Loading States") {
    VStack(spacing: 30) {
        PremiumLoadingView(message: "Loading...", style: .default)
        
        PremiumLoadingView(message: "Analyzing...", style: .shimmer)
        
        PremiumLoadingView(message: "Syncing...", style: .pulse)
        
        PremiumLoadingView(message: "Uploading...", style: .progress(0.65))
        
        DotLoadingIndicator()
        
        SkeletonCard()
        
        SkeletonText(lines: 3)
        
        PremiumProgressBar(progress: 0.7, style: .gradient)
            .padding(.horizontal)
    }
    .padding()
    .background(QXColor.cosmicBlack)
}
