//
//  CreateModelViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//

import SwiftUI

// TODO: consider making this actually just expose the model (so that the editing sheet can re-use it)

@Observable
final class CreateModelViewModel {
    // Attributes
    var id: String = UUID().uuidString
    var name: String = ""
    var type: ModelTypeV2 = .misc
    var color: ModelColor = .black
    var material: ModelMaterial = .none
    var value: Double? = 0.0
    var brand: String? = ""
    var purchaseLocation: String? = ""
    var datePurchased: String? = ""
    
    // Items
    var itemCount: Int = 0
    
    // Images
    var primaryImage: RDImage = RDImage()
    var secondaryImages: [RDImage] = []
    
    // Description
    var description: String = ""
    var isEssential: Bool = false
    
    let modelRepo: ModelRepository = ModelRepository()
    let itemRepo: ItemRepository = ItemRepository()
    
    func createModel() async {
        var items: [ItemV2] = []
        var itemIds: [String] = []
        for _ in (0..<itemCount) {
            let newItem = ItemV2(
                modelId: id,
                id: UUID().uuidString,
                isAvailable: true,
                attention: false
            )
            items.append(newItem)
            itemIds.append(newItem.id)
        }
        
        let model = ModelV2(
            id: id,
            name: name,
            nameLowercased: name.lowercased(),
            type: type,
            color: color,
            material: material,
            value: value,
            brand: brand,
            purchaseLocation: purchaseLocation,
            datePurchased: datePurchased,
            itemIds: itemIds,
            availableItemCount: itemCount,
            primaryImage: primaryImage,
            secondaryImages: secondaryImages,
            description: description.isEmpty ? nil : description,
            isEssential: isEssential
        )
        
        do {
            var batch = modelRepo.db.batch()
            for item in items {
                try itemRepo.set(item, id: item.id, inBatch: batch)
            }
            try modelRepo.set(model, id: model.id, inBatch: batch)
            
            try await batch.commit()
        } catch {
            print("error creating model: \(name)")
        }
    }
}
