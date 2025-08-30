//
//  ItemImagesView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/20/24.
//

import SwiftUI

struct ModelImagesView: View {
    
    @Binding var images: [UIImage]
    @State private var showDeleteConfirmation: Bool = false
    @State private var selectedImageIndex: Int?
    
    @Binding var selectedImage: UIImage?
    @Binding var isImageFullScreen: Bool
    var isEditing: Bool
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(images.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedImage = images[index]
                            isImageFullScreen = true
                        }
                    
                    if (isEditing) {
                        DeleteButton {
                            selectedImageIndex = index
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to delete this photo?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deletePhoto()
                }
                Button("Cancel", role: .cancel) {}
            }
            
        }
        
    }
    
    private func deletePhoto() {
        if let index = selectedImageIndex {
            images.remove(at: index)
        }
    }
}



//
//#Preview {
//    ModelImagesView()
//}
