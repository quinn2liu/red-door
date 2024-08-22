//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var testModelArray = [Model()]
    @State private var isAdding = false
    @State private var isEditing = false
    var TESTMODEL = Model()
    @State private var path = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $path) {
                HStack {
                    ZStack {
                        Menu {
                            Button(action: {
                                isAdding = true
                                isEditing = true
                                print(isAdding)
                                path.append(Model())
                            }) {
                                HStack {
                                    Text("Add Item")
                                    Image(systemName: "plus")
                                }
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
                
                //            HStack {
                //                Text("Type")
                //                Spacer()
                //                Text("Color 1")
                //            }
                //            .padding(.horizontal, 20)
                //            .padding(.top, 20)
                //            .padding(.bottom, 10)
                //            .background(Color(.systemGray6))
                //            .foregroundColor(Color(.systemGray))
                //            Divider()
                //                .padding(.horizontal)
                
                List {
                    ForEach(testModelArray) { model in
                        NavigationLink(value: model) {
                            InventoryItemView(model: model)
                        }
                    }
                }
                .navigationDestination(for: Model.self) { model in
                    ItemView(path: $path, model: model, isAdding: $isAdding, isEditing: $isEditing)
                }

            }
            .navigationViewStyle(StackNavigationViewStyle())
            .padding(.bottom)
        }
    }
}

#Preview {
    InventoryView()
}
