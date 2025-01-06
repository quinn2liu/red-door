import SwiftUI


struct InventoryView: View {
    
    @State private var viewModel = ViewModel()
    @State private var modelsArray: [Model] = []
    @State private var path: NavigationPath = NavigationPath()
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    
    @State var activeType: ModelType?
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
                InventoryFilterView(activeType: $activeType)
                
                List {
                    ForEach(filteredModels) { model in
                        NavigationLink(value: model) {
                            InventoryItemListView(model: model)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search inventory")
            .onAppear {
                isEditing = false
                viewModel.getInventoryModels { fetchedModels in
                    self.modelsArray = fetchedModels
                }
            }
            .onDisappear {
                viewModel.stopListening()
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
}

#Preview {
    InventoryView()
}
