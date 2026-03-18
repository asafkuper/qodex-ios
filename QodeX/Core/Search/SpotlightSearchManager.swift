//
//  SpotlightSearchManager.swift
//  CoreSpotlight integration for system-wide search
//

import Foundation
import CoreSpotlight
import MobileCoreServices

class SpotlightSearchManager {
    static let shared = SpotlightSearchManager()
    private let searchableIndex = CSSearchableIndex.default()
    
    // MARK: - Index User Content
    func indexUserNumerology(user: QodeXUser) async {
        guard let birthDate = user.birthDate else { return }
        
        let lifePath = NumerologyCalculator().calculateLifePathNumber(birthDate: birthDate)
        let items = createSearchableItems(for: user, lifePath: lifePath)
        
        do {
            try await searchableIndex.indexSearchableItems(items)
            print("✅ Indexed \(items.count) items to Spotlight")
        } catch {
            print("❌ Failed to index: \(error)")
        }
    }
    
    private func createSearchableItems(for user: QodeXUser, lifePath: Int) -> [CSSearchableItem] {
        var items: [CSSearchableItem] = []
        
        // Life Path item
        let lifePathAttributeSet = CSSearchableItemAttributeSet(contentType: .data)
        lifePathAttributeSet.title = "Your Life Path Number: \(lifePath)"
        lifePathAttributeSet.contentDescription = getLifePathDescription(lifePath)
        lifePathAttributeSet.keywords = ["numerology", "life path", "destiny", "birth chart"]
        lifePathAttributeSet.thumbnailData = generateNumberThumbnail(number: lifePath)
        
        let lifePathItem = CSSearchableItem(
            uniqueIdentifier: "lifepath-\(user.id)",
            domainIdentifier: "com.qodex.numerology",
            attributeSet: lifePathAttributeSet
        )
        items.append(lifePathItem)
        
        // Daily number history (last 7 days)
        let calculator = NumerologyCalculator()
        for dayOffset in 0..<7 {
            guard let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dailyNumber = calculator.calculateDailyNumber(for: date)
            let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            
            let attributeSet = CSSearchableItemAttributeSet(contentType: .data)
            attributeSet.title = "Daily Number \(dailyNumber) - \(dateString)"
            attributeSet.contentDescription = "Your numerology energy for \(dateString) was \(dailyNumber)"
            attributeSet.keywords = ["daily", "number", "energy", "forecast"]
            attributeSet.contentCreationDate = date
            
            let item = CSSearchableItem(
                uniqueIdentifier: "daily-\(user.id)-\(date.timeIntervalSince1970)",
                domainIdentifier: "com.qodex.daily",
                attributeSet: attributeSet
            )
            items.append(item)
        }
        
        // Teachings based on Life Path
        let teachings = getRelevantTeachings(lifePath: lifePath)
        for teaching in teachings {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            attributeSet.title = teaching.title
            attributeSet.contentDescription = teaching.description
            attributeSet.keywords = ["teaching", "lesson", "numerology", "growth"]
            
            let item = CSSearchableItem(
                uniqueIdentifier: "teaching-\(teaching.id)",
                domainIdentifier: "com.qodex.teachings",
                attributeSet: attributeSet
            )
            items.append(item)
        }
        
        return items
    }
    
    // MARK: - Handle Search Selection
    func handleSpotlightSelection(identifier: String) -> DeepLinkRoute? {
        if identifier.hasPrefix("lifepath-") {
            return .lifePath(userId: nil)
        } else if identifier.hasPrefix("daily-") {
            let components = identifier.split(separator: "-")
            if components.count >= 3 {
                return .dailyQode(date: nil)
            }
        } else if identifier.hasPrefix("teaching-") {
            return nil // Would navigate to specific teaching
        }
        return nil
    }
    
    // MARK: - Delete Index
    func deleteIndex() async {
        do {
            try await searchableIndex.deleteAllSearchableItems()
            print("✅ Deleted all Spotlight indexes")
        } catch {
            print("❌ Failed to delete index: \(error)")
        }
    }
    
    func deleteIndex(forUser userId: String) async {
        do {
            try await searchableIndex.deleteSearchableItems(withDomainIdentifiers: [
                "com.qodex.numerology",
                "com.qodex.daily",
                "com.qodex.teachings"
            ])
        } catch {
            print("❌ Failed to delete user index: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    private func getLifePathDescription(_ number: Int) -> String {
        let descriptions: [Int: String] = [
            1: "The Leader - Independent, ambitious, and innovative",
            2: "The Diplomat - Cooperative, intuitive, and sensitive",
            3: "The Creative - Expressive, optimistic, and social",
            4: "The Builder - Practical, disciplined, and hardworking",
            5: "The Freedom Seeker - Adventurous, adaptable, and curious",
            6: "The Nurturer - Responsible, compassionate, and loving",
            7: "The Seeker - Analytical, spiritual, and introspective",
            8: "The Powerhouse - Ambitious, authoritative, and successful",
            9: "The Humanitarian - Compassionate, wise, and selfless"
        ]
        return descriptions[number] ?? "Your unique path"
    }
    
    private func generateNumberThumbnail(number: Int) -> Data? {
        // Generate a simple image with the number
        let size = CGSize(width: 120, height: 120)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(hex: "12121A")!.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        let text = "\(number)" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 60, weight: .bold),
            .foregroundColor: UIColor(hex: "E5C158")!
        ]
        let textSize = text.size(withAttributes: attributes)
        text.draw(at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2), withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()?.pngData()
    }
    
    private func getRelevantTeachings(lifePath: Int) -> [TeachingSnippet] {
        // Return relevant teachings based on life path
        return [
            TeachingSnippet(id: "1", title: "Understanding Life Path \(lifePath)", description: "Deep dive into your core number"),
            TeachingSnippet(id: "2", title: "Mastering Your Energy", description: "How to align with your numerology")
        ]
    }
}

struct TeachingSnippet {
    let id: String
    let title: String
    let description: String
}

// MARK: - Intent Donations
class IntentDonationManager {
    static let shared = IntentDonationManager()
    
    func donateViewDailyNumberIntent() {
        let intent = QodeXDailyNumberIntent()
        intent.suggestedInvocationPhrase = "What's my number today?"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("❌ Failed to donate intent: \(error)")
            } else {
                print("✅ Donated intent")
            }
        }
    }
    
    func donateViewChartIntent() {
        // Donate view chart intent
    }
}

import Intents

class QodeXDailyNumberIntent: INIntent {
    override init() {
        super.init()
        self.suggestedInvocationPhrase = "What's my number today?"
    }
}
