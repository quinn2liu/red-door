//
//  ItemDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import CachedAsyncImage
import SwiftUI

struct ItemDetailView: View {
    @Environment(NavigationCoordinator.self) var coordinator
    @State private var viewModel: ItemViewModel

    @State private var showEditSheet: Bool = false
    @State private var backupItem: Item? = nil

    @State private var showQRCode: Bool = false
    @State private var qrCode: UIImage? = nil

    init(item: Item) {
        viewModel = ItemViewModel(selectedItem: item)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            Text("Item ID: \(viewModel.selectedItem.id)")

            Button("Delete Item") {
                Task {
                    await viewModel.deleteItem()
                }
                coordinator.resetSelectedPath()
            }
        }
        .fullScreenCover(isPresented: $showQRCode) {
            ItemQRCodeView()
        }
        .frameTop()
        .frameVerticalPadding()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .sheet(isPresented: $showEditSheet) {
            ItemEditSheet()
        }
    }

    // MARK: - Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            Text(viewModel.selectedItem.id)
        }, trailingIcon: {
            HStack(spacing: 12) {
                Button {
                    showQRCode = true
                } label: {
                    Image(systemName: "qrcode")
                }

                Button {
                    showEditSheet = true
                    backupItem = viewModel.selectedItem
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        })
    }

    // MARK: - Item QR Code View

    @ViewBuilder
    private func ItemQRCodeView() -> some View {
        let qrCodeImage: UIImage? = viewModel.selectedItem.id.generateQRCode()
        VStack(spacing: 0) {
            TopAppBar(leadingIcon: {
                BackButton()
            }, header: {
                Text("QR Code")
            }, trailingIcon: {
                Group {
                    if #available(iOS 17, *), let qrCode: UIImage = qrCodeImage, let imageData: Data = qrCode.pngData() {
                        ShareLink(
                            item: QRCodeImage(data: imageData),
                            preview: SharePreview(
                                viewModel.selectedItem.id,
                                image: Image(uiImage: qrCode)
                            )
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            })

            Spacer()

            if let qrCode: UIImage = qrCodeImage {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Error Generating QR Code")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .toolbar(.hidden)
    }

    // MARK: - Item Edit Sheet

    @ViewBuilder
    private func ItemEditSheet() -> some View {
        VStack(spacing: 16) {
            Button {
                showEditSheet = false
            } label: {
                Text("Exit")
            }
            Text("Edit Item")
            Text("Item ID: \(viewModel.selectedItem.id)")
            Text("Model ID: \(viewModel.selectedItem.modelId)")
            Text("List ID: \(viewModel.selectedItem.listId)")
            Text("Attention: \(viewModel.selectedItem.attention.description)")
            Text("Is Available: \(viewModel.selectedItem.isAvailable.description)")
            CachedAsyncImage(url: viewModel.selectedItem.image.imageURL) // curently no way to set item image
        }
    }
}
