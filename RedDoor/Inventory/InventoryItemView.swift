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
        }
    }
}

#Preview {
    InventoryItemView(model: Model())
}
