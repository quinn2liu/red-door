//
//  RoomListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct RoomListItemView: View {
    
    var roomName: String
    var itemIds: [String]
    @State private var showItems: Bool = false
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(roomName)
                    .onTapGesture {
                        showSheet = true
                    }
                
                Spacer()
                
                Button {
                    showItems.toggle()
                } label: {
                    Image(systemName: showItems ? "minus" : "plus")
                        .fontWeight(.semibold)
                }
            }
            
            if showItems {
                ForEach(itemIds, id: \.self) { itemId in
                    HStack(spacing: 0) {
                        Text(itemId)
                    }
                }
            }
        }
        
    }
}

#Preview {
    RoomListItemView(roomName: "testing room", itemIds: [], showSheet: .constant(true))
}
