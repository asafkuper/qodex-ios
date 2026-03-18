//
//  Transitions.swift
//  QodeX Custom Transitions - iOS 18 Style
//  Reference: iOS 18 Human Interface Guidelines, SF Symbols 5
//

import SwiftUI

// MARK: - Custom Transitions

/// Zoom transition for chart views (iOS 18 style)
struct ZoomTransition: ViewModifier {
    let isActive: Bool
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(QXAnimation.zoom, value: isActive)
    }
}

/// Slide transition for onboarding
struct OnboardingSlideTransition: ViewModifier {
    let direction: SlideDirection
    let isActive: Bool
    
    enum SlideDirection {
        case left, right, up, down
        
        var offset: CGSize {
            switch self {
            case .left: return CGSize(width: -50, height: 0)
            case .right: return CGSize(width: 50, height: 0)
            case .up: return CGSize(width: 0, height: -50)
            case .down: return CGSize(width: 0, height: 50)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(isActive ? .zero : direction.offset)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(QXAnimation.pageTransition, value: isActive)
    }
}

/// Fade transition for modals
struct ModalFadeTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1.0 : 0.0)
            .scaleEffect(isActive ? 1.0 : 0.95)
            .animation(QXAnimation.easeInOut, value: isActive)
    }
}

/// Hero transition for card expansions
struct HeroTransition: ViewModifier {
    let isActive: Bool
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: isActive ? 0 : cornerRadius))
            .animation(QXAnimation.spring, value: isActive)
    }
}

/// Card flip transition
struct FlipTransition: ViewModifier {
    let isFlipped: Bool
    let axis: Axis
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: axis == .horizontal ? (x: 1, y: 0, z: 0) : (x: 0, y: 1, z: 0)
            )
            .opacity(isFlipped ? 0 : 1)
            .animation(QXAnimation.emphasis, value: isFlipped)
    }
}

// MARK: - Transition Extensions

extension AnyTransition {
    /// Zoom transition from center
    static var zoom: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
    
    /// Slide from bottom (modal style)
    static var slideFromBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
    
    /// Slide from trailing (navigation style)
    static var slideFromTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Card stack transition
    static var cardStack: AnyTransition {
        .asymmetric(
            insertion: .offset(y: 100).combined(with: .opacity),
            removal: .offset(y: -50).combined(with: .opacity)
        )
    }
    
    /// Expand transition for fullscreen
    static var expand: AnyTransition {
        .modifier(
            active: ExpandModifier(progress: 0),
            identity: ExpandModifier(progress: 1)
        )
    }
    
    /// Shrink transition for dismissal
    static var shrink: AnyTransition {
        .modifier(
            active: ShrinkModifier(progress: 0),
            identity: ShrinkModifier(progress: 1)
        )
    }
}

// MARK: - Transition Modifiers

struct ExpandModifier: ViewModifier {
    let progress: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(progress)
            .opacity(progress)
    }
}

struct ShrinkModifier: ViewModifier {
    let progress: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1.0 - (1.0 - progress) * 0.3)
            .opacity(progress)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies zoom transition
    func zoomTransition(isActive: Bool, anchor: UnitPoint = .center) -> some View {
        modifier(ZoomTransition(isActive: isActive, anchor: anchor))
    }
    
    /// Applies slide transition for onboarding
    func onboardingSlide(direction: OnboardingSlideTransition.SlideDirection, isActive: Bool) -> some View {
        modifier(OnboardingSlideTransition(direction: direction, isActive: isActive))
    }
    
    /// Applies modal fade transition
    func modalFade(isActive: Bool) -> some View {
        modifier(ModalFadeTransition(isActive: isActive))
    }
    
    /// Applies hero transition
    func heroTransition(isActive: Bool, cornerRadius: CGFloat = 16) -> some View {
        modifier(HeroTransition(isActive: isActive, cornerRadius: cornerRadius))
    }
    
    /// Applies flip transition
    func flipTransition(isFlipped: Bool, axis: Axis = .horizontal) -> some View {
        modifier(FlipTransition(isFlipped: isFlipped, axis: axis))
    }
}

// MARK: - Navigation Transitions

