//
//  RDList.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/26/24.
//

import Foundation
import MapKit

import Foundation
import MapKit

struct RDList: Codable, Identifiable, Hashable {
    var id: String
    var listType: DocumentType

    var address: Address
    var addressId: String

    var createdDate: String
    var installDate: String
    var installed: Bool
    var client: String

    var roomIds: [String]

    // MARK: - Init from Address (might not be needed)

    init(
        address: Address,
        installDate: String = "",
        client: String = "",
        installed: Bool = false,
        roomNames: [String] = [],
        listType: DocumentType
    ) {
        id = UUID().uuidString
        self.listType = listType

        self.address = address
        addressId = address.id

        createdDate = ISO8601DateFormatter().string(from: Date())
        self.installDate = installDate
        self.installed = installed
        self.client = client
        roomIds = roomNames
    }

    // MARK: - Init from Existing List

    init(
        pullList: RDList,
        listType: DocumentType
    ) {
        id = pullList.id
        self.listType = listType

        address = pullList.address
        addressId = pullList.address.id

        createdDate = pullList.createdDate
        installDate = pullList.installDate
        installed = pullList.installed
        client = pullList.client
        roomIds = pullList.roomIds
    }

    // MARK: - Init from blank

    init(
        listType: DocumentType = .pull_list
    ) {
        id = UUID().uuidString
        self.listType = listType

        address = Warehouse.warehouse1.address
        addressId = address.id

        createdDate = ISO8601DateFormatter().string(from: Date())
        installDate = ""
        installed = false
        client = ""
        roomIds = []
    }
}
