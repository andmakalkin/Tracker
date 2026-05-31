import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    
    private lazy var containerView = UIView()
    
    private lazy var stubTextLabel = UILabel()
    private lazy var stubImageView = UIImageView()
    private lazy var stubStackView = UIStackView()
    
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
        setupStub()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Статистика"
        titleLabel.textColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
        ])
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor
            ),
            containerView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            containerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            containerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
        ])
    }
    
    private func setupStub() {
        stubTextLabel.text = "Анализировать пока нечего"
        stubTextLabel.textColor = .ypBlack
        stubTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        stubImageView.image = UIImage(resource: .stubStatistics)
        
        stubStackView.axis = .vertical
        stubStackView.alignment = .center
        stubStackView.distribution = .fill
        stubStackView.spacing = 8
        
        stubStackView.addArrangedSubview(stubImageView)
        stubStackView.addArrangedSubview(stubTextLabel)
        
        containerView.addSubview(stubStackView)
        stubStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor
            ),
            stubStackView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            stubImageView.widthAnchor.constraint(
                equalToConstant: 80
            ),
            stubImageView.heightAnchor.constraint(
                equalToConstant: 80
            ),
        ])
    }
}
