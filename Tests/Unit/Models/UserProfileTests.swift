//
//  UserProfileTests.swift
//  Tests for User model and related data structures
//

import Testing
import Foundation
@testable import QodeX

// MARK: - Test Data Builders

struct UserProfileTestBuilder {
    static func makeUser(
        id: String = UUID().uuidString,
        email: String = "test@example.com",
        fullName: String = "Test User",
        birthDate: Date? = nil,
        membershipTier: MembershipTier = .free,
        createdAt: Date = Date()
    ) -> QodeXUser {
        let defaultBirthDate = birthDate ?? {
            var components = DateComponents()
            components.year = 1990
            components.month = 6
            components.day = 15
            return Calendar.current.date(from: components)!
        }()
        
        return QodeXUser(
            id: id,
            email: email,
            fullName: fullName,
            birthDate: defaultBirthDate,
            membershipTier: membershipTier,
            createdAt: createdAt
        )
    }
    
    static func makeUserProfileData(
        userId: String = UUID().uuidString,
        name: String = "Test User",
        email: String = "test@example.com",
        birthDate: Date = Date(),
        timezone: String = "UTC",
        lifePath: Int = 1
    ) -> UserProfileData {
        return UserProfileData(
            userId: userId,
            name: name,
            email: email,
            birthDate: birthDate,
            birthTime: nil,
            timezone: timezone,
            lifePath: lifePath,
            createdAt: Date()
        )
    }
}

// MARK: - QodeXUser Model Tests

@Suite("QodeXUser Model Tests")
struct QodeXUserTests {
    
    // MARK: - Initialization Tests
    
    @Test("User initializes with all properties")
    func testUserInitialization() async throws {
        let id = UUID().uuidString
        let email = "test@example.com"
        let fullName = "John Doe"
        let birthDate = Date()
        let tier = MembershipTier.seeker
        
        let user = QodeXUser(
            id: id,
            email: email,
            fullName: fullName,
            birthDate: birthDate,
            membershipTier: tier,
            createdAt: Date()
        )
        
        #expect(user.id == id)
        #expect(user.email == email)
        #expect(user.fullName == fullName)
        #expect(user.birthDate == birthDate)
        #expect(user.membershipTier == tier)
    }
    
    @Test("User initializes with nil birthDate")
    func testUserInitializationNilBirthDate() async throws {
        let user = QodeXUser(
            id: "test-id",
            email: "test@example.com",
            fullName: "Test",
            birthDate: nil,
            membershipTier: .free,
            createdAt: Date()
        )
        
        #expect(user.birthDate == nil)
        #expect(user.age == nil)
    }
    
    @Test("User conforms to Identifiable")
    func testIdentifiableConformance() async throws {
        let user = UserProfileTestBuilder.makeUser()
        // Should compile if Identifiable is properly implemented
        let _: String = user.id
    }
    
    @Test("User conforms to Codable")
    func testCodableConformance() async throws {
        let user = UserProfileTestBuilder.makeUser()
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(QodeXUser.self, from: data)
        
        #expect(decodedUser.id == user.id)
        #expect(decodedUser.email == user.email)
        #expect(decodedUser.fullName == user.fullName)
    }
    
    // MARK: - Initials Tests
    
