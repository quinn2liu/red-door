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
    case model_primary, model_secondary, item, rd_list, dirty, misc
    
    var objectPath: String? {
        switch self {
        case .model_primary, .model_secondary:
            return "model_images"
        case .item:
            return "items"
        case .rd_list:
            return "rd_lists"
        case .misc:
            return "misc"
        case .dirty:
            return nil // no valid path for dirty
        }
    }
}

struct RDImage: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var imageType: RDImageTypeEnum = .dirty
    var objectId: String? = nil
    var imageURL: URL? = nil
    var uiImage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, objectId, imageURL, imageType
    }
}
