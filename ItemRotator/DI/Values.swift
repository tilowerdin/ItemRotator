//
//  Values.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import Foundation
import CoreData

// MARK: ManagedObjectContext
private struct ManagedObjectContextKey : InjectionKey {
    static var currentValue: NSManagedObjectContext = PersistenceController.shared.container.viewContext
}

extension InjectedValues {
    var context: NSManagedObjectContext {
        get { Self[ManagedObjectContextKey.self] }
        set { Self[ManagedObjectContextKey.self] = newValue }
    }
}

// MARK: UIEventPublisher
private struct UIEventPublisherKey : InjectionKey {
    static var currentValue: Publisher = Publisher()
}

extension InjectedValues {
    var uiEventPublisher: Publisher {
        get { Self[UIEventPublisherKey.self] }
        set { Self[UIEventPublisherKey.self] = newValue }
    }
}
