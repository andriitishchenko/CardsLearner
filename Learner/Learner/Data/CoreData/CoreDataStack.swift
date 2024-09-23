import CoreData
protocol CoreDataStack {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func saveContext() throws
}
