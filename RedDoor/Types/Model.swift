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
    var item_ids: [Int]
    var type: String
    var primaryColor: String
    var primaryMaterial: String
    var images: [String]
    var count: Int
    
    var id: String {
        return model_name
    }
    
    init(
        model_name: String = "",
        item_ids: [Int] = [],
        type: String = "Chair",
        primaryColor: String = "Red",
        primaryMaterial: String = "Wood",
        images: [String] = [""],
        count: Int = 1) {
        self.model_name = model_name
        self.item_ids = item_ids
        self.type = type
        self.primaryColor = primaryColor
        self.primaryMaterial = primaryMaterial
        self.images = images
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
