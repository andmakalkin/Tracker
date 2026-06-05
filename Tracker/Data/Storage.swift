import Foundation
import CoreData

final class Storage {
    
    // MARK: - Dependencies
    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol
    private let recordStore: TrackerRecordStoreProtocol
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.trackerStore = TrackerStore(context: context)
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
    }
}

// MARK: - StorageProtocol
extension Storage: StorageProtocol {
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        try trackerStore.addTracker(tracker, to: category)
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let category: TrackerCategory
        
        if try categoryStore.categoryExists(with: title) {
            category = try categoryStore.fetchTrackerCategory(with: title)
        } else {
            let newCategory = TrackerCategory(
                title: title,
                trackers: []
            )
            
            try categoryStore.addTrackerCategory(newCategory)
            category = newCategory
        }
        
        try trackerStore.addTracker(tracker, to: category)
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(tracker)
    }
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        try categoryStore.addTrackerCategory(trackerCategory)
    }
    
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        try categoryStore.deleteTrackerCategory(trackerCategory)
    }
    
    func categoryExists(with title: String) throws -> Bool {
        try categoryStore.categoryExists(with: title)
    }
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try recordStore.addTrackerRecord(trackerRecord)
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try recordStore.deleteTrackerRecord(trackerRecord)
    }
}
