import Foundation

struct TrackerCategory: Equatable {
    let categoryID: UUID
    let title: String
    let trackers: [Tracker]
    
    init(
        categoryID: UUID = UUID(),
        title: String,
        trackers: [Tracker]
    ) {
        self.categoryID = categoryID
        self.title = title
        self.trackers = trackers
    }
}
