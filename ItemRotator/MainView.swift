//
//  ContentView.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

struct MainView: View {

    private let eventPublisher: Publisher = InjectedValues[\.uiEventPublisher]
    
    @ObservedObject
    private var viewModel = ViewModel()
    @State
    private var newQueueName: String = ""
    @FocusState
    private var textFieldFocused: Bool
    @State
    private var selectedQueue: Queue?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.queues, id: \.id) { queue in
                        ListItem(deleteAction: {
                            withAnimation {
                                self.viewModel.remove(queue: queue)
                            }
                        }) {
                            Text(queue.name!)
                        }
                        .onTapGesture {
                            eventPublisher.publish(QueueClickedEvent())
                            selectedQueue = queue
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .navigationDestination(item: $selectedQueue, destination: { queue in
                        QueueView(viewModel: QueueView.ViewModel(queue: queue))
                    })
                    
                    ListItem {
                        TextField("Add new queue", text: $newQueueName)
                            .focused($textFieldFocused)
                            .onSubmit() {
                                self.addQueue()
                            }
                    }
                    .onTapGesture {
                        textFieldFocused = true
                    }
                }
                .padding()
            }
            .navigationTitle("Queues")
            .navigationBarTitleDisplayMode(.large)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func addQueue() {
        withAnimation {
            if (newQueueName != "") {
                viewModel.addQueue(named: newQueueName)
                newQueueName = ""
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            if let queueToDelete = offsets.map({ self.viewModel.queues[$0] }).first {
                viewModel.remove(queue: queueToDelete)
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
