import UIKit

final class CollectionViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: CollectionViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Data
    var sectionsToShow = [TrackerSection]()
    
    // MARK: - Configuration
    private let interitemSpacing: CGFloat = 9
    private let contentInset = UIEdgeInsets(
        top: 24,
        left: 16,
        bottom: 24,
        right: 16
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .clear
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier
        )
        
        collectionView.register(
            CollectionViewControllerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewControllerSupplementaryView.reuseIdentifier
        )
        
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
        ])
        
        collectionView.contentInset = contentInset
    }
    
    // MARK: - Public Methods
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    // MARK: - Cell Configuration
    private func configureCell(_ cell: CollectionViewCell, indexPath: IndexPath) {
        guard let delegate else { return }
        
        let tracker = sectionsToShow[indexPath.section].trackers[indexPath.row]
        let isCompleted = delegate.isTrackerCompletedOnSelectedDate(tracker)
        let isPinned = delegate.isTrackerPinnedOnSelectedDate(tracker)
        let counterText = delegate.completedDaysText(for: tracker)
        
        cell.configure(
            title: tracker.title,
            emoji: tracker.emoji,
            counterText: counterText,
            color: tracker.color,
            isCompleted: isCompleted,
            isPinned: isPinned
        )
    }
    
    // MARK: - Context Menu Configuration
    private func makeMenuActions(for indexPath: IndexPath) -> UIMenu {
        let tracker = sectionsToShow[indexPath.section].trackers[indexPath.row]
        
        let sectionKind = sectionsToShow[indexPath.section].kind
        let pinActionTitle = sectionKind == .pinned ? "Открепить" : "Закрепить"
        
        let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapPin(tracker: tracker)
        }
        
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapEdit(tracker: tracker)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapDelete(tracker: tracker)
        }
        
        return UIMenu(children: [pinAction, editAction, deleteAction])
    }
    
    private func makeTargetedPreview(for cell: CollectionViewCell) -> UITargetedPreview? {
        let targetView = cell.returnPreview()
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = targetView.backgroundColor ?? .clear

        return UITargetedPreview(view: targetView, parameters: parameters)
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionsToShow.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sectionsToShow[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? CollectionViewCell else {
            print("\n❌ [CollectionViewController] cellForItemAt: не удалось получить CollectionViewCell")
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionViewControllerSupplementaryView.reuseIdentifier,
            for: indexPath
        ) as? CollectionViewControllerSupplementaryView else {
            print("\n❌ [CollectionViewController] viewForSupplementaryElementOfKind: не удалось получить CollectionViewControllerSupplementaryView")
            return UICollectionReusableView()
        }
        
        view.configure(title: sectionsToShow[indexPath.section].title)
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 24,
            right: 0
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 19)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: (collectionView.bounds.width - interitemSpacing - contentInset.left - contentInset.right) / 2,
            height: 140
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        interitemSpacing
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        
        let configuration = UIContextMenuConfiguration(
            actionProvider: { [weak self] _ in
                self?.makeMenuActions(for: indexPath)
            }
        )
        
        return configuration
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(
            at: indexPath
        ) as? CollectionViewCell else {
            return nil
        }
        
        return makeTargetedPreview(for: cell)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(
            at: indexPath
        ) as? CollectionViewCell else {
            return nil
        }
        
        return makeTargetedPreview(for: cell)
    }
}

// MARK: - CollectionViewCellDelegateProtocol
extension CollectionViewController: CollectionViewCellDelegateProtocol {
    
    func completeButtonDidTap(cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            print("\n❌ [CollectionViewController] completeButtonDidTap: не удалось получить indexPath для ячейки")
            return
        }
        
        let tracker = sectionsToShow[indexPath.section].trackers[indexPath.row]
        
        delegate?.completeButtonDidTap(tracker: tracker)
    }
}
