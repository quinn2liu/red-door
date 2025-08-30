//
//  ModelRDImageOverlayView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/28/25.
//

import SwiftUI
import CachedAsyncImage

struct ModelRDImageOverlay: View {
    
    let selectedRDImage: RDImage?
    @Binding var isImageFullScreen: Bool
    
    var body: some View {
        if let selectedRDImage {
            if isImageFullScreen {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isImageFullScreen = false
                    }
                
                if let uiImage = selectedRDImage.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                } else if selectedRDImage.imageUrl != nil {
                    CachedAsyncImage(url: selectedRDImage.imageUrl)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
        }
    }
}
