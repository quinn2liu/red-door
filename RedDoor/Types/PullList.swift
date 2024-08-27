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
    var address: Address = Address()
    var addressContents: [String: RoomItems] = [String: RoomItems]()

    
    init(id: String, address: Address) {
        self.id = id
        self.address = address
    }
    
}

struct RoomItems: Codable, Hashable {
    let itemID: String
    let count: Int
}

struct Address: Codable, Hashable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let longitude: Double
    let latitude: Double
    
    init(street: String = "",
         city: String = "",
         state: String = "",
         zipCode: String = "",
         country: String = "",
         longitude: Double = 0,
         latitude: Double = 0) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.longitude = longitude
        self.latitude = latitude
    }
    
}
