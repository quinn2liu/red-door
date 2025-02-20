//
//  InventoryLegendView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/18/24.
//

import SwiftUI

struct InventoryLegendView: View {
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
    InventoryLegendView()
}
