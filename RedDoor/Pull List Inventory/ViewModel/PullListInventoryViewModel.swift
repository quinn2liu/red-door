//
//  PullListInventoryViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/20/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import SwiftUI
import FirebaseStorage

@Observable
class PullListInventoryViewModel {
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    // MARK: Pull List
    
    func loadPullLists(limit: Int = 20, completion: @escaping ([PullList]) -> Void) async {
        lastDocument = nil
        hasMoreData = true
        
        let collectionRef = db.collection("pull_lists")

        let query: Query = collectionRef.limit(to: limit).order(by: "id", descending: false)
        
        do {
            let querySnapshot = try await query.getDocuments()
            lastDocument = querySnapshot.documents.last
            
            let pullLists = querySnapshot.documents.compactMap { document -> PullList? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try JSONDecoder().decode(PullList.self, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            
            hasMoreData = !querySnapshot.documents.isEmpty && querySnapshot.documents.count == limit
            
            await MainActor.run {
                completion(pullLists)
            }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
            await MainActor.run {
                completion([])
            }
        }
    }
}
