//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation

struct Model: Identifiable, Codable {
    
    var model_name: String
    var num_model: Int
    var item_ids: [Int]
    var type: String
    var color: String
    var material: String
    var image: String
    var count: Int
    
    var id: String {
        return model_name
    }
    
    init(model_name: String = "Enter Name Here",
             num_model: Int = 0,
             item_ids: [Int] = [],
             type: String = "Select Type",
             color: String = "Select Color",
             material: String = "Select Saterial",
             image: String = "image_string",
             count: Int = 0) {
            self.model_name = model_name
            self.num_model = num_model
            self.item_ids = item_ids
            self.type = type
            self.color = color
            self.material = material
            self.image = image
            self.count = count
    }
    
}
