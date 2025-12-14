//
//  RDListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation
import PhotosUI
import SwiftUI

@Observable
class RDListViewModel {
    // current data
    var selectedList: RDList
    var rooms: [Room]

    // firebase
    let db: Firestore = Firestore.firestore()
    let listDocumentRef: DocumentReference
    let roomsDocumentRef: CollectionReference

    // MARK: init
    
    init(selectedList: RDList = RDList(), rooms: [Room] = []) {
        self.selectedList = selectedList
        self.rooms = rooms

        listDocumentRef = db.collection(selectedList.listType.collectionString).document(selectedList.id)
        roomsDocumentRef = listDocumentRef.collection("rooms")
    }

    var selectedListReference: DocumentReference {
        return db.collection(selectedList.listType.collectionString).document(selectedList.id)
    }

    // MARK: Update RDList

    func updateSelectedList() {
        do {
            try selectedListReference.setData(from: selectedList, merge: true)
        } catch {
            print("Error updating RDList: \(selectedList.id): \(error)")
        }
    }

    // MARK: Refresh PL

    @MainActor
    func refreshRDList() async {
        do {
            let document = try await selectedListReference.getDocument()

            if let data: [String : Any] = document.data() {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let updatedRDList = try JSONDecoder().decode(RDList.self, from: jsonData)

                if selectedList != updatedRDList {
                    selectedList = updatedRDList
                }

                await loadRooms()
            }
        } catch {
            print("Error refreshing RDList: \(error.localizedDescription)")
        }
    }

    // MARK: Delete RDList

    // TODO: UPDATE THE LOCATIONS OF ITEMS IF THIS HAPPENS

    func deleteRDList() async {
        do {
            let roomsSnapshot = try await selectedListReference.collection("rooms").getDocuments()

            let batch = db.batch()

            for document in roomsSnapshot.documents {
                batch.deleteDocument(document.reference)
            }

            batch.deleteDocument(selectedListReference)

            try await batch.commit()

        } catch {
            print("Error deleting RDList: \(error.localizedDescription)")
        }
    }
}

// MARK: - Room

extension RDListViewModel {

    // MARK: Create Empty Room (doesn't exist in firebase)

    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, roomNames: selectedList.roomIds) {
            return false // room not added
        } else {
            selectedList.roomIds.append(Room.roomNameToId(listId: selectedList.id, roomName: roomName))
            rooms.append(Room(roomName: roomName, listId: selectedList.id))
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
