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
        VStack(alignment: .leading, spacing: 16) {
            RoomPreviewHeader()
            
            if showRoomPreview {
                NavigationLink(destination: PlanningRoomDetailsView(parentList: parentList, rooms: rooms, roomViewModel: $viewModel)) {
                    RoomPreview()
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(6)
        .task {
            await viewModel.loadItemsAndModels()
        }
    }

    // MARK: Room Preview Header

    @ViewBuilder
    private func RoomPreviewHeader() -> some View {
        HStack(spacing: 12) {
            RDButton(variant: .outline, size: .icon, leadingIcon: showRoomPreview ? SFSymbols.minus : SFSymbols.plus, iconBold: true, fullWidth: false) {
                showRoomPreview.toggle()
            }

            Text(viewModel.selectedRoom.roomName)
                .foregroundColor(.primary)

            Spacer()

            (
                Text("Items: ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                +
                Text("\(viewModel.items.count)")
                    .font(.caption)
                    .foregroundColor(.red)
            )

            NavigationLink(destination: PlanningRoomDetailsView(parentList: parentList, rooms: rooms, roomViewModel: $viewModel)) {
                Image(systemName: SFSymbols.chevronRight)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(8)
                    .frame(32)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.red)
                    )
            }
        }
    }

    // MARK: Room Preview

    @ViewBuilder
    private func RoomPreview() -> some View {
        HStack(spacing: 0) {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120, maximum: 200)),
                GridItem(.adaptive(minimum: 120, maximum: 200))
            ], spacing: 4) {
                ForEach(viewModel.items, id: \.self) { item in
                    ItemListItem(item: item)
                }
            }
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
