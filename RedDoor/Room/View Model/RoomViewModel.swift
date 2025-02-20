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
    
    var selectedRoom: Room?
    
    let db = Firestore.firestore()
 
    private var roomListener: ListenerRegistration?
        
    func startListening(pullListId: String, roomId: String) {
        let roomRef = db.collection("pull_lists")
            .document(pullListId)
            .collection("rooms")
            .document(roomId)
        
        roomListener = roomRef
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(),
                      let updatedRoom = try? Firestore.Decoder().decode(Room.self, from: data) else { return }
                
                self?.selectedRoom = updatedRoom
            }
    }
    
    func stopListening() {
        roomListener?.remove()
    }
    
    func updateRoom(_ room: Room) {
        let roomRef = db.collection("rooms").document(room.id)
        do {
            try roomRef.setData(from: room)
        } catch {
            print("Error adding pull list: \(room.id): \(error)")
        }
    }
}
