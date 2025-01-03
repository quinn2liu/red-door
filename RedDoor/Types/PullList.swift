//
//  PullList.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/26/24.
//

import Foundation
import MapKit

struct PullList: Codable, Identifiable, Hashable {
    
    var id: String = UUID().uuidString
    var address: Address
    var roomContents: [String: [Item]] = [String: [Item]]() // roomName : items in that room
    var installdate: String = ""
    var client: String = ""

    init(address: Address = Address()) {
        self.address = address
    }
    
}


struct Address: Codable, Hashable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let longitude: Double
    let latitude: Double
    let name: String
    let isWarehouse: Bool
    
    init(street: String = "",
         city: String = "",
         state: String = "",
         zipCode: String = "",
         country: String = "",
         longitude: Double = 0,
         latitude: Double = 0,
         isWarehouse: Bool = false) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.longitude = longitude
        self.latitude = latitude
        self.name = street + " " + city + " " + state
        self.isWarehouse = isWarehouse
    }
    
}
