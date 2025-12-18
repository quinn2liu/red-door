//
//  ItemListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/9/25.
//

import CachedAsyncImage
import SwiftUI

struct ModelItemListView: View {
    @State var viewModel: ModelViewModel
    @State var listExpanded: Bool = false

    var body: some View {
        HStack {
            Text("Item Count: \(viewModel.itemCount)")
            Spacer()
            Image(systemName: listExpanded ? SFSymbols.minus : SFSymbols.plus)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            listExpanded.toggle()
        }

        if !viewModel.items.isEmpty && listExpanded {
            NavigationLink(destination: ModelItemListDetailView(modelViewModel: $viewModel)) {
                VStack(spacing: 0) {
                    ForEach(viewModel.items, id: \.self) { item in
                        ModelItemListItem(item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func ModelItemListItem(_ item: Item) -> some View {
        let model = viewModel.selectedModel

        HStack {
            if let itemImage = item.image, itemImage.imageExists, let imageURL = itemImage.imageURL {
                CachedAsyncImage(url: imageURL)
            } else {
                Image(systemName: SFSymbols.photoBadgePlus)
            }
            Text(item.id)
            Text(model.type)
            Text(item.attention.description)
        }
    }
}
