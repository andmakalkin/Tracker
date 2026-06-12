import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Types
    private enum RenderMode {
        case stub
        case searchEmpty
        case content
    }
    
    // MARK: - Dependencies
    private let storage: StorageProtocol
    private var dataProvider: TrackersDataProviderProtocol
    private let filteringService: TrackersFilteringService
    private let alertPresenter: AlertPresenterProtocol
    
    // MARK: - Child View Controllers
    private let searchTextFieldViewController = SearchTextFieldViewController()
    private let collectionViewController = CollectionViewController()
    
    // MARK: - UI Elements
    private lazy var addingTrackerButton = UIButton(type: .custom)
    private lazy var datePicker = UIDatePicker()
    private lazy var titleLabel = UILabel()

    private lazy var containerView = UIView()

    private lazy var stubStackView = UIStackView()
    private lazy var stubImageView = UIImageView()
    private lazy var stubTextLabel = UILabel()

    private lazy var filtersButton = UIButton(type: .custom)
    
    // MARK: - Data
    private var categories = [TrackerCategory]() {
        didSet {
            updateSectionsToShow()
        }
    }
    
    private var completedTrackers = [TrackerRecord]() {
        didSet {
            updateSectionsToShow()
        }
    }
    
    private var pinnedTrackers = [TrackerPin]() {
        didSet {
            updateSectionsToShow()
        }
    }
    
    private var sectionsToShow = [TrackerSection]() {
        didSet {
            collectionViewController.sectionsToShow = sectionsToShow
            updateContentState()
        }
    }
    
    private var pinnedTrackerIDsOnSelectedDate = Set<UUID>()
    private var completedTrackerIDsOnSelectedDate = Set<UUID>()
    private var completedDaysCountByTrackerID = [UUID: Int]()
    
    // MARK: - State
    private var searchText: String = "" {
        didSet {
            updateSectionsToShow()
        }
    }
    
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            updateSectionsToShow()
        }
    }
    
    private var renderMode: RenderMode?
    
    // MARK: - Initialization
    init(
        storage: StorageProtocol,
        dataProvider: TrackersDataProviderProtocol,
        filteringService: TrackersFilteringService = TrackersFilteringService(),
        alertPresenter: AlertPresenterProtocol = AlertPresenter()
    ) {
        self.storage = storage
        self.dataProvider = dataProvider
        self.filteringService = filteringService
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
        
        searchTextFieldViewController.delegate = self
        collectionViewController.delegate = self
        dataProvider.delegate = self
        
        setupView()
        loadDataFromProvider()
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
            ),
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
        
        collectionViewController.sectionsToShow = self.sectionsToShow
        
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
                equalTo: containerView.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
        ])
        
        collectionViewController.didMove(toParent: self)
    }
    
    private func setupStubStackView() {
        stubTextLabel.textColor = .ypBlack
        stubTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
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
        searchTextFieldViewController.hideKeyboard()
    }
    
    @objc private func filtersButtonDidTap() {
        // TODO: filtersButtonDidTap()
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
    
    private func showEditingTrackerScreen(for tracker: Tracker) {
        guard let category = fetchTrackerCategory(for: tracker) else {
            return
        }
        
        let navigationController = UINavigationController()
        let addingTrackerViewController = AddingTrackerViewController(
            tracker: tracker,
            category: category,
            completedDaysText: completedDaysText(for: tracker)
        )
        
        navigationController.viewControllers = [addingTrackerViewController]
        
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.modalTransitionStyle = .coverVertical
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Content State
    private func updateContentState() {
        let newRenderMode = makeRenderMode()
        
        if newRenderMode != renderMode {
            setRenderState(newRenderMode)
        }
        
        if newRenderMode == .content {
            collectionViewController.reloadCollectionView()
        }
    }
    
    private func makeRenderMode() -> RenderMode {
        if !sectionsToShow.isEmpty {
            return .content
        }
        
        let trimmedSearchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        return trimmedSearchText.isEmpty ? .stub : .searchEmpty
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
            
            stubTextLabel.text = "Что будем отслеживать?"
            stubImageView.image = UIImage(resource: .stubTrackers)
            
        case .searchEmpty:
            collectionViewController.view.isHidden = true
            stubStackView.isHidden = false
            filtersButton.isHidden = true
            
            stubTextLabel.text = "Ничего не найдено"
            stubImageView.image = UIImage(resource: .stubSearch)
            
        case .content:
            stubStackView.isHidden = true
            collectionViewController.view.isHidden = false
            filtersButton.isHidden = false
        }
    }
    
    // MARK: - Data Updates
    private func loadDataFromProvider() {
        self.categories = dataProvider.categories
        self.completedTrackers = dataProvider.completedTrackers
        self.pinnedTrackers = dataProvider.pinnedTrackers
    }
    
    private func updateSectionsToShow() {
        completedTrackerIDsOnSelectedDate = filteringService.makeCompletedTrackerIDs(
            from: completedTrackers,
            selectedDate: selectedDate
        )
        
        completedDaysCountByTrackerID = filteringService.makeCompletedDaysCountByTrackerID(
            from: completedTrackers
        )
        
        pinnedTrackerIDsOnSelectedDate = filteringService.makePinnedTrackerIDs(
            from: pinnedTrackers,
            selectedDate: selectedDate
        )
        
        sectionsToShow = filteringService.makeSectionsToShow(
            from: categories,
            completedTrackers: completedTrackers,
            pinnedTrackers: pinnedTrackers,
            selectedDate: selectedDate,
            searchText: searchText
        )
    }
    
    // MARK: - Helpers
    private func fetchTrackerCategory(for tracker: Tracker) -> TrackerCategory? {
        do {
            return try storage.fetchTrackerCategory(for: tracker)
        } catch {
            print("❌ [TrackersViewController] fetchTrackerCategory: \(error)")
            return nil
        }
    }
    
    private func daysText(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 14 {
            return "\(count) дней"
        }
        
        switch remainder10 {
        case 1:
            return "\(count) день"
        case 2...4:
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
    
    private func makeDeleteTrackerAlertModel(for tracker: Tracker) -> AlertModel? {
        AlertModel(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            destructiveButtonText: "Удалить",
            cancelButtonText: "Отменить",
            destructiveCompletion: { [weak self] in
                self?.deleteTracker(tracker: tracker)
            },
            cancelCompletion: nil
        )
    }
    
    private func deleteTracker(tracker: Tracker) {
        do {
            try storage.deleteTracker(tracker)
        } catch {
            print("❌ [TrackersViewController] didTapDelete: \(error)")
        }
    }
}

// MARK: - CollectionViewControllerDelegateProtocol
extension TrackersViewController: CollectionViewControllerDelegateProtocol {
    
    func didTapPin(tracker: Tracker) {
        let trackerPin = TrackerPin(
            trackerID: tracker.id,
            date: selectedDate
        )
        
        do {
            switch isTrackerPinnedOnSelectedDate(tracker) {
            case true:
                try storage.deleteTrackerPin(trackerPin)
            case false:
                try storage.addTrackerPin(trackerPin)
            }
        } catch {
            print("❌ [TrackersViewController] didTapPin: \(error)")
        }
    }
    
    func didTapEdit(tracker: Tracker) {
        showEditingTrackerScreen(for: tracker)
    }
    
    func didTapDelete(tracker: Tracker) {
        guard let alertModel = makeDeleteTrackerAlertModel(for: tracker) else {
            return
        }
        
        alertPresenter.show(
            in: self,
            model: alertModel
        )
    }
    
    func isTrackerCompletedOnSelectedDate(_ tracker: Tracker) -> Bool {
        completedTrackerIDsOnSelectedDate.contains(tracker.id)
    }
    
    func isTrackerPinnedOnSelectedDate(_ tracker: Tracker) -> Bool {
        pinnedTrackerIDsOnSelectedDate.contains(tracker.id)
    }
    
    func completedDaysText(for tracker: Tracker) -> String {
        let completedDays = completedDaysCountByTrackerID[tracker.id] ?? 0
        return daysText(for: completedDays)
    }
    
    func completeButtonDidTap(tracker: Tracker) {
        guard selectedDate <= Calendar.current.startOfDay(for: Date()) else {
            print("\nℹ️ [TrackersViewController] completeButtonDidTap: попытка отметить трекер в будущую дату")
            return
        }
        
        let trackerRecord = TrackerRecord(
            trackerID: tracker.id,
            date: selectedDate
        )
        
        do {
            switch isTrackerCompletedOnSelectedDate(tracker) {
            case true:
                try storage.deleteTrackerRecord(trackerRecord)
            case false:
                try storage.addTrackerRecord(trackerRecord)
            }
        } catch {
            print("❌ [TrackersViewController] completeButtonDidTap: \(error)")
        }
    }
}

// MARK: - SearchTextFieldViewControllerDelegateProtocol
extension TrackersViewController: SearchTextFieldViewControllerDelegateProtocol {
    
    func didFinishInputEditing(_ text: String) {
        guard searchText != text else {
            return
        }
        
        searchText = text
    }
}

// MARK: - TrackersDataProviderDelegateProtocol
extension TrackersViewController: TrackersDataProviderDelegateProtocol {
    
    func categoriesDidUpdate() {
        categories = dataProvider.categories
    }
    
    func completedTrackersDidUpdate() {
        completedTrackers = dataProvider.completedTrackers
    }
    
    func pinnedTrackersDidUpdate() {
        pinnedTrackers = dataProvider.pinnedTrackers
    }
}
