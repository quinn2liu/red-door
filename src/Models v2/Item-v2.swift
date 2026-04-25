//
//  Item-v2.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//

struct ItemV2: Codable, Identifiable, Hashable {
    var modelId: String
    var id: String
    var listId: String
    var isAvailable: Bool
    var image: RDImage?
    var attention: Bool
    var attentionDescription: String?
    
    init(
        modelId: String,
        id: String,
        listId: String,
        isAvailable: Bool,
        image: RDImage? = nil,
        attention: Bool,
        attentionDescription: String? = nil
    ) {
        self.modelId = modelId
        self.id = id
        self.listId = listId
        self.isAvailable = isAvailable
        self.image = image
        self.attention = attention
        self.attentionDescription = attentionDescription
    }
}
