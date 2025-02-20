//
//  InventoryPullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/13/25.
//

import SwiftUI


struct PullListAddItemsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = InventoryViewModel()
    @State private var modelsArray: [Model] = []
    @Binding var showSheet: Bool
    @FocusState var isSearchFocused: Bool
    
    // MARK: Filter Variables
    @State private var searchText: String = ""
    @State private var selectedType: ModelType?
    @State private var isLoading: Bool = false
    private let fetchLimit = 20
    
    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                Text("Add Items")
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
            
            SearchBar()
            
            InventoryFilterView(selectedType: $selectedType)
            
            InventoryList()
            
            Spacer()
            
        }
        
        .frameTop()
        
        //        .rootNavigationDestinations()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .onAppear {
            Task {
                isLoading = true
                await loadInitialModels()
                isLoading = false
            }
        }
        .onDisappear {
            showSheet = false
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
    }
    
    // MARK: Inventory List
    @ViewBuilder private func InventoryList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(modelsArray, id: \.self) { model in
                    NavigationLink(value: model) {
                        ModelListItemView(model: model)
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
    }
    
    // MARK: Search Bar
    @ViewBuilder private func SearchBar() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("", text: $searchText, prompt: Text("Search..."))
                    .font(.footnote)
                    .focused($isSearchFocused)
                    .onSubmit {
                        Task {
                            isLoading = true
                            await searchModels()
                            isLoading = false
                        }
                    }
            }
            .padding(8)
            .clipShape(.rect(cornerRadius: 8))
            
            if isSearchFocused {
                Button("Cancel") {
                    searchText = ""
                    isSearchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.bouncy(duration: 0.5), value: isSearchFocused)
    }
    
    // MARK: Load Content Functions
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
    PullListAddItemsSheet(showSheet: .constant(true))
}
