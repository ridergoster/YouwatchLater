//
//  DataManager.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 06/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject {
    
    public static let shared = DataManager()
    
    public var objectContext: NSManagedObjectContext?
    
    private override init() {
        
        // Load momd
        if let modelURL = Bundle.main.url(forResource: "YouwatchLater", withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOf: modelURL) {
                let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                if let dbURL = FileManager.documentURL(childPath: "YouwatchLater") {
                    print(dbURL)
                    _ = try? persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.persistentStoreCoordinator = persistentStoreCoordinator
                    self.objectContext = context
                }
            }
        }
    }
}
