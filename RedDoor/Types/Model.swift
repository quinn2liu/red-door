//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import SwiftUI

struct Model: Identifiable, Codable, Hashable {
    
    
    var name: String
    var item_ids: [Int]
    var type: String
    var primaryColor: String
    var primaryMaterial: String
    var imageIDs: [String]
    var imageURLDict: [String: String]
    var count: Int
    var id: String
    
    init(
        name: String = "",
        item_ids: [Int] = [],
        type: String = "Chair",
        primaryColor: String = "Red",
        primaryMaterial: String = "Wood",
        imageIDs: [String] = [],
        imageURLDict: [String: String] = [String: String](),
        count: Int = 1,
        id: String = UUID().uuidString) {
        self.name = name
        self.item_ids = item_ids
        self.type = type
        self.primaryColor = primaryColor
        self.primaryMaterial = primaryMaterial
        self.imageIDs = imageIDs
        self.imageURLDict = imageURLDict
        self.count = count
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
            case name, item_ids, type, primaryColor, primaryMaterial, imageIDs, imageURLDict, count, id
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(item_ids, forKey: .item_ids)
        try container.encode(type, forKey: .type)
        try container.encode(primaryColor, forKey: .primaryColor)
        try container.encode(primaryMaterial, forKey: .primaryMaterial)
        try container.encode(imageIDs, forKey: .imageIDs)
        guard let imageURLDictData = try? JSONEncoder().encode(imageURLDict) else { return }
        try container.encode(imageURLDict, forKey: .imageURLDict)
        try container.encode(count, forKey: .count)
        try container.encode(id, forKey: .id)
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        item_ids = try container.decode([Int].self, forKey: .item_ids)
        type = try container.decode(String.self, forKey: .type)
        primaryColor = try container.decode(String.self, forKey: .primaryColor)
        primaryMaterial = try container.decode(String.self, forKey: .primaryMaterial)
        imageIDs = try container.decode([String].self, forKey: .imageIDs)
        imageURLDict = try container.decode([String: String].self, forKey: .imageURLDict)
        count = try container.decode(Int.self, forKey: .count)
        id = try container.decode(String.self, forKey: .id)

    }
    
    
}

