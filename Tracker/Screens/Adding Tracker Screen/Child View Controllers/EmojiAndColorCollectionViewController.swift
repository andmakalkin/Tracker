import UIKit

final class EmojiAndColorCollectionViewController: UIViewController {
    
    // MARK: - Types
    private enum RenderMode {
        case emojis
        case colors
    }
    
    private enum CollectionItem {
        case emoji(String)
        case color(UIColor)
    }
    
    // MARK: - Delegate
    weak var delegate: EmojiAndColorCollectionViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Data
    private let collectionItems: [CollectionItem]
    
    // MARK: - Configuration
    private let itemsPerRow = 6
    
    private let horizontalInset: CGFloat = 2
    private let minHorizontalSpacing: CGFloat = 5
    private let referenceItemWidth: CGFloat = 52
    
    private let verticalInset: CGFloat = 24
    private let verticalSpacing: CGFloat = 0
    
    private var itemsCount: Int {
        collectionItems.count
    }
    
    private var horizontalSpacingsCount: CGFloat {
        CGFloat(itemsPerRow - 1)
    }
    
    // MARK: - State
    private let renderMode: RenderMode
    private var selectedIndexPath: IndexPath?
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(emojis: [String], selectedIndex: Int?) {
        self.collectionItems = emojis.map {
            CollectionItem.emoji($0)
        }
        
        if let selectedIndex {
            self.selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        }
        
        self.renderMode = .emojis
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(colors: [UIColor], selectedIndex: Int?) {
        self.collectionItems = colors.map {
            CollectionItem.color($0)
        }
        
        if let selectedIndex {
            self.selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        }
        
        self.renderMode = .colors
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard collectionView.bounds.width > 0 else { return }
        
        let newHeight = calculateCollectionViewHeight()
        
        guard heightConstraint?.constant != newHeight else { return }
        
        heightConstraint?.constant = newHeight
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .clear
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(
            EmojiAndColorCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiAndColorCollectionViewCell.reuseIdentifier
        )
        
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        guard let heightConstraint else { return }
        
        NSLayoutConstraint.activate([
            heightConstraint,
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
    }
    
    // MARK: - Cell Configuration
    private func configureCell(
        _ cell: EmojiAndColorCollectionViewCell,
        indexPath: IndexPath
    ) {
        let collectionItem = collectionItems[indexPath.item]
        let isSelected = indexPath == selectedIndexPath
        
        switch collectionItem {
        case .color(let color):
            cell.configureForColor(color, isSelected: isSelected)
            
        case .emoji(let emoji):
            cell.configureForEmoji(emoji, isSelected: isSelected)
        }
    }
    
    // MARK: - Helpers
    // Используем ширину ячейки по макету — 52,
    // только если при ней спейсинг остаётся не меньше 5.
    // Иначе фиксируем минимальный спейсинг 5
    // и уменьшаем ширину ячейки.
    private func calculateItemSize() -> CGSize {
        let contentWidth = collectionView.bounds.width - horizontalInset * 2
        let minimumSpacingWidth = horizontalSpacingsCount * minHorizontalSpacing
        let referenceItemsWidth = referenceItemWidth * CGFloat(itemsPerRow)
        
        let canUseReferenceItemWidth = referenceItemsWidth + minimumSpacingWidth <= contentWidth
        
        let itemWidth: CGFloat
        
        if canUseReferenceItemWidth {
            itemWidth = referenceItemWidth
        } else {
            itemWidth = (contentWidth - minimumSpacingWidth) / CGFloat(itemsPerRow)
        }
        
        return CGSize(
            width: itemWidth,
            height: itemWidth
        )
    }
    
    private func calculateHorizontalItemsSpacing() -> CGFloat {
        let contentWidth = collectionView.bounds.width - horizontalInset * 2
        let itemWidth = calculateItemSize().width
        let itemsWidth = itemWidth * CGFloat(itemsPerRow)
        let remainingWidth = contentWidth - itemsWidth
        
        let spacing = remainingWidth / horizontalSpacingsCount
        
        // Чтобы не было проблем с округлением.
        let safeSpacing = spacing - 0.5
        
        return max(minHorizontalSpacing, safeSpacing)
    }
    
    private func calculateCollectionViewHeight() -> CGFloat {
        let itemHeight = calculateItemSize().height
        
        let rowsCount = ceil(
            CGFloat(itemsCount) / CGFloat(itemsPerRow)
        )
        
        let totalVerticalSpacing = max(0, rowsCount - 1) * verticalSpacing
        let verticalInsets = verticalInset * 2
        
        return rowsCount * itemHeight + totalVerticalSpacing + verticalInsets
    }
}

// MARK: - UICollectionViewDataSource
extension EmojiAndColorCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        itemsCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiAndColorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiAndColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension EmojiAndColorCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let oldSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        let collectionItem = collectionItems[indexPath.item]
        
        switch collectionItem {
        case .emoji(let emoji):
            delegate?.didSelectEmoji(emoji)
            
        case .color(let color):
            delegate?.didSelectColor(color)
        }
        
        var indexPathsToReload = [indexPath]
        
        if let oldSelectedIndexPath,
           oldSelectedIndexPath != indexPath {
            indexPathsToReload.append(oldSelectedIndexPath)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: indexPathsToReload)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EmojiAndColorCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        calculateItemSize()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        verticalSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        calculateHorizontalItemsSpacing()
    }
}
