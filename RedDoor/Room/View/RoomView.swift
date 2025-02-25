//
//  RoomView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/17/25.
//

import SwiftUI

struct RoomView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: View Parameters
    @State var viewModel: RoomViewModel
    
    // MARK: init()
    init(room: Room) {
        self._viewModel = State(initialValue: RoomViewModel(room: room))
    }
    
    // MARK: State Variables
    @State private var isEditing: Bool = false
    @State private var showAddItemsSheet: Bool = false
    
    // MARK: Body()
    var body: some View {
        VStack(spacing: 16) {
            
            TopBar()
            
            Button {
                showAddItemsSheet = true
            } label: {
                Text("Add Items")
            }
            
            RoomContents()
            
        }
        .sheet(isPresented: $showAddItemsSheet) {
            // TODO: rename this to room add items, and pass in the room
            RoomAddItemsSheet(roomViewModel: $viewModel, showSheet: $showAddItemsSheet)
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
    }
    
    // MARK: TopBar()
    @ViewBuilder
    private func TopBar() -> some View {
        
        TopAppBar(leadingIcon: {
            if isEditing {
                Button {
                    isEditing = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.blue)
                }
            } else {
                BackButton()
            }
        }, header: {
            if isEditing {
                TextField("", text: $viewModel.selectedRoom.roomName)
                    .padding(6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            } else {
                Text(viewModel.selectedRoom.roomName)
            }
        }, trailingIcon: {
            Button {
                if isEditing {
                    viewModel.updateRoom()
                }
                isEditing.toggle()
            } label: {
                Text(isEditing ? "Save" : "Edit")
                    .foregroundStyle(isEditing ? .blue : .red)
                    .fontWeight(isEditing ? .semibold : .regular)
            }
        })
    }
    
    // MARK: RoomContents()
    @ViewBuilder private func RoomContents() -> some View {
        
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.selectedRoom.itemIds, id: \.self) { itemId in
                    Text("itemId: \(itemId)")
                }
            }
        }
        
    }
    
}

#Preview {
    RoomView(room: Room.MOCK_DATA[0])
}
