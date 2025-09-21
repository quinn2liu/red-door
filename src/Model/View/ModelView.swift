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
    @State private var isEditing: Bool = false

    // Data
    @State private var viewModel: ModelViewModel
    @State private var backupModel: Model?
    
    // Presented variables
    @State private var showDeleteAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var showItemList: Bool = false
    
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
                
                ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditing)
                                
                ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
                
                ItemListView()
                
                HStack {
                    if isEditing {
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
                    Button {
                        if let backup = backupModel {
                            viewModel.selectedModel = backup
                        }
                        isEditing = false
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
                    if isEditing {
                        saveModel()
                        isEditing = false
                    } else {
                        backupModel = viewModel.selectedModel
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Done" : "Edit")
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
                Image(systemName: showItemList ? "minus" : "plus")
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                showItemList.toggle()
            }
            
            if !viewModel.items.isEmpty && showItemList {
                NavigationLink(destination: ModelItemListDetailView(modelViewModel: $viewModel)) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.items, id: \.self) { item in
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
