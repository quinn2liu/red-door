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

@MainActor
@Observable
class PullListViewModel {
    var selectedPullList: PullList {
        didSet {
            print("selectedPullList updated: \(selectedPullList)")
        }
    }
    var rooms: [Room] = [] {
        didSet {
            print("updatedRooms \(rooms)")
        }
    }
    private var listener: ListenerRegistration?
    
    let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private var hasMoreData = true
    
    init(selectedPullList: PullList = PullList()) {
        self.selectedPullList = selectedPullList
    }

    func refreshPullList() async {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        print("refreshPullList() called")
        do {
            let document = try await pullListRef.getDocument()
            
            if let data = document.data() {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let updatedPullList = try JSONDecoder().decode(PullList.self, from: jsonData)
                
                // Update selectedPullList on the main thread
                if self.selectedPullList != updatedPullList {
                    DispatchQueue.main.async {
                        self.selectedPullList = updatedPullList
                    }
                }

                // Refresh rooms
                await loadRooms()
            }
        } catch {
            print("Error refreshing pull list: \(error.localizedDescription)")
        }
    }
    
    // MARK: Pull List
    func createPullList() {
        // This will only create pull list, not setup a listener
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        
        do {
            try pullListRef.setData(from: selectedPullList)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
        
        // creating the rooms
        let batch = db.batch()
        selectedPullList.roomNames.forEach { roomName in
            let room = Room(roomName: roomName, listId: selectedPullList.id)
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
            try pullListRef.setData(from: selectedPullList, merge: true)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
    }
    
    
    func deletePullList() {
        let pullListRef = db.collection("pull_lists").document(selectedPullList.id)
        pullListRef.delete()
        for roomId in selectedPullList.roomNames {
            let roomsRef = pullListRef.collection("rooms").document(roomId)
            roomsRef.delete()
        }
    }
    
    // MARK: Room
    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, roomNames: self.selectedPullList.roomNames) {
            return false // room not added
        } else {
            self.selectedPullList.roomNames.append(roomName)
            return true // room successfully added
        }
    }
    
    func roomExists(newRoomName: String, roomNames: [String]) -> Bool {
        let trimmedNewRoom = newRoomName.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        
        return roomNames.contains { roomName in
            let trimmedRoomName = roomName
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")
            return trimmedRoomName == trimmedNewRoom
        }
    }
    
    func loadRooms() async {
        
        let roomRef = db.collection("pull_lists").document(selectedPullList.id).collection("rooms")
        
        do {
            let roomDocuments = try await roomRef.getDocuments()
            
            let rooms = roomDocuments.documents.compactMap { roomDocument -> Room? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: roomDocument.data(), options: [])
                    return try JSONDecoder().decode(Room.self, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            self.rooms = rooms
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
}
