import CoreData
import Foundation

final class TrackerCategoryStore {
    
    // MARK: - Types
    private enum TrackerCategoryStoreError: Error {
        case categoryAlreadyExists
    }
    
    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let entityProvider: CoreDataEntityProvider
    private let mapper: CoreDataMapper
    
    // MARK: - Initialization
    init(
        context: NSManagedObjectContext,
        entityProvider: CoreDataEntityProvider? = nil,
        mapper: CoreDataMapper = CoreDataMapper()
    ) {
        self.context = context
        self.entityProvider = entityProvider ?? CoreDataEntityProvider(context: context)
        self.mapper = mapper
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        guard try !categoryExists(
            with: trackerCategory.title,
            excluding: nil
        ) else {
            throw TrackerCategoryStoreError.categoryAlreadyExists
        }
        
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.categoryID = trackerCategory.categoryID
        categoryEntity.title = trackerCategory.title
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerCategoryStore] addTrackerCategory: добавлена новая категория:\n\(trackerCategory.title)")
    }
    
    func deleteTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let categoryEntity = try entityProvider.fetchCategory(
            with: trackerCategory.categoryID
        )
        
        context.delete(categoryEntity)
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerCategoryStore] deleteTrackerCategory: удалена категория:\n\(trackerCategory.title)")
    }
    
    func updateTrackerCategory(
        _ trackerCategory: TrackerCategory,
        newTitle: String
    ) throws {
        guard try !categoryExists(
            with: newTitle,
            excluding: trackerCategory
        ) else {
            throw TrackerCategoryStoreError.categoryAlreadyExists
        }
        
        let categoryEntity = try entityProvider.fetchCategory(
            with: trackerCategory.categoryID
        )
        
        categoryEntity.title = newTitle
        
        try context.saveContextIfNeeded()
        print("\n✅ [TrackerCategoryStore] updateTrackerCategory: название категории изменено на:\n\(newTitle)")
    }
    
    func fetchTrackerCategory(with id: UUID) throws -> TrackerCategory {
        let categoryEntity = try entityProvider.fetchCategory(with: id)
        
        return try mapper.makeTrackerCategory(from: categoryEntity)
    }
    
    func categoryExists(
        with title: String,
        excluding category: TrackerCategory?
    ) throws -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        if let category {
            request.predicate = NSPredicate(
                format: "%K == %@ AND %K != %@",
                #keyPath(TrackerCategoryCoreData.title),
                title,
                #keyPath(TrackerCategoryCoreData.categoryID),
                category.categoryID as CVarArg
            )
        } else {
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCategoryCoreData.title),
                title
            )
        }
        
        request.fetchLimit = 1
        
        let count = try context.count(for: request)
        
        return count > 0
    }
}
