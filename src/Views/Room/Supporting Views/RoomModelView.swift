//
//  RoomModelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import CachedAsyncImage
import SwiftUI

struct RoomModelView: View {
    // MARK: Environment variables

    @Environment(\.dismiss) private var dismiss
    @State private var modelViewModel: ModelViewModel
    @Binding private var roomViewModel: RoomViewModel

    // MARK: State Variables

    @State private var showingDeleteAlert = false

    // MARK: RD Image Refactor

    @State private var selectedRDImage: RDImage? = nil
    @State private var isImageSelected: Bool = false

    // MARK: Initializer

    init(model: Model, roomViewModel: Binding<RoomViewModel>) {
        modelViewModel = ModelViewModel(model: model)
        _roomViewModel = roomViewModel
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            ModelImages(model: $modelViewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: .constant(false))

            ModelDetailsView(isEditing: false, viewModel: $modelViewModel)

            // TODO: rename this
            ModelItemList()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ModelNameView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadItems()
        }
        .overlay(
            ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
        )
    }

    // MARK: - ModelNameView()

    @ViewBuilder private func ModelNameView() -> some View {
        HStack {
            Text("Name:")
                .font(.headline)
            Text(modelViewModel.selectedModel.name)
        }
    }

    @ViewBuilder
    private func ModelItemList() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Item Count: \(modelViewModel.itemCount)")
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())

            if !modelViewModel.items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(modelViewModel.items, id: \.self) { item in
                        NavigationLink(destination: RoomItemView(item: item, roomViewModel: $roomViewModel)) {
                            ModelItemListItem(item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func ModelItemListItem(_ item: Item) -> some View {
        let model = modelViewModel.selectedModel

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

    // MARK: loadItems()

    private func loadItems() async {
        do {
            modelViewModel.items = try await modelViewModel.getModelItems()
        } catch {
            print("Error loading model items: \(error.localizedDescription)")
        }
    }
}
