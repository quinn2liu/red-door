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
class ModelViewModel {
    var images: [UIImage] = []
    let db = Firestore.firestore()
    
    let storageRef: StorageReference
    var selectedModel: Model
    
    init(selectedModel: Model = Model()) {
        self.selectedModel = selectedModel
        self.storageRef = Storage.storage().reference().child("model_images").child(selectedModel.id)
    }
    
    func printViewModelValues() {
        print(
    """
    selectedModel.primaryColor = \(selectedModel.primary_color)
    selectedModel.type = \(selectedModel.type)
    selectedModel.primaryMaterial = \(selectedModel.primary_material)
    selectedModel.count = \(selectedModel.count)
    selectedModel.imageURLDict.count = \(selectedModel.image_url_dict.count)
    """)
        for (imageID, imageURL) in selectedModel.image_url_dict {
            print("imageID: \(imageID), imageURL: \(imageURL)")
        }
    }
    
    // MARK: Update Model
    func updateModelDataFirebase()  {
        do {
            selectedModel.name_lowercased = selectedModel.name.lowercased()
            try db.collection("models").document(selectedModel.id).setData(from: selectedModel)
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    // MARK: Create Model Items
    func createModelItemsFirebase() {
        let batch = db.batch()
        
        for _ in (1...selectedModel.count) {
            let itemId = "item-\(UUID().uuidString)"
            let item: Item = Item(modelId: selectedModel.id, id: itemId, repair: false)
            selectedModel.item_ids.append(itemId)
            selectedModel.available_item_ids.append(itemId)
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
        selectedModel.item_ids.append(itemId)
        selectedModel.available_item_ids.append(itemId)
        selectedModel.count += 1
        let itemRef = db.collection("items").document(itemId)
        let modelRef = db.collection("models").document(selectedModel.id)
        do {
            try itemRef.setData(from: item)
            modelRef.updateData(["count": selectedModel.count])
            //            print("single item added")
        } catch {
            print("Error adding item: \(itemId): \(error)")
        }
    }
    
    // MARK: Get Model Items
    func getModelItems(completion: @escaping (Result<[Item], Error>) -> Void) {
        let query: Query = db.collection("items").whereField("modelId", isEqualTo: selectedModel.id)
        
        query.getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([])) // no documents were found
                return
            }
            
            do {
                let items = try documents.map { document in
                    try document.data(as: Item.self)
                }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    //    func updateModelItemsFirebase()  {
    //        let batch = db.batch()
    //
    //        for itemId in (selectedModel.item_ids) {
    //            selectedModel.item_ids.append(itemId)
    //            let item: Item = Item(modelId: selectedModel.id, id: itemId, repair: false)
    //            let documentRef = db.collection("items").document(itemId)
    //            do {
    //                try batch.setData(from: item, forDocument: documentRef)
    //            } catch {
    //                print("Error adding item: \(itemId): \(error)")
    //            }
    //        }
    //        batch.commit { err in
    //            if let err {
    //                print("Error writing batch: \(err)")
    //            } else {
    //                print("Batch write successful")
    //            }
    //        }
    //    }
    
    // MARK: Load Images
    func loadImages() {
        let dispatchGroup = DispatchGroup()
        var loadedImages: [UIImage] = []
        
        for (_, urlString) in selectedModel.image_url_dict {
            guard let url = URL(string: urlString) else { continue }
            //            print("Attempting to load imageURL: \(urlString)")
            dispatchGroup.enter()
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { dispatchGroup.leave() }
                
                if let data = data, let image = UIImage(data: data) {
                    loadedImages.append(image)
                } else {
                    print("Failed to load image from \(urlString): \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.images = loadedImages
        }
    }
    
    // MARK: Update Model Images
    func updateModelUIImagesFirebase(images: [UIImage]) async {
        
        if images.count > 0 {
            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    
                    // delete og images
                    group.addTask {
                        await self.deleteModelImagesFirebase()
                    }
                    
                    group.addTask {
                        
                        self.selectedModel.image_url_dict.removeAll()
                        self.selectedModel.image_ids.removeAll()
                        
                        // now update the images
                        for (index, image) in images.enumerated() {
                            let imageID = "\(self.selectedModel.id)-\(index)"
                            let imageRef = self.storageRef.child(imageID)
                            self.selectedModel.image_ids.append(imageID)
                            
                            // Compress the image to JPEG with a specified compression quality (0.0 to 1.0)
                            guard let imageData = image.jpegData(compressionQuality: 0.3) else {
                                print("Error converting UIImage to jpegData")
                                return
                            }
                            
                            let metaData = StorageMetadata()
                            metaData.contentType = "image/jpeg"
                            
                            do {
                                let _ = try await imageRef.putDataAsync(imageData, metadata: metaData)
                                let imageURL = try await imageRef.downloadURL().absoluteString
                                self.selectedModel.image_url_dict.updateValue(imageURL, forKey: imageID)
                            } catch {
                                print("Error occurred when uploading image \(error.localizedDescription)")
                            }
                        }
                    }
                    try await group.waitForAll()
                    
                }
            } catch {
                print("Error updating images: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Delete Model Images
    func deleteModelImagesFirebase() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for imageID in selectedModel.image_ids {
                    group.addTask {
                        let deleteRef = self.storageRef.child(imageID)
                        do {
                            try await deleteRef.delete()
                        } catch {
                            print("Error deleting imageID \(imageID): \(error)")
                        }
                    }
                }
                
                try await group.waitForAll()
            }
        } catch {
            print("Error removing image: \(error)")
        }
    }
    
    // MARK: Delete Model
    func deleteModelFirebase() async {
        await withThrowingTaskGroup(of: Void.self) { group in
            
            group.addTask {
                await self.deleteModelImagesFirebase()
            }
            
            group.addTask {
                do {
                    try await self.db.collection("models").document(self.selectedModel.id).delete()
                    
                    for itemId in self.selectedModel.item_ids {
                        try await self.db.collection("items").document(itemId).delete()
                    }
                    //                    print("Document \(self.selectedModel.id) successfully removed!")
                } catch {
                    print("Error removing document: \(error)")
                }
            }
            
        }
    }
    
    // MARK: uploadPrimaryImage
    func uploadPrimaryImage(image: UIImage) async {
        // now update the images
            let imageID = "primary"
            let imageRef = self.storageRef.child(imageID)
            
            // Compress the image to JPEG with a specified compression quality (0.0 to 1.0)
            guard let imageData = image.jpegData(compressionQuality: 0.3) else {
                print("Error converting UIImage to jpegData")
                return
            }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            do {
                let _ = try await imageRef.putDataAsync(imageData, metadata: metaData)
                let imageURL = try await imageRef.downloadURL().absoluteString
                self.selectedModel.primary_image_url = imageURL
            } catch {
                print("Error occurred when uploading image \(error.localizedDescription)")
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
