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
    var itemIds: [String] = [String]() // itemIDs in the room

    init(roomName: String, contents: [String] = [], listId: String) {
        self.id = listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
        self.roomName = roomName
        self.listId = listId
        self.itemIds = contents
    }
}

extension Room {
    static var MOCK_DATA: [Room] = [
        .init(roomName: "test room name", listId: "test list id")
    ]
}
