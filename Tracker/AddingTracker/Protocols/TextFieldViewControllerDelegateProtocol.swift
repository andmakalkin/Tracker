import Foundation

protocol TextFieldViewControllerDelegateProtocol: AnyObject {
    func didFinishInputEditing(_ text: String)
}
