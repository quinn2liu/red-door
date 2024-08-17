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
    @State private var isScanItemViewPresented = false
    
    var body: some View {
        NavigationStack {
                List {
                    ForEach(0...30, id: \.self) { id in
                        Text("item \(id)")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button("Add Item", systemImage: "plus") { isAddItemViewPresented = true }
                            
                            Button("Scan Item", systemImage: "qrcode.viewfinder") {
                                isScanItemViewPresented = true
                            }
                        }
                        label: {
                            Label("Options", systemImage: "ellipsis")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Inventory")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .navigationDestination(isPresented: $isAddItemViewPresented) {
                    AddItemView()
                }
                .navigationDestination(isPresented: $isScanItemViewPresented) {
                    ScanItemView()
                }
        }
    }
    
    
    
    
}

#Preview {
    InventoryView()
}
