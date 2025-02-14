//
//  AddItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/22/24.
//

import SwiftUI
import PhotosUI

struct CreateModelView: View {
    
    @State private var viewModel: ModelViewModel = ModelViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var images: [UIImage] = []
    
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen: Bool = false
    @State private var isEditing: Bool = true
    
    var body: some View {
        
        VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        AddImagesView(images: $images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
                        
                        if (!images.isEmpty) {
                            ModelImagesView(images: $images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: $isEditing)
                        }
                    }
                
                    ModelDetailsView(isEditing: $isEditing, viewModel: $viewModel)
                    
                    Stepper("Item Count: \(viewModel.selectedModel.count)", value: $viewModel.selectedModel.count, in: 1...100, step: 1)
                
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ModelNameEntry()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerSheetView()
            }
            
            
            RedDoorButton(type: .green, leadingIcon: "plus", text: "Add Item to Inventory", semibold: true) {
                createModel()
            }
            
        }
        .ignoresSafeArea(.keyboard)
        .overlay(
            ImageSelectedView()
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
    }
    
    @ViewBuilder private func ModelNameEntry() -> some View {
        TextField("Item Name", text: $viewModel.selectedModel.name)
            .padding(6)
            .background(isImageFullScreen ? Color.clear : Color(.systemGray5))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder private func ImagePickerSheetView() -> some View {
        if sourceType == .camera {
            ImagePickerWrapper(
                images: $images,
                isPresented: $isImagePickerPresented,
                sourceType: .camera
            )
            .background(Color.black)
        } else {
            ImagePickerWrapper(
                images: $images,
                isPresented: $isImagePickerPresented,
                sourceType: .photoLibrary
            )
        }
    }
    
    @ViewBuilder private func ImageSelectedView() -> some View {
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
    
    private func createModel() {
        Task {
            await viewModel.updateModelUIImagesFirebase(images: images)
            await withCheckedContinuation { continuation in
                viewModel.createModelItemsFirebase()
                continuation.resume()
            }
            await withCheckedContinuation { continuation in
                viewModel.updateModelDataFirebase()
                continuation.resume()
            }
        }
        dismiss()
    }
    
}

#Preview {
    CreateModelView()
}
