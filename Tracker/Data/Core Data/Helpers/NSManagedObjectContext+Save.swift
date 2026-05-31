import CoreData

extension NSManagedObjectContext {
    func saveContextIfNeeded() throws {
        guard hasChanges else {
            return
        }
        
        do {
            try save()
        } catch {
            rollback()
            print("❌ [NSManagedObjectContext] saveContextIfNeeded: не удалось выполнить сохранение")
            throw error
        }
    }
}
