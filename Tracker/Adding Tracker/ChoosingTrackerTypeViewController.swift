import UIKit

final class ChoosingTrackerTypeViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView()
    
    private lazy var newRegularTrackerButton = UIButton(type: .custom)
    private lazy var newIrregularTrackerButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupTitleLabel()
        setupContainerView()
        setupStackView()
        setupButtons()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Создание трекера"
        titleLabel.textColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 26
            ),
            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
        ])
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 14
            ),
            containerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            containerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            containerView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            stackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
        ])
    }
    
    private func setupButtons() {
        setupButton(newRegularTrackerButton, withText: "Привычка")
        newRegularTrackerButton.addTarget(
            self,
            action: #selector(newRegularTrackerButtonDidTap),
            for: .touchUpInside
        )
        
        setupButton(newIrregularTrackerButton, withText: "Нерегулярное событие")
        newIrregularTrackerButton.addTarget(
            self,
            action: #selector(newIrregularTrackerButtonDidTap),
            for: .touchUpInside
        )
        
        stackView.addArrangedSubview(newRegularTrackerButton)
        stackView.addArrangedSubview(newIrregularTrackerButton)
        newRegularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        newIrregularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newRegularTrackerButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
            newIrregularTrackerButton.heightAnchor.constraint(
                equalTo: newRegularTrackerButton.heightAnchor
            ),
        ])
    }
    
    private func setupButton(_ button: UIButton, withText text: String) {
        button.setTitle(text, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @objc private func newRegularTrackerButtonDidTap() {
        showAddingTrackerScreen(with: .regular)
    }
    
    @objc private func newIrregularTrackerButtonDidTap() {
        showAddingTrackerScreen(with: .irregular)
    }
    
    // MARK: - Navigation
    private func showAddingTrackerScreen(with trackerType: TrackerType) {
        let addingTrackerViewController = AddingTrackerViewController(
            trackerType: trackerType
        )
        
        navigationController?.pushViewController(
            addingTrackerViewController,
            animated: true
        )
    }
}
