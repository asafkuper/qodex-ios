//
//  iCloudSyncManager.swift
//  Cross-device data synchronization
//

import Foundation
import CloudKit

class iCloudSyncManager {
    static let shared = iCloudSyncManager()
    private let container: CKContainer
    private let database: CKDatabase
    
    private init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    // MARK: - Sync User Data
    func syncUserData(_ user: QodeXUser) async throws {
        let record = createRecord(from: user)
        
        do {
            let savedRecord = try await database.save(record)
            print("✅ Synced user data to iCloud: \(savedRecord.recordID)")
        } catch {
            print("❌ Failed to sync: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch from iCloud
    func fetchUserData(userId: String) async throws -> QodeXUser? {
        let recordID = CKRecord.ID(recordName: "user-\(userId)")
        
        do {
            let record = try await database.record(for: recordID)
            return createUser(from: record)
        } catch {
            print("❌ Failed to fetch: \(error)")
            return nil
        }
    }
    
    // MARK: - Sync Calculations
    func syncCalculation(_ calculation: NumerologyCalculation) async throws {
        let record = CKRecord(recordType: "Calculation")
        record["userId"] = calculation.userId
        record["type"] = calculation.type
        record["result"] = calculation.result
        record["date"] = calculation.date
        record["inputData"] = calculation.inputData
        
        _ = try await database.save(record)
    }
    
    func fetchCalculations(for userId: String) async throws -> [NumerologyCalculation] {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: "Calculation", predicate: predicate)
        
        let (results, _) = try await database.records(matching: query)
        
        return results.compactMap { _, result in
            guard case .success(let record) = result else { return nil }
            return self.createCalculation(from: record)
        }
    }
    
    // MARK: - Sync Settings
    func syncSettings(_ settings: UserSettings) async throws {
        let record = createRecord(from: settings)
        _ = try await database.save(record)
    }
    
    // MARK: - Conflict Resolution
    func resolveConflicts(local: QodeXUser, remote: QodeXUser) -> QodeXUser {
        // Use the most recent update
        if let localDate = local.lastModifiedAt,
           let remoteDate = remote.lastModifiedAt {
            return localDate > remoteDate ? local : remote
        }
        return remote // Default to remote if no timestamps
    }
    
    // MARK: - Private Helpers
    private func createRecord(from user: QodeXUser) -> CKRecord {
        let recordID = CKRecord.ID(recordName: "user-\(user.id)")
        let record = CKRecord(recordType: "User", recordID: recordID)
        
        record["fullName"] = user.fullName
        record["email"] = user.email
        record["membershipTier"] = user.membershipTier.rawValue
        record["blueprintCompletion"] = user.blueprintCompletion
        
        if let birthDate = user.birthDate {
            record["birthDate"] = birthDate
        }
        
        record["lastModified"] = Date()
        
        return record
    }
    
    private func createUser(from record: CKRecord) -> QodeXUser? {
        guard let fullName = record["fullName"] as? String,
              let email = record["email"] as? String else {
            return nil
        }
        
        return QodeXUser(
            id: record.recordID.recordName.replacingOccurrences(of: "user-", with: ""),
            email: email,
            fullName: fullName,
            birthDate: record["birthDate"] as? Date,
            membershipTier: MembershipTier(rawValue: record["membershipTier"] as? String ?? "free") ?? .free,
            blueprintCompletion: record["blueprintCompletion"] as? Double ?? 0
        )
    }
    
    private func createCalculation(from record: CKRecord) -> NumerologyCalculation? {
        guard let userId = record["userId"] as? String,
              let type = record["type"] as? String,
              let result = record["result"] as? Int,
              let date = record["date"] as? Date else {
            return nil
        }
        
        return NumerologyCalculation(
            id: record.recordID.recordName,
            userId: userId,
            type: type,
            result: result,
            date: date,
            inputData: record["inputData"] as? String ?? ""
        )
    }
    
    private func createRecord(from settings: UserSettings) -> CKRecord {
        let record = CKRecord(recordType: "Settings")
        record["userId"] = settings.userId
        record["notificationsEnabled"] = settings.notificationsEnabled
        record["theme"] = settings.theme.rawValue
        return record
    }
    
    // MARK: - Subscription (Real-time Sync)
    func subscribeToChanges(userId: String) async throws {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let subscription = CKQuerySubscription(
            recordType: "User",
            predicate: predicate,
            subscriptionID: "user-changes-\(userId)",
            options: [.firesOnRecordUpdate, .firesOnRecordCreate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        _ = try await database.save(subscription)
    }
}

// MARK: - Supporting Types
struct NumerologyCalculation: Identifiable {
    let id: String
    let userId: String
    let type: String
    let result: Int
    let date: Date
    let inputData: String
}

struct UserSettings {
    let userId: String
    var notificationsEnabled: Bool
    var theme: AppTheme
    
    enum AppTheme: String {
        case light
        case dark
        case auto
    }
}
