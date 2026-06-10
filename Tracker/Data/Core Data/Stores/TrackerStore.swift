import CoreData
import Foundation

final class TrackerStore {
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let entityProvider: CoreDataEntityProvider
    private let mapper: CoreDataMapper
    
    // MARK: - Initialization
    init(
        context: NSManagedObjectContext,
        entityProvider: CoreDataEntityProvider? = nil,
        mapper: CoreDataMapper = CoreDataMapper()
    ) {
        self.context = context
        self.entityProvider = entityProvider ?? CoreDataEntityProvider(context: context)
        self.mapper = mapper
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let categoryEntity = try entityProvider.fetchCategory(
            with: category.categoryID
        )
        
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.trackerID = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSSet
        trackerEntity.category = categoryEntity
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerStore] addTracker: добавлен новый трекер:\n\(tracker.title)")
    }
    
    func updateTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
        let trackerEntity = try entityProvider.fetchTracker(with: tracker.id)
        let categoryEntity = try entityProvider.fetchCategory(
            with: category.categoryID
        )
        
        trackerEntity.title = tracker.title
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSSet
        trackerEntity.category = categoryEntity
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerStore] updateTracker: обновлён трекер:\n\(tracker.title)")
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let trackerEntity = try entityProvider.fetchTracker(with: tracker.id)
        
        context.delete(trackerEntity)
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerStore] deleteTracker: удалён трекер:\n\(tracker.title)")
    }
    
    func fetchTrackerCategory(for tracker: Tracker) throws -> TrackerCategory {
        let trackerEntity = try entityProvider.fetchTracker(with: tracker.id)
        
        guard let categoryEntity = trackerEntity.category else {
            throw CoreDataMapper.CoreDataMapperError.categoryMappingFailed
        }
        
        return try mapper.makeTrackerCategory(from: categoryEntity)
    }
}
