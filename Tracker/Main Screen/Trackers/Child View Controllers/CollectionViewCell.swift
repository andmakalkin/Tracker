import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    // MARK: - Types
    private enum CellState {
        case completed
        case uncompleted
    }
    
    // MARK: - Type Properties
    static let reuseIdentifier = "TrackersCollectionViewCell"
    
    // MARK: - Delegate
    weak var delegate: CollectionViewCellDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var cardView = UIView()
    private lazy var cardStackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var emojiLabel = UILabel()
    
    private lazy var quantityManagementView = UIView()
    private lazy var quantityManagementStackView = UIStackView()
    private lazy var counterLabel = UILabel()
    private lazy var completeButton = UIButton(type: .custom)
    
    // MARK: - State
    private var color: UIColor? {
        didSet {
            cardView.backgroundColor = color
            completeButton.tintColor = color
        }
    }
    
    private var cellState: CellState = .uncompleted
    
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
        
        titleLabel.attributedText = nil
        emojiLabel.text = nil
        counterLabel.text = nil
        color = nil
        setCellState(.uncompleted)
    }
    
    // MARK: - UI Setup
    private func setupView() {
        setupCardView()
        setupCardStackView()
        setupEmojiLabel()
        setupTitleLabel()
        
        setupQuantityManagementView()
        setupQuantityManagementStackView()
        setupCounterLabel()
        setupCompleteButton()
    }
    
    private func setupCardView() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.overrideUserInterfaceStyle = .light
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.layer.borderColor = UIColor(resource: .ypCellBorder).cgColor
        cardView.layer.borderWidth = 1
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cardView.heightAnchor.constraint(
                equalToConstant: 90
            ),
        ])
    }
    
    private func setupEmojiLabel() {
        emojiLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        // В макете emoji имеет размер 16, но визуально ему соответствует размер 13.
        emojiLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        emojiLabel.textAlignment = .center
        
        cardStackView.addArrangedSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(
                equalToConstant: 24
            ),
            emojiLabel.heightAnchor.constraint(
                equalToConstant: 24
            ),
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.textAlignment = .natural
        titleLabel.numberOfLines = 2
        
        cardStackView.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCardStackView() {
        cardStackView.axis = .vertical
        cardStackView.alignment = .leading
        cardStackView.distribution = .equalCentering
        
        cardView.addSubview(cardStackView)
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),
            cardStackView.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),
            cardStackView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            cardStackView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -12
            ),
        ])
    }
    
    private func setupQuantityManagementView() {
        contentView.addSubview(quantityManagementView)
        quantityManagementView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quantityManagementView.topAnchor.constraint(
                equalTo: cardView.bottomAnchor
            ),
            quantityManagementView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            quantityManagementView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            quantityManagementView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
        ])
    }
    
    private func setupQuantityManagementStackView() {
        quantityManagementStackView.axis = .horizontal
        
        quantityManagementView.addSubview(quantityManagementStackView)
        quantityManagementStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quantityManagementStackView.topAnchor.constraint(
                equalTo: quantityManagementView.topAnchor,
                constant: 8
            ),
            quantityManagementStackView.leadingAnchor.constraint(
                equalTo: quantityManagementView.leadingAnchor,
                constant: 12
            ),
            quantityManagementStackView.trailingAnchor.constraint(
                equalTo: quantityManagementView.trailingAnchor,
                constant: -12
            ),
            quantityManagementStackView.bottomAnchor.constraint(
                equalTo: quantityManagementView.bottomAnchor,
                constant: -8
            ),
        ])
    }
    
    private func setupCounterLabel() {
        counterLabel.textAlignment = .natural
        counterLabel.textColor = .ypBlack
        counterLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        quantityManagementStackView.addArrangedSubview(counterLabel)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCompleteButton() {
        completeButton.addTarget(
            self,
            action: #selector(completeButtonDidTap),
            for: .touchUpInside
        )
        
        quantityManagementStackView.addArrangedSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        completeButton.layer.cornerRadius = 17
        completeButton.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            completeButton.widthAnchor.constraint(
                equalToConstant: 34
            ),
            completeButton.heightAnchor.constraint(
                equalToConstant: 34
            ),
        ])
    }
    
    // MARK: - Actions
    @objc private func completeButtonDidTap() {
        delegate?.completeButtonDidTap(cell: self)
    }
    
    // MARK: - Public Methods
    func configure(
        title: String,
        emoji: String,
        counterText: String,
        color: UIColor,
        isCompleted: Bool
    ) {
        setTitle(title)
        emojiLabel.text = emoji
        counterLabel.text = counterText
        self.color = color
        setCellState(isCompleted ? .completed : .uncompleted)
    }
    
    // MARK: - Content State
    private func setCellState(_ state: CellState) {
        cellState = state
        render(for: state)
    }
    
    private func render(for state: CellState) {
        switch state {
        case .completed:
            completeButton.setImage(
                UIImage(resource: .doneButton).withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            
        case .uncompleted:
            completeButton.setImage(
                UIImage(resource: .plusButton).withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
    }
    
    // MARK: - Helpers
    private func setTitle(_ title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        paragraphStyle.maximumLineHeight = 18
        paragraphStyle.alignment = .natural
        
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.ypWhite,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
