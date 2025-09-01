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
    @State private var inventoryViewModel: DocumentsListViewModel = DocumentsListViewModel(.model)
    @Binding var roomViewModel: RoomViewModel
    @Binding var showSheet: Bool
    
    // MARK: init()
    init(roomViewModel: Binding<RoomViewModel>, showSheet: Binding<Bool>) {
        self._roomViewModel = roomViewModel
        self._showSheet = showSheet
    }
    
    // MARK: Filter Variables
    @State private var searchText: String = ""
    @State private var selectedType: ModelType?
    
    // MARK: State Variables
    @State var path: NavigationPath = NavigationPath()
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
                Text("Inventory")
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
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("", text: $searchText, prompt: Text("Search..."))
                    .submitLabel(.search)
                    .focused($searchTextFocused)
                    .onSubmit {
                        if !searchText.isEmpty {
                            Task {
                                await fetchModels(initial: true, searchText: searchText, modelType: selectedType)
                            }
                        }
                        searchTextFocused = false
                        searchFocused = false
                    }
            }
            .padding(8)
            .clipShape(.rect(cornerRadius: 8))
            
            if searchTextFocused {
                Button("Cancel") {
                    searchText = ""
                    searchTextFocused = false
                    searchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.bouncy(duration: 0.5), value: searchTextFocused)
    }
    
    // MARK: ToolBarMenu
    @ViewBuilder private func ToolBarMenu() -> some View {
        Menu {
            NavigationLink(destination: CreateModelView()) {
                Label("Add Item", systemImage: "plus")
            }
            NavigationLink(destination: ScanItemView()) {
                Label("Scan Item", systemImage: "qrcode.viewfinder")
            }
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
    private func fetchModels(initial isInitial: Bool, searchText: String?, modelType: ModelType?) async {
        var filters: [String: Any] = [:]
        
        if let modelType {
            filters.updateValue(modelType, forKey: "type")
        }
        
        if let searchText {
            filters.updateValue(searchText.lowercased(), forKey: "nameLowercased")
        }
        
        DispatchQueue.main.async {
            isLoadingModels = true
        }

        if isInitial {
            await inventoryViewModel.fetchInitialDocuments(filters: filters)
        } else {
            await inventoryViewModel.fetchMoreDocuments(filters: filters)
        }

        DispatchQueue.main.async {
            isLoadingModels = false
        }
    }
    
}

//#Preview {
//    RoomAddItemsSheet(room: Room.MOCK_DATA[0], showSheet: .constant(true))
//}
