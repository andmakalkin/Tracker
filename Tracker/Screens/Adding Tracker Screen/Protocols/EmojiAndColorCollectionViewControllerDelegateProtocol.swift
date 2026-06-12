import UIKit

protocol EmojiAndColorCollectionViewControllerDelegateProtocol: AnyObject {
    func didSelectEmoji(_ emoji: String)
    func didSelectColor(_ color: UIColor)
}
