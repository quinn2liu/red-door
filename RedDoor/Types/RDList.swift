//
//  List.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/26/24.
//

import Foundation
import MapKit

enum RDListType: String, Codable {
    case pull, installed, storage
}

struct RDList: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    
    var roomNames: [String] = []
    var installDate: String
    var client: String
    var installed: Bool?
    var listType: RDListType

    init(address: Address = Address(warehouseNumber: "1"), installDate: String = "", client: String = "", installed: Bool? = nil, listType: RDListType) {
        self.id = address.toUniqueID()
        self.installDate = installDate
        self.client = client
        self.installed = installed
        self.listType = listType
    }
}

extension RDList {
    static var MOCK_DATA: [RDList] = [
        .init(address: Address(warehouseNumber: "1"), installDate: "2025-04-01", client: "Client A", listType: .pull),
        .init(address: Address(warehouseNumber: "2"), installDate: "2025-04-05", client: "Client B", listType: .pull),
        .init(address: Address(warehouseNumber: "3"), installDate: "2025-04-10", client: "Client C", listType: .pull),
        .init(address: Address(warehouseNumber: "4"), installDate: "2025-04-15", client: "Client D", listType: .pull),
        .init(address: Address(warehouseNumber: "5"), installDate: "2025-04-20", client: "Client E", listType: .pull)
    ]
}
