//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI
import CachedAsyncImage

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
//        self.selectedImagesURLs = model.imageURLDict
    }

    var body: some View {
        VStack {
            Form {
                    if (isEditing) {
                        Section(header: Text("Item Images")) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    
                                    MemoryImageView(selectedImages: selectedImages)

                                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
                                        Label(selectedItems.count <= 2 ? "Select a photo" : "Edit photos", systemImage: "photo")
                                    }
                                    .frame(width: 200, height: 200)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .padding(.vertical, 10)
                            }
                            .onChange(of: selectedItems) {
                                Task {
                                    selectedImages.removeAll()
                                    for (index, photoPickerItem) in selectedItems.enumerated() {
                                        if let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
                                            if let loadedImage = UIImage(data: data) {
                                                let imageID = viewModel.selectedModel.id + "-\(index)"
                                                viewModel.selectedModel.imageIDs.append(imageID)
                                                selectedImages[imageID] = loadedImage
                                                
                                                print("imageID: \(imageID)")
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
        
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if (selectedImages.isEmpty) {
                                    if (!viewModel.selectedModel.imageURLDict.isEmpty) {
                                        CachedImageView(imageURLDict: viewModel.selectedModel.imageURLDict)
                                    } else {
                                        Text("""
                                            No Images
                                            """)
                                            .frame(width: 200, height: 200)
                                            .background(Color(.systemGray5))
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                } else {
                                    MemoryImageView(selectedImages: selectedImages)
                                }
                            }
                        }
                        .padding(.vertical, 10)
        
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
                        if (isEditing) { // edit mode -> view mode
                            isEditing = false
                            selectedImages = [:]
                            Task {
                                await viewModel.updateModelImagesFirebase(imageDict: selectedImages)
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
            
            //
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
                                    try await withThrowingTaskGroup(of: Void.self) { group in
                                        group.addTask {
                                            await viewModel.deleteModelImagesFirebase()
                                        }
                                        group.addTask {
                                            await viewModel.deleteModelFirebase()
                                            
                                        }
                                        try await group.waitForAll()
                                    }
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
                        Spacer()
                        Button("Check values") {
                            viewModel.printViewModelValues()
                        }
                    }
                    
                }
            }
            .padding(.top) // delete button
                
            } // vstack
        
    } // view
    
} // struct
    

                                                    

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}
