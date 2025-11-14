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

    init(selectedList: RDList = RDList(), rooms: [Room] = []) {
        self.selectedList = selectedList
        self.rooms = rooms

        listDocumentRef = db.collection(selectedList.listType.collectionString).document(selectedList.id)
        roomsDocumentRef = listDocumentRef.collection("rooms")
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
            for roomName in selectedList.roomIds {
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

                if selectedList != updatedPullList {
                    selectedList = updatedPullList
                }

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

    func deletePullList() async {
        do {
            let roomsSnapshot = try await selectedListReference.collection("rooms").getDocuments()

            let batch = db.batch()

            for document in roomsSnapshot.documents {
                batch.deleteDocument(document.reference)
            }

            batch.deleteDocument(selectedListReference)

            try await batch.commit()

        } catch {
            print("Error deleting PL: \(error.localizedDescription)")
        }
    }

    // MARK: Validate PL

    func validatePullList() async throws { // throws PullListValidationError
        var modelItemCounts: [String: Int] = [:] // modelId -> number of those Items that exist in PL

        // validate item availability
        for room in rooms {
            for (itemId, modelId) in room.itemModelMap {
                modelItemCounts[modelId, default: 0] += 1

                let itemRef = db.collection("items").document(itemId)
                let itemSnap = try await itemRef.getDocument() // only throws network, permission, or serialization errors

                guard itemSnap.exists else {
                    throw PullListValidationError.itemDoesNotExist(id: itemId)
                }

                if let isAvailable = itemSnap["isAvailable"] as? Bool {
                    guard isAvailable else {
                        throw PullListValidationError.itemNotAvailable(id: itemId)
                    }
                }

                // TODO: add code to validate location = warehouse when Location type is implemented
            }
        }

        // validate model availability
        for (modelId, listItemCount) in modelItemCounts {
            let modelRef = db.collection("models").document(modelId)
            let modelSnap = try await modelRef.getDocument()

            guard modelSnap.exists else {
                throw PullListValidationError.modelDoesNotExist(id: modelId)
            }

            if let availableItemCount = modelSnap["availableItemCount"] as? Int {
                if availableItemCount - listItemCount < 0 {
                    throw PullListValidationError.modelAvailableCountInvalid(id: modelId)
                }
            }
        }
    }
}

// MARK: - Installed List

extension RDListViewModel {
    // MARK: Create Installed List from Pull List

    func createInstalledFromPull() async throws -> RDList {
        let installedList = RDList(pullList: selectedList, listType: .installed_list)
        let installedListRef = db.collection("installed_lists").document(installedList.id)
        let roomsRef = installedListRef.collection("rooms")

        try await validatePullList() // will throw PullListValidationErrors

        let result = try await db.runTransaction { transaction, _ in
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
            var modelItemCounts: [String: Int] = [:]

            for room in self.rooms {
                for (itemId, modelId) in room.itemModelMap {
                    let itemRef = self.db.collection("items").document(itemId)
                    transaction.updateData([
                        "listId": installedList.id,
                        "isAvailable": false,
                    ], forDocument: itemRef)

                    modelItemCounts[modelId, default: 0] += 1
                }
            }

            // 4. Update models with increments
            for (modelId, installedItemCount) in modelItemCounts {
                let modelRef = self.db.collection("models").document(modelId)

                transaction.updateData([
                    "availableItemCount": FieldValue.increment(Int64(-installedItemCount)),
                ], forDocument: modelRef)
            }

            return installedList
        }

        guard let installedList = result as? RDList else {
            throw InstalledFromPullError.creationFailed
        }

        return installedList
    }
}

// MARK: - Room

extension RDListViewModel {
    // MARK: Create Empty Room

    func createEmptyRoom(_ roomName: String) -> Bool {
        if roomExists(newRoomName: roomName, roomNames: selectedList.roomIds) {
            return false // room not added
        } else {
            selectedList.roomIds.append(Room.roomNameToId(listId: selectedList.id, roomName: roomName))
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
