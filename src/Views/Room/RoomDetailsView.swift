//
//  RoomDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/4/25.
//

import CachedAsyncImage
import SwiftUI

struct RoomDetailsView: View {
    // MARK: init Variables

    @Binding var viewModel: RoomViewModel

    // MARK: State Variables

    @State private var showItems: Bool = false
    @State private var showSheet: Bool = false
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            RoomItemList()
        }
        .sheet(isPresented: $showSheet) {
            RoomAddItemsSheet(roomViewModel: $viewModel, showSheet: $showSheet)
        }
        .onAppear {
            if !viewModel.items.isEmpty {
                Task {
                    await viewModel.loadItemsAndModels()
                }
            }
        }
        .onChange(of: viewModel.selectedRoom.itemModelIdMap) { // TODO: not auto-reload?
            Task {
                await viewModel.loadItemsAndModels()
            }
        }
        .toolbar(.hidden)
        .frameTop()
        .frameTopPadding()
        .frameHorizontalPadding()
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: TopBar()

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            Text(viewModel.selectedRoom.roomName)
        }, trailingIcon: {
            Menu("Edit") {
                EditRoomMenu()
            }
        })
    }

    // MARK: RoomItemList()

    @ViewBuilder
    private func RoomItemList() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.items, id: \.self) { item in
                NavigationLink(destination: RoomItemView(item: item, roomViewModel: $viewModel)) { // MARK: RoomItemView should take in a viewmodel

                    RoomItemListItem(item)
                }
            }
        }
    }

    // MARK: RoomItemListItem()

    @ViewBuilder
    private func RoomItemListItem(_ item: Item) -> some View {
        HStack(spacing: 12) {
            if let model = viewModel.getModelForItem(item) {
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
                    Image(systemName: "photo.badge.exclamationmark")
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

                Image(systemName: "wrench.fill")
                    .foregroundStyle(Color.yellow)
            }
        }
    }

    // MARK: EditRoomMenu()

    @ViewBuilder
    private func EditRoomMenu() -> some View {
        Group {
            Button {

            } label: {
                HStack(spacing: 0) { // TODO: replace with label item
                    Text("Delete Room")

                    Spacer()
                }
            }

            Button {
                showSheet = true
            } label: {
                HStack(spacing: 0) {
                    Text("Add Items")

                    Spacer()
                }
            }
        }
    }
}
