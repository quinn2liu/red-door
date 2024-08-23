//
//  InventoryItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/20/24.
//

import SwiftUI

struct InventoryItemView: View {
    
    var model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
       
        HStack {
            Text(model.name)
            Text(model.type)
            Text(model.primaryMaterial)
            Text(model.primaryColor)
            Text(String(model.count))
        }
    }
}

struct InventoryItemLegendView: View {
    var body: some View {
//        ScrollView(.horizontal) {
            HStack {
                Text("Name")
                Spacer()
                Text("Type")
                Spacer()
                Text("Material 1")
                Spacer()
                Text("Color 1")
                Spacer()
                Text("Count")
            }
//        }
        .padding(.horizontal)
//        .background(Color(.systemGray6))
        .foregroundColor(Color(.systemGray))
        Divider()
            .padding(.horizontal)
    }
}

#Preview {
    InventoryItemView(model: Model())
}
