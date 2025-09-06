//
//  ModelListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/16/25.
//

import SwiftUI
import CachedAsyncImage

struct ModelListItemView: View {
    
    var model: Model
    
    // TODO: add primary image
    var urlString: String {
        return model.imageUrlDict.values.first ?? ""
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ModelImage()
            
            Spacer()
            
            Text(model.name)
            
            Spacer()

            Text(model.type)
            
            Spacer()

            Text(model.primaryMaterial)
            
            Spacer()

            Text(model.primaryColor)
            
            Spacer()

            Text(String(model.itemCount))
        }
    }
    
    @ViewBuilder private func ModelImage() -> some View {
        if let imageURL = model.primaryImage.imageURL {
            CachedAsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Placeholder while loading
                case .success(let image):
                    image.resizable().frame(50)
                case .failure:
                    Image(systemName: "")
                        .frame(50) // Fallback image
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .frame(50) // Fallback image
        }
    }
}

//#Preview {
//    ModelListItemView(model: Model())
//}
