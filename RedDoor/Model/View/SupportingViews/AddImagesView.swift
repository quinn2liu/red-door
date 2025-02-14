//
//  AddImagesView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/21/24.
//

import SwiftUI

struct AddImagesView: View {
    
    @Binding var images: [UIImage]
    @Binding var isImagePickerPresented: Bool
    @Binding var sourceType: UIImagePickerController.SourceType?
    
    var body: some View {
        HStack {
            TransparentButton(backgroundColor: .blue, foregroundColor: .blue, leadingIcon: "photo", text: "Album", fullWidth: true) {
                sourceType = .photoLibrary
                isImagePickerPresented = true
            }
            
            Spacer()
            
            TransparentButton(backgroundColor: .gray, foregroundColor: .gray, leadingIcon: "camera", text: "Camera", fullWidth: true) {
                sourceType = .camera
                isImagePickerPresented = true
            }

        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    AddImagesView()
//}
