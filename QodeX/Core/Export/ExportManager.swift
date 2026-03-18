//
//  ExportManager.swift
//  Export and share user data - GDPR Compliant
//

import Foundation
import PDFKit
import UIKit
import FirebaseFirestore
import FirebaseAuth

/// Manages user data export for GDPR compliance and sharing
class ExportManager {
    static let shared = ExportManager()
    
    private let db = Firestore.firestore()
    
    // MARK: - Export Types
    enum ExportFormat {
        case pdf
        case image
        case json
        case csv
    }
    
    enum ExportError: Error {
        case notAuthenticated
        case dataFetchFailed(String)
        case exportGenerationFailed
        case noDataAvailable
        case fileSystemError
        case networkError
        
        var localizedDescription: String {
            switch self {
            case .notAuthenticated:
                return "User not authenticated"
            case .dataFetchFailed(let reason):
                return "Failed to fetch data: \(reason)"
            case .exportGenerationFailed:
                return "Failed to generate export file"
            case .noDataAvailable:
                return "No data available to export"
            case .fileSystemError:
                return "File system error"
            case .networkError:
                return "Network error - please try again"
            }
        }
    }
    
    // MARK: - GDPR Data Export
    
    /// Complete GDPR-compliant data export for a user
    /// Fetches ALL user data from Firestore and exports to JSON
    func exportUserData(userId: String? = nil) async -> Result<ExportedUserData, ExportError> {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return .failure(.notAuthenticated)
        }
        
        let targetUserId = userId ?? currentUserId
        
        // Security check: users can only export their own data
        guard targetUserId == currentUserId else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Fetch all user data concurrently
            async let userProfile = fetchUserProfile(userId: targetUserId)
            async let journalEntries = fetchJournalEntries(userId: targetUserId)
            async let notifications = fetchNotifications(userId: targetUserId)
            async let activityLog = fetchActivityLog(userId: targetUserId)
            async let readings = fetchQodeReads(userId: targetUserId)
            async let communityPosts = fetchCommunityPosts(userId: targetUserId)
            async let communityComments = fetchCommunityComments(userId: targetUserId)
            async let subscriptions = fetchSubscriptions(userId: targetUserId)
            async let compatibilityReports = fetchCompatibilityReports(userId: targetUserId)
            async let mentorshipRequests = fetchMentorshipRequests(userId: targetUserId)
            async let challengeProgress = fetchChallengeProgress(userId: targetUserId)
            
            // Wait for all fetches to complete
            let exportedData = ExportedUserData(
                exportMetadata: ExportMetadata(
                    userId: targetUserId,
                    exportDate: Date(),
                    appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
                    dataVersion: "1.0"
                ),
                userProfile: try await userProfile,
                journalEntries: try await journalEntries,
                notifications: try await notifications,
                activityLog: try await activityLog,
                qodeReads: try await readings,
                communityPosts: try await communityPosts,
                communityComments: try await communityComments,
                subscriptions: try await subscriptions,
                compatibilityReports: try await compatibilityReports,
                mentorshipRequests: try await mentorshipRequests,
                challengeProgress: try await challengeProgress
            )
            
