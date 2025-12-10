import SwiftUI

struct AddressSheet: View {
    @Binding var selectedAddress: Address
    @State private var selectedAddressMode: String = "Search"
    let addressOptions = ["Search", "Entry"]

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
                    AddressSearchView($selectedAddress)
                } else {
                    AddressEntryView($selectedAddress)
                }
            }
        }
        .frameTop()
        .frameVerticalPadding()
        .frameHorizontalPadding()
    }
}