//
//  InventoryViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

//  MARK: Could be abstracted for all lists
extension InventoryView {
    @Observable
    class ViewModel {
        
        let db = Firestore.firestore()
        private var lastDocument: DocumentSnapshot?
        private var hasMoreData = true
        
        //        func getInventoryModels(selectedType: ModelType?, completion: @escaping ([Model]) -> Void) {
        //                let collectionRef = db.collection("unique_models")
        //
        //                var query : Query
        //
        //                if let selectedType {
        //                    query = collectionRef.whereField("type", isEqualTo: selectedType.rawValue)
        //                } else {
        //                    query = collectionRef
        //                }
        //
        //                listener = query.addSnapshotListener { querySnapshot, error in
        //                    guard let documents = querySnapshot?.documents else {
        //                        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
        //                        return
        //                    }
        //
        //                    let models = documents.compactMap { document -> Model? in
        //                        do {
        //                           let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
        //                           let model = try JSONDecoder().decode(Model.self, from: jsonData)
        //                           return model
        //                       } catch {
        //                           print("Error decoding document: \(error)")
        //                           return nil
        //                       }
        //                    }
        //
        //                    completion(models)
        //                }
        //            }
        
        //        func stopListening() {
        //            listener?.remove()
        //        }
        
        func searchInventoryModels(searchText: String, selectedType: ModelType?, limit: Int, completion: @escaping ([Model]) -> Void) async {
            lastDocument = nil
            hasMoreData = true

            let collectionRef = db.collection("unique_models")
            var query: Query = collectionRef
                .whereField("name", isGreaterThanOrEqualTo: searchText)
                .whereField("name", isLessThan: searchText + "\u{f8ff}")
                .limit(to: limit)
                .order(by: "name", descending: false)

            if let selectedType {
                query = query.whereField("type", isEqualTo: selectedType.rawValue)
            }

            do {
                let querySnapshot = try await query.getDocuments()
                lastDocument = querySnapshot.documents.last

                let models = querySnapshot.documents.compactMap { document -> Model? in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        return try JSONDecoder().decode(Model.self, from: jsonData)
                    } catch {
                        print("Error decoding document: \(error)")
                        return nil
                    }
                }

                hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit

                await MainActor.run {
                    completion(models)
                }
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                await MainActor.run {
                    completion([])
                }
            }
        }
        
        func getInitialInventoryModels(selectedType: ModelType?, limit: Int, completion: @escaping ([Model]) -> Void) async {
            
            lastDocument = nil
            hasMoreData = true
            
            let collectionRef = db.collection("unique_models")

            var query: Query = collectionRef.limit(to: limit).order(by: "name", descending: false)
            
            if let selectedType {
                query = collectionRef.whereField("type", isEqualTo: selectedType.rawValue)
            }
            
            do {
                let querySnapshot = try await query.getDocuments()
                lastDocument = querySnapshot.documents.last
                
                let models = querySnapshot.documents.compactMap { document -> Model? in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        return try JSONDecoder().decode(Model.self, from: jsonData)
                    } catch {
                        print("Error decoding document: \(error)")
                        return nil
                    }
                }
                
                hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit
                
                await MainActor.run {
                    completion(models)
                }
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                await MainActor.run {
                    completion([])
                }
            }
        }
        
        func getMoreInventoryModels(searchText: String?, selectedType: ModelType?, limit: Int, completion: @escaping ([Model]) -> Void) async {
            guard hasMoreData, let lastDocument = lastDocument else {
                await MainActor.run {
                    completion([])
                }
                print("hasMoreData = \(hasMoreData), getMoreModels returned EMPTY ARRAY []")
                return
            }
            
            let collectionRef = db.collection("unique_models").order(by: "name", descending: false)
            var query: Query = collectionRef
                .limit(to: limit)
                .start(afterDocument: lastDocument)
            
            if let searchText {
                query = query
                    .whereField("name", isGreaterThanOrEqualTo: searchText)
                    .whereField("name", isLessThan: searchText + "\u{f8ff}")
            }
            
            if let selectedType {
                query = query.whereField("type", isEqualTo: selectedType.rawValue)
            }
            
            do {
                let querySnapshot = try await query.getDocuments()
                self.lastDocument = querySnapshot.documents.last
                
                let models = querySnapshot.documents.compactMap { document -> Model? in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        return try JSONDecoder().decode(Model.self, from: jsonData)
                    } catch {
                        print("Error decoding document: \(error)")
                        return nil
                    }
                }
                
                print("getMoreModels RETURNED \(models.count) MODELS")
                
                hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit
                
                await MainActor.run {
                    completion(models)
                }
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                await MainActor.run {
                    completion([])
                }
            }
        }
    }
}
