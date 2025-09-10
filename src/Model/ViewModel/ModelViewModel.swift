//
//  ItemViewModelProvider.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/22/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import SwiftUI
import FirebaseStorage


@Observable
final class ModelViewModel {
    let db = Firestore.firestore()
    
    let storageRef: StorageReference
    var selectedModel: Model
    private let imageManager: FirebaseImageManager
    
    init(selectedModel: Model = Model(), imageManager: FirebaseImageManager = FirebaseImageManager.shared) {
        self.selectedModel = selectedModel
        self.storageRef = Storage.storage().reference().child("model_images").child(selectedModel.id)
        self.imageManager = imageManager
    }
    
    // MARK: Create Model Items
    func createModelItemsFirebase() {
        let batch = db.batch()
        
        for _ in (1...selectedModel.itemCount) {
            let itemId = "item-\(UUID().uuidString)"
            let item: Item = Item(modelId: selectedModel.id, id: itemId, repair: false)
            selectedModel.itemIds.append(itemId)
            selectedModel.availableItemIds.append(itemId)
            let documentRef = db.collection("items").document(itemId)
            do {
                try batch.setData(from: item, forDocument: documentRef)
            } catch {
                print("Error adding item: \(itemId): \(error)")
            }
        }
        
        batch.commit { err in
            if let err {
                print("Error writing batch: \(err)")
            }
        }
    }
    
    // MARK: Create Single Model Item
    func createSingleModelItem() {
        let itemId = "item-\(UUID().uuidString)"
        let item: Item = Item(modelId: selectedModel.id, id: itemId, repair: false)
        selectedModel.itemIds.append(itemId)
        selectedModel.availableItemIds.append(itemId)
        selectedModel.itemCount += 1
        let itemRef = db.collection("items").document(itemId)
        let modelRef = db.collection("models").document(selectedModel.id)
        do {
            try itemRef.setData(from: item)
            modelRef.updateData(["count": selectedModel.itemCount])
            //            print("single item added")
        } catch {
            print("Error adding item: \(itemId): \(error)")
        }
    }
    
    // MARK: Get Model Items
    func getModelItems() async throws -> [Item] {
        let query: Query = db.collection("items")
            .whereField("modelId", isEqualTo: selectedModel.id)
        
        // `getDocuments()` now has an async version
        let snapshot = try await query.getDocuments()
        
        let items: [Item] = try snapshot.documents.map { document in
            try document.data(as: Item.self)
        }
        
        return items
    }
    
    // MARK: Update Priamry Image
    func updatePrimaryImage(image: RDImage) async {
        if let uiImage = image.uiImage {
            
            let imageRef = self.storageRef.child(image.id)
            guard let imageData = uiImage.jpegData(compressionQuality: 0.3) else {
                print("Error converting UIImage to jpegData")
                return
            }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            do {
                let _ = try await imageRef.putDataAsync(imageData, metadata: metaData)
                let imageURL = try await imageRef.downloadURL()
                self.selectedModel.primaryImage.imageURL = imageURL
                if self.selectedModel.primaryImage.imageType == .dirty {
                    self.selectedModel.primaryImage.imageType = .model_primary
                }
                
            } catch {
                print("Error occurred when uploading image \(error.localizedDescription)")
            }
            
        } else {
            print("Error occurred when uploading image: no RDImage.uiImage = nil")
        }
    }
    
    // MARK: New Update Model
    @MainActor
    func updateModel() async {
        do {
            // update primary image
            selectedModel.primaryImage.objectId = selectedModel.id
            let newPrimaryImage = try await imageManager.updateImage(
                selectedModel.primaryImage,
                resultImageType: .model_primary
            )

            // delete secondary images
            for index in selectedModel.secondaryImages.indices {
                selectedModel.secondaryImages[index].objectId = selectedModel.id
            }
            let newSecondaryImages = try await imageManager.updateImages(
                selectedModel.secondaryImages,
                resultImageType: .model_secondary
            )

            // delete model items
            for itemId in self.selectedModel.itemIds {
                try await self.db.collection("items").document(itemId).delete()
            }
            
            // delete model data
            selectedModel.nameLowercased = selectedModel.name.lowercased()
            if let newPrimaryImage {
                selectedModel.primaryImage = newPrimaryImage
            } else {
                selectedModel.primaryImage = RDImage()
            }
            selectedModel.secondaryImages = newSecondaryImages

            // Firestore update
            let modelReference = db.collection("models").document(selectedModel.id)
            try modelReference.setData(from: selectedModel)
        } catch {
            print("Error updating model: \(error)")
        }
    }
    
    // MARK: New Update Model
    func deleteModel() async {
        do {
            // delete primary image
            selectedModel.primaryImage.objectId = selectedModel.id
            selectedModel.primaryImage.imageType = .delete
            let _ = try await imageManager.updateImage(
                selectedModel.primaryImage,
                resultImageType: .model_primary
            )

            // upload secondary images
            for index in selectedModel.secondaryImages.indices {
                selectedModel.secondaryImages[index].objectId = selectedModel.id
                selectedModel.secondaryImages[index].imageType = .delete
            }
            let _ = try await imageManager.updateImages(
                selectedModel.secondaryImages,
                resultImageType: .model_secondary
            )

            // create model items
            for itemId in self.selectedModel.itemIds {
                try await self.db.collection("items").document(itemId).delete()
            }
            
            // Firestore update
            try await db.collection("models").document(self.selectedModel.id).delete()
            
        } catch {
            print("Error updating model: \(error)")
        }
    }
}

// MARK: - Model Options
extension ModelViewModel {
    
    static var colorMap: [String: Color] = [
        "No Selection": .primary.opacity(0.5),
        "Black": .black,
        "White": .white,
        "Brown": .brown,
        "Gray": .gray,
        "Pink": .pink,
        "Red": .red,
        "Orange": .orange,
        "Yellow": .yellow,
        "Green": .green,
        "Mint": .mint,
        "Teal": .teal,
        "Cyan": .cyan,
        "Blue": .blue,
        "Purple": .purple,
        "Indigo": .indigo,
    ]
    
    static var typeOptions: [String] = [
        "Chair",
        "Desk",
        "Table",
        "Couch",
        "Lamp",
        "Art",
        "Decor",
        "Miscellaneous",
        "No Selection"
    ]
    
    static var typeMap: [String: String] = [
        "Chair": "chair.fill",
        "Desk": "table.furniture.fill",
        "Table": "table.furniture.fill",
        "Couch": "sofa.fill",
        "Lamp": "lamp.floor.fill",
        "Art": "photo.artframe",
        "Miscellaneous": "ellipsis.circle",
        "No Selection": "nosign"
    ]
    
    // TODO: convert model type to an enum, and then have these fields as computed property
    static var materialOptions: [String] = [
        "Wood",
        "Metal",
        "Glass",
        "Plastic",
        "Leather",
        "Fabric",
        "Wicker",
        "Rattan",
        "Stone",
        "Marble",
        "Acrylic",
        "Veneer",
        "Bamboo",
        "Concrete",
        "Engineered Wood",
        "Laminates",
        "Vinyl",
        "Resin",
        "Cane",
        "Stainless Steel",
        "No Selection",
        "None"
    ]
    
}
