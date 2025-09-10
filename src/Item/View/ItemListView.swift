//
//  ItemListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/9/25.
//

import SwiftUI

struct ItemListView: View {
    
    var items: [Item]
    var isEditing: Bool
    @State var viewModel: ModelViewModel
    @State var listExpanded: Bool = false
    
    var body: some View {
        
        if isEditing {
            TransparentButton(backgroundColor: .green, foregroundColor: .green, leadingIcon: "plus", text: "Add Item") {
                viewModel.createSingleModelItem()
            }
        } else {
            HStack {
                Text("Item Count: \(viewModel.selectedModel.itemCount)")
                Spacer()
                Image(systemName: listExpanded ? "minus" : "plus")
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                listExpanded.toggle()
            }
          
        }
        
        if !items.isEmpty && listExpanded {
//            List {
            ForEach(items, id: \.self) { item in
                NavigationLink(value: item) {
                    ItemListItemView(item: item, model: viewModel.selectedModel)
                }
            }
//            }
        }
    }
}

//#Preview {
//    ItemListView()
//}
