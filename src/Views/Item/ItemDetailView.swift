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
    @State private var model: Model? = nil

    @State private var showEditSheet: Bool = false
    @State private var backupItem: Item? = nil

    @State private var showQRCode: Bool = false
    @State private var qrCode: UIImage? = nil

    init(item: Item, model: Model? = nil) {
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
                                ModelImageView()
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
                if let model: Model = model {
                    ItemLabelView(item: viewModel.selectedItem, model: model, )
                } else {
                    Text("Error loading item. Please try again.")
                }
            }
            .sheet(isPresented: $showEditSheet) {
                ItemEditSheet(viewModel: $viewModel)
            }
            .task {
                if model == nil {
                    model = await Item.getItemModel(modelId: viewModel.selectedItem.modelId)
                }
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

    // MARK: - Model Image View

    @ViewBuilder
    private func ModelImageView() -> some View {
        if let model: Model = model {
            CachedAsyncImage(url: model.primaryImage.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(Constants.screenWidthPadding / 2)
                    .cornerRadius(8)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(.systemGray6))
                    .frame(Constants.screenWidthPadding / 2)
                    .overlay(Image(systemName: SFSymbols.photoBadgePlus)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.secondary)
                    )
            }
        } else {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.systemGray6))
                .frame(Constants.screenWidthPadding / 2)
                .overlay(Image(systemName: SFSymbols.photoBadgePlus)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.secondary)
                )
        }
    }
}
