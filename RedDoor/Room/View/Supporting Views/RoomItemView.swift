//
//  RoomItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct RoomItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ItemViewModel
    var room: Room
    
    init(item: Item, room: Room) {
        self.viewModel = ItemViewModel(selectedItem: item)
        self.room = room
    }
    
    var body: some View {
        Text("Item ID: \(viewModel.selectedItem.id)")
        
        Button {
            viewModel.addItemToRoomDraft(room: room)
            dismiss()
        } label: {
            Text("Add Item to room")
        }
    }
}

//#Preview {
//    RoomItemView()
//}
