import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Types
    private enum SaveButtonRenderMode {
        case enabled
        case disabled
    }
    
    // MARK: - Dependencies
    private let storage: StorageProtocol
    
    // MARK: - Child View Controllers
    private lazy var titleInputViewController = TextFieldViewController(
        placeholderText: "Введите название категории",
        text: inputText
    )
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    private lazy var saveButton = UIButton(type: .custom)
    
    // MARK: - State
    private let editingCategory: TrackerCategory?
    
    private var isCategoryReadyForSaving = false {
        didSet {
            guard oldValue != isCategoryReadyForSaving else { return }
            
            if isCategoryReadyForSaving {
                setSaveButtonState(.enabled)
            } else {
                setSaveButtonState(.disabled)
            }
        }
    }
    
    private var titleLabelText: String {
        editingCategory == nil
        ? "Новая категория"
        : "Редактирование категории"
    }
    
    private var inputText: String {
        didSet {
            guard inputText != oldValue else { return }
            
            isCategoryReadyForSaving = checkCategoryIsReadyForSaving()
        }
    }
    
    private var saveButtonRenderMode: SaveButtonRenderMode = .disabled
    
    // MARK: - Initialization
    init(
        editingCategory: TrackerCategory,
        storage: StorageProtocol = Storage()
    ) {
        self.editingCategory = editingCategory
        self.storage = storage
        self.inputText = editingCategory.title
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(storage: StorageProtocol = Storage()) {
        self.editingCategory = nil
        self.storage = storage
        self.inputText = ""
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleInputViewController.delegate = self
        
        setupView()
        setupTapGesture()
        
        isCategoryReadyForSaving = checkCategoryIsReadyForSaving()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupTitleLabel()
        setupSaveButton()
        renderSaveButton(for: .disabled)
        setupTitleInputViewController()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = titleLabelText
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
    
    private func setupSaveButton() {
        saveButton.addTarget(
            self,
            action: #selector(saveButtonDidTap),
            for: .touchUpInside
        )
        
        saveButton.setTitle("Готово", for: .normal)
        saveButton.setTitleColor(.ypWhite, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = true
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            saveButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            saveButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }
    
    private func setupTitleInputViewController() {
        addChild(titleInputViewController)
        view.addSubview(titleInputViewController.view)
        
        titleInputViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleInputViewController.view.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 38
            ),
            titleInputViewController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleInputViewController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
        
        titleInputViewController.didMove(toParent: self)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc
    private func saveButtonDidTap() {
        do {
            try saveCategory()
            closeScreen()
        } catch {
            print("❌ [NewCategoryViewController] saveButtonDidTap: \(error)")
        }
    }
    
    @objc
    private func hideKeyboard() {
        titleInputViewController.finishInputEditing()
    }
    
    // MARK: - Navigation
    private func closeScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Content State
    private func setSaveButtonState(_ state: SaveButtonRenderMode) {
        guard saveButtonRenderMode != state else { return }
        
        saveButtonRenderMode = state
        renderSaveButton(for: state)
    }
    
    private func renderSaveButton(for state: SaveButtonRenderMode) {
        switch state {
        case .enabled:
            saveButton.backgroundColor = .ypBlack
            saveButton.isUserInteractionEnabled = true
            
        case .disabled:
            saveButton.backgroundColor = .ypGray
            saveButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Data Updates
    private func checkCategoryIsReadyForSaving() -> Bool {
        guard !inputText.isEmpty else {
            return false
        }
        
        if editingCategory?.title == inputText {
            return true
        }
        
        do {
            let categoryExists = try storage.categoryExists(
                with: inputText,
                excluding: editingCategory
            )
            
            return !categoryExists
        } catch {
            print("❌ [NewCategoryViewController] checkCategoryIsReadyForSaving: \(error)")
            return false
        }
    }
    
    private func saveCategory() throws {
        if editingCategory?.title == inputText {
            return
        }
        
        if let editingCategory {
            try storage.updateTrackerCategory(
                editingCategory,
                newTitle: inputText
            )
        } else {
            let category = TrackerCategory(
                title: inputText,
                trackers: []
            )
            
            try storage.addTrackerCategory(category)
        }
    }
}

// MARK: - TextFieldViewControllerDelegateProtocol
extension NewCategoryViewController: TextFieldViewControllerDelegateProtocol {
    func didChangeInputText(_ text: String) {
        inputText = text
    }
    
    
    func didFinishInputEditing(_ text: String) {
        inputText = text
    }
}
