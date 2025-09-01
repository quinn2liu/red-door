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
    @State private var secondaryImages: [UIImage] = []
    
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen: Bool = false
    @State private var isEditing: Bool = true
    
    @State private var selectedRDImage: RDImage?
    
    var body: some View {
        VStack(spacing: 12) {
                    
            TopBar()
                        
            if !viewModel.selectedModel.primaryImageExists {
                HStack {
                    Spacer()
                    
                    ModelPrimaryImage(primaryRDImage: $viewModel.selectedModel.primaryImage,
                                      selectedRDImage: $selectedRDImage,
                                      selectedUIImage: $selectedImage,
                                      isImageFullScreen: $isImageFullScreen,
                                      isEditing: $isEditing)
                        
                    Spacer()
                }
            } else {
                HStack(spacing: 0) {
                    ModelPrimaryImage(primaryRDImage: $viewModel.selectedModel.primaryImage,
                                      selectedRDImage: $selectedRDImage,
                                      selectedUIImage: $selectedImage,
                                      isImageFullScreen: $isImageFullScreen,
                                      isEditing: $isEditing)
                    
                    Spacer()

                    ModelSecondaryImages(secondaryRDImages: $viewModel.selectedModel.secondaryImages,
                                         selectedRDImage: $selectedRDImage,
                                         isImageFullScreen: $isImageFullScreen,
                                         isEditing: $isEditing)
                }
            }
                    
            ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
            
            Stepper("Item Count: \(viewModel.selectedModel.count)", value: $viewModel.selectedModel.count, in: 1...100, step: 1)
                
            RedDoorButton(type: .green, leadingIcon: "plus", text: "Add Model to Inventory", semibold: true) {
                viewModel.updateModel()
                dismiss()
            }
        }
        .toolbar(.hidden)
        .frameTop()
        .frameHorizontalPadding()
        .ignoresSafeArea(.keyboard)
        .overlay(
            ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageFullScreen: $isImageFullScreen)
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
    }
    
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                BackButton()
            },
            header: {
                ModelNameEntry()
            },
            trailingIcon: {
                Spacer().frame(24)
            }
        )
    }
        
    // MARK: Model Name Entry
    @ViewBuilder
    private func ModelNameEntry() -> some View {
        TextField("Item Name", text: $viewModel.selectedModel.name)
            .padding(6)
            .background(isImageFullScreen ? Color.clear : Color(.systemGray5))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private func ImagePickerSheetView() -> some View {
        if sourceType == .camera {
            ModelImagesPickerWrapper(
                images: $secondaryImages,
                isPresented: $isImagePickerPresented,
                sourceType: .camera
            )
            .background(Color.black)
        } else {
            ModelImagesPickerWrapper(
                images: $secondaryImages,
                isPresented: $isImagePickerPresented,
                sourceType: .photoLibrary
            )
        }
    }
    
    // TODO: move to model view model
    private func createModel() {
        Task {
            await viewModel.updateModelUIImagesFirebase(images: secondaryImages)
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
