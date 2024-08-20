//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI
import PhotosUI

struct ItemViewCopy: View {
    
    @State private var viewModel: ViewModel
    @State private var model: Model = Model()
    @State private var isEditing: Bool

    var isAdding: Bool
    
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()

    init(model: Model, isAdding: Bool, isEditing: Bool) {
        self.isEditing = isEditing
        self.isAdding = isAdding
        self.viewModel = ViewModel(selectedModel: isAdding ? Model() : model)
        self.model = self.viewModel.selectedModel
    }

    var body: some View {
        NavigationStack {
    
            
            
            Form {
                if (isEditing == true) {

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
                        Picker("Primary Color", selection: $model.primaryColor) {
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
                        
                        
                        Picker("Item Type", selection: $model.type) {
                            ForEach(viewModel.typeOptions, id: \.self) { option in
                                HStack {
                                    Text("\(option)")
                                    Image(systemName: viewModel.typeMap[option] ?? "camera.metering.unknown")
                                }
                            }
                        }
                        
                        Picker("Material", selection: $model.primaryMaterial) {
                            ForEach(viewModel.materialOptions, id: \.self) { material in
                                Text(material)
                            }
                        }
                        
                        Stepper("Item Count: \(model.count)", value: $model.count, in: 0...12, step: 1)
                    }

                } else {
                    HStack {
                        Text("Primary Color: \(model.primaryColor)")
                        Image(systemName: "circle.fill")
                            .foregroundStyle(viewModel.colorMap[model.primaryColor] ?? .black)
                            .overlay(
                                Image(systemName: "circle")
                                    .foregroundColor(.black.opacity(0.5))
                            )
                    }
                    HStack {
                        Text("Item Type: \(model.type)")
                        Image(systemName: viewModel.typeMap[model.type] ?? "camera.metering.unknown")
                    }
                    
                    Text("Material: \(model.primaryMaterial)")
                    
                    Text("Item Count: \(model.count)")
                    
                }
                
                Button("check values") {
                    print("viewModel.typeMap[model.type] = \(String(describing: viewModel.typeMap[model.type]))")
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if (isEditing == true) {
                            HStack {
                                Text(isAdding ? "Adding:" : "Editing:")
                                    .font(.headline)
                                TextField("", text: $model.model_name)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray, lineWidth: 2)
                                    )
                            }
                        } else {
                            HStack {
                                Text("Viewing:")
                                    .font(.headline)
                                Text(model.model_name)
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
            
        
            if (isEditing) {
                HStack {
                    Spacer()
                    Button(isAdding == true ? "Add Item to Inventory" : "Save Item") {
                        // stuff
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.red)
                    .clipShape(Capsule())
                    if (isAdding == false) {
                        Spacer()

                        Button("Add Item to Pull List") {
                            // stuff
                        }
                    }
                    Spacer()
                }
                .padding(.top)
            }
        }
    }
        
}

#Preview {
    ItemViewCopy(model: Model(), isAdding: true, isEditing: true)
}
