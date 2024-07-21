//
//  Queue+CoreDataClass.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//
//

import Foundation
import CoreData

@objc(Queue)
public class Queue: NSManagedObject {

    convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
    
}
