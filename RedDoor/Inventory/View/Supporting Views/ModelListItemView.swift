//
//  ModelListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/16/25.
//

import SwiftUI

struct ModelListItemView: View {
    
    var model: Model
    
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

//#Preview {
//    ModelListItemView(model: )
//}
