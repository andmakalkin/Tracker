import CoreData
import Foundation

final class TrackerRecordStore {
    
    // MARK: - Types
    private enum TrackerRecordStoreError: Error {
        case trackerRecordAlreadyExists
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let entityProvider: CoreDataEntityProvider
    
    // MARK: - Initialization
    init(
        context: NSManagedObjectContext,
        entityProvider: CoreDataEntityProvider? = nil
    ) {
        self.context = context
        self.entityProvider = entityProvider ?? CoreDataEntityProvider(context: context)
    }
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        guard try !trackerRecordExists(
            for: trackerRecord.trackerID,
            on: trackerRecord.date
        ) else {
            throw TrackerRecordStoreError.trackerRecordAlreadyExists
        }
        
        let trackerEntity = try entityProvider.fetchTracker(
            with: trackerRecord.trackerID
        )
        
        let trackerRecordEntity = TrackerRecordCoreData(context: context)
        trackerRecordEntity.tracker = trackerEntity
        trackerRecordEntity.date = trackerRecord.date
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerRecordStore] addTrackerRecord: добавлена отметка выполнения")
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordEntity = try entityProvider.fetchTrackerRecord(
            for: trackerRecord.trackerID,
            on: trackerRecord.date
        )
        
        context.delete(trackerRecordEntity)
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerRecordStore] deleteTrackerRecord: удалена отметка выполнения")
    }
}

// MARK: - Helpers
private extension TrackerRecordStore {
    
    func trackerRecordExists(
        for trackerID: UUID,
        on date: Date
    ) throws -> Bool {
        let tracker = try entityProvider.fetchTracker(with: trackerID)
        
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
