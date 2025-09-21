//
//  ModelItemListDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 9/18/25.
//

import SwiftUI
import CachedAsyncImage

struct ModelItemListDetailView: View {
    @Binding var modelViewModel: ModelViewModel
    
    // Image selected variables
    @State private var selectedRDImage: RDImage?
    @State private var isImageSelected: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            TopBar()
            
            ModelPrimaryImage(primaryRDImage: Binding.constant(modelViewModel.selectedModel.primaryImage), selectedRDImage: $selectedRDImage, isImageSelected: $isImageSelected, isEditing: Binding.constant(false))
            
            ForEach(modelViewModel.items, id: \.self) { item in
                // TODO: update this with the Route enum
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemListItem(item)
                }
            }
            
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .overlay(
            ModelRDImageOverlay(selectedRDImage: selectedRDImage, isImageSelected: $isImageSelected)
        )
    }
        
    
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            Text(modelViewModel.selectedModel.name)
        }, trailingIcon: {
            Spacer().frame(24)
        })
    }
    
    // MARK: Item List Item
    @ViewBuilder
    private func ItemListItem(_ item: Item) -> some View {
        let model = modelViewModel.selectedModel
        
        HStack {
            if item.image.imageExists {
                CachedAsyncImage(url: item.image.imageURL)
            } else {
                Image(systemName: "photo.badge.plus")
            }
            Text(item.id)
            Text(model.type)
            Text(item.repair.description)
        }
    }
}
