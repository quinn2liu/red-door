//
//  PullListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import SwiftUI
import FirebaseStorage

@Observable
class PullListViewModel {
    var selectedPullList: PullList
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    init(selectedPullList: PullList = PullList()) {
        self.selectedPullList = selectedPullList
    }
    
    func createEmptyRoom(_ roomName: String) {
        self.selectedPullList.roomContents[roomName] = []
        updatePullList()
    }
 
    func updatePullList() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        do {
            try pullListRef.setData(from: selectedPullList)
//            print("pull list added")
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
    }
    
    func deletePullList() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        pullListRef.delete()
//            print("pull list deleted")
    }
    
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
