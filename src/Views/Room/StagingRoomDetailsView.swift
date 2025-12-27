//
//  StagingRoomDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/4/25.
//

import CachedAsyncImage
import SwiftUI

struct StagingRoomDetailsView: View {
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

    @State private var showItems: Bool = false
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            RoomItemList()
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
            RDButton(variant: .red, size: .icon, leadingIcon: "arrow.counterclockwise", iconBold: true, fullWidth: false) { 
                Task {
                    await roomViewModel.loadItemsAndModels()
                    }
                }
                .clipShape(Circle())
            }
        )
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
