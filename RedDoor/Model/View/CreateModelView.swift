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
    
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var images: [UIImage] = []
    
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen: Bool = false
    @State private var isEditing: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
                    
            TopBar()
            
            HStack(spacing: 0) {
                ModelPrimaryImage()
                
                Spacer()
                
                Text("info here")
            }
            
            SecondaryImages()
        
            ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
            
            Stepper("Item Count: \(viewModel.selectedModel.count)", value: $viewModel.selectedModel.count, in: 1...100, step: 1)
                
            RedDoorButton(type: .green, leadingIcon: "plus", text: "Add Model to Inventory", semibold: true) {
                createModel()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerSheetView()
        }
        .ignoresSafeArea(.keyboard)
        .overlay(
            ModelImageOverlay(selectedImage: selectedImage, isImageFullScreen: $isImageFullScreen)
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
        .frameTop()
        .frameHorizontalPadding()
    }
    
    @ViewBuilder private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                BackButton()
            },
            header: {
                ModelNameEntry()
            },
            trailingIcon: {
                
            }
        )
    }
    
    // MARK: Secondary Images
    @ViewBuilder private func SecondaryImages() -> some View {
        AddSecondaryImages(images: $images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
        
        if (!images.isEmpty) {
            ModelImagesView(images: $images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: isEditing)
        }
    }
        
    // MARK: Model Name Entry
    @ViewBuilder private func ModelNameEntry() -> some View {
        TextField("Item Name", text: $viewModel.selectedModel.name)
            .padding(6)
            .background(isImageFullScreen ? Color.clear : Color(.systemGray5))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder private func ImagePickerSheetView() -> some View {
        if sourceType == .camera {
            ModelImagesPickerWrapper(
                images: $images,
                isPresented: $isImagePickerPresented,
                sourceType: .camera
            )
            .background(Color.black)
        } else {
            ModelImagesPickerWrapper(
                images: $images,
                isPresented: $isImagePickerPresented,
                sourceType: .photoLibrary
            )
        }
    }
    
    // TODO: move to model view model
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
