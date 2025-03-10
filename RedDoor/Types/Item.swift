//
//  Item.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import Foundation
struct Item: Identifiable, Codable, Hashable {
    var modelId: String // comes from the "parent" model
    var id: String // the item's id (a variation of the modelId
    var repair: Bool // whether the item needs to be repaired
    var listId: String // "effective location"
    
    init(modelId: String = "", id: String = "", repair: Bool = false, listId: String = "warehouse-1") {
        self.modelId = modelId
        self.id = id
        self.repair = repair
        self.listId = listId
    }
}

extension Item {
    static var MOCK_DATA: [Item] = [
        // Items for mock_Chair
        .init(modelId: "mock_Chair_id", id: "mock_Chair_id_item_1", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Chair_id", id: "mock_Chair_id_item_2", repair: true, listId: "warehouse-1"),
        .init(modelId: "mock_Chair_id", id: "mock_Chair_id_item_3", repair: false, listId: "warehouse-1"),

        // Items for mock_Desk
        .init(modelId: "mock_Desk_id", id: "mock_Desk_id_item_1", repair: true, listId: "warehouse-1"),
        .init(modelId: "mock_Desk_id", id: "mock_Desk_id_item_2", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Desk_id", id: "mock_Desk_id_item_3", repair: false, listId: "warehouse-1"),

        // Items for mock_Table
        .init(modelId: "mock_Table_id", id: "mock_Table_id_item_1", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Table_id", id: "mock_Table_id_item_2", repair: true, listId: "warehouse-1"),
        .init(modelId: "mock_Table_id", id: "mock_Table_id_item_3", repair: false, listId: "warehouse-1"),

        // Items for mock_Couch
        .init(modelId: "mock_Couch_id", id: "mock_Couch_id_item_1", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Couch_id", id: "mock_Couch_id_item_2", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Couch_id", id: "mock_Couch_id_item_3", repair: true, listId: "warehouse-1"),

        // Items for mock_Lamp
        .init(modelId: "mock_Lamp_id", id: "mock_Lamp_id_item_1", repair: true, listId: "warehouse-1"),
        .init(modelId: "mock_Lamp_id", id: "mock_Lamp_id_item_2", repair: false, listId: "warehouse-1"),
        .init(modelId: "mock_Lamp_id", id: "mock_Lamp_id_item_3", repair: false, listId: "warehouse-1")
    ]
}
