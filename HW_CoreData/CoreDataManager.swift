//
//  CoreDataManager.swift
//  HW_CoreData
//
//  Created by Gena on 01.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {

    class var instance: CoreDataManager {
        struct Singleton {
            static let instance = CoreDataManager()
        }
        return Singleton.instance
    }
    
    let coordinator: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let context: NSManagedObjectContext
    var queue: dispatch_queue_t
    
    private override init() {
        let modelURL = NSBundle.mainBundle().URLForResource("HW_CoreData", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let fileManager = NSFileManager.defaultManager()
        let docsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
        let storeURL = docsURL.URLByAppendingPathComponent("HW_CoreData.sqlite")
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: nil)
        if store == nil {
            abort()
        }
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
        
        queue = dispatch_queue_create("CoreData queue", DISPATCH_QUEUE_SERIAL)
        
        super.init()
    }
    
    func save() {
        dispatch_async(queue, { () -> Void in
            var error: NSError?
            if !self.context.save(&error) {
                abort()
            }
        })
    }
    
    //MARK: - Page
    
    func savePage(page: Page) {
        dispatch_async(queue, { () -> Void in
            self.context.insertObject(page)
        })
    }
    
    func deletePage(page: Page) {
        dispatch_async(queue, { () -> Void in
            self.context.deleteObject(page)
        })
    }
    
    func getAllPages(completion: (pages: [Page]) -> ()) {
        dispatch_async(queue, { () -> Void in
            var error: NSError?
            let request = NSFetchRequest(entityName: "Page")
            var results = self.context.executeFetchRequest(request, error: &error)
            
            if let error = error {
                abort()
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(pages: results as [Page])
            })
        })
    }
    
}
