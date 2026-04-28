//
//  CreateModelViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//

import SwiftUI

@Observable
final class CreateModelViewModel {
    private let modelRepo: ModelRepository = ModelRepository()
    private let itemRepo: ItemRepository = ItemRepository()
    
    // MARK: modelState
    var modelState: ModelV2 = ModelV2(
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
        image: RDImage(),
        description: "",
        isEssential: false
    )
    
    // MARK: ViewState
    
    var itemCount: Int = 0 // Separate from ModelV2 — a create-only input that produces itemIds at commit time
    
    // Image Overlay
    var selectedRDImage: RDImage? = nil
    var isImageSelected: Bool = false
    
    var isLoading: Bool = false
    
    func createModel() async {
        var items: [ItemV2] = []
        var itemIds: [String] = []
        for _ in (0..<itemCount) {
            let newItem = ItemV2(
                modelId: modelState.id,
                id: UUID().uuidString,
                isAvailable: true,
                attention: false
            )
            items.append(newItem)
            itemIds.append(newItem.id)
        }

        // Derive computed fields at commit time
        modelState.nameLowercased = modelState.name.lowercased()
        modelState.itemIds = itemIds
        modelState.availableItemCount = itemCount
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            var batch = modelRepo.db.batch()
            for item in items {
                try itemRepo.set(item, id: item.id, inBatch: batch)
            }
            try modelRepo.set(modelState, id: modelState.id, inBatch: batch)
            
            try await batch.commit()
        } catch {
            print("error creating model: \(modelState.name)")
        }
    }
}
