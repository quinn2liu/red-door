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
    var imageURLs: [URL]
    var count: Int
    var id: UUID = UUID()
    
    init(
        name: String = "",
        item_ids: [Int] = [],
        type: String = "Chair",
        primaryColor: String = "Red",
        primaryMaterial: String = "Wood",
        imageIDs: [String] = [],
        imageURLs: [URL] = [],
        count: Int = 1) {
        self.name = name
        self.item_ids = item_ids
        self.type = type
        self.primaryColor = primaryColor
        self.primaryMaterial = primaryMaterial
        self.imageIDs = imageIDs
        self.imageURLs = imageURLs
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
