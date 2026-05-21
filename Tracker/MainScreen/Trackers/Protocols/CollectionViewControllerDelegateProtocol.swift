import Foundation

protocol CollectionViewControllerDelegateProtocol: AnyObject {
    func completeButtonDidTap(tracker: Tracker)
    func numberOfCompletedDays(for tracker: Tracker) -> Int
    func isTrackerCompletedOnSelectedDate(_ tracker: Tracker) -> Bool
}
