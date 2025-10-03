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

@Observable
class RDListViewModel {
    
    // current data
    var selectedList: RDList
    var rooms: [Room]
    
    // firebase
    let db = Firestore.firestore()
    let listDocumentRef: DocumentReference
    let roomsDocumentRef: CollectionReference
    
    init(selectedList: RDList = RDList(), rooms: [Room] = []) {
        self.selectedList = selectedList
        self.rooms = rooms
        
        self.listDocumentRef = db.collection("\(selectedList.listType.collectionString)").document("\(selectedList.id)")
        self.roomsDocumentRef = listDocumentRef.collection("rooms")
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
    @MainActor
    func refreshPullList() async {
        do {
            let document = try await selectedListReference.getDocument()
            
            if let data = document.data() {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let updatedPullList = try JSONDecoder().decode(RDList.self, from: jsonData)
                
                // Update selectedInstalledList on the main thread
                if selectedList != updatedPullList {
//                    DispatchQueue.main.async {
                        selectedList = updatedPullList
//                    }
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
    
    // MARK: Create Installed List from Pull List
    func createInstalledFromPull() async -> RDList? {
        let installedList = RDList(pullList: selectedList, listType: .installed_list)
        let installedListRef = db.collection("installed_lists").document(installedList.id)
        let roomsRef = installedListRef.collection("rooms")
        
        do {
            let result = try await db.runTransaction { transaction, errorPointer in
                // 1. Create installed list
                do {
                    try transaction.setData(from: installedList, forDocument: installedListRef)
                } catch {
                    print("Error creating installedList document: (\(error.localizedDescription))")
                    return nil
                }
                
                // 2. Copy rooms
                for room in self.rooms {
                    let roomRef = roomsRef.document(room.id)
                    do {
                        try transaction.setData(from: room, forDocument: roomRef)
                    } catch {
                        print("Error creating installedList rooms documents: (\(error.localizedDescription))")
                        return nil
                    }
                }
                
                // 3. Update items + collect model counts
                var modelItemCounts: [String:Int] = [:]
                
                for room in self.rooms {
                    for itemId in room.itemModelMap.keys {
                        let itemRef = self.db.collection("items").document(itemId)
                        guard let itemSnap = try? transaction.getDocument(itemRef),
                        let item = try? itemSnap.data(as: Item.self) else { continue }
                        transaction.updateData([
                            "listId": installedList.id,
                            "isAvailable": false
                        ], forDocument: itemRef)

                        modelItemCounts[item.modelId, default: 0] += 1
                    }
                }
                
                // 4. Update models with increments
                for (modelId, installedItemCount) in modelItemCounts {
                    let modelRef = self.db.collection("models").document(modelId)
                    
                    transaction.updateData([
                        "availableItemCount": FieldValue.increment(Int64(-installedItemCount))
                    ], forDocument: modelRef)
                }
                
                return installedList
            }
            
            return result as? RDList
        } catch {
            print("Transaction failed: \(error.localizedDescription)")
            return installedList
        }
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
    @MainActor
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
