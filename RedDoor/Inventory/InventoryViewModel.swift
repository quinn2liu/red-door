//
//  InventoryViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

extension InventoryView {
    @Observable
    class ViewModel {
        
        let db = Firestore.firestore()
        
        func addItem() {
            
            let testItem = UniqueItem(
                type: "chair",
                color: "brown",
                material: "wood",
                image: "",
                count: 1
            )
            
            do {
                try db.collection("unique_items").document("placeholder_id").setData(from: testItem)
                print("DOCUMENT ADDED")
            } catch {
                print("Error adding document: \(error)")
            }
        }
        
        
        
    }
    
    public struct UniqueItem: Codable {
        let type: String
        let color: String
        let material: String
        let image: String
        let count: Int
    }
}
