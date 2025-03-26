import SwiftUI

struct InventoryView: View {
    
    @State private var viewModel = DocumentsListViewModel()
    @State private var path: NavigationPath = NavigationPath()
    
    @State private var searchText: String = ""
    
    // MARK: View Modifier Variables
    @State private var selectedType: ModelType?
    @State private var isLoading: Bool = false
    @State private var searchFocused: Bool = false
    @FocusState var searchTextFocused: Bool
    
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
                
                InventoryFilterView(selectedType: $selectedType)
                
                InventoryList()
                
                Spacer()
            }
            .frameTop()
            .frameHorizontalPadding()
            .frameTopPadding()
            .onAppear {
                Task {
                    isLoading = true
                    await fetchModels(searchText: nil, modelType: selectedType)
                    isLoading = false
                }
            }
            .onChange(of: path) {
                searchFocused = false
            }
            .onChange(of: selectedType) {
                searchText = ""
                Task {
                    isLoading = true
                    await fetchModels(searchText: nil, modelType: selectedType)
                    isLoading = false
                }
            }
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    Task {
                        isLoading = true
                        await fetchModels(searchText: nil, modelType: selectedType)
                        isLoading = false
                    }
                }
            }
            .rootNavigationDestinations()
        }
    }
    
    // MARK: Fetch Models (Using the Abstracted ViewModel)
    private func fetchModels(searchText: String?, modelType: ModelType?) async {
        var filters: [String: Any] = [:]
        
        if let modelType {
            filters.updateValue(modelType, forKey: "type")
        }
        
        if let searchText {
            filters.updateValue(searchText, forKey: "name")
        }
        
        let models: [Model] = await viewModel.fetchDocuments(from: "models", matching: filters.isEmpty ? nil : filters, orderBy: "name", descending: false)
        
        viewModel.documentsArray = models
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
        )
        .tint(.red)
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
                        if searchText != "" {
                            Task {
                                isLoading = true
                                await fetchModels(searchText: searchText, modelType: selectedType)
                                isLoading = false
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
    
    // MARK: InventoryList
    @ViewBuilder private func InventoryList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                    ForEach(viewModel.documentsArray.compactMap { $0 as? Model }, id: \.self) { model in
                        NavigationLink(value: model) {
                            ModelListItemView(model: model)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if model == viewModel.documentsArray.last as? Model {
                                Task {
                                    isLoading = true
                                    await fetchModels(searchText: !searchText.isEmpty ? searchText : nil, modelType: selectedType)
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
    
}

#Preview {
    InventoryView()
}
