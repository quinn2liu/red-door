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
class SharedViewModel {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference().child("model_images")
    
    var selectedModel: Model
    
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
        do {
            try await db.collection("unique_models").document(selectedModel.id).delete()
            print("Document \(selectedModel.id) successfully removed!")
        } catch {
            print("Error removing document: \(error)")
        }
        
    }
    
    func deleteModelImagesFirebase() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                    for imageID in selectedModel.imageIDs {
                        group.addTask {
                            let deleteRef = self.storageRef.child(imageID)
                            try await deleteRef.delete()
                        }
                    }
                    
                    try await group.waitForAll()
            }
        } catch {
            print("Error removing image: \(error)")
        }
    }
    
    func updateModelImagesFirebase(imageDict: [String: UIImage]) async {
                
        for imageID in imageDict.keys {
            let imageRef = storageRef.child("\(imageID)")
            
            guard let imageData = imageDict[imageID]?.pngData() else {
                print("error converting UIImage to pngData")
                return
            }
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            
            do {
                let resultMetaData = try await imageRef.putDataAsync(imageData, metadata: metaData)
                print("Upload finished. Metadata: \(resultMetaData)")
                let imageURL = try await imageRef.downloadURL().absoluteString
                print("imageURL = \(imageURL)")
                selectedModel.imageURLDict.updateValue(imageURL, forKey: imageID)
            } catch {
                print("Error occurred when uploading image \(error.localizedDescription)")
            }

        }
}

}

extension ItemView  {
    typealias ViewModel = SharedViewModel
}

extension AddItemView  {
    typealias ViewModel = SharedViewModel
}
