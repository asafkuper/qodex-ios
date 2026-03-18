//
//  TestDataBuilders.swift
//  Test data builders for consistent test data creation
//

import Foundation
@testable import QodeX

// MARK: - User Test Data Builder

struct UserTestBuilder {
    private var id: String = UUID().uuidString
    private var email: String = "test@example.com"
    private var fullName: String = "Test User"
    private var birthDate: Date? = TestDateFactory.date(year: 1990, month: 6, day: 15)
    private var membershipTier: MembershipTier = .free
    private var membershipExpiry: Date? = nil
    private var createdAt: Date = Date()
    private var lastActiveAt: Date? = Date()
    private var profileImageURL: String? = nil
    private var bio: String? = nil
    private var location: String? = nil
    private var timezone: String? = "UTC"
    
    func withId(_ id: String) -> Self {
        var builder = self
        builder.id = id
        return builder
    }
    
    func withEmail(_ email: String) -> Self {
        var builder = self
        builder.email = email
        return builder
    }
    
    func withFullName(_ name: String) -> Self {
        var builder = self
        builder.fullName = name
        return builder
    }
    
    func withBirthDate(_ date: Date?) -> Self {
        var builder = self
        builder.birthDate = date
        return builder
    }
    
    func withBirthDate(year: Int, month: Int, day: Int) -> Self {
        var builder = self
        builder.birthDate = TestDateFactory.date(year: year, month: month, day: day)
        return builder
    }
    
    func withMembershipTier(_ tier: MembershipTier) -> Self {
        var builder = self
        builder.membershipTier = tier
        return builder
    }
    
    func withMembershipExpiry(_ date: Date?) -> Self {
        var builder = self
        builder.membershipExpiry = date
        return builder
    }
    
    func withCreatedAt(_ date: Date) -> Self {
        var builder = self
        builder.createdAt = date
        return builder
    }
    
    func withLastActiveAt(_ date: Date?) -> Self {
        var builder = self
        builder.lastActiveAt = date
        return builder
    }
    
    func withProfileImageURL(_ url: String?) -> Self {
        var builder = self
        builder.profileImageURL = url
        return builder
    }
    
    func withBio(_ bio: String?) -> Self {
        var builder = self
        builder.bio = bio
        return builder
    }
    
    func withLocation(_ location: String?) -> Self {
        var builder = self
        builder.location = location
        return builder
    }
    
    func withTimezone(_ timezone: String?) -> Self {
        var builder = self
        builder.timezone = timezone
        return builder
    }
    
    func build() -> QodeXUser {
        return QodeXUser(
            id: id,
            email: email,
            fullName: fullName,
            birthDate: birthDate,
            membershipTier: membershipTier,
            membershipExpiry: membershipExpiry,
            createdAt: createdAt,
            lastActiveAt: lastActiveAt,
            profileImageURL: profileImageURL,
            bio: bio,
            location: location,
            timezone: timezone
        )
    }
    
    // MARK: - Convenience Factory Methods
    
    static func freeUser() -> QodeXUser {
        return UserTestBuilder()
            .withMembershipTier(.free)
            .build()
    }
    
    static func seekerUser() -> QodeXUser {
        return UserTestBuilder()
            .withMembershipTier(.seeker)
            .withMembershipExpiry(Date().addingTimeInterval(30 * 24 * 3600))
            .build()
    }
    
    static func initiateUser() -> QodeXUser {
        return UserTestBuilder()
            .withMembershipTier(.initiate)
            .withMembershipExpiry(Date().addingTimeInterval(30 * 24 * 3600))
            .build()
    }
    
    static func masterUser() -> QodeXUser {
        return UserTestBuilder()
            .withMembershipTier(.master)
            .withMembershipExpiry(Date().addingTimeInterval(30 * 24 * 3600))
            .build()
    }
    
    static func userWithLifePath(_ lifePath: Int) -> QodeXUser {
        // Create a birth date that would result in the given life path
        let birthDate = TestDateFactory.dateForLifePath(lifePath)
        return UserTestBuilder()
            .withBirthDate(birthDate)
            .build()
    }
    
    static func userWithoutBirthDate() -> QodeXUser {
        return UserTestBuilder()
            .withBirthDate(nil)
            .build()
    }
    
