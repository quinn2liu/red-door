//
//  ModelDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import SwiftUI

struct ModelDetailsView: View {
    var isEditing: Bool
    @Binding var viewModel: ModelViewModel
    @State private var isPrimaryColorPickerActive = false
    @State private var isSecondaryColorPickerActive = false

    // MARK: Body

    var body: some View {
        if isEditing {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Colors:")
                        .foregroundColor(.red)
                        .bold()

                    ColorPickerRow()
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Materials:")
                        .foregroundColor(.red)
                        .bold()

                    HStack(alignment: .top, spacing: 0) {
                        MaterialPicker(selectedMaterial: $viewModel.selectedModel.primaryMaterial, title: "Primary:")

                        Spacer()

                        MaterialPicker(selectedMaterial: $viewModel.selectedModel.secondaryMaterial, title: "Secondary:")
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Details:")
                        .foregroundColor(.red)
                        .bold()

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center, spacing: 4) {
                                Text("Model Type:")

                                Picker("", selection: $viewModel.selectedModel.type) {
                                    ForEach(Array(ModelViewModel.typeMap), id: \.key) { option, iconName in
                                        HStack(spacing: 8) {
                                            Text(option)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                            Image(systemName: iconName)
                                                .padding(4)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer()
                            
                            HStack(alignment: .center, spacing: 4) {
                                Text("Essential:")
                                    .foregroundColor(.red)
                                    .bold()
                                
                                Toggle("", isOn: $viewModel.selectedModel.isEssential)
                                    .labelsHidden()
                            }
                        }

                        Stepper( value: $viewModel.itemCount, in: 1 ... 100, step: 1) {
                            Text("Item Count: \(viewModel.itemCount)")
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .foregroundColor(.red)
                        .bold()
                        
                    TextField("Type here", text: $viewModel.selectedModel.description, axis: .vertical)
                        .disabled(viewModel.selectedModel.description.count > 100)
                        .lineLimit(3...5)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        } else {
            HStack {
                Text("Primary Color: \(viewModel.selectedModel.primaryColor)")
                Image(systemName: SFSymbols.circleFill)
                    .foregroundStyle(ModelViewModel.colorMap[viewModel.selectedModel.primaryColor] ?? .black)
                    .overlay(
                        Image(systemName: SFSymbols.circle)
                            .foregroundColor(.black.opacity(0.5))
                    )
            }

            HStack {
                Text("Type: \(viewModel.selectedModel.type)")
                Image(systemName: ModelViewModel.typeMap[viewModel.selectedModel.type] ?? "camera.metering.unknown")
            }

            Text("Material: \(viewModel.selectedModel.primaryMaterial)")
        }
    }

    // MARK: ColorPickerRow

    @ViewBuilder
    private func ColorPickerRow() -> some View {
        HStack(alignment: .top, spacing: 0) {
            if !isSecondaryColorPickerActive {
                VStack(alignment: .leading, spacing: 4) {
                    ColorPickerToggle(
                        isActive: $isPrimaryColorPickerActive,
                        title: "Primary:",
                        selectedColor: viewModel.selectedModel.primaryColor
                    )

                    if isPrimaryColorPickerActive {
                        ColorPickerGrid(
                            selectedColor: $viewModel.selectedModel.primaryColor,
                            isActive: $isPrimaryColorPickerActive,
                            title: "Primary:"
                        )
                    }
                }
            }

            Spacer()
            
            if !isPrimaryColorPickerActive {
                VStack(alignment: .leading, spacing: 4) {
                    ColorPickerToggle(
                        isActive: $isSecondaryColorPickerActive,
                        title: "Secondary: ",
                        selectedColor: viewModel.selectedModel.secondaryColor
                    )

                    if isSecondaryColorPickerActive {
                        ColorPickerGrid(
                            selectedColor: $viewModel.selectedModel.secondaryColor,
                            isActive: $isSecondaryColorPickerActive,
                            title: "Secondary: "
                        )
                    }
                }
            }
        }
    }
}

// MARK: Material Picker
struct MaterialPicker: View {
    @Binding var selectedMaterial: String
    var title: String

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .foregroundColor(.primary)

            Picker("Material", selection: $selectedMaterial) {
                ForEach(ModelViewModel.materialOptions, id: \.self) { material in
                    Text(material)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
// MARK: ColorPickerToggle

struct ColorPickerToggle: View {
    @Binding var isActive: Bool
    var title: String
    var selectedColor: String

    var body: some View {
        // Button to show/hide picker
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isActive.toggle()
            }
        }) {
            HStack(spacing: 6) {
                Text(title)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text(selectedColor)
                        .foregroundColor(.blue)
                    Image(systemName: SFSymbols.circleFill)
                        .foregroundStyle(ModelViewModel.colorMap[selectedColor] ?? .black)
                }
                .padding(8)
                .background(isActive ? Color.clear : Color(.systemGray5) )
                .cornerRadius(6)
            }
        }
    }
}

// MARK: - ColorPickerGrid

struct ColorPickerGrid: View {
    @Binding var selectedColor: String
    @Binding var isActive: Bool
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(ModelViewModel.colorGroups, id: \.0) { groupName, colors in
                VStack(alignment: .leading, spacing: 4) {
                    Text(groupName)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),  
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 6) {
                        ForEach(colors, id: \.self) { colorName in
                            ColorOptionView(
                                colorName: colorName,
                                color: ModelViewModel.colorMap[colorName] ?? .black,
                                isSelected: selectedColor == colorName
                            ) {
                                selectedColor = colorName
                                withAnimation(.spring(response: 0.3)) {
                                    isActive = false
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(8)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray6), lineWidth: 2)
        )
    }
}

// MARK: - ColorOptionView

struct ColorOptionView: View {
    let colorName: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: SFSymbols.circleFill)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .padding(2)
                    )
                
                Text(colorName)
                    .font(.system(size: 10))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// #Preview {
//    ItemDetailsView()
// }
