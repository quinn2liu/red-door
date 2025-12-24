//
//  RDListDocumentListItem.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/24/25.
//

import SwiftUI

struct RDListDocumentListItem: View {
    let list: RDList

    // MARK: Body

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(list.address.getStreetAddress() ?? "")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                (
                    Text(list.listType == .pull_list ? "Install Date: " : "Uninstall Date: ")
                        .foregroundColor(.red)
                    +
                    Text(list.listType == .pull_list ? list.installDate : list.uninstallDate)
                        .foregroundColor(.secondary)
                )

                Text("Client: \(list.client)")
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray5))
        .cornerRadius(6)
        .frame(maxWidth: .infinity) 
    }
}