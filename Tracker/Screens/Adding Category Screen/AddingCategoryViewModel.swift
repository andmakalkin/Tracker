import Foundation

typealias Binding<T> = (T) -> Void

final class AddingCategoryViewModel {
    
    // MARK: - Binding
    var onCategoriesStateChange: Binding<[TrackerCategory]>?
    var onEmptyStateChange: Binding<Bool>?
    var onSelectedIndexChange: Binding<Int?>?
    
    // MARK: - Dependencies
    private let model: AddingCategoryModel
    
    // MARK: - State
    private var selectedCategory: TrackerCategory?
    
    // MARK: - Initialization
    init(
        selectedCategory: TrackerCategory? = nil,
        model: AddingCategoryModel = AddingCategoryModel()
    ) {
        self.model = model
        self.selectedCategory = selectedCategory
        
        self.model.onDataDidUpdate = { [weak self] in
            self?.loadData()
        }
    }
    
    // MARK: - Public Methods
    func loadData() {
        let categories = model.fetchCategories()
        
        let selectedIndex = categories.firstIndex {
            $0.categoryID == selectedCategory?.categoryID
        }
        
        onCategoriesStateChange?(categories)
        onEmptyStateChange?(categories.isEmpty)
        onSelectedIndexChange?(selectedIndex)
    }
    
    func category(at index: Int) -> TrackerCategory? {
        let categories = model.fetchCategories()
        
        guard categories.indices.contains(index) else {
            return nil
        }
        
        return categories[index]
    }
    
    func didTapDeleteCategory(at index: Int) {
        guard let category = category(at: index) else {
            return
        }
        
        if selectedCategory?.categoryID == category.categoryID {
            selectedCategory = nil
        }
        
        model.deleteCategory(category)
    }
    
    func didSelectCategory(at index: Int) -> TrackerCategory? {
        guard let category = category(at: index) else {
            return nil
        }
        
        selectedCategory = category
        
        return category
    }
    
    func makeDeleteCategoryAlertModel(at index: Int) -> AlertModel? {
        guard let category = category(at: index) else {
            return nil
        }
        
        return AlertModel(
            title: "Эта категория точно не нужна?",
            message: nil,
            destructiveButtonText: "Удалить",
            cancelButtonText: "Отменить",
            destructiveCompletion: { [weak self] in
                self?.deleteCategory(category)
            },
            cancelCompletion: nil
        )
    }
    
    // MARK: - Data Updates
    private func deleteCategory(_ category: TrackerCategory) {
        if selectedCategory?.categoryID == category.categoryID {
            selectedCategory = nil
        }
        
        model.deleteCategory(category)
    }
}
