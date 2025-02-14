//
//  ItemViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/7/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseCore

class ItemViewModel {
    let db = Firestore.firestore()
    
    var selectedItem: Item
    
    init(selectedItem: Item) {
        self.selectedItem = selectedItem
    }
    
    func getItemModel(modelId: String, completion: @escaping (Result<Model, Error>) -> Void) {
        db.collection("models").document(modelId).getDocument() { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documentSnapshot = documentSnapshot,
                  documentSnapshot.exists else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Model (\(modelId)) not found."])))
                return
            }
            
            do {
                let model = try documentSnapshot.data(as: Model.self)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteItem() async {
        // delete from "items" collection
        do {
            try await db.collection("items").document(selectedItem.id).delete()
//            print("Item successfully removed from Firestore")
        } catch {
            print("Error removing item \(selectedItem.id): \(error)")
        }
        
        // delete from "models" collection
        let modelRef = db.collection("models").document(selectedItem.modelId)
        do {
            try await modelRef.updateData([
                "item_ids": FieldValue.arrayRemove([selectedItem.id]),
                "count": FieldValue.increment(Int64(-1))
            ])
//            print("item successfully removed from Item")
        } catch {
            print("Error removing item \(selectedItem.id) from it's model: \(error)")
        }
    }
    
}


