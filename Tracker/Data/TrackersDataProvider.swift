import CoreData
import Foundation

final class TrackersDataProvider: NSObject, TrackersDataProviderProtocol {
    
    // MARK: - Delegate
    weak var delegate: TrackersDataProviderDelegateProtocol?
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let mapper: CoreDataMapper
    
    // MARK: - Data
    private(set) var categories = [TrackerCategory]()
    private(set) var completedTrackers = [TrackerRecord]()
    private(set) var pinnedTrackers = [TrackerPin]()
    
    private lazy var trackerCategoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: #keyPath(TrackerCategoryCoreData.title),
                ascending: true
            ),
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
    
    private lazy var trackerFetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: #keyPath(TrackerCoreData.title),
                ascending: true
            ),
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
            ),
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
    
    private lazy var trackerPinFetchedResultsController: NSFetchedResultsController<TrackerPinCoreData> = {
        let fetchRequest = TrackerPinCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: #keyPath(TrackerPinCoreData.date),
                ascending: true
            ),
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
    init(
        context: NSManagedObjectContext = CoreDataStack.shared.context,
        mapper: CoreDataMapper = CoreDataMapper()
    ) {
        self.context = context
        self.mapper = mapper
        
        super.init()
        
        performFetch()
    }
    
    // MARK: - Data Updates
    private func performFetch() {
        do {
            try trackerCategoryFetchedResultsController.performFetch()
            try trackerFetchedResultsController.performFetch()
            try trackerRecordFetchedResultsController.performFetch()
            try trackerPinFetchedResultsController.performFetch()
            try updateCategories()
            try updateCompletedTrackers()
            try updatePinnedTrackers()
        } catch {
            assertionFailure(
                "❌ [TrackersDataProvider] performFetch: "
                + "не удалось загрузить данные: \(error)"
            )
        }
    }
    
    private func updateCategories() throws {
        let categoryEntities = trackerCategoryFetchedResultsController.fetchedObjects ?? []
        
        categories = try categoryEntities.map {
            try mapper.makeTrackerCategory(from: $0)
        }
    }
    
    private func updateCompletedTrackers() throws {
        let trackerRecordEntities = trackerRecordFetchedResultsController.fetchedObjects ?? []
        
        completedTrackers = try trackerRecordEntities.map {
            try mapper.makeTrackerRecord(from: $0)
        }
    }
    
    private func updatePinnedTrackers() throws {
        let trackerPinEntities = trackerPinFetchedResultsController.fetchedObjects ?? []
        
        pinnedTrackers = try trackerPinEntities.map {
            try mapper.makeTrackerPin(from: $0)
        }
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
            
            if controller === trackerFetchedResultsController {
                try updateCategories()
                delegate?.categoriesDidUpdate()
            }
            
            if controller === trackerRecordFetchedResultsController {
                try updateCompletedTrackers()
                delegate?.completedTrackersDidUpdate()
            }
            
            if controller === trackerPinFetchedResultsController {
                try updatePinnedTrackers()
                delegate?.pinnedTrackersDidUpdate()
            }
        } catch {
            print("❌ [TrackersDataProvider] controllerDidChangeContent: \(error)")
        }
    }
}
