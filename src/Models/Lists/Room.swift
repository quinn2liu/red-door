//
//  Room.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import Foundation

struct Room: Codable, Identifiable, Hashable {
    // TODO: don't love coupling meaning into the ID
    var id: String // listId + roomName(spaces replaced by -, lowercased), separated by ";" ex: (adslkfasdflkjasdkl;living-room)

    var roomName: String
    var listId: String // Id of parent list (pull list or installed list)
    var itemModelMap: [String: String] = [:]

    init(roomName: String, listId: String, itemToModelIds: [String: String] = [:]) {
        id = listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
        self.roomName = roomName
        self.listId = listId
        itemModelMap = itemToModelIds
    }
}

extension Room {
    static func roomNameToId(listId: String, roomName: String) -> String {
        return listId + ";" + roomName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
    }

    static var MOCK_DATA: [Room] = [
        .init(roomName: "test room name", listId: "test list id"),
    ]
}
