//
//  InventoryPullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/13/25.
//

import SwiftUI


struct RoomAddItemsSheet: View {
    // MARK: Environment Variables
    @Environment(\.dismiss) private var dismiss
    
    // MARK: View Parameters
    @State private var inventoryViewModel: InventoryViewModel = InventoryViewModel()
    @Binding var roomViewModel: RoomViewModel
    @Binding var showSheet: Bool
    
    // MARK: Filter Variables
    @State private var searchText: String = ""
    @State private var selectedType: ModelType?
    @State private var isLoading: Bool = false
    
    // MARK: State Variables
    @FocusState var searchFocused: Bool
    @State var path: NavigationPath = NavigationPath()
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 16) {
                if !searchFocused {
                    HStack(spacing: 0) {
                        Text("Add Items: \(roomViewModel.selectedRoom.roomName)")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                
                SearchBar()
                
                InventoryFilterView(selectedType: $selectedType)
                
                InventoryList()
                
                Spacer()
            }
            .navigationDestination(for: Model.self) { model in
                RoomModelView(model: model, roomViewModel: $roomViewModel)
            }
            .navigationDestination(for: Item.self) { item in
                RoomItemView(item: item, room: roomViewModel.selectedRoom)
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .onAppear {
            Task {
                isLoading = true
                await inventoryViewModel.getInitialInventoryModels(selectedType: selectedType)
                isLoading = false
            }
        }
        .onDisappear {
            showSheet = false
        }
        .onChange(of: selectedType) {
            inventoryViewModel.modelsArray = []
            Task {
                isLoading = true
                await inventoryViewModel.getInitialInventoryModels(selectedType: selectedType)
                isLoading = false
            }
        }
        .onChange(of: searchText) {
            if (searchText.isEmpty) {
                Task {
                    inventoryViewModel.modelsArray = []
                    isLoading = true
                    await inventoryViewModel.getInitialInventoryModels(selectedType: selectedType)
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: Inventory List
    @ViewBuilder private func InventoryList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(inventoryViewModel.modelsArray, id: \.self) { model in
                    NavigationLink(value: model) {
                        ModelListItemView(model: model)
                    }
                    .onAppear {
                        if model == inventoryViewModel.modelsArray.last {
                            Task {
                                isLoading = true
                                await inventoryViewModel.getMoreInventoryModels(searchText: !searchText.isEmpty ? searchText : nil, selectedType: selectedType)
                                isLoading = false
                            }
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
    
    // MARK: Search Bar
    @ViewBuilder private func SearchBar() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("", text: $searchText, prompt: Text("Search..."))
                    .font(.footnote)
                    .focused($searchFocused)
                    .onSubmit {
                        Task {
                            isLoading = true
                            await inventoryViewModel.searchInventoryModels(searchText: searchText, selectedType: selectedType)
                            isLoading = false
                        }
                    }
            }
            .padding(8)
            .clipShape(.rect(cornerRadius: 8))
            
            if searchFocused {
                Button("Cancel") {
                    searchText = ""
                    searchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.bouncy(duration: 0.5), value: searchFocused)
    }
}

#Preview {
    @Previewable @State var viewModel = RoomViewModel(roomData: RoomMetadata.MOCK_DATA[0])
    RoomAddItemsSheet(roomViewModel: $viewModel, showSheet: .constant(true))
}
