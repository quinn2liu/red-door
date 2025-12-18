//
//  ModelDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import SwiftUI

struct ModelDetailsView: View {
    @Binding var viewModel: ModelViewModel

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Colors:")
                    .foregroundColor(.red)
                    .bold()

                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text("Primary: ")
                                .foregroundColor(.primary)

                            HStack(spacing: 6) {
                                Text(viewModel.selectedModel.primaryColor)
                                Image(systemName: SFSymbols.circleFill)
                                    .foregroundStyle(Model.colorMap[viewModel.selectedModel.primaryColor] ?? .black)
                            }
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                        }
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Secondary:")
                                .foregroundColor(.primary)

                            HStack(spacing: 6) {
                                Text(viewModel.selectedModel.secondaryColor)
                                    .foregroundColor(.blue)
                                Image(systemName: SFSymbols.circleFill)
                                    .foregroundStyle(Model.colorMap[viewModel.selectedModel.secondaryColor] ?? .black)
                            }
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Materials:")
                    .foregroundColor(.red)
                    .bold()

                HStack(alignment: .top, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Primary: ")
                            .foregroundColor(.primary)
                        Text(viewModel.selectedModel.primaryMaterial)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }

                    Spacer()

                    HStack(spacing: 0) {
                        Text("Secondary: ")
                            .foregroundColor(.primary)
                        Text(viewModel.selectedModel.secondaryMaterial)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
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

                            HStack(spacing: 8) {
                                Text(viewModel.selectedModel.type)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Image(systemName: Model.typeMap[viewModel.selectedModel.type] ?? "camera.metering.unknown")
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                        
                        HStack(alignment: .center, spacing: 4) {
                            Text("Essential:")
                                .foregroundColor(.red)
                                .bold()
                            
                            Image(systemName: viewModel.selectedModel.isEssential ? SFSymbols.checkmarkCircleFill : SFSymbols.circle)
                                .foregroundColor(viewModel.selectedModel.isEssential ? .yellow : .gray)
                        }
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
                    
                Text(viewModel.selectedModel.description.isEmpty ? "No description" : viewModel.selectedModel.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(viewModel.selectedModel.description.isEmpty ? .secondary : .primary)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
}
