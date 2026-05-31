import UIKit
import CoreData

final class TrackersDataProvider: NSObject, TrackersDataProviderProtocol {
    
    // MARK: - Types
    private enum TrackersDataProviderError: Error {
        case trackerCategoryMappingFailed
        case trackerMappingFailed
        case trackerRecordMappingFailed
    }
    
    // MARK: - Delegate
    weak var delegate: TrackersDataProviderDelegateProtocol?
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    
    // MARK: - Data
    private(set) var categories = [TrackerCategory]()
    private(set) var completedTrackers = [TrackerRecord]()
    
    // MARK: - State
    private lazy var trackerCategoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: #keyPath(TrackerCategoryCoreData.title),
                ascending: true
            )
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private lazy var trackerRecordFetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: #keyPath(TrackerRecordCoreData.date),
                ascending: true
            )
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) throws {
        self.context = context
        
        super.init()
        
        try performFetch()
    }
    
    // MARK: - Data Updates
    private func performFetch() throws {
        try trackerCategoryFetchedResultsController.performFetch()
        try trackerRecordFetchedResultsController.performFetch()
        try updateCategories()
        try updateCompletedTrackers()
    }
    
    private func updateCategories() throws {
        let categoriesEntity = trackerCategoryFetchedResultsController.fetchedObjects ?? []
        
        categories = try categoriesEntity.map {
            try makeTrackerCategory(from: $0)
        }
    }
    
    private func updateCompletedTrackers() throws {
        let recordEntities = trackerRecordFetchedResultsController.fetchedObjects ?? []
        
        completedTrackers = try recordEntities.map {
            try makeTrackerRecord(from: $0)
        }
    }
    
    // MARK: - Helpers
    private func makeTracker(from entity: TrackerCoreData) throws -> Tracker {
        guard
            let id = entity.trackerID,
            let title = entity.title,
            let emoji = entity.emoji,
            let color = entity.color as? UIColor,
            let schedule = entity.schedule as? Set<Weekday>
        else {
            throw TrackersDataProviderError.trackerMappingFailed
        }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    private func makeTrackerCategory(from entity: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard
            let categoryID = entity.categoryID,
            let title = entity.title
        else {
            throw TrackersDataProviderError.trackerCategoryMappingFailed
        }
        
        let trackerEntities = entity.trackers as? Set<TrackerCoreData> ?? []
        let trackers = try trackerEntities
            .sorted {
                ($0.title ?? "") < ($1.title ?? "")
            }
            .map {
                try makeTracker(from: $0)
            }
        
        return TrackerCategory(
            categoryID: categoryID,
            title: title,
            trackers: trackers
        )
    }
    
    private func makeTrackerRecord(from entity: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let date = entity.date,
            let trackerID = entity.tracker?.trackerID
        else {
            throw TrackersDataProviderError.trackerRecordMappingFailed
        }
        
        return TrackerRecord(
            trackerID: trackerID,
            date: date
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        do {
            if controller === trackerCategoryFetchedResultsController {
                try updateCategories()
                delegate?.categoriesDidUpdate()
            }
            
            if controller === trackerRecordFetchedResultsController {
                try updateCompletedTrackers()
                delegate?.completedTrackersDidUpdate()
            }
        } catch {
            print("❌ [TrackersDataProvider] controllerDidChangeContent: \(error)")
        }
    }
}
