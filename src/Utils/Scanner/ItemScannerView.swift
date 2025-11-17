//
//  ItemScannerView.swift
//  RedDoor
//
//  Created by Quinn Liu on 11/16/25.
//

import SwiftUI

struct ItemScannerView: View {

    @Environment(NavigationCoordinator.self) var coordinator
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var scannedItem: Item?

    @State private var item: Item? = Item(modelId: "123", id: "456")
    var body: some View {
        VStack(spacing: 16) {
            Text("Item Scanner")
            
            Spacer()

            if let item {
                Button {
                    scannedItem = item
                    dismiss()
                } label: {
                    Text("View Item Details")
                }
            }
        }
        .frameTop()
        .frameHorizontalPadding()
    }
}

#Preview {
    ItemScannerView(scannedItem: .constant(nil))
}