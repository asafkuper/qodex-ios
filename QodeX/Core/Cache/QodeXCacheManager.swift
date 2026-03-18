//
//  QodeXCacheManager.swift
//  Local data persistence for offline mode
//

import CoreData
import Foundation

class QodeXCacheManager {
    static let shared = QodeXCacheManager()
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "QodeXCache")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ CoreData failed to load: \(error)")
            }
        }
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Cache Daily Readings
    func cacheDailyReadings(_ readings: [DailyReading], for userId: String) {
        for reading in readings {
            let entity = DailyReadingEntity(context: context)
            entity.id = reading.id
            entity.userId = userId
            entity.date = reading.date
            entity.number = Int32(reading.number)
            entity.vibe = reading.vibe
            entity.fullReading = reading.fullReading
            entity.cachedAt = Date()
        }
        
        saveContext()
        print("✅ Cached \(readings.count) daily readings")
    }
    
    func getCachedDailyReading(for date: Date, userId: String) -> DailyReading? {
        let request: NSFetchRequest<DailyReadingEntity> = DailyReadingEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "userId == %@ AND date == %@",
            userId, date as CVarArg
        )
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first else { return nil }
            
            // Check if cache is fresh (less than 7 days old)
            if let cachedAt = entity.cachedAt,
               Date().timeIntervalSince(cachedAt) < 7 * 24 * 60 * 60 {
                return DailyReading(
                    id: entity.id ?? UUID().uuidString,
                    date: entity.date ?? Date(),
                    number: Int(entity.number),
                    vibe: entity.vibe ?? "",
                    fullReading: entity.fullReading ?? ""
                )
            }
            
            // Stale cache, delete it
            context.delete(entity)
            saveContext()
            return nil
            
        } catch {
            print("❌ Failed to fetch cached reading: \(error)")
            return nil
        }
    }
    
    // MARK: - Cache User Profile
    func cacheUserProfile(_ user: QodeXUser) {
        let entity = UserProfileEntity(context: context)
        entity.id = user.id
        entity.email = user.email
        entity.fullName = user.fullName
        entity.membershipTier = user.membershipTier.rawValue
        entity.cachedAt = Date()
        
        saveContext()
    }
    
    func getCachedUserProfile(userId: String) -> QodeXUser? {
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first else { return nil }
            
            return QodeXUser(
                id: entity.id ?? "",
                email: entity.email ?? "",
                fullName: entity.fullName ?? "",
                membershipTier: MembershipTier(rawValue: entity.membershipTier ?? "free") ?? .free
            )
        } catch {
            return nil
        }
    }
    
    // MARK: - Pre-fetch Strategy
    func prefetchUpcomingReadings(for user: QodeXUser) async {
        let calculator = NumerologyCalculator()
        let upcomingReadings: [DailyReading] = (0..<7).compactMap { dayOffset in
            guard let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) else { return nil }
            
            // Skip if already cached
            if getCachedDailyReading(for: date, userId: user.id) != nil {
                return nil
            }
            
            let number = calculator.calculateDailyNumber(for: date)
            return DailyReading(
                id: "\(user.id)_\(date.timeIntervalSince1970)",
                date: date,
                number: number,
                vibe: getVibe(for: number),
                fullReading: generateFullReading(for: number, user: user)
            )
        }
        
        cacheDailyReadings(upcomingReadings, for: user.id)
    }
    
    // MARK: - Clear Cache
    func clearAllCache() {
        let entities = ["DailyReadingEntity", "UserProfileEntity"]
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try container.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch {
                print("❌ Failed to clear cache: \(error)")
            }
        }
    }
    
    // MARK: - Private Helpers
    private func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
    
    private func getVibe(for number: Int) -> String {
        let vibes = ["", "New Beginnings", "Partnership", "Creativity", "Foundation", "Freedom", "Harmony", "Wisdom", "Abundance", "Completion"]
        return vibes[number] ?? "Spiritual Growth"
    }
    
    private func generateFullReading(for number: Int, user: QodeXUser) -> String {
        // In real app, this would be personalized content
        return "Today's energy of \(number) brings unique opportunities for growth."
    }
}

// MARK: - Models
struct DailyReading: Codable {
    let id: String
    let date: Date
    let number: Int
    let vibe: String
    let fullReading: String
}

// MARK: - CoreData Entities (would be in .xcdatamodeld file)
// These are represented as classes that CoreData would generate
@objc(DailyReadingEntity)
public class DailyReadingEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var date: Date?
    @NSManaged public var number: Int32
    @NSManaged public var vibe: String?
    @NSManaged public var fullReading: String?
    @NSManaged public var cachedAt: Date?
}

@objc(UserProfileEntity)
public class UserProfileEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var membershipTier: String?
    @NSManaged public var cachedAt: Date?
}
