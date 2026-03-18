//
//  QXScrollEffects.swift
//  QodeX Premium Scroll Effects
//  Reference: iOS 18 Photos app, Things 3, Headspace
//

import SwiftUI

// MARK: - Parallax Header
public struct QXParallaxHeader<Content: View, Header: View>: View {
    let content: Content
    let header: Header
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let parallaxFactor: CGFloat
    
    @State private var scrollOffset: CGFloat = 0
    
    public init(
        minHeight: CGFloat = 100,
        maxHeight: CGFloat = 300,
        parallaxFactor: CGFloat = 0.5,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.parallaxFactor = parallaxFactor
        self.header = header()
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    // Parallax header
                    GeometryReader { headerGeo in
                        let offset = headerGeo.frame(in: .global).minY
                        let height = max(minHeight, maxHeight + offset * parallaxFactor)
                        
                        header
                            .frame(width: geo.size.width, height: height)
                            .clipped()
                            .offset(y: offset > 0 ? -offset * (1 - parallaxFactor) : 0)
                            .onChange(of: offset) { _, newValue in
                                scrollOffset = newValue
                            }
                    }
                    .frame(height: maxHeight)
                    
                    // Content
                    content
                        .background(QXColor.cosmicBlack)
                }
            }
            .coordinateSpace(name: "parallax")
        }
    }
}

// MARK: - Sticky Header
public struct QXStickyHeader<Content: View, Header: View>: View {
    let content: Content
    let header: Header
    let headerHeight: CGFloat
    let collapseThreshold: CGFloat
    
    @State private var scrollOffset: CGFloat = 0
    @State private var headerProgress: CGFloat = 0
    
    public init(
        headerHeight: CGFloat = 200,
        collapseThreshold: CGFloat = 150,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.headerHeight = headerHeight
        self.collapseThreshold = collapseThreshold
        self.header = header()
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    // Expandable header
                    GeometryReader { headerGeo in
                        let offset = headerGeo.frame(in: .global).minY
                        let progress = min(1, max(0, -offset / collapseThreshold))
                        
                        header
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(1 - progress * 0.5)
                            .scaleEffect(1 - progress * 0.1)
                            .onChange(of: progress) { _, newValue in
                                headerProgress = newValue
                            }
                    }
                    .frame(height: max(headerHeight - scrollOffset, 60))
                    
                    // Main content
                    content
                }
            }
            .overlay(alignment: .top) {
                // Collapsed header
                if headerProgress > 0.8 {
                    HStack {
                        Text("QodeX")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Pull to Refresh
public struct QXPullToRefresh: View {
    let coordinateSpaceName: String
    let onRefresh: () async -> Void
    let tintColor: Color
    
    @State private var isRefreshing = false
    @State private var pullProgress: CGFloat = 0
    @State private var rotation: Double = 0
    
    public init(
        coordinateSpaceName: String,
        tintColor: Color = QXColor.gold,
        onRefresh: @escaping () async -> Void
    ) {
        self.coordinateSpaceName = coordinateSpaceName
        self.tintColor = tintColor
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .named(coordinateSpaceName)).minY
            
            if offset > 0 {
                ZStack {
                    // Background
                    Circle()
                        .fill(QXColor.deepVoid)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    if isRefreshing {
                        // Loading indicator
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(tintColor, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .rotationEffect(.degrees(rotation))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    rotation = 360
                                }
                            }
                    } else {
                        // Arrow
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(tintColor)
                            .rotationEffect(.degrees(min(Double(offset) * 2, 180)))
                            .opacity(min(Double(offset) / 60, 1))
                    }
                }
                .frame(maxWidth: .infinity)
                .offset(y: min(offset / 2, 50) - 50)
                .onChange(of: offset) { _, newValue in
                    pullProgress = newValue / 100
                    
                    if newValue > 100 && !isRefreshing {
                        isRefreshing = true
                        QXHaptic.refreshTrigger()
                        
                        Task {
                            await onRefresh()
                            withAnimation {
                                isRefreshing = false
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 0)
    }
}

// MARK: - Bouncy Scroll Indicator
public struct QXBouncyScrollIndicator: View {
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    public var body: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .global)
            
            Circle()
                .fill(QXColor.gold.opacity(0.5))
                .frame(width: 4, height: 40)
                .offset(y: offset)
                .position(x: frame.width - 6, y: frame.midY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        offset = isDragging ? 0 : sin(Date().timeIntervalSince1970) * 5
                    }
                }
        }
    }
}

// MARK: - Sticky Section Header
public struct QXStickySectionHeader: View {
    let title: String
    let subtitle: String?
    let isSticky: Bool
    
    @State private var isAtTop = false
    
    public init(title: String, subtitle: String? = nil, isSticky: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.isSticky = isSticky
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(QXColor.stardust)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(QXColor.disabled)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                QXColor.cosmicBlack
                
                if isAtTop && isSticky {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        )
    }
}

// MARK: - Scroll Progress Indicator
public struct QXScrollProgressIndicator: View {
    let progress: CGFloat
    let color: Color
    
    public init(progress: CGFloat, color: Color = QXColor.gold) {
        self.progress = progress
        self.color = color
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 2)
                
                // Progress fill
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress, height: 2)
                    .animation(.easeInOut(duration: 0.1), value: progress)
                
                // Glow at progress point
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
                    .offset(x: geo.size.width * progress - 3, y: 0)
                    .animation(.easeInOut(duration: 0.1), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Scroll View with Progress
public struct QXScrollViewWithProgress<Content: View>: View {
    let content: Content
    let showProgress: Bool
    let onScroll: ((CGFloat) -> Void)?
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    
    public init(
        showProgress: Bool = true,
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showProgress = showProgress
        self.onScroll = onScroll
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geo in
            let viewportHeight = geo.size.height
            
            ScrollView {
                content
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear
                                .onAppear {
                                    contentHeight = contentGeo.size.height
                                }
                                .onChange(of: contentGeo.size.height) { _, newValue in
                                    contentHeight = newValue
                                }
                        }
                    )
                    .background(
                        GeometryReader { scrollGeo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: scrollGeo.frame(in: .named("scroll")).minY)
                        }
                    )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
                onScroll?(scrollOffset)
            }
            .overlay(alignment: .top) {
                if showProgress && contentHeight > viewportHeight {
                    let progress = min(1, max(0, scrollOffset / (contentHeight - viewportHeight)))
                    QXScrollProgressIndicator(progress: progress)
                }
            }
        }
    }
}

