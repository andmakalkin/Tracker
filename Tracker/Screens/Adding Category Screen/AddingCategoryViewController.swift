import UIKit

final class AddingCategoryViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: AddingCategoryViewControllerDelegateProtocol?
    
    // MARK: - Dependencies
    private let viewModel: AddingCategoryViewModel
    private let alertPresenter: AlertPresenterProtocol
    
    // MARK: - Child View Controllers
    private lazy var tableViewController = TableViewController(
        renderMode: .addingCategoryViewController,
        titles: []
    )
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    private lazy var addCategoryButton = UIButton(type: .custom)
    private lazy var scrollView = UIScrollView()

    private lazy var stubContainerView = UIView()
    private lazy var stubStackView = UIStackView()
    private lazy var stubImageView = UIImageView()
    private lazy var stubTextLabel = UILabel()
    
    // MARK: - Initialization
    init(
        selectedCategory: TrackerCategory? = nil,
        viewModel: AddingCategoryViewModel? = nil,
        alertPresenter: AlertPresenterProtocol = AlertPresenter()
    ) {
        let viewModel = viewModel ?? AddingCategoryViewModel(
            selectedCategory: selectedCategory
        )
        
        self.viewModel = viewModel
        self.alertPresenter = alertPresenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewController.delegate = self
        
        bind()
        viewModel.loadData()
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupTitleLabel()
        setupAddCategoryButton()
        setupScrollView()
        setupStub()
        setupTableViewController()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Категория"
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
    
    private func setupAddCategoryButton() {
        addCategoryButton.addTarget(
            self,
            action: #selector(addCategoryButtonDidTap),
            for: .touchUpInside
        )
        
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.ypWhite, for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.layer.masksToBounds = true
        
        view.addSubview(addCategoryButton)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            addCategoryButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            addCategoryButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            addCategoryButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }
    
    private func setupScrollView() {
        scrollView.backgroundColor = .ypWhite
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.contentInset = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 14
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: addCategoryButton.topAnchor,
                constant: -16
            ),
        ])
    }
    
    private func setupStub() {
        stubTextLabel.text = "Привычки и события можно\nобъединить по смыслу"
        stubTextLabel.textColor = .ypBlack
        stubTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubTextLabel.numberOfLines = 2
        stubTextLabel.textAlignment = .center
        
        stubImageView.image = UIImage(resource: .stubTrackers)
        
        stubStackView.axis = .vertical
        stubStackView.alignment = .center
        stubStackView.distribution = .fill
        stubStackView.spacing = 8
        
        view.addSubview(stubContainerView)
        stubContainerView.addSubview(stubStackView)
        stubStackView.addArrangedSubview(stubImageView)
        stubStackView.addArrangedSubview(stubTextLabel)
        
        stubContainerView.translatesAutoresizingMaskIntoConstraints = false
        stubStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stubContainerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 14
            ),
            stubContainerView.bottomAnchor.constraint(
                equalTo: addCategoryButton.topAnchor
            ),
            stubContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            stubContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            
            stubStackView.centerXAnchor.constraint(
                equalTo: stubContainerView.centerXAnchor
            ),
            stubStackView.centerYAnchor.constraint(
                equalTo: stubContainerView.centerYAnchor
            ),
            
            stubImageView.widthAnchor.constraint(
                equalToConstant: 80
            ),
            stubImageView.heightAnchor.constraint(
                equalToConstant: 80
            ),
        ])
    }
    
    private func setupTableViewController() {
        addChild(tableViewController)
        scrollView.addSubview(tableViewController.view)
        
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableViewController.view.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            tableViewController.view.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            tableViewController.view.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            tableViewController.view.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            tableViewController.view.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
        ])
        
        tableViewController.didMove(toParent: self)
    }
    
    // MARK: - Actions
    @objc
    private func addCategoryButtonDidTap() {
        showNewCategoryScreen()
    }
    
    // MARK: - Navigation
    private func closeScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showNewCategoryScreen() {
        let newCategoryViewController = NewCategoryViewController()
        navigationController?.pushViewController(
            newCategoryViewController,
            animated: true
        )
    }
    
    private func showEditingCategoryScreen(with category: TrackerCategory) {
        let newCategoryViewController = NewCategoryViewController(
            editingCategory: category
        )
        
        navigationController?.pushViewController(
            newCategoryViewController,
            animated: true
        )
    }
    
    // MARK: - Binding
    private func bind() {
        viewModel.onCategoriesStateChange = { [weak self] categories in
            self?.tableViewController.titlesAndDescriptions = categories.map {
                ($0.title, nil)
            }
        }
        
        viewModel.onEmptyStateChange = { [weak self] isEmpty in
            self?.stubContainerView.isHidden = !isEmpty
            self?.scrollView.isHidden = isEmpty
        }
        
        viewModel.onSelectedIndexChange = { [weak self] selectedIndex in
            self?.tableViewController.setSelectedIndex(
                for: selectedIndex
            )
        }
    }
}

// MARK: - TableViewControllerDelegateProtocol
extension AddingCategoryViewController: TableViewControllerDelegateProtocol {
    
    func didTapEdit(at index: Int) {
        guard let category = viewModel.category(at: index) else {
            return
        }
        
        showEditingCategoryScreen(with: category)
    }
    
    func didTapDelete(at index: Int) {
        guard let alertModel = viewModel.makeDeleteCategoryAlertModel(at: index) else {
            return
        }
        
        alertPresenter.show(
            in: self,
            model: alertModel
        )
    }
    
    func didSelectRowAt(_ index: Int, title: String) {
        guard let category = viewModel.didSelectCategory(at: index) else {
            return
        }
        
        delegate?.didSelectCategory(category)
        closeScreen()
    }
    
    func didChangeSwitcherValueAt(row: Int, newValue: Bool) { }
}
