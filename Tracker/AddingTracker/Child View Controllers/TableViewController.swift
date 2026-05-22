import UIKit

final class TableViewController: UIViewController {
    
    // MARK: - Types
    enum RenderMode {
        case addingTrackerViewController
        case addingScheduleViewController
    }
    
    // MARK: - Delegate
    weak var delegate: TableViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var tableView = UITableView()
    
    // MARK: - Data
    var titlesAndDescriptions: [(String, String?)] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Configuration
    private let renderMode: RenderMode
    private let cellHeight: CGFloat = 75
    private var numberOfRows: Int { titlesAndDescriptions.count }
    
    // MARK: - State
    private var switchStates: [Bool]
    
    // MARK: - Initialization
    init(renderMode: RenderMode, titlesAndDescriptions: [(String, String?)]) {
        self.renderMode = renderMode
        self.titlesAndDescriptions = titlesAndDescriptions
        self.switchStates = Array(
            repeating: false,
            count: titlesAndDescriptions.count
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(
            TableViewControllerCell.self,
            forCellReuseIdentifier: TableViewControllerCell.reuseIdentifier
        )
        
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypBackground
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(
                equalToConstant: CGFloat(numberOfRows) * cellHeight
            ),
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
        ])
    }
    
    // MARK: - Cell Configuration
    private func makeCellModel(for indexPath: IndexPath) -> TableViewControllerCell.Model {
        let item = titlesAndDescriptions[indexPath.row]
        
        switch renderMode {
        case .addingTrackerViewController:
            return TableViewControllerCell.Model(
                title: item.0,
                description: item.1,
                accessory: .navigation
            )
            
        case .addingScheduleViewController:
            return TableViewControllerCell.Model(
                title: item.0,
                description: nil,
                accessory: .switcher(isOn: switchStates[indexPath.row])
            )
        }
    }
}

// MARK: - UITableViewDelegate
extension TableViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == numberOfRows - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        } else {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard renderMode == .addingTrackerViewController else { return }
        
        let title = titlesAndDescriptions[indexPath.row].0
        delegate?.didSelectRowWith(title: title)
    }
}

// MARK: - UITableViewDataSource
extension TableViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TableViewControllerCell.reuseIdentifier,
            for: indexPath
        ) as? TableViewControllerCell else {
            print("❌ [TableViewController] cellForRowAt: не удалось получить TableViewControllerCell")
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        let model = makeCellModel(for: indexPath)
        cell.configure(with: model)
        
        return cell
    }
}

extension TableViewController: TableViewControllerCellDelegateProtocol {
    
    func didChangeSwitcherValue(at cell: TableViewControllerCell, newValue: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("❌ [TableViewController] didChangeSwitcherValue: не удалось получить indexPath для ячейки")
            return
        }
        
        switchStates[indexPath.row] = newValue
        
        delegate?.didChangeSwitcherValueAt(
            raw: indexPath.row,
            newValue: newValue
        )
    }
}
