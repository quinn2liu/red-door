//
//  ModelSecondaryImages.swift
//  RedDoor
//
//  Created by Quinn Liu on 7/30/25.
//

import SwiftUI
import CachedAsyncImage

struct ModelSecondaryImages: View {
    
    @State private var activeSheet: ImageSourceEnum?
    @State private var showAlert: Bool = false
    @State private var editIndex: Int? = nil
    
    @Binding var secondaryRDImages: [RDImage]
    @Binding var selectedRDImage: RDImage?
    @Binding var isImageFullScreen: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        Group {
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<2) { col in
                            let index = 2 * row + col
                            
                            SecondaryImageItem(index: index)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
        }
        .alert("Upload Type", isPresented: $showAlert) {
            EditImageAlert()
        }
        .sheet(item: $activeSheet) { activeSheet in
            if let editIndex = editIndex {
                PickerSheet(item: activeSheet, editIndex: editIndex)
            }
        }
        .frame(maxWidth: Constants.screenWidthPadding / 2,
               maxHeight: Constants.screenWidthPadding / 2)

    }
    
    // MARK: Edit Image Alert
    @ViewBuilder
    private func EditImageAlert() -> some View {
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

    // MARK: Secondary Image Item
    @ViewBuilder
    private func SecondaryImageItem(index: Int) -> some View {
     
        if index < secondaryRDImages.count {
            Button {
                if isEditing {
                    showAlert = true
                    editIndex = index
                } else {
                    if secondaryRDImages[index].imageURL != nil {
                        selectedRDImage = secondaryRDImages[index]
                    } else if let uiImage = secondaryRDImages[index].uiImage {
                        selectedRDImage = RDImage(uiImage: uiImage)
                    }
                    isImageFullScreen = true
                }
                
            } label: {
                if let imageUrl = secondaryRDImages[index].imageURL {
                    CachedAsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        PlaceholderRectangle()
                    }
                } else if let uiImage = secondaryRDImages[index].uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    PlaceholderRectangle()
                }
            }
        } else if index == secondaryRDImages.count {
            Button {
                if isEditing {
                    showAlert = true
                    editIndex = index
                }
            } label: {
                ZStack (alignment: .center) {
                    PlaceholderRectangle()
                    
                    Image(systemName: isEditing ? "plus" : "photo")
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
                MultiLibraryPicker(selectedRDImages: $secondaryRDImages, editIndex: editIndex) {
                    activeSheet = nil
                }
            case .camera:
                MultiCameraPicker(selectedRDImages: $secondaryRDImages, editIndex: editIndex) {
                    activeSheet = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private func PlaceholderRectangle() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.clear)
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    ModelSecondaryImages()
//}
