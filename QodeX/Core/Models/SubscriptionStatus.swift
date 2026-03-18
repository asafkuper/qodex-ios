//
//  SubscriptionStatus.swift
//  QodeX
//
//  Subscription status enumeration for RevenueCat integration
//

import Foundation

/// Represents the current subscription status of a user
enum SubscriptionStatus: Equatable {
    case unknown
    case free
    case active(tier: MembershipTier, expiryDate: Date?)
    case expired(tier: MembershipTier, gracePeriod: Bool)
    case trial(tier: MembershipTier, daysRemaining: Int)
    case willExpire(tier: MembershipTier, daysRemaining: Int)
    
    var isActive: Bool {
        switch self {
        case .active, .trial:
            return true
        default:
            return false
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .active(let tier, _), .trial(let tier, _), .willExpire(let tier, _):
            return tier != .free
        default:
            return false
        }
    }
    
    var currentTier: MembershipTier {
        switch self {
        case .free, .unknown:
            return .free
        case .active(let tier, _),
             .expired(let tier, _),
             .trial(let tier, _),
             .willExpire(let tier, _):
            return tier
        }
    }
    
    var displayText: String {
        switch self {
        case .unknown:
            return "Loading..."
        case .free:
            return "Free Plan"
        case .active(let tier, _):
            return "\(tier.displayName) Active"
        case .expired(let tier, let gracePeriod):
            return gracePeriod ? "\(tier.displayName) Expired (Grace)" : "\(tier.displayName) Expired"
        case .trial(let tier, let days):
            return "\(tier.displayName) Trial (\(days) days left)"
        case .willExpire(let tier, let days):
            return "\(tier.displayName) Expires in \(days) days"
        }
    }
    
    var canAccessPremium: Bool {
        switch self {
        case .active, .trial:
            return true
        case .willExpire:
            return true
        case .expired(_, let gracePeriod):
            return gracePeriod
        default:
            return false
        }
    }
}

// MARK: - Codable Support

extension SubscriptionStatus: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case tier
        case expiryDate
        case gracePeriod
        case daysRemaining
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .unknown:
            try container.encode("unknown", forKey: .type)
        case .free:
            try container.encode("free", forKey: .type)
        case .active(let tier, let expiryDate):
            try container.encode("active", forKey: .type)
            try container.encode(tier, forKey: .tier)
            try container.encode(expiryDate, forKey: .expiryDate)
        case .expired(let tier, let gracePeriod):
            try container.encode("expired", forKey: .type)
            try container.encode(tier, forKey: .tier)
            try container.encode(gracePeriod, forKey: .gracePeriod)
        case .trial(let tier, let daysRemaining):
            try container.encode("trial", forKey: .type)
            try container.encode(tier, forKey: .tier)
            try container.encode(daysRemaining, forKey: .daysRemaining)
        case .willExpire(let tier, let daysRemaining):
            try container.encode("willExpire", forKey: .type)
            try container.encode(tier, forKey: .tier)
            try container.encode(daysRemaining, forKey: .daysRemaining)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "unknown":
            self = .unknown
        case "free":
            self = .free
        case "active":
            let tier = try container.decode(MembershipTier.self, forKey: .tier)
            let expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
            self = .active(tier: tier, expiryDate: expiryDate)
        case "expired":
            let tier = try container.decode(MembershipTier.self, forKey: .tier)
            let gracePeriod = try container.decode(Bool.self, forKey: .gracePeriod)
            self = .expired(tier: tier, gracePeriod: gracePeriod)
        case "trial":
            let tier = try container.decode(MembershipTier.self, forKey: .tier)
            let daysRemaining = try container.decode(Int.self, forKey: .daysRemaining)
            self = .trial(tier: tier, daysRemaining: daysRemaining)
        case "willExpire":
            let tier = try container.decode(MembershipTier.self, forKey: .tier)
            let daysRemaining = try container.decode(Int.self, forKey: .daysRemaining)
            self = .willExpire(tier: tier, daysRemaining: daysRemaining)
        default:
            self = .unknown
        }
    }
}
