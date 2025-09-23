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
    var selectedModel: Model
    var itemCount: Int
    var items: [Item] = []
    
    let db = Firestore.firestore()
    let modelDocumentRef: DocumentReference
    let storageRef: StorageReference
    private let imageManager: FirebaseImageManager
    
    init(model: Model = Model(), imageManager: FirebaseImageManager = FirebaseImageManager.shared) {
        self.selectedModel = model
        self.itemCount = model.itemIds.count

        self.modelDocumentRef = db.collection("models").document(model.id)
        self.storageRef = Storage.storage().reference().child("model_images").child(model.id)
        
        self.imageManager = imageManager
    }
    
    // MARK: Create Single Model Item
    func createSingleModelItem() async throws {
        let item = Item(modelId: selectedModel.id)
        selectedModel.itemIds.append(item.id)
        selectedModel.availableItemCount += 1
        
        try await modelDocumentRef.updateData([
            "availableItemCount": selectedModel.availableItemCount,
            "itemIds": selectedModel.itemIds
        ])
        
        let itemRef = db.collection("items").document(item.id)
        try itemRef.setData(from: item)
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
    
    
    // MARK: Create Items
    private func createModelItems() async throws {
        let batch = db.batch()
        let collectionRef = db.collection("items")
        
        for _ in (1...itemCount) {
            let item = Item(modelId: selectedModel.id)
            selectedModel.itemIds.append(item.id)
            selectedModel.availableItemCount += 1
            
            let documentRef = collectionRef.document(item.id)
            try batch.setData(from: item, forDocument: documentRef)
        }
        
        try await batch.commit()
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
                selectedModel.primaryImage.imageURL = imageURL
                if selectedModel.primaryImage.imageType == .dirty {
                    selectedModel.primaryImage.imageType = .model_primary
                }
                
            } catch {
                print("Error occurred when uploading image \(error.localizedDescription)")
            }
            
        } else {
            print("Error occurred when uploading image: no RDImage.uiImage = nil")
        }
    }
    
    
    // MARK: Update Model
    @MainActor
    func updateModel() async {
        do {
            // update primary image
            selectedModel.primaryImage.objectId = selectedModel.id
            let newPrimaryImage = try await imageManager.updateImage(
                selectedModel.primaryImage,
                resultImageType: .model_primary
            )

            // update secondary images

            for index in selectedModel.secondaryImages.indices {
                selectedModel.secondaryImages[index].objectId = selectedModel.id
            }
            let newSecondaryImages = try await imageManager.updateImages(
                selectedModel.secondaryImages,
                resultImageType: .model_secondary
            )

            // create items
            let itemIdCount = selectedModel.itemIds.count
            if itemCount != itemIdCount && itemIdCount == 0 { // create items if none exist
                try await createModelItems()
            }
            
            // fetch updated models
            items = try await getModelItems()
            selectedModel.itemIds = items.map(\.id)
                        
            // update model data
            selectedModel.nameLowercased = selectedModel.name.lowercased()
            if let newPrimaryImage {
                selectedModel.primaryImage = newPrimaryImage
            } else {
                selectedModel.primaryImage = RDImage()
            }
            selectedModel.secondaryImages = newSecondaryImages

            // Firestore update
            try modelDocumentRef.setData(from: selectedModel)
        } catch {
            print("Error updating model: \(error)")
        }
    }
    
    // MARK: Delete Model
    func deleteModel() async {
        do {
            // delete primary image
            selectedModel.primaryImage.objectId = selectedModel.id
            selectedModel.primaryImage.imageType = .delete
            let _ = try await imageManager.updateImage(
                selectedModel.primaryImage,
                resultImageType: .model_primary
            )

            // delete secondary images
            for index in selectedModel.secondaryImages.indices {
                selectedModel.secondaryImages[index].objectId = selectedModel.id
                selectedModel.secondaryImages[index].imageType = .delete
            }
            let _ = try await imageManager.updateImages(
                selectedModel.secondaryImages,
                resultImageType: .model_secondary
            )

            // delete items
            for itemId in self.selectedModel.itemIds {
                try await self.db.collection("items").document(itemId).delete()
            }
            
            // Firestore update
            try await modelDocumentRef.delete()
            
        } catch {
            print("Error deleting model: \(error)")
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
