import SwiftUI

struct AddressSheet: View {
    @Binding var selectedAddress: Address
    @Binding var addressId: String
    @State private var selectedAddressMode: String = "Search"
    let addressOptions = ["Search", "Entry"]

    init(selectedAddress: Binding<Address>, addressId: Binding<String>) {
        _selectedAddress = selectedAddress
        _addressId = addressId
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Capsule()
                .fill(Color(.systemGray3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Picker("Address Mode", selection: $selectedAddressMode) {
                ForEach(addressOptions, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Group {
                if selectedAddressMode == "Search" {
                    AddressSearchView($selectedAddress, addressId: $addressId)
                } else {
                    AddressEntryView($selectedAddress, addressId: $addressId)
                }
            }
        }
        .frameTop()
        .frameVerticalPadding()
        .frameHorizontalPadding()
    }
}