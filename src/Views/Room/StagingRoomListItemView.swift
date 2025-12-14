//
//  StagingRoomListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import CachedAsyncImage
import SwiftUI

struct StagingRoomListItemView: View {
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
            HStack(spacing: 0) {
                Text(viewModel.selectedRoom.roomName)
                    .foregroundStyle(Color(.label))

                Spacer()

                Text("Items \(viewModel.items.count)")

                Image(systemName: showRoomPreview ? "minus" : "plus")
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
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.items, id: \.self) { item in
                    ItemListItem(
                        item: item,
                        isSelected: viewModel.selectedRoom.selectedItemIdSet.contains(item.id)
                    )
                }
            }
        }
        .task {
            if !viewModel.selectedRoom.itemModelIdMap.isEmpty {
                await viewModel.getRoomModels()
            }
        }
    }

    // MARK: Item List Item

    @ViewBuilder
    private func ItemListItem(item: Item, isSelected: Bool) -> some View {
        let model: Model? = viewModel.getModelForItem(item)

        HStack(spacing: 8) {
            Button {
                Task {
                    await toggleItemSelection(item.id)
                }
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 20))
            }
            
            Group {
                ItemPreviewImage(item: item, model: model)

                Text(model?.name ?? "No Model Name")
            }
            .opacity(isSelected ? 1.0 : 0.5)

            Spacer()
        }
    }

    // MARK: Item Preview Image

    // TODO: good place for image store or other optimization?

    @ViewBuilder
    private func ItemPreviewImage(item: Item, model: Model? = nil) -> some View {
        Group {
            if item.image.imageExists, let imageURL = item.image.imageURL {
                ItemCachedAsyncImage(imageURL: imageURL)
            } else if let modelImageURL = model?.primaryImage.imageURL {
                ItemCachedAsyncImage(imageURL: modelImageURL)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(32)
        .cornerRadius(8)
    }

    // MARK: Item Cached Async Image

    @ViewBuilder
    private func ItemCachedAsyncImage(imageURL: URL) -> some View {
        CachedAsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()                        
            case .failure:
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            @unknown default:
                Color.gray
                    .overlay(
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .foregroundColor(.white)
                    )
            }
        }
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
