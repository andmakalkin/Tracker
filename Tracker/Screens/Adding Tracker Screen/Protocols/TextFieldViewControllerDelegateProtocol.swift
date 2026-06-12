import Foundation

protocol TextFieldViewControllerDelegateProtocol: AnyObject {
    func didChangeInputText(_ text: String)
    func didFinishInputEditing(_ text: String)
}
