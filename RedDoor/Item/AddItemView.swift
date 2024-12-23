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

    @State private var isImagePickerPresented = false
    @State private var images: [UIImage] = [] // Array to store multiple images
    @State private var sourceType: UIImagePickerController.SourceType?
    
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen: Bool = false
    @State private var isEditing: Bool = true
    
    var body: some View {
    
        VStack {
            Form {
                Section(header: Text("Images")) {
                    
                    VStack {
                        HStack {
                            
                            HStack {
                                Image(systemName: "photo")
                                Text("Album")
                            }
                            .transparentButtonStyle(backgroundColor: .clear, foregroundColor: .blue)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .onTapGesture {
                                sourceType = .photoLibrary
                                isImagePickerPresented = true
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "camera")
                                Text("Camera")
                            }
                            .transparentButtonStyle(backgroundColor: .clear, foregroundColor: .gray)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onTapGesture {
                                
                                sourceType = .camera
                                isImagePickerPresented = true
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                            
                        if (!images.isEmpty) {
                            AddedImagesView(images: $images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: $isEditing)
                                .padding(.top, 8)
                        }
                    }
                }
                    
                Section(header: Text("Options")) {
                    Picker("Primary Color", selection: $viewModel.selectedModel.primaryColor) {
                        ForEach(viewModel.colorOptions, id: \.self) { option in
                            HStack {
                                Text(option)
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(viewModel.colorMap[option] ?? .black)
                                    .overlay(
                                        Image(systemName: "circle")
                                            .foregroundColor(.black.opacity(0.5))
                                    )
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                        
                        
                    Picker("Item Type", selection: $viewModel.selectedModel.type) {
                        ForEach(viewModel.typeOptions, id: \.self) { option in
                            HStack {
                                Text("\(option)")
                                Image(systemName: viewModel.typeMap[option] ?? "camera.metering.unknown")
                            }
                        }
                    }
                            
                    Picker("Material", selection: $viewModel.selectedModel.primaryMaterial) {
                        ForEach(viewModel.materialOptions, id: \.self) { material in
                            Text(material)
                        }
                    }
                    
                    Stepper("Item Count: \(viewModel.selectedModel.count)", value: $viewModel.selectedModel.count, in: 1...100, step: 1)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextField("Item Name", text: $viewModel.selectedModel.name)
                    .padding(6)
                    .foregroundStyle(isImageFullScreen ? Color.white : Color.black)
                    .background(isImageFullScreen ? Color.black.opacity(0.0) : Color(.systemGray5))
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
