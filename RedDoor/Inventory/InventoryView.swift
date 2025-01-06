import SwiftUI


struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var modelsArray: [Model] = []
    @State private var path: NavigationPath = NavigationPath()
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    
    @State var selectedType: ModelType?
    
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
                    ForEach(filteredModels.indices, id: \.self) { index in
                        let model = modelsArray[index]
                        NavigationLink(value: model) {
                            InventoryItemListView(model: model)
                        }
//                        .onAppear {
//                            if index == filteredModels.count - 1 {
//                                loadMoreItems()
//                            }
//                        }
                    }
                }
            }
            
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                isEditing = false
                viewModel.getInventoryModels(selectedType: selectedType) { fetchedModels in
                    self.modelsArray = fetchedModels
                }
//                viewModel.resetPagination()
//                loadMoreItems()
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .onChange(of: selectedType) {
                viewModel.getInventoryModels(selectedType: selectedType) { fetchedModels in
                    self.modelsArray = fetchedModels
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
    
//    private func loadMoreItems() {
//        viewModel.getInventoryModels(limit: fetchLimit) { newModels in
//            self.modelsArray.append(contentsOf: newModels)
//        }
//    }
    
}

#Preview {
    InventoryView()
}
