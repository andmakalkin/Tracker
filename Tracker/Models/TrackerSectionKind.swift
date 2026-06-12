import Foundation

enum TrackerSectionKind: Equatable {
    case pinned
    case category(id: UUID)
}
