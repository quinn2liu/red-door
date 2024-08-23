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
    @State private var isEditing = false
    var TESTMODEL = Model()
    @State private var path = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $path) {
                HStack {
                    ZStack {
                        Menu {
                            NavigationLink(destination: AddItemView()) {
                                Text("Add Item")
                                Image(systemName: "plus")
                            }
                            NavigationLink(destination: ScanItemView()) {
                                Text("Scan Item")
                                Image(systemName: "qrcode.viewfinder")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity,  alignment: .topTrailing)
                        
                        Text("Inventory")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom)
                
                InventoryItemLegendView()

                List {
                    ForEach(modelsArray) { model in
                        NavigationLink(value: model) {
                            InventoryItemView(model: model)
                        }
                    }
                }
                .navigationDestination(for: Model.self) { model in
                    ItemView(path: $path, model: model, isEditing: $isEditing)
                }
                .onAppear {
                    viewModel.getInventoryModels { fetchedModels in
                        self.modelsArray = fetchedModels
                    }
                }
                

            }
            .navigationViewStyle(StackNavigationViewStyle())
            .padding(.bottom)
        }
        .onAppear {
            isEditing = false
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
        
}

#Preview {
    InventoryView()
}
