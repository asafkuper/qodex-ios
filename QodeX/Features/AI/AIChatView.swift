//
//  AIChatView.swift
//  AI-powered Qode assistant for instant answers
//

import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                chatHeader
                
                // Messages
                messagesList
                
                // Quick suggestions
                if viewModel.messages.isEmpty {
                    suggestionsSection
                }
                
                // Input
                inputSection
            }
        }
    }
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(QodeXColors.mysticPurple.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(QodeXColors.mysticPurple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Qode AI")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundStyle(QodeXColors.stardust)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.clearChat() }) {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(QodeXColors.stardust)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(QodeXColors.deepVoid)
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if viewModel.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages) { _ in
                if let last = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isTyping) { isTyping in
                if isTyping {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try asking:")
                .font(QodeXTypography.caption)
                .foregroundStyle(QodeXColors.stardust)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        SuggestionPill(text: suggestion) {
                            messageText = suggestion
                            sendMessage()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
    }
    
    private var inputSection: some View {
        HStack(spacing: 12) {
            TextField("Ask about your Qode...", text: $messageText, axis: .vertical)
                .lineLimit(1...5)
                .padding(12)
                .background(QodeXColors.deepVoid)
                .cornerRadius(20)
                .foregroundStyle(QodeXColors.pureWhite)
                .focused($isInputFocused)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(messageText.isEmpty ? QodeXColors.stardust : QodeXColors.gold)
            }
            .disabled(messageText.isEmpty || viewModel.isTyping)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(QodeXColors.cosmicBlack)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        isInputFocused = false
        
        Task {
            await viewModel.sendMessage(text)
        }
    }
}

struct MessageBubble: View {
    let message: AIChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundStyle(message.isUser ? QodeXColors.cosmicBlack : QodeXColors.pureWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser ? QodeXColors.gold : QodeXColors.deepVoid
                    )
                    .cornerRadius(20, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                
                Text(message.timeString)
                    .font(.system(size: 10))
                    .foregroundStyle(QodeXColors.stardust)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(QodeXColors.stardust)
                        .frame(width: 6, height: 6)
                        .offset(y: offset)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                            value: offset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(QodeXColors.deepVoid)
            .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
            
            Spacer()
        }
        .onAppear {
            offset = -4
        }
    }
}

struct SuggestionPill: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(QodeXColors.starlight)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Model

class AIChatViewModel: ObservableObject {
    @Published var messages: [AIChatMessage] = []
    @Published var isTyping = false
    
    let suggestions = [
        "What does Life Path 7 mean?",
        "Calculate my Expression number",
        "When is my next personal year?",
        "What numbers are compatible with 3?",
        "Explain Master Numbers"
    ]
    
    func sendMessage(_ text: String) async {
        // Add user message
        let userMessage = AIChatMessage(content: text, isUser: true, timestamp: Date())
        await MainActor.run {
            messages.append(userMessage)
            isTyping = true
        }
        
        // Simulate AI response
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let response = generateResponse(to: text)
        let aiMessage = AIChatMessage(content: response, isUser: false, timestamp: Date())
        
        await MainActor.run {
            messages.append(aiMessage)
            isTyping = false
        }
    }
    
    private func generateResponse(to query: String) -> String {
        // In production, this would call OpenAI/Claude API
        let lowercased = query.lowercased()
        
        if lowercased.contains("life path 7") {
            return "Life Path 7 is The Seeker. You're analytical, introspective, and drawn to spiritual truths. You seek deeper meaning in everything and have a natural gift for research and understanding hidden patterns."
        } else if lowercased.contains("expression") {
            return "Your Expression Number is calculated from your full birth name. It reveals your natural talents, abilities, and how you express yourself to the world. Would you like me to calculate yours?"
        } else if lowercased.contains("compatible") {
            return "Number 3 (The Creative) is most compatible with 1, 5, and 7. These numbers appreciate your joy, creativity, and self-expression. You may find challenges with 4 and 8, who prefer structure."
        } else if lowercased.contains("master") {
            return "Master Numbers (11, 22, 33) carry amplified spiritual significance. 11 is the Intuitive, 22 the Master Builder, 33 the Master Teacher. They bring higher calling but also greater challenges."
        } else {
            return "That's a fascinating question about numerology! I'd love to explore this with you. Could you share your birth date so I can give you a more personalized answer?"
        }
    }
    
    func clearChat() {
        messages.removeAll()
    }
}

struct AIChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    AIChatView()
}