            return .success(exportedData)
            
        } catch let error as ExportError {
            return .failure(error)
        } catch {
            return .failure(.dataFetchFailed(error.localizedDescription))
        }
    }
    
    /// Exports user data to JSON file for download
    func exportUserDataToFile(userId: String? = nil) async -> Result<URL, ExportError> {
        let exportResult = await exportUserData(userId: userId)
        
        switch exportResult {
        case .success(let exportedData):
            do {
                let jsonData = try JSONEncoder().encode(exportedData)
                
                // Save to temporary file
                let fileName = "qodex_data_export_\(exportedData.exportMetadata.userId)_\(Int(Date().timeIntervalSince1970)).json"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                try jsonData.write(to: tempURL)
                
                return .success(tempURL)
            } catch {
                return .failure(.exportGenerationFailed)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Data Fetching Methods
    
    private func fetchUserProfile(userId: String) async throws -> UserProfileExport? {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard let data = doc.data() else { return nil }
        
        return UserProfileExport(
            id: doc.documentID,
            email: data["email"] as? String ?? "",
            fullName: data["fullName"] as? String ?? "",
            birthDate: (data["birthDate"] as? Timestamp)?.dateValue(),
            birthTime: (data["birthTime"] as? Timestamp)?.dateValue(),
            birthLocation: data["birthLocation"] as? String,
            timezone: data["timezone"] as? String,
            membershipTier: data["membershipTier"] as? String ?? "free",
            membershipExpiry: (data["membershipExpiry"] as? Timestamp)?.dateValue(),
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastActiveAt: (data["lastActiveAt"] as? Timestamp)?.dateValue(),
            bio: data["bio"] as? String,
            location: data["location"] as? String,
            notificationSettings: data["notificationSettings"] as? [String: Bool] ?? [:],
            streakData: data["streakData"] as? [String: Any]
        )
    }
    
    private func fetchJournalEntries(userId: String) async throws -> [JournalEntryExport] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("journal")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return JournalEntryExport(
                id: doc.documentID,
                title: data["title"] as? String ?? "",
                content: data["content"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue(),
                tags: data["tags"] as? [String] ?? [],
                mood: data["mood"] as? String,
                numerologyInsights: data["numerologyInsights"] as? [String: Any]
            )
        }
    }
    
    private func fetchNotifications(userId: String) async throws -> [NotificationExport] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return NotificationExport(
                id: doc.documentID,
                title: data["title"] as? String ?? "",
                body: data["body"] as? String ?? "",
                type: data["type"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                isRead: data["isRead"] as? Bool ?? false,
                metadata: data["metadata"] as? [String: Any]
            )
        }
    }
    
    private func fetchActivityLog(userId: String) async throws -> [ActivityExport] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("activity")
            .order(by: "timestamp", descending: true)
            .limit(to: 1000) // Limit to last 1000 activities
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return ActivityExport(
                id: doc.documentID,
                action: data["action"] as? String ?? "",
                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                metadata: data["metadata"] as? [String: Any]
            )
        }
    }
    
    private func fetchQodeReads(userId: String) async throws -> [QodeReadExport] {
        let snapshot = try await db.collection("qode_reads")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return QodeReadExport(
                id: doc.documentID,
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                number: data["number"] as? Int ?? 0,
                completed: data["completed"] as? Bool ?? false,
                reflection: data["reflection"] as? String
            )
        }
    }
    
    private func fetchCommunityPosts(userId: String) async throws -> [CommunityPostExport] {
        let snapshot = try await db.collection("community_posts")
            .whereField("authorId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return CommunityPostExport(
                id: doc.documentID,
                title: data["title"] as? String ?? "",
                content: data["content"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue(),
                likesCount: data["likesCount"] as? Int ?? 0,
                commentsCount: data["commentsCount"] as? Int ?? 0
            )
        }
    }
    
    private func fetchCommunityComments(userId: String) async throws -> [CommunityCommentExport] {
        let snapshot = try await db.collectionGroup("comments")
            .whereField("authorId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return CommunityCommentExport(
                id: doc.documentID,
                postId: data["postId"] as? String ?? "",
                text: data["text"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
            )
        }
    }
    
    private func fetchSubscriptions(userId: String) async throws -> [SubscriptionExport] {
        let snapshot = try await db.collection("subscriptions")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return SubscriptionExport(
                id: doc.documentID,
                tier: data["tier"] as? String ?? "",
                status: data["status"] as? String ?? "",
                startDate: (data["startDate"] as? Timestamp)?.dateValue(),
                endDate: (data["endDate"] as? Timestamp)?.dateValue(),
                transactionId: data["transactionId"] as? String,
                revenueCatId: data["revenueCatId"] as? String
            )
        }
    }
    
    private func fetchCompatibilityReports(userId: String) async throws -> [CompatibilityReportExport] {
        let snapshot = try await db.collection("compatibility_reports")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return CompatibilityReportExport(
                id: doc.documentID,
                partnerName: data["partnerName"] as? String ?? "",
                partnerBirthDate: (data["partnerBirthDate"] as? Timestamp)?.dateValue(),
                compatibilityScore: data["compatibilityScore"] as? Int,
                report: data["report"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    
    private func fetchMentorshipRequests(userId: String) async throws -> [MentorshipRequestExport] {
        let snapshot = try await db.collection("mentorship_requests")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return MentorshipRequestExport(
                id: doc.documentID,
                type: data["type"] as? String ?? "",
                message: data["message"] as? String,
                status: data["status"] as? String ?? "pending",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
            )
        }
    }
    
    private func fetchChallengeProgress(userId: String) async throws -> [ChallengeProgressExport] {
        // Fetch from challenges collection where user is a participant
        let snapshot = try await db.collectionGroup("participants")
            .whereField(FieldPath.documentID(), isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            let challengeId = doc.reference.parent.parent?.documentID ?? ""
            return ChallengeProgressExport(
                challengeId: challengeId,
                progress: data["progress"] as? Double ?? 0.0,
                completed: data["completed"] as? Bool ?? false,
                joinedAt: (data["joinedAt"] as? Timestamp)?.dateValue() ?? Date(),
                completedAt: (data["completedAt"] as? Timestamp)?.dateValue()
            )
        }
    }
    
    // MARK: - Generate Chart PDF
    
    func generateChartPDF(for user: QodeXUser) async -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "QodeX",
            kCGPDFContextAuthor: user.fullName,
            kCGPDFContextTitle: "\(user.fullName)'s Numerology Chart"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(hex: "E5C158")!
            ]
            let title = "Your Numerology Chart"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // User Info
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            
            var yPosition: CGFloat = 120
            
            if let birthDate = user.birthDate {
                let dateText = "Birth Date: \(birthDate.formatted(date: .long, time: .omitted))"
                dateText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: infoAttributes)
                yPosition += 30
            }
            
            // Core Numbers
            let calculator = NumerologyCalculator()
            let lifePath = calculator.calculateLifePathNumber(birthDate: user.birthDate ?? Date())
            
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            
            yPosition += 40
            "Life Path Number: \(lifePath)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            
            yPosition += 50
            let description = getLifePathDescription(lifePath)
            let descAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            description.draw(in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 200), withAttributes: descAttributes)
            
            // Footer
            yPosition = pageHeight - 50
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.lightGray
            ]
            "Generated by QodeX • qodex.academy".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: footerAttributes)
        }
        
        return data
    }
    
    // MARK: - Generate Share Image
    
    func generateShareImage(dailyNumber: Int, vibe: String, date: Date) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Background
        let backgroundColor = UIColor(hex: "12121A")!
        context.setFillColor(backgroundColor.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Decorative elements
        let goldColor = UIColor(hex: "E5C158")!
        context.setStrokeColor(goldColor.cgColor)
        context.setLineWidth(2)
        
        // Draw circle
        let circleRect = CGRect(x: 340, y: 200, width: 400, height: 400)
        context.strokeEllipse(in: circleRect)
        
        // Draw number
        let numberText = "\(dailyNumber)" as NSString
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 200, weight: .bold),
            .foregroundColor: goldColor
        ]
        let numberSize = numberText.size(withAttributes: numberAttributes)
        numberText.draw(at: CGPoint(x: (size.width - numberSize.width) / 2, y: 300), withAttributes: numberAttributes)
        
        // Draw vibe
        let vibeText = vibe as NSString
        let vibeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let vibeSize = vibeText.size(withAttributes: vibeAttributes)
        vibeText.draw(at: CGPoint(x: (size.width - vibeSize.width) / 2, y: 650), withAttributes: vibeAttributes)
        
        // Draw date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateText = dateFormatter.string(from: date) as NSString
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.lightGray
        ]
        let dateSize = dateText.size(withAttributes: dateAttributes)
        dateText.draw(at: CGPoint(x: (size.width - dateSize.width) / 2, y: 750), withAttributes: dateAttributes)
        
        // Draw branding
        let brandText = "QodeX" as NSString
        let brandAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold),
            .foregroundColor: goldColor
        ]
        brandText.draw(at: CGPoint(x: 50, y: size.height - 100), withAttributes: brandAttributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Share Sheet
    
    func presentShareSheet(for item: ShareableItem, from viewController: UIViewController) {
        let activityItems: [Any]
        
        switch item {
        case .dailyReading(let number, let vibe):
            if let image = generateShareImage(dailyNumber: number, vibe: vibe, date: Date()) {
                activityItems = [image, "Today's QodeX number is \(number) - \(vibe)!"]
            } else {
                activityItems = ["Today's number is \(number)"]
            }
            
        case .chartPDF(let user):
            Task {
                if let pdfData = await generateChartPDF(for: user) {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("chart.pdf")
                    try? pdfData.write(to: tempURL)
                    
                    await MainActor.run {
                        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                        viewController.present(activityVC, animated: true)
                    }
                }
            }
            return
            
        case .referral(let code):
            activityItems = ["Join me on QodeX! Use my code \(code) for a discount.", URL(string: "https://qodex.academy/refer/\(code)")!]
            
        case .dataExport(let url):
            let activityItems: [Any] = [
                url,
                "My QodeX data export"
            ]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            viewController.present(activityVC, animated: true)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    enum ShareableItem {
        case dailyReading(number: Int, vibe: String)
        case chartPDF(user: QodeXUser)
        case referral(code: String)
        case dataExport(url: URL)
    }
    
    // MARK: - Private Helpers
    
    private func getLifePathDescription(_ number: Int) -> String {
        let descriptions: [Int: String] = [
            1: "As a Life Path 1, you are a natural born leader. You have a strong desire to be independent and to lead others. Your determination and self-confidence are your greatest assets.",
            2: "Life Path 2 brings diplomacy and partnership. You are sensitive, intuitive, and cooperative. Your ability to bring people together is your superpower.",
            3: "As a Life Path 3, creativity and self-expression are your gifts. You are optimistic, joyful, and have a natural ability to communicate.",
            4: "Life Path 4 is the path of stability and foundation. You are practical, hardworking, and detail-oriented. Building lasting structures is your strength.",
            5: "As a Life Path 5, freedom and adventure call to you. You are versatile, curious, and adaptable. Change is your constant companion.",
            6: "Life Path 6 is the nurturer's path. You are compassionate, responsible, and protective. Creating harmony in relationships is your gift.",
            7: "Life Path 7 is the path of the seeker. You are analytical, spiritual, and drawn to understanding the deeper mysteries of life.",
            8: "As a Life Path 8, abundance and power are your themes. You are ambitious, efficient, and have strong executive abilities.",
            9: "Life Path 9 is the humanitarian path. You are compassionate, tolerant, and drawn to helping others. Completion and service guide you."
        ]
        return descriptions[number] ?? "Your Life Path number reveals your unique journey and purpose."
    }
}

// MARK: - Exported Data Structures

/// Complete user data export structure (GDPR compliant)
struct ExportedUserData: Codable {
    let exportMetadata: ExportMetadata
    let userProfile: UserProfileExport?
    let journalEntries: [JournalEntryExport]
    let notifications: [NotificationExport]
    let activityLog: [ActivityExport]
    let qodeReads: [QodeReadExport]
    let communityPosts: [CommunityPostExport]
    let communityComments: [CommunityCommentExport]
    let subscriptions: [SubscriptionExport]
    let compatibilityReports: [CompatibilityReportExport]
    let mentorshipRequests: [MentorshipRequestExport]
    let challengeProgress: [ChallengeProgressExport]
}

struct ExportMetadata: Codable {
    let userId: String
    let exportDate: Date
    let appVersion: String
    let dataVersion: String
}

struct UserProfileExport: Codable {
    let id: String
    let email: String
    let fullName: String
    let birthDate: Date?
    let birthTime: Date?
    let birthLocation: String?
    let timezone: String?
    let membershipTier: String
    let membershipExpiry: Date?
    let createdAt: Date
    let lastActiveAt: Date?
    let bio: String?
    let location: String?
    let notificationSettings: [String: Bool]
    let streakData: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, email, fullName, birthDate, birthTime, birthLocation, timezone
        case membershipTier, membershipExpiry, createdAt, lastActiveAt, bio, location
        case notificationSettings, streakData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(birthDate?.iso8601, forKey: .birthDate)
        try container.encode(birthTime?.iso8601, forKey: .birthTime)
        try container.encode(birthLocation, forKey: .birthLocation)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(membershipTier, forKey: .membershipTier)
        try container.encode(membershipExpiry?.iso8601, forKey: .membershipExpiry)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(lastActiveAt?.iso8601, forKey: .lastActiveAt)
        try container.encode(bio, forKey: .bio)
        try container.encode(location, forKey: .location)
        try container.encode(notificationSettings, forKey: .notificationSettings)
    }
}

struct JournalEntryExport: Codable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date?
    let tags: [String]
    let mood: String?
    let numerologyInsights: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, createdAt, updatedAt, tags, mood, numerologyInsights
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(updatedAt?.iso8601, forKey: .updatedAt)
        try container.encode(tags, forKey: .tags)
        try container.encode(mood, forKey: .mood)
    }
}

