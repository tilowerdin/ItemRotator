//
//  ListItem.swift
//  ItemRotator
//
//  Created by Tilo Werdin on 31.10.23.
//

import SwiftUI

struct ListItem <Content: View> : View {
    
    @State var offsetX: CGFloat = 0.0
    @State var offsetXAtDragStart: CGFloat = 0.0
    @GestureState private var isDragging: Bool = false
    
    let deleteTopColor = Color(uiColor: UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1))
    let deleteBottomColor = Color(uiColor: UIColor(red: 1, green: 0.0, blue: 0.0, alpha: 1))
    
    var content: () -> Content
    var deleteAction: (() -> ())?
    @State var followDrag: Bool?
    
    init(deleteAction: (() -> ())? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.deleteAction = deleteAction
        resetFollowDrag()
    }
    
    private func resetFollowDrag() {
        self.followDrag = deleteAction == nil ? false : nil
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                content()
                Spacer()
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .contentShape(Rectangle())
            .frame(minHeight: 50)
            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(10)
            .offset(x: offsetX)
            .gesture(DragGesture()
                .updating($isDragging, body: { _, isDragging, _ in
                    isDragging = true
                })
                .onChanged({ gestureValue in
                    if (followDrag == nil) {
                        followDrag = abs(gestureValue.translation.width) > abs(gestureValue.translation.height)
                            && gestureValue.translation.width < -offsetX
                    }
                    
                    if (followDrag == true) {
                        offsetX = offsetXAtDragStart + gestureValue.translation.width
                    }
                }))
            .onChange(of: isDragging) { oldValue, newValue in
                if !newValue {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if (followDrag == true) {
                            if (offsetX < -50.0) {
                                offsetX = -100.0
                            } else {
                                offsetX = 0.0
                            }
                            offsetXAtDragStart = offsetX
                        }
                        
                        resetFollowDrag()
                    }
                }
            }
            
            if (deleteAction != nil) {
                GeometryReader { geometry in
                    ZStack {
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [deleteTopColor, deleteBottomColor]), startPoint: .top, endPoint: .bottom))
                                .frame(width: max(0, -offsetX))
                                .cornerRadius(10.0)
                                .onTapGesture {
                                    deleteAction?()
                                }
                        }
                        HStack {
                            Text("Delete")
                                .lineLimit(1)
                                .padding()
                            Spacer()
                        }
                        .offset(x: geometry.size.width + offsetX)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
    }
}

#Preview {
    ListItem {
        Text("Hello World")
    }
}
