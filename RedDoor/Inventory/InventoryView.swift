//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var isAddItemViewPresented = false
    @State private var isItemViewPresented = false
    @State private var isScanItemViewPresented = false
    
    var TESTMODEL = Model()
    
    // INITIALIZE A NAVIGATION PATH
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        
                        Menu {
                            Button("Add Item", systemImage: "plus") { isAddItemViewPresented = true }
                            
                            Button("Scan Item", systemImage: "qrcode.viewfinder") {
                                isScanItemViewPresented = true
                            }
                        }
                        label: {
                            Label("", systemImage: "ellipsis")
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity,  alignment: .topTrailing)
                        
                        Text("Inventory")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                List {
                    ForEach(0...30, id: \.self) { id in
                        Text("item \(id)")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isAddItemViewPresented) {
                ItemView(editMode: .active, model: TESTMODEL, isAdding: true)
            }
            .navigationDestination(isPresented: $isItemViewPresented) {
                ItemView(editMode: .active, model: TESTMODEL, isAdding: false)
            }
            .navigationDestination(isPresented: $isScanItemViewPresented) {
                ScanItemView()
            }
            .padding(.bottom)
        }
    }
    
    
    
    
}

#Preview {
    InventoryView()
}
