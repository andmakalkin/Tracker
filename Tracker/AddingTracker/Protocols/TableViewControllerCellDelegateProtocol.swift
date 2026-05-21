import Foundation

protocol TableViewControllerCellDelegateProtocol: AnyObject {
    func didChangeSwitcherValue(at cell: TableViewControllerCell, newValue: Bool)
}