    static func userWithCompleteProfile() -> QodeXUser {
        return UserTestBuilder()
            .withFullName("Alexandra Johnson")
            .withEmail("alex.j@example.com")
            .withBirthDate(year: 1985, month: 3, day: 22)
            .withMembershipTier(.initiate)
            .withProfileImageURL("https://example.com/profile.jpg")
            .withBio("Spiritual seeker on a journey of self-discovery")
            .withLocation("San Francisco, CA")
            .withTimezone("America/Los_Angeles")
            .build()
    }
}

// MARK: - Numerology Chart Test Builder

struct NumerologyChartTestBuilder {
    private var lifePath: Int = 5
    private var expression: Int = 3
    private var soulUrge: Int = 7
    private var personality: Int = 1
    private var birthday: Int = 15
    private var birthDate: Date = TestDateFactory.date(year: 1990, month: 6, day: 15)
    private var fullName: String = "Test User"
    
    func withLifePath(_ number: Int) -> Self {
        var builder = self
        builder.lifePath = number
        return builder
    }
    
    func withExpression(_ number: Int) -> Self {
        var builder = self
        builder.expression = number
        return builder
    }
    
    func withSoulUrge(_ number: Int) -> Self {
        var builder = self
        builder.soulUrge = number
        return builder
    }
    
    func withPersonality(_ number: Int) -> Self {
        var builder = self
        builder.personality = number
        return builder
    }
    
    func withBirthDate(_ date: Date) -> Self {
        var builder = self
        builder.birthDate = date
        builder.birthday = Calendar.current.component(.day, from: date)
        return builder
    }
    
    func withFullName(_ name: String) -> Self {
        var builder = self
        builder.fullName = name
        return builder
    }
    
    func build() -> NumerologyChart {
        let maturity = lifePath + expression
        
        let challenges = [
            abs(lifePath - expression) % 9,
            abs(soulUrge - personality) % 9,
            abs(lifePath - soulUrge) % 9,
            abs(expression - personality) % 9
        ]
        
        let pinnacles = [
            Pinnacle(number: (lifePath + expression) % 9 + 1, ageStart: 0, ageEnd: 35),
            Pinnacle(number: (expression + soulUrge) % 9 + 1, ageStart: 36, ageEnd: 44),
            Pinnacle(number: (soulUrge + personality) % 9 + 1, ageStart: 45, ageEnd: 53),
            Pinnacle(number: (lifePath + personality) % 9 + 1, ageStart: 54, ageEnd: nil)
        ]
        
        let calendar = Calendar.current
        let today = Date()
        let personalYear = ((calendar.component(.month, from: birthDate) + 
                            calendar.component(.day, from: birthDate) +
                            calendar.component(.year, from: today)) % 9) + 1
        
        return NumerologyChart(
            lifePath: lifePath,
            expression: expression,
            soulUrge: soulUrge,
            personality: personality,
            birthday: birthday,
            maturity: maturity,
            challenges: challenges,
            pinnacles: pinnacles,
            personalYear: personalYear,
            personalMonth: ((personalYear + calendar.component(.month, from: today)) % 9) + 1,
            personalDay: 1,
            birthDate: birthDate,
            fullName: fullName
        )
    }
    
    // MARK: - Convenience Factory Methods
    
    static func masterNumber11() -> NumerologyChart {
        return NumerologyChartTestBuilder()
            .withLifePath(11)
            .withExpression(2)
            .withSoulUrge(9)
            .build()
    }
    
    static func masterNumber22() -> NumerologyChart {
        return NumerologyChartTestBuilder()
            .withLifePath(22)
            .withExpression(4)
            .withSoulUrge(18)
            .build()
    }
    
    static func masterNumber33() -> NumerologyChart {
        return NumerologyChartTestBuilder()
            .withLifePath(33)
            .withExpression(6)
            .withSoulUrge(27)
            .build()
    }
    
    static func allNumbersEqual(_ number: Int) -> NumerologyChart {
        return NumerologyChartTestBuilder()
            .withLifePath(number)
            .withExpression(number)
            .withSoulUrge(number)
            .withPersonality(number)
            .build()
    }
}

// MARK: - Daily Qode Test Builder

struct DailyQodeTestBuilder {
    private var date: Date = Date()
    private var universalDay: Int = 3
    private var personalDay: Int = 5
    private var lifePath: Int = 7
    private var title: String = "Day of Discovery"
    private var description: String = "A day for new experiences and growth."
    private var affirmation: String = "I embrace the opportunities of today."
    private var activities: [String] = ["Reflect", "Plan", "Act"]
    private var avoidances: [String] = ["Procrastinate"]
    
    func withDate(_ date: Date) -> Self {
        var builder = self
        builder.date = date
        return builder
    }
    
