//
//  RoomItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct RoomItemView: View {
    @Environment(\.dismiss) private var dismiss
    var item: Item
    @Binding var roomViewModel: RoomViewModel
    
    var body: some View {
        Text("Item ID: \(item.id)")
        
        Button {
            let added = roomViewModel.addItemToRoomDraft(item: item)
            if !added {
                // toggle a warning sheet
            }
            dismiss()
        } label: {
            Text("Add Item to room")
        }
    }
}

//#Preview {
//    RoomItemView()
//}
