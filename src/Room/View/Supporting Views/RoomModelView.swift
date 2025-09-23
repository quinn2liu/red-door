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
    @State private var showingDeleteAlert = false
    
    // MARK: RD Image Refactor
    @State private var selectedRDImage: RDImage? = nil
    @State private var isImageSelected: Bool = false

    // MARK: Initializer
    init(model: Model, roomViewModel: Binding<RoomViewModel>) {
        self.modelViewModel = ModelViewModel(model: model)
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
                    ModelItemListView(viewModel: modelViewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ModelNameView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadItems()
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
    
    // MARK: loadItems()
    private func loadItems() async {
        do {
            modelViewModel.items = try await modelViewModel.getModelItems()
        } catch {
            print("Error loading model items: \(error.localizedDescription)")
        }
    }
}

