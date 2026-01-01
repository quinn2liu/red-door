//
//  StagingRoomItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct StagingRoomItemView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var roomViewModel: RoomViewModel
    var parentList: RDList
    var rooms: [Room]
    var item: Item

    @State private var showOtherRoomSheet: Bool = false
    @State private var roomToMoveTo: Room? = nil
    @State private var showMovedAlert: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Item ID: \(item.id)")

            Button {
                showOtherRoomSheet = true
            } label: {
                Text("Move Item to Separate Room")
            }
        }
        .sheet(isPresented: $showOtherRoomSheet) {
            OtherRoomSheet()
        }
    }
    
    @ViewBuilder
    private func OtherRoomSheet() -> some View {
        VStack(spacing: 16) {
            Text(parentList.address.getStreetAddress() ?? parentList.address.formattedAddress)

            Text("Other Rooms:")
            LazyVStack(spacing: 12) {
                ForEach(rooms, id: \.self) { room in
                    if room.id != roomViewModel.selectedRoom.id {
                        Button {
                            Task {
                                showOtherRoomSheet = false
                                let added = await roomViewModel.moveItemToNewRoom(item: item, newRoomId: room.id)
                                if added {
                                    roomToMoveTo = room
                                    showMovedAlert = true
                                }
                            }
                        } label: {
                            Text(room.roomName)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .alert("Item Moved", isPresented: $showMovedAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            if let roomToMoveTo = roomToMoveTo {
                Text("Item has been moved to the \(roomToMoveTo.roomName).")
            } else {
                Text("Item has been moved to the selected room.")
            }
        }
    }
}

// #Preview {
//    RoomItemView()
// }
