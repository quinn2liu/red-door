//
//  InventoryPullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/13/25.
//

import SwiftUI


struct InventoryPullListView: View {
    
    @State private var viewModel = InventoryViewModel()
    @State private var modelsArray: [Model] = []
    @State private var path: NavigationPath = NavigationPath()
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var selectedType: ModelType?
    @State private var isLoading: Bool = false
    
    private let fetchLimit = 20
    var TESTMODEL = Model()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack{
                InventoryFilterView(selectedType: $selectedType)
                
                InventoryList()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                Task {
                    isLoading = true
                    await searchModels()
                    isLoading = false
                }
            }
            .onAppear {
                isEditing = false
                Task {
                    isLoading = true
                    await loadInitialModels()
                    isLoading = false
                }
            }
            .onChange(of: selectedType) {
                modelsArray = []
                Task {
                    isLoading = true
                    await loadInitialModels()
                    isLoading = false
                }
            }
            .onChange(of: searchText) {
                if (searchText.isEmpty) {
                    Task {
                        modelsArray = []
                        isLoading = true
                        await loadInitialModels()
                        isLoading = false
                    }
                }
            }
            .rootNavigationDestinations()
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text("Inventory")
                        .font(.system(.title2, design: .default))
                        .bold()
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolBarMenu()
                }
            }
        }
    }
    
    @ViewBuilder private func InventoryList() -> some View {
        List {
            ForEach(modelsArray, id: \.self) { model in
                NavigationLink(value: model) {
                    InventoryItemListView(model: model)
                }
                .onAppear {
                    if model == modelsArray.last && !searchText.isEmpty {
                        Task {
                            isLoading = true
                            await loadMoreSearchResults()
                            isLoading = false
                        }
                    } else if model == modelsArray.last {
                        Task {
                            isLoading = true
                            await loadMoreModels()
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
    
    private func searchModels() async {
        await viewModel.searchInventoryModels(searchText: searchText, selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray = fetchedModels
        }
    }
    
    private func loadMoreSearchResults() async {
        await viewModel.getMoreInventoryModels(searchText: searchText, selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray.append(contentsOf: fetchedModels)
        }
    }
    
    private func loadInitialModels() async {
        await viewModel.getInitialInventoryModels(selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray = fetchedModels
        }
    }
    
    private func loadMoreModels() async {
        await viewModel.getMoreInventoryModels(searchText: nil, selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray.append(contentsOf: fetchedModels)
        }
    }
    
}

#Preview {
    InventoryView()
}
