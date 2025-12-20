//
//  ItemEditSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/20/25.
//

import SwiftUI

struct ItemEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: ItemViewModel
    @State private var editingItem: Item

    init(viewModel: Binding<ItemViewModel>) {
        _viewModel = viewModel
        editingItem = viewModel.selectedItem.wrappedValue
    }

    var body: some View {
        VStack(spacing: 16) {
            RDButton(variant: .red, size: .default, leadingIcon: "xmark", fullWidth: false) {
                dismiss()
            }
            ItemImage(itemImage: $viewModel.selectedItem.image, isEditing: true)
            Text("Edit Item")
            Text("Item ID: \(viewModel.selectedItem.id)")
            Text("Model ID: \(viewModel.selectedItem.modelId)")
            Text("List ID: \(viewModel.selectedItem.listId)")
            Text("Attention: \(viewModel.selectedItem.attention.description)")
            Text("Is Available: \(viewModel.selectedItem.isAvailable.description)")
            RDButton(variant: .red, size: .default, leadingIcon: "trash", fullWidth: false) {
                Task {
                    await viewModel.deleteItem()
                }
                dismiss()
            }
        }
    }
}