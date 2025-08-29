//
//  RDImage.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/14/25.
//

import Foundation
import PhotosUI
import SwiftUI

enum RDImageTypeEnum: String, Codable {
    case model_primary, model_secondary, item, RDList, misc
}

struct RDImage: Identifiable, Codable, Hashable {
    var objectId: String = "" // id of parent object to which this image belongs to
    var id: String  = ""// photo id
    var imageUrl: URL? = URL(string: "")
    var imageType: RDImageTypeEnum
    
    init(objectId: String = "", id: String = "", imageUrl: URL? = nil, imageType: RDImageTypeEnum = .model_primary) {
        self.objectId = objectId
        self.id = id
        self.imageUrl = imageUrl
        self.imageType = imageType
    }
    
    init(objectId: String, imageType: RDImageTypeEnum) {
        switch imageType {
        case .model_primary:
            self.id = "\(objectId)-primary"
        case .model_secondary:
            self.id = "\(objectId)-secondary"
        case .item: // TODO: UPDATE BEHAVIOR FOR THE FOLLOWING
            self.id = "\(objectId)"
        case .RDList:
            self.id = "\(objectId)"
        case .misc:
            self.id = "\(objectId)"
        }
        
        self.objectId = objectId
        self.imageType = imageType
    }
}
