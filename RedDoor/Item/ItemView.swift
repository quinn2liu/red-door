//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI

struct ItemView: View {
    
    @State private var viewModel: ViewModel
    @State private var selectedItems: [PhotosPickerItem] = [PhotosPickerItem]()
    @State private var selectedImages: [String: UIImage] = [:]
    @Binding var path: NavigationPath
    @Binding private var isEditing: Bool
    
    @State private var showingDeleteAlert = false

    init(path: Binding<NavigationPath>, model: Model, isEditing: Binding<Bool>) {
        self.viewModel = ViewModel(selectedModel: model)
        self._path = path
        self._isEditing = isEditing
        self.selectedImages = self.viewModel.getImages()
    }

    var body: some View {
            Form {
                if (isEditing) {
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
                                viewModel.selectedModel.imageURLs = []
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

                } else {
                    
                    
                    
                    HStack {
                        Text("Primary Color: \(viewModel.selectedModel.primaryColor)")
                        Image(systemName: "circle.fill")
                            .foregroundStyle(viewModel.colorMap[viewModel.selectedModel.primaryColor] ?? .black)
                            .overlay(
                                Image(systemName: "circle")
                                    .foregroundColor(.black.opacity(0.5))
                            )
                    }
                    HStack {
                        Text("Item Type: \(viewModel.selectedModel.type)")
                        Image(systemName: viewModel.typeMap[viewModel.selectedModel.type] ?? "camera.metering.unknown")
                    }
                    
                    Text("Material: \(viewModel.selectedModel.primaryMaterial)")
                    
                    Text("Item Count: \(viewModel.selectedModel.count)")
                    
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
                        if (isEditing) {
                            isEditing = false
                            Task {
                                await viewModel.updateModelImagesFirebase(imageDict: selectedImages)
                            }
                            viewModel.updateModelDataFirebase()
                        } else {
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
                    Button("Add Item to Pull List") {
                    
                    }
                }
            }
            .padding(.top)
    }
        
}
                                                    

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}
