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
@Observable
class InventoryViewModel {
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    var modelsArray: [Model] = []
    let fetchLimit: Int = 20
    
    func searchInventoryModels(searchText: String, selectedType: ModelType?) async {
        lastDocument = nil
        hasMoreData = true
        
        let searchLowercased = searchText.lowercased()
        
        let collectionRef = db.collection("models")
        var query: Query = collectionRef
            .whereField("name_lowercased", isGreaterThanOrEqualTo: searchLowercased)
            .whereField("name_lowercased", isLessThan: searchLowercased + "\u{f8ff}")
            .limit(to: fetchLimit)
        
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
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == fetchLimit
            
            modelsArray = models
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
            
        }
    }
    
    func getInitialInventoryModels(selectedType: ModelType?) async {
        
        lastDocument = nil
        hasMoreData = true
        
        let collectionRef = db.collection("models")
        
        var query: Query = collectionRef.limit(to: fetchLimit).order(by: "name", descending: false)
        
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
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == fetchLimit
            
            modelsArray = models
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
    
    func getMoreInventoryModels(searchText: String?, selectedType: ModelType?) async {
        guard hasMoreData, let lastDocument = lastDocument else {
            //                print("hasMoreData = \(hasMoreData), getMoreModels returned EMPTY ARRAY []")
            return
        }
        
        let collectionRef = db.collection("models").order(by: "name", descending: false)
        var query: Query = collectionRef
            .limit(to: fetchLimit)
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
            
            //                print("getMoreModels RETURNED \(models.count) MODELS")
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == fetchLimit
            
            modelsArray.append(contentsOf: models)
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")

        }
    }
}