struct NotificationExport: Codable {
    let id: String
    let title: String
    let body: String
    let type: String
    let createdAt: Date
    let isRead: Bool
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, type, createdAt, isRead, metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(isRead, forKey: .isRead)
    }
}

struct ActivityExport: Codable {
    let id: String
    let action: String
    let timestamp: Date
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, action, timestamp, metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(action, forKey: .action)
        try container.encode(timestamp.iso8601, forKey: .timestamp)
    }
}

struct QodeReadExport: Codable {
    let id: String
    let date: Date
    let number: Int
    let completed: Bool
    let reflection: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, number, completed, reflection
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date.iso8601, forKey: .date)
        try container.encode(number, forKey: .number)
        try container.encode(completed, forKey: .completed)
        try container.encode(reflection, forKey: .reflection)
    }
}

struct CommunityPostExport: Codable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date?
    let likesCount: Int
    let commentsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, createdAt, updatedAt, likesCount, commentsCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(updatedAt?.iso8601, forKey: .updatedAt)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(commentsCount, forKey: .commentsCount)
    }
}

struct CommunityCommentExport: Codable {
    let id: String
    let postId: String
    let text: String
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, postId, text, createdAt, updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(postId, forKey: .postId)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(updatedAt?.iso8601, forKey: .updatedAt)
    }
}

