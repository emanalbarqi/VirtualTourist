//
//  PinAlbumViewController+NSManagedObejectDelegate.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 27/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension PinAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        pinPhotosCollection.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.pinPhotosCollection.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.pinPhotosCollection.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.pinPhotosCollection.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}
