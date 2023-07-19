//
//  PersistenceManager.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit
import CoreData
import Foundation

/// A generic manager for CoreData
struct PersistenceManager {
    
    /// Singleton instance
    static let shared = PersistenceManager()

    /// Container for CoreData
    let container: NSPersistentContainer

    /// Default init method
    init() {
        container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { _, _ in }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Cache images
    func cacheImage(_ image: UIImage, key: String) {
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        if let existingResult = try? container.viewContext.fetch(fetchRequest).first {
            existingResult.image = image.pngData()
            existingResult.date = Date()
        } else {
            let entity = ImageEntity(context: container.viewContext)
            entity.image = image.pngData()
            entity.date = Date()
            entity.key = key
        }
        try? container.viewContext.save()
    }
    
    /// Fetch cached image
    func cachedImage(forKey key: String) -> UIImage? {
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        if let imageData = try? container.viewContext.fetch(fetchRequest).first?.image {
            return UIImage(data: imageData)
        }
        return nil
    }
}
