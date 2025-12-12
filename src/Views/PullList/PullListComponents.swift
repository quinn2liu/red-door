//
//  PullListComponents.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/10/25.
//

import SwiftUI

struct PullListTopBar<TrailingIcon: View>: View {
    @Binding var streetAddress: Address
    @ViewBuilder var trailingIcon: TrailingIcon

    private var status: InstallationStatus

    init(streetAddress: Binding<Address>, trailingIcon: TrailingIcon, status: InstallationStatus) {
        _streetAddress = streetAddress
        self.trailingIcon = trailingIcon
        self.status = status
    }

    var body: some View {
        TopAppBar(
            leadingIcon: { BackButton() },
            header: { 
                (
                    Text("\(status.rawValue.capitalized): ")
                        .foregroundColor(.red)
                        .bold()
                    +
                    Text(streetAddress.getStreetAddress() ?? "")
                )
            },
            trailingIcon: { trailingIcon }
        )
    }
}

struct PullListDetails: View {
    @Binding var installDate: String
    @Binding var client: String

    var body: some View {
        HStack(spacing: 0) {
            Text("Install Date: \(installDate)")

            Spacer()

            Text("Client: \(client)")
        }
    }
}