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
    var pullListId: String // "effective location"
    
    init(modelId: String = "", id: String = "", repair: Bool = false, pullListId: String = "warehouse-1") {
        self.modelId = modelId
        self.id = id
        self.repair = repair
        self.pullListId = pullListId
    }
}


