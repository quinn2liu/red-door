//
//  ItemListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemListItemView: View {
    var item: Item
    @State var model: Model?
    @State private var errorMessage: String?
    var viewModel: ItemViewModel

    init(item: Item, model: Model) {
        self.item = item
        self.model = model
        viewModel = ItemViewModel(selectedItem: item)
    }

    var body: some View {
        Group {
            if let model {
                HStack {
                    Text(model.name)
                    Text(item.id)
                    Text(model.type)
                    Text(item.repair.description)
                    Text(item.listId)
                }
            } else if let errorMessage {
                HStack {
                    Text("Error:")
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            guard self.model != nil else {
                getItemModel()
                return
            }
        }
    }

    private func getItemModel() {
        viewModel.getItemModel(modelId: item.modelId) { result in
            switch result {
            case let .success(model):
                self.model = model
            case let .failure(error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// #Preview {
//    ItemListItemView()
// }
