import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Types
    private enum RenderMode {
        case stub
        case content
    }
    
    // MARK: - Dependencies
    private let storage = Storage.shared
    
    // MARK: - Child View Controllers
    private let searchTextFieldViewController = SearchTextFieldViewController()
    private let collectionViewController = CollectionViewController()
    
    // MARK: - Observers
    private var storageCategoriesObserver: NSObjectProtocol?
    private var storageCompletedTrackersObserver: NSObjectProtocol?
    
    // MARK: - UI Elements
    private lazy var addingTrackerButton = UIButton(type: .custom)
    private lazy var datePicker = UIDatePicker()
    private lazy var titleLabel = UILabel()
    private lazy var filtersButton = UIButton(type: .custom)
    
    private lazy var containerView = UIView()
    
    private lazy var stubStackView = UIStackView()
    private lazy var stubTextLabel = UILabel()
    private lazy var stubImageView = UIImageView()
    
    // MARK: - Data
    private var categories: [TrackerCategory] {
        didSet {
            updateCategoriesToShow()
        }
    }
    
    private var completedTrackers: [TrackerRecord] {
        didSet {
            updateCompletedTrackersInfo()
            updateCategoriesToShow()
        }
    }
    
    private var categoriesToShow = [TrackerCategory]() {
        didSet {
            collectionViewController.categoriesToShow = categoriesToShow
            updateContentState()
        }
    }
    
    private var completedTrackerIdsOnSelectedDate = Set<UUID>()
    private var completedDaysCountByTrackerId = [UUID: Int]()
    
    // MARK: - State
    private var inputText: String = ""
    
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            updateCompletedTrackersInfo()
            updateCategoriesToShow()
        }
    }
    
    private var selectedWeekday: Weekday {
        convertDateToWeekday(selectedDate)
    }
    
    private var renderMode: RenderMode?
    
    // MARK: - Initialization
    init() {
        self.categories = storage.categories
        self.completedTrackers = storage.completedTrackers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    deinit {
        if let storageCategoriesObserver {
            NotificationCenter.default.removeObserver(storageCategoriesObserver)
        }
        
        if let storageCompletedTrackersObserver {
            NotificationCenter.default.removeObserver(storageCompletedTrackersObserver)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextFieldViewController.delegate = self
        collectionViewController.delegate = self
        
        addObservers()
        setupView()
        updateCompletedTrackersInfo()
        updateCategoriesToShow()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupAddTrackerButton()
        setupDatePicker()
        setupTitleLabel()
        addAndSetupSearchTextFieldController()
        setupContainerView()
        addAndSetupCollectionViewController()
        setupStubStackView()
        setupFiltersButton()
        setupTapGesture()
    }
    
    private func setupAddTrackerButton() {
        addingTrackerButton.addTarget(
            self,
            action: #selector(Self.addingTrackerButtonDidTap),
            for: .touchUpInside
        )
        
        addingTrackerButton.tintColor = .ypBlack
        addingTrackerButton.setImage(
            UIImage(resource: .plus).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        
        view.addSubview(addingTrackerButton)
        addingTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addingTrackerButton.widthAnchor.constraint(
                equalToConstant: 42
            ),
            addingTrackerButton.heightAnchor.constraint(
                equalToConstant: 42
            ),
            addingTrackerButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 1
            ),
            addingTrackerButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 6
            ),
        ])
    }
    
    private func setupDatePicker() {
        datePicker.addTarget(
            self,
            action: #selector(didChangeDatePickerValue),
            for: .valueChanged
        )
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(
                equalToConstant: 34
            ),
            datePicker.centerYAnchor.constraint(
                equalTo: addingTrackerButton.centerYAnchor
            ),
            datePicker.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Трекеры"
        titleLabel.textColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: addingTrackerButton.bottomAnchor,
                constant: 1
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
        ])
    }
    
    private func addAndSetupSearchTextFieldController() {
        addChild(searchTextFieldViewController)
        
        guard let searchTextField = searchTextFieldViewController.view else { return }
        
        view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 7
            ),
            searchTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            searchTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            searchTextField.heightAnchor.constraint(
                equalToConstant: 36
            )
        ])
        
        searchTextFieldViewController.didMove(toParent: self)
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .clear
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: searchTextFieldViewController.view.bottomAnchor,
                constant: 10
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
    
    private func addAndSetupCollectionViewController() {
        addChild(collectionViewController)
        
        collectionViewController.categoriesToShow = self.categoriesToShow
        
        guard let collectionView = collectionViewController.view else { return }
        
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 16
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -16
            ),
        ])
        
        collectionViewController.didMove(toParent: self)
    }
    
    private func setupStubStackView() {
        stubTextLabel.text = "Что будем отслеживать?"
        stubTextLabel.textColor = .ypBlack
        stubTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        stubImageView.image = UIImage(resource: .stubTrackers)
        
        stubStackView.axis = .vertical
        stubStackView.alignment = .center
        stubStackView.distribution = .fill
        stubStackView.spacing = 8
        stubStackView.backgroundColor = .clear
        
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
    
    private func setupFiltersButton() {
        filtersButton.addTarget(
            self,
            action: #selector(filtersButtonDidTap),
            for: .touchUpInside
        )
        
        filtersButton.overrideUserInterfaceStyle = .light
        filtersButton.setTitle("Фильтры", for: .normal)
        filtersButton.setTitleColor(.ypWhite, for: .normal)
        filtersButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filtersButton.backgroundColor = .ypBlue
        
        filtersButton.layer.cornerRadius = 16
        filtersButton.layer.masksToBounds = true
        
        view.addSubview(filtersButton)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            filtersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            filtersButton.widthAnchor.constraint(
                equalToConstant: 114
            ),
            filtersButton.heightAnchor.constraint(
                equalToConstant: 50
            ),
        ])
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
    @objc private func addingTrackerButtonDidTap() {
        showChoosingTrackerTypeScreen()
    }
    
    @objc private func didChangeDatePickerValue() {
        selectedDate = Calendar.current.startOfDay(for: datePicker.date)
    }
    
    @objc private func hideKeyboard() {
        searchTextFieldViewController.finishInputEditing()
    }
    
    @objc private func filtersButtonDidTap() {
        
    }
    
    // MARK: - Navigation
    private func showChoosingTrackerTypeScreen() {
        let navigationController = UINavigationController()
        let choosingTrackerTypeViewController = ChoosingTrackerTypeViewController()
        
        navigationController.viewControllers = [choosingTrackerTypeViewController]
        
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.modalTransitionStyle = .coverVertical
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Content State
    private func updateContentState() {
        let newRenderMode: RenderMode = categoriesToShow.isEmpty ? .stub : .content
        
        if newRenderMode != renderMode {
            setRenderState(newRenderMode)
        }
        
        if newRenderMode == .content {
            collectionViewController.reloadCollectionView()
        }
    }
    
    private func setRenderState(_ state: RenderMode) {
        renderMode = state
        render(for: state)
    }
    
    private func render(for state: RenderMode) {
        switch state {
        case .stub:
            collectionViewController.view.isHidden = true
            stubStackView.isHidden = false
            filtersButton.isHidden = true
            
        case .content:
            stubStackView.isHidden = true
            collectionViewController.view.isHidden = false
            filtersButton.isHidden = false
        }
    }
    
    // MARK: - Data Updates
    private func updateCategoriesToShow() {
        var newCategoriesToShow = [TrackerCategory]()
        
        categories.forEach { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else {
                    // Нерегулярное событие
                    return isTrackerCompletedOnSelectedDate(tracker) ||
                    numberOfCompletedDays(for: tracker) == 0
                }
                // Регулярное событие
                return schedule.selectedDays.contains(selectedWeekday)
            }
            
            if !filteredTrackers.isEmpty {
                newCategoriesToShow.append(
                    TrackerCategory(
                        title: category.title,
                        trackers: filteredTrackers
                    )
                )
            }
        }
        
        self.categoriesToShow = newCategoriesToShow
    }
    
    private func updateCompletedTrackersInfo() {
        completedTrackerIdsOnSelectedDate = Set(
            completedTrackers
                .filter { $0.date == selectedDate }
                .map { $0.id }
        )
        
        completedDaysCountByTrackerId = Dictionary(
            grouping: completedTrackers,
            by: { $0.id }
        ).mapValues { $0.count }
    }
    
    // MARK: - Observer Setup
    private func addObservers() {
        storageCategoriesObserver = NotificationCenter.default
            .addObserver(
                forName: Storage.categoriesDidChangeNotification,
                object: nil,
                queue: .main
            ){ [weak self] _ in
                guard let self else { return }
                self.categories = storage.categories
            }
        
        storageCompletedTrackersObserver = NotificationCenter.default
            .addObserver(
                forName: Storage.completedTrackersDidChangeNotification,
                object: nil,
                queue: .main
            ){ [weak self] _ in
                guard let self else { return }
                self.completedTrackers = storage.completedTrackers
            }
    }
    
    // MARK: - Helpers
    private func convertDateToWeekday(_ date: Date) -> Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        
        switch weekdayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return .monday
        }
    }
}

