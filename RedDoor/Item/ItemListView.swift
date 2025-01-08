//
//  ItemListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/8/25.
//

import SwiftUI

struct ItemListView: View {
    
    var item: Item
    @State var model: Model?
    @State private var errorMessage: String?
    var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Group {
            if let model {
                HStack {
                    Text(model.name)
                    Text(item.id)
                    Text(model.type)
                    Text(item.repair.description)
                    Text(item.pullListId)
                }
            } else if let errorMessage {
                HStack {
                    Text("Error:")
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            guard self.model != nil else {
                getItemModel()
                return
            }
        }
    }
    
    private func getItemModel() {
        viewModel.getItemModel(modelId: item.modelId) { result in
            switch result {
            case .success(let model):
                self.model = model
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
}

//#Preview {
//    ItemListView()
//}
