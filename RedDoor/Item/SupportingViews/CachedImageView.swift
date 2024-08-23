//
//  CachedImageView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/23/24.
//

import SwiftUI
import CachedAsyncImage

struct CachedImageView: View {
    
    var imageURLDict: [String: String]
    
    var body: some View {
        ForEach(Array(imageURLDict), id: \.value) { (imageID, imageURL) in
            CachedAsyncImage(url: URL(string: imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else if phase.error != nil {
                    Text("Error loading image.")
                } else {
                    Text("Loading image.")
                }
            }
        }
    }
}

//#Preview {
//    CachedImageView()
//}
