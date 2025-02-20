//
//  RoomListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct RoomMetadataListItemView: View {
    
    var roomMetadata: RoomMetadata
    @State private var showItems: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(roomMetadata.name)
                
                Spacer()
                
                Button {
                    showItems.toggle()
                } label: {
                    Image(systemName: showItems ? "minus" : "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        
    }
}

#Preview {
    RoomMetadataListItemView(roomMetadata: RoomMetadata.MOCK_DATA[0])
}
