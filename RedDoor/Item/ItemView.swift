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

    let colorOptions: [(name: String, color: Color)] = [
        ("Black", .black),
        ("White", .white),
        ("Brown", .brown),
        ("Gray", .gray),
        ("Pink", .pink),
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Mint", .mint),
        ("Teal", .teal),
        ("Cyan", .cyan),
        ("Blue", .blue),
        ("Purple", .purple),
        ("Indigo", .indigo)
        
    ]

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
                        ForEach(colorOptions, id: \.name) { option in
                            HStack {
                                Text(option.name)
                                Spacer()
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(option.color)
                                    .overlay(
                                        Image(systemName: "circle")
                                            .foregroundColor(.black.opacity(0.5))
                                    )
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)

                } else {
                    Text("Color: \(model.primaryColor)")
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if (isEditing == true) {
                            HStack {
                                Text("Editing:")
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
                        
                    }
                }
                Spacer()
            }
            .padding(.top)

        }
    }
    
}

#Preview {
    ItemView(model: Model(), isAdding: true, isEditing: true)
}
