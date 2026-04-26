//
//  Model-v2.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//
import SwiftUI

struct ModelV2: AnyRDDocument{
    static let collectionName: String = "models_V2"
    static let orderByField: String = "name_lowercased"
    
    // Attributes
    var id: String
    var name: String
    var nameLowercased: String // for search
    var type: ModelTypeV2
    var color: ModelColor
    var material: ModelMaterial
    var value: Double?
    var brand: String?
    var purchaseLocation: String?
    var datePurchased: String?
    
    // Items
    var itemIds: [String]
    var availableItemCount: Int
    
    // Images
    var primaryImage: RDImage
    var secondaryImages: [RDImage]
    
    // Description
    var description: String
    var isEssential: Bool
    
    init(id: String,
         name: String,
         nameLowercased: String,
         type: ModelTypeV2,
         color: ModelColor,
         material: ModelMaterial,
         value: Double? = nil,
         brand: String? = nil,
         purchaseLocation: String? = nil,
         datePurchased: String? = nil,
         itemIds: [String],
         availableItemCount: Int,
         primaryImage: RDImage,
         secondaryImages: [RDImage] = [],
         description: String = "",
         isEssential: Bool
    ) {
        self.id = id
        self.name = name
        self.nameLowercased = nameLowercased
        self.type = type
        self.color = color
        self.material = material
        self.value = value
        self.brand = brand
        self.purchaseLocation = purchaseLocation
        self.datePurchased = datePurchased
        self.itemIds = itemIds
        self.availableItemCount = availableItemCount
        self.primaryImage = primaryImage
        self.secondaryImages = secondaryImages
        self.description = description
        self.isEssential = isEssential
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, color, material, value, brand, description
        case nameLowercased = "name_lowercased"
        case purchaseLocation = "purchase_location"
        case datePurchased = "date_purchased"
        case itemIds = "item_ids"
        case availableItemCount = "available_item_count"
        case primaryImage = "primary_image"
        case secondaryImages = "seconday_images"
        case isEssential = "is_essential"
    }
}

enum ModelTypeV2: String, Codable, CaseIterable {
    case chair = "Chair"
    case desk = "Desk"
    case table = "Table"
    case lamp = "Lamp"
    case accessories = "Accessories"
    case misc = "Miscellaneous"
}

enum ModelColor: String, Codable, CaseIterable {
    case black = "Black"
    case blue = "Blue"
    case brown = "Brown"
    case cyan = "Cyan"
    case gray = "Gray"
    case green = "Green"
    case indigo = "Indigo"
    case mint = "Mint"
    case orange = "Orange"
    case pink = "Pink"
    case purple = "Purple"
    case red = "Red"
    case teal = "Teal"
    case white = "White"
    case yellow = "Yellow"
    case clear = "Clear"

    var title: String { rawValue }

    var color: Color {
        switch self {
        case .black: return .black
        case .blue: return .blue
        case .brown: return .brown
        case .cyan: return .cyan
        case .gray: return .gray
        case .green: return .green
        case .indigo: return .indigo
        case .mint: return .mint
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        case .white: return .white
        case .yellow: return .yellow
        case .clear: return .clear
        }
    }
}

enum ModelMaterial: String, Codable, CaseIterable {
    case acrylic = "Acrylic"
    case bamboo = "Bamboo"
    case cane = "Cane"
    case concrete = "Concrete"
    case engineeredWood = "Engineered Wood"
    case fabric = "Fabric"
    case glass = "Glass"
    case laminates = "Laminates"
    case leather = "Leather"
    case marble = "Marble"
    case metal = "Metal"
    case none = "None"
    case plastic = "Plastic"
    case rattan = "Rattan"
    case resin = "Resin"
    case stainlessSteel = "Stainless Steel"
    case stone = "Stone"
    case veneer = "Veneer"
    case vinyl = "Vinyl"
    case wicker = "Wicker"
    case wood = "Wood"
    case other = "Other"

    var title: String { rawValue }
}
