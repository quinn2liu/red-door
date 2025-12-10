//
//  RDList.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/26/24.
//

import Foundation
import MapKit

enum InstallationStatus: String, Codable {
    case planning = "planning"
    case installing = "installing"
    case installed = "installed"
}

struct RDList: Codable, Identifiable, Hashable {
    var id: String
    var listType: DocumentType

    var address: Address
    var addressId: String

    var createdDate: String
    var installDate: String
    var status: InstallationStatus
    var client: String

    var roomIds: [String]

    // MARK: - Init from Address (might not be needed)

    init(
        address: Address,
        installDate: String = "",
        client: String = "",
        status: InstallationStatus = .planning,
        roomNames: [String] = [],
        listType: DocumentType
    ) {
        id = UUID().uuidString
        self.listType = listType

        self.address = address
        addressId = address.id

        createdDate = ISO8601DateFormatter().string(from: Date())
        self.installDate = installDate
        self.status = status
        self.client = client
        roomIds = roomNames
    }

    // MARK: - Init from Existing List

    init(
        list: RDList,
        listType: DocumentType
    ) {
        id = list.id
        self.listType = listType

        address = list.address
        addressId = list.address.id

        createdDate = list.createdDate
        installDate = list.installDate
        status = list.status
        client = list.client
        roomIds = list.roomIds
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
        status = .planning
        client = ""
        roomIds = []
    }
}
