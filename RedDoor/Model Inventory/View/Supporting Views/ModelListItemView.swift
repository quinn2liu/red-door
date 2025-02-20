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
    
    var urlString: String {
        return model.imageURLDict.values.first ?? ""
    }
    
    var body: some View {
        HStack {
            if urlString != "" {
                CachedAsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Placeholder while loading
                    case .success(let image):
                        image.resizable().frame(50)
                    case .failure:
                        Image(systemName: "photo.badge.exclamationmark")
                            .frame(50) // Fallback image
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .frame(50) // Fallback image
            }
            
            Spacer()
            
            Text(model.name)
            
            Spacer()

            Text(model.type)
            
            Spacer()

            Text(model.primaryMaterial)
            
            Spacer()

            Text(model.primaryColor)
            
            Spacer()

            Text(String(model.count))
        }
    }
}

#Preview {
    ModelListItemView(model: Model())
}