/// Custom navigation transition for view stack
struct NavigationTransitionModifier: ViewModifier {
    let direction: NavigationDirection
    let isPushing: Bool
    
    enum NavigationDirection {
        case forward, backward
    }
    
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: isPushing ? .trailing : .leading),
                    removal: .move(edge: isPushing ? .leading : .trailing)
                )
            )
    }
}

// MARK: - Page Transition Container

/// Container view that manages page transitions
struct PageTransitionContainer<Content: View>: View {
    let content: Content
    let pageIndex: Int
    let totalPages: Int
    let direction: PageDirection
    
    enum PageDirection {
        case forward, backward
    }
    
    init(
        pageIndex: Int,
        totalPages: Int,
        direction: PageDirection = .forward,
        @ViewBuilder content: () -> Content
    ) {
        self.pageIndex = pageIndex
        self.totalPages = totalPages
        self.direction = direction
        self.content = content()
    }
    
    var body: some View {
        content
            .id(pageIndex)
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction == .forward ? .trailing : .leading)
                        .combined(with: .opacity),
                    removal: .move(edge: direction == .forward ? .leading : .trailing)
                        .combined(with: .opacity)
                )
            )
            .animation(QXAnimation.pageTransition, value: pageIndex)
    }
}

// MARK: - Sheet Transitions

/// Custom sheet presentation transition
struct SheetTransition: ViewModifier {
    let isPresented: Bool
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isPresented ? 0 : height)
            .animation(QXAnimation.spring, value: isPresented)
    }
}

// MARK: - Parallax Effect

/// Parallax scrolling effect
struct ParallaxModifier: ViewModifier {
    let scrollOffset: CGFloat
    let parallaxFactor: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: scrollOffset * parallaxFactor)
    }
}

extension View {
    /// Applies parallax effect based on scroll offset
    func parallax(scrollOffset: CGFloat, factor: CGFloat = 0.3) -> some View {
        modifier(ParallaxModifier(scrollOffset: scrollOffset, parallaxFactor: factor))
    }
}

// MARK: - Blur Transition

/// Blur fade transition
struct BlurModifier: ViewModifier {
    let radius: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
            .opacity(opacity)
    }
}

extension AnyTransition {
    /// Blur fade transition
    static var blurFade: AnyTransition {
        .modifier(
            active: BlurModifier(radius: 10, opacity: 0),
            identity: BlurModifier(radius: 0, opacity: 1)
        )
    }
}

// MARK: - Matched Geometry Extensions

extension Namespace.ID {
    /// Creates a matched geometry effect with iOS 18 style timing
    func matchedGeometryEffectIOS18<ID: Hashable>(
        id: ID,
        in namespace: Namespace.ID,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some ViewModifier {
        // This would be used with the actual matchedGeometryEffect modifier
        // Return a custom modifier that wraps it
        MatchedGeometryModifier(
            id: id,
            namespace: namespace,
            properties: properties,
            anchor: anchor,
            isSource: isSource
        )
    }
}

struct MatchedGeometryModifier<ID: Hashable>: ViewModifier {
    let id: ID
    let namespace: Namespace.ID
    let properties: MatchedGeometryProperties
    let anchor: UnitPoint
    let isSource: Bool
    
    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(
                id: id,
                in: namespace,
                properties: properties,
                anchor: anchor,
                isSource: isSource
            )
    }
}

// MARK: - Preview

#Preview("Transitions") {
    @Previewable @State var showZoom = false
    @Previewable @State var showSlide = false
    @Previewable @State var showModal = false
    
    VStack(spacing: 20) {
        Button("Toggle Zoom") { showZoom.toggle() }
        
        if showZoom {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gold)
                .frame(width: 200, height: 100)
                .transition(.zoom)
        }
        
        Button("Toggle Slide") { showSlide.toggle() }
        
        if showSlide {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cosmicTeal)
                .frame(width: 200, height: 100)
                .transition(.slideFromBottom)
        }
        
        Button("Toggle Modal") { showModal.toggle() }
            .padding(.top)
        
        if showModal {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.deepVoid)
                .frame(width: 300, height: 200)
                .overlay(Text("Modal").foregroundColor(.white))
                .transition(.blurFade)
        }
    }
    .padding()
    .background(Color.cosmicBlack)
}
