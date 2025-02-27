//
//  RoomItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct RoomItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var itemViewModel: ItemViewModel
    @Binding var roomViewModel: RoomViewModel
    
    init(item: Item, roomViewModel: Binding<RoomViewModel>) {
        self.itemViewModel = ItemViewModel(selectedItem: item)
        _roomViewModel = roomViewModel
    }
    
    var body: some View {
        Text("Item ID: \(itemViewModel.selectedItem.id)")
        
        Button {
            roomViewModel.addItemToRoomDraft(item: itemViewModel.selectedItem)
            dismiss()
        } label: {
            Text("Add Item to room")
        }
    }
}

//#Preview {
//    RoomItemView()
//}
