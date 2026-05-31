import UIKit
import CoreData

final class TrackerRecordStore {
    
    // MARK: - Types
    private enum TrackerRecordStoreError: Error {
        case trackerNotFound
        case trackerRecordNotFound
        case trackerRecordAlreadyExists
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Helpers
    private func fetchTracker(with trackerID: UUID) throws -> TrackerCoreData {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerID),
            trackerID as CVarArg
        )
        request.fetchLimit = 1
        
        guard let tracker = try context.fetch(request).first else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        return tracker
    }
    
    private func fetchTrackerRecord(
        for tracker: TrackerCoreData,
        on date: Date
    ) throws -> TrackerRecordCoreData {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.tracker),
            tracker,
            #keyPath(TrackerRecordCoreData.date),
            date as NSDate
        )
        request.fetchLimit = 1
        
        guard let trackerRecord = try context.fetch(request).first else {
            throw TrackerRecordStoreError.trackerRecordNotFound
        }
        
        return trackerRecord
    }
    
    private func trackerRecordExists(
        for tracker: TrackerCoreData,
        on date: Date
    ) throws -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.tracker),
            tracker,
            #keyPath(TrackerRecordCoreData.date),
            date as NSDate
        )
        request.fetchLimit = 1
        
        let count = try context.count(for: request)
        
        return count > 0
    }
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerEntity = try fetchTracker(with: trackerRecord.trackerID)
        guard try !trackerRecordExists(
            for: trackerEntity,
            on: trackerRecord.date
        ) else {
            throw TrackerRecordStoreError.trackerRecordAlreadyExists
        }
        
        let trackerRecordEntity = TrackerRecordCoreData(context: context)
        trackerRecordEntity.tracker = trackerEntity
        trackerRecordEntity.date = trackerRecord.date
        
        try context.saveContextIfNeeded()
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerEntity = try fetchTracker(with: trackerRecord.trackerID)
        let trackerRecordEntity = try fetchTrackerRecord(
            for: trackerEntity,
            on: trackerRecord.date
        )
        
        context.delete(trackerRecordEntity)
        try context.saveContextIfNeeded()
    }
}
