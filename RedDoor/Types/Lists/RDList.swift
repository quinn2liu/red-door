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
    var listType: DocumentType

    // init from address
    init(address: Address = Address(warehouseNumber: "1"), installDate: String = "", client: String = "", installed: Bool? = nil, listType: DocumentType) {
        self.id = address.toUniqueID()
        self.installDate = installDate
        self.client = client
        self.installed = installed
        self.listType = listType
    }
    
    // init from list
    init(pullList: RDList, listType: DocumentType) {
        self.id = pullList.id
        self.roomNames = pullList.roomNames
        self.client = pullList.client
        self.installDate = pullList.installDate
        self.listType = listType
    }
}

extension RDList {
    static var MOCK_DATA: [RDList] = [
        .init(address: Address(warehouseNumber: "1"), installDate: "2025-04-01", client: "Client A", listType: .pull_list),
        .init(address: Address(warehouseNumber: "2"), installDate: "2025-04-05", client: "Client B", listType: .pull_list),
        .init(address: Address(warehouseNumber: "3"), installDate: "2025-04-10", client: "Client C", listType: .pull_list),
        .init(address: Address(warehouseNumber: "4"), installDate: "2025-04-15", client: "Client D", listType: .pull_list),
        .init(address: Address(warehouseNumber: "5"), installDate: "2025-04-20", client: "Client E", listType: .pull_list)
    ]
}
