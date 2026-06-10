import UIKit

final class AddingTrackerViewController: UIViewController {
    
    // MARK: - Types
    private enum SaveButtonRenderMode {
        case enabled
        case disabled
    }
    
    // MARK: - Dependencies
    private let storage: StorageProtocol
    
    // MARK: - Navigation View Controllers
    private lazy var addingScheduleViewController = AddingScheduleViewController(
        schedule: inputSchedule
    )
    private lazy var addingCategoryViewController = AddingCategoryViewController(
        selectedCategory: inputCategory
    )
    
    // MARK: - Child View Controllers
    private lazy var titleInputViewController = TextFieldViewController(
        placeholderText: "Введите название трекера",
        text: inputText
    )
    
    private lazy var tableViewController = TableViewController(
        renderMode: .addingTrackerViewController,
        titlesAndDescriptions: tableTitlesAndValues
    )
    
    private lazy var emojiViewController = EmojiAndColorCollectionViewController(
        emojis: TrackerEmoji.emojis,
        selectedIndex: TrackerEmoji.emojis.firstIndex(of: inputEmoji)
    )
    
    private lazy var colorViewController = EmojiAndColorCollectionViewController(
        colors: TrackerColor.colors,
        selectedIndex: TrackerColor.colors.firstIndex {
            guard let inputColor else { return false }
            return $0.cgColor == inputColor.cgColor
        }
    )
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    
    private lazy var counterLabel = UILabel()
    
    private lazy var emojiLabelContainerView = UIView()
    private lazy var emojiLabel = UILabel()
    
    private lazy var colorLabelContainerView = UIView()
    private lazy var colorLabel = UILabel()
    
    private lazy var bottomButtonsStackView = UIStackView()
    private lazy var saveButton = UIButton(type: .custom)
    private lazy var cancelButton = UIButton(type: .custom)
    
    // MARK: - Data
    private let trackerType: TrackerType
    
    private var tableTitlesAndValues: [(String, String?)] {
        switch trackerType {
        case .regular:
            return [
                ("Категория", inputCategory?.title),
                ("Расписание", scheduleLabelText),
            ]
            
        case .irregular:
            return [
                ("Категория", inputCategory?.title),
            ]
        }
    }

    private var scheduleLabelText: String? {
        convertScheduleToString(inputSchedule)
    }
    
    private var titleLabelText: String?
    private var counterLabelText: String?
    private var saveButtonText: String?
    
    // MARK: - State
    private var isTrackerReadyForSaving: Bool = false {
        didSet {
            guard oldValue != isTrackerReadyForSaving else { return }
            
            if isTrackerReadyForSaving {
                setSaveButtonState(.enabled)
            } else {
                setSaveButtonState(.disabled)
            }
        }
    }
    
    private var saveButtonRenderMode: SaveButtonRenderMode = .disabled
    
    private var inputTracker: Tracker?
    
    private var inputText: String = "" {
        didSet {
            isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
        }
    }
    
    private var inputCategory: TrackerCategory? {
        didSet {
            tableViewController.titlesAndDescriptions = tableTitlesAndValues
            isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
        }
    }
    
    private var inputSchedule: Set<Weekday> = [] {
        didSet {
            tableViewController.titlesAndDescriptions = tableTitlesAndValues
            isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
        }
    }
    
    private var inputColor: UIColor? {
        didSet {
            isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
        }
    }
    
    private var inputEmoji: String = "" {
        didSet {
            isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
        }
    }
    
