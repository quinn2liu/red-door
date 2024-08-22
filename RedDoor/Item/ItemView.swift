//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI

struct ItemView: View {
    
    @State private var viewModel: ViewModel = ViewModel()
    @State private var selectedImages: [Image] = [Image]()
    @State private var selectedItems: [PhotosPickerItem] = [PhotosPickerItem]()
    @Binding var path: NavigationPath
    
    @Binding private var isAdding: Bool
    @Binding private var isEditing: Bool

    
    init(path: Binding<NavigationPath>, model: Model, isAdding: Binding<Bool>, isEditing: Binding<Bool>) {
        self.viewModel = ViewModel(selectedModel: model)
        self._path = path
        self._isAdding = isAdding
        self._isEditing = isEditing
        if (!self.isAdding) {
            self.selectedImages = self.viewModel.getImages()
        }
    }

    var body: some View {
//        NavigationStack {
    
            Form {
                if (isEditing) {

                    Section(header: Text("Item Images")) {
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    if (!selectedImages.isEmpty) {
                                        ForEach(0..<selectedImages.count, id: \.self) { i in
                                            selectedImages[i]
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 200)
                                                .background(Color(.systemGray5))
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
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

                                for item in selectedItems {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        if let loadedImage = UIImage(data: data) {
                                            selectedImages.append(Image(uiImage: loadedImage))
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
                        if (isEditing) {
                            HStack {
                                Text(isAdding ? "Adding:" : "Editing:")
                                    .font(.headline)
                                TextField("", text: $viewModel.selectedModel.model_name)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                Text("Viewing:")
                                    .font(.headline)
                                Text(viewModel.selectedModel.model_name)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if (!isAdding) {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            
        
            HStack {
                if (isEditing) {
                    Spacer()
                    Button(isAdding ? "Add Item to Inventory" : "Save Item") {
                        viewModel.printViewModelValues()
//                        viewModel.updateModelFirebase()
                        path = NavigationPath()
                        isAdding = false
                        isEditing = false
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.red)
                    .clipShape(Capsule())
                }
               
                if (!isAdding && !isEditing) {
                    Spacer()

                    Button("Add Item to Pull List") {
                        path = NavigationPath()
                        print(path)
                    }
                }
                Spacer()
            }
            .padding(.top)
        
        
    }
        
}

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}
