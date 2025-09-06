//
//  ModelPrimaryImage.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/10/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation
import CachedAsyncImage

struct ModelPrimaryImage: View {
    
    @State private var showEditAlert: Bool = false
    @State private var activeSheet: ImageSourceEnum?
    
    @Binding var primaryRDImage: RDImage
    @Binding var selectedRDImage: RDImage?
    @Binding var isImageSelected: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            if isEditing {
                showEditAlert = true
            } else {
                if let uiImage = primaryRDImage.uiImage {
                    selectedRDImage = RDImage(uiImage: uiImage)
                } else if primaryRDImage.imageURL != nil {
                    selectedRDImage = primaryRDImage
                }
                isImageSelected = true
            }
        } label: {
            if let uiImage = primaryRDImage.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageUrl = primaryRDImage.imageURL {
                CachedAsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.3))
                }
            } else { // no image selected
                Rectangle()
                    .foregroundStyle(.blue)
            }
        }
        .alert(
            primaryRDImage.imageURL != URL(string: "") ? "Upload Method" : "Update Image",
            isPresented: $showEditAlert
        ) {
            EditPhotoAlert()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .library:
                SingleLibraryPicker(primaryRDImage: $primaryRDImage) {
                    activeSheet = nil
                }
            case .camera:
                SingleCameraPicker(primaryRDImage: $primaryRDImage) {
                    activeSheet = nil
                }
            }
        }
        .frame(maxWidth: Constants.screenWidthPadding / 2, maxHeight: Constants.screenWidthPadding / 2)
        .contentShape(Rectangle())
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func EditPhotoAlert() -> some View {
        Group {
            Button(role: .none) {
                activeSheet = .library
            } label: {
                Text("Library")
            }
            
            Button(role: .none) {
                activeSheet = .camera
            } label: {
                Text("Camera")
            }
            
            if isEditing {
                Button(role: .destructive) {
                    
                } label: {
                    Text("Delete")
                }
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
        }
    }
}

//
//#Preview {
//    @Previewable @State var primaryImage: UIImage? = nil
//    ModelPrimaryImage(primaryImage: $primaryImage)
//}
