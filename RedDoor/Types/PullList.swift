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
    
    var roomNames: [String] = []
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

extension PullList {
    static var MOCK_DATA: [PullList] = [
        .init(address: Address(warehouseNumber: "1"), installDate: "2025-04-01", client: "Client A", isStorage: false),
        .init(address: Address(warehouseNumber: "2"), installDate: "2025-04-05", client: "Client B", isStorage: true),
        .init(address: Address(warehouseNumber: "3"), installDate: "2025-04-10", client: "Client C", isStorage: false),
        .init(address: Address(warehouseNumber: "4"), installDate: "2025-04-15", client: "Client D", isStorage: true),
        .init(address: Address(warehouseNumber: "5"), installDate: "2025-04-20", client: "Client E", isStorage: false)
    ]
}
