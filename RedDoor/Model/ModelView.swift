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
    
    @State private var viewModel: ViewModel
    @Binding var path: NavigationPath
    @Binding private var isEditing: Bool
    
    @State private var showingDeleteAlert = false
    
//    @State private var images: [UIImage] = []
    @State private var selectedImage: UIImage? = nil
    @State private var isImageFullScreen: Bool = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    

    init(path: Binding<NavigationPath>, model: Model, isEditing: Binding<Bool>) {
        self.viewModel = ViewModel(selectedModel: model)
        self._path = path
        self._isEditing = isEditing
    }

    var body: some View {
        VStack {
            Form {
                Section("Images") {
                    if (isEditing) {
                        AddImagesView(images: $viewModel.images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
                    }
                    ModelImagesView(images: $viewModel.images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: $isEditing)
                }

                Section("Details"){
                    ModelDetailsView(isEditing: $isEditing, viewModel: $viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if isEditing {
                            HStack {
                                Text("Editing:")
                                    .font(.headline)
                                TextField("", text: $viewModel.selectedModel.name)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                Text("Viewing:")
                                    .font(.headline)
                                Text(viewModel.selectedModel.name)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Done" : "Edit") {
                        if (isEditing) { // edit mode -> view mode
                            isEditing = false
                            Task {
                                await viewModel.updateModelUIImagesFirebase(images: viewModel.images)
                                await withCheckedContinuation { continuation in
                                    viewModel.updateModelDataFirebase()
                                    continuation.resume()
                                }
                            }
                        } else { // view mode -> edit mode
                            isEditing = true
                        }
                    }
                    
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
        
            HStack {
                if (isEditing) {
                    Button("Delete Item") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Confirmation"),
                            message: Text("Please confirm if you want to delete this item."),
                            primaryButton: .cancel(Text("Cancel")),
                            secondaryButton: .destructive(Text("Delete")) {
                                Task {
                                    await viewModel.deleteModelFirebase()
                                    path = NavigationPath()
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
        .onAppear {
            viewModel.loadImages()
        }
    
    } // view
    
} // struct
    

                                                    

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}