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
    
    var collectionString: String {
        switch self {
        case .models:
            return "models"
        case .pull_lists:
            return "pull_lists"
        case .installed_lists:
            return "installed_lists"
        case .storage:
            return "storage"
        }
    }
    
    var documentDataType: Codable.Type {
        switch self {
            case .models:
                return Model.self
            case .pull_lists, .installed_lists, .storage:
                return RDList.self
        }
    }
    
    var orderByField: String {
        switch self {
        case .models:
            return "name_lowercased"
        case .pull_lists, .installed_lists, .storage:
            return "id"
        }
    }
}

//  MARK: Could be abstracted for all lists
@Observable
class DocumentsListViewModel {
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData: Bool = true
    
    var documentType: DocumentType
    var documentsArray: [Codable] = [] // Generic array to store different types of data
    let fetchLimit: Int = 10
    
    init(_ documentType: DocumentType) {
        self.documentType = documentType
    }
    
    // MARK: Fetch Initial Documents
    func fetchInitialDocuments(
        filters: [String: Any]? = nil
    ) async {
        documentsArray = []
        lastDocument = nil
        hasMoreData = true
        
        var query: Query = db.collection(documentType.collectionString)
            .limit(to: fetchLimit)
            .order(by: documentType.orderByField)
        
        // applying search and additional features
        if let filters {
            query = applyQueryFilters(query, filters: filters)
        }
        
        do {
            let querySnapshot = try await query.getDocuments()
            lastDocument = querySnapshot.documents.last
            
            let dataType = documentType.documentDataType
            
            let documents: [Codable] = querySnapshot.documents.compactMap { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try JSONDecoder().decode(dataType, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == fetchLimit
            
            documentsArray = documents
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
    
    func fetchMoreDocuments(
        filters: [String: Any]? = nil
    ) async {
        guard hasMoreData, let lastDocument else {
            print("hasMoreData: \(hasMoreData)")
            return
        }
        
        var query: Query = db.collection(documentType.collectionString)
            .order(by: documentType.orderByField)
            .limit(to: fetchLimit)
            .start(afterDocument: lastDocument)
        
        // applying search and additional features
        if let filters {
            query = applyQueryFilters(query, filters: filters)
        }
        
        do {
            let querySnapshot = try await query.getDocuments()
            self.lastDocument = querySnapshot.documents.last
            
            let dataType = documentType.documentDataType
            
            let documents = querySnapshot.documents.compactMap { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try JSONDecoder().decode(dataType, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
                        
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == fetchLimit
            
            documentsArray.append(contentsOf: documents)
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
    
    // MARK: Apply query filters and search filter
    func applyQueryFilters(_ query: Query, filters: [String: Any]) -> Query {
        var updatedQuery = query
        
        for (key, value) in filters {
            if key == "name_lowercased", let searchText = value as? String {
                updatedQuery = updatedQuery
                    .whereField("name_lowercased", isGreaterThanOrEqualTo: searchText)
                    .whereField("name_lowercased", isLessThan: searchText + "\u{f8ff}")
            } else {
                updatedQuery = updatedQuery.whereField(key, isEqualTo: value)
            }
        }
        
        return updatedQuery
    }
}
