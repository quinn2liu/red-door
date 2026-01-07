//
//  PullListComponents.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/10/25.
//

import SwiftUI

struct RDListTopBar<TrailingIcon: View>: View {
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

struct RDListDetails: View {
    let list: RDList

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            (
                Text("Address: ")
                    .foregroundColor(.red)
                    .bold()
                +
                Text(list.address.formattedAddress)
            )

            (
                Text("Install Date: ")
                    .foregroundColor(.red)
                    .bold()
                +
                Text(list.installDate)
            )

            (
                Text("Uninstall Date: ")
                    .foregroundColor(.red)
                    .bold()
                +
                Text(list.uninstallDate)
            )

            (
                Text("Client: ")
                    .foregroundColor(.red)
                    .bold()
                +
                Text(list.client)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray3), lineWidth: 4)
        )
    }
}