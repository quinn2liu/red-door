import SwiftUI

struct ModelInventoryView: View {
    
    @State private var viewModel = DocumentsListViewModel(.model)
    @State private var path: NavigationPath = NavigationPath()
    
    // MARK: Filter Variables
    @State private var searchText: String = ""
    @State private var selectedType: ModelType?
    
    // MARK: View Modifier Variables
    @State private var isLoadingModels: Bool = false
    @State private var searchFocused: Bool = false
    @FocusState private var searchTextFocused: Bool
    
    @State private var showCreateModelCover: Bool = false
    
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
            .rootNavigationDestinations(path: $path)
            .fullScreenCover(isPresented: $showCreateModelCover) {
                CreateModelView()
            }
        }
    }
    
    // MARK: Top Bar
    @ViewBuilder
    private func TopBar() -> some View {
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
                            searchFocused = true
                            searchTextFocused = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    
                    NavigationLink(destination: ScanItemView()) {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    
                    Button {
                        showCreateModelCover = true
                    } label: {
                        Image(systemName: "plus")
                    }
//                    NavigationLink(destination: CreateItemview()) {
//                        Image(systemName: "plus")
//                    }
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
            await viewModel.fetchInitialDocuments(filters: filters)
        } else {
            await viewModel.fetchMoreDocuments(filters: filters)
        }

        DispatchQueue.main.async {
            isLoadingModels = false
        }
    }
}

#Preview {
    ModelInventoryView()
}
