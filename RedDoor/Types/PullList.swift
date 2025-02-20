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
    
    var rooms: [Room] = []
    var installDate: String
    var client: String
    var isStorage: Bool

    init(address: Address = Address(warehouseNumber: "1"), installDate: String = "", client: String = "", isStorage: Bool = false) {
        self.installDate = installDate
        self.client = client
        self.id = address.toUniqueID()
        self.isStorage = isStorage
    }
    
}


