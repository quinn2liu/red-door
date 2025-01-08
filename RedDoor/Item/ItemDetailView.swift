//
//  ItemDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemDetailView: View {
    
    @State var item: Item
    
    var body: some View {
        Text("Item ID: \(item.id)")
    }
}

//#Preview {
//    ItemDetailView()
//}
