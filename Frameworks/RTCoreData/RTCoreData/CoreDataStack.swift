//
//  CoreDataStack.swift
//
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import CoreData
import UIKit


public func createMainContext(modelStoreName:String, bundles:[Bundle]?) -> NSManagedObjectContext {
    let storeURL = URL.documentsURL.appendingPathComponent(modelStoreName)
    
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {fatalError("model not found")}
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    let options = [NSInferMappingModelAutomaticallyOption:true,
                   NSMigratePersistentStoresAutomaticallyOption: true]
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}

public func createBackgroundContext(modelStoreName:String, bundles:[Bundle]?) -> NSManagedObjectContext {
    let storeURL = URL.documentsURL.appendingPathComponent(modelStoreName)
    
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {fatalError("model not found")}
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    let options = [NSInferMappingModelAutomaticallyOption:true,
                   NSMigratePersistentStoresAutomaticallyOption: true]
    
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}

// Used for testing, data will not persist
public func createInMemoryMainContext(modelStoreName:String, bundles:[Bundle]?) -> NSManagedObjectContext {
    let storeURL = URL.documentsURL.appendingPathComponent(modelStoreName)
    
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {fatalError("model not found")}
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    let options = [NSInferMappingModelAutomaticallyOption:true,
                   NSMigratePersistentStoresAutomaticallyOption: true]
    
    try! psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: storeURL, options: options)
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}

extension URL {
    
    static func temporaryURL() -> URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
    }
    
    static var documentsURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
}

extension NSManagedObjectContext {
    public func insertObject<A:ManagedObject>() -> A where A:ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {fatalError("wrong object type - Type should be \(A.entityName))")}
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block:@escaping ()->()){
        perform { 
            block()
            if self.saveOrRollback() {
                print("Success performing core data changes")
            } else {
                print("Error performing core data changes")
            }
        }
    }
}
