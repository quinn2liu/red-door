//
//  ModelPrimaryImage.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/10/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

enum SourceTypeEnum: String, Identifiable {
    var id: String {
        self.rawValue
    }
    case library, camera
}

struct ModelPrimaryImage: View {
        
    @State var primaryImage: UIImage? = nil
    @State private var isEditing: Bool = false
    @State private var sourceTypeEnum: SourceTypeEnum?
    @State private var showAlert: Bool = false
    @State private var activeSheet: SourceTypeEnum?
    
    let size = (UIScreen.width - 32) / 2.5
    
    var body: some View {
        Group {
            if let primaryImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: primaryImage)
                        .resizable()
                        .scaledToFill()
                    
                    if isEditing {
                        DeleteButton {
                            // remove the image
                        }
                    }
                }
            } else {
                Rectangle()
                    .foregroundStyle(.blue)
            }
        }
        .onTapGesture {
            showAlert = true
        }
        .alert("Upload Type", isPresented: $showAlert) {
            
            Button {
                activeSheet = .library
            } label: {
                Text("Library")
            }
            
            Button {
                activeSheet = .camera
            } label: {
                Text("Camera")
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .library:
                LibraryPicker(primaryImage: $primaryImage) {
                    activeSheet = nil
                }
            case .camera:
                CameraPicker(primaryImage: $primaryImage) {
                    activeSheet = nil
                }
            }
        }
        .frame(size)
        .cornerRadius(12)
    }
}

#Preview {
    ModelPrimaryImage()
}

// TODO: Figure out how this works lol
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var primaryImage: UIImage?
    var dismiss: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.primaryImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
struct LibraryPicker: UIViewControllerRepresentable {
    @Binding var primaryImage: UIImage?
    var dismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        let nav = UINavigationController(rootViewController: picker)
        return nav
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LibraryPicker

        init(_ parent: LibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                // User canceled the selection
                parent.dismiss()
                return
            }

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                parent.dismiss()
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.primaryImage = image as? UIImage
                    self.parent.dismiss()
                }
            }
        }
        
        @objc func didTapCancel() {
            parent.dismiss()
        }
    }
}
