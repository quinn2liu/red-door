//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI

struct ItemView: View {
    @State private var viewModel = ViewModel()
    @State var mode: EditMode
    @State private var model: Model = Model()
    @State private var modelName: String = ""
    var isAdding: Bool

    var body: some View {
        NavigationStack {
    
            Form {
                TextField("Color", text: $model.color)
                List {
                    ForEach(0...30, id: \.self) { id in
                        Text("item \(id)")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if mode == .active {
                            HStack {
                                Text("Editing:")
                                    .font(.headline)
                                TextField("", text: $modelName)
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
            .environment(\.editMode, $mode)
            .onAppear() {
                modelName = model.model_name
            }
            .onChange(of: mode) { oldMode, newMode  in
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
        model.model_name = modelName
    }
    
}

#Preview {
    ItemView(mode: .active, isAdding: false)
}
