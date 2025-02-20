//
//  Room.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import Foundation

struct Room: Codable, Identifiable, Hashable {
    
    var id: String // listId + roomName(spaces replaced by -, lowercased), separated by ";" ex: (adslkfasdflkjasdkl;living-room)
    
    var roomName: String
    var listId: String // Id of parent list (pull list or installed list)
    var contents: [String] = [String]() // itemIDs in the room

    init(roomName: String, contents: [String] = [], listId: String) {
        self.id = listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
        self.roomName = roomName
        self.listId = listId
        self.contents = contents
    }
}


struct RoomMetadata: Codable, Identifiable, Hashable {
    var id: String // room id
    var name: String // roomName
    var itemCount: Int // number of items
    
    init(roomName: String, listId: String, itemCount: Int = 0) {
        self.id = listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
        self.name = roomName
        self.itemCount = itemCount
    }
}

extension RoomMetadata {
    static var MOCK_DATA: [RoomMetadata] = [
        .init(roomName: "Mock Living Room", listId: "Test List ID", itemCount: 5)
    ]
}
