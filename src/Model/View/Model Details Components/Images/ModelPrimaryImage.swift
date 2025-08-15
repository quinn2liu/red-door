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

struct ModelPrimaryImage: View {
    
    @State private var showEditAlert: Bool = false
    @State private var activeSheet: ImageSourceEnum?
    
    @Binding var primaryImage: UIImage?
    @Binding var selectedImage: UIImage?
    @Binding var isImageFullScreen: Bool
    @Binding var isEditing: Bool
        
    var body: some View {
        Group {
            Button {
                if isEditing && primaryImage == nil {
                    showEditAlert = true
                } else {
                    selectedImage = primaryImage
                    isImageFullScreen = true
                }
            } label: {
                if let primaryImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: primaryImage)
                            .resizable()
                            .scaledToFill()
                    }
                } else {
                    Rectangle()
                        .foregroundStyle(.blue)
                }
            }
        }
        .alert(primaryImage == nil ? "Upload Method" : "Update Image", isPresented: $showEditAlert) {
            EditPhotoAlert()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .library:
                SingleLibraryPicker(primaryImage: $primaryImage) {
                    activeSheet = nil
                }
            case .camera:
                SingleCameraPicker(primaryImage: $primaryImage) {
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
