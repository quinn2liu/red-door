//
//  ModelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI
import CachedAsyncImage

struct ModelView: View {
    // Environment variables
    @Environment(\.dismiss) private var dismiss
    
    // Data
    @State private var viewModel: ModelViewModel
    @State private var backupModel: Model?
    
    // Presented variables
    @State private var showDeleteAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var isEditingModel: Bool = false
    @State private var showEditingItems: Bool = false
    
    // Image selected variables
    @State private var selectedRDImage: RDImage?
    @State private var isImageSelected: Bool = false
    
    // Initializer
    init(model: Model, editable: Bool = true) {
        self.viewModel = ModelViewModel(model: model)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()
                
                ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditingModel)
                                
                ModelDetailsView(isEditing: isEditingModel, viewModel: $viewModel)
                
                ItemListView()
                
                HStack {
                    if isEditingModel {
                        Button("Delete Model") {
                            showDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .alert(
                            "Confirm Delete",
                            isPresented: $showDeleteAlert
                        ) {
                            Button(role: .destructive) {
                                deleteModel()
                            } label: {
                                Text("Delete")
                            }
                            
                            Button(role: .cancel) {

                            } label: {
                                Text("Cancel")
                            }
                        }
                    } else {
                        Button("Add Item to Pull List") { }
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
        if isEditingModel {
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
                if isEditingModel {
                    Button {
                        if let backup = backupModel {
                            viewModel.selectedModel = backup
                        }
                        isEditingModel = false
                    } label: {
                        Text("Cancel")
                    }
                } else {
                    BackButton()
                }
            },
            header: {
                ModelNameView()
            },
            trailingIcon: {
                Button {
                    if isEditingModel {
                        saveModel()
                        isEditingModel = false
                    } else {
                        backupModel = viewModel.selectedModel
                        isEditingModel = true
                    }
                } label: {
                    Text(isEditingModel ? "Save" : "Edit")
                }
            }
        )
    }

    
    // MARK: - Item List View
    @ViewBuilder
    private func ItemListView() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Item Count: \(viewModel.itemCount)")
                
                Spacer()
                
                Button {
                    showEditingItems = true
                } label: {
                    Text("Edit")
                }
            }
            
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
            if item.image.imageExists {
                CachedAsyncImage(url: item.image.imageURL)
            } else {
                Image(systemName: "photo.badge.plus")
            }
            Text(item.id)
            Text(model.type)
            Text(item.repair.description)
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
