import Foundation

protocol TrackerPinStoreProtocol {
    func addTrackerPin(_ trackerPin: TrackerPin) throws
    func deleteTrackerPin(_ trackerPin: TrackerPin) throws
}
