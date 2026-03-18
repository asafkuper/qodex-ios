//
//  ViewStateMachine.swift
//  Unified state management for all views
//

import SwiftUI
import Combine

enum ViewState<T>: Equatable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)
    
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            return true
        case (.loaded, .loaded):
            return true // Simplified - would need to compare values
        case (.error, .error):
            return true // Simplified - would need to compare errors
        default:
            return false
        }
    }
}

protocol StateMachineViewModel: ObservableObject {
    associatedtype DataType
    var state: ViewState<DataType> { get set }
    func load() async
    func refresh() async
    func handleError(_ error: Error)
}

extension StateMachineViewModel {
    func transition(to newState: ViewState<DataType>) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }
    
    func loadWithRetry(policy: RetryPolicy = .standard) async {
        for attempt in 0..<policy.maxRetries {
            do {
                transition(to: .loading)
                try await performLoad()
                return
            } catch {
                if attempt == policy.maxRetries - 1 {
                    transition(to: .error(error))
                    handleError(error)
                } else {
                    let delay = policy.delay(forAttempt: attempt)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
    }
    
    func performLoad() async throws {
        // Override in concrete implementations
    }
}

// MARK: - State Views
struct StateContainerView<Content: View, DataType>: View {
    let state: ViewState<DataType>
    let content: (DataType) -> Content
    let onRetry: () -> Void
    
    init(
        state: ViewState<DataType>,
        onRetry: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (DataType) -> Content
    ) {
        self.state = state
        self.content = content
        self.onRetry = onRetry
    }
    
    var body: some View {
        switch state {
        case .idle:
            Color.clear
                .onAppear {
                    onRetry()
                }
            
        case .loading:
            LoadingView()
            
        case .loaded(let data):
            content(data)
            
        case .empty:
            EmptyStateView(onAction: onRetry)
            
        case .error(let error):
            ErrorStateView(error: error, onRetry: onRetry)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .gold))
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cosmicBlack)
    }
}

struct EmptyStateView: View {
    let onAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.gold.opacity(0.5))
            
            Text("Nothing here yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Start your journey to see personalized insights here.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Get Started", action: onAction)
                .buttonStyle(QXPrimaryButtonStyle())
                .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cosmicBlack)
    }
}

struct ErrorStateView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(QXPrimaryButtonStyle())
                .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cosmicBlack)
    }
}

// MARK: - Skeleton Loading
struct SkeletonModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func skeleton() -> some View {
        modifier(SkeletonModifier())
    }
}

// MARK: - Pull to Refresh
struct RefreshableModifier: ViewModifier {
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                await action()
            }
    }
}

extension View {
    func onRefresh(action: @escaping () async -> Void) -> some View {
        modifier(RefreshableModifier(action: action))
    }
}
