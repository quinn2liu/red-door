    //
    //  ModelView.swift
    //  RedDoor
    //
    //  Created by Quinn Liu on 8/13/24.
    //

    import SwiftUI
    import PhotosUI

    struct ModelView: View {
        // Environment variables
        @Environment(\.dismiss) private var dismiss
        @State private var isEditing: Bool = false

        // Data
        @State private var viewModel: ModelViewModel
        @State private var items: [Item] = []
        @State private var backupModel: Model?
        
        // Presented variables
        @State private var showDeleteAlert: Bool = false
        @State private var isLoading: Bool = false
        
        // Image selected variables
        @State private var selectedRDImage: RDImage?
        @State private var isImageSelected: Bool = false
        
        // Initializer
        init(model: Model, editable: Bool = true) {
            self.viewModel = ModelViewModel(selectedModel: model)
        }
        
        // MARK: - Body
        var body: some View {
            ZStack {
                VStack(spacing: 12) {
                    TopBar()
                    
                    ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditing)
                                    
                    ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
                    
                    ItemListView(items: items, isEditing: isEditing, viewModel: viewModel)
                    
                    HStack {
                        if isEditing {
                            Button("Delete Model") {
                                showDeleteAlert = true
                            }
                            .foregroundColor(.red)
                            .alert(
                                "Confirm Delete",
                                isPresented: $showDeleteAlert
                            ) {
                                
                                Button(role: .destructive) {
                                    Task {
                                        // TODO: DELETE MODEL CODE
                                        dismiss()
                                    }
                                } label: {
                                    Text("Delete")
                                }
                                
                                Button(role: .cancel) {

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
                
                if isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Saving Model...")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .shadow(radius: 10)
                }
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
            Task {
                self.items = try await viewModel.getModelItems()
            }
        }
        
        // MARK: - Top Bar
        @ViewBuilder
        private func TopBar() -> some View {
            TopAppBar(
                leadingIcon: {
                    if isEditing {
                        Button {
                            if let backup = backupModel {
                                viewModel.selectedModel = backup
                            }
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
                            isEditing = false
                        } else {
                            backupModel = viewModel.selectedModel
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
            isLoading = true
            Task {
                await viewModel.updateModel()
                self.items = try await viewModel.getModelItems()
                isLoading = false
            }
        }
    }
