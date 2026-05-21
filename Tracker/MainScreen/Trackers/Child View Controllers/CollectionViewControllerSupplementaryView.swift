import UIKit

final class CollectionViewControllerSupplementaryView: UICollectionReusableView {
    
    // MARK: - Type Properties
    static let reuseIdentifier = "TrackersCollectionViewSupplementaryViewHeader"
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTitleLabel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - UI Setup
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .ypBlack
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor
            )
        ])
    }
    
    // MARK: - Public Methods
    func configure(title: String) {
        titleLabel.text = title
    }
}
