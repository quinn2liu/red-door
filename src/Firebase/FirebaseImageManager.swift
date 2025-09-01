//
//  FirebaseImageManager.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/31/25.
//

import Foundation
import Firebase
import FirebaseStorage

protocol ImageManager {
    func uploadImage(_ rdImage: RDImage, newImageType: RDImageTypeEnum) async throws -> RDImage
    func uploadImages(_ images: [RDImage], newImageType: RDImageTypeEnum) async throws -> [RDImage]
}

final class FirebaseImageManager: ImageManager {
    static let shared = FirebaseImageManager()

    private init() {}
    
    func uploadImage(_ rdImage: RDImage, newImageType: RDImageTypeEnum) async throws -> RDImage {
        let (uiImage, objectPath, objectId): (UIImage, String, String)
        
        do {
            (uiImage, objectPath, objectId) = try validateRDImage(rdImage, newImageType: newImageType)
        } catch {
            print("Upload skipped: \(error)")
            return rdImage
        }
        
        var storageRef = Storage.storage().reference().child(objectPath)
        storageRef = storageRef.child(objectId).child(rdImage.id)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.5) else { throw ImageUploadError.cannotCompress }
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metaData)
        let url = try await storageRef.downloadURL()
        
        var updated = rdImage
        updated.imageURL = url
        updated.imageType = newImageType
        updated.uiImage = nil
        return updated
    }
    
    func uploadImages(_ images: [RDImage], newImageType: RDImageTypeEnum) async throws -> [RDImage] {
        try await withThrowingTaskGroup(of: RDImage.self) { group in
            for image in images where image.imageType == .dirty {
                group.addTask {
                    try await self.uploadImage(image, newImageType: newImageType)
                }
            }
            
            var updated: [RDImage] = []
            for try await uploaded in group {
                updated.append(uploaded)
            }
            
            let clean = images.filter { $0.imageType != .dirty }
            return clean + updated
        }
    }
    
    enum ImageUploadError: Error {
        case notDirty, invalidType, noUIImage, cannotCompress, missingObjectId
    }

    private func validateRDImage(_ rdImage: RDImage, newImageType: RDImageTypeEnum) throws -> (uiImage: UIImage, objectPath: String, objectId: String) {
        
        guard rdImage.imageType == .dirty else { throw ImageUploadError.notDirty }
        
        guard let objectPath = newImageType.objectPath else { throw ImageUploadError.invalidType }
        
        guard let uiImage = rdImage.uiImage else { throw ImageUploadError.noUIImage }
        
        guard let objectId = rdImage.objectId else { throw ImageUploadError.missingObjectId }
        
        return (uiImage, objectPath, objectId)
    }
}
