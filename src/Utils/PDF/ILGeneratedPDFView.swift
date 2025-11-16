//
//  ILGeneratedPDFView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/7/25.
//

import SwiftUI

struct ILGeneratedPDFView: View {
    // MARK: Init Values

    let installedList: RDList
    let roomViewModels: [RoomViewModel]
    let preloadedImages: [String: UIImage]

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header()

            VStack(alignment: .leading, spacing: 20) {
                ForEach(roomViewModels, id: \.selectedRoom.id) { roomVM in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Room: \(roomVM.selectedRoom.roomName)")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 40)

                        if !roomVM.items.isEmpty {
                            VStack(spacing: 0) {
                                RoomHeader()

                                ForEach(roomVM.items, id: \.id) { item in
                                    HStack(spacing: 0) {
                                        ItemImage(item)
                                            .frame(width: 60, alignment: .center)
                                            .padding(.leading, 10)

                                        Text(item.modelId)
                                            .font(.system(size: 11))
                                            .frame(width: 180, alignment: .leading)
                                            .padding(.leading, 8)

                                        Text(item.listId)
                                            .font(.system(size: 11))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                    }
                                    .frame(height: 50)
                                    .background(Color.white)
                                    .overlay(Rectangle().stroke(Color(white: 0.8), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal, 40)
                        } else {
                            Text("No items found")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(width: 612, height: 792)
        .background(Color.white)
    }

    // MARK: Header

    @ViewBuilder
    private func Header() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Installed List: \(installedList.id)")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 6)
            Text("Client: \(installedList.client)").font(.system(size: 14))
            Text("Install Date: \(installedList.installDate)").font(.system(size: 14))
            Text("Type: \(installedList.listType.rawValue)").font(.system(size: 14))
        }
        .padding(.top, 40)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }

    // MARK: Room Header

    @ViewBuilder
    private func RoomHeader() -> some View {
        HStack(spacing: 0) {
            Text("Image")
                .font(.system(size: 12, weight: .bold))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 8)

            Text("Item ID")
                .font(.system(size: 12, weight: .bold))
                .frame(width: 180, alignment: .leading)
                .padding(.leading, 8)

            Text("Location")
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
        }
        .frame(height: 25)
        .background(Color(white: 0.9))
        .overlay(Rectangle().stroke(Color(white: 0.7), lineWidth: 1))
    }

    // MARK: Item Image

    @ViewBuilder
    private func ItemImage(_ item: Item) -> some View {
        if let uiImage = preloadedImages[item.id] {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
        }
    }
}
