//
//  ModelImageOverlay.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/23/25.
//

import SwiftUI

struct ModelImageOverlay: View {
    
    let selectedImage: UIImage?
    @Binding var isImageFullScreen: Bool
    
    var body: some View {
        if isImageFullScreen, let selectedImage = selectedImage {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isImageFullScreen = false
                }
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(8)
                .shadow(radius: 10)
        }
    }
}
