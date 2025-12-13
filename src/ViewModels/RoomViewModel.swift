//
//  RoomViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import Firebase
import Foundation

@Observable
class RoomViewModel {
    static let db = Firestore.firestore()
    var roomRef: DocumentReference {
        return Self.db.collection("pull_lists")
                .document(selectedRoom.listId)
                .collection("rooms")
                .document(selectedRoom.id)
    }

    var selectedRoom: Room
    var items: [Item] = [] // for display
    var modelsById: [String: Model] = [:] // mapping modelId to model, for display

    var modelsLoaded = false

    // MARK: init

    init(room: Room) {
        selectedRoom = room
    }

    init(roomName: String, listId: String) {
        selectedRoom = Room(roomName: roomName, listId: listId)
    }

    // MARK: updateRoom

    func updateRoom() {
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

extension RoomViewModel {
    // MARK: Add Item to Room

    func addItemToRoom(item: Item) -> Bool {
        let itemIdsSet = Set(selectedRoom.itemModelIdMap.keys)
        if !itemIdsSet.contains(item.id) { // the itemId doesn't already exist in the room's items and was added
            selectedRoom.itemModelIdMap.updateValue(item.modelId, forKey: item.id) // insert into map

            // update the room with the new item
            roomRef.updateData(["itemModelIdMap": selectedRoom.itemModelIdMap])
            return true
        } else { // itemId already exists for the room
            return false
        }
    }

    // MARK: Add Item to Separate Room

    func moveItemToSeparateRoom(item: Item, newRoomId: String) async -> Bool {
        let newRoomRef = Self.db.collection("pull_lists").document(selectedRoom.listId).collection("rooms").document(newRoomId)
        
        do {
            let result = try await Self.db.runTransaction { transaction, _ -> Any? in
                // Read both room documents within the transaction
                let newRoomSnapshot: DocumentSnapshot
                let currentRoomSnapshot: DocumentSnapshot
                
                do {
                    newRoomSnapshot = try transaction.getDocument(newRoomRef)
                } catch {
                    print("Error reading new room document: \(error)")
                    return nil
                }
                
                do {
                    currentRoomSnapshot = try transaction.getDocument(self.roomRef)
                } catch {
                    print("Error reading current room document: \(error)")
                    return nil
                }
                
                guard var newRoom = try? newRoomSnapshot.data(as: Room.self) else {
                    return nil
                }
                
                guard var currentRoom = try? currentRoomSnapshot.data(as: Room.self) else {
                    return nil
                }
                
                // Check if item already exists in the new room or doesn't exist in the source room
                let newRoomItemIdSet = Set(newRoom.itemModelIdMap.keys)
                guard !newRoomItemIdSet.contains(item.id) else {
                    print("ERROR: Item \(item.id) already exists in target room \(newRoom.roomName)")
                    return nil
                }
                
                let currentRoomItemIdSet = Set(currentRoom.itemModelIdMap.keys)
                guard currentRoomItemIdSet.contains(item.id) else {
                    print("ERROR: Item \(item.id) doesn't exist in source room \(currentRoom.roomName)")
                    return nil
                }
                
                newRoom.itemModelIdMap.updateValue(item.modelId, forKey: item.id)
                currentRoom.itemModelIdMap.removeValue(forKey: item.id)
                
                self.selectedRoom.itemModelIdMap = currentRoom.itemModelIdMap
                transaction.updateData(["itemModelIdMap": newRoom.itemModelIdMap], forDocument: newRoomRef)
                transaction.updateData(["itemModelIdMap": currentRoom.itemModelIdMap], forDocument: self.roomRef)
                
                return true
            }
            
            return result != nil
        } catch {
            print("Error moving item \(item.id) to separate room: \(error)")
            return false
        }
    }
    
    // MARK: Load Items and Models

    func loadItemsAndModels() async {
        if !selectedRoom.itemModelIdMap.isEmpty {
            await getRoomItems()
            await getRoomModels()
        }
    }

    // MARK: Load Items

    @MainActor
    func getRoomItems() async {
        do {
            // Query items where listId matches the room's listId and is in the room's itemIds array
            let itemIds = Array(selectedRoom.itemModelIdMap.keys)
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
            let modelIds = Set(selectedRoom.itemModelIdMap.values)

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
                let modelDict = Dictionary(fetchedModelTuples, uniquingKeysWith: { first, _ in first })

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
            let itemIds = Array(room.itemModelIdMap.keys)
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

    // MARK: Remove Item from Room

    @MainActor
    func deselectItem(itemId: String) async {
        do {
            selectedRoom.selectedItemIdSet.remove(itemId)
            let selectedItemIdsArray: [String] = Array(selectedRoom.selectedItemIdSet)
            try await roomRef.updateData(["selectedItemIdSet": selectedItemIdsArray])
        } catch {
            print("Error deselecting item \(itemId): \(error)")
        }
    }

    // MARK: Add Item to Room

    @MainActor
    func selectItem(itemId: String) async {
        do {
            selectedRoom.selectedItemIdSet.insert(itemId)
            let selectedItemIdsArray: [String] = Array(selectedRoom.selectedItemIdSet)
            try await roomRef.updateData(["selectedItemIdSet": selectedItemIdsArray])
        } catch {
            print("Error selecting item \(itemId): \(error)")
        }
    }
}
