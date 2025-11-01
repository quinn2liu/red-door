//
//  Address.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/6/25.
//

import CoreLocation
import Foundation
import MapKit

struct Address: Codable, Hashable {
    var id: String // lowercased, trimmed, not punctuation
    var unit: String?
    var warehouseNumber: String?
    let formattedAddress: String
//    var coordinates: GeoPoint?

    init(
        street: String,
        city: String,
        state: String,
        zipcode: String,
        country: String,
        unit: String? = nil,
        warehouseNumber: String? = nil
        //        coordinates: GeoPoint? = nil
    ) {
        // ID: concatenated, lowercased, trimmed, no punctuation or spaces
        id = Address.normalize([street, city, state, zipcode, country].joined())

        // Formatted address: standard comma-separated form
        formattedAddress = [
            street,
            city,
            state,
            zipcode,
            country,
            unit,
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")

        self.warehouseNumber = warehouseNumber
    }

    @available(iOS 26.0, *)
    init(address: MKAddress, unit: String? = nil, warehouseNumber: String? = nil) {
        id = Address.normalize(address.fullAddress)
        formattedAddress = address.fullAddress
        self.unit = unit
        self.warehouseNumber = warehouseNumber
    }

    init(placemark: MKPlacemark, unit: String? = nil, warehouseNumber: String? = nil) {
        let street = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let zipcode = placemark.postalCode ?? ""
        let country = placemark.country ?? ""

        id = Address.normalize([street, city, state, zipcode, country].joined())

        formattedAddress = [
            street,
            city,
            state,
            zipcode,
            country,
            unit,
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")

        self.unit = unit
        self.warehouseNumber = warehouseNumber
    }

    func isInitialized() -> Bool {
        warehouseNumber == nil && !id.isEmpty && !formattedAddress.isEmpty
    }

    static func normalize(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercase = trimmed.lowercased()
        let noPunctuation = lowercase.components(separatedBy: CharacterSet.punctuationCharacters).joined()
        let noSpaces = noPunctuation.replacingOccurrences(of: " ", with: "")
        return noSpaces
    }
}
