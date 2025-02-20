//
//  RoomViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import Foundation
import Firebase

@Observable
class RoomViewModel {
    let db = Firestore.firestore()
 
    func updateRoom(_ room: Room) {
        let roomRef = db.collection("rooms").document(room.id)
        do {
            try roomRef.setData(from: room)
        } catch {
            print("Error adding pull list: \(room.id): \(error)")
        }
    }
}
