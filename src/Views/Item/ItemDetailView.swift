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
    private let model: Model

    @State private var showEditSheet: Bool = false
    @State private var backupItem: Item? = nil

    @State private var showQRCode: Bool = false
    @State private var qrCode: UIImage? = nil

    init(item: Item, model: Model) {
        viewModel = ItemViewModel(selectedItem: item)
        self.model = model
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()
                    .padding(.horizontal, 16)

                ScrollView {
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            VStack(spacing: 6) {
                                Text("Model Image:")
                                    .foregroundColor(.red)
                                    .bold()
                                CachedAsyncImage(url: model.primaryImage.imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(48)
                                        .cornerRadius(8)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(Color(.systemGray6))
                                        .frame(width: Constants.screenWidthPadding / 2, height: Constants.screenWidthPadding / 2)
                                        .overlay(Image(systemName: SFSymbols.photoBadgePlus)
                                            .font(.largeTitle)
                                            .bold()
                                            .foregroundColor(.secondary)
                                        )
                                }
                            }

                            Spacer()

                            VStack(spacing: 6) {
                                Text("Item Image:")
                                    .foregroundColor(.red)
                                    .bold()
                                ItemImage(itemImage: $viewModel.selectedItem.image, isEditing: false)
                            }
                        }
                        

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("Item ID: ")
                                    .foregroundColor(.red)
                                    .bold()
                                
                                Text(viewModel.selectedItem.id)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .frameHorizontalPadding()
                }
            }
            .frameTop()
            .toolbar(.hidden)
            .fullScreenCover(isPresented: $showQRCode) {
                ItemQRCodeView()
            }
            .sheet(isPresented: $showEditSheet) {
                ItemEditSheet(viewModel: $viewModel)
            }
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
            HStack(spacing: 8) {
                RDButton(variant: .red, size: .icon, leadingIcon: "qrcode", fullWidth: false) {
                    showQRCode = true
                }
                .clipShape(Circle())

                RDButton(variant: .red, size: .icon, leadingIcon: "square.and.pencil", fullWidth: false) {
                    showEditSheet = true
                    backupItem = viewModel.selectedItem
                }
                .clipShape(Circle())
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
                            Image(systemName: SFSymbols.squareAndArrowUp)
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
}
