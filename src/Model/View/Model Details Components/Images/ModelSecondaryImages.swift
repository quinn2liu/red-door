//
//  ModelSecondaryImages.swift
//  RedDoor
//
//  Created by Quinn Liu on 7/30/25.
//

import SwiftUI

struct ModelSecondaryImages: View {
    
    @State private var activeSheet: ImageSourceEnum?
    @State private var showAlert: Bool = false
    @Binding var secondaryImages: [UIImage]
    
    var body: some View {
        Group {
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<2) { col in
                            let index = 2 * row + col
                            
                            if index < secondaryImages.count {
                                Image(uiImage: secondaryImages[index])
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(12)
                                    .clipped()
                                
                            } else if index < 4 {
                                Button {
                                    showAlert = true
                                } label: {
                                    ZStack (alignment: .center) {
                                        placeholderRectangle()
                                        
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                    }
                                }
                            } else {
                                placeholderRectangle()
                                
                            }
                        }
                    }
                }
            }
        }
        .alert("Upload Type", isPresented: $showAlert) {
            Button(role: .none) {
                activeSheet = .library
            } label: {
                Text("Library")
            }

            Button(role: .none) {
                activeSheet = .camera
            } label: {
                Text("Camera")
            }

            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }
        }
        .sheet(item: $activeSheet) { item in
            PickerSheet(item: item)
        }
        .frame(maxWidth: Constants.screenWidth / 2,
               maxHeight: Constants.screenWidth / 2)
    }
    
    @ViewBuilder
    private func PickerSheet(item: ImageSourceEnum) -> some View {
        Group {
            switch item {
            case .library:
                MultiLibraryPicker(selectedImages: $secondaryImages) {
                    activeSheet = nil
                }
            case .camera:
                MultiCameraPicker(selectedImages: $secondaryImages) {
                    activeSheet = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private func placeholderRectangle() -> some View {
        Rectangle()
            .fill(Color.gray)
            .cornerRadius(12)
            .aspectRatio(1, contentMode: .fit)
    }
}



//#Preview {
//    ModelSecondaryImages()
//}
