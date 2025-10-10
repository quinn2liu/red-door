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
    static let db = Firestore.firestore()
    
    var selectedRoom: Room
    var items: [Item] = [] // for display
    var modelsById: [String: Model] = [:] // mapping modelId to model, for display
    
    var modelsLoaded = false
    
    // MARK: init/deinit
    init(room: Room) {
        self.selectedRoom = room
    }
    
    init(roomName: String, listId: String) {
        self.selectedRoom = Room(roomName: roomName, listId: listId)
    }
    
    // MARK: updateRoom
    func updateRoom() {
        let roomRef = Self.db.collection("pull_lists")
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
    
    // MARK: addItemToRoomDraft()
    func addItemToRoomDraft(item: Item) -> Bool {
        let roomRef = Self.db.collection("pull_lists").document(selectedRoom.listId).collection("rooms").document(selectedRoom.id)
        
        var itemIdsSet = Set(selectedRoom.itemModelMap.keys)
        let (inserted, _) = itemIdsSet.insert(item.id)
        if inserted { // the itemId doesn't already exist in the room's items and was added
            selectedRoom.itemModelMap.updateValue(item.modelId, forKey: item.id) // insert into map
        
            // update the room with the new item
            roomRef.updateData(["itemModelMap": selectedRoom.itemModelMap])
            return true
        } else { // itemId already exists for the room
            return false
        }
        
    }
    
    // MARK: Load Items and Models
    func loadItemsAndModels() async {
        if !selectedRoom.itemModelMap.isEmpty {
            await getRoomItems()
            await getRoomModels()
        }
    }

    // MARK: Load Items
    @MainActor
    func getRoomItems() async {
        do {
            // Query items where listId matches the room's listId and is in the room's itemIds array
            let itemIds = Array(selectedRoom.itemModelMap.keys)
            let itemsRef = Self.db.collection("items")
                .whereField("id", in: itemIds)
            
            let snapshot = try await itemsRef.getDocuments()
            
            // Parse the items
            let fetchedItems = snapshot.documents.compactMap { document -> Item? in
                try? Firestore.Decoder().decode(Item.self, from: document.data())
            }
            
            items = fetchedItems
        } catch {
            print("Error loading items for room \(selectedRoom.id): \(error)")
        }
    }

    // MARK: Load Models for Items
    @MainActor
    func getRoomModels(reloadModels: Bool = false) async {
        if !modelsLoaded || reloadModels {
            let modelIds = Set(selectedRoom.itemModelMap.values)
            
            do {
                // Fetch models with those IDs
                let modelsRef = Self.db.collection("models")
                    .whereField("id", in: Array(modelIds))
                
                let snapshot = try await modelsRef.getDocuments()
                
                // Create dictionary mapping modelId to Model - do this outside of concurrent context
                let fetchedModelTuples = try snapshot.documents.map { document -> (String, Model) in
                    let model = try Firestore.Decoder().decode(Model.self, from: document.data())
                    return (model.id, model)
                }
                
                // Create the dictionary from the array of tuples
                let modelDict = Dictionary(fetchedModelTuples, uniquingKeysWith: { (first, _) in first })
                
                modelsById = modelDict
                modelsLoaded = true
            } catch {
                print("Error loading models for items: \(error)")
            }
        }
    }
    
    // MARK: Get Model for Item
    // Helper function to easily get a model for a given item
    func getModelForItem(_ item: Item) -> Model? {
        return modelsById[item.modelId]
    }
    
    // MARK: Group Items by Room
    static func getItemsByRoom(_ room: Room) async -> [Item]? {
        do {
            // Query items where listId matches the room's listId and is in the room's itemIds array
            let itemIds = Array(room.itemModelMap.keys)
            let itemsRef = db.collection("items")
                .whereField("id", in: itemIds)
            
            let snapshot = try await itemsRef.getDocuments()
            
            // Parse the items
            let fetchedItems = snapshot.documents.compactMap { document -> Item? in
                try? Firestore.Decoder().decode(Item.self, from: document.data())
            }
            
            return fetchedItems
        } catch {
            print("Error loading items for room \(room.id): \(error)")
            return nil
        }
    }
}
