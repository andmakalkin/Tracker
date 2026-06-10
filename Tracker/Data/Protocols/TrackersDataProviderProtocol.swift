import Foundation

protocol TrackersDataProviderProtocol {
    var delegate: TrackersDataProviderDelegateProtocol? { get set }
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
    var pinnedTrackers: [TrackerPin] { get }
}
