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

class SharedItemViewModel {
    let db = Firestore.firestore()
    
    func getItemModel(modelId: String, completion: @escaping (Result<Model, Error>) -> Void) {
        db.collection("unique_models").document(modelId).getDocument() { documentSnapshot, error in
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
}

extension ItemListView {
    typealias ViewModel  = SharedItemViewModel
}

