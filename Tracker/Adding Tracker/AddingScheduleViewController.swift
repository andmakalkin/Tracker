import UIKit

final class AddingScheduleViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: AddingScheduleViewControllerDelegateProtocol?
    
    // MARK: - Child View Controllers
    private lazy var tableViewController = TableViewController(
        renderMode: .addingScheduleViewController,
        titlesAndDescriptions: tableTitles
    )
    
    // MARK: - UI Elements
    private lazy var titleLabel = UILabel()
    private lazy var scrollView = UIScrollView()
    private lazy var doneButton = UIButton(type: .custom)
    
    // MARK: - Data
    private let weekdays = [
        "Понедельник",
        "Вторник",
        "Среда",
        "Четверг",
        "Пятница",
        "Суббота",
        "Воскреcенье"
    ]
    
    private var tableTitles: [(String, String?)] {
        weekdays.map { ($0, nil) }
    }
    
    // MARK: - State
    private var schedule: Set<Weekday> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewController.delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypWhite
        
        setupTitleLabel()
        setupDoneButton()
        setupScrollView()
        addChildController(tableViewController)
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Расписание"
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
                equalTo: doneButton.topAnchor,
                constant: -24
            ),
        ])
    }
    
    private func setupDoneButton() {
        doneButton.addTarget(
            self,
            action: #selector(doneButtonDidTap),
            for: .touchUpInside
        )
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = .ypBlack
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
        ])
    }
    
    private func addChildController(_ child: UIViewController) {
        addChild(child)
        scrollView.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            child.view.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            child.view.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            child.view.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            child.view.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
        ])
        
        child.didMove(toParent: self)
    }
    
    // MARK: - Actions
    @objc private func doneButtonDidTap() {
        delegate?.didFinishSelectingSchedule(schedule)
        closeScreen()
    }
    
    // MARK: - Navigation
    private func closeScreen() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableViewControllerDelegateProtocol
extension AddingScheduleViewController: TableViewControllerDelegateProtocol {
    
    func didSelectRowWith(title: String) { }
    
    func didChangeSwitcherValueAt(raw: Int, newValue: Bool) {
        let weekday = Weekday.allCases[raw]
        
        switch newValue {
        case true:
            schedule.insert(weekday)
        case false:
            schedule.remove(weekday)
        }
    }
}
