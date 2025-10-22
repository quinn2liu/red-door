//
//  Warehouse.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/21/25.
//

import Foundation

enum Warehouse: String, Codable, CaseIterable {
    case warehouse1 = "warehouse-1"
    case warehouse2 = "warehouse-2"

    var name: String {
        switch self {
        case .warehouse1: return "Main Warehouse"
        case .warehouse2: return "Secondary Warehouse"
        }
    }

    var address: Address {
        switch self {
        case .warehouse1:
            return Address(
                street: "123 Distribution Way",
                city: "Boston",
                state: "MA",
                zipCode: "02118"
            )
        case .warehouse2:
            return Address(
                street: "42 Storage Blvd",
                city: "Cambridge",
                state: "MA",
                zipCode: "02139"
            )
        }
    }
}
