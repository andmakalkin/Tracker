import Foundation

protocol TrackersDataProviderDelegateProtocol: AnyObject {
    func categoriesDidUpdate()
    func completedTrackersDidUpdate()
    func pinnedTrackersDidUpdate()
}
