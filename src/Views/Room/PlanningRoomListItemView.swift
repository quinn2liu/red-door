//
//  PreviewRoomListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct PreviewRoomListItemView: View {
    // MARK: init Variables

    @State private var viewModel: RoomViewModel
    private var parentList: RDList
    private var rooms: [Room]

    @State private var showRoomPreview: Bool = false

    init(room: Room, parentList: RDList, rooms: [Room]) {
        _viewModel = State(initialValue: RoomViewModel(room: room))
        self.parentList = parentList
        self.rooms = rooms
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text(viewModel.selectedRoom.roomName)

                (
                    Text("Items: ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    +
                    Text("\(viewModel.items.count)")
                        .font(.caption)
                        .foregroundColor(.red)
                )

                Spacer()

                Image(systemName: showRoomPreview ? SFSymbols.minus : SFSymbols.plus)
                    .bold()
                    .foregroundColor(.secondary)
            }

            if showRoomPreview {
                NavigationLink(destination: StagingRoomDetailsView(parentList: parentList, rooms: rooms, roomViewModel: $viewModel)) {
                    RoomPreview()
                }
            }
        }
        .task {
            await viewModel.loadItemsAndModels()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showRoomPreview.toggle()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(6)
    }

    // MARK: Room Preview

    @ViewBuilder
    private func RoomPreview() -> some View {
        HStack(spacing: 0) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.items, id: \.self) { item in
                    ItemListItem(
                        item: item
                    )
                }

            }

            Spacer()

            Image(systemName: SFSymbols.chevronRight)
                .bold()
                .foregroundColor(.secondary)
        }
        .task {
            if viewModel.selectedRoom.itemModelIdMap.isEmpty {
                await viewModel.getRoomModels()
            }
        }
    }

    // MARK: Item List Item

    @ViewBuilder
    private func ItemListItem(item: Item) -> some View {
        let model: Model? = viewModel.getModelForItem(item)

        HStack(spacing: 8) {            
            ItemModelImage(item: item, model: model)

            Group {
                Text(model?.name ?? "No Model Name")

                Image(systemName: Model.typeMap[model?.type ?? ""] ?? "nosign")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray4))
        .cornerRadius(6)
    }


    // MARK: toggleItemSelection()
    private func toggleItemSelection(_ itemId: String) async {
        if viewModel.selectedRoom.selectedItemIdSet.contains(itemId) {
            await viewModel.deselectItem(itemId: itemId)
        } else {
            await viewModel.selectItem(itemId: itemId)
        }
    }
}
