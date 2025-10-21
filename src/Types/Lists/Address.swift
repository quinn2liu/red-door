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

extension Address {
    static let warehouseAddresses: [String: Address] = [
        "1": Address(
            street: "123 Apple St",
            city: "Cupertino",
            state: "CA",
            zipCode: "95014",
            warehouseNumber: "1"
        ),
        "2": Address(
            street: "456 Orange Ave",
            city: "San Jose",
            state: "CA",
            zipCode: "95110",
            warehouseNumber: "2"
        ),
    ]
    
    static func warehouse(_ warehouseNumber: String) -> Address {
        return warehouseAddresses[warehouseNumber] ?? warehouseAddresses["1"]!
    }
}
