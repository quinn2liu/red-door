//
//  ItemDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemDetailView: View {
    
    @State var item: Item
    @Binding var path: NavigationPath
    var viewModel: ViewModel

    init(item: Item, path: Binding<NavigationPath>) {
        self.item = item
        self._path = path
        self.viewModel = ViewModel(selectedItem: item)
    }
    
    var body: some View {
        Text("Item ID: \(item.id)")
        Button("Delete Item") {
            Task {
                await viewModel.deleteItem()
            }
            path.removeLast()
        }
    }
}

//#Preview {
//    ItemDetailView()
//}
