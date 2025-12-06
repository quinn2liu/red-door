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
    @Binding var scannedItemId: String?

    @State private var itemId: String? = nil
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()

            HStack {
                Text("Scan Item")
                Image(systemName: "qrcode")
            }
            .font(.system(.title2, design: .default))
            .bold()
            .foregroundStyle(.red)
            .padding(.top, 16)

            ZStack {
                CodeScannerView(codeTypes: [.qr], simulatedData: "SIMULATION_MODEL_ID") { response in
                    if case let .success(result) = response {
                        let itemId: String = result.string
                        scannedItemId = itemId
                        dismiss()
                    }
                }
            }
            .padding(16)
        }
    }
}