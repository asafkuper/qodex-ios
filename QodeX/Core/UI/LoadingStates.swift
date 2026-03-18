//
//  QXLoadingStates.swift
//  Premium loading animations
//

import SwiftUI

// MARK: - Shimmer Effect
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "2A2A3E"),
                    Color(hex: "1A1A2E")
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

struct ShimmerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                ShimmerView()
                    .mask(content)
            )
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Views
struct CardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 120, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 12)
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 12)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 200, height: 12)
            }
        }
        .padding()
        .background(Color.deepVoid)
        .cornerRadius(16)
        .shimmer()
    }
}

struct NumberSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .frame(width: 120, height: 120)
            
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 150, height: 24)
            
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 200, height: 16)
        }
        .padding()
        .shimmer()
    }
}

struct ListSkeleton: View {
    let count: Int
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                CardSkeleton()
            }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String
    let showSpinner: Bool
    
    init(message: String = "Loading...", showSpinner: Bool = true) {
        self.message = message
        self.showSpinner = showSpinner
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                if showSpinner {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .gold))
                }
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.deepVoid)
            )
        }
    }
}

// MARK: - Pull to Refresh
struct PullToRefresh: View {
    let coordinateSpaceName: String
    let onRefresh: () -> Void
    
    @State private var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .named(coordinateSpaceName)).midY > 50 {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if geo.frame(in: .named(coordinateSpaceName)).maxY < 10 {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.gold)
                }
                Spacer()
            }
        }
        .padding(.top, -40)
    }
}

// MARK: - Success Animation
struct SuccessCheckmark: View {
    @State private var showCheckmark = false
    @State private var showCircle = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gold, lineWidth: 3)
                .frame(width: 60, height: 60)
                .scaleEffect(showCircle ? 1 : 0)
            
            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.gold)
                .opacity(showCheckmark ? 1 : 0)
                .scaleEffect(showCheckmark ? 1 : 0.5)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                showCircle = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    showCheckmark = true
                }
            }
        }
    }
}

// MARK: - Number Counter Animation
struct AnimatedNumber: View {
    let value: Int
    @State private var displayValue: Int = 0
    
    var body: some View {
        Text("\(displayValue)")
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .foregroundColor(.gold)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { newValue in
                withAnimation(.easeOut(duration: 0.5)) {
                    displayValue = newValue
                }
            }
    }
}

// MARK: - Staggered Animation Modifier
struct StaggeredAnimation: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay * Double(index)) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func staggered(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(StaggeredAnimation(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Pulse Animation
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseEffect())
    }
}
