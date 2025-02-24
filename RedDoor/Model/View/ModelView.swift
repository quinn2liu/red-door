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
    
    // MARK: Environment variables
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ModelViewModel

    // MARK: Image variables
    @State private var selectedImage: UIImage? = nil
    @State private var isImageFullScreen: Bool = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    // MARK: State Variables
    @State private var isEditing: Bool = false
    @State private var items: [Item] = []
    @State private var showingDeleteAlert = false

    // MARK: Initializer
    init(model: Model, editable: Bool = true) {
        self.viewModel = ModelViewModel(selectedModel: model)
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Images") {
                    if isEditing {
                        AddImagesView(images: $viewModel.images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
                    }
                    if !viewModel.images.isEmpty {
                        ModelImagesView(images: $viewModel.images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: isEditing)
                    } else {
                        Text("No Images")
                    }
                }
                
                Section("Details") {
                    ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
                }
                Section("Items") {
                    ItemListView(items: items, isEditing: isEditing, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ModelNameView()
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveModel()
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            HStack {
                if isEditing {
                    Button("Delete Model") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Confirm Delete"),
                            primaryButton: .cancel(Text("Cancel")),
                            secondaryButton: .destructive(Text("Delete")) {
                                Task {
                                    await viewModel.deleteModelFirebase()
                                    dismiss()
                                }
                            }
                        )
                    }
                } else {
                    Button("Add Item to Pull List") { }
                }
            }.padding(.top)
        }
        .overlay(
            ModelImageOverlay(selectedImage: selectedImage, isImageFullScreen: $isImageFullScreen)
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
        .onAppear {
            getInitialData()
        }
    }
    
    // MARK: ModelNameView()
    @ViewBuilder private func ModelNameView() -> some View {
        if isEditing {
            HStack {
                Text("Editing:")
                    .font(.headline)
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
    
    // MARK: saveModel()
    private func saveModel() {

        if isEditing {
            isEditing = false
            Task {
                await viewModel.updateModelUIImagesFirebase(images: viewModel.images)
                await withCheckedContinuation { continuation in
                    viewModel.updateModelDataFirebase()
                    continuation.resume()
                }
                viewModel.loadImages()
                viewModel.getModelItems { result in
                    switch result {
                    case .success(let items):
                        self.items = items
                    case .failure(let error):
                        print("Error fetching items: \(error)")
                    }
                }
            }
        } else {
            isEditing = true
        }
    }
    
    private func getInitialData() {
        viewModel.loadImages()
        viewModel.getModelItems { result in
            switch result {
            case .success(let items):
                self.items = items
            case .failure(let error):
                print("Error fetching items: \(error)")
            }
        }
    }
} // struct

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}
