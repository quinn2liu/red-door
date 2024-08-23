//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import SwiftUI

struct Model: Identifiable, Codable, Hashable {
    
    var model_name: String
    var item_ids: [Int]
    var type: String
    var primaryColor: String
    var primaryMaterial: String
    var imageIDs: [String]
    var count: Int
    
    var id: String {
        return UUID()
    }
    
    init(
        model_name: String = "",
        item_ids: [Int] = [],
        type: String = "Chair",
        primaryColor: String = "Red",
        primaryMaterial: String = "Wood",
        imageIDs: [String] = [""],
        count: Int = 1) {
        self.model_name = model_name
        self.item_ids = item_ids
        self.type = type
        self.primaryColor = primaryColor
        self.primaryMaterial = primaryMaterial
        self.imageIDs = imageIDs
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