    func withUniversalDay(_ number: Int) -> Self {
        var builder = self
        builder.universalDay = number
        return builder
    }
    
    func withPersonalDay(_ number: Int) -> Self {
        var builder = self
        builder.personalDay = number
        return builder
    }
    
    func withLifePath(_ number: Int) -> Self {
        var builder = self
        builder.lifePath = number
        return builder
    }
    
    func withTitle(_ title: String) -> Self {
        var builder = self
        builder.title = title
        return builder
    }
    
    func withDescription(_ description: String) -> Self {
        var builder = self
        builder.description = description
        return builder
    }
    
    func withAffirmation(_ affirmation: String) -> Self {
        var builder = self
        builder.affirmation = affirmation
        return builder
    }
    
    func withActivities(_ activities: [String]) -> Self {
        var builder = self
        builder.activities = activities
        return builder
    }
    
    func withAvoidances(_ avoidances: [String]) -> Self {
        var builder = self
        builder.avoidances = avoidances
        return builder
    }
    
    func build() -> DailyQodeData {
        return DailyQodeData(
            date: date,
            universalDay: universalDay,
            personalDay: personalDay,
            lifePath: lifePath,
            title: title,
            description: description,
            affirmation: affirmation,
            activities: activities,
            avoidances: avoidances
        )
    }
    
    // MARK: - Convenience Factory Methods
    
    static func forLifePath(_ lifePath: Int) -> DailyQodeData {
        let titles = [
            1: "Day of New Beginnings",
            2: "Day of Partnership",
            3: "Day of Creativity",
            4: "Day of Foundation",
            5: "Day of Change",
            6: "Day of Harmony",
            7: "Day of Wisdom",
            8: "Day of Power",
            9: "Day of Completion"
        ]
        
        return DailyQodeTestBuilder()
            .withLifePath(lifePath)
            .withTitle(titles[lifePath] ?? "Day of Discovery")
            .build()
    }
}

// MARK: - Community Post Test Builder

struct CommunityPostTestBuilder {
    private var id: String = UUID().uuidString
    private var userId: String = UUID().uuidString
    private var content: String = "Test post content"
    private var tags: [String] = ["spirituality", "numerology"]
    private var timestamp: Date = Date()
    private var likes: Int = 0
    private var comments: Int = 0
    
    func withId(_ id: String) -> Self {
        var builder = self
        builder.id = id
        return builder
    }
    
    func withUserId(_ userId: String) -> Self {
        var builder = self
        builder.userId = userId
        return builder
    }
    
    func withContent(_ content: String) -> Self {
        var builder = self
        builder.content = content
        return builder
    }
    
    func withTags(_ tags: [String]) -> Self {
        var builder = self
        builder.tags = tags
        return builder
    }
    
    func withTimestamp(_ timestamp: Date) -> Self {
        var builder = self
        builder.timestamp = timestamp
        return builder
    }
    
    func withLikes(_ likes: Int) -> Self {
        var builder = self
        builder.likes = likes
        return builder
    }
    
    func withComments(_ comments: Int) -> Self {
        var builder = self
        builder.comments = comments
        return builder
    }
    
    func build() -> CommunityPostData {
        let dict: [String: Any] = [
            "userId": userId,
            "content": content,
            "tags": tags,
            "timestamp": timestamp,
            "likes": likes,
            "comments": comments
        ]
        
        return CommunityPostData(from: dict, id: id)!
    }
}

// MARK: - Live Session Test Builder

struct LiveSessionTestBuilder {
    private var id: String = UUID().uuidString
    private var title: String = "Test Live Session"
    private var description: String = "A test session description"
    private var startTime: Date = Date().addingTimeInterval(3600)
    private var duration: Int = 60
    private var maxAttendees: Int = 100
    private var registeredAttendees: Int = 0
    private var isPremium: Bool = false
    private var type: String = "qa"
    private var recordingUrl: String? = nil
    
    func withId(_ id: String) -> Self {
        var builder = self
        builder.id = id
        return builder
    }
    
    func withTitle(_ title: String) -> Self {
        var builder = self
        builder.title = title
        return builder
    }
    
    func withStartTime(_ time: Date) -> Self {
        var builder = self
        builder.startTime = time
        return builder
    }
    
    func withDuration(_ minutes: Int) -> Self {
        var builder = self
        builder.duration = minutes
        return builder
    }
    
    func withMaxAttendees(_ count: Int) -> Self {
        var builder = self
        builder.maxAttendees = count
        return builder
    }
    
