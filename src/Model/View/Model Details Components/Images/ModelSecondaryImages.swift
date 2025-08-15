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
    @State private var editIndex: Int? = nil
    
    @Binding var secondaryImages: [UIImage]
    @Binding var selectedImage: UIImage?
    @Binding var isImageFullScreen: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        Group {
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<2) { col in
                            let index = 2 * row + col
                            
                            SecondaryImage(index: index)
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
            
            if isEditing {
                Button(role: .destructive) {
                    DeleteSecondaryImage(index: editIndex)
                } label: {
                    Text("Delete")
                }
            }

            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }
        }
        .sheet(item: $activeSheet) { activeSheet in
            if let editIndex = editIndex {
                PickerSheet(item: activeSheet, editIndex: editIndex)
            }
        }
        .frame(maxWidth: Constants.screenWidth / 2,
               maxHeight: Constants.screenWidth / 2)
    }

    @ViewBuilder
    private func SecondaryImage(index: Int) -> some View {
        if index < secondaryImages.count {
            Button {
                if isEditing {
                    showAlert = true
                    editIndex = index
                } else {
                    selectedImage = secondaryImages[index]
                    isImageFullScreen = true
                }
                
            } label: {
                Image(uiImage: secondaryImages[index])
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                    .clipped()
            }
        } else if index == secondaryImages.count {
            Button {
                showAlert = true
                editIndex = index
            } label: {
                ZStack (alignment: .center) {
                    PlaceholderRectangle()
                    
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
        } else {
            PlaceholderRectangle()
        }
    }
    
    private func DeleteSecondaryImage(index: Int?) {
        // TODO: Delete the secondary image
    }
    
    @ViewBuilder
    private func PickerSheet(item: ImageSourceEnum, editIndex: Int) -> some View {
        Group {
            switch item {
            case .library:
                MultiLibraryPicker(selectedImages: $secondaryImages, editIndex: editIndex) {
                    activeSheet = nil
                }
            case .camera:
                MultiCameraPicker(selectedImages: $secondaryImages, editIndex: editIndex) {
                    activeSheet = nil
                }
            }
        }
    }
    
    
    
    @ViewBuilder
    private func PlaceholderRectangle() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.clear)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray, lineWidth: 1)
            )
    }
}



//#Preview {
//    ModelSecondaryImages()
//}
