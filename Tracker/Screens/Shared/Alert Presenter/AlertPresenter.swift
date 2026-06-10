import UIKit

// MARK: - AlertPresenter
final class AlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Public Methods
    func show(
        in viewController: UIViewController,
        model: AlertModel
    ) {
        DispatchQueue.main.async {
            self.presentAlert(in: viewController, model: model)
        }
    }
    
    // MARK: - Helpers
    private func presentAlert(
        in viewController: UIViewController,
        model: AlertModel
    ) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .actionSheet
        )
        
        let destructiveAction = UIAlertAction(
            title: model.destructiveButtonText,
            style: .destructive
        ) { _ in
            model.destructiveCompletion()
        }
        
        let cancelAction = UIAlertAction(
            title: model.cancelButtonText,
            style: .cancel
        ) { _ in
            model.cancelCompletion?()
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true)
    }
}
