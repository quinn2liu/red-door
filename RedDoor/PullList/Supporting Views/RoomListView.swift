//
//  RoomListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct RoomListView: View {
    
    var roomName: String
    var items: [Item]
    
    var body: some View {
        HStack {
            Text(roomName)
            Spacer()
            Image(systemName: "plus")
        }
    }
}

#Preview {
    RoomListView(roomName: "testing room", items: [])
}