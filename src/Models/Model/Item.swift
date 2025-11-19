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
    var listId: String // listId -> RDList ID the item is currently at (1 or 2 signify corresponding warehouse)
    var attention: Bool // whether the item needs attention (like repairs)
    var isAvailable: Bool // whether item is available to be added to a list (in storage)

    var image: RDImage

    init(modelId: String, id: String = UUID().uuidString, attention: Bool = false, listId: String = Warehouse.warehouse1.name, isAvailable: Bool = true, image: RDImage = RDImage()) {
        self.modelId = modelId
        self.id = id
        self.attention = attention
        self.listId = listId
        self.isAvailable = isAvailable
        self.image = image
    }
}
