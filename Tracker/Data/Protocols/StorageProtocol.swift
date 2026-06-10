import Foundation

protocol StorageProtocol {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, in category: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func updateTrackerCategory(_ trackerCategory: TrackerCategory, newTitle: String) throws
    func fetchTrackerCategory(with id: UUID) throws -> TrackerCategory
    func fetchTrackerCategory(for tracker: Tracker) throws -> TrackerCategory
    func categoryExists(with title: String, excluding category: TrackerCategory?) throws -> Bool
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws
    
    func addTrackerPin(_ trackerPin: TrackerPin) throws
    func deleteTrackerPin(_ trackerPin: TrackerPin) throws
}
