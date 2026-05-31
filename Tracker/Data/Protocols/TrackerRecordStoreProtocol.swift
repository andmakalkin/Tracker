import Foundation

protocol TrackerRecordStoreProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws
}
