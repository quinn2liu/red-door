//
//  DocumentsListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/10/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum DocumentType {
    case models, pull_lists, installed_lists, storage
}

//  MARK: Could be abstracted for all lists
@Observable
class DocumentsListViewModel {
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData: Bool = true
    
    var documentsArray: [Codable] = [] // Generic array to store different types of data
    let fetchLimit: Int = 20
    
    // MARK: - Get Firestore Collection Reference Dynamically
    func getCollectionRef(for collection: String) -> CollectionReference {
        return db.collection(collection)
    }
    
//    func searchDocuments<T: Codable>(
//        from collection: String,
//        matching filters: [String: Any]? = nil,
//        orderBy field: String = "id",
//        descending: Bool = false,
//        limit: Int = 10
//    ) async -> [T] {
//        
//    }
    
    // MARK: - Generic Fetch Function (Async Version)
    func fetchDocuments<T: Codable>(
        from collection: String,
        matching filters: [String: Any]? = nil,
        orderBy field: String = "id",
        descending: Bool = false,
        limit: Int = 10
    ) async -> [T] {
        var query: Query = getCollectionRef(for: collection)
            .limit(to: limit + 1) // Fetch one extra document to check for more
            .order(by: field, descending: descending)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        // Apply optional filters
        if let filters {
            for (key, value) in filters {
                if key == "name_lowercased", let searchText = value as? String {
                    query = query
                        .whereField("name_lowercased", isGreaterThanOrEqualTo: searchText)
                        .whereField("name_lowercased", isLessThan: searchText + "\u{f8ff}")
                } else {
                    query = query.whereField(key, isEqualTo: value)
                }
            }
        }
        
        do {
            let querySnapshot = try await query.getDocuments()
            
            // Determine if there are more documents
            hasMoreData = querySnapshot.documents.count > limit
            
            // If there are more documents than the limit, remove the last one
            let documents = hasMoreData
                ? Array(querySnapshot.documents.prefix(limit))
                : querySnapshot.documents
            
            // Update last document for next pagination
            lastDocument = hasMoreData
                ? querySnapshot.documents[limit - 1]
                : querySnapshot.documents.last
            
            if !querySnapshot.isEmpty {
                let parsedDocuments = documents.compactMap { document -> T? in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        return try JSONDecoder().decode(T.self, from: jsonData)
                    } catch {
                        print("Error decoding document: \(error)")
                        return nil
                    }
                }
                
                return parsedDocuments
            } else {
                return []
            }
            
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Fetch Lists (Callback Version)
//    func loadLists(installedLists: Bool, limit: Int = 20, completion: @escaping ([RDList]) -> Void) async {
//        lastDocument = nil
//        hasMoreData = true
//        
//        let collectionName = installedLists ? "installed_lists" : "pull_lists"
//        let collectionRef = getCollectionRef(for: collectionName)
//        
//        let query: Query = collectionRef.limit(to: limit).order(by: "id", descending: false)
//        
//        do {
//            let querySnapshot = try await query.getDocuments()
//            lastDocument = querySnapshot.documents.last
//            
//            let lists = querySnapshot.documents.compactMap { document -> RDList? in
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//                    return try JSONDecoder().decode(RDList.self, from: jsonData)
//                } catch {
//                    print("Error decoding document: \(error)")
//                    return nil
//                }
//            }
//            
//            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit
//            
//            await MainActor.run {
//                completion(lists)
//            }
//        } catch {
//            print("Error fetching documents: \(error.localizedDescription)")
//            await MainActor.run {
//                completion([])
//            }
//        }
//    }
}
