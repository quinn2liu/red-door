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
    @Binding var selectedUIImage: UIImage?
    
    @Binding var isImageFullScreen: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            if isEditing {
                showEditAlert = true
            } else {
                if let uiImage = primaryRDImage.uiImage {
                    selectedRDImage = RDImage(uiImage: uiImage)
                } else if primaryRDImage.imageUrl != nil {
                    selectedRDImage = primaryRDImage
                }
                isImageFullScreen = true
            }
        } label: {
            if let uiImage = primaryRDImage.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageUrl = primaryRDImage.imageUrl {
                CachedAsyncImage(url: imageUrl)
                    .scaledToFill()
            } else { // no image selected
                Rectangle()
                    .foregroundStyle(.blue)
            }
        }
        .alert(
            primaryRDImage.imageUrl != URL(string: "") ? "Upload Method" : "Update Image",
            isPresented: $showEditAlert
        ) {
            EditPhotoAlert()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .library:
                SingleLibraryPicker(primaryImage: $primaryRDImage.uiImage) {
                    activeSheet = nil
                }
            case .camera:
                SingleCameraPicker(primaryImage: $primaryRDImage.uiImage) {
                    activeSheet = nil
                }
            }
        }
        .frame(maxWidth: Constants.screenWidthPadding / 2,
               maxHeight: Constants.screenWidthPadding / 2)
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
