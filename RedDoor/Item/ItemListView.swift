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
    var viewModel: ViewModel
    @State var listExpanded: Bool = false
    
    var body: some View {
        
        if isEditing {
            HStack {
                Image(systemName: "plus")
                Text("Add Item")
            }
            .transparentButtonStyle(backgroundColor: .green, foregroundColor: .green)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                viewModel.createSingleModelItem()
            }
        } else {
            HStack {
                Text("Item Count: \(viewModel.selectedModel.count)")
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
            List {
                ForEach(items, id: \.self) { item in
                    NavigationLink(value: item) {
                        ItemListItemView(item: item, model: viewModel.selectedModel)
                    }
                }
            }
        }
    }
}

//#Preview {
//    ItemListView()
//}
