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
    
    @Binding var primaryImage: UIImage?
    @State private var isEditing: Bool = false
    @State private var showEditAlert: Bool = false
    @State private var activeSheet: ImageSourceEnum?
    
    //    let size = (UIScreen.width - 32) / 2
    
    var body: some View {
        Group {
            if let primaryImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: primaryImage)
                        .resizable()
                        .scaledToFill()
                    
                    if isEditing {
                        DeleteButton {
                            // remove the image
                        }
                    }
                }
            } else {
                Rectangle()
                    .foregroundStyle(.blue)
            }
        }
        .onTapGesture {
            showEditAlert = true
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
            
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
        }
    }
}


#Preview {
    @Previewable @State var primaryImage: UIImage? = nil
    ModelPrimaryImage(primaryImage: $primaryImage)
}
