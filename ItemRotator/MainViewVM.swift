//
//  MainViewVM.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import Foundation
import CoreData

extension MainView {
    
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        
        @Published
        var queues: [Queue] = []
        
        private var fetchedResultsController: NSFetchedResultsController<Queue>
        private var context: NSManagedObjectContext
        
        override init() {
            self.context = InjectedValues[\.context]
            
            let request = Queue.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
            ]
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            
            super.init()
            
            self.fetchedResultsController.delegate = self
            self.refresh()
        }
        
        func refresh() {
            try? fetchedResultsController.performFetch()
            self.updateQueue()
        }
        
        func addQueue(named queueName: String) {
            let _ = Queue(name: queueName, context: self.context)
            try? context.save()
        }
        
        func remove(queue: Queue) {
            context.delete(queue)
            try? context.save()
        }
        
        // MARK: - FetchedResultsControllerDelegate
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.updateQueue()
        }
        
        private func updateQueue() {
            self.queues = fetchedResultsController.fetchedObjects ?? []
        }
    }
}
