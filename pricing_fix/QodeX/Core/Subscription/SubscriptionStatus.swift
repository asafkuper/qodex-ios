//
//  SubscriptionStatus.swift
//  QodeX Subscription Status
//

import Foundation

enum SubscriptionStatus: Equatable {
    case unknown
    case free
    case active(tier: MembershipTier, expiryDate: Date?)
    case expired(tier: MembershipTier, gracePeriod: Bool)
    case pendingPurchase
    case failed(error: SubscriptionError)
}
