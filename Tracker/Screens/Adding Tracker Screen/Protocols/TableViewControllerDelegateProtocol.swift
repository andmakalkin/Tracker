import Foundation

protocol TableViewControllerDelegateProtocol: AnyObject {
    func didSelectRowAt(_ index: Int, title: String)
    func didChangeSwitcherValueAt(row: Int, newValue: Bool)
    func didTapEdit(at index: Int)
    func didTapDelete(at index: Int)
}
