//
//  EditItemNameTextField.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

struct EditItemNameTextField: View {
    
    let item: Item
    let editHandler: (String) -> ()
    @State
    private var name: String
    
    init(item: Item, editHandler: @escaping (String) -> ()) {
        self.item = item
        self.editHandler = editHandler
        self.name = item.name!
    }
    
    var body: some View {
        TextField("Name of the item", text: $name)
            .onSubmit {
                editHandler(name)
            }
    }
}
