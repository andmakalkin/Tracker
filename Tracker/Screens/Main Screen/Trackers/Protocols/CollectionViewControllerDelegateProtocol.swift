import Foundation

protocol CollectionViewControllerDelegateProtocol: AnyObject {
    func completeButtonDidTap(tracker: Tracker)
    func didTapPin(tracker: Tracker)
    func didTapEdit(tracker: Tracker)
    func didTapDelete(tracker: Tracker)
    func completedDaysText(for tracker: Tracker) -> String
    func isTrackerCompletedOnSelectedDate(_ tracker: Tracker) -> Bool
    func isTrackerPinnedOnSelectedDate(_ tracker: Tracker) -> Bool
}
