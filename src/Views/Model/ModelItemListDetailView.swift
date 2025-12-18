//
//  ModelItemListDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 9/18/25.
//

import CachedAsyncImage
import SwiftUI

struct ModelItemListDetailView: View {
    @Binding var modelViewModel: ModelViewModel

    @State private var selectedRDImage: RDImage?
    @State private var isImageSelected: Bool = false

    private var model: Model {
        modelViewModel.selectedModel
    }

    var body: some View {
        VStack(spacing: 12) {
            TopBar()

            ModelInformation()

            ForEach(modelViewModel.items, id: \.self) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemListItem(item)
                }
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .overlay(
            ModelRDImageOverlay(selectedRDImage: selectedRDImage,
                                isImageSelected: $isImageSelected)
        )
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: { BackButton() },
            header: { Text(model.name) },
            trailingIcon: { Spacer().frame(24) }
        )
    }

    // MARK: Item List Item

    @ViewBuilder
    private func ItemListItem(_ item: Item) -> some View {
        HStack {
            if let itemImage = item.image, itemImage.imageExists {
                CachedAsyncImage(url: itemImage.imageURL)
            } else {
                Image(systemName: SFSymbols.photoBadgePlus)
            }
            Text(item.id)
            Text(model.type)
            Text(item.attention.description)
        }
    }

    // MARK: Model Information

    @ViewBuilder
    private func ModelInformation() -> some View {
        HStack(spacing: 0) {
            ModelPrimaryImage(
                primaryRDImage: Binding.constant(model.primaryImage),
                selectedRDImage: $selectedRDImage,
                isImageSelected: $isImageSelected,
                isEditing: Binding.constant(false)
            )

            Spacer()

            VStack(spacing: 0) {
                Text("Type: \(model.type)")
                Text("Primary Color: \(model.primaryColor)")
                Text("Primary Material: \(model.primaryMaterial)")
            }
        }
    }
}
