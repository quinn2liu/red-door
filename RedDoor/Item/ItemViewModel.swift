//
//  ItemViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import SwiftUI

extension ItemView {
    
    @Observable
    class ViewModel {
        let db = Firestore.firestore()
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
        
        init(selectedModel: Model) {
            self.selectedModel = selectedModel
        }
        
        func updateModelFirebase(model: Model) {
            do {
                try db.collection("unique_items").document(model.id).setData(from: model)
                print("MODEL ADDED")
            } catch {
                print("Error adding document: \(error)")
            }
        }
        
        func getImages(model: Model) -> [Image] {
            let images = [Image]()
            return images
        }
        
    }
    
}
