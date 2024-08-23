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
    @State private var selectedItems: [PhotosPickerItem] = [PhotosPickerItem]()
    @State private var selectedImages: [String: UIImage] = [:]
    @Environment(\.dismiss) var dismiss

    var body: some View {
    
        Form {
            Section(header: Text("Item Images")) {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if (!selectedImages.isEmpty) {
                                ForEach(Array(selectedImages.keys), id: \.self) { imageName in
                                    if let image = selectedImages[imageName] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .background(Color(.systemGray5))
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    } else {
                                        Text("Unable to load image")
                                        Image("photo.badge.exclamationmark")
                                    }
                                }
                            }
                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
                                Label(selectedItems.count <= 2 ? "Select a photo" : "Edit photos", systemImage: "photo")
                            }
                            .frame(width: 200, height: 200)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.vertical, 10)
                }
                .onChange(of: selectedItems) {
                    Task {
                        selectedImages.removeAll()
                        viewModel.selectedModel.imageIDs = []
                        for (index, photoPickerItem) in selectedItems.enumerated() {
                            if let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
                                if let loadedImage = UIImage(data: data) {
                                    let imageID = viewModel.selectedModel.id.uuidString + "-\(index)"
                                    viewModel.selectedModel.imageIDs.append(imageID)
                                    selectedImages[imageID] = loadedImage
                                    print("imageID: \(imageID)")
                                }
                            }
                        }
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
                    HStack {
                        Text("Adding:")
                            .font(.headline)
                        TextField("", text: $viewModel.selectedModel.name)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
        
            HStack {
                Spacer()
                Button("Add Item to Inventory") {
                    viewModel.updateModelDataFirebase()
                    Task {
                        await viewModel.updateModelImagesFirebase(imageDict: selectedImages)
                    }
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.green)
                .clipShape(Capsule())
                Spacer()
            }
            .padding(.top)
        
        
    }
        
}

#Preview {
    AddItemView()
}
