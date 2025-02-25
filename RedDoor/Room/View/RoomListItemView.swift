//
//  RoomListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI
import CachedAsyncImage

struct RoomListItemView: View {
    
    // MARK: init Variables
    @State private var viewModel: RoomViewModel
    
    init(room: Room) {
        _viewModel = State(initialValue: RoomViewModel(room: room))
    }
    
    // MARK: State Variables
    @State private var showItems: Bool = false

    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 12) {
                Text(viewModel.selectedRoom.roomName)
                    .foregroundStyle(Color(.label))
                        
                Spacer()
                
                Text("Items \(viewModel.selectedRoom.itemIds.count)")
                
                Button {
                    showItems.toggle()
                } label: {
                    Image(systemName: showItems ? "minus" : "plus")
                }
            }
            
            if showItems {
                RoomItemList()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadItemsAndModels()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: RoomItemList()
    
    @ViewBuilder private func RoomItemList() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.items, id: \.self) { item in
                NavigationLink(destination: RoomItemView(item: item, room: viewModel.selectedRoom)) { // MARK: RoomItemView should take in a viewmodel
                    RoomItemListItem(item)
                }
            }
        }
    }
    
    // MARK: RoomItemListItem()
    @ViewBuilder private func RoomItemListItem(_ item: Item) -> some View {
        HStack(spacing: 12) {
            if let model = viewModel.getModelForItem(item) {
                if !model.imageIDs.isEmpty, let imageURL = model.imageURLDict[model.imageIDs[0]] {
                    CachedAsyncImage(url: URL(string: imageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(.headline)
                        .foregroundStyle(Color(.label))
                    
                    HStack {
                        Text(model.type)
                        Text("•")
                        Text(model.primaryColor)
                        Text("•")
                        Text(model.primaryMaterial)
                    }
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray))
                }
            } else {
                // Fallback if model isn't loaded yet
                Text(item.id)
                    .foregroundStyle(Color(.label))
            }
            
            Spacer()
            
            // Show repair status if applicable
            if item.repair {
                Image(systemName: "wrench.fill")
                    .foregroundStyle(Color.yellow)
            }
        }
    }
    
    // MARK: RoomItemView
    
}

#Preview {
    RoomListItemView(room: Room.MOCK_DATA[0])
}
