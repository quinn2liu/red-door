//
//  Model.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Model: Identifiable, Codable, Hashable {
    // ID
    var id: String
    var name: String
    var nameLowercased: String

    // Attributes
    var type: String

    var primaryColor: String
    var secondaryColor: String

    var primaryMaterial: String
    var secondaryMaterial: String

    // Items
    var itemIds: [String]
    var availableItemCount: Int

    // Images
    var primaryImage: RDImage
    var secondaryImages: [RDImage]

    // Description
    var description: String
    var descriptionLowercased: String
    var isEssential: Bool

    init(
        id: String = UUID().uuidString,
        name: String = "",

        itemIds: [String] = [],
        availableItemCount: Int = 0,

        type: String = "N/A",
        primaryColor: String = "N/A",
        secondaryColor: String = "N/A",

        primaryMaterial: String = "N/A",
        secondaryMaterial: String = "N/A",

        primaryImage: RDImage = RDImage(),
        secondaryImages: [RDImage] = [],

        description: String = "",
        isEssential: Bool = false
    ) {
        self.id = id
        self.name = name
        nameLowercased = name.lowercased()

        self.type = type

        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor

        self.primaryMaterial = primaryMaterial
        self.secondaryMaterial = secondaryMaterial

        self.itemIds = itemIds
        self.availableItemCount = availableItemCount

        self.primaryImage = primaryImage
        self.secondaryImages = secondaryImages

        self.description = description
        self.descriptionLowercased = description.lowercased()
        self.isEssential = isEssential
    }
}

// MARK: primaryImageExists

extension Model {
    var primaryImageExists: Bool {
        return !(primaryImage.imageURL == nil && primaryImage.uiImage == nil)
    }
}

extension Model {
    static func getModel(modelId: String) async throws -> Model {
        let documentSnapshot = try await Firestore.firestore().collection("models").document(modelId).getDocument()
        return try documentSnapshot.data(as: Model.self)
    }
}