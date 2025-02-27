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
    @State private var showSheet: Bool = false
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 16){
            HStack(spacing: 0) {
                Text(viewModel.selectedRoom.roomName)
                    .foregroundStyle(Color(.label))
                        
                Spacer()
                
                if !isEditing {
                    Text("Items \(viewModel.selectedRoom.itemIds.count)")
                }
                
                Button {
                    if isEditing {
                        isEditing = false
                    } else {
                        showItems.toggle()
                    }
                } label: {
                    if isEditing {
                        Text("Cancel")
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: showItems ? "minus" : "plus")
                    }
                }
            }
            
            if showItems {
                RoomItemList()
                
                EditRoomMenu()
            }
        }
        .sheet(isPresented: $showSheet) {
            RoomAddItemsSheet(roomViewModel: $viewModel, showSheet: $showSheet)
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
            if isEditing {
                Image(systemName: "xmark")
                    .frame(maxWidth: 16, maxHeight: 16)
                    .foregroundStyle(Color(.systemGray))
                    .padding(6)
                    .background(.red)
                    .clipShape(Circle())
            } else {
                if item.repair {
                    Image(systemName: "wrench.fill")
                        .foregroundStyle(Color.yellow)
                }
            }
        }
    }
    
    // MARK: EditRoomMenu()
    @ViewBuilder private func EditRoomMenu() -> some View {
        
        HStack(spacing: 0) {
            if isEditing {
                TransparentButton(backgroundColor: .red, foregroundColor: .red, text: "Delete Room") {
                    // viewModel.deleteRoom
                }
                
                Spacer()
                
                
                TransparentButton(backgroundColor: .green, foregroundColor: .green, text: "Add Items") {
                    showSheet = true
                }
                
                Spacer()
                
                TransparentButton(backgroundColor: .gray, foregroundColor: .gray, text: "Save") {
                    isEditing = true
                }
            } else {
                TransparentButton(backgroundColor: .gray, foregroundColor: .gray, text: "Edit") {
                    isEditing = true
                }
            }
        }
    }
    
}

#Preview {
    @Previewable @State var showAddItemsSheet = false
    RoomListItemView(room: Room.MOCK_DATA[0])
}
