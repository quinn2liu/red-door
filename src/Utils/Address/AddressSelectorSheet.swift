//
//  AddressSelectorSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/21/25.
//

import SwiftUI
import MapKit

struct AddressSelectorSheet: View {
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedItem: MKMapItem?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            TextField("Search address", text: $searchText)
                .onSubmit {
                    searchAddress()
                }
            
            Map(position: $cameraPosition, selection: $selectedItem) {
                ForEach(searchResults, id: \.self) { item in
                    Marker(item.name ?? "Location", coordinate: item.placemark.coordinate)
                        .tag(item)
                }
            }
            
            List(searchResults, id: \.self) { item in
                Button(action: {
                    selectedItem = item
                    cameraPosition = .region(MKCoordinateRegion(
                        center: item.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }) {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown")
                        Text(formatPlacemark(item.placemark))
                    }
                }
            }
            
            if let item = selectedItem {
                Button("Use This Address") {
                    let address = convertToAddress(item.placemark)
                    print("Selected address: \(address.formattedAddress)")
                }
            }
        }
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
            if let first = searchResults.first {
                selectedItem = first
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
    
    private func formatPlacemark(_ placemark: MKPlacemark) -> String {
        [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
    
    private func convertToAddress(_ placemark: MKPlacemark) -> Address {
        Address(
            street: placemark.thoroughfare ?? "",
            city: placemark.locality ?? "",
            state: placemark.administrativeArea ?? "",
            zipCode: placemark.postalCode ?? "",
            unit: placemark.subThoroughfare
        )
    }
}

#Preview {
    AddressSelectorSheet()
}
