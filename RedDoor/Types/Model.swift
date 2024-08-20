//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import SwiftUI

struct Model: Identifiable, Codable {
    
    var model_name: String
    var num_model: Int
    var item_ids: [Int]
    var type: String
    var primaryColor: String
    var material: String
    var image: String
    var count: Int
    
    var id: String {
        return model_name
    }
    
    init(
        model_name: String = "",
        num_model: Int = 0,
        item_ids: [Int] = [],
        type: String = "Chair",
        primaryColor: String = "Red",
        material: String = "",
        image: String = "",
        count: Int = 0) {
        self.model_name = model_name
        self.num_model = num_model
        self.item_ids = item_ids
        self.type = type
        self.primaryColor = primaryColor
        self.material = material
        self.image = image
        self.count = count
    }
}

struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    
    
    func toColor() -> Color {
        return Color(.sRGB, red: red, green: green, blue: blue)
    }
    
}
