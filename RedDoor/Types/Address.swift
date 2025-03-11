//
//  Address.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/6/25.
//

import Foundation

struct Address {
    let number: String = ""
    let street: String = ""
    let streetType: String = ""
    let city: String = ""
    let state: String = ""
    let zipcode: String = ""
    let warehouseNumber: String?
    let fullAddress: String?
    
    init(warehouseNumber: String? = nil, fullAddress: String? = nil) {
        self.warehouseNumber = warehouseNumber
        self.fullAddress = fullAddress
    }
    
    // Normalize the street type using a dictionary
    static let streetTypeMapping: [String: String] = [
        "road": "rd", "rd": "rd",
        "avenue": "ave", "ave": "ave",
        "street": "st", "st": "st",
        "boulevard": "blvd", "blvd": "blvd",
        "drive": "dr", "dr": "dr",
        "lane": "ln", "ln": "ln",
        "circle": "cir", "cir": "cir",
        "court": "ct", "ct": "ct",
        "place": "pl", "pl": "pl"
    ]
    
    static func normalizeStreetType(_ input: String) -> String {
        let lowercaseInput = input.lowercased()
        return streetTypeMapping[lowercaseInput] ?? lowercaseInput // Default to the input if no match
    }
    
    func toUniqueID() -> String {
        if let warehouseNumber {
            return "warehouse-\(warehouseNumber)"
        }
        
        if let address = fullAddress {
            let normalizedStreetType = Address.normalizeStreetType(streetType)
            return "\(number)-\(street.lowercased())-\(normalizedStreetType)-\(city.lowercased())-\(state.lowercased())-\(zipcode)"
        }
        
        return "Error: Address"
    }
}
