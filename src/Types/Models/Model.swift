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
    var name_lowercased: String
    var item_ids: [String]
    var available_item_ids: [String]
    var type: String
    var primary_color: String
    var primary_material: String
    var primary_image_url: String
    var image_ids: [String]
    var image_url_dict: [String: String]
    var count: Int
    var id: String
    
    var primary_image: RDImage
    var secondary_images: [RDImage]
    
    init(
        name: String = "",
        item_ids: [String] = [],
        available_item_ids: [String] = [],
        type: String = "No Selection",
        primary_color: String = "No Selection",
        primary_material: String = "No Selection",
        primary_image_url: String = "",
        image_ids: [String] = [],
        image_url_dict: [String: String] = [String: String](), // [imageID : imageURL]
        count: Int = 1,
        id: String = UUID().uuidString,
        
        primary_image: RDImage = RDImage(),
        secondary_images: [RDImage] = []
    ) {
        self.name = name
        self.name_lowercased = name.lowercased()
        self.item_ids = item_ids
        self.available_item_ids = available_item_ids
        self.type = type
        self.primary_color = primary_color
        self.primary_material = primary_material
        self.primary_image_url = primary_image_url
        self.image_ids = image_ids
        self.image_url_dict = image_url_dict
        self.count = count
        self.id = id
        
        self.primary_image = primary_image
        self.secondary_images = secondary_images
    }
}

// MARK: - Mock Data
extension Model {
    static var MOCK_DATA: [Model] = [
        .init(
            name: "mock_Chair",
            type: "Chair",
            primary_color: "Black",
            primary_material: "Wood",
            id: "mock_Chair_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Chair_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Desk",
            type: "Desk",
            primary_color: "Brown",
            primary_material: "Metal",
            id: "mock_Desk_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Desk_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Table",
            type: "Table",
            primary_color: "White",
            primary_material: "Glass",
            id: "mock_Table_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Table_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Couch",
            type: "Couch",
            primary_color: "Gray",
            primary_material: "Fabric",
            id: "mock_Couch_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Couch_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Lamp",
            type: "Lamp",
            primary_color: "Yellow",
            primary_material: "Plastic",
            id: "mock_Lamp_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Lamp_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Art",
            type: "Art",
            primary_color: "Red",
            primary_material: "Canvas",
            id: "mock_Art_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Art_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Decor",
            type: "Decor",
            primary_color: "Green",
            primary_material: "Stone",
            id: "mock_Decor_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Decor_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Misc1",
            type: "Miscellaneous",
            primary_color: "Blue",
            primary_material: "Resin",
            id: "mock_Misc1_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Misc1_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Misc2",
            type: "Miscellaneous",
            primary_color: "Indigo",
            primary_material: "Bamboo",
            id: "mock_Misc2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Misc2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Misc3",
            type: "Miscellaneous",
            primary_color: "Pink",
            primary_material: "Acrylic",
            id: "mock_Misc3_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Misc3_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Chair2",
            type: "Chair",
            primary_color: "Teal",
            primary_material: "Metal",
            id: "mock_Chair2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Chair2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Desk2",
            type: "Desk",
            primary_color: "Cyan",
            primary_material: "Wood",
            id: "mock_Desk2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Desk2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Table2",
            type: "Table",
            primary_color: "Purple",
            primary_material: "Glass",
            id: "mock_Table2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Table2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Couch2",
            type: "Couch",
            primary_color: "Mint",
            primary_material: "Leather",
            id: "mock_Couch2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Couch2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Lamp2",
            type: "Lamp",
            primary_color: "Orange",
            primary_material: "Plastic",
            id: "mock_Lamp2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Lamp2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Art2",
            type: "Art",
            primary_color: "White",
            primary_material: "Fabric",
            id: "mock_Art2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Art2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Decor2",
            type: "Decor",
            primary_color: "Gray",
            primary_material: "Concrete",
            id: "mock_Decor2_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Decor2_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Rug",
            type: "Decor",
            primary_color: "Brown",
            primary_material: "Wicker",
            id: "mock_Rug_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Rug_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Shelf",
            type: "Table",
            primary_color: "Blue",
            primary_material: "Veneer",
            id: "mock_Shelf_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Shelf_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        ),
        .init(
            name: "mock_Stand",
            type: "Miscellaneous",
            primary_color: "Red",
            primary_material: "Stainless Steel",
            id: "mock_Stand_id",
            primary_image: {
                var img = RDImage(objectId: "mock_Stand_id", imageType: .model_primary)
                img.imageUrl = URL(string: "https://via.placeholder.com/300")
                return img
            }()
        )
    ]
}


