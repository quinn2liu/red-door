//
//  MemoryImageView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/23/24.
//

import SwiftUI

struct MemoryImageView: View {
    var selectedImages: [String: UIImage]
    
    var body: some View {
        ForEach(Array(selectedImages.keys), id: \.self) { imageID in
            if let image = selectedImages[imageID] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Text("Unable to load image")
                Image("photo.badge.exclamationmark")
            }
        }
    }
}

//#Preview {
//    MemoryImageView()
//}
