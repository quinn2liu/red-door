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
    private var listener: ListenerRegistration?
    private let isListening: Bool
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    init(selectedPullList: PullList = PullList(), isListening: Bool = false) {
        self.selectedPullList = selectedPullList
        self.isListening = isListening
        
        if isListening {
            setupListener()
        }
    }
    
    deinit {
        // Clean up listener when view model is deallocated
        listener?.remove()
    }
    
    private func setupListener() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        
        listener = pullListRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self,
                  let document = documentSnapshot,
                  document.exists,
                  let updatedPullList = try? document.data(as: PullList.self) else {
                return
            }
            
            self.selectedPullList = updatedPullList
        }
    }
    
    // MARK: Pull List
    func createPullList() {
        // This will only create, not setup a listener
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        
        do {
            try pullListRef.setData(from: selectedPullList)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
        
        let batch = db.batch()
        selectedPullList.roomMetadata.forEach { roomData in
            let room = Room(roomName: roomData.name, listId: selectedPullList.id)
            
            let roomRef = pullListRef.collection("rooms").document(room.id)
            do {
                try batch.setData(from: room, forDocument: roomRef)
            } catch {
                print("Error adding item: \(room.id): \(error)")
            }
        }
        
        batch.commit { err in
            if let err {
                print("Error writing batch: \(err)")
            }
        }
    }
    
    func updatePullList() {        
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        do {
            try pullListRef.setData(from: selectedPullList)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
    }
    
    
    func deletePullList() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        pullListRef.delete()
//            print("pull list deleted")
    }
    
    // MARK: Room
    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, existingRooms: self.selectedPullList.roomMetadata) {
            return false // room not added
        } else {
            self.selectedPullList.roomMetadata.append(RoomMetadata(roomName: roomName, listId: selectedPullList.id))
            return true // room successfully added
        }
    }
    
    func roomExists(newRoomName: String, existingRooms: [RoomMetadata]) -> Bool {
        let trimmedNewRoom = newRoomName.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        
        return existingRooms.contains { room in
            let trimmedRoom = room.name.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")
            
            return trimmedRoom == trimmedNewRoom
        }
    }
    
}