    func withRegisteredAttendees(_ count: Int) -> Self {
        var builder = self
        builder.registeredAttendees = count
        return builder
    }
    
    func withIsPremium(_ premium: Bool) -> Self {
        var builder = self
        builder.isPremium = premium
        return builder
    }
    
    func build() -> LiveSessionData {
        let dict: [String: Any] = [
            "title": title,
            "description": description,
            "startTime": startTime,
            "duration": duration,
            "maxAttendees": maxAttendees,
            "registeredAttendees": registeredAttendees,
            "isPremium": isPremium,
            "type": type,
            "recordingUrl": recordingUrl as Any
        ]
        
        return LiveSessionData(from: dict, id: id)!
    }
}

// MARK: - Date Factory

struct TestDateFactory {
    static func date(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func dateForLifePath(_ lifePath: Int) -> Date {
        // Returns a birth date that produces the given life path
        switch lifePath {
        case 1:
            return date(year: 1997, month: 1, day: 1)  // 1 + 1 + 8 = 10 = 1
        case 2:
            return date(year: 1998, month: 1, day: 19) // 1 + 1 + 9 = 11 = 2
        case 3:
            return date(year: 1990, month: 1, day: 1)  // 1 + 1 + 1 = 3
        case 4:
            return date(year: 1991, month: 1, day: 1)  // 1 + 1 + 2 = 4
        case 5:
            return date(year: 1992, month: 1, day: 1)  // 1 + 1 + 3 = 5
        case 6:
            return date(year: 1993, month: 1, day: 1)  // 1 + 1 + 4 = 6
        case 7:
            return date(year: 1994, month: 1, day: 1)  // 1 + 1 + 5 = 7
        case 8:
            return date(year: 1995, month: 1, day: 1)  // 1 + 1 + 6 = 8
        case 9:
            return date(year: 1996, month: 1, day: 1)  // 1 + 1 + 7 = 9
        case 11:
            return date(year: 1998, month: 1, day: 1)  // 1 + 1 + 9 = 11
        case 22:
            return date(year: 1980, month: 2, day: 29) // 11 + 2 + 9 = 22
        case 33:
            return date(year: 1980, month: 2, day: 22) // 22 + 2 + 9 = 33
        default:
            return date(year: 1990, month: 6, day: 15)
        }
    }
    
    static func futureDate(days: Int = 1) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
    
    static func pastDate(years: Int = 1) -> Date {
        return Calendar.current.date(byAdding: .year, value: -years, to: Date()) ?? Date()
    }
    
    static func age(_ years: Int) -> Date {
        return pastDate(years: years)
    }
}

// MARK: - String Factory

struct TestStringFactory {
    static func validEmail() -> String {
        return "test\(UUID().uuidString.prefix(8))@example.com"
    }
    
    static func invalidEmail() -> String {
        return "invalid-email"
    }
    
    static func validPassword() -> String {
        return "Password123!"
    }
    
    static func weakPassword() -> String {
        return "123"
    }
    
    static func validName() -> String {
        return "John Doe"
    }
    
    static func longName(length: Int = 100) -> String {
        return String(repeating: "A", count: length)
    }
    
    static func randomString(length: Int = 10) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

// MARK: - Compatibility Report Test Builder

struct CompatibilityReportTestBuilder {
    private var overallScore: Int = 85
    private var lifePathScore: Int = 90
    private var expressionScore: Int = 80
    private var soulUrgeScore: Int = 85
    private var personalityScore: Int = 75
    private var birthdayScore: Int = 70
    private var insights: [String] = ["You have natural chemistry", "Your communication flows easily"]
    private var relationshipType: RelationshipType = .harmonious
    private var strengths: [String] = ["Trust", "Respect"]
    private var challenges: [String] = ["Different paces"]
    private var advice: String = "Focus on your shared values"
    
    func withOverallScore(_ score: Int) -> Self {
        var builder = self
        builder.overallScore = score
        return builder
    }
    
    func withRelationshipType(_ type: RelationshipType) -> Self {
        var builder = self
        builder.relationshipType = type
        return builder
    }
    
    func build() -> CompatibilityReport {
        return CompatibilityReport(
            overallScore: overallScore,
            lifePathScore: lifePathScore,
            expressionScore: expressionScore,
            soulUrgeScore: soulUrgeScore,
            personalityScore: personalityScore,
            birthdayScore: birthdayScore,
            insights: insights,
            relationshipType: relationshipType,
            strengths: strengths,
            challenges: challenges,
            advice: advice
        )
    }
}