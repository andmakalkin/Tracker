import UIKit

final class TableViewController: UIViewController {
    
    // MARK: - Types
    enum RenderMode {
        case addingTrackerViewController
        case addingScheduleViewController
        case addingCategoryViewController
    }
    
    // MARK: - Delegate
    weak var delegate: TableViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var tableView = UITableView()
    
    // MARK: - Data
    var titlesAndDescriptions: [(String, String?)] {
        didSet {
            updateTableViewHeight()
            tableView.reloadData()
        }
    }
    
    // MARK: - Configuration
    private let renderMode: RenderMode
    private let cellHeight: CGFloat = 75
    private var numberOfRows: Int { titlesAndDescriptions.count }
    
    // MARK: - State
    private var switchStates: [Bool]?
    private var selectedIndexPath: IndexPath?
    private var contextMenuIndexPath: IndexPath?
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(renderMode: RenderMode, titlesAndDescriptions: [(String, String?)]) {
        self.renderMode = renderMode
        self.titlesAndDescriptions = titlesAndDescriptions
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(renderMode: RenderMode, titles: [String], switchStates: [Bool]) {
        self.renderMode = renderMode
        self.titlesAndDescriptions = titles.map { ($0, nil) }
        self.switchStates = switchStates
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(renderMode: RenderMode, titles: [String]) {
        self.renderMode = renderMode
        self.titlesAndDescriptions = titles.map { ($0, nil) }
        
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
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        heightConstraint = view.heightAnchor.constraint(
            equalToConstant: CGFloat(numberOfRows) * cellHeight
        )
        
        guard let heightConstraint else { return }
        
        NSLayoutConstraint.activate([
            heightConstraint,
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
    
    // MARK: - Public Methods
    func setSelectedIndex(for index: Int?) {
        selectedIndexPath = index.map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.reloadData()
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
            let switchState = switchStates?.indices.contains(indexPath.row) == true
                ? switchStates?[indexPath.row] ?? false
                : false

            return TableViewControllerCell.Model(
                title: item.0,
                description: nil,
                accessory: .switcher(isOn: switchState)
            )
            
        case .addingCategoryViewController:
            return TableViewControllerCell.Model(
                title: item.0,
                description: nil,
                accessory: .select(isOn: selectedIndexPath == indexPath)
            )
        }
    }
    
    // MARK: - Context Menu Configuration
    private func makeMenuActions(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapEdit(at: indexPath.row)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapDelete(at: indexPath.row)
        }
        
        return UIMenu(children: [editAction, deleteAction])
    }
    
    private func makeTargetedPreview(for cell: TableViewControllerCell) -> UITargetedPreview? {
        let targetView = cell.returnPreview()
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = targetView.backgroundColor ?? .clear
        
        return UITargetedPreview(
            view: targetView,
            parameters: parameters
        )
    }
    
    // MARK: - Helpers
    private func updateTableViewHeight() {
        let newHeight = CGFloat(numberOfRows) * cellHeight
        heightConstraint?.constant = newHeight
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
        didSelectRowAt indexPath: IndexPath
    ) {
        switch renderMode {
        case .addingTrackerViewController:
            let title = titlesAndDescriptions[indexPath.row].0
            delegate?.didSelectRowAt(indexPath.row, title: title)
            
        case .addingScheduleViewController:
            return
            
        case .addingCategoryViewController:
            let oldSelectedIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            
            var indexPathsToReload = [indexPath]
            
            if let oldSelectedIndexPath,
               oldSelectedIndexPath != indexPath {
                indexPathsToReload.append(oldSelectedIndexPath)
            }
            
            UIView.performWithoutAnimation {
                tableView.reloadRows(at: indexPathsToReload, with: .none)
            }
            
            let title = titlesAndDescriptions[indexPath.row].0
            delegate?.didSelectRowAt(indexPath.row, title: title)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard renderMode == .addingCategoryViewController else { return nil }
        
        contextMenuIndexPath = indexPath
        
        return UIContextMenuConfiguration(
            actionProvider: { [weak self] _ in
                self?.makeMenuActions(for: indexPath)
            }
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let contextMenuIndexPath,
              let cell = tableView.cellForRow(
                at: contextMenuIndexPath
              ) as? TableViewControllerCell else {
            return nil
        }
        
        return makeTargetedPreview(for: cell)
    }
    
    func tableView(
        _ tableView: UITableView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let contextMenuIndexPath,
              let cell = tableView.cellForRow(
                at: contextMenuIndexPath
              ) as? TableViewControllerCell else {
            return nil
        }
        
        return makeTargetedPreview(for: cell)
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
            print(
                "❌ [TableViewController] cellForRowAt: "
                + "не удалось получить TableViewControllerCell"
            )
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        let model = makeCellModel(for: indexPath)
        cell.configure(with: model)
        
        let isLastRow = indexPath.row == numberOfRows - 1
        cell.setSeparatorHidden(isLastRow)
        
        return cell
    }
}

// MARK: - TableViewControllerCellDelegateProtocol
extension TableViewController: TableViewControllerCellDelegateProtocol {
    
    func didChangeSwitcherValue(at cell: TableViewControllerCell, newValue: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print(
                "❌ [TableViewController] didChangeSwitcherValue: "
                + "не удалось получить indexPath для ячейки"
            )
            return
        }
        
        switchStates?[indexPath.row] = newValue
        
        delegate?.didChangeSwitcherValueAt(
            row: indexPath.row,
            newValue: newValue
        )
    }
}
