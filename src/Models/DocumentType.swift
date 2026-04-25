//
//  DocumentType.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/29/25.
//

import Foundation

enum DocumentType: String, Codable {
    case model, item, pull_list, installed_list

    var collectionString: String {
        switch self {
        case .model:
            return "models"
        case .item:
            return "items"
        case .pull_list:
            return "pull_lists"
        case .installed_list:
            return "installed_lists"
        }
    }

    var documentDataType: Codable.Type {
        switch self {
        case .model:
            return Model.self
        case .item:
            return Item.self
        case .pull_list, .installed_list:
            return RDList.self
        }
    }

    var orderByField: String {
        switch self {
        case .model:
            return "nameLowercased"
        case .item:
            return "id"
        case .pull_list:
            return "createdDate"
        case .installed_list:
            return "installDate"
        }
    }
}
