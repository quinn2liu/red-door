//
//  PlanningRoomDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/4/25.
//

import CachedAsyncImage
import SwiftUI

struct PlanningRoomDetailsView: View {
    // MARK: init Variables
    
    private var parentList: RDList
    private var rooms: [Room]
    @Binding var roomViewModel: RoomViewModel

    init(parentList: RDList, rooms: [Room], roomViewModel: Binding<RoomViewModel>) {
        self.parentList = parentList
        self.rooms = rooms
        _roomViewModel = roomViewModel
    }

    // MARK: State Variables

    @State private var showSheet: Bool = false
    @State private var isEditing: Bool = false


    // MARK: Body
    
    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            HStack(spacing: 0) {
                SmallCTA(type: .default, leadingIcon: SFSymbols.arrowCounterclockwise, text: "Refresh") { 
                    Task {
                        await roomViewModel.loadItemsAndModels()
                    }
                }
                
                Spacer()

                SmallCTA(type: .red, leadingIcon: SFSymbols.plus, text: "Add Items") { 
                    showSheet = true
                }
            }

            RoomItemList()
        }
        .sheet(isPresented: $showSheet) {
            RoomAddItemsSheet(roomViewModel: $roomViewModel, showSheet: $showSheet)
        }
        .onAppear {
            if !roomViewModel.items.isEmpty {
                Task {
                    await roomViewModel.loadItemsAndModels()
                }
            }
        }
        .onChange(of: roomViewModel.selectedRoom.itemModelIdMap) { // TODO: not auto-reload?
            Task {
                await roomViewModel.loadItemsAndModels()
            }
        }
        .toolbar(.hidden)
        .frameTop()
        .frameTopPadding()
        .frameHorizontalPadding()
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            Text(roomViewModel.selectedRoom.roomName)
        }, trailingIcon: {
            RoomDetailsMenu()
        }
        )
    }

    // MARK: Room Details Menu

    @ViewBuilder
    private func RoomDetailsMenu() -> some View {
        Menu {
            Button("Edit Room", systemImage: SFSymbols.pencil) {
                isEditing = true
            }

            Button("Delete Room", systemImage: SFSymbols.trash) {
                // Task {
                //     await roomViewModel.deleteRoom()
                // }
            }
        } label: {
            RDButton(variant: .red, size: .icon, leadingIcon: SFSymbols.ellipsis, iconBold: true, fullWidth: false, action: {})    
                .clipShape(Circle())
        }
    }

    // MARK: Room Item List

    @ViewBuilder
    private func RoomItemList() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(roomViewModel.items, id: \.self) { item in
                NavigationLink(destination: StagingRoomItemView(roomViewModel: $roomViewModel, parentList: parentList, rooms: rooms, item: item)) {
                    RoomItemListItem(item)
                }
            }
        }
    }

    // MARK: Room Item List Item

    @ViewBuilder
    private func RoomItemListItem(_ item: Item) -> some View {
        HStack(spacing: 12) {
            if let model = roomViewModel.getModelForItem(item) {
                if let uiImage = model.primaryImage.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                } else if let imageUrl = model.primaryImage.imageURL {
                    CachedAsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                    } placeholder: {
                        Color.gray
                    }
                } else {
                    Image(systemName: SFSymbols.photoBadgeExclamationmark)
                        .foregroundStyle(.gray)
                        .frame(width: 40, height: 40)
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

            if item.attention {
                Spacer()

                Image(systemName: SFSymbols.wrenchFill)
                    .foregroundStyle(Color.yellow)
            }
        }
    }
}
