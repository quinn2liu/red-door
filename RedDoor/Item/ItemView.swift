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
    @State private var model: Model = Model()
    @State private var isEditing: Bool

    var isAdding: Bool

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
                    
                    Picker("Select Color:", selection: $model.primaryColor) {
                        ForEach(viewModel.colorOptions, id: \.self) { option in
                            HStack {
                                Text(option)
                                Spacer()
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

                    
                    Picker("Select Item Type:", selection: $model.type) {
                        ForEach(viewModel.typeOptions, id: \.self) { option in
                            HStack {
                                Text("\(option)")
                                Image(systemName: viewModel.typeMap[option] ?? "camera.metering.unknown")
                            }
                        }
                    }

                } else {
                    HStack {
                        Text("Color: \(model.primaryColor)")
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
                }
                
                Button("check values") {
                    print("viewModel.typeMap[model.type]")
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
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
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
                    .padding(12)
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
    ItemView(model: Model(), isAdding: true, isEditing: true)
}
