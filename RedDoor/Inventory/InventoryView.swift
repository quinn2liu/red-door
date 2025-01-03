//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var modelsArray: [Model] = []
    @Binding var isEditing: Bool
    var TESTMODEL = Model()
    @State private var path: NavigationPath = NavigationPath()
    @Binding var searchText: String  // Add this
    
    var filteredModels: [Model] {
        if searchText.isEmpty {
            return modelsArray
        } else {
            return modelsArray.filter { model in
                // Modify this based on what properties you want to search
                model.name.localizedCaseInsensitiveContains(searchText)
                // Add other properties as needed
            }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                HStack {
                    ZStack {
                        Menu {
                            NavigationLink(destination: CreateModelView()) {
                                Text("Add Item")
                                Image(systemName: "plus")
                            }
                            NavigationLink(destination: ScanItemView()) {
                                Text("Scan Item")
                                Image(systemName: "qrcode.viewfinder")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .frame(maxWidth: .infinity,  alignment: .topTrailing)
                        .padding(.horizontal)
                        
                        Text("Inventory")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom)
                
                InventoryLegendView()
                
                List {
                    ForEach(filteredModels) { model in
                        NavigationLink(value: model) {
                            InventoryItemListView(model: model)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search inventory")
            }
            .onAppear {
                isEditing = false
                viewModel.getInventoryModels { fetchedModels in
                    self.modelsArray = fetchedModels
                }
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .navigationDestination(for: Model.self) { model in
                ModelView(path: $path, model: model, isEditing: $isEditing)
            }
            
        }
    }
    
}

//#Preview {
//    InventoryView()
//}
