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
    var categoriesToShow = [TrackerCategory]()
    
    // MARK: - Configuration
    private let interitemSpacing: CGFloat = 9
    
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
        
        collectionView.contentInset = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
    }
    
    // MARK: - Public Methods
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    // MARK: - Cell Configuration
    private func configureCell(_ cell: CollectionViewCell, indexPath: IndexPath) {
        guard let delegate else { return }
        
        let tracker = categoriesToShow[indexPath.section].trackers[indexPath.row]
        let isCompleted = delegate.isTrackerCompletedOnSelectedDate(tracker)
        let completedDaysCount = delegate.numberOfCompletedDays(for: tracker)
        let counterText = daysText(for: completedDaysCount)
        
        cell.configure(
            title: tracker.title,
            emoji: tracker.emoji,
            counterText: counterText,
            color: tracker.color,
            isCompleted: isCompleted
        )
    }
    
    // MARK: - Helpers
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
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoriesToShow.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        categoriesToShow[section].trackers.count
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
        
        view.configure(title: categoriesToShow[indexPath.section].title)
        
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
            width: (collectionView.bounds.width - interitemSpacing) / 2,
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

// MARK: - CollectionViewCellDelegateProtocol
extension CollectionViewController: CollectionViewCellDelegateProtocol {
    
    func completeButtonDidTap(cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            print("\n❌ [CollectionViewController] completeButtonDidTap: не удалось получить indexPath для ячейки")
            return
        }
        
        let tracker = categoriesToShow[indexPath.section].trackers[indexPath.row]
        
        delegate?.completeButtonDidTap(tracker: tracker)
    }
}
