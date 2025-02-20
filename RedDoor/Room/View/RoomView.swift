//
//  RoomView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import SwiftUI

struct RoomView: View {
    
    @State var viewModel: RoomViewModel = RoomViewModel()
    var room: Room
    
    var body: some View {
        VStack(spacing: 0) {
            Text(room.roomName)
        }.frameTop()
    }
}

#Preview {
    RoomView(room: Room.MOCK_DATA[0])
}
