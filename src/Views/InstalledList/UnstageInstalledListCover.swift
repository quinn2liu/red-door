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
    @Environment(NavigationCoordinator.self) private var coordinator: NavigationCoordinator
    @Binding var viewModel: InstalledListViewModel

    @State private var unstagedItems: [Item] = []
    @State private var stagedItems: [Item] = []
    @State private var modelsById: [String: Model] = [:]

    @State private var showUnstageSheet: Bool = false
    @State private var selectedItemAndModel: (Item, Model)? = nil

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
            .refreshable {
                stagedItems = []
                unstagedItems = []
                await loadItems()
                await loadModels()
            }
            
            Spacer()

            Footer()
        }
        .sheet(isPresented: $showUnstageSheet) {
            if let selectedItemAndModel {
                UnstageItemSheet(selectedItemAndModel, stagedItems: $stagedItems, unstagedItems: $unstagedItems)
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .task {
            await loadItems()
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
                    Text("Unstaging: ")
                        .foregroundColor(.red)
                        .bold()
                    +
                    Text(viewModel.selectedList.address.getStreetAddress() ?? "")
                )
            },
            trailingIcon: { 
                RDButton(variant: .red, size: .icon, leadingIcon: "arrow.counterclockwise", fullWidth: false) {
                    Task {
                        stagedItems = []
                        unstagedItems = []
                        await loadItems()
                        await loadModels()
                    }
                }
                .clipShape(Circle())
            }
        )
    }

    // MARK: Exit Button

    @ViewBuilder
    private func ExitButton() -> some View {
        RDButton(variant: .red, size: .icon, leadingIcon: "xmark", iconBold: true, fullWidth: false) {
            dismiss()
        }
    }

    // MARK: Unstaged Item List

    @ViewBuilder
    private func UnstagedItemList() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("Items in Warehouse")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()

                Text("(\(unstagedItems.count))")
                    .foregroundColor(.secondary)
            }
            
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
            HStack(spacing: 0) {    
                Text("Staged Items")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("(\(stagedItems.count))")
                    .foregroundColor(.secondary)
            }

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
        if let model = modelsById[item.modelId] {
            HStack(spacing: 8) {
                ItemPreviewImage(item: item, model: model)

                Text(model.name)

                Spacer()

                RDLinkButton(leadingIcon: "shippingbox") {
                    selectedItemAndModel = (item, model)
                    showUnstageSheet = true
                }
            }
        }
    }

    // MARK: Item Preview Image

    @ViewBuilder
    private func ItemPreviewImage(item: Item, model: Model?) -> some View {
        Group {
            if let itemImage = item.image, let imageURL = itemImage.imageURL {
                ItemCachedAsyncImage(imageURL: imageURL)
            } else if let modelImageURL = model?.primaryImage.imageURL {
                ItemCachedAsyncImage(imageURL: modelImageURL)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: SFSymbols.photoBadgeExclamationmarkFill)
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
                        Image(systemName: SFSymbols.photoBadgeExclamationmarkFill)
                            .foregroundColor(.white)
                    )
            @unknown default:
                Color.gray
                    .overlay(
                        Image(systemName: SFSymbols.photoBadgeExclamationmarkFill)
                            .foregroundColor(.white)
                    )
            }
        }
    }

    // MARK: Footer

    @ViewBuilder
    private func Footer() -> some View {
        if stagedItems.isEmpty {
            HStack(spacing: 0) {
                RDButton(variant: .default, text: "Set List as Unstaged", fullWidth: true) {
                    Task {
                        await viewModel.setListAsUnstaged()
                        coordinator.resetSelectedPath()
                    }
                }
            }
        }
    }

    // MARK: Load Items

    @MainActor
    private func loadItems() async {
        for room in viewModel.rooms {
            for itemId in room.itemModelIdMap.keys {
                do {
                    let item = try await Item.getItem(itemId: itemId)
                    if !item.isAvailable {
                        stagedItems.append(item)
                    } else {
                        unstagedItems.append(item)
                    }
                } catch {
                    print("Error loading item \(itemId): \(error)")
                }
            }
        }
    }

    // MARK: Load Models

    @MainActor
    private func loadModels() async {
        for item in unstagedItems + stagedItems {
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