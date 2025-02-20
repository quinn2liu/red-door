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
    
    // MARK: Pull List
    
    func createPullList() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        
        do {
            try pullListRef.setData(from: selectedPullList)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
        
//        let batch = db.batch()
//        selectedPullList.rooms.forEach { room in
//            let roomRef = db.collection("rooms").document(room.id)
//            do {
//                try batch.setData(from: room, forDocument: roomRef)
//            } catch {
//                print("Error adding item: \(room.id): \(error)")
//            }
//        }
//        
//        batch.commit { err in
//            if let err {
//                print("Error writing batch: \(err)")
//            }
//        }
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
    
    // MARK: Room
    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, existingRooms: self.selectedPullList.rooms) {
            return false // room not added
        } else {
            self.selectedPullList.rooms.append(Room(roomName: roomName, listId: selectedPullList.id))
            return true // room successfully added
        }
    }
    
    func roomExists(newRoomName: String, existingRooms: [Room]) -> Bool {
        let trimmedNewRoom = newRoomName.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        
        return existingRooms.contains { room in
            let trimmedRoom = room.roomName.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")
            
            return trimmedRoom == trimmedNewRoom
        }
    }
    
}
