//
//  SmartReplyGenerator.swift
//  AI-powered suggested replies for community
//

import Foundation
import NaturalLanguage

class SmartReplyGenerator {
    static let shared = SmartReplyGenerator()
    
    private let contextAnalyzer = ContextAnalyzer()
    
    // MARK: - Generate Suggested Replies
    func generateReplies(for post: CommunityPost, userLifePath: Int) -> [String] {
        var suggestions: [String] = []
        
        // Analyze post sentiment and content
        let sentiment = analyzeSentiment(post.content)
        let topic = extractTopic(post.content)
        
        // Generate based on context
        switch sentiment {
        case .positive:
            suggestions.append(contentsOf: positiveReplies(topic: topic, lifePath: userLifePath))
        case .negative:
            suggestions.append(contentsOf: supportiveReplies(topic: topic, lifePath: userLifePath))
        case .question:
            suggestions.append(contentsOf: answeringReplies(topic: topic, lifePath: userLifePath))
        case .neutral:
            suggestions.append(contentsOf: engagingReplies(topic: topic, lifePath: userLifePath))
        }
        
        // Add numerology-specific replies if relevant
        if post.content.lowercased().contains("life path") ||
           post.content.lowercased().contains("number") {
            suggestions.append(contentsOf: numerologyReplies(lifePath: userLifePath))
        }
        
        return Array(suggestions.prefix(3))
    }
    
    // MARK: - Reply Templates by Life Path
    private func positiveReplies(topic: String, lifePath: Int) -> [String] {
        let templates: [Int: [String]] = [
            1: ["Love your leadership on this! 🔥", "Taking charge - that's the Life Path 1 way!", "Your initiative is inspiring"],
            2: ["Beautiful harmony in your words 🕊️", "Your diplomacy shines through", "So balanced and thoughtful"],
            3: ["Creative energy flowing! ✨", "Love the artistic expression", "Your creativity is contagious"],
            4: ["Solid foundation building! 🏗️", "Practical wisdom as always", "Building something great"],
            5: ["Freedom and adventure! 🦅", "Embracing change beautifully", "Your adventurous spirit shows"],
            6: ["Nurturing energy ❤️", "Your care comes through", "Beautiful harmony"],
            7: ["Deep wisdom here 🧠", "Your analysis is spot on", "Spiritual insights as always"],
            8: ["Power and abundance! 💪", "Manifesting success", "Your authority shows"],
            9: ["Humanitarian heart 🌍", "Completing the cycle beautifully", "Your compassion shines"]
        ]
        
        return templates[lifePath] ?? ["Great post! 👍", "Love this!", "Well said!"]
    }
    
    private func supportiveReplies(topic: String, lifePath: Int) -> [String] {
        let templates: [Int: [String]] = [
            1: ["Every leader faces challenges. You've got this! 💪", "Take charge of your destiny", "Your strength will see you through"],
            2: ["Finding balance takes time. Be gentle with yourself 🕊️", "Partnership challenges are growth", "Harmony will come"],
            3: ["Creativity has ups and downs. Keep expressing! 🎨", "Your voice matters", "Express through the pain"],
            4: ["Strong foundations bend but don't break 🏗️", "Rebuild stronger", "Stability returns"],
            5: ["Freedom includes difficult choices 🦅", "Embrace the transition", "Change brings growth"],
            6: ["Nurturing yourself is vital too ❤️", "You give so much - receive too", "Harmony includes self-care"],
            7: ["Wisdom comes from questioning 🧠", "Your search leads to truth", "Spiritual growth through struggle"],
            8: ["Power includes vulnerability 💪", "True strength admits challenges", "Abundance includes lessons"],
            9: ["Completion means endings too 🌍", "Your service is seen", "New cycles await"]
        ]
        
        return templates[lifePath] ?? ["Sending support 💙", "Here for you", "Stay strong"]
    }
    
    private func answeringReplies(topic: String, lifePath: Int) -> [String] {
        let templates: [Int: [String]] = [
            1: ["As a Life Path 1, I'd lead with...", "Take initiative by...", "My experience leading shows..."],
            7: ["From a Life Path 7 perspective...", "My research suggests...", "Spiritually speaking..."],
            9: ["Having completed similar journeys...", "My humanitarian work shows...", "In my experience..."]
        ]
        
        return templates[lifePath] ?? ["From my experience...", "I found that...", "Have you tried..."]
    }
    
    private func engagingReplies(topic: String, lifePath: Int) -> [String] {
        return [
            "Tell me more about your journey!",
            "How has your Life Path influenced this?",
            "What led you to this realization?",
            "Would love to hear more!"
        ]
    }
    
    private func numerologyReplies(lifePath: Int) -> [String] {
        return [
            "As a fellow Life Path \(lifePath), I totally get this!",
            "Your Life Path energy is strong here ✨",
            "Life Path \(lifePath) wisdom showing!",
            "This resonates with my numerology too"
        ]
    }
    
    // MARK: - Analysis
    private func analyzeSentiment(_ text: String) -> SentimentType {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let score = Double(sentiment?.rawValue ?? "0") {
            if score > 0.5 {
                return .positive
            } else if score < -0.5 {
                return .negative
            }
        }
        
        // Check for question patterns
        if text.contains("?") || text.lowercased().contains("how") || text.lowercased().contains("what") {
            return .question
        }
        
        return .neutral
    }
    
    private func extractTopic(_ text: String) -> String {
        // Extract key topics using NLP
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var topics: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if tag == .personalName {
                topics.append(String(text[range]))
            }
            return true
        }
        
        return topics.first ?? "general"
    }
}

// MARK: - Supporting Types
enum SentimentType {
    case positive
    case negative
    case question
    case neutral
}

class ContextAnalyzer {
    // Analyze conversation context for better suggestions
}
