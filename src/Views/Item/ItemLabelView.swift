//
//  ItemLabelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/22/25.
//

import SwiftUI
import CachedAsyncImage

struct ItemLabelView: View {
    let item: Item
    let model: Model
    let qrCode: UIImage?
    let image: RDImage

    init(item: Item, model: Model) {
        self.item = item
        self.model = model
        self.qrCode = item.id.generateQRCode()
        image = item.image ?? model.primaryImage
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            TopBar()

            VStack(alignment: .leading, spacing: 12) {
                Text(model.name)
                    .font(.headline)
                    .foregroundColor(.red)
                    .bold()

                HStack(spacing: 0) {
                    // QR Code
                    ItemQRCodeView()

                    Spacer()

                    // Item Image
                    ItemLabelImage()
                }

                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description:")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .bold()

                    if model.description.isEmpty {
                        Text("No description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(model.description)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .frame(Constants.screenWidthPadding / 2)
                    }
                }
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            Text("QR Code")
        }, trailingIcon: {
            // TODO: SHARE BUTTON FOR PDF
            Spacer().frame(width: 32)
        })
    }

    // MARK: - Item QR Code View

    @ViewBuilder
    private func ItemQRCodeView() -> some View {
        if let qrCode: UIImage = qrCode {
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFill()
                .frame(Constants.screenWidthPadding / 2)
        } else {
            Text("Error Generating QR Code")
                .foregroundColor(.red)
        }
    }

    // MARK: Item Image
    @ViewBuilder
    private func ItemLabelImage() -> some View {
        let size = Constants.screenWidthPadding / 2
        
        if let imageURL = image.imageURL {
            CachedAsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(size)
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(size)
                        .cornerRadius(12)
                        .clipped()
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color(.systemGray6))
                        .frame(size)
                        .overlay(Image(systemName: SFSymbols.photoBadgePlus)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.systemGray6))
                .frame(size)
                .overlay(Image(systemName: SFSymbols.photoBadgePlus)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.secondary)
                )
        }
    }

    // MARK: Item Label Share Link
    // @ViewBuilder
    // private func ItemLabelShareLink() -> some View {
    //     ShareLink(
    //         item: QRCodeImage(data: qrCode.pngData()),
    //         preview: SharePreview(item.id, image: Image(uiImage: qrCode))
    //     )
    // }
}