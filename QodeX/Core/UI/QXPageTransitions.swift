//
//  QXPageTransitions.swift
//  QodeX Premium Page Transitions
//  Reference: iOS 18 HIG, Apple Design Awards 2024
//

import SwiftUI

// MARK: - Page Transition Types
public enum QXPageTransition {
    case slide(direction: SlideDirection)
    case zoom(from: CGRect, to: CGRect)
    case fade
    case flip(axis: Axis)
    case cardStack
    case hero
    case blur
    
    public enum SlideDirection {
        case left, right, up, down
        
        var edge: Edge {
            switch self {
            case .left: return .trailing
            case .right: return .leading
            case .up: return .bottom
            case .down: return .top
            }
        }
    }
}

// MARK: - View Transition Modifier
public struct QXViewTransition: ViewModifier {
    let transition: QXPageTransition
    let isActive: Bool
    let duration: Double
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var blur: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .blur(radius: blur)
            .onAppear {
                animateIn()
            }
            .onChange(of: isActive) { _, newValue in
                if !newValue {
                    animateOut()
                }
            }
    }
    
    private func animateIn() {
        switch transition {
        case .slide(let direction):
            offset = offsetFor(direction: direction, isEntering: true)
            opacity = 0
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = .zero
                opacity = 1
            }
            
        case .fade:
            opacity = 0
            withAnimation(.easeInOut(duration: duration)) {
                opacity = 1
            }
            
        case .zoom:
            scale = 0.8
            opacity = 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
            
        case .flip(let axis):
            rotation = axis == .horizontal ? 90 : -90
            opacity = 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                rotation = 0
                opacity = 1
            }
            
        case .cardStack:
            offset = CGSize(width: 0, height: 100)
            opacity = 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = .zero
                opacity = 1
            }
            
        case .hero:
            scale = 0.9
            opacity = 0
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
            
        case .blur:
            blur = 10
            opacity = 0
            withAnimation(.easeOut(duration: duration)) {
                blur = 0
                opacity = 1
            }
        }
    }
    
    private func animateOut() {
        withAnimation(.easeInOut(duration: duration * 0.5)) {
            opacity = 0
            scale = 0.95
        }
    }
    
    private func offsetFor(direction: QXPageTransition.SlideDirection, isEntering: Bool) -> CGSize {
        let distance: CGFloat = isEntering ? 100 : -100
        switch direction {
        case .left: return CGSize(width: distance, height: 0)
        case .right: return CGSize(width: -distance, height: 0)
        case .up: return CGSize(width: 0, height: distance)
        case .down: return CGSize(width: 0, height: -distance)
        }
    }
}

public extension View {
    func qxTransition(_ transition: QXPageTransition, isActive: Bool = true, duration: Double = 0.3) -> some View {
        modifier(QXViewTransition(transition: transition, isActive: isActive, duration: duration))
    }
}

// MARK: - Navigation Transition
public struct QXNavigationTransition<Content: View>: View {
    let content: Content
    let direction: QXPageTransition.SlideDirection
    @State private var isVisible = false
    
    public init(direction: QXPageTransition.SlideDirection = .right, @ViewBuilder content: () -> Content) {
        self.direction = direction
        self.content = content()
    }
    
    public var body: some View {
        content
            .qxTransition(.slide(direction: direction), isActive: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

// MARK: - Page View with Transitions
public struct QXPageView<Content: View>: View {
    let pages: [Content]
    @Binding var currentPage: Int
    let transition: QXPageTransition
    
    @State private var direction: QXPageTransition.SlideDirection = .right
    @State private var previousPage: Int = 0
    
    public init(
        pages: [Content],
        currentPage: Binding<Int>,
        transition: QXPageTransition = .slide(direction: .right)
    ) {
        self.pages = pages
        self._currentPage = currentPage
        self.transition = transition
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<pages.count, id: \.self) { index in
                if index == currentPage {
                    pages[index]
                        .transition(asymmetricTransition)
                        .id(index)
                }
            }
        }
        .onChange(of: currentPage) { oldValue, newValue in
            direction = newValue > oldValue ? .right : .left
            previousPage = oldValue
            
            // Haptic feedback
            QXHaptic.selection()
        }
    }
    
    private var asymmetricTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: direction.edge).combined(with: .opacity),
            removal: .move(edge: direction == .right ? .leading : .trailing).combined(with: .opacity)
        )
    }
}

// MARK: - Matched Geometry Transition
public struct QXMatchedGeometryTransition<Content: View, Destination: View>: View {
    @Namespace var namespace
    let content: Content
    let destination: Destination
    let id: String
    @Binding var isExpanded: Bool
    
    public init(
        id: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: () -> Destination
    ) {
        self.id = id
        self._isExpanded = isExpanded
        self.content = content()
        self.destination = destination()
    }
    
    public var body: some View {
        ZStack {
            if !isExpanded {
                content
                    .matchedGeometryEffect(id: id, in: namespace)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isExpanded = true
                        }
                        QXHaptic.mediumImpact()
                    }
            } else {
                destination
                    .matchedGeometryEffect(id: id, in: namespace)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isExpanded = false
                        }
                    }
            }
        }
    }
}

