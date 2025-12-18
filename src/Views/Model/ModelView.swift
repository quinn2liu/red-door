//
//  ModelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import CachedAsyncImage
import PhotosUI
import SwiftUI

struct ModelView: View {
    // Environment variables
    @Environment(\.dismiss) private var dismiss

    // Data
    @State private var viewModel: ModelViewModel
    @State private var backupModel: Model?

    // Presented variables
    @State private var showDeleteAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var isEditing: Bool = false
    @State private var showEditingItems: Bool = false

    // Image selected variables
    @State private var selectedRDImage: RDImage?
    @State private var isImageSelected: Bool = false

    // Initializer
    init(model: Model, editable _: Bool = true) {
        viewModel = ModelViewModel(model: model)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()

                ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditing)

                ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)

                ItemListView()

                if isEditing {
                    RDButton(variant: .red, size: .default, leadingIcon: "trash", text: "Delete Model", fullWidth: false) {
                        showDeleteAlert = true
                    }
                    .alert(
                        "Confirm Delete",
                        isPresented: $showDeleteAlert
                    ) {
                        Button(role: .destructive) {
                            deleteModel()
                        } label: {
                            Text("Delete")
                        }

                        Button(role: .cancel) {} label: {
                            Text("Cancel")
                        }
                    }
                    
                }
            }
            .frameTop()
            .frameHorizontalPadding()
            .toolbar(.hidden)
            .sheet(isPresented: $showEditingItems) {
                EditItemsSheet()
            }
            .overlay(
                ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
            )
            .task {
                await loadItems()
            }

            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("Saving Model...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .shadow(radius: 10)
            }
        }
    }

    // MARK: Model Name

    @ViewBuilder
    private func ModelNameView() -> some View {
        if isEditing {
            HStack {
                TextField("", text: $viewModel.selectedModel.name)
                    .padding(6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        } else {
            HStack {
                Text("Name:")
                    .font(.headline)
                Text(viewModel.selectedModel.name)
            }
        }
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                if isEditing {
                    RDButton(variant: .red, size: .icon, leadingIcon: "xmark", iconBold: true, fullWidth: false) {
                        if let backup = backupModel {
                            viewModel.selectedModel = backup
                        }
                        isEditing = false
                    }
                    .clipShape(Circle())
                } else {
                    BackButton()
                }
            },
            header: {
                ModelNameView()
            },
            trailingIcon: {
                RDButton(variant: .red, size: .icon, leadingIcon: isEditing ? "checkmark" : "square.and.pencil", iconBold: true, fullWidth: false) {
                    if isEditing {
                        saveModel()
                        isEditing = false
                    } else {
                        backupModel = viewModel.selectedModel
                        isEditing = true
                    }
                }
                .clipShape(Circle())
            }
        )
    }

    // MARK: - Item List View

    @ViewBuilder
    private func ItemListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Item Count: \(viewModel.itemCount)")

            if !viewModel.items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            ItemListItem(item)
                        }
                    }
                }
            }
        }
    }

    // MARK: Item List Item

    @ViewBuilder
    private func ItemListItem(_ item: Item) -> some View {
        let model = viewModel.selectedModel

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

    // MARK: EditItemsSheet

    // TODO: maybe put this in separate file...?
    @ViewBuilder
    private func EditItemsSheet() -> some View {
        ForEach(viewModel.items, id: \.self) { item in
            ItemListItem(item)
        }
    }

    // MARK: - Helper Functions

    private func saveModel() {
        isLoading = true
        Task {
            await viewModel.updateModel()
            isLoading = false
        }
    }

    private func deleteModel() {
        isLoading = true
        Task {
            await viewModel.deleteModel()
            isLoading = false
            dismiss()
        }
    }

    private func loadItems() async {
        do {
            viewModel.items = try await viewModel.getModelItems()
        } catch {
            print("Error loading model items: \(error.localizedDescription)")
        }
    }
}
