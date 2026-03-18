//
//  DeepLinkManager.swift
//  Universal linking and URL handling
//

import Foundation
import SwiftUI

enum DeepLinkRoute: Equatable {
    case dailyQode(date: Date?)
    case lifePath(userId: String?)
    case chart(type: ChartType)
    case liveSession(sessionId: String)
    case mentorship(mentorId: String?)
    case community(topicId: String?)
    case paywall(feature: PremiumFeature)
    case settings(tab: String?)
    case onboarding(step: Int?)
    
    enum ChartType {
        case full
        case compatibility(with: String)
        case yearly(year: Int)
    }
}

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var currentRoute: DeepLinkRoute?
    @Published var pendingRoute: DeepLinkRoute?
    
    private init() {}
    
    // MARK: - Handle Incoming URL
    func handle(url: URL) -> Bool {
        guard let route = parse(url: url) else {
            return false
        }
        
        // Check if user is authenticated for protected routes
        if requiresAuthentication(route) && !AuthManager.shared.isAuthenticated {
            pendingRoute = route
            currentRoute = .onboarding(step: nil)
            return true
        }
        
        currentRoute = route
        logDeepLink(route: route, url: url)
        return true
    }
    
    // MARK: - Parse URL
    private func parse(url: URL) -> DeepLinkRoute? {
        // Universal Links: https://qodex.academy/app/...
        // Custom URL Scheme: qodex://...
        
        if url.scheme == "qodex" {
            return parseCustomScheme(url: url)
        }
        
        if url.host == "qodex.academy" {
            return parseUniversalLink(url: url)
        }
        
        return nil
    }
    
    private func parseCustomScheme(url: URL) -> DeepLinkRoute? {
        let path = url.pathComponents.filter { $0 != "/" }
        guard !path.isEmpty else { return nil }
        
        switch path[0] {
        case "daily":
            let date = parseDate(from: url.queryParameters?["date"])
            return .dailyQode(date: date)
            
        case "lifepath":
            return .lifePath(userId: url.queryParameters?["userId"])
            
        case "chart":
            let type = path.count > 1 ? path[1] : "full"
            return .chart(type: parseChartType(type, query: url.queryParameters))
            
        case "live":
            guard let sessionId = url.queryParameters?["id"] else { return nil }
            return .liveSession(sessionId: sessionId)
            
        case "mentor":
            return .mentorship(mentorId: url.queryParameters?["id"])
            
        case "community":
            return .community(topicId: url.queryParameters?["topicId"])
            
        case "premium":
            let feature = url.queryParameters?["feature"] ?? "full"
            return .paywall(feature: parseFeature(feature))
            
        case "settings":
            return .settings(tab: url.queryParameters?["tab"])
            
        default:
            return nil
        }
    }
    
    private func parseUniversalLink(url: URL) -> DeepLinkRoute? {
        let path = url.pathComponents.filter { $0 != "/" }
        guard path.count >= 2, path[0] == "app" else { return nil }
        
        // Same parsing as custom scheme but from /app/ path
        switch path[1] {
        case "daily":
            return .dailyQode(date: nil)
        case "chart":
            return .chart(type: .full)
        case "mentorship":
            return .mentorship(mentorId: nil)
        default:
            return nil
        }
    }
    
    // MARK: - Generate Shareable Links
    func generateShareLink(for route: DeepLinkRoute) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "qodex.academy"
        
        switch route {
        case .dailyQode:
            components.path = "/app/daily"
            
        case .lifePath(let userId):
            components.path = "/app/lifepath"
            if let id = userId {
                components.queryItems = [URLQueryItem(name: "userId", value: id)]
            }
            
        case .liveSession(let sessionId):
            components.path = "/app/live"
            components.queryItems = [URLQueryItem(name: "id", value: sessionId)]
            
        default:
            return nil
        }
        
        return components.url
    }
    
    // MARK: - Share Reading
    func shareReading(_ reading: DailyReading, from viewController: UIViewController) {
        let link = generateShareLink(for: .dailyQode(date: reading.date))?.absoluteString ?? ""
        
        let text = """
        Today's Energy: \(reading.number) - \(reading.vibe)
        
        \(reading.fullReading.prefix(100))...
        
        Discover your numbers: \(link)
        """
        
        let activityItems: [Any] = [text]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Private Helpers
    private func requiresAuthentication(_ route: DeepLinkRoute) -> Bool {
        switch route {
        case .onboarding, .paywall:
            return false
        default:
            return true
        }
    }
    
    private func parseDate(from string: String?) -> Date? {
        guard let string = string else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
    
    private func parseChartType(_ type: String, query: [String: String]?) -> DeepLinkRoute.ChartType {
        switch type {
        case "compatibility":
            return .compatibility(with: query?["with"] ?? "")
        case "yearly":
            let year = Int(query?["year"] ?? "") ?? Calendar.current.component(.year, from: Date())
            return .yearly(year: year)
        default:
            return .full
        }
    }
    
    private func parseFeature(_ feature: String) -> PremiumFeature {
        switch feature {
        case "soul": return .soulUrge
        case "destiny": return .destiny
        case "compatibility": return .compatibility
        default: return .dailyExtended
        }
    }
    
    private func logDeepLink(route: DeepLinkRoute, url: URL) {
        QodeXAnalytics.shared.logEvent("deep_link_opened", parameters: [
            "route": String(describing: route),
            "url": url.absoluteString
        ])
    }
}

// MARK: - URL Extensions
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}

// MARK: - SwiftUI Integration
struct DeepLinkHandler: ViewModifier {
    @StateObject private var deepLinkManager = DeepLinkManager.shared
    @State private var navigationPath = NavigationPath()
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                _ = deepLinkManager.handle(url: url)
            }
            .onChange(of: deepLinkManager.currentRoute) { route in
                handleRoute(route)
            }
    }
    
    private func handleRoute(_ route: DeepLinkRoute?) {
        guard let route = route else { return }
        
        // Navigate based on route
        switch route {
        case .dailyQode:
            navigationPath.append("daily")
        case .lifePath:
            navigationPath.append("lifepath")
        case .chart:
            navigationPath.append("chart")
        case .liveSession(let id):
            navigationPath.append("live/\(id)")
        default:
            break
        }
    }
}

extension View {
    func handleDeepLinks() -> some View {
        modifier(DeepLinkHandler())
    }
}
