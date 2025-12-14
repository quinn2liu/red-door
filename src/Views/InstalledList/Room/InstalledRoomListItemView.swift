//
//  InstalledRoomListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/13/25.
//

import CachedAsyncImage
import SwiftUI

struct InstalledRoomListItemView: View {
    // MARK: init Variables

    @State private var viewModel: RoomViewModel

    init(room: Room) {
        _viewModel = State(initialValue: RoomViewModel(room: room))
    }

    // MARK: State Variables

    @State private var showRoomPreview: Bool = false

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
        let columns = [
            GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 12),
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(viewModel.modelsById.values), id: \.self) { model in
                    ModelPreviewImage(model: model)
                }
            }
            .padding()
        }
        .task {
            if !viewModel.selectedRoom.itemModelIdMap.isEmpty {
                await viewModel.getRoomModels()
            }
        }
    }

    @ViewBuilder
    private func ModelPreviewImage(model: Model) -> some View {
        CachedAsyncImage(url: model.primaryImage.imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
            case .failure:
                Color.gray
                    .overlay(
                        Image(systemName: "xmark.octagon")
                            .foregroundColor(.white)
                    )
                    .aspectRatio(1, contentMode: .fill)
            @unknown default:
                EmptyView()
                    .aspectRatio(1, contentMode: .fill)
            }
        }
    }
}