import CoreData

final class Storage {
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let entityProvider: CoreDataEntityProvider
    private let mapper: CoreDataMapper
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let trackerPinStore: TrackerPinStoreProtocol
    
    // MARK: - Initialization
    convenience init() {
        self.init(context: CoreDataStack.shared.context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let entityProvider = CoreDataEntityProvider(context: context)
        let mapper = CoreDataMapper()
        
        self.entityProvider = entityProvider
        self.mapper = mapper
        
        trackerStore = TrackerStore(
            context: context,
            entityProvider: entityProvider,
            mapper: mapper
        )
        
        trackerCategoryStore = TrackerCategoryStore(
            context: context,
            entityProvider: entityProvider,
            mapper: mapper
        )
        
        trackerRecordStore = TrackerRecordStore(
            context: context,
            entityProvider: entityProvider
        )
        
        trackerPinStore = TrackerPinStore(
            context: context,
            entityProvider: entityProvider
        )
    }
}

// MARK: - StorageProtocol
extension Storage: StorageProtocol {
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        try trackerStore.addTracker(tracker, to: category)
    }
    
    func updateTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
        try trackerStore.updateTracker(tracker, in: category)
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(tracker)
    }
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        try trackerCategoryStore.addTrackerCategory(trackerCategory)
    }
    
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        try trackerCategoryStore.deleteTrackerCategory(trackerCategory)
    }
    
    func updateTrackerCategory(
        _ trackerCategory: TrackerCategory,
        newTitle: String
    ) throws {
        try trackerCategoryStore.updateTrackerCategory(
            trackerCategory,
            newTitle: newTitle
        )
    }
    
    func fetchTrackerCategory(with id: UUID) throws -> TrackerCategory {
        try trackerCategoryStore.fetchTrackerCategory(with: id)
    }
    
    func fetchTrackerCategory(for tracker: Tracker) throws -> TrackerCategory {
        try trackerStore.fetchTrackerCategory(for: tracker)
    }
    
    func categoryExists(
        with title: String,
        excluding category: TrackerCategory?
    ) throws -> Bool {
        try trackerCategoryStore.categoryExists(
            with: title,
            excluding: category
        )
    }
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.addTrackerRecord(trackerRecord)
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.deleteTrackerRecord(trackerRecord)
    }
    
    func addTrackerPin(_ trackerPin: TrackerPin) throws {
        try trackerPinStore.addTrackerPin(trackerPin)
    }
    
    func deleteTrackerPin(_ trackerPin: TrackerPin) throws {
        try trackerPinStore.deleteTrackerPin(trackerPin)
    }
}
