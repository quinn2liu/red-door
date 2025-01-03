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
class SharedModelViewModel {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference().child("model_images")
    
    var selectedModel: Model
    
    var images: [UIImage] = []
    
    init(selectedModel: Model = Model()) {
        self.selectedModel = selectedModel
    }
    
    func printViewModelValues() {
        print(
    """
    selectedModel.primaryColor = \(selectedModel.primaryColor)
    selectedModel.type = \(selectedModel.type)
    selectedModel.primaryMaterial = \(selectedModel.primaryMaterial)
    selectedModel.count = \(selectedModel.count)
    selectedModel.imageURLDict.count = \(selectedModel.imageURLDict.count)
    """)
        for (imageID, imageURL) in selectedModel.imageURLDict {
            print("imageID: \(imageID), imageURL: \(imageURL)")
        }
    }
    
    func updateModelDataFirebase()  {
        
        do {
            try db.collection("unique_models").document(selectedModel.id).setData(from: selectedModel)
            print("MODEL ADDED/EDITED")
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    func deleteModelFirebase() async {
        await withThrowingTaskGroup(of: Void.self) { group in
            
            group.addTask {
                await self.deleteModelImagesFirebase()
            }
            
            group.addTask {
                do {
                    try await self.db.collection("unique_models").document(self.selectedModel.id).delete()
                    print("Document \(self.selectedModel.id) successfully removed!")
                } catch {
                    print("Error removing document: \(error)")
                }
            }
            
        }
    }
    
    func deleteModelImagesFirebase() async {
        do {
            print("deleteModelImagesFirebase triggered")
            try await withThrowingTaskGroup(of: Void.self) { group in
                print("#imageIDs in selectedModel.imageIDs = \(selectedModel.imageIDs.count)")
                for imageID in selectedModel.imageIDs {
                    group.addTask {
                        let deleteRef = self.storageRef.child(imageID)
                        do {
                            try await deleteRef.delete()
                            print("Successfully deleted imageID: \(imageID)")
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
    
    func updateModelUIImagesFirebase(images: [UIImage]) async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                
                // delete og images
                group.addTask {
                    await self.deleteModelImagesFirebase()
                }
                
                group.addTask {
                    
                    self.selectedModel.imageURLDict.removeAll()
                    self.selectedModel.imageIDs.removeAll()
                    
                    // now update the images
                    for (index, image) in images.enumerated() {
                        let imageID = "\(self.selectedModel.id)-\(index)"
                        let imageRef = self.storageRef.child(imageID)
                        self.selectedModel.imageIDs.append(imageID)
                        
                        // Compress the image to JPEG with a specified compression quality (0.0 to 1.0)
                        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
                            print("Error converting UIImage to jpegData")
                            return
                        }
                        
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpeg"
                        
                        do {
                            let resultMetaData = try await imageRef.putDataAsync(imageData, metadata: metaData)
                            print("Upload finished. Metadata: \(resultMetaData)")
                            let imageURL = try await imageRef.downloadURL().absoluteString
                            print("imageURL = \(imageURL)")
                            self.selectedModel.imageURLDict.updateValue(imageURL, forKey: imageID)
                        } catch {
                            print("Error occurred when uploading image \(error.localizedDescription)")
                        }
                    }
                    print("after re-uploading, imageID.count = \(self.selectedModel.imageIDs.count)")
                    
                }
                try await group.waitForAll()
                
            }
        } catch {
            print("Error updating images: \(error.localizedDescription)")
        }
    }
    
    func loadImages() {
        let dispatchGroup = DispatchGroup()
        var loadedImages: [UIImage] = []
        
        for (_, urlString) in selectedModel.imageURLDict {
            guard let url = URL(string: urlString) else { continue }
            print("Attempting to load imageURL: \(urlString)")
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
    
    var colorOptions: [String] = [
        "Black",
        "White",
        "Brown",
        "Gray",
        "Pink",
        "Red",
        "Orange",
        "Yellow",
        "Green",
        "Mint",
        "Teal",
        "Cyan",
        "Blue",
        "Purple",
        "Indigo"
    ]
    
    var colorMap: [String: Color] = [
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
        "Indigo": .indigo
    ]
    
    var typeOptions: [String] = [
        "Chair",
        "Desk",
        "Table",
        "Couch",
        "Lamp",
        "Art"
    ]
    
    var typeMap: [String: String] = [
        "Chair": "chair.fill",
        "Desk": "table.furniture.fill",
        "Table": "table.furniture.fill",
        "Couch": "sofa.fill",
        "Lamp": "lamp.floor.fill",
        "Art": "photo.artframe"
    ]
    
    var materialOptions: [String] = [
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
        "Stainless Steel"
    ]
    
}

extension ModelView  {
    typealias ViewModel = SharedModelViewModel
}

extension CreateModelView  {
    typealias ViewModel = SharedModelViewModel
}
