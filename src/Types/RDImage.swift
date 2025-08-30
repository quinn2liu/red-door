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
}

struct RDImage: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var imageUrl: URL? = nil
    var imageType: RDImageTypeEnum = .dirty
    
    var uiImage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, imageUrl, imageType
    }
}
