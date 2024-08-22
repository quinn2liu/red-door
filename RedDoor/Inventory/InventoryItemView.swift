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
            Text(model.type)
            Text(model.model_name)
            Text(model.primaryColor)
            Text(model.primaryMaterial)
            Text(String(model.count))
        }
    }
}

#Preview {
    InventoryItemView(model: Model())
}
