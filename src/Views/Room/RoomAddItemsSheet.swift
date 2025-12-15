//
//  RoomAddItemsSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/13/25.
//

import SwiftUI

struct RoomAddItemsSheet: View {
    // MARK: Environment Variables

    @Environment(\.dismiss) private var dismiss

    // MARK: View Parameters

    @State private var inventoryViewModel: DocumentsListViewModel = .init(.model)
    @Binding var roomViewModel: RoomViewModel
    @Binding var showSheet: Bool

    // MARK: init()

    init(roomViewModel: Binding<RoomViewModel>, showSheet: Binding<Bool>) {
        _roomViewModel = roomViewModel
        _showSheet = showSheet
    }

    // MARK: Filter Variables

    @State private var searchText: String = ""
    @State private var selectedType: ModelType?

    // MARK: State Variables

    @State var path: NavigationPath = .init()
    @State private var searchFocused: Bool = false
    @FocusState var searchTextFocused: Bool
    @State private var isLoadingModels: Bool = false

    // MARK: Body

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                if !searchTextFocused {
                    TopBar()
                }

                if searchFocused {
                    SearchBar()
                }

                ModelInventoryFilterView(selectedType: $selectedType)

                InventoryList()

                Spacer()
            }
            .frameTop()
            .frameTopPadding()
            .frameHorizontalPadding()
            .onAppear {
                Task {
                    if !isLoadingModels {
                        await fetchModels(initial: true, searchText: nil, modelType: selectedType)
                    }
                }
            }
            .onChange(of: path) {
                searchFocused = false
            }
            .onChange(of: selectedType) {
                searchText = ""
                Task {
                    await fetchModels(initial: true, searchText: nil, modelType: selectedType)
                }
            }
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    Task {
                        isLoadingModels = true
                        await fetchModels(initial: true, searchText: nil, modelType: selectedType)
                        isLoadingModels = false
                    }
                }
            }
            .navigationDestination(for: Model.self) { model in
                RoomModelView(model: model, roomViewModel: $roomViewModel)
            }
            .navigationDestination(for: Item.self) { item in
                RoomItemView(item: item, roomViewModel: $roomViewModel)
            }
        }
    }

    // MARK: Top Bar

    @ViewBuilder private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                Text("Available Inventory")
                    .font(.system(.title2, design: .default))
                    .bold()
                    .foregroundStyle(.red)
            },
            header: {
                EmptyView()
            },
            trailingIcon: {
                HStack(spacing: 12) {
                    if !searchFocused {
                        Button {
                            searchTextFocused = true
                            searchFocused = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }

                    ToolBarMenu()
                }
            }
        ).tint(.red)
    }

    // MARK: Search Bar

    @ViewBuilder private func SearchBar() -> some View {
        SearchBarComponent(
            searchText: $searchText,
            searchFocused: $searchFocused,
            searchTextFocused: $searchTextFocused,
            onSubmit: {
                Task {
                    await fetchModels(initial: true, searchText: searchText, modelType: selectedType)
                }
            }
        )
    }

    // MARK: ToolBarMenu

    @ViewBuilder private func ToolBarMenu() -> some View {
        Menu {
            NavigationLink(destination: CreateModelView()) {
                Label("Add Item", systemImage: "plus")
            }

            Label("Scan Item", systemImage: "qrcode.viewfinder")
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.red)
        }
    }

    // MARK: InventoryList

    @ViewBuilder private func InventoryList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(inventoryViewModel.documentsArray.compactMap { $0 as? Model }, id: \.self) { model in
                    NavigationLink(value: model) {
                        ModelListItemView(model: model)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if model == inventoryViewModel.documentsArray.last as? Model {
                            Task {
                                await fetchModels(initial: false, searchText: searchText.isEmpty ? nil : searchText, modelType: selectedType)
                            }
                        }
                    }
                }

                if isLoadingModels {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }

    // MARK: Fetch Models (Using the Abstracted ViewModel)

    @MainActor
    private func fetchModels(initial isInitial: Bool, searchText: String?, modelType: ModelType?) async {
        isLoadingModels = true

        var filters: [String: Any] = [:]
        filters["itemsAvailable"] = true

        if let modelType {
            filters["type"] = modelType.rawValue
        }

        if let searchText {
            filters["nameLowercased"] = searchText.lowercased()
        }

        if isInitial {
            await inventoryViewModel.fetchInitialDocuments(filters: filters)
        } else {
            await inventoryViewModel.fetchMoreDocuments(filters: filters)
        }

        isLoadingModels = false
    }
}

// #Preview {
//    RoomAddItemsSheet(room: Room.MOCK_DATA[0], showSheet: .constant(true))
// }
