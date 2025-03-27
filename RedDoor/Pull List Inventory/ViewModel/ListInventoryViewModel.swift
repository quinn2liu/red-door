//
//  PullListInventoryViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/20/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import FirebaseStorage

@Observable
class ListInventoryViewModel {
    
    var installedLists: Bool = false
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    func loadLists(limit: Int = 20, completion: @escaping ([RDList]) -> Void) async {
        lastDocument = nil
        hasMoreData = true
        
        let collectionRef = db.collection(installedLists ? "installed_lists" : "pull_lists")

        let query: Query = collectionRef.limit(to: limit).order(by: "id", descending: false)
        
        do {
            let querySnapshot = try await query.getDocuments()
            lastDocument = querySnapshot.documents.last
            
            let lists = querySnapshot.documents.compactMap { document -> RDList? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try JSONDecoder().decode(RDList.self, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit
            
            await MainActor.run {
                completion(lists)
            }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
            await MainActor.run {
                completion([])
            }
        }
    }
}
