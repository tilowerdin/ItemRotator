//
//  ItemListItem.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

struct SelfUncheckingCheckBox: View {
    var action: () -> ()
    
    @State private var checked = false
    
    var body: some View {
        ZStack {
            Image(systemName: "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.secondary)
                
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(red: 0, green: 0.3843671083, blue: 0))
                .opacity(checked ? 1 : 0)
                .animation(.easeIn, value: checked)
        }
        .onTapGesture {
            self.checked.toggle()
            action()
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                reset()
            }
        }
        
    }
    
    private func reset() {
        checked = false
    }
}
