//
//  ImagePickerWrapper.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import Foundation
import SwiftUI
import PhotosUI

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
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                parent.images.append(image) // Append to the array
            }
            parent.isPresented = false
        }
        
        @objc func image(_ image: UIImage,
            didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                print("ERROR: \(error)")
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
