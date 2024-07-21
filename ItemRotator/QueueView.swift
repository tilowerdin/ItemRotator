//
//  QueueView.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

let checkAnimation = Animation.easeInOut(duration: 1.5).delay(1.0)
let insertAnimation = Animation.easeInOut(duration: 1.0)

struct QueueView: View, KeyboardReadable {
    
    @ObservedObject
    private var viewModel: ViewModel
    
    @State
    private var newItemName: String = ""
    @FocusState
    private var textFieldFocused: Bool
    @State
    private var isKeyboardOpen = false
    
    private let dateFormatter = DateFormatter()
    
    private func lastUpdatedString(_ date: Date) -> String {
        let daysAgo = Calendar.current.numberOfDaysBetween(date, and: Date())
        return "Last updated: \(dateFormatter.string(from: date)) - \(daysAgo) day\(daysAgo != 1 ? "s" : "") ago"
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .none
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ListItem {
                    TextField("Add new item", text: $newItemName)
                        .focused($textFieldFocused)
                        .onSubmit() {
                            self.addItem()
                        }
                }
                .onTapGesture {
                    textFieldFocused = true
                }
                
                ForEach(viewModel.filterResults
                        && viewModel.items.count > ViewModel.AMOUNT_RESULTS_FILTERED
                        ? viewModel.items[..<ViewModel.AMOUNT_RESULTS_FILTERED]
                        : viewModel.items[..<viewModel.items.count],
                        id: \Item.id) { item in
                    ListItem(deleteAction: {
                        withAnimation {
                            self.viewModel.remove(item: item)
                        }
                    }) {
                        HStack {
                            SelfUncheckingCheckBox(action: {
                                withAnimation(checkAnimation) {
                                    viewModel.tapped(item: item)
                                    hideKeyboard()
                                }
                            })
                            
                            VStack(alignment: .leading, spacing: 2) {
                                EditItemNameTextField(item: item) { newName in
                                    viewModel.rename(item: item, to: newName)
                                }
                                if let lastUpdated = item.lastUpdated {
                                    Text(lastUpdatedString(lastUpdated))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: removeItem)
                
                if viewModel.pace >= 0.0 {
                    Spacer(minLength: 32)
                    Text("Pace: \(viewModel.pace, specifier: "%.2f") - \(viewModel.paceItems) in \(viewModel.paceDays) day\(viewModel.paceDays != 1 ? "s" : "")")
                        .font(.footnote)
                }
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle(viewModel.queueName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            if isKeyboardOpen {
                Button {
                    withAnimation {
                        hideKeyboard()
                    }
                } label: {
                    Text("Done")
                }
            } else {
                Button {
                    withAnimation {
                        viewModel.toggleFilterResults()
                    }
                } label: {
                    Image(systemName: viewModel.filterResults
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
                Button {
                    withAnimation {
                        textFieldFocused = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        })
        .onReceive(keyboardPublisher, perform: { keyboardIsShown in
            withAnimation {
                self.isKeyboardOpen = keyboardIsShown
            }
        })
    }
    
    private func addItem() {
        withAnimation(insertAnimation) {
            if (self.newItemName != "") {
                self.viewModel.addItem(named: newItemName)
                self.newItemName = ""
            }
            textFieldFocused = true
        }
    }
    
    private func removeItem(offsets: IndexSet) {
        withAnimation {
            if let itemToDelete = offsets.map({ self.viewModel.items[$0] }).first {
                self.viewModel.remove(item: itemToDelete)
            }
        }
    }
}

#Preview {
    QueueView(viewModel: QueueView.ViewModel(queue: Queue(name: "Queue", context: PersistenceController.preview.container.viewContext)))
}