// MARK: - CollectionViewControllerDelegateProtocol
extension TrackersViewController: CollectionViewControllerDelegateProtocol {
    
    func isTrackerCompletedOnSelectedDate(_ tracker: Tracker) -> Bool {
        completedTrackerIdsOnSelectedDate.contains(tracker.id)
    }
    
    func numberOfCompletedDays(for tracker: Tracker) -> Int {
        completedDaysCountByTrackerId[tracker.id] ?? 0
    }
    
    func completeButtonDidTap(tracker: Tracker) {
        guard selectedDate <= Calendar.current.startOfDay(for: Date()) else {
            print("\nℹ️ [TrackersViewController] completeButtonDidTap: попытка отметить трекер в будущую дату")
            return
        }
        
        let trackerRecord = TrackerRecord(
            id: tracker.id,
            date: selectedDate
        )
        
        switch isTrackerCompletedOnSelectedDate(tracker) {
        case true:
            storage.removeCompletedTracker(trackerRecord)
        case false:
            storage.addCompletedTracker(trackerRecord)
        }
    }
}

// MARK: - SearchTextFieldViewControllerDelegateProtocol
extension TrackersViewController: SearchTextFieldViewControllerDelegateProtocol {
    
    func didFinishInputEditing(_ text: String) {
        self.inputText = text
    }
}
