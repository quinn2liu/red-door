//
//  UnstageInstalledListCover.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/13/25.
//

import SwiftUI
import CachedAsyncImage

struct UnstageInstalledListCover: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: InstalledListViewModel

    @State private var unstagedItems: [Item] = []
    @State private var stagedItems: [Item] = []
    @State private var modelsById: [String: Model] = [:]

    init(viewModel: Binding<InstalledListViewModel>) {
        _viewModel = viewModel
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            ScrollView {
                StagedItemList()

                UnstagedItemList()
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .task {
            await loadStagedItems()
            await loadModels()
        }
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: { ExitButton() },
            header: {
                (
                    Text("Unstaging ")
                        .foregroundColor(.red)
                        .bold()
                    +
                    Text(viewModel.selectedList.address.getStreetAddress() ?? "")
                )
            },
            trailingIcon: { Spacer().frame(24) }
        )
    }

    // MARK: Exit Button

    @ViewBuilder
    private func ExitButton() -> some View {
        Button{
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .fontWeight(.bold)
                .frame(24)
                .foregroundColor(.red)
        }
    }

    // MARK: Unstaged Item List

    @ViewBuilder
    private func UnstagedItemList() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unstaged Items")
            .font(.headline)
            .foregroundColor(.red)

            LazyVStack {
                ForEach(unstagedItems, id: \.self) { item in
                    ItemListItem(item)
                }
            }
        }
    }

    // MARK: Staged Item List
    @ViewBuilder
    private func StagedItemList() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Staged Items")
            .font(.headline)
            .foregroundColor(.secondary)

            LazyVStack(spacing: 12) {
                ForEach(stagedItems, id: \.self) { item in
                    ItemListItem(item)
                }
            }
        }
    }
    
    // MARK: Item List Item
    @ViewBuilder
    private func ItemListItem(_ item: Item) -> some View {
        let model: Model? = modelsById[item.modelId]
        HStack(spacing: 8) {
            ItemPreviewImage(item: item, model: model)

            Text(model?.name ?? "No Model Name")

            Spacer()

            Button {
                // TODO: Unstage Item
            } label: {
                Image(systemName:"shippingbox")
                    .fontWeight(.bold)
                    .frame(24)
            }
        }
    }

    // MARK: Item Preview Image

    @ViewBuilder
    private func ItemPreviewImage(item: Item, model: Model? = nil) -> some View {
        Group {
            if item.image.imageExists, let imageURL = item.image.imageURL {
                ItemCachedAsyncImage(imageURL: imageURL)
            } else if let modelImageURL = model?.primaryImage.imageURL {
                ItemCachedAsyncImage(imageURL: modelImageURL)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(32)
        .cornerRadius(8)
    }

    // MARK: Item Cached Async Image

    @ViewBuilder
    private func ItemCachedAsyncImage(imageURL: URL) -> some View {
        CachedAsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()                        
            case .failure:
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            @unknown default:
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            }
        }
    }

    // MARK: Load Staged Items

    @MainActor
    private func loadStagedItems() async {
        for room in viewModel.rooms {
            for itemId in room.itemModelIdMap.keys {
                do {
                    let item = try await Item.getItem(itemId: itemId)
                    stagedItems.append(item)
                } catch {
                    print("Error loading item \(itemId): \(error)")
                }
            }
        }
    }

    // MARK: Load Models

    @MainActor
    private func loadModels() async {
        for item in stagedItems {
            if !modelsById.keys.contains(item.modelId) {
                do {
                    let model = try await Model.getModel(modelId: item.modelId)
                    modelsById[item.modelId] = model
                } catch {
                    print("Error loading model \(item.modelId): \(error)")
                }
            }
        }
    }
}