//
//  Copyright © 2020 Iterable. All rights reserved.
//

import CoreData
import Foundation

enum PersistenceConst {
    static let dataModelFileName = "IterableDataModel"
    static let dataModelExtension = "momd"

    enum Entity {
        enum Task {
            static let name = "IterableTaskManagedObject"
            
            enum Column {
                static let id = "id"
                static let scheduledAt = "scheduledAt"
            }
        }
    }
}

enum PersistentContainerError: Error {
    /// The persistent store failed to load.
    case storeFailedToLoad
}

class PersistentContainer: NSPersistentContainer {
    static var shared: PersistentContainer?
    
    static func initialize() -> PersistentContainer? {
        if shared == nil {
            shared = create()
        }
        return shared
    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return backgroundContext
    }

    private static func create() -> PersistentContainer? {
        guard let managedObjectModel = createManagedObjectModel() else {
            ITBError("Could not initialize managed object model")
            return nil
        }
        let container = PersistentContainer(name: PersistenceConst.dataModelFileName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { desc, error in
            if let error = error {
                ITBError("Unresolved error when creating PersistentContainer: \(error)")
            }
            
            ITBInfo("Successfully loaded persistent store at: \(desc.url?.description ?? "nil")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        
        return container
    }
    
    private static func createManagedObjectModel() -> NSManagedObjectModel? {
        guard let url = dataModelUrl(fromBundles: [Bundle.main, Bundle(for: PersistentContainer.self)]) else {
            ITBError("Could not find \(PersistenceConst.dataModelFileName).\(PersistenceConst.dataModelExtension) in bundle")
            return nil
        }
        ITBInfo("DB Bundle url: \(url)")
        return NSManagedObjectModel(contentsOf: url)
    }
    
    private static func dataModelUrl(fromBundles bundles: [Bundle]) -> URL? {
        bundles.lazy.compactMap(dataModelUrl(fromBundle:)).first
    }
    
    private static func dataModelUrl(fromBundle bundle: Bundle) -> URL? {
        ResourceHelper.url(forResource: PersistenceConst.dataModelFileName,
                           withExtension: PersistenceConst.dataModelExtension,
                           fromBundle: bundle)
    }
}

struct CoreDataPersistenceContextProvider: IterablePersistenceContextProvider {
    init?(dateProvider: DateProviderProtocol = SystemDateProvider()) {
        guard let persistentContainer = PersistentContainer.initialize() else {
            return nil
        }
        self.persistentContainer = persistentContainer
        self.dateProvider = dateProvider
    }
    
    func newBackgroundContext() -> IterablePersistenceContext {
        return CoreDataPersistenceContext(managedObjectContext: persistentContainer.newBackgroundContext(), dateProvider: dateProvider)
    }
    
    func mainQueueContext() -> IterablePersistenceContext {
        return CoreDataPersistenceContext(managedObjectContext: persistentContainer.viewContext, dateProvider: dateProvider)
    }
    
    private let persistentContainer: PersistentContainer
    private let dateProvider: DateProviderProtocol
}

struct CoreDataPersistenceContext: IterablePersistenceContext {
    init(managedObjectContext: NSManagedObjectContext, dateProvider: DateProviderProtocol) {
        self.managedObjectContext = managedObjectContext
        self.dateProvider = dateProvider
    }
    
    func create(task: IterableTask) throws -> IterableTask {
        guard let taskManagedObject = createTaskManagedObject() else {
            throw IterableDBError.general("Could not create task managed object")
        }
        
        PersistenceHelper.copy(from: task, to: taskManagedObject)
        taskManagedObject.createdAt = dateProvider.currentDate
        return PersistenceHelper.task(from: taskManagedObject)
    }
    
    func update(task: IterableTask) throws -> IterableTask {
        guard let taskManagedObject = try findTaskManagedObject(id: task.id) else {
            throw IterableDBError.general("Could not find task to update")
        }
        
        PersistenceHelper.copy(from: task, to: taskManagedObject)
        taskManagedObject.modifiedAt = dateProvider.currentDate
        return PersistenceHelper.task(from: taskManagedObject)
    }
    
    func delete(task: IterableTask) throws {
        try deleteTask(withId: task.id)
    }

    func nextTask() throws -> IterableTask? {
        let taskManagedObjects: [IterableTaskManagedObject] = try CoreDataUtil.findSortedEntities(context: managedObjectContext,
                                                                                                  entity: PersistenceConst.Entity.Task.name,
                                                                                                  column: PersistenceConst.Entity.Task.Column.scheduledAt,
                                                                                                  ascending: true,
                                                                                                  limit: 1)
        return taskManagedObjects.first.map(PersistenceHelper.task(from:))
    }
    
    func findTask(withId id: String) throws -> IterableTask? {
        guard let taskManagedObject = try findTaskManagedObject(id: id) else {
            return nil
        }
        return PersistenceHelper.task(from: taskManagedObject)
    }
    
    func deleteTask(withId id: String) throws {
        guard let taskManagedObject = try findTaskManagedObject(id: id) else {
            return
        }
        managedObjectContext.delete(taskManagedObject)
    }
    
    func findAllTasks() throws -> [IterableTask] {
        let taskManagedObjects: [IterableTaskManagedObject] = try CoreDataUtil.findAll(context: managedObjectContext, entity: PersistenceConst.Entity.Task.name)
        
        return taskManagedObjects.map(PersistenceHelper.task(from:))
    }
    
    func deleteAllTasks() throws {
        let taskManagedObjects: [IterableTaskManagedObject] = try CoreDataUtil.findAll(context: managedObjectContext, entity: PersistenceConst.Entity.Task.name)
        taskManagedObjects.forEach {
            if !$0.isDeleted {
                managedObjectContext.delete($0)
            } else {
                ITBDebug("task already deleted")
            }
        }
    }
    
    func countTasks() throws -> Int {
        return try CoreDataUtil.count(context: managedObjectContext, entity: PersistenceConst.Entity.Task.name)
    }
    
    func save() throws {
        // FIXME: Temporary patch to prevent Objective-C exceptions
        //
        // Core Data throws a recoverable error in NSPersistentContainer's `loadPersistentStores:` method,
        // if you ignore that error, then subsequent calls to `try context.save()` will throw an
        // Objective-C exception which cannot be caught in Swift.
        guard
            let coordinator = managedObjectContext.persistentStoreCoordinator,
            !coordinator.persistentStores.isEmpty
        else {
            throw PersistentContainerError.storeFailedToLoad
        }
        try managedObjectContext.save()
    }
    
    func perform(_ block: @escaping () -> Void) {
        managedObjectContext.perform(block)
    }
    
    func performAndWait(_ block: () -> Void) {
        managedObjectContext.performAndWait(block)
    }
    
    func performAndWait<T>(_ block: () throws -> T) throws -> T {
        try managedObjectContext.performAndWait(block)
    }
    
    private let managedObjectContext: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol
    
    private func findTaskManagedObject(id: String) throws -> IterableTaskManagedObject? {
        try CoreDataUtil.findEntitiyByColumn(context: managedObjectContext, entity: PersistenceConst.Entity.Task.name, columnName: PersistenceConst.Entity.Task.Column.id, columnValue: id)
    }
    
    private func createTaskManagedObject() -> IterableTaskManagedObject? {
        CoreDataUtil.create(context: managedObjectContext, entity: PersistenceConst.Entity.Task.name)
    }
}
