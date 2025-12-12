//
//  PullListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseFirestore

@Observable
class PullListViewModel: RDListViewModel {
    // MARK: Create Installed List from Pull List

    func createInstalledFromPull() async throws -> RDList {
        let installedList = RDList(list: selectedList, listType: .installed_list)
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
                for (itemId, modelId) in room.itemModelIdMap {
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

    // MARK: Validate PL

    func validatePullList() async throws { // throws PullListValidationError
        var modelItemCounts: [String: Int] = [:] // modelId -> number of those Items that exist in PL

        // validate item availability
        for room in rooms {
            for (itemId, modelId) in room.itemModelIdMap {
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

    // MARK: Create Pull List

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
            print("Error creating pull list: \(selectedList.id): \(error)")
        }
    }
}