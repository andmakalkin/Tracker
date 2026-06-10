import CoreData
import Foundation

final class CoreDataEntityProvider {
    
    // MARK: - Types
    enum CoreDataEntityProviderError: Error {
        case categoryNotFound
        case trackerNotFound
        case trackerRecordNotFound
        case trackerPinNotFound
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func fetchCategory(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.categoryID),
            id as CVarArg
        )
        request.fetchLimit = 1
        
        guard let category = try context.fetch(request).first else {
            throw CoreDataEntityProviderError.categoryNotFound
        }
        
        return category
    }
    
    func fetchTracker(with id: UUID) throws -> TrackerCoreData {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerID),
            id as CVarArg
        )
        request.fetchLimit = 1
        
        guard let tracker = try context.fetch(request).first else {
            throw CoreDataEntityProviderError.trackerNotFound
        }
        
        return tracker
    }
    
    func fetchTrackerRecord(
        for trackerID: UUID,
        on date: Date
    ) throws -> TrackerRecordCoreData {
        let tracker = try fetchTracker(with: trackerID)
        
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
            throw CoreDataEntityProviderError.trackerRecordNotFound
        }
        
        return trackerRecord
    }
    
    func fetchTrackerPin(
        for trackerID: UUID,
        on date: Date
    ) throws -> TrackerPinCoreData {
        let tracker = try fetchTracker(with: trackerID)
        
        let request = TrackerPinCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerPinCoreData.tracker),
            tracker,
            #keyPath(TrackerPinCoreData.date),
            date as NSDate
        )
        request.fetchLimit = 1
        
        guard let trackerPin = try context.fetch(request).first else {
            throw CoreDataEntityProviderError.trackerPinNotFound
        }
        
        return trackerPin
    }
}