struct SubscriptionExport: Codable {
    let id: String
    let tier: String
    let status: String
    let startDate: Date?
    let endDate: Date?
    let transactionId: String?
    let revenueCatId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, tier, status, startDate, endDate, transactionId, revenueCatId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(tier, forKey: .tier)
        try container.encode(status, forKey: .status)
        try container.encode(startDate?.iso8601, forKey: .startDate)
        try container.encode(endDate?.iso8601, forKey: .endDate)
        try container.encode(transactionId, forKey: .transactionId)
        try container.encode(revenueCatId, forKey: .revenueCatId)
    }
}

struct CompatibilityReportExport: Codable {
    let id: String
    let partnerName: String
    let partnerBirthDate: Date?
    let compatibilityScore: Int?
    let report: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, partnerName, partnerBirthDate, compatibilityScore, report, createdAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(partnerName, forKey: .partnerName)
        try container.encode(partnerBirthDate?.iso8601, forKey: .partnerBirthDate)
        try container.encode(compatibilityScore, forKey: .compatibilityScore)
        try container.encode(report, forKey: .report)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
    }
}

struct MentorshipRequestExport: Codable {
    let id: String
    let type: String
    let message: String?
    let status: String
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, type, message, status, createdAt, updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(message, forKey: .message)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt.iso8601, forKey: .createdAt)
        try container.encode(updatedAt?.iso8601, forKey: .updatedAt)
    }
}

struct ChallengeProgressExport: Codable {
    let challengeId: String
    let progress: Double
    let completed: Bool
    let joinedAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case challengeId, progress, completed, joinedAt, completedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(challengeId, forKey: .challengeId)
        try container.encode(progress, forKey: .progress)
        try container.encode(completed, forKey: .completed)
        try container.encode(joinedAt.iso8601, forKey: .joinedAt)
        try container.encode(completedAt?.iso8601, forKey: .completedAt)
    }
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
}

// MARK: - Date Extension

extension Date {
    var iso8601: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

// MARK: - NumerologyCalculator Placeholder

class NumerologyCalculator {
    func calculateLifePathNumber(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: birthDate)
        
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000
        
        let sum = reduceToSingleDigit(day) + reduceToSingleDigit(month) + reduceToSingleDigit(year)
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 && n != 11 && n != 22 && n != 33 {
            var sum = 0
            while n > 0 {
                sum += n % 10
                n /= 10
            }
            n = sum
        }
        return n == 0 ? 1 : n
    }
}
