//
//  DeepLinkManager.swift
//  Universal Links, Custom URL Schemes, Navigation
//

import Foundation
import SwiftUI

@MainActor
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var currentRoute: AppRoute?
    @Published var presentedSheet: SheetRoute?
    
    private init() {}
    
    // MARK: - URL Handling
    
    func handle(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        // Handle Universal Links (https://qodex.academy/app/...)
        if components.host == "qodex.academy" {
            return handleUniversalLink(components: components)
        }
        
        // Handle Custom URL Scheme (qodex://...)
        if url.scheme == "qodex" {
            return handleCustomScheme(components: components)
        }
        
        return false
    }
    
    private func handleUniversalLink(components: URLComponents) -> Bool {
        let path = components.path.trimmingCharacters(in: "/")
        let segments = path.split(separator: "/").map(String.init)
        
        guard let first = segments.first else { return false }
        
        switch first {
        case "qode":
            if segments.count > 1 {
                currentRoute = .calculatorResult(number: segments[1])
            } else {
                currentRoute = .calculator
            }
            
        case "teaching":
            if let teachingId = segments.dropFirst().first {
                currentRoute = .teaching(id: teachingId)
            }
            
        case "live":
            if let sessionId = segments.dropFirst().first {
                currentRoute = .liveSession(id: sessionId)
            } else {
                currentRoute = .liveSessions
            }
            
        case "community":
            if let topicId = segments.dropFirst().first {
                currentRoute = .topic(id: topicId)
            } else {
                currentRoute = .community
            }
            
        case "profile":
            currentRoute = .profile
            
        case "membership":
            presentedSheet = .paywall
            
        case "invite":
            if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                handleInviteCode(code)
            }
            
        case "reset-password":
            if let token = components.queryItems?.first(where: { $0.name == "token" })?.value {
                presentedSheet = .passwordReset(token: token)
            }
            
        default:
            return false
        }
        
        return true
    }
    
    private func handleCustomScheme(components: URLComponents) -> Bool {
        let path = components.host ?? ""
        
        switch path {
        case "daily-qode":
            currentRoute = .dailyQode
            
        case "calculator":
            currentRoute = .calculator
            
        case "library":
            currentRoute = .library
            
        case "community":
            currentRoute = .community
            
        case "live":
            currentRoute = .liveSessions
            
        case "profile":
            currentRoute = .profile
            
        case "settings":
            presentedSheet = .settings
            
        case "support":
            presentedSheet = .support
            
        case "share":
            if let text = components.queryItems?.first(where: { $0.name == "text" })?.value {
                presentedSheet = .shareSheet(text: text)
            }
            
        default:
            return false
        }
        
        return true
    }
    
    // MARK: - Share Links
    
    func generateShareLink(for type: ShareableContent) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "qodex.academy"
        
        switch type {
        case .dailyQode(let number):
            components.path = "/app/qode/\(number)"
            components.queryItems = [
                URLQueryItem(name: "utm_source", value: "app"),
                URLQueryItem(name: "utm_medium", value: "share")
            ]
            
        case .teaching(let id, let title):
            components.path = "/app/teaching/\(id)"
            components.queryItems = [
                URLQueryItem(name: "title", value: title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            ]
            
        case .liveSession(let id, let title):
            components.path = "/app/live/\(id)"
            components.queryItems = [
                URLQueryItem(name: "title", value: title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            ]
            
        case .invite(let code):
            components.path = "/app/invite"
            components.queryItems = [URLQueryItem(name: "code", value: code)]
            
        case .appStore:
            return URL(string: "https://apps.apple.com/app/qodex/id1234567890")!
        }
        
        return components.url!
    }
    
    // MARK: - Invite System
    
    private func handleInviteCode(_ code: String) {
        // Validate and apply invite code
        Task {
            do {
                let result = try await validateInviteCode(code)
                if result.valid {
                    // Apply reward (free month, discount, etc.)
                    await applyInviteReward(result)
                    currentRoute = .inviteSuccess(reward: result.reward)
                }
            } catch {
                currentRoute = .inviteError(message: error.localizedDescription)
            }
        }
    }
    
    private func validateInviteCode(_ code: String) async throws -> InviteValidation {
        // Call Firebase Function
        return InviteValidation(valid: true, reward: .freeWeek)
    }
    
    private func applyInviteReward(_ validation: InviteValidation) async {
        // Update user subscription
    }
    
    // MARK: - Widget Deep Links
    
    func handleWidgetURL(_ url: URL) {
        // Handle widget interactions
        if url.absoluteString.contains("widget-daily-qode") {
            currentRoute = .dailyQode
        } else if url.absoluteString.contains("widget-live") {
            currentRoute = .liveSessions
        } else if url.absoluteString.contains("widget-progress") {
            currentRoute = .profile
        }
    }
}

// MARK: - Routes

enum AppRoute: Hashable {
    case dailyQode
    case calculator
    case calculatorResult(number: String)
    case teaching(id: String)
    case library
    case liveSessions
    case liveSession(id: String)
    case community
    case topic(id: String)
    case profile
    case inviteSuccess(reward: InviteReward)
    case inviteError(message: String)
}

enum SheetRoute: Identifiable {
    case paywall
    case settings
    case support
    case passwordReset(token: String)
    case shareSheet(text: String)
    
    var id: String {
        switch self {
        case .paywall: return "paywall"
        case .settings: return "settings"
        case .support: return "support"
        case .passwordReset(let token): return "reset-\(token)"
        case .shareSheet(let text): return "share-\(text.hashValue)"
        }
    }
}

enum ShareableContent {
    case dailyQode(number: Int)
    case teaching(id: String, title: String)
    case liveSession(id: String, title: String)
    case invite(code: String)
    case appStore
}

struct InviteValidation {
    let valid: Bool
    let reward: InviteReward
}

enum InviteReward {
    case freeWeek
    case freeMonth
    case discount50
    case discount25
}
