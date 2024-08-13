//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InventoryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Text("Inventory")
            Button("Add Item") {
                viewModel.addItem()
            }
        }
        .navigationTitle("Inventory")
    }
    
}

#Preview {
    InventoryView()
}
