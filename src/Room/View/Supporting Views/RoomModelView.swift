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

    // MARK: Image variables
    @State private var selectedImage: UIImage? = nil
    @State private var isImageFullScreen: Bool = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    // MARK: State Variables
    @State private var items: [Item] = []
    @State private var showingDeleteAlert = false

    // MARK: Initializer
    init(model: Model, roomViewModel: Binding<RoomViewModel>) {
        self.modelViewModel = ModelViewModel(selectedModel: model)
        _roomViewModel = roomViewModel
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Images") {
                    if !modelViewModel.images.isEmpty {
                        ModelImagesView(images: $modelViewModel.images, selectedImage: $selectedImage, isImageFullScreen: $isImageFullScreen, isEditing: false)
                    } else {
                        Text("No Images")
                    }
                }
                
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
            ModelImageOverlay(selectedImage: selectedImage, isImageFullScreen: $isImageFullScreen)
                .animation(.easeInOut(duration: 0.3), value: isImageFullScreen)
        )
    }
    
    // MARK: ModelNameView()
    @ViewBuilder private func ModelNameView() -> some View {
        HStack {
            Text("Name:")
                .font(.headline)
            Text(modelViewModel.selectedModel.name)
        }
    }
    
    
    
    private func getInitialData() {
        modelViewModel.loadImages()
        modelViewModel.getModelItems { result in
            switch result {
            case .success(let items):
                self.items = items
            case .failure(let error):
                print("Error fetching items: \(error)")
            }
        }
    }
} // struct

//#Preview {
//    ItemView(path: Binding<NavigationPath>, model: Model(), isAdding: true, isEditing: true)
//}

