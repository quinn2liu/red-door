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
        HStack(spacing: 12) {
            Text(roomMetadata.name)
                .foregroundStyle(Color(.label))
                    
            Spacer()
            
            Group {
                Text("Items: \(roomMetadata.itemCount)")
                
                Image(systemName: "chevron.right")
            }.foregroundStyle(Color(.systemGray))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    RoomMetadataListItemView(roomMetadata: RoomMetadata.MOCK_DATA[0])
}
