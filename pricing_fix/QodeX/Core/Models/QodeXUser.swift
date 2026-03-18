//
//  QodeXUser.swift
//  QodeX
//
//  Core user model for the QodeX platform
//

import Foundation
import FirebaseFirestore

/// Represents a user in the QodeX system
struct QodeXUser: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    var fullName: String
    var birthDate: Date?
    var birthTime: Date?
    var birthLocation: String?
    var timezone: String
    var membershipTier: MembershipTier
    var membershipExpiry: Date?
    let createdAt: Date
    var lastActiveAt: Date?
    var profileImageURL: String?
    var bio: String?
    var location: String?
    var role: UserRole
    var notificationSettings: NotificationSettings
    var streakData: StreakData?
    var blueprintCompletion: Double
    
    /// Computed properties
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        if components.count > 1,
           let first = components.first?.first,
           let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(fullName.prefix(1)).uppercased()
    }
    
    /// Backward compatibility alias for displayName
    var name: String {
        return displayName
    }
    
    var displayName: String {
        return fullName.isEmpty ? "Seeker" : fullName
    }
    
    var isPremium: Bool {
        return membershipTier != .free
    }
    
    var isAdmin: Bool {
        return role == .admin
    }
    
    /// Default initializer
    init(
        id: String,
        email: String,
        fullName: String,
        birthDate: Date? = nil,
        birthTime: Date? = nil,
        birthLocation: String? = nil,
        timezone: String = TimeZone.current.identifier,
        membershipTier: MembershipTier = .free,
        membershipExpiry: Date? = nil,
        createdAt: Date = Date(),
        lastActiveAt: Date? = nil,
        profileImageURL: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        role: UserRole = .user,
        notificationSettings: NotificationSettings = NotificationSettings(),
        streakData: StreakData? = nil,
        blueprintCompletion: Double = 0.0
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.timezone = timezone
        self.membershipTier = membershipTier
        self.membershipExpiry = membershipExpiry
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.location = location
        self.role = role
        self.notificationSettings = notificationSettings
        self.streakData = streakData
        self.blueprintCompletion = blueprintCompletion
    }
}

// MARK: - Supporting Types

enum MembershipTier: String, Codable, CaseIterable, Equatable {
    case free = "free"
    case seeker = "seeker"
    case initiate = "initiate"
    case master = "master"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .seeker: return "Seeker"
        case .initiate: return "Initiate"
        case .master: return "Master"
        }
    }
    
    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .seeker: return 9.99
        case .initiate: return 19.99
        case .master: return 199.99
        }
    }
    
    var annualPrice: Double {
        switch self {
        case .free: return 0
        case .seeker: return 59.99
        case .initiate: return 119.99
        case .master: return 199.99
        }
    }
    
    var isLifetime: Bool {
        self == .master
    }
    
    var features: [String] {
        switch self {
        case .free:
            return ["Life Path Calculator", "Daily Qode", "Basic Journal"]
        case .seeker:
            return ["All Free Features", "Astrology", "Tarot", "Kabbalah", "Community Access"]
        case .initiate:
            return ["All Seeker Features", "Sacred Geometry", "Frequency Work", "Alchemy", "Mentorship"]
        case .master:
            return ["All Initiate Features", "1:1 Sessions with Shani", "Advanced Teachings", "Priority Support"]
        }
    }
}

enum UserRole: String, Codable, Equatable {
    case user = "user"
    case moderator = "moderator"
    case admin = "admin"
}

struct NotificationSettings: Codable, Equatable {
    var dailyQode: Bool
    var weeklyReport: Bool
    var liveSessions: Bool
    var newTeachings: Bool
    var communityReplies: Bool
    var membershipUpdates: Bool
    var marketing: Bool
    
    init(
        dailyQode: Bool = true,
        weeklyReport: Bool = true,
        liveSessions: Bool = true,
        newTeachings: Bool = true,
        communityReplies: Bool = true,
        membershipUpdates: Bool = true,
        marketing: Bool = false
    ) {
        self.dailyQode = dailyQode
        self.weeklyReport = weeklyReport
        self.liveSessions = liveSessions
        self.newTeachings = newTeachings
        self.communityReplies = communityReplies
        self.membershipUpdates = membershipUpdates
        self.marketing = marketing
    }
}

