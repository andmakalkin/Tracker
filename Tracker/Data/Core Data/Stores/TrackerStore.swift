import UIKit
import CoreData

final class TrackerStore {
    
    // MARK: - Types
    private enum TrackerStoreError: Error {
        case categoryNotFound
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Helpers
    private func fetchCategory(with categoryID: UUID) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.categoryID),
            categoryID as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let category = try context.fetch(request).first else {
            throw TrackerStoreError.categoryNotFound
        }
        
        return category
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCategory = try fetchCategory(with: category.categoryID)
        
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.trackerID = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = tracker.color
        trackerEntity.schedule = tracker.schedule as NSObject
        trackerEntity.category = trackerCategory
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerStore] addTracker: добавлен новый трекер:\n\(tracker.title)")
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        // TODO: deleteTracker
    }
}
