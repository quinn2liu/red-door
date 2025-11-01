//
//  AddressSearchView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/21/25.
//

import MapKit
import SwiftUI

struct AddressSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAddress: Address

    @State private var unit: String = ""

    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var cameraPosition: MapCameraPosition = .automatic

    @State private var selectedItem: MKMapItem?

    init(_ selectedAddress: Binding<Address>) {
        _selectedAddress = selectedAddress
        searchText = ""
        searchResults = []
        selectedItem = nil
        cameraPosition = .automatic
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Search address", text: $searchText)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray6), lineWidth: 2)
                )
                .onSubmit {
                    searchAddress(searchText) { results in
                        searchResults = results
                    }
                }

            Map(position: $cameraPosition, selection: $selectedItem) {
                ForEach(searchResults, id: \.self) { item in
                    Marker(item.name ?? "Location", coordinate: item.placemark.coordinate)
                        .tag(item)
                }
            }
            .cornerRadius(8)
            .layoutPriority(searchResults.isEmpty ? 1 : 0)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(searchResults, id: \.self) { result in
                        SearchListItem(result)
                    }
                }
                .padding(2)
            }

            if let item = selectedItem {
                Footer()
            }
        }
    }

    // MARK: Footer

    @ViewBuilder
    private func Footer() -> some View {
        HStack(spacing: 0) {
            if let item = selectedItem {
                TextField("Specify Unit", text: $unit)

                Spacer()

                Button {
                    if let address = convertToAddress(item) {
                        selectedAddress = address
                    }
                    dismiss()
                } label: {
                    Text("Use This Address")
                }
            }
        }
    }

    // MARK: Search List Item

    @ViewBuilder
    private func SearchListItem(_ mapItem: MKMapItem) -> some View {
        let isSelected = mapItem == selectedItem
        Button {
            selectedItem = mapItem
            cameraPosition = .region(MKCoordinateRegion(
                center: mapItem.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(mapItem.name ?? "Unknown Name")
                    .foregroundStyle(.primary)
                Text(formatAddress(mapItem) ?? "Unknown Address")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue.opacity(0.6) : Color(.systemGray6), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Search Address Function

    private func searchAddress(_ searchText: String, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }
            selectedItem = nil
            if let first = searchResults.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            completion(searchResults)
        }
    }

    // MARK: - Placemark Implementation

    private func formatAddress(_ mapItem: MKMapItem) -> String? {
        if #available(iOS 27, *) {
            if let address = mapItem.address {
                return address.fullAddress
            } else {
                return nil
            }
        } else {
            let placemark = mapItem.placemark

            return [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode,
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
        }
    }

    private func convertToAddress(_ mapItem: MKMapItem) -> Address? {
        if #available(iOS 27, *) {
            if let address = mapItem.address {
                return Address(address: address, unit: unit)
            } else {
                return nil
            }
        } else {
            let placemark = mapItem.placemark
            return Address(placemark: placemark)
        }
    }
}
