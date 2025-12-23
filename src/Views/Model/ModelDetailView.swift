//
//  ModelDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import CachedAsyncImage
import PhotosUI
import SwiftUI

struct ModelDetailView: View {
    // Environment variables
    @Environment(\.dismiss) private var dismiss

    // Data
    @State private var viewModel: ModelViewModel

    // Presented variables
    @State private var isLoading: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showInformation: Bool = false

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
                .padding(.horizontal, 16)

                ScrollView {
                    VStack(spacing: 12) {
                        ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: .constant(false))

                        ItemListView()

                        VStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    showInformation.toggle()
                                }
                            }) {
                                HStack(spacing: 0) {
                                    Text("Information")
                                    .foregroundColor(.white)
                                    .bold()

                                    Spacer()
                                    
                                    Image(systemName: showInformation ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .background(.red)
                                .cornerRadius(6)
                            }

                            if showInformation {
                                ModelInformationView(model: viewModel.selectedModel)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .padding(.top, 4)
                    .frameHorizontalPadding()
                }
            }
            .frameTop()
            .toolbar(.hidden)
            .sheet(isPresented: $showEditSheet) {
                EditModelInformationSheet(viewModel: $viewModel)
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
            HStack(alignment: .bottom,spacing: 0) {
                Text("Item Count: ")
                    .foregroundColor(.red)
                    .bold()
                
                Text("\(viewModel.selectedModel.itemIds.count)")
                    .bold()
            }

            if !viewModel.items.isEmpty {
                let columns = [
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4)
                ]
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.items, id: \.self) { item in
                        NavigationLink(destination: ItemDetailView(item: item, model: viewModel.selectedModel)) {
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
        HStack(spacing: 8) {
            ItemModelImage(item: item, model: viewModel.selectedModel, size: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text("Available: ")
                        .foregroundColor(.secondary)  
                        .font(.footnote)                      

                    Image(systemName: item.isAvailable ? SFSymbols.checkmarkCircleFill : SFSymbols.xmarkCircleFill)
                        .foregroundColor(item.isAvailable ? .green : .red)
                        .frame(16)
                        .font(.footnote)
                    }
                    
                if item.attention {
                    HStack(spacing: 0) {
                        Text("Attention Needed: ")
                            .foregroundColor(.secondary)  
                            .font(.footnote)   

                        Image(systemName: SFSymbols.exclamationmarkTriangleFill)
                            .foregroundColor(.yellow) 
                            .frame(16)                   
                    }
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
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
