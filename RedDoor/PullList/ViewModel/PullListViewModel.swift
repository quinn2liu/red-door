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
    var selectedPullList: RDList
    var rooms: [Room] = []
    
    let db = Firestore.firestore()
    
    var selectedPullListReference: DocumentReference {
        return db.collection("pull_lists").document(selectedPullList.id)
    }
    
    init(selectedPullList: RDList = RDList(listType: .pull)) {
        self.selectedPullList = selectedPullList
    }
    
    // MARK: - Create Pull List
    func createPullList() {
        do {
            try selectedPullListReference.setData(from: selectedPullList)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
        
        // creating the rooms
        let batch = db.batch()
        selectedPullList.roomNames.forEach { roomName in
            let room = Room(roomName: roomName, listId: selectedPullList.id)
            let roomRef = selectedPullListReference.collection("rooms").document(room.id)
            
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

    // MARK: Refresh Pull List
    func refreshPullList() async {
        do {
            let document = try await selectedPullListReference.getDocument()
            
            if let data = document.data() {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let updatedPullList = try JSONDecoder().decode(RDList.self, from: jsonData)
                
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
    
    // MARK: Update Pull List
    func updatePullList() {
        do {
            try selectedPullListReference.setData(from: selectedPullList, merge: true)
        } catch {
            print("Error adding pull list: \(selectedPullList.id): \(error)")
        }
    }
    
    
    // MARK: Delete Pull List
    func deletePullList() {
        selectedPullListReference.delete()
        for roomId in selectedPullList.roomNames {
            let roomsRef = selectedPullListReference.collection("rooms").document(roomId)
            roomsRef.delete()
        }
    }
    
    // MARK: - Create Room
    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, roomNames: self.selectedPullList.roomNames) {
            return false // room not added
        } else {
            self.selectedPullList.roomNames.append(roomName)
            return true // room successfully added
        }
    }
    
    // MARK: Room Exists
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
    
    // MARK: Load Rooms
    func loadRooms() async {
        let roomRef = selectedPullListReference.collection("rooms")
        
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
    
    // MARK: - Create Installed List
    func createInstalledFromPull() async -> RDList {
        
        // creating installed list
        var installedList: RDList = RDList(pullList: selectedPullList, listType: .installed)
        let installedListReference: DocumentReference = db.collection("installed_lists").document(installedList.id)
        
        do {
            try installedListReference.setData(from: installedList)
        } catch {
            print("Error adding installed list: \(installedList.id): \(error)")
        }
        
        // creating the rooms
        do {
            let roomsBatch = db.batch()
            let pullListRoomRef = selectedPullListReference.collection("rooms")
            let roomDocuments = try await pullListRoomRef.getDocuments()
            
            let rooms: [Room] = roomDocuments.documents.compactMap { roomDocument -> Room? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: roomDocument.data(), options: [])
                    return try JSONDecoder().decode(Room.self, from: jsonData)
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }

            rooms.forEach { room in
                let roomRef = installedListReference.collection("rooms").document(room.id)
                
                do {
                    try roomsBatch.setData(from: room, forDocument: roomRef)
                } catch {
                    print("Error adding item: \(room.id): \(error)")
                }
            }
            
            // committing batch
            try await roomsBatch.commit()
            
        } catch {
            print("Error creating installed list rooms: \(error.localizedDescription)")
        }
    
        return installedList
    }
}
