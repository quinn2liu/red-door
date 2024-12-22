//
//  AddItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/22/24.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    
    @State private var viewModel: ViewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var images: [UIImage] = [] // Array to store multiple images
    
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen: Bool = false
    @State private var isEditing: Bool = true
    
    var body: some View {
    
        VStack {
            Form {
                Section(header: Text("Images")) {
                    
                    VStack {
                        AddImagesView(images: $images, isImagePickerPresented: $isImagePickerPresented, sourceType: $sourceType)
                            
                        if (!images.isEmpty) {
                            AddedImagesView(images: $images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: $isEditing)
                                .padding(.top, 8)
                        }
                    }
                }
                    
                Section(header: Text("Options")) {
                    ItemDetailsView(isEditing: $isEditing, viewModel: $viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextField("Item Name", text: $viewModel.selectedModel.name)
                    .padding(6)
                    .background(isImageFullScreen ? Color.clear : Color(.systemGray5))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImagePickerPresented) {
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
        
            HStack {
                Spacer()
                Button("Add Item to Inventory") {
                    Task {
                        await viewModel.updateModelUIImagesFirebase(images: images)
                        await withCheckedContinuation { continuation in
                            viewModel.updateModelDataFirebase()
                            continuation.resume()
                        }
                    }
                    dismiss()
                }
                .transparentButtonStyle(backgroundColor: .green, foregroundColor: .green)
                Spacer()
            }
            .padding(.top)
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
    }
    
    
}

#Preview {
    AddItemView()
}
