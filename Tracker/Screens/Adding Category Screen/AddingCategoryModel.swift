import Foundation

final class AddingCategoryModel {
    
    // MARK: - Binding
    var onDataDidUpdate: (() -> Void)?
    
    // MARK: - Dependencies
    private var dataProvider: TrackersDataProviderProtocol
    private let storage: StorageProtocol
    
    // MARK: - Initialization
    init(
        dataProvider: TrackersDataProviderProtocol = TrackersDataProvider(),
        storage: StorageProtocol = Storage()
    ) {
        self.dataProvider = dataProvider
        self.storage = storage
        
        self.dataProvider.delegate = self
    }
    
    // MARK: - Public Methods
    func fetchCategories() -> [TrackerCategory] {
        dataProvider.categories
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        do {
            try storage.deleteTrackerCategory(category)
        } catch {
            print("❌ [AddingCategoryModel] deleteCategory: не удалось удалить категорию: \(error)")
        }
    }
}

// MARK: - TrackersDataProviderDelegateProtocol
extension AddingCategoryModel: TrackersDataProviderDelegateProtocol {
    
    func categoriesDidUpdate() {
        onDataDidUpdate?()
    }
    
    func pinnedTrackersDidUpdate() { }
    
    func completedTrackersDidUpdate() { }
}
