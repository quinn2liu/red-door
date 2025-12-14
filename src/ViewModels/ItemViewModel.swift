//
//  ItemViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/7/25.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation

class ItemViewModel {
    let db = Firestore.firestore()

    var selectedItem: Item
    let itemRef: DocumentReference

    init(selectedItem: Item) {
        self.selectedItem = selectedItem
        self.itemRef = db.collection("items").document(selectedItem.id)
    }

    // MARK: if we have items as a subcollection, i'm not sure we need this...

    func getItemModel(modelId: String, completion: @escaping (Result<Model, Error>) -> Void) {
        db.collection("models").document(modelId).getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documentSnapshot = documentSnapshot,
                  documentSnapshot.exists
            else {
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
        let batch = db.batch()

        let modelRef = db.collection("models").document(selectedItem.modelId)

        batch.deleteDocument(itemRef)
        batch.updateData([
            "itemIds": FieldValue.arrayRemove([selectedItem.id]),
            "availableItemCount": FieldValue.increment(Int64(-1)),
        ], forDocument: modelRef)

        do {
            try await batch.commit()
        } catch {
            print("Error committing batch delete for item \(selectedItem.id): \(error)")
        }
    }

    func unstageItem(warehouseId: String) async -> Item {
        let modelRef = db.collection("models").document(selectedItem.modelId)
        let batch = db.batch()

        selectedItem.listId = warehouseId
        selectedItem.isAvailable = true
        
        batch.updateData(["listId": warehouseId, "isAvailable": true], forDocument: itemRef)
        batch.updateData(["availableItemCount": FieldValue.increment(Int64(1))], forDocument: modelRef)
        
        do {
            try await batch.commit()
        } catch {
            print("Error unstaging item: \(error.localizedDescription)")
        }
        return selectedItem
    }
}