    // MARK: - Initialization
    init(trackerType: TrackerType, storage: StorageProtocol = Storage()) {
        self.trackerType = trackerType
        self.storage = storage
        
        switch trackerType {
        case .regular:
            self.titleLabelText = "Новая привычка"
        case .irregular:
            self.titleLabelText = "Новое нерегулярное событие"
        }

        self.saveButtonText = "Создать"
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(
        tracker: Tracker,
        category: TrackerCategory,
        completedDaysText: String,
        storage: StorageProtocol = Storage()
    ) {
        self.inputTracker = tracker
        self.inputText = tracker.title
        self.inputSchedule = tracker.schedule
        self.inputColor = tracker.color
        self.inputEmoji = tracker.emoji
        self.inputCategory = category
        
        self.storage = storage
        
        switch tracker.schedule.isEmpty {
        case true:
            self.trackerType = .irregular
            self.titleLabelText = "Редактирование нерегулярного события"
        case false:
            self.trackerType = .regular
            self.titleLabelText = "Редактирование привычки"
        }

        self.saveButtonText = "Сохранить"
        self.counterLabelText = completedDaysText
        
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
        addingCategoryViewController.delegate = self
        addingScheduleViewController.delegate = self
        titleInputViewController.delegate = self
        emojiViewController.delegate = self
        colorViewController.delegate = self
        
        setupView()
        setupTapGesture()
        isTrackerReadyForSaving = checkTrackerIsReadyForSaving()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupTitleLabel()
        
        setupBottomButtonsStackView()
        setupCancelButton()
        setupSaveButton()
        
        setupScrollView()
        setupContentStackView()
        
        setupCounterLabel()
        
        setupTitleInputViewController()
        setupTableViewController()
        
        setupEmojiLabelContainerView()
        setupEmojiLabel()
        setupEmojiViewController()
        
        setupColorLabelContainerView()
        setupColorLabel()
        setupColorViewController()
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
    
    private func setupBottomButtonsStackView() {
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.spacing = 8
        bottomButtonsStackView.alignment = .fill
        bottomButtonsStackView.distribution = .fillEqually
        
        view.addSubview(bottomButtonsStackView)
        bottomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomButtonsStackView.heightAnchor.constraint(
                equalToConstant: 60
            ),
            bottomButtonsStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            bottomButtonsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            bottomButtonsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonDidTap),
            for: .touchUpInside
        )
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .clear
        
        cancelButton.layer.borderColor = UIColor(resource: .ypRed).cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        
        bottomButtonsStackView.addArrangedSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSaveButton() {
        saveButton.addTarget(
            self,
            action: #selector(saveButtonDidTap),
            for: .touchUpInside
        )
        
        guard let saveButtonText else { return }
        
        saveButton.setTitle(saveButtonText, for: .normal)
        saveButton.setTitleColor(.ypWhite, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        renderSaveButton(for: .disabled)
        
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = true
        
        bottomButtonsStackView.addArrangedSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
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
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: bottomButtonsStackView.topAnchor,
                constant: -16
            ),
        ])
    }
    
    private func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: 16
            ),
            
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -16
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
        ])
    }
    
    private func setupCounterLabel() {
        guard let counterLabelText else { return }
        
        counterLabel.text = counterLabelText
        counterLabel.textColor = .ypBlack
        counterLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        counterLabel.backgroundColor = .clear
        counterLabel.textAlignment = .center
        
        contentStackView.addArrangedSubview(counterLabel)
        contentStackView.setCustomSpacing(
            40,
            after: counterLabel
        )
    }
    
    private func setupTitleInputViewController() {
        addToStackViewChildController(titleInputViewController)
    }
    
    private func setupTableViewController() {
        contentStackView.setCustomSpacing(
            24,
            after: titleInputViewController.view
        )
        addToStackViewChildController(tableViewController)
    }
    
    private func setupEmojiLabelContainerView() {
        contentStackView.setCustomSpacing(
            32,
            after: tableViewController.view
        )
        
        contentStackView.addArrangedSubview(emojiLabelContainerView)
        emojiLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupEmojiLabel() {
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .ypBlack
        emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        emojiLabelContainerView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(
                equalTo: emojiLabelContainerView.topAnchor
            ),
            emojiLabel.leadingAnchor.constraint(
                equalTo: emojiLabelContainerView.leadingAnchor,
                constant: 12
            ),
            emojiLabel.bottomAnchor.constraint(
                equalTo: emojiLabelContainerView.bottomAnchor
            ),
        ])
    }
    
    private func setupEmojiViewController() {
        addToStackViewChildController(emojiViewController)
    }
    
    private func setupColorLabelContainerView() {
        contentStackView.setCustomSpacing(
            16,
            after: emojiViewController.view
        )
        
        contentStackView.addArrangedSubview(colorLabelContainerView)
        colorLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupColorLabel() {
        colorLabel.text = "Цвет"
        colorLabel.textColor = .ypBlack
        colorLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        colorLabelContainerView.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(
                equalTo: colorLabelContainerView.topAnchor
            ),
            colorLabel.leadingAnchor.constraint(
                equalTo: colorLabelContainerView.leadingAnchor,
                constant: 12
            ),
            colorLabel.bottomAnchor.constraint(
                equalTo: colorLabelContainerView.bottomAnchor
            ),
        ])
    }
    
    private func setupColorViewController() {
        addToStackViewChildController(colorViewController)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addToStackViewChildController(_ child: UIViewController) {
        addChild(child)
        contentStackView.addArrangedSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.didMove(toParent: self)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonDidTap() {
        closeScreen()
    }
    
    @objc private func saveButtonDidTap() {
        do {
            try saveTracker()
            closeScreen()
        } catch {
            print("❌ [AddingTrackerViewController] saveButtonDidTap: \(error)")
        }
    }
    
    @objc private func hideKeyboard() {
        titleInputViewController.finishInputEditing()
    }
    
    // MARK: - Navigation
    private func closeScreen() {
        dismiss(animated: true)
    }
    
    private func showAddingScheduleScreen() {
        navigationController?.pushViewController(
            addingScheduleViewController,
            animated: true
        )
    }
    
    private func showAddingCategoryScreen() {
        navigationController?.pushViewController(
            addingCategoryViewController,
            animated: true
        )
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
    private func checkTrackerIsReadyForSaving() -> Bool {
        guard trackerType == .irregular || (trackerType == .regular && !inputSchedule.isEmpty) else {
            return false
        }
        
        return !inputText.isEmpty
        && !inputEmoji.isEmpty
        && inputColor != nil
        && inputCategory != nil
    }
    
    private func saveTracker() throws {
        guard
            let inputColor,
            let inputCategory
        else {
            return
        }
        
        if let inputTracker {
            let tracker = Tracker(
                id: inputTracker.id,
                title: inputText,
                color: inputColor,
                emoji: inputEmoji,
                schedule: inputSchedule
            )
            
            try storage.updateTracker(
                tracker,
                in: inputCategory
            )
            
        } else {
            let tracker = Tracker(
                title: inputText,
                color: inputColor,
                emoji: inputEmoji,
                schedule: inputSchedule
            )
            
            try storage.addTracker(
                tracker,
                to: inputCategory
            )
        }
    }
    
    // MARK: - Helpers
    private func convertScheduleToString(_ schedule: Set<Weekday>) -> String? {
        if trackerType == .irregular || (trackerType == .regular && schedule.isEmpty) {
            return nil
        }
        
        if schedule.count == 7 {
            return "Каждый день"
        }
        
        let week = Weekday.allCases
        var sortedScheduleString = [String]()
        
        week.forEach {
            if schedule.contains($0) {
                sortedScheduleString.append($0.rawValue)
            }
        }
        
        return sortedScheduleString.joined(separator: ", ")
    }
}

// MARK: - TableViewControllerDelegateProtocol
extension AddingTrackerViewController: TableViewControllerDelegateProtocol {

    func didTapEdit(at index: Int) { }
    
    func didTapDelete(at index: Int) { }
    
    func didChangeSwitcherValueAt(row: Int, newValue: Bool) { }
    
    func didSelectRowAt(_ index: Int, title: String) {
        switch title {
        case "Категория":
            showAddingCategoryScreen()
            return
            
        case "Расписание":
            showAddingScheduleScreen()
            
        default:
            break
        }
    }
}

// MARK: - AddingCategoryViewControllerDelegateProtocol
extension AddingTrackerViewController: AddingCategoryViewControllerDelegateProtocol {
    
    func didSelectCategory(_ category: TrackerCategory) {
        inputCategory = category
    }
}

// MARK: - AddingScheduleViewControllerDelegateProtocol
extension AddingTrackerViewController: AddingScheduleViewControllerDelegateProtocol {
    
    func didFinishSelectingSchedule(_ schedule: Set<Weekday>) {
        inputSchedule = schedule
    }
}

// MARK: - TextFieldViewControllerDelegateProtocol
extension AddingTrackerViewController: TextFieldViewControllerDelegateProtocol {
    
    func didFinishInputEditing(_ text: String) {
        inputText = text
    }
}

// MARK: - EmojiAndColorCollectionViewControllerDelegateProtocol
extension AddingTrackerViewController: EmojiAndColorCollectionViewControllerDelegateProtocol {
    
    func didSelectEmoji(_ emoji: String) {
        inputEmoji = emoji
    }
    
    func didSelectColor(_ color: UIColor) {
        inputColor = color
    }
}
