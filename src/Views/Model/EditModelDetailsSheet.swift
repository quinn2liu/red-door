//
//  EditModelDetailsSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import PhotosUI
import SwiftUI

struct EditModelDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var viewModel: ModelViewModel
    @State private var editingViewModel: ModelViewModel
    var onDelete: (() -> Void)?
    
    // Image overlay variables
    @State private var selectedRDImage: RDImage? = nil
    @State private var isImageSelected: Bool = false
    
    // Loading and delete variables
    @State private var isLoading: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    init(viewModel: Binding<ModelViewModel>, onDelete: (() -> Void)? = nil) {
        _viewModel = viewModel
        self.onDelete = onDelete
        // Create a copy of the viewModel's selectedModel for editing
        self.editingViewModel = ModelViewModel(model: viewModel.wrappedValue.selectedModel)
    }
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()
                
                ModelImages(
                    model: $editingViewModel.selectedModel,
                    selectedRDImage: $selectedRDImage,
                    isImageSelected: $isImageSelected,
                    isEditing: .constant(true)
                )
                
                EditingModelDetailsView(viewModel: $editingViewModel)
                
                Spacer()
                
                RDButton(variant: .red, size: .default, leadingIcon: "trash", text: "Delete Model", fullWidth: false) {
                    showDeleteAlert = true
                }
                .alert(
                    "Confirm Delete",
                    isPresented: $showDeleteAlert
                ) {
                    Button(role: .destructive) {
                        deleteModel()
                    } label: {
                        Text("Delete")
                    }
                    
                    Button(role: .cancel) {} label: {
                        Text("Cancel")
                    }
                }
            }
            .toolbar(.hidden)
            .frameTop()
            .frameHorizontalPadding()
            .frameTopPadding()
            .overlay(
                ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
                    .animation(.easeInOut(duration: 0.3), value: isImageSelected)
            )
            
            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("Saving Model...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .shadow(radius: 10)
            }
        }
    }
    
    // MARK: Top Bar
    
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                RDButton(variant: .red, size: .icon, leadingIcon: "xmark", iconBold: true, fullWidth: false) {
                    dismiss()
                }
                .clipShape(Circle())
            },
            header: {
                ModelNameEntry()
            },
            trailingIcon: {
                RDButton(variant: .red, size: .icon, leadingIcon: "checkmark", iconBold: true, fullWidth: false) {
                    saveModel()
                }
                .clipShape(Circle())
            }
        )
    }
    
    // MARK: Model Name Entry
    
    @ViewBuilder
    private func ModelNameEntry() -> some View {
        TextField("Model Name", text: $editingViewModel.selectedModel.name)
            .padding(6)
            .background(isImageSelected ? Color.clear : Color(.systemGray5))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
    }
    
    // MARK: Helper Functions
    
    private func saveModel() {
        isLoading = true
        Task {
            // Update the original viewModel's selectedModel with the edited version
            viewModel.selectedModel = editingViewModel.selectedModel
            // Update itemCount if it changed
            viewModel.itemCount = editingViewModel.itemCount
            
            // Save to Firebase
            await viewModel.updateModel()
            isLoading = false
            dismiss()
        }
    }
    
    private func deleteModel() {
        isLoading = true
        Task {
            // Update the original viewModel's selectedModel before deleting
            viewModel.selectedModel = editingViewModel.selectedModel
            await viewModel.deleteModel()
            isLoading = false
            dismiss()
            // Notify parent that deletion occurred
            onDelete?()
        }
    }
}

