//
//  RoomPreviewListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import CachedAsyncImage
import SwiftUI

struct RoomListItemView: View {
    // MARK: init Variables

    @State private var viewModel: RoomViewModel

    init(room: Room) {
        _viewModel = State(initialValue: RoomViewModel(room: room))
    }

    // MARK: State Variables

    @State private var showRoomPreview: Bool = false
    @State private var selectedItemIds: Set<String> = []

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                Text(viewModel.selectedRoom.roomName)
                    .foregroundStyle(Color(.label))

                Spacer()

                Text("Items \(viewModel.selectedRoom.itemModelIdMap.count)")

                Image(systemName: showRoomPreview ? "minus" : "plus")
            }

            if showRoomPreview {
                NavigationLink(destination: RoomDetailsView(viewModel: $viewModel)) {
                    RoomPreview()
                }
            }
        }
        .task {
            await viewModel.loadItemsAndModels()
            selectedItemIds = Set(viewModel.items.map { $0.id })
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showRoomPreview.toggle()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(6)
    }

    // MARK: RoomPreview()

    @ViewBuilder
    private func RoomPreview() -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.items, id: \.self) { item in
                    ItemListItem(
                        item: item,
                        isSelected: selectedItemIds.contains(item.id)
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
    
    private func toggleItemSelection(_ itemId: String) {
        if selectedItemIds.contains(itemId) {
            selectedItemIds.remove(itemId)
        } else {
            selectedItemIds.insert(itemId)
        }
    }

    @ViewBuilder
    private func ItemListItem(item: Item, isSelected: Bool) -> some View {
        let model: Model? = viewModel.getModelForItem(item)

        HStack(spacing: 8) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.system(size: 20))
                .onTapGesture {
                    toggleItemSelection(item.id)
                }
            
            Group {
                ItemPreviewImage(item: item, model: model)

                Text(model?.name ?? "No Model Name")
            }
            .opacity(isSelected ? 1.0 : 0.5)
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
}
