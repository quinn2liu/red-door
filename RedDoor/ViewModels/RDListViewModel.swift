//
//  RDListViewModel.swift
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
class RDListViewModel {
    
    var selectedList: RDList
    var rooms: [Room]
    
    let db = Firestore.firestore()
    
    init(selectedList: RDList = RDList(), rooms: [Room] = []) {
        self.selectedList = selectedList
        self.rooms = rooms
    }
    
    var selectedListReference: DocumentReference {
        return db.collection(selectedList.listType.collectionString).document(selectedList.id)
    }
}

// MARK: - Pull List
extension RDListViewModel {
    
    // MARK: Create PL
    func createPullList() {
        do {
            try selectedListReference.setData(from: selectedList)
            
            // creating empty rooms
            let batch = db.batch()
            selectedList.roomNames.forEach { roomName in
                let room = Room(roomName: roomName, listId: selectedList.id)
                let roomRef = selectedListReference.collection("rooms").document(room.id)
                
                do {
                    try batch.setData(from: room, forDocument: roomRef)
                } catch {
                    print("Error adding item: \(room.id): \(error)")
                }
            }
            
            batch.commit()
        } catch {
            print("Error adding pull list: \(selectedList.id): \(error)")
        }
    }
    
    // MARK: Refresh PL
    func refreshPullList() async {
        do {
            let document = try await selectedListReference.getDocument()
            
            if let data = document.data() {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let updatedPullList = try JSONDecoder().decode(RDList.self, from: jsonData)
                
                // Update selectedInstalledList on the main thread
                if self.selectedList != updatedPullList {
                    DispatchQueue.main.async {
                        self.selectedList = updatedPullList
                    }
                }
                
                // Refresh rooms
                await loadRooms()
            }
        } catch {
            print("Error refreshing pull list: \(error.localizedDescription)")
        }
    }
    
    // MARK: Update PL
    func updatePullList() {
        do {
            try selectedListReference.setData(from: selectedList, merge: true)
        } catch {
            print("Error adding pull list: \(selectedList.id): \(error)")
        }
    }
    
    
    // MARK: Delete PL
    func deletePullList() {
        for roomId in selectedList.roomNames {
            let roomsRef = selectedListReference.collection("rooms").document(roomId) // TODO: confirm if this works
            roomsRef.delete()
        }
        selectedListReference.delete()
    }
}

// MARK: - Installed List
extension RDListViewModel {
    
    // MARK: Create IL
    func createInstalledFromPull() async -> RDList {
        // creating installed list
        let installedList: RDList = RDList(pullList: selectedList)
        let installedListReference: DocumentReference = db.collection("installed_lists").document(installedList.id)
        
        do {
            try installedListReference.setData(from: installedList)
        } catch {
            print("Error adding installed list: \(installedList.id): \(error)")
        }
        
        // creating the rooms
        do {
            let installedListRoomReference = installedListReference.collection("rooms")
            
            if !rooms.isEmpty {
                let roomsBatch = db.batch()
                
                rooms.forEach { room in
                    let roomRef = installedListRoomReference.document(room.id)
                    
                    do {
                        try roomsBatch.setData(from: room, forDocument: roomRef)
                    } catch {
                        print("Error adding item: \(room.id): \(error)")
                    }
                }
                
                // committing batch
                try await roomsBatch.commit()
            }
        } catch {
            print("Error creating installed list rooms: \(error.localizedDescription)")
        }
        
        // delete pull list
        deletePullList()
        
        return installedList
    }
//      TODO: what to update after creating the installed list:
//    1. delete the pull list.
//    2. update the listID of each of the items.
//    3. update the available_item_ids of the models.
    
    func updateItemsLocations() async {
        //
    }
    
}

// MARK: - Room
extension RDListViewModel {
    // MARK: Create Empty Room
    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, roomNames: self.selectedList.roomNames) {
            return false // room not added
        } else {
            self.selectedList.roomNames.append(roomName)
            return true // room successfully added
        }
    }
    
    // MARK: (Helper) Room Exists
    func roomExists(newRoomName: String, roomNames: [String]) -> Bool {
        let trimmedNewRoom = newRoomName
            .lowercased()
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
        let roomRef = selectedListReference.collection("rooms")
        
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
