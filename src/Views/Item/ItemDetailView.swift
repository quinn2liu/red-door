//
//  ItemDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemDetailView: View {
    @Environment(NavigationCoordinator.self) var coordinator
    @State private var viewModel: ItemViewModel

    init(item: Item) {
        viewModel = ItemViewModel(selectedItem: item)
    }

    var body: some View {
        Text("Item ID: \(viewModel.selectedItem.id)")
        Button("Delete Item") {
            Task {
                await viewModel.deleteItem()
            }
            coordinator.resetSelectedPath()
        }
    }
}

// #Preview {
//    ItemDetailView()
// }