// MARK: - Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Fade Edge Modifier
public struct FadeEdgeModifier: ViewModifier {
    let edge: Edge
    let length: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: length / 100),
                        .init(color: .black, location: 1 - length / 100),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: edge == .top ? .top : .leading,
                    endPoint: edge == .bottom ? .bottom : .trailing
                )
            )
    }
}

public extension View {
    func fadeEdge(_ edge: Edge, length: CGFloat = 20) -> some View {
        modifier(FadeEdgeModifier(edge: edge, length: length))
    }
}

// MARK: - Elastic Pull Effect
public struct QXElasticPullEffect: ViewModifier {
    @State private var pullOffset: CGFloat = 0
    let maxPull: CGFloat
    let resistance: CGFloat
    
    public init(maxPull: CGFloat = 100, resistance: CGFloat = 2.5) {
        self.maxPull = maxPull
        self.resistance = resistance
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(y: pullOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let rawOffset = value.translation.height
                        pullOffset = max(0, rawOffset / resistance)
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            pullOffset = 0
                        }
                    }
            )
    }
}

public extension View {
    func elasticPull(maxPull: CGFloat = 100, resistance: CGFloat = 2.5) -> some View {
        modifier(QXElasticPullEffect(maxPull: maxPull, resistance: resistance))
    }
}

// MARK: - Preview
#Preview("Scroll Effects") {
    QXScrollViewWithProgress { offset in
        print("Scroll offset: \(offset)")
    } content: {
        VStack(spacing: 20) {
            // Parallax header demo
            ForEach(0..<20) { i in
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.deepVoid)
                    .frame(height: 100)
                    .overlay(
                        Text("Item \(i + 1)")
                            .foregroundColor(.white)
                    )
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .background(QXColor.cosmicBlack)
}
