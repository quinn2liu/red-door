import SwiftUI


struct InventoryView: View {
    
    @State private var viewModel = InventoryViewModel()
    @State private var path: NavigationPath = NavigationPath()
    
    @State private var searchText: String = ""
    
    // MARK: View Modifier Variables
    @State private var selectedType: ModelType?
    @State private var isLoading: Bool = false
    
    var TESTMODEL = Model()
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $path) {
            VStack{
                InventoryFilterView(selectedType: $selectedType)
                
                InventoryList()
            }
            .frameHorizontalPadding()
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
            .onSubmit(of: .search) {
                Task {
                    isLoading = true
                    await viewModel.searchInventoryModels(searchText: searchText, selectedType: selectedType)
                    isLoading = false
                }
            }
            .onAppear {
                Task {
                    isLoading = true
                    await viewModel.getInitialInventoryModels(selectedType: selectedType)
                    isLoading = false
                }
            }
            .onChange(of: selectedType) {
                searchText = ""
                Task {
                    isLoading = true
                    await viewModel.getInitialInventoryModels(selectedType: selectedType)
                    isLoading = false
                }
            }
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    Task {
                        isLoading = true
                        await viewModel.getInitialInventoryModels(selectedType: selectedType)
                        isLoading = false
                    }
                }
            }
            .rootNavigationDestinations()
        }
    }
    
    // MARK: InventoryList
    @ViewBuilder private func InventoryList() -> some View {
        LazyVStack(spacing: 12) {
            ScrollView {
                ForEach(viewModel.modelsArray, id: \.self) { model in
                    NavigationLink(value: model) {
                        ModelListItemView(model: model)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if model == viewModel.modelsArray.last {
                            Task {
                                isLoading = true
                                await viewModel.getMoreInventoryModels(searchText: !searchText.isEmpty ? searchText : nil, selectedType: selectedType)
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
