//
//  ModelListItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/16/25.
//

import CachedAsyncImage
import SwiftUI

struct ModelListItemView: View {
    var model: Model

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
        }
    }

    @ViewBuilder private func ModelImage() -> some View {
        if let imageURL = model.primaryImage.imageURL {
            CachedAsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Placeholder while loading
                case let .success(image):
                    image.resizable().frame(50)
                case .failure:
                    Image(systemName: SFSymbols.photoBadgePlus)
                        .frame(50) // Fallback image
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: SFSymbols.photo)
                .frame(50) // Fallback image
        }
    }
}

// #Preview {
//    ModelListItemView(model: Model())
// }
