//
//  AddItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/22/24.
//

import SwiftUI
import PhotosUI

struct CreateModelView: View {
    
    // Environment variables
    @State private var viewModel: ModelViewModel = ModelViewModel() // initializes new blank model
    @Environment(\.dismiss) var dismiss
    @State private var isEditing: Bool = true

    // Image Overlay
    @State private var selectedRDImage: RDImage? = nil
    @State private var isImageSelected: Bool = false
    
    // Loading Variables
    @State private var isLoading: Bool = false

    init(viewModel: ModelViewModel = ModelViewModel()) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TopBar()
                            
                ModelImages(model: $viewModel.selectedModel, selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: $isEditing)
                                        
                ModelDetailsView(isEditing: isEditing, viewModel: $viewModel)
                
                Stepper("Item Count: \(viewModel.selectedModel.itemCount)", value: $viewModel.selectedModel.itemCount, in: 1...100, step: 1)
                    
                RedDoorButton(type: .green, leadingIcon: "plus", text: "Add Model to Inventory", semibold: true) {
                    saveModel()
                }
            }
            .toolbar(.hidden)
            .frameTop()
            .frameHorizontalPadding()
            .ignoresSafeArea(.keyboard)
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
    
    private func saveModel() {
        isLoading = true
        Task {
            await viewModel.updateModel()
            isLoading = false
            dismiss()
        }
    }
    
    
    // MARK: - Top Bar
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                BackButton()
            },
            header: {
                ModelNameEntry()
            },
            trailingIcon: {
                Spacer().frame(24)
            }
        )
    }
        
    // MARK: Model Name Entry
    @ViewBuilder
    private func ModelNameEntry() -> some View {
        TextField("Item Name", text: $viewModel.selectedModel.name)
            .padding(6)
            .background(isImageSelected ? Color.clear : Color(.systemGray5))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    CreateModelView()
}
