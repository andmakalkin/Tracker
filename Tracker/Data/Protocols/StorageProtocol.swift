import Foundation

protocol StorageProtocol {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws
    func deleteTracker(_ tracker: Tracker) throws
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func categoryExists(with title: String) throws -> Bool
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws
}
