//
//  MembershipTier.swift
//  QodeX Membership System
//

import Foundation

enum MembershipTier: String, CaseIterable, Identifiable {
    case free = "free"
    case seeker = "seeker"
    case initiate = "initiate"
    case master = "master"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .free: return "Free Seeker"
        case .seeker: return "Inner Circle"
        case .initiate: return "Qode Initiate"
        case .master: return "Qode Master"
        }
    }
    
    var subtitle: String {
        switch self {
        case .free: return "Explore the basics"
        case .seeker: return "Full access to teachings"
        case .initiate: return "Personal guidance & community"
        case .master: return "1:1 sessions with Shani"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .seeker: return "$9.99/month"
        case .initiate: return "$19.99/month"
        case .master: return "$199.99"
        }
    }
    
    var annualPrice: String {
        switch self {
        case .free: return "Free"
        case .seeker: return "$59.99/year"
        case .initiate: return "$119.99/year"
        case .master: return "$199.99 lifetime"
        }
    }
    
    var isLifetime: Bool {
        self == .master
    }
    
    var features: [TierFeature] {
        switch self {
        case .free:
            return [
                TierFeature(icon: "number.circle", title: "Basic Qode Calculator", description: "Life Path number only"),
                TierFeature(icon: "book", title: "3 Free Teachings", description: "Introductory content"),
                TierFeature(icon: "calendar", title: "Daily Qode", description: "Basic daily guidance"),
                TierFeature(icon: "xmark.circle", title: "No Community Access", description: "Upgrade to join discussions"),
                TierFeature(icon: "xmark.circle", title: "No Live Sessions", description: "Recorded content only"),
            ]
        case .seeker:
            return [
                TierFeature(icon: "number.circle.fill", title: "Full Qode Calculator", description: "All core numbers"),
                TierFeature(icon: "books.vertical.fill", title: "Complete Library", description: "All teachings & courses"),
                TierFeature(icon: "sparkles", title: "Advanced Daily Qodes", description: "Personalized insights"),
                TierFeature(icon: "person.3.fill", title: "Community Access", description: "Join Inner Circle discussions"),
                TierFeature(icon: "video.fill", title: "Live Session Replays", description: "Watch past sessions"),
                TierFeature(icon: "arrow.down.circle", title: "Offline Downloads", description: "Save for later"),
            ]
        case .initiate:
            return [
                TierFeature(icon: "number.circle.fill", title: "Full Qode Calculator", description: "All core numbers"),
                TierFeature(icon: "books.vertical.fill", title: "Complete Library", description: "All teachings & courses"),
                TierFeature(icon: "sparkles", title: "Advanced Daily Qodes", description: "Personalized insights"),
                TierFeature(icon: "person.3.fill", title: "Priority Community", description: "Initiate-only channels"),
                TierFeature(icon: "video.badge.checkmark", title: "Monthly Live Call", description: "Group session with Shani"),
                TierFeature(icon: "envelope.fill", title: "Monthly Qode Report", description: "Personalized PDF reading"),
                TierFeature(icon: "questionmark.circle.fill", title: "Priority Support", description: "Faster responses"),
            ]
        case .master:
            return [
                TierFeature(icon: "crown.fill", title: "Everything in Initiate", description: "All features included"),
                TierFeature(icon: "person.fill", title: "Monthly 1:1 with Shani", description: "60-minute personal session"),
                TierFeature(icon: "calendar.badge.clock", title: "Priority Booking", description: "First access to events"),
                TierFeature(icon: "lock.shield.fill", title: "Master Circle", description: "Exclusive master community"),
                TierFeature(icon: "wand.and.stars", title: "Custom Qode Work", description: "Advanced calculations"),
                TierFeature(icon: "phone.fill", title: "WhatsApp Access", description: "Direct line to Shani"),
                TierFeature(icon: "gift.fill", title: "Annual Retreat Access", description: "In-person gatherings"),
            ]
        }
    }
    
    var color: String {
        switch self {
        case .free: return "8B8B9E"
        case .seeker: return "D4AF37"
        case .initiate: return "6B4EE6"
        case .master: return "00D4AA"
        }
    }
    
    var isPopular: Bool {
        self == .seeker
    }
}

struct TierFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    var isIncluded: Bool = true
}

// MARK: - Subscription Product IDs

enum SubscriptionProduct: String {
    case seekerMonthly = "com.qodex.seeker.monthly"
    case seekerAnnual = "com.qodex.seeker.annual"
    case initiateMonthly = "com.qodex.initiate.monthly"
    case initiateAnnual = "com.qodex.initiate.annual"
    case masterLifetime = "com.qodex.master.lifetime"
    
    var tier: MembershipTier {
        switch self {
        case .seekerMonthly, .seekerAnnual: return .seeker
        case .initiateMonthly, .initiateAnnual: return .initiate
        case .masterLifetime: return .master
        }
    }
    
    var isAnnual: Bool {
        switch self {
        case .seekerAnnual, .initiateAnnual:
            return true
        case .seekerMonthly, .initiateMonthly, .masterLifetime:
            return false
        }
    }
    
    var isLifetime: Bool {
        self == .masterLifetime
    }
}