// MARK: - Custom Transition Modifiers
public struct QXSlideTransition: ViewModifier {
    let offset: CGSize
    let opacity: Double
    let isActive: Bool
    
    public func body(content: Content) -> some View {
        content
            .offset(isActive ? .zero : offset)
            .opacity(isActive ? 1 : opacity)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

public struct QXScaleTransition: ViewModifier {
    let scale: CGFloat
    let isActive: Bool
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : scale)
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
    }
}

public extension View {
    func slideIn(from edge: Edge, isActive: Bool) -> some View {
        let offset: CGSize = {
            switch edge {
            case .top: return CGSize(width: 0, height: -100)
            case .bottom: return CGSize(width: 0, height: 100)
            case .leading: return CGSize(width: -100, height: 0)
            case .trailing: return CGSize(width: 100, height: 0)
            }
        }()
        
        return modifier(QXSlideTransition(offset: offset, opacity: 0, isActive: isActive))
    }
    
    func scaleIn(isActive: Bool, from scale: CGFloat = 0.8) -> some View {
        modifier(QXScaleTransition(scale: scale, isActive: isActive))
    }
}

// MARK: - Staggered Children Transition
public struct QXStaggeredTransition: ViewModifier {
    let index: Int
    let delay: Double
    @State private var isVisible = false
    
    public func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }
    }
}

public extension View {
    func staggeredTransition(index: Int, delay: Double = 0.05) -> some View {
        modifier(QXStaggeredTransition(index: index, delay: delay))
    }
}

// MARK: - Page Curl Transition
public struct QXPageCurlTransition: View {
    @State private var angle: Double = 0
    let frontView: AnyView
    let backView: AnyView
    @Binding var isFlipped: Bool
    
    public init<F: View, B: View>(
        isFlipped: Binding<Bool>,
        @ViewBuilder front: () -> F,
        @ViewBuilder back: () -> B
    ) {
        self._isFlipped = isFlipped
        self.frontView = AnyView(front())
        self.backView = AnyView(back())
    }
    
    public var body: some View {
        ZStack {
            // Back view (visible when flipped)
            backView
                .opacity(angle > 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(angle - 180),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Front view
            frontView
                .opacity(angle <= 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(angle),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .onChange(of: isFlipped) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                angle = newValue ? 180 : 0
            }
            QXHaptic.mediumImpact()
        }
    }
}

// MARK: - Contextual Transition Container
public struct QXContextualTransitionContainer<Content: View>: View {
    @State private var activeTransition: QXPageTransition?
    @State private var isTransitioning = false
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .environment(\.qxTransitionTrigger, QXTransitionTrigger(
                trigger: { transition in
                    performTransition(transition)
                }
            ))
    }
    
    private func performTransition(_ transition: QXPageTransition) {
        guard !isTransitioning else { return }
        isTransitioning = true
        activeTransition = transition
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTransitioning = false
            activeTransition = nil
        }
    }
}

// MARK: - Environment Key for Transition
@MainActor
public struct QXTransitionTrigger {
    public let trigger: (QXPageTransition) -> Void
}

private struct QXTransitionTriggerKey: EnvironmentKey {
    static let defaultValue: QXTransitionTrigger? = nil
}

public extension EnvironmentValues {
    var qxTransitionTrigger: QXTransitionTrigger? {
        get { self[QXTransitionTriggerKey.self] }
        set { self[QXTransitionTriggerKey.self] = newValue }
    }
}

// MARK: - Transition Preview
#Preview("Page Transitions") {
    @Previewable @State var currentPage = 0
    @Previewable @State var isExpanded = false
    
    VStack {
        // Page view demo
        QXPageView(
            pages: [
                Color.red.overlay(Text("Page 1").foregroundColor(.white)),
                Color.green.overlay(Text("Page 2").foregroundColor(.white)),
                Color.blue.overlay(Text("Page 3").foregroundColor(.white))
            ],
            currentPage: $currentPage,
            transition: .slide(direction: .right)
        )
        .frame(height: 200)
        
        HStack {
            Button("Previous") {
                currentPage = max(0, currentPage - 1)
            }
            .disabled(currentPage == 0)
            
            Spacer()
            
            Button("Next") {
                currentPage = min(2, currentPage + 1)
            }
            .disabled(currentPage == 2)
        }
        .padding()
        
        // Matched geometry demo
        QXMatchedGeometryTransition(
            id: "card",
            isExpanded: $isExpanded,
            content: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(QXColor.gold)
                    .frame(width: 100, height: 100)
                    .overlay(Text("Tap").foregroundColor(.black))
            },
            destination: {
                RoundedRectangle(cornerRadius: 24)
                    .fill(QXColor.gold)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .overlay(Text("Expanded").foregroundColor(.black))
            }
        )
        .padding()
    }
    .background(QXColor.cosmicBlack)
}
