//
//  InstalledListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation

@Observable
class InstalledListViewModel: RDListViewModel {

    // MARK: Create Pull List from Installed List

    func createPullFromInstalled() async throws -> RDList {
        let pullList = RDList(list: selectedList, listType: .pull_list)
        let pullListRef = db.collection("pull_lists").document(pullList.id)
        let roomsRef = pullListRef.collection("rooms")

        let result = try await db.runTransaction { transaction, _ in
            // 1. Create pull list
            do {
                try transaction.setData(from: pullList, forDocument: pullListRef)
            } catch {
                print("Error creating pullList document: (\(error.localizedDescription))")
                return nil
            }

            // 2. Copy rooms
            for room in self.rooms {
                let roomRef = roomsRef.document(room.id)
                do {
                    try transaction.setData(from: room, forDocument: roomRef)
                } catch {
                    print("Error creating pullList rooms documents: (\(error.localizedDescription))")
                    return nil
                }
            }
            return pullList
        }

        guard let pullList = result as? RDList else {
            throw InstalledFromPullError.creationFailed
        }

        return pullList
    }
}