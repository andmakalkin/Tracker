import UIKit

final class TableViewControllerCell: UITableViewCell {
    // MARK: - Types
    enum Accessory {
        case navigation
        case switcher(isOn: Bool)
    }
    
    struct Model {
        let title: String
        let description: String?
        let accessory: Accessory
    }
    
    // MARK: - Type Properties
    static let reuseIdentifier = "TableViewControllerCell"
    
    // MARK: - Delegate
    weak var delegate: TableViewControllerCellDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var verticalStackView = UIStackView()
    private lazy var horizontalStackView = UIStackView()
    
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    
    private lazy var navigationButton = UIButton(type: .custom)
    private lazy var switcher = UISwitch()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switcher.layer.cornerRadius = switcher.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = true
        navigationButton.isHidden = true
        switcher.isHidden = true
        switcher.isOn = false
    }
    
    // MARK: - UI Setup
    private func setupCellView() {
        contentView.backgroundColor = .ypBackground
        selectionStyle = .none
        
        setupHStack()
        setupVStack()
        setupTitleLabel()
        setupDescriptionLabel()
        setupNavigationButton()
        setupSwitcher()
    }
    
    private func setupHStack() {
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .center
        
        contentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(navigationButton)
        horizontalStackView.addArrangedSubview(switcher)
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            horizontalStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            horizontalStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            horizontalStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
        ])
    }
    
    private func setupVStack() {
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 2
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.textColor = .ypGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.isHidden = true
    }
    
    private func setupNavigationButton() {
        navigationButton.setImage(
            UIImage(resource: .forward),
            for: .normal
        )
        
        navigationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationButton.widthAnchor.constraint(
                equalToConstant: 24
            ),
            navigationButton.heightAnchor.constraint(
                equalToConstant: 24
            ),
        ])
        
        navigationButton.isHidden = true
    }
    
    private func setupSwitcher() {
        switcher.addTarget(
            self,
            action: #selector(switcherValueDidChange),
            for: .valueChanged
        )
        
        switcher.onTintColor = .ypBlue
        switcher.thumbTintColor = .white
        switcher.tintColor = .ypLightGray
        switcher.backgroundColor = .ypLightGray
        switcher.clipsToBounds = true
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        switcher.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func switcherValueDidChange() {
        delegate?.didChangeSwitcherValue(
            at: self,
            newValue: switcher.isOn
        )
    }
    
    // MARK: - Public Methods
    func configure(with model: Model) {
        titleLabel.text = model.title
        
        if let description = model.description {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        switch model.accessory {
        case .navigation:
            navigationButton.isHidden = false
            switcher.isHidden = true
            
        case .switcher(let isOn):
            navigationButton.isHidden = true
            switcher.isHidden = false
            switcher.setOn(isOn, animated: false)
        }
    }
}
