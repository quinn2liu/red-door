//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI
import CachedAsyncImage

struct ModelView: View {
    
    @State private var viewModel: ModelViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing: Bool = false
    
    @State private var showingDeleteAlert = false
    
    @State private var selectedImage: UIImage? = nil
    @State private var isImageFullScreen: Bool = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var items: [Item] = []
    
    
    init(model: Model) {
        self.viewModel = ModelViewModel(selectedModel: model)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Images") {
                    if (isEditing) {
                        AddImagesView(images: $viewModel.images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
                    }
                    if (!viewModel.images.isEmpty) {
                        ModelImagesView(images: $viewModel.images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: $isEditing)
                    } else {
                        Text("No Images")
                    }
                }
                
                Section("Details"){
                    ModelDetailsView(isEditing: $isEditing, viewModel: $viewModel)
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
                if (isEditing) {
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
//                                    path = NavigationPath()
                                    dismiss()
                                    isEditing = false
                                }
                                
                            }
                        )
                    }
                } else {
                    HStack {
                        Button("Add Item to Pull List") {
                            
                        }
                    }
                }
            }
            .padding(.top) // delete button
            
        } // vstack
        .sheet(isPresented: $isImagePickerPresented) {
            if sourceType == .camera {
                ImagePickerWrapper(
                    images: $viewModel.images,
                    isPresented: $isImagePickerPresented,
                    sourceType: .camera
                )
                .background(Color.black)
            } else {
                ImagePickerWrapper(
                    images: $viewModel.images,
                    isPresented: $isImagePickerPresented,
                    sourceType: .photoLibrary
                )
            }
        }
        .overlay(
            Group {
                if isImageFullScreen, let selectedImage = selectedImage {
                    Color.black.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isImageFullScreen = false
                        }
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
        .onAppear() {
            getInitialData()
        }
        
    } // view
    
    @ViewBuilder
    private func ModelNameView() -> some View {
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
    
    private func saveModel() {
        if (isEditing) { // edit mode -> view mode
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
//                        print("Items for model (\(viewModel.selectedModel.id)) successfully retrieved.")
                    case .failure(let error):
                        print("Error fetching items for model (\(viewModel.selectedModel.id)): \(error)")
                    }
                }
            }
        } else { // view mode -> edit mode
            isEditing = true
        }
    }
    
    private func getInitialData() {
        viewModel.loadImages()
        viewModel.getModelItems { result in
            switch result {
            case .success(let items):
                self.items = items
//                print("Items for model (\(viewModel.selectedModel.id)) successfully retrieved.")
            case .failure(let error):
                print("Error fetching items for model (\(viewModel.selectedModel.id)): \(error)")
            }
        }
    }
    
} // struct




//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}
