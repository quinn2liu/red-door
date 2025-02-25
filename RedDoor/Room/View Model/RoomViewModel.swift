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
    var items: [Item] = [] // for display
    var models: [String: Model] = [:] // mapping modelId to model, for display
    
    private var roomListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    // MARK: init/deinit
    init(room: Room) {
        self.selectedRoom = room
        
        startListening()
    }
    
    init(roomName: String, listId: String) {
        self.selectedRoom = Room(roomName: roomName, listId: listId)
        
        startListening()
    }
    
    deinit {
        stopListening()
    }
     
    // MARK: startListenint()
    private func startListening() {
        let roomRef = db.collection("pull_lists")
            .document(selectedRoom.listId)
            .collection("rooms")
            .document(selectedRoom.id)
        
        roomListener = roomRef
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self,
                      let data = snapshot?.data(),
                      let updatedRoom = try? Firestore.Decoder().decode(Room.self, from: data)
                else { return }
                
                // Check if itemIds changed BEFORE updating selectedRoom
                let currentItemIds = Set(self.selectedRoom.itemIds)
                let newItemIds = Set(updatedRoom.itemIds)
                let itemIdsChanged = currentItemIds != newItemIds
                
                print("selectedRoom.ids: \(self.selectedRoom.itemIds), updatedRoom.ids: \(updatedRoom.itemIds)")
                print("itemIdsChanged: \(itemIdsChanged)")
                
                if itemIdsChanged {
                    print("itemIds changed from \(currentItemIds) to \(newItemIds)")
                    
                    // Update room
                    if self.selectedRoom != updatedRoom {
                        self.selectedRoom = updatedRoom
                        
                    }
                    // Reload items and models
                    Task {
                        await self.loadItemsAndModels()
                    }
                } else {
                    // Just update the room without triggering a reload
                    if self.selectedRoom != updatedRoom {
                        self.selectedRoom = updatedRoom
                    }
                }
            }
    }
    // MARK: stopListening()
    private func stopListening() {
        roomListener?.remove()
    }
    
    // MARK: updateRoom
    func updateRoom() {
        let roomRef = db.collection("pull_lists")
            .document(selectedRoom.listId)
            .collection("rooms")
            .document(selectedRoom.id)
            
        do {
            try roomRef.setData(from: selectedRoom)
        } catch {
            print("Error updating room: \(selectedRoom.id): \(error)")
        }
    }
    
    static func roomNameToId(roomName: String, listId: String) -> String {
        return listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
    }
}

// MARK: Models + Items
extension RoomViewModel {
    
    // MARK: Load Items and Models
    func loadItemsAndModels() async {
        if !selectedRoom.itemIds.isEmpty {
            await loadItems()
            await loadModelsForItems()
        }
    }

    // MARK: Load Items
    private func loadItems() async {
        do {
            // Query items where listId matches the room's listId and is in the room's itemIds array
            let itemsRef = db.collection("items")
                .whereField("id", in: selectedRoom.itemIds)
            
            let snapshot = try await itemsRef.getDocuments()
            
            // Parse the items
            let fetchedItems = snapshot.documents.compactMap { document -> Item? in
                try? Firestore.Decoder().decode(Item.self, from: document.data())
            }
            
            // Update the items on the main thread
            await MainActor.run {
                self.items = fetchedItems
            }
        } catch {
            print("Error loading items for room \(selectedRoom.id): \(error)")
        }
    }

    // MARK: Load Models for Items
    private func loadModelsForItems() async {
        // Only proceed if we have items
        guard !items.isEmpty else { return }
        
        // Get unique modelIds from the items
        let modelIds = Set(items.map { $0.modelId })
        
        do {
            // Fetch models with those IDs
            let modelsRef = db.collection("models")
                .whereField("id", in: Array(modelIds))
            
            let snapshot = try await modelsRef.getDocuments()
            
            // Create dictionary mapping modelId to Model - do this outside of concurrent context
            let fetchedModels = snapshot.documents.compactMap { document -> (String, Model)? in
                guard let model = try? Firestore.Decoder().decode(Model.self, from: document.data()) else {
                    return nil
                }
                return (model.id, model)
            }
            
            // Create the dictionary from the array of tuples
            let modelDict = Dictionary(uniqueKeysWithValues: fetchedModels)
            
            // Update the models dictionary on the main thread
            await MainActor.run {
                self.models = modelDict
            }
        } catch {
            print("Error loading models for items: \(error)")
        }
    }
    // MARK: Get Model for Item
    // Helper function to easily get a model for a given item
    func getModelForItem(_ item: Item) -> Model? {
        return models[item.modelId]
    }
}
