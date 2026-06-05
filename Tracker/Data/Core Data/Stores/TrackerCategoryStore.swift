import UIKit
import CoreData

final class TrackerCategoryStore {
    
    // MARK: - Types
    private enum TrackerCategoryStoreError: Error {
        case categoryAlreadyExists
        case categoryNotFound
        case categoryMappingFailed
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func categoryExists(with title: String) throws -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        request.fetchLimit = 1
        
        let count = try context.count(for: request)
        
        return count > 0
    }

    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        guard try !categoryExists(with: trackerCategory.title) else {
            throw TrackerCategoryStoreError.categoryAlreadyExists
        }
        
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.categoryID = trackerCategory.categoryID
        categoryEntity.title = trackerCategory.title
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerCategoryStore] addTrackerCategory: добавлена новая категория:\n\(trackerCategory.title)")
    }
    
    func fetchTrackerCategory(with title: String) throws -> TrackerCategory {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        request.fetchLimit = 1
        
        guard let categoryEntity = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }
        
        guard
            let categoryID = categoryEntity.categoryID,
            let title = categoryEntity.title
        else {
            throw TrackerCategoryStoreError.categoryMappingFailed
        }
        
        let trackerEntities = categoryEntity.trackers as? Set<TrackerCoreData> ?? []
        let trackers = trackerEntities.compactMap { trackerEntity -> Tracker? in
            guard
                let trackerID = trackerEntity.trackerID,
                let title = trackerEntity.title,
                let emoji = trackerEntity.emoji,
                let color = trackerEntity.color as? UIColor,
                let schedule = trackerEntity.schedule as? Set<Weekday>
            else {
                return nil
            }
            
            return Tracker(
                id: trackerID,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule
            )
        }
        
        return TrackerCategory(
            categoryID: categoryID,
            title: title,
            trackers: trackers
        )
    }
    
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        // TODO: deleteTrackerCategory
    }
}
