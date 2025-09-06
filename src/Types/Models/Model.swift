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
    var nameLowercased: String
    var itemIds: [String]
    var availableItemIds: [String]
    var type: String
    var primaryColor: String
    var primaryMaterial: String
    var imageIds: [String]
    var imageUrlDict: [String: String]
    var itemCount: Int
    var id: String
    
    var primaryImage: RDImage
    var secondaryImages: [RDImage]
    
    init(
        name: String = "",
        itemIds: [String] = [],
        availableItemIds: [String] = [],
        type: String = "No Selection",
        primaryColor: String = "No Selection",
        primaryMaterial: String = "No Selection",
        imageIds: [String] = [],
        imageUrlDict: [String: String] = [String: String](), // [imageID : imageURL]
        count: Int = 1,
        id: String = UUID().uuidString,
        
        primaryImage: RDImage = RDImage(),
        secondaryImages: [RDImage] = []
    ) {
        self.name = name
        self.nameLowercased = name.lowercased()
        self.itemIds = itemIds
        self.availableItemIds = availableItemIds
        self.type = type
        self.primaryColor = primaryColor
        self.primaryMaterial = primaryMaterial
        self.imageIds = imageIds
        self.imageUrlDict = imageUrlDict
        self.itemCount = count
        self.id = id
        
        self.primaryImage = primaryImage
        self.secondaryImages = secondaryImages
    }
}

// MARK: primaryImageExists
extension Model {
    var primaryImageExists: Bool {
        !(primaryImage.imageURL == nil && primaryImage.uiImage == nil)
    }
}

// MARK: - Mock Data
extension Model {
    static var MOCK_DATA: [Model] = [
        .init(
            name: "mock_Chair",
            type: "Chair",
            primaryColor: "Black",
            primaryMaterial: "Wood",
            id: "mock_Chair_id",
        ),
        .init(
            name: "mock_Desk",
            type: "Desk",
            primaryColor: "Brown",
            primaryMaterial: "Metal",
            id: "mock_Desk_id",
        ),
        .init(
            name: "mock_Table",
            type: "Table",
            primaryColor: "White",
            primaryMaterial: "Glass",
            id: "mock_Table_id",
        ),
        .init(
            name: "mock_Couch",
            type: "Couch",
            primaryColor: "Gray",
            primaryMaterial: "Fabric",
            id: "mock_Couch_id",
        ),
        .init(
            name: "mock_Lamp",
            type: "Lamp",
            primaryColor: "Yellow",
            primaryMaterial: "Plastic",
            id: "mock_Lamp_id",
        ),
        .init(
            name: "mock_Art",
            type: "Art",
            primaryColor: "Red",
            primaryMaterial: "Canvas",
            id: "mock_Art_id",
        ),
        .init(
            name: "mock_Decor",
            type: "Decor",
            primaryColor: "Green",
            primaryMaterial: "Stone",
            id: "mock_Decor_id",
        ),
        .init(
            name: "mock_Misc1",
            type: "Miscellaneous",
            primaryColor: "Blue",
            primaryMaterial: "Resin",
            id: "mock_Misc1_id",
        ),
        .init(
            name: "mock_Misc2",
            type: "Miscellaneous",
            primaryColor: "Indigo",
            primaryMaterial: "Bamboo",
            id: "mock_Misc2_id",
        ),
        .init(
            name: "mock_Misc3",
            type: "Miscellaneous",
            primaryColor: "Pink",
            primaryMaterial: "Acrylic",
            id: "mock_Misc3_id",
        ),
        .init(
            name: "mock_Chair2",
            type: "Chair",
            primaryColor: "Teal",
            primaryMaterial: "Metal",
            id: "mock_Chair2_id",
        ),
        .init(
            name: "mock_Desk2",
            type: "Desk",
            primaryColor: "Cyan",
            primaryMaterial: "Wood",
            id: "mock_Desk2_id",
        ),
        .init(
            name: "mock_Table2",
            type: "Table",
            primaryColor: "Purple",
            primaryMaterial: "Glass",
            id: "mock_Table2_id",
        ),
        .init(
            name: "mock_Couch2",
            type: "Couch",
            primaryColor: "Mint",
            primaryMaterial: "Leather",
            id: "mock_Couch2_id",
        ),
        .init(
            name: "mock_Lamp2",
            type: "Lamp",
            primaryColor: "Orange",
            primaryMaterial: "Plastic",
            id: "mock_Lamp2_id",
        ),
        .init(
            name: "mock_Art2",
            type: "Art",
            primaryColor: "White",
            primaryMaterial: "Fabric",
            id: "mock_Art2_id",
        ),
        .init(
            name: "mock_Decor2",
            type: "Decor",
            primaryColor: "Gray",
            primaryMaterial: "Concrete",
            id: "mock_Decor2_id",
        ),
        .init(
            name: "mock_Rug",
            type: "Decor",
            primaryColor: "Brown",
            primaryMaterial: "Wicker",
            id: "mock_Rug_id",
        ),
        .init(
            name: "mock_Shelf",
            type: "Table",
            primaryColor: "Blue",
            primaryMaterial: "Veneer",
            id: "mock_Shelf_id",
        ),
        .init(
            name: "mock_Stand",
            type: "Miscellaneous",
            primaryColor: "Red",
            primaryMaterial: "Stainless Steel",
            id: "mock_Stand_id",
        )
    ]
}


