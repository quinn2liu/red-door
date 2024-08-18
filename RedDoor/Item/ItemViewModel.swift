//
//  ItemViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

extension ItemView {
    @Observable
    class ViewModel {
        let db = Firestore.firestore()
        var testModel = Model()

        func updateModelFirebase(model: Model) {
            do {
                try db.collection("unique_items").document(model.id).setData(from: model)
                print("MODEL ADDED")
            } catch {
                print("Error adding document: \(error)")
            }
        }
    }
}
