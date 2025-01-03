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
        private var listener: ListenerRegistration?
        
        func getInventoryModels(completion: @escaping ([Model]) -> Void) {
                let collectionRef = db.collection("unique_models")
                
                listener = collectionRef.addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    let models = documents.compactMap { document -> Model? in
                        do {
                           let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                           let model = try JSONDecoder().decode(Model.self, from: jsonData)
                           return model
                       } catch {
                           print("Error decoding document: \(error)")
                           return nil
                       }
                    }
                    
                    completion(models)
                }
            }
            
        func stopListening() {
            listener?.remove()
        }
    }
}
