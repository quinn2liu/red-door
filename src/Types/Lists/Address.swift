//
//  Address.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/6/25.
//

import Foundation
import CoreLocation

struct Address: Codable, Hashable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var unit: String?
    var warehouseNumber: String?
    var formattedAddress: String {    // For display and searching
        [
            street,
            unit,
            city,
            state,
            zipCode
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
//    var coordinates: GeoPoint?
    
    init(
        street: String,
        city: String,
        state: String,
        zipCode: String,
        unit: String? = nil,
        warehouseNumber: String? = nil
//        coordinates: GeoPoint? = nil
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.unit = unit
        self.warehouseNumber = warehouseNumber
//        self.coordinates = coordinates
    }
    
    func toUniqueID() -> String {
        let normalized = [
            street.lowercased().replacingOccurrences(of: " ", with: ""),
            city.lowercased(),
            state.lowercased(),
            zipCode
        ]
        .joined(separator: "_")
        return normalized
    }
}

