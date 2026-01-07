//
//  MoveItemRoomSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct MoveItemRoomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var roomViewModel: RoomViewModel
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    let parentList: RDList
    let item: Item
    let rooms: [Room]

    var body: some View {
        VStack(spacing: 16) {
            Text(parentList.address.getStreetAddress() ?? parentList.address.formattedAddress)

            Text("Other Rooms:")
            LazyVStack(spacing: 12) {
                ForEach(rooms, id: \.self) { otherRoom in
                    if otherRoom.id != roomViewModel.selectedRoom.id {
                        Button {
                            Task {
                                dismiss()
                                let added = await roomViewModel.moveItemToNewRoom(item: item, newRoomId: otherRoom.id)
                                if added {
                                    showAlert = true
                                    alertMessage = "Item has been moved to \(otherRoom.roomName)."
                                }
                            }
                        } label: {
                            Text(otherRoom.roomName)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .presentationDetents([.medium])
    }
}