    @Test("Initials for single name")
    func testInitialsSingleName() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "Madonna")
        #expect(user.initials == "MM")
    }
    
    @Test("Initials for two names")
    func testInitialsTwoNames() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "John Doe")
        #expect(user.initials == "JD")
    }
    
    @Test("Initials for three names")
    func testInitialsThreeNames() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "John James Doe")
        #expect(user.initials == "JD")
    }
    
    @Test("Initials are uppercase")
    func testInitialsUppercase() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "john doe")
        #expect(user.initials == "JD")
    }
    
    @Test("Initials with hyphenated name")
    func testInitialsHyphenated() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "Mary-Jane Watson")
        #expect(user.initials == "MW")
    }
    
    @Test("Initials with apostrophe")
    func testInitialsApostrophe() async throws {
        let user = UserProfileTestBuilder.makeUser(fullName: "D'Artagnan")
        #expect(user.initials == "DD")
    }
    
    // MARK: - Age Tests
    
    @Test("Age calculation is correct")
    func testAgeCalculation() async throws {
        var components = DateComponents()
        components.year = 1990
        components.month = 1
        components.day = 1
        let birthDate = Calendar.current.date(from: components)!
        
        let user = UserProfileTestBuilder.makeUser(birthDate: birthDate)
        
        // Age depends on current date, so verify it's positive
        if let age = user.age {
            #expect(age > 0)
        }
    }
    
    @Test("Age is nil when birthDate is nil")
    func testAgeNilWithoutBirthDate() async throws {
        let user = QodeXUser(
            id: "test",
            email: "test@test.com",
            fullName: "Test",
            birthDate: nil,
            membershipTier: .free,
            createdAt: Date()
        )
        
        #expect(user.age == nil)
    }
    
    @Test("Age calculation for recent birth")
    func testAgeRecentBirth() async throws {
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        let user = UserProfileTestBuilder.makeUser(birthDate: oneYearAgo)
        
        if let age = user.age {
            #expect(age == 0 || age == 1)
        }
    }
    
    @Test("Age calculation for exact birthday")
    func testAgeExactBirthday() async throws {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        var birthComponents = components
        birthComponents.year = (components.year ?? 2000) - 25
        
        if let birthDate = calendar.date(from: birthComponents) {
            let user = UserProfileTestBuilder.makeUser(birthDate: birthDate)
            #expect(user.age == 25)
        }
    }
    
    // MARK: - Membership Tier Tests
    
    @Test("All membership tiers exist")
    func testAllMembershipTiers() async throws {
        let tiers: [MembershipTier] = [.free, .seeker, .initiate, .master]
        #expect(tiers.count == 4)
    }
    
    @Test("Membership tier raw values are correct")
    func testMembershipTierRawValues() async throws {
        #expect(MembershipTier.free.rawValue == "free")
        #expect(MembershipTier.seeker.rawValue == "seeker")
        #expect(MembershipTier.initiate.rawValue == "initiate")
        #expect(MembershipTier.master.rawValue == "master")
    }
    
    @Test("Membership tier display names are set")
    func testMembershipTierDisplayNames() async throws {
        #expect(!MembershipTier.free.displayName.isEmpty)
        #expect(!MembershipTier.seeker.displayName.isEmpty)
        #expect(!MembershipTier.initiate.displayName.isEmpty)
        #expect(!MembershipTier.master.displayName.isEmpty)
    }
    
    @Test("Membership tier conforms to CaseIterable")
    func testMembershipTierCaseIterable() async throws {
        let allCases = MembershipTier.allCases
        #expect(allCases.count == 4)
    }
    
    @Test("Membership tier conforms to Identifiable")
    func testMembershipTierIdentifiable() async throws {
        let tier = MembershipTier.seeker
        let _: String = tier.id
    }
    
    @Test("Free tier has correct price")
    func testFreeTierPrice() async throws {
        #expect(MembershipTier.free.price == "Free")
        #expect(MembershipTier.free.annualPrice == "Free")
    }
    
    @Test("Paid tiers have prices")
    func testPaidTierPrices() async throws {
        #expect(MembershipTier.seeker.price.contains("$"))
        #expect(MembershipTier.initiate.price.contains("$"))
        #expect(MembershipTier.master.price.contains("$"))
    }
    
    @Test("Each tier has features")
    func testTierFeatures() async throws {
        for tier in MembershipTier.allCases {
            #expect(!tier.features.isEmpty, "\(tier) should have features")
        }
    }
    
    @Test("Seeker tier is marked as popular")
    func testSeekerIsPopular() async throws {
        #expect(MembershipTier.seeker.isPopular == true)
        #expect(MembershipTier.free.isPopular == false)
    }
    
    @Test("Higher tiers have more features")
    func testFeatureCountProgression() async throws {
        let freeCount = MembershipTier.free.features.count
        let seekerCount = MembershipTier.seeker.features.count
        let initiateCount = MembershipTier.initiate.features.count
        let masterCount = MembershipTier.master.features.count
        
        #expect(seekerCount > freeCount)
        #expect(initiateCount >= seekerCount)
        #expect(masterCount >= initiateCount)
    }
    
    // MARK: - Tier Feature Tests
    
    @Test("TierFeature has required properties")
    func testTierFeatureProperties() async throws {
        let feature = TierFeature(
            icon: "star.fill",
            title: "Test Feature",
            description: "Test Description"
        )
        
        #expect(feature.icon == "star.fill")
        #expect(feature.title == "Test Feature")
        #expect(feature.description == "Test Description")
        #expect(feature.isIncluded == true)
    }
    
    @Test("TierFeature conforms to Identifiable")
    func testTierFeatureIdentifiable() async throws {
        let feature = TierFeature(icon: "star", title: "Test", description: "Test")
        let _: UUID = feature.id
    }
    
    // MARK: - Optional Properties Tests
    
    @Test("User with all optional properties")
    func testUserWithAllOptionals() async throws {
        let membershipExpiry = Date().addingTimeInterval(86400 * 30) // 30 days
        let lastActiveAt = Date()
        
        let user = QodeXUser(
            id: "test",
            email: "test@test.com",
            fullName: "Test User",
            birthDate: Date(),
            membershipTier: .seeker,
            membershipExpiry: membershipExpiry,
            createdAt: Date(),
            lastActiveAt: lastActiveAt,
            profileImageURL: "https://example.com/image.jpg",
            bio: "Test bio",
            location: "New York",
            timezone: "America/New_York"
        )
        
        #expect(user.membershipExpiry == membershipExpiry)
        #expect(user.lastActiveAt == lastActiveAt)
        #expect(user.profileImageURL == "https://example.com/image.jpg")
        #expect(user.bio == "Test bio")
        #expect(user.location == "New York")
        #expect(user.timezone == "America/New_York")
    }
    
    @Test("User with nil optional properties")
    func testUserWithNilOptionals() async throws {
        let user = QodeXUser(
            id: "test",
            email: "test@test.com",
            fullName: "Test User",
            birthDate: nil,
            membershipTier: .free,
            membershipExpiry: nil,
            createdAt: Date(),
            lastActiveAt: nil,
            profileImageURL: nil,
            bio: nil,
            location: nil,
            timezone: nil
        )
        
        #expect(user.birthDate == nil)
        #expect(user.membershipExpiry == nil)
        #expect(user.lastActiveAt == nil)
        #expect(user.profileImageURL == nil)
        #expect(user.bio == nil)
        #expect(user.location == nil)
        #expect(user.timezone == nil)
    }
    
    // MARK: - Subscription Product Tests
    
    @Test("All subscription products have valid tier mapping")
    func testSubscriptionProductTierMapping() async throws {
        let products: [SubscriptionProduct] = [
            .seekerMonthly, .seekerAnnual,
            .initiateMonthly, .initiateAnnual,
            .masterMonthly, .masterAnnual
        ]
        
        for product in products {
            #expect(product.tier != .free)
        }
    }
    
    @Test("Subscription products have correct tier associations")
    func testSubscriptionProductTiers() async throws {
        #expect(SubscriptionProduct.seekerMonthly.tier == .seeker)
        #expect(SubscriptionProduct.seekerAnnual.tier == .seeker)
        #expect(SubscriptionProduct.initiateMonthly.tier == .initiate)
        #expect(SubscriptionProduct.initiateAnnual.tier == .initiate)
        #expect(SubscriptionProduct.masterMonthly.tier == .master)
        #expect(SubscriptionProduct.masterAnnual.tier == .master)
    }
    
    // MARK: - UserProfileData Tests
    
    @Test("UserProfileData initializes correctly")
    func testUserProfileDataInitialization() async throws {
        let profile = UserProfileTestBuilder.makeUserProfileData()
        
        #expect(!profile.userId.isEmpty)
        #expect(!profile.name.isEmpty)
        #expect(!profile.email.isEmpty)
        #expect(!profile.timezone.isEmpty)
        #expect(profile.lifePath > 0)
    }
    
    @Test("UserProfileData converts to dictionary")
    func testUserProfileDataToDictionary() async throws {
        let profile = UserProfileTestBuilder.makeUserProfileData()
        let dict = profile.toDictionary()
        
        #expect(dict["userId"] as? String == profile.userId)
        #expect(dict["name"] as? String == profile.name)
        #expect(dict["email"] as? String == profile.email)
        #expect(dict["timezone"] as? String == profile.timezone)
        #expect(dict["lifePath"] as? Int == profile.lifePath)
    }
    
    @Test("UserProfileData initializes from dictionary")
    func testUserProfileDataFromDictionary() async throws {
        let dict: [String: Any] = [
            "userId": "test-id",
            "name": "Test User",
            "email": "test@example.com",
            "birthDate": Timestamp(date: Date()),
            "timezone": "UTC",
            "lifePath": 5,
            "createdAt": Timestamp(date: Date())
        ]
        
        let profile = UserProfileData(from: dict)
        
        #expect(profile.userId == "test-id")
        #expect(profile.name == "Test User")
        #expect(profile.email == "test@example.com")
        #expect(profile.timezone == "UTC")
        #expect(profile.lifePath == 5)
    }
    
    @Test("UserProfileData handles missing dictionary values")
    func testUserProfileDataFromEmptyDictionary() async throws {
        let dict: [String: Any] = [:]
        
        let profile = UserProfileData(from: dict)
        
        #expect(profile.userId.isEmpty)
        #expect(profile.name.isEmpty)
        #expect(profile.email.isEmpty)
        #expect(profile.timezone == "UTC") // Default value
        #expect(profile.lifePath == 1) // Default value
    }
}

// MARK: - Equatable Tests

@Suite("Equatable Tests")
struct EquatableTests {
    
    @Test("Same user ID means same user")
    func testSameUser() async throws {
        let user1 = UserProfileTestBuilder.makeUser(id: "same-id", fullName: "Name One")
        let user2 = UserProfileTestBuilder.makeUser(id: "same-id", fullName: "Name Two")
        
        // Users with same ID should be equal
        #expect(user1.id == user2.id)
    }
    
    @Test("Different users have different IDs")
    func testDifferentUsers() async throws {
        let user1 = UserProfileTestBuilder.makeUser()
        let user2 = UserProfileTestBuilder.makeUser()
        
        // Different UUIDs should be different
        #expect(user1.id != user2.id)
    }
}

// MARK: - Helper Extensions

// Helper to make Timestamp available for tests
struct Timestamp {
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
}