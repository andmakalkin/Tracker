import Foundation

protocol TrackerCategoryStoreProtocol {
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func fetchTrackerCategory(with title: String) throws -> TrackerCategory
    func categoryExists(with title: String) throws -> Bool
}

