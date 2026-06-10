import Foundation

struct AlertModel {
    let title: String
    let message: String?
    let destructiveButtonText: String
    let cancelButtonText: String
    let destructiveCompletion: () -> Void
    let cancelCompletion: (() -> Void)?
}
