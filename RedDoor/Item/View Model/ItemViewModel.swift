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
    
    // MARK: if we have items as a subcollection, i'm not sure we need this...
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
    
    // MARK: addItemToRoomDraft()
    func addItemToRoomDraft(room: Room) {
        let pullListRef = db.collection("pull_lists").document(room.listId)
        let roomRef = pullListRef.collection("rooms").document(room.id)

        // update the room with the new item
        roomRef.updateData([
            "itemIds": FieldValue.arrayUnion([selectedItem.id])
        ]) { error in
            if let error = error {
                print("Error adding item to room: \(error)")
            }
        }
        
        // update roomMetadata in pull list
    }
    
    
    
//    TODO: this code should only run from turning a pull list into an installed list
    
//    func addItemToRoom(room: Room) {
//        // 1. add the item id to the room
//        let roomRef = db.collection("pull_lists").document(room.listId).collection("rooms").document(room.id)
//        
//        roomRef.updateData([
//            "contents": FieldValue.arrayUnion([selectedItem.id])
//        ]) { error in
//            if let error = error {
//                print("Error adding item to room: \(error)")
//            }
//        }
//        
//        // 2. update the item locations to the designated pull list
//        
//        
//        
//        // 3. update the roommetadata
//
//    }
//    
//    
//    func updateItemLocation(room: Room) {
//        let itemRef = db.collection("items").document(selectedItem.id)
//        itemRef.updateData([
//            "listId": room.listId
//        ]) { error in
//            if let error = error {
//                print("Error updating item (\(self.selectedItem.id)) to list (\(room.listId)): \(error)")
//            }
//        }
//    }
    
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


