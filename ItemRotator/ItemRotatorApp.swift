//
//  ItemRotatorApp.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

@main
struct ItemRotatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
