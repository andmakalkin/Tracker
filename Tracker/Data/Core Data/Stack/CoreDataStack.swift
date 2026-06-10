import CoreData
import Foundation

final class CoreDataStack {
    
    // MARK: - Type Properties
    static let shared = CoreDataStack()
    private static let persistentContainerName = "DataModel"
    
    // MARK: - Data
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    private init() {
        persistentContainer = NSPersistentContainer(
            name: Self.persistentContainerName
        )
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("❌ [CoreDataStack] persistentContainer: \(error), \(error.userInfo)")
            }
        }
    }
}
