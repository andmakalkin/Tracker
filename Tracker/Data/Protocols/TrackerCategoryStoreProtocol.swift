import Foundation

protocol TrackerCategoryStoreProtocol {
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws
    func updateTrackerCategory(_ trackerCategory: TrackerCategory, newTitle: String) throws
    func fetchTrackerCategory(with id: UUID) throws -> TrackerCategory
    func categoryExists(with title: String, excluding category: TrackerCategory?) throws -> Bool
}

