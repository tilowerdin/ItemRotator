//
//  Item+CoreDataClass.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//
//

import Foundation
import CoreData


public class Item: NSManagedObject {

    convenience init(name: String, position: Int, queue: Queue, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.id = UUID().uuidString
        self.position = Int16(position)
        self.queue = queue
    }
    
    public func rename(to newName: String) {
        self.name = newName
    }
    
    public func move(to newPosition: Int) {
        self.position = Int16(newPosition)
    }
    
    public func update() {
        self.lastUpdated = Date()
    }
}
