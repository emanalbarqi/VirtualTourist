//
//  DataController.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 24/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()-> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, err) in
            guard err == nil else {
                fatalError((err?.localizedDescription)!)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
