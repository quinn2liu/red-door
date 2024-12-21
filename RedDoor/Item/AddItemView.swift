//
//  AddItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/22/24.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    
    @State private var viewModel: ViewModel = ViewModel()
    @State private var selectedItems: [PhotosPickerItem] = [PhotosPickerItem]()
    @State private var selectedImages: [String: UIImage] = [:]
    @Environment(\.dismiss) var dismiss

    @State private var isImagePickerPresented = false
    @State private var images: [UIImage] = [] // Array to store multiple images
    @State private var sourceType: UIImagePickerController.SourceType?
    
    var body: some View {
    
        Form {
            Section(header: Text("Item Images")) {
                
                
                HStack {
                    
                    HStack {
                        Image(systemName: "photo")
                        Text("Select Photos")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    .onTapGesture {
                        sourceType = .photoLibrary
                        DispatchQueue.main.async {
                            isImagePickerPresented = true
                        }
                        print("sourceType is: \(sourceType!)")
                    }
                    
                    
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
                    .onTapGesture {
                        sourceType = .camera
                        DispatchQueue.main.async {
                            isImagePickerPresented = true
                        }
                        print("sourceType is: \(sourceType!)")
                    }
                    
                }
                    
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                        }
                    }
                    .padding()
                }
                
//                VStack {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 16) {
//                            if (!selectedImages.isEmpty) {
//                                ForEach(Array(selectedImages.keys), id: \.self) { imageName in
//                                    if let image = selectedImages[imageName] {
//                                        Image(uiImage: image)
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 200, height: 200)
//                                            .background(Color(.systemGray5))
//                                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                                    } else {
//                                        Text("Unable to load image")
//                                        Image("photo.badge.exclamationmark")
//                                    }
//                                }
//                            }
//                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
//                                Label(selectedItems.count <= 2 ? "Select a photo" : "Edit photos", systemImage: "photo")
//                            }
//                            .frame(width: 200, height: 200)
//                            .background(Color(.systemGray5))
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                        }
//                    }
//                    .padding(.vertical, 10)
//                }
//                .onChange(of: selectedItems) {
//                    Task {
//                        selectedImages.removeAll()
//                        viewModel.selectedModel.imageIDs = []
//                        for (index, photoPickerItem) in selectedItems.enumerated() {
//                            if let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
//                                if let loadedImage = UIImage(data: data) {
//                                    let imageID = viewModel.selectedModel.id + "-\(index)"
//                                    viewModel.selectedModel.imageIDs.append(imageID)
//                                    selectedImages[imageID] = loadedImage
//                                    print("imageID: \(imageID)")
//                                }
//                            }
//                        }
//                    }
//                }
            }
                
            Section(header: Text("Options")) {
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
                
                Stepper("Item Count: \(viewModel.selectedModel.count)", value: $viewModel.selectedModel.count, in: 1...100, step: 1)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Adding:")
                        .font(.headline)
                    TextField("", text: $viewModel.selectedModel.name)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            if sourceType == .camera {
                    ImagePickerWrapper(
                        images: $images,
                        isPresented: $isImagePickerPresented,
                        sourceType: .camera
                    )
            } else {
                ImagePickerWrapper(
                    images: $images,
                    isPresented: $isImagePickerPresented,
                    sourceType: .photoLibrary
                )
            }
        }
        
    
        HStack {
            Spacer()
            Button("Add Item to Inventory") {
                Task {
                    await viewModel.updateModelImagesFirebase(imageDict: selectedImages)
                    await withCheckedContinuation { continuation in
                        viewModel.updateModelDataFirebase()
                        continuation.resume()
                    }
                }
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.green)
            .clipShape(Capsule())
            Spacer()
        }
        .padding(.top)
    }
}

struct ImagePickerWrapper: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerWrapper

        init(_ parent: ImagePickerWrapper) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.images.append(image) // Append to the array
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

//#Preview {
//    AddItemView()
//}
