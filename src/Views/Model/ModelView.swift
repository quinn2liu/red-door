//
//  ModelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import CachedAsyncImage
import PhotosUI
import SwiftUI

struct ModelView: View {
    // Environment variables
    @Environment(\.dismiss) private var dismiss

    // Data
    @State private var viewModel: ModelViewModel

    // Presented variables
    @State private var isLoading: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showEditingItems: Bool = false
    @State private var showDetails: Bool = false

    // Image selected variables
    @State private var selectedRDImage: RDImage?
    @State private var isImageSelected: Bool = false

    // Initializer
    init(model: Model, editable _: Bool = true) {
        viewModel = ModelViewModel(model: model)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()
                ScrollView {
                    ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: .constant(false))

                    ItemListView()

                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                showDetails.toggle()
                            }
                        }) {
                            HStack(spacing: 0) {
                                Text("Details")
                                .foregroundColor(.white)
                                .bold()

                                Spacer()
                                
                                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(.red)
                            .cornerRadius(6)
                        }

                        if showDetails {
                            ModelDetailsView(viewModel: $viewModel)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
            .frameTop()
            .frameHorizontalPadding()
            .toolbar(.hidden)
            .sheet(isPresented: $showEditSheet) {
                EditModelDetailsSheet(viewModel: $viewModel, onDelete: {
                    dismiss()
                })
            }
            .sheet(isPresented: $showEditingItems) {
                EditItemsSheet()
            }
            .overlay(
                ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
            )
            .task {
                await loadItems()
            }

            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("Saving Model...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .shadow(radius: 10)
            }
        }
    }

    // MARK: Model Name

    @ViewBuilder
    private func ModelNameView() -> some View {
        HStack {
            Text("Name:")
                .font(.headline)
            Text(viewModel.selectedModel.name)
        }
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                BackButton()
            },
            header: {
                ModelNameView()
            },
            trailingIcon: {
                RDButton(variant: .red, size: .icon, leadingIcon: "square.and.pencil", iconBold: true, fullWidth: false) {
                    showEditSheet = true
                }
                .clipShape(Circle())
            }
        )
    }

    // MARK: - Item List View

    @ViewBuilder
    private func ItemListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("Item Count: ")
                    .foregroundColor(.red)
                    .bold()
                
                Text("\(viewModel.selectedModel.itemIds.count)")
                    .bold()
            }

            if !viewModel.items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            ItemListItem(item)
                        }
                    }
                }
            }
        }
    }

    // MARK: Item List Item

    @ViewBuilder
    private func ItemListItem(_ item: Item) -> some View {
        let model = viewModel.selectedModel

        HStack {
            if let itemImage = item.image, itemImage.imageExists {
                CachedAsyncImage(url: itemImage.imageURL)
            } else {
                Image(systemName: SFSymbols.photoBadgePlus)
            }
            Text(item.id)
            Text(model.type)
            Text(item.attention.description)
        }
    }

    // MARK: EditItemsSheet

    // TODO: maybe put this in separate file...?
    @ViewBuilder
    private func EditItemsSheet() -> some View {
        ForEach(viewModel.items, id: \.self) { item in
            ItemListItem(item)
        }
    }

    // MARK: - Helper Functions

    private func loadItems() async {
        do {
            viewModel.items = try await viewModel.getModelItems()
        } catch {
            print("Error loading model items: \(error.localizedDescription)")
        }
    }
}
