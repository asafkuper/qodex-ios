//
//  UniversalLinksHandler.swift
//  Handle universal links from web, email, social media
//

import Foundation

class UniversalLinksHandler {
    static let shared = UniversalLinksHandler()
    
    // MARK: - Handle Incoming URL
    func handle(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return false
        }
        
        switch host {
        case "qodex.academy":
            return handleQodexLink(components: components)
        case "app.qodex.academy":
            return handleAppLink(components: components)
        default:
            return false
        }
    }
    
    // MARK: - QodeX Domain Links
    private func handleQodexLink(components: URLComponents) -> Bool {
        let path = components.path
        
        if path.hasPrefix("/daily") {
            return handleDailyLink(components: components)
        } else if path.hasPrefix("/chart") {
            return handleChartLink(components: components)
        } else if path.hasPrefix("/mentor") {
            return handleMentorLink(components: components)
        } else if path.hasPrefix("/community") {
            return handleCommunityLink(components: components)
        } else if path.hasPrefix("/session") {
            return handleSessionLink(components: components)
        } else if path.hasPrefix("/referral") {
            return handleReferralLink(components: components)
        }
        
        return false
    }
    
    // MARK: - App Links
    private func handleAppLink(components: URLComponents) -> Bool {
        // Handle app-specific deep links
        // app.qodex.academy/open/chart/123
        let pathComponents = components.path.split(separator: "/")
        
        guard pathComponents.count >= 2 else { return false }
        
        let action = String(pathComponents[0])
        let id = pathComponents.count > 1 ? String(pathComponents[1]) : nil
        
        switch action {
        case "open":
            if let resourceId = id {
                return openResource(id: resourceId)
            }
        case "share":
            if let contentId = id {
                return handleShare(id: contentId)
            }
        default:
            return false
        }
        
        return false
    }
    
    // MARK: - Specific Handlers
    private func handleDailyLink(components: URLComponents) -> Bool {
        // qodex.academy/daily?date=2024-01-01
        let date = components.queryItems?.first(where: { $0.name == "date" })?.value
        
        NotificationCenter.default.post(
            name: Notification.Name("OpenDailyReading"),
            object: nil,
            userInfo: date != nil ? ["date": date!] : nil
        )
        
        return true
    }
    
    private func handleChartLink(components: URLComponents) -> Bool {
        // qodex.academy/chart?id=user123
        let userId = components.queryItems?.first(where: { $0.name == "id" })?.value
        
        NotificationCenter.default.post(
            name: Notification.Name("OpenChart"),
            object: nil,
            userInfo: userId != nil ? ["userId": userId!] : nil
        )
        
        return true
    }
    
    private func handleMentorLink(components: URLComponents) -> Bool {
        // qodex.academy/mentor?id=mentor456
        guard let mentorId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            return false
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("OpenMentorProfile"),
            object: nil,
            userInfo: ["mentorId": mentorId]
        )
        
        return true
    }
    
    private func handleCommunityLink(components: URLComponents) -> Bool {
        // qodex.academy/community/post/789
        let pathComponents = components.path.split(separator: "/")
        
        if pathComponents.count >= 3,
           let postId = String(pathComponents[2]) as String? {
            NotificationCenter.default.post(
                name: Notification.Name("OpenCommunityPost"),
                object: nil,
                userInfo: ["postId": postId]
            )
            return true
        }
        
        // Just open community
        NotificationCenter.default.post(name: Notification.Name("OpenCommunity"), object: nil)
        return true
    }
    
    private func handleSessionLink(components: URLComponents) -> Bool {
        // qodex.academy/session?id=session789
        guard let sessionId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            return false
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("OpenLiveSession"),
            object: nil,
            userInfo: ["sessionId": sessionId]
        )
        
        return true
    }
    
    private func handleReferralLink(components: URLComponents) -> Bool {
        // qodex.academy/referral?code=ABC123
        guard let referralCode = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return false
        }
        
        // Store referral code
        UserDefaults.standard.set(referralCode, forKey: "pendingReferralCode")
        
        NotificationCenter.default.post(
            name: Notification.Name("HandleReferral"),
            object: nil,
            userInfo: ["code": referralCode]
        )
        
        return true
    }
    
    private func openResource(id: String) -> Bool {
        NotificationCenter.default.post(
            name: Notification.Name("OpenResource"),
            object: nil,
            userInfo: ["resourceId": id]
        )
        return true
    }
    
    private func handleShare(id: String) -> Bool {
        NotificationCenter.default.post(
            name: Notification.Name("HandleSharedContent"),
            object: nil,
            userInfo: ["contentId": id]
        )
        return true
    }
    
    // MARK: - Generate Shareable Links
    func generateShareLink(for content: ShareableContent) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "qodex.academy"
        
        switch content {
        case .dailyReading(let date):
            components.path = "/daily"
            components.queryItems = [
                URLQueryItem(name: "date", value: ISO8601DateFormatter().string(from: date))
            ]
            
        case .chart(let userId):
            components.path = "/chart"
            components.queryItems = [
                URLQueryItem(name: "id", value: userId)
            ]
            
        case .mentor(let mentorId):
            components.path = "/mentor"
            components.queryItems = [
                URLQueryItem(name: "id", value: mentorId)
            ]
            
        case .communityPost(let postId):
            components.path = "/community/post/\(postId)"
            
        case .session(let sessionId):
            components.path = "/session"
            components.queryItems = [
                URLQueryItem(name: "id", value: sessionId)
            ]
            
        case .referral(let code):
            components.path = "/referral"
            components.queryItems = [
                URLQueryItem(name: "code", value: code)
            ]
        }
        
        return components.url
    }
}

// MARK: - Shareable Content Types
enum ShareableContent {
    case dailyReading(date: Date)
    case chart(userId: String)
    case mentor(mentorId: String)
    case communityPost(postId: String)
    case session(sessionId: String)
    case referral(code: String)
}
