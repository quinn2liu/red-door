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
        
        Button {
            
        } label: {
            Text("Show QR Code")
        }
        
        if (isEditing) {
            Picker("Primary Color", selection: $viewModel.selectedModel.primary_color) {
                ForEach(Array(ModelViewModel.colorMap), id: \.key) { option, color in
                    HStack(spacing: 0) {
                        Text(option)
                        
                        Image(systemName: "circle.fill")
                            .foregroundStyle(color)
                            .overlay(
                                Image(systemName: "circle")
                                    .foregroundColor(.black.opacity(0.5))
                            )
                    }
                }
            }
            .pickerStyle(.navigationLink)

            Picker("Item Type", selection: $viewModel.selectedModel.type) {
                ForEach(Array(ModelViewModel.typeMap), id: \.key) { option, iconName in
                    HStack(spacing: 8) {
                        Text(option)
                        Image(systemName: iconName)
                    }
                }
            }

            Picker("Material", selection: $viewModel.selectedModel.primary_material) {
                ForEach(ModelViewModel.materialOptions, id: \.self) { material in
                    Text(material)
                }
            }

        } else {
            HStack {
                Text("Primary Color: \(viewModel.selectedModel.primary_color)")
                Image(systemName: "circle.fill")
                    .foregroundStyle(ModelViewModel.colorMap[viewModel.selectedModel.primary_color] ?? .black)
                    .overlay(
                        Image(systemName: "circle")
                            .foregroundColor(.black.opacity(0.5))
                    )
            }
            
            HStack {
                Text("Item Type: \(viewModel.selectedModel.type)")
                Image(systemName: ModelViewModel.typeMap[viewModel.selectedModel.type] ?? "camera.metering.unknown")
            }

            Text("Material: \(viewModel.selectedModel.primary_material)")
        }
    }
}

//#Preview {
//    ItemDetailsView()
//}
