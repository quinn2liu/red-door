//
//  ItemDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import SwiftUI

struct ModelDetailsView: View {
    
    var isEditing: Bool
    @Binding var viewModel: ModelViewModel
        
    var body: some View {
        if (isEditing) {
            Picker("Primary Color", selection: $viewModel.selectedModel.primaryColor) {
                ForEach(viewModel.colorOptions, id: \.self) { option in
                    HStack {
                        Text(option)
                        Image(systemName: "circle.fill")
                            .foregroundStyle(viewModel.colorMap[option] ?? .black)
                            .overlay(
                                Image(systemName: "circle")
                                    .foregroundColor(.black.opacity(0.5))
                            )
                    }
                }
            }
            .pickerStyle(.navigationLink)


            Picker("Item Type", selection: $viewModel.selectedModel.type) {
                ForEach(viewModel.typeOptions, id: \.self) { option in
                    HStack {
                        Text("\(option)")
                        Image(systemName: viewModel.typeMap[option] ?? "camera.metering.unknown")
                    }
                }
            }

            Picker("Material", selection: $viewModel.selectedModel.primaryMaterial) {
                ForEach(viewModel.materialOptions, id: \.self) { material in
                    Text(material)
                }
            }

        } else {
            HStack {
                Text("Primary Color: \(viewModel.selectedModel.primaryColor)")
                Image(systemName: "circle.fill")
                    .foregroundStyle(viewModel.colorMap[viewModel.selectedModel.primaryColor] ?? .black)
                    .overlay(
                        Image(systemName: "circle")
                            .foregroundColor(.black.opacity(0.5))
                    )
            }
            HStack {
                Text("Item Type: \(viewModel.selectedModel.type)")
                Image(systemName: viewModel.typeMap[viewModel.selectedModel.type] ?? "camera.metering.unknown")
            }

            Text("Material: \(viewModel.selectedModel.primaryMaterial)")
        }
    }
}

//#Preview {
//    ItemDetailsView()
//}
