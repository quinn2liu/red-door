//
//  CreateModelViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//

import SwiftUI

@Observable
final class CreateModelViewModel {
    var model: ModelV2 = ModelV2(
        id: UUID().uuidString,
        name: "",
        nameLowercased: "",
        type: .misc,
        color: .black,
        material: .none,
        value: 0.0,
        brand: "",
        purchaseLocation: "",
        datePurchased: "",
        itemIds: [],
        availableItemCount: 0,
        primaryImage: RDImage(),
        secondaryImages: [],
        description: "",
        isEssential: false
    )

    // Separate from ModelV2 — a create-only input that produces itemIds at commit time
    var itemCount: Int = 0

    let modelRepo: ModelRepository = ModelRepository()
    let itemRepo: ItemRepository = ItemRepository()
    
    func createModel() async {
        var items: [ItemV2] = []
        var itemIds: [String] = []
        for _ in (0..<itemCount) {
            let newItem = ItemV2(
                modelId: model.id,
                id: UUID().uuidString,
                isAvailable: true,
                attention: false
            )
            items.append(newItem)
            itemIds.append(newItem.id)
        }

        // Derive computed fields at commit time
        model.nameLowercased = model.name.lowercased()
        model.itemIds = itemIds
        model.availableItemCount = itemCount
        
        do {
            var batch = modelRepo.db.batch()
            for item in items {
                try itemRepo.set(item, id: item.id, inBatch: batch)
            }
            try modelRepo.set(model, id: model.id, inBatch: batch)
            
            try await batch.commit()
        } catch {
            print("error creating model: \(model.name)")
        }
    }
}
