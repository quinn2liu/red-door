    //
    //  ModelView.swift
    //  RedDoor
    //
    //  Created by Quinn Liu on 8/13/24.
    //

    import SwiftUI
    import PhotosUI

    struct ModelView: View {
        // MARK: Environment variables
        @Environment(\.dismiss) private var dismiss
        @State private var viewModel: ModelViewModel
        
        // MARK: State variables
        @State private var isEditing: Bool = false
        @State private var items: [Item] = []
        @State private var showingDeleteAlert = false
        
        // MARK: Image selected variables
        @State private var selectedRDImage: RDImage?
        @State private var isImageSelected: Bool = false
        
        // MARK: Initializer
        init(model: Model, editable: Bool = true) {
            self.viewModel = ModelViewModel(selectedModel: model)
        }
        
        // MARK: - Body
        var body: some View {
            VStack(spacing: 12) {
                TopBar()
                
                ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditing)
                                
                ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
                
                ItemListView(items: items, isEditing: isEditing, viewModel: viewModel)
                
                HStack {
                    if isEditing {
                        Button("Delete Model") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .alert(
                            "Confirm Delete",
                            isPresented: $showingDeleteAlert
                        ) {
                            
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteModelFirebase()
                                    dismiss()
                                }
                            } label: {
                                Text("Delete")
                            }
                            
                            Button(role: .cancel) {
                                viewModel.selectedModel.primaryImage.uiImage = nil
                            } label: {
                                Text("Cancel")
                            }
                        }
                    } else {
                        Button("Add Item to Pull List") { }
                    }
                    
                }.padding(.top)
            }
            .frameTop()
            .frameHorizontalPadding()
            .toolbar(.hidden)
            .overlay(
                ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
            )
            .onAppear {
                getInitialData()
            }
        }
        
        // MARK: ModelNameView()
        @ViewBuilder
        private func ModelNameView() -> some View {
            if isEditing {
                HStack {
                    TextField("", text: $viewModel.selectedModel.name)
                        .padding(6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            } else {
                HStack {
                    Text("Name:")
                        .font(.headline)
                    Text(viewModel.selectedModel.name)
                }
            }
        }
        
        private func getInitialData() {
            viewModel.getModelItems { result in
                switch result {
                case .success(let items):
                    self.items = items
                case .failure(let error):
                    print("Error fetching items: \(error)")
                }
            }
        }
        
        // MARK: - Top Bar
        @ViewBuilder
        private func TopBar() -> some View {
            TopAppBar(
                leadingIcon: {
                    if isEditing {
                        Button {
                            isEditing = false
                        } label: {
                            Text("Cancel")
                        }
                    } else {
                        BackButton()
                    }
                },
                header: {
                    ModelNameView()
                },
                trailingIcon: {
                    Button {
                        if isEditing {
                            saveModel()
                        } else {
                            isEditing = true
                        }
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            )
        }
        
        // MARK: - saveModel()
        private func saveModel() {
            if isEditing {
                isEditing = false
                Task {
                    await viewModel.updateModel()
                    viewModel.getModelItems { result in
                        switch result {
                        case .success(let items):
                            self.items = items
                        case .failure(let error):
                            print("Error fetching items: \(error)")
                        }
                    }
                }
            }
        }
        
    }
