import SwiftUI


struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var modelsArray: [Model] = []
    @State private var path: NavigationPath = NavigationPath()
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    @State var selectedType: ModelType?
    @State private var isLoading: Bool = false
    
    private let fetchLimit = 20
    var TESTMODEL = Model()
    
    
    var filteredModels: [Model] {
        if searchText.isEmpty {
            return modelsArray
        } else {
            return modelsArray.filter { model in
                model.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack{
                InventoryFilterView(selectedType: $selectedType)
                
                List {
                    ForEach(filteredModels, id: \.self) { model in
                        NavigationLink(value: model) {
                            InventoryItemListView(model: model)
                        }
                        .onAppear {
                            if model == filteredModels.last {
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
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                isEditing = false
                Task {
                    isLoading = true
                    await loadInitialModels()
                    isLoading = false
                }
            }
//            .onDisappear {
//                viewModel.stopListening()
//            }
            .onChange(of: selectedType) {
                modelsArray = []
                Task {
                    isLoading = true
                    await loadInitialModels()
                    isLoading = false
                }
            }
            .navigationDestination(for: Model.self) { model in
                ModelView(path: $path, model: model, isEditing: $isEditing)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text("Inventory")
                        .font(.system(.title2, design: .default))
                        .bold()
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: CreateModelView()) {
                            Label("Add Item", systemImage: "plus")
                        }
                        NavigationLink(destination: ScanItemView()) {
                            Label("Scan Item", systemImage: "qrcode.viewfinder")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
    
    private func loadInitialModels() async {
        await viewModel.getInitialInventoryModels(selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray = fetchedModels
        }
//        for model in modelsArray {
//            print("model.name = \(model.name)")
//        }
    }
    
    private func loadMoreModels() async {
        await viewModel.getMoreInventoryModels(selectedType: selectedType, limit: fetchLimit) { fetchedModels in
            modelsArray.append(contentsOf: fetchedModels)
        }
    }
    
}

#Preview {
    InventoryView()
}
