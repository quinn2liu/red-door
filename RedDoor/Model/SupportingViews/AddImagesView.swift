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
            
            HStack {
                Image(systemName: "photo")
                Text("Album")
            }
            .transparentButtonStyle(backgroundColor: .clear, foregroundColor: .blue)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            .onTapGesture {
                sourceType = .photoLibrary
                isImagePickerPresented = true
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "camera")
                Text("Camera")
            }
            .transparentButtonStyle(backgroundColor: .clear, foregroundColor: .gray)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .onTapGesture {
                
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
