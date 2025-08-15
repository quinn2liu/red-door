//
//  MultiImagePicker.swift
//  RedDoor
//
//  Created by Quinn Liu on 7/30/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

struct MultiCameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var editIndex: Int
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
        let parent: MultiCameraPicker

        init(_ parent: MultiCameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if parent.editIndex >= 0 && parent.editIndex < parent.selectedImages.count {
                    // Replace existing image at editIndex
                    parent.selectedImages[parent.editIndex] = image
                } else {
                    // Append if index is invalid or beyond array bounds
                    parent.selectedImages.append(image)
                }
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct MultiLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var editIndex: Int
    var dismiss: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 4

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiLibraryPicker

        init(_ parent: MultiLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let group = DispatchGroup()

            for result in results {
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }

                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            if self.parent.editIndex >= 0 && self.parent.editIndex < self.parent.selectedImages.count {
                                // Replace existing image
                                self.parent.selectedImages[self.parent.editIndex] = image
                            } else {
                                // Append if index is invalid or beyond array bounds
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.dismiss()
            }
        }
    }
}
