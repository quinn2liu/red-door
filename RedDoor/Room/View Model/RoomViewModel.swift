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
    var selectedRoom: Room
    let pullListId: String
    
    private var roomListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    // MARK: init/deinit
    init(roomData: RoomMetadata) {
        self.selectedRoom = Room(roomName: roomData.name, listId: String(roomData.id.split(separator: ";").first ?? ""))
        self.pullListId = String(roomData.id.split(separator: ";").first ?? "")
        
        startListening()
    }
    
    deinit {
        stopListening()
    }
     
    // MARK: startListenint()
    private func startListening() {
        let roomRef = db.collection("pull_lists")
            .document(pullListId)
            .collection("rooms")
            .document(selectedRoom.id)
        
        roomListener = roomRef
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self,
                      let data = snapshot?.data(),
                      let updatedRoom = try? Firestore.Decoder().decode(Room.self, from: data)
                else { return }
                
                self.selectedRoom = updatedRoom
            }
    }
    
    // MARK: stopListening()
    private func stopListening() {
        roomListener?.remove()
    }
    
    // MARK: updateRoom
    func updateRoom() {
        let roomRef = db.collection("pull_lists")
            .document(pullListId)
            .collection("rooms")
            .document(selectedRoom.id)
            
        do {
            try roomRef.setData(from: selectedRoom)
        } catch {
            print("Error updating room: \(selectedRoom.id): \(error)")
        }
    }
}
