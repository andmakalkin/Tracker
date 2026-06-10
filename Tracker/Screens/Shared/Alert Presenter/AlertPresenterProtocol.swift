import UIKit

protocol AlertPresenterProtocol {
    func show(in viewController: UIViewController, model: AlertModel)
}
