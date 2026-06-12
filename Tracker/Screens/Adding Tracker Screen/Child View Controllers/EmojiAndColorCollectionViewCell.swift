import UIKit

final class EmojiAndColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Types
    private enum RenderMode {
        case normal
        case selected
    }
    
    // MARK: - Type Properties
    static let reuseIdentifier = "EmojiAndColorCollectionViewCell"
    
    // MARK: - UI Elements
    private lazy var button = UIButton(type: .custom)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.backgroundColor = .clear
        contentView.layer.borderColor = nil
        contentView.layer.borderWidth = 0
        
        button.setTitle(nil, for: .normal)
        button.backgroundColor = .clear
    }
    
    // MARK: - UI Setup
    private func setupView() {
        setupButton()
    }
    
    private func setupButton() {
        button.isUserInteractionEnabled = false
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(
                equalToConstant: 40
            ),
            button.heightAnchor.constraint(
                equalToConstant: 40
            ),
            button.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            button.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
        ])
    }
    
    // MARK: - Public Methods
    func configureForEmoji(
        _ emoji: String,
        isSelected: Bool
    ) {
        let state: RenderMode = isSelected ? .selected : .normal
        renderEmoji(for: state, emoji: emoji)
    }
    
    func configureForColor(
        _ color: UIColor,
        isSelected: Bool
    ) {
        let state: RenderMode = isSelected ? .selected : .normal
        renderColor(for: state, color: color)
    }
    
    // MARK: - Content State
    private func renderEmoji(for state: RenderMode, emoji: String) {
        button.setTitle(emoji, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        switch state {
        case .normal:
            contentView.backgroundColor = .clear
            
        case .selected:
            contentView.backgroundColor = UIColor(resource: .ypLightGray)
        }
    }
    
    private func renderColor(for state: RenderMode, color: UIColor) {
        button.backgroundColor = color
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        switch state {
        case .normal:
            contentView.layer.borderColor = nil
            contentView.layer.borderWidth = 0
            
        case .selected:
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            contentView.layer.borderWidth = 3
        }
    }
}
