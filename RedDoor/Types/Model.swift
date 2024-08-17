//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation

struct Model: Identifiable, Codable{
    var model_id: String
    var num_model: Int
    var item_ids: [Int]
    var type: String
    var color: String
    var material: String
    var image: String
    var count: Int
    
    var id: String {
        return model_id
    }
    
    init(model_id: String = "test_id",
             num_model: Int = 0,
             item_ids: [Int] = [],
             type: String = "default_type",
             color: String = "default_color",
             material: String = "default_material",
             image: String = "default_image",
             count: Int = 0) {
            self.model_id = model_id
            self.num_model = num_model
            self.item_ids = item_ids
            self.type = type
            self.color = color
            self.material = material
            self.image = image
            self.count = count
    }
    
}
