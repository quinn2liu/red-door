//
//  AddressEntryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/22/25.
//

import SwiftUI

struct AddressEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAddress: Address

    @State private var street: String = ""
    @State private var town: String = ""
    @State private var state: String = ""
    @State private var zipcode: String = ""
    @State private var unit: String = ""

    init(_ selectedAddress: Binding<Address>) {
        _selectedAddress = selectedAddress
        street = ""
        town = ""
        state = ""
        zipcode = ""
        unit = ""
    }

    var body: some View {
        VStack(spacing: 8) {
            TextField("Street", text: $street)

            TextField("Town", text: $town)

            Picker("Pick a state", selection: $state) {
                ForEach(states, id: \.self) { state in
                    Text(state)
                }
            }

            TextField("Zipcode", text: $zipcode)

            TextField("Unit", text: $unit)

            Button {
                updateSelectedAddress()
                dismiss()
            } label: {
                Text("Save Address")
            }
        }
    }

    private func updateSelectedAddress() {
//        selectedAddress.street = street
//        selectedAddress.city = town
//        selectedAddress.state = state
//        selectedAddress.zipcode = zipcode
//        if !unit.isEmpty {
//            selectedAddress.unit = unit
//        }
    }

    let states: [String] = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
    ]
}
