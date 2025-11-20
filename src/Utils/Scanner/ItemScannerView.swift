//
//  ItemScannerView.swift
//  RedDoor
//
//  Created by Quinn Liu on 11/16/25.
//

import SwiftUI
import CodeScanner

struct ItemScannerView: View {

    @Environment(NavigationCoordinator.self) var coordinator
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var scannedItem: Item?

    @State private var item: Item? = Item(modelId: "123", id: "456")
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "SIMULATION_MODEL_ID") { response in
            if case let .success(result) = response {
                let itemId = result.string
                let item = Item(modelId: itemId)
                scannedItem = item
                dismiss()
            }
        }
    }
}

#Preview {
    ItemScannerView(scannedItem: .constant(nil))
}