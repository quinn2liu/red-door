//
//  CameraAlbumPicker.swift
//  RedDoor
//
//  Created by Quinn Liu on 7/30/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

// TODO: Figure out how this works lol
struct SingleCameraPicker: UIViewControllerRepresentable {
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
        let parent: SingleCameraPicker

        init(_ parent: SingleCameraPicker) {
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

struct SingleLibraryPicker: UIViewControllerRepresentable {
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
        let parent: SingleLibraryPicker
        
        init(_ parent: SingleLibraryPicker) {
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