struct StreakData: Codable, Equatable {
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckIn: Date?
    var totalCheckIns: Int
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCheckIn: Date? = nil,
        totalCheckIns: Int = 0
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCheckIn = lastCheckIn
        self.totalCheckIns = totalCheckIns
    }
}

// MARK: - Firestore Converters

extension QodeXUser {
    init?(from document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.id = document.documentID
        self.email = data["email"] as? String ?? ""
        self.fullName = data["fullName"] as? String ?? ""
        self.birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
        self.birthTime = (data["birthTime"] as? Timestamp)?.dateValue()
        self.birthLocation = data["birthLocation"] as? String
        self.timezone = data["timezone"] as? String ?? TimeZone.current.identifier
        
        if let tierString = data["membershipTier"] as? String,
           let tier = MembershipTier(rawValue: tierString) {
            self.membershipTier = tier
        } else {
            self.membershipTier = .free
        }
        
        self.membershipExpiry = (data["membershipExpiry"] as? Timestamp)?.dateValue()
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lastActiveAt = (data["lastActiveAt"] as? Timestamp)?.dateValue()
        self.profileImageURL = data["profileImageURL"] as? String
        self.bio = data["bio"] as? String
        self.location = data["location"] as? String
        
        if let roleString = data["role"] as? String,
           let role = UserRole(rawValue: roleString) {
            self.role = role
        } else {
            self.role = .user
        }
        
        if let notifData = data["notificationSettings"] as? [String: Bool] {
            self.notificationSettings = NotificationSettings(
                dailyQode: notifData["dailyQode"] ?? true,
                weeklyReport: notifData["weeklyReport"] ?? true,
                liveSessions: notifData["liveSessions"] ?? true,
                newTeachings: notifData["newTeachings"] ?? true,
                communityReplies: notifData["communityReplies"] ?? true,
                membershipUpdates: notifData["membershipUpdates"] ?? true,
                marketing: notifData["marketing"] ?? false
            )
        } else {
            self.notificationSettings = NotificationSettings()
        }
        
        if let streakData = data["streakData"] as? [String: Any] {
            self.streakData = StreakData(
                currentStreak: streakData["currentStreak"] as? Int ?? 0,
                longestStreak: streakData["longestStreak"] as? Int ?? 0,
                lastCheckIn: (streakData["lastCheckIn"] as? Timestamp)?.dateValue(),
                totalCheckIns: streakData["totalCheckIns"] as? Int ?? 0
            )
        } else {
            self.streakData = nil
        }
        
        self.blueprintCompletion = data["blueprintCompletion"] as? Double ?? 0.0
    }
    
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "email": email,
            "fullName": fullName,
            "timezone": timezone,
            "membershipTier": membershipTier.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "role": role.rawValue,
            "notificationSettings": [
                "dailyQode": notificationSettings.dailyQode,
                "weeklyReport": notificationSettings.weeklyReport,
                "liveSessions": notificationSettings.liveSessions,
                "newTeachings": notificationSettings.newTeachings,
                "communityReplies": notificationSettings.communityReplies,
                "membershipUpdates": notificationSettings.membershipUpdates,
                "marketing": notificationSettings.marketing
            ],
            "blueprintCompletion": blueprintCompletion
        ]
        
        if let birthDate = birthDate {
            data["birthDate"] = Timestamp(date: birthDate)
        }
        if let birthTime = birthTime {
            data["birthTime"] = Timestamp(date: birthTime)
        }
        if let birthLocation = birthLocation {
            data["birthLocation"] = birthLocation
        }
        if let membershipExpiry = membershipExpiry {
            data["membershipExpiry"] = Timestamp(date: membershipExpiry)
        }
        if let lastActiveAt = lastActiveAt {
            data["lastActiveAt"] = Timestamp(date: lastActiveAt)
        }
        if let profileImageURL = profileImageURL {
            data["profileImageURL"] = profileImageURL
        }
        if let bio = bio {
            data["bio"] = bio
        }
        if let location = location {
            data["location"] = location
        }
        if let streakData = streakData {
            data["streakData"] = [
                "currentStreak": streakData.currentStreak,
                "longestStreak": streakData.longestStreak,
                "lastCheckIn": streakData.lastCheckIn != nil ? Timestamp(date: streakData.lastCheckIn!) : NSNull(),
                "totalCheckIns": streakData.totalCheckIns
            ]
        }
        
        return data
    }
}
