//
//  AddressSearchView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/21/25.
//

import SwiftUI
import MapKit

struct AddressSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAddress: Address
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedItem: MKMapItem?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(_ selectedAddress: Binding<Address>) {
        self._selectedAddress = selectedAddress
        self.searchText = ""
        self.searchResults = []
        self.selectedItem = nil
        self.cameraPosition = .automatic
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
                    searchAddress()
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
                Button("Use This Address") {
                    if #available(iOS 26.0, *) {
                        print("Item.address.description: \(item.address?.description)")
                        print("Item.address.fullAddress: \(item.address?.fullAddress)")
                        print("Item.address.shortAddress: \(item.address?.shortAddress)")
                        print("Item.addressRepresentations.fullAddress: \(item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true))")
                    } else {
//                        selectedAddress = convertToAddress(item)
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: Search List Item
    @ViewBuilder
    private func SearchListItem(_ result: MKMapItem) -> some View {
        let isSelected = result == selectedItem
        Button {
            selectedItem = result
            cameraPosition = .region(MKCoordinateRegion(
                center: result.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(result.name ?? "Unknown")
                    .foregroundStyle(.primary)
                Text(formatPlacemark(result))
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
    
    private func searchAddress() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            searchResults = response.mapItems
            selectedItem = nil
            if let first = searchResults.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
    
    
    // MARK: - Placemark Implementation
    @available(iOS, introduced: 16.0, deprecated: 26.0)
    private func formatPlacemark(_ mapItem: MKMapItem) -> String {
           let placemark = mapItem.placemark
           
           return [
               placemark.thoroughfare,
               placemark.locality,
               placemark.administrativeArea,
               placemark.postalCode
           ]
           .compactMap { $0 }
           .joined(separator: ", ")
       }

//    @available(iOS, introduced: 16.0, deprecated: 26.0)
//    private func convertToAddress(_ mapItem: MKMapItem) -> Address? {
//        if #available(iOS 27, *) {
//            if let address = mapItem.address {
//                
//            }
//        } else {
//            let placemark = mapItem.placemark
//            
//            return Address(
//                street: placemark.thoroughfare ?? "",
//                city: placemark.locality ?? "",
//                state: placemark.administrativeArea ?? "",
//                zipCode: placemark.postalCode ?? "",
//                unit: placemark.subThoroughfare
//            )
//        }
//        
//    }
}
