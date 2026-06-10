import CoreData
import Foundation

final class TrackerPinStore {
    
    // MARK: - Types
    private enum TrackerPinStoreError: Error {
        case trackerPinAlreadyExists
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

// MARK: - TrackerPinStoreProtocol
extension TrackerPinStore: TrackerPinStoreProtocol {
    
    func addTrackerPin(_ trackerPin: TrackerPin) throws {
        guard try !trackerPinExists(
            for: trackerPin.trackerID,
            on: trackerPin.date
        ) else {
            throw TrackerPinStoreError.trackerPinAlreadyExists
        }
        
        let trackerEntity = try entityProvider.fetchTracker(
            with: trackerPin.trackerID
        )
        
        let trackerPinEntity = TrackerPinCoreData(context: context)
        trackerPinEntity.tracker = trackerEntity
        trackerPinEntity.date = trackerPin.date
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerPinStore] addTrackerPin: добавлена отметка о закреплении")
    }
    
    func deleteTrackerPin(_ trackerPin: TrackerPin) throws {
        let trackerPinEntity = try entityProvider.fetchTrackerPin(
            for: trackerPin.trackerID,
            on: trackerPin.date
        )
        
        context.delete(trackerPinEntity)
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerPinStore] deleteTrackerPin: удалена отметка о закреплении")
    }
}

// MARK: - Helpers
private extension TrackerPinStore {
    
    func trackerPinExists(
        for trackerID: UUID,
        on date: Date
    ) throws -> Bool {
        let tracker = try entityProvider.fetchTracker(with: trackerID)
        
        let request = TrackerPinCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerPinCoreData.tracker),
            tracker,
            #keyPath(TrackerPinCoreData.date),
            date as NSDate
        )
        request.fetchLimit = 1
        
        let count = try context.count(for: request)
        
        return count > 0
    }
}
