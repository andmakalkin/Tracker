import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Type Properties
    static let shared = CoreDataStack()
    
    // MARK: - State
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    private init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("❌ [CoreDataStack] persistentContainer: \(error), \(error.userInfo)")
            }
        }
    }
}
