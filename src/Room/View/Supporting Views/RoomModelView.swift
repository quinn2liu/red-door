//
//  RoomModelView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct RoomModelView: View {
    
    // MARK: Environment variables
    @Environment(\.dismiss) private var dismiss
    @State private var modelViewModel: ModelViewModel
    @Binding private var roomViewModel: RoomViewModel
    
    // MARK: State Variables
    @State private var items: [Item] = []
    @State private var showingDeleteAlert = false
    
    // MARK: RD Image Refactor
    @State private var selectedRDImage: RDImage? = nil
    @State private var isImageSelected: Bool = false

    // MARK: Initializer
    init(model: Model, roomViewModel: Binding<RoomViewModel>) {
        self.modelViewModel = ModelViewModel(selectedModel: model)
        _roomViewModel = roomViewModel
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            Form {
                ModelImages(model: $modelViewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: .constant(false))
                
                Section("Details") {
                    ModelDetailsView(isEditing: false, viewModel: $modelViewModel)
                }
                Section("Items") {
                    ItemListView(items: items, isEditing: false, viewModel: modelViewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ModelNameView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            getInitialData()
        }
        .overlay(
            ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
        )
    }
    
    // MARK: - ModelNameView()
    @ViewBuilder private func ModelNameView() -> some View {
        HStack {
            Text("Name:")
                .font(.headline)
            Text(modelViewModel.selectedModel.name)
        }
    }
    
    private func getInitialData() {
        Task {
            self.items = try await modelViewModel.getModelItems()
        }
    }
} // struct

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}

