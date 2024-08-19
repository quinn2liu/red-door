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
    @State var editMode: EditMode
    @State private var model: Model = Model()
    var isAdding: Bool
    
//    @State private var pickerItems = [PhotosPickerItem]()
//    @State private var selectedImages = [Image]()
        
    init(editMode: EditMode, model: Model, isAdding: Bool) {
        if (isAdding == true) {
            self.viewModel = ViewModel(selectedModel: Model())
            self.editMode = editMode
        } else {
            self.viewModel = ViewModel(selectedModel: model)
            self.editMode = editMode
        }
        self.isAdding = isAdding
        self.model = self.viewModel.selectedModel
    }

    var body: some View {
        NavigationStack {
    
            Form {
                TextField("Color", text: $model.color)
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if editMode == .active {
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
                    EditButton()
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $editMode)
            .onAppear() {
//                modelName = model.model_name
            }
            .onChange(of: editMode) { oldMode, newMode  in
                if newMode == .inactive {
                    saveModel()
                }
            }
            
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
    
    func saveModel() {
//        model.model_name = modelName
    }
    
}

#Preview {
    ItemView(editMode: .active, model: Model(), isAdding: true)
}
