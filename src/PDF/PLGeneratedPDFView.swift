//
//  PLGeneratedPDFView.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/7/25.
//

import SwiftUI

struct PLGeneratedPDFView: View {
    // MARK: Init Values

    let pullList: RDList
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
                            .padding(.horizontal, 20)

                        if !roomVM.items.isEmpty && roomVM.selectedRoom.itemModelIdMap.count > 0 {
                            VStack(spacing: 0) {
                                RoomHeader()

                                ForEach(roomVM.items, id: \.id) { item in
                                    ItemRow(item: item, roomVM: roomVM)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            Text("No items found")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(width: 850, height: 1100)
        .background(Color.white)
    }

    // MARK: Header

    @ViewBuilder
    private func Header() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pull List: \(pullList.address.getStreetAddress() ?? "")")
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 6)
            Text("Client: \(pullList.client)").font(.system(size: 12))
            Text("Install Date: \(pullList.installDate)").font(.system(size: 12))
            Text("Uninstall Date: \(pullList.uninstallDate)").font(.system(size: 12))
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: Room Header

    @ViewBuilder
    private func RoomHeader() -> some View {
        HStack(spacing: 0) {
            Text("Image")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 6)

            Text("Name")    
                .font(.system(size: 10, weight: .bold))
                .frame(width: 120, alignment: .leading)
                .padding(.leading, 6)

            Text("Item ID")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 150, alignment: .leading)
                .padding(.leading, 6)

            Text("Type")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 130, alignment: .leading)
                .padding(.leading, 6)

            Text("Location")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 150, alignment: .leading)
                .padding(.leading, 6)

            Text("Essential")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 80, alignment: .center)

            Text("QR Code")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 80, alignment: .center)
        }
        .frame(height: 25)
        .background(Color(white: 0.9))
        .overlay(Rectangle().stroke(Color(white: 0.7), lineWidth: 1))
    }

    // MARK: Item Row

    @ViewBuilder
    private func ItemRow(item: Item, roomVM: RoomViewModel) -> some View {
        let model = roomVM.modelsById[item.modelId]
        
        HStack(spacing: 0) {
            ItemImage(item)
                .frame(width: 50, height: 50, alignment: .center)
                .padding(.leading, 6)

            Text(model?.name ?? "N/A")
                .font(.system(size: 9))
                .frame(width: 120, alignment: .leading)
                .padding(.leading, 6)
                .lineLimit(2)

            Text(item.modelId)
                .font(.system(size: 9))
                .frame(width: 150, alignment: .leading)
                .padding(.leading, 6)
                .lineLimit(2)

            Text(model?.type ?? "N/A")
                .font(.system(size: 9))
                .frame(width: 130, alignment: .leading)
                .padding(.leading, 6)
                .lineLimit(1)

            Text(item.listId)
                .font(.system(size: 9))
                .frame(width: 150, alignment: .leading)
                .padding(.leading, 6)
                .lineLimit(2)

            if let model = model {
                Image(systemName: model.isEssential ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 12))
                    .foregroundColor(model.isEssential ? .green : .gray)
                    .frame(width: 80, alignment: .center)
            } else {
                Text("—")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .center)
            }

            if let qrCodeImage = item.id.generateQRCode() {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .frame(width: 80, alignment: .center)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .frame(width: 80, alignment: .center)
            }
        }
        .frame(height: 60)
        .background(Color.white)
        .overlay(Rectangle().stroke(Color(white: 0.8), lineWidth: 1))
    }

    // MARK: Item Image

    @ViewBuilder
    private func ItemImage(_ item: Item) -> some View {
        if let uiImage = preloadedImages[item.id] {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
        }
    }
}
