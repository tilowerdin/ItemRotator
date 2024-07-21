//
//  QueueViewVM.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI
import CoreData

extension QueueView {
    
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        
        static let FILTER_RESULTS_KEY = "queueView_filterResults"
        static let AMOUNT_RESULTS_FILTERED = 3
        
        let queueName: String
        
        @Published
        var items: [Item] = []
        
        @Published
        var pace: Double = 0.0
        
        @Published
        var paceItems: Int = 0
        
        @Published
        var paceDays: Int = 0
        
        @Published
        var filterResults = UserDefaults.standard.bool(forKey: FILTER_RESULTS_KEY)
        
        private var fetchedResultsController: NSFetchedResultsController<Item>
        private var context: NSManagedObjectContext
        private let queue: Queue
        
        init(queue: Queue) {
            self.queueName = queue.name!
            self.queue = queue
            self.context = InjectedValues[\.context]
            
            let request = Item.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Item.lastUpdated, ascending: true)
            ]
            request.predicate = NSPredicate(format: "queue = %@", self.queue)
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
  
            super.init()
            
            self.fetchedResultsController.delegate = self
            self.refresh()
            
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(notification:)), name: .NSCalendarDayChanged, object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        
        @objc func appDidBecomeActive(notification: Notification) {
            refresh()
        }
        
        func refresh() {
            try? fetchedResultsController.performFetch()
            self.updateQueue()
        }
        
        func addItem(named itemName: String) {
            let item = Item(name: itemName, position: self.items.count, queue: self.queue, context: self.context)
            self.queue.addToItems(item)
            save()
        }
        
        func remove(item: Item) {
            context.delete(item)
            save()
        }
        
        func tapped(item: Item) {
            item.update()
            save()
        }
        
        func save() -> ()? {
            return try? context.save()
        }
        
        func rename(item: Item, to newName: String) {
            if (newName.isEmpty) {
                remove(item: item)
            } else {
                item.rename(to: newName)
            }
            save()
        }
        
        // MARK: - FetchedResultsControllerDelegate
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.updateQueue()
        }
        
        private func updateQueue() {
            self.items = fetchedResultsController.fetchedObjects ?? []
            var optFirstLastUpdated: Date? = nil
            let optIndex = self.items.firstIndex { item in
                optFirstLastUpdated = item.lastUpdated
                return item.lastUpdated != nil
            }
            if let index = optIndex, let firstLastUpdated = optFirstLastUpdated {
                let now: Date = Date()
                paceDays = Calendar.current.numberOfDaysBetween(firstLastUpdated, and: now) + 1
                paceItems = self.items.count - index
                
                var localPace = 0.0
                var lastDayAddition = 0.0
                var lastDay = Calendar.current.startOfDay(for: Date())
                
                for item in self.items {
                    if let lastUpdate = item.lastUpdated {
                        let daysSince = Calendar.current.numberOfDaysBetween(lastUpdate, and: now) + 1
                        let valueToAdd = pow(Double(0.5), Double(daysSince))
                        localPace += valueToAdd
                        let newLastDay = Calendar.current.startOfDay(for: lastUpdate)
                        if lastDay == newLastDay {
                            lastDayAddition += valueToAdd
                        } else if newLastDay < lastDay {
                            lastDay = newLastDay
                            lastDayAddition = valueToAdd
                        }
                    }
                }
                
                localPace += lastDayAddition
                
                pace = localPace
            } else {
                pace = -1.0
            }
        }
        
        func toggleFilterResults() {
            filterResults.toggle()
            UserDefaults.standard.setValue(filterResults, forKey: ViewModel.FILTER_RESULTS_KEY)
        }
    }
    
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
    
    var tomorrow: Date {
        let today = startOfDay(for: Date())
        let nextDay = date(byAdding: .day, value: 1, to: today)
        return nextDay!
    }
}
