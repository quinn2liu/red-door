//
//  List.swift
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
    var addressKey: String
    var cityLowercased: String
    var streetLowercased: String
    var stateLowercased: String

    var createdDate: String
    var installDate: String
    var installed: Bool
    var client: String

    var roomIds: [String]

    // MARK: - Init from Address
    init(
        address: Address = Address.warehouse("1"),
        installDate: String = "",
        client: String = "",
        installed: Bool = false,
        roomNames: [String] = [],
        listType: DocumentType
    ) {
        self.id = UUID().uuidString
        self.listType = listType

        self.address = address
        self.addressKey = address.toUniqueID()
        self.cityLowercased = address.city.lowercased()
        self.streetLowercased = address.street.lowercased().replacingOccurrences(of: " ", with: "")
        self.stateLowercased = address.state.lowercased()

        self.createdDate = ISO8601DateFormatter().string(from: Date())
        self.installDate = installDate
        self.installed = installed
        self.client = client
        self.roomIds = roomNames
    }

    // MARK: - Init from Existing List
    init(
        pullList: RDList,
        listType: DocumentType
    ) {
        self.id = pullList.id
        self.listType = listType

        self.address = pullList.address
        self.addressKey = pullList.addressKey
        self.cityLowercased = pullList.cityLowercased
        self.streetLowercased = pullList.streetLowercased
        self.stateLowercased = pullList.stateLowercased

        self.createdDate = pullList.createdDate
        self.installDate = pullList.installDate
        self.installed = pullList.installed
        self.client = pullList.client
        self.roomIds = pullList.roomIds
    }
    
    // MARK: - Init from blank
    init(
        listType: DocumentType = .pull_list
    ) {
        self.id = UUID().uuidString
        self.listType = listType

        self.address = Address.warehouse("1")
        self.addressKey = address.toUniqueID()
        self.cityLowercased = address.city.lowercased()
        self.streetLowercased = address.street.lowercased().replacingOccurrences(of: " ", with: "")
        self.stateLowercased = address.state.lowercased()

        self.createdDate = ISO8601DateFormatter().string(from: Date())
        self.installDate = ""
        self.installed = false
        self.client = ""
        self.roomIds = []
    }
}


