import Foundation

protocol TableViewControllerDelegateProtocol: AnyObject {
    func didSelectRowWith(title: String)
    func didChangeSwitcherValueAt(raw: Int, newValue: Bool)
}
