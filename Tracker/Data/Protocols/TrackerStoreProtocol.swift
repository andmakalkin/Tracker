import Foundation

protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, in category: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
    func fetchTrackerCategory(for tracker: Tracker) throws -> TrackerCategory
}
