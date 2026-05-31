import Foundation

protocol AddingScheduleViewControllerDelegateProtocol: AnyObject {
    func didFinishSelectingSchedule(_ schedule: Set<Weekday>)
}
