import Foundation

protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
}
