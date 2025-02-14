//
//  ItemDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: Item
    var viewModel: ItemViewModel

//    init(item: Item, path: Binding<NavigationPath>) {
//        self.item = item
//        self._path = path
//        self.viewModel = ViewModel(selectedItem: item)
//    }
    
    init(item: Item) {
        self.item = item
        self.viewModel = ItemViewModel(selectedItem: item)
    }
    
    var body: some View {
        Text("Item ID: \(item.id)")
        Button("Delete Item") {
            Task {
                await viewModel.deleteItem()
            }
            dismiss()
        }
    }
}

//#Preview {
//    ItemDetailView()
//}
