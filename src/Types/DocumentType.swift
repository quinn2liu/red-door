//
//  DocumentType.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/29/25.
//

import Foundation

enum DocumentType: String, Codable {
    case model, pull_list, installed_list, storage

    var collectionString: String {
        switch self {
        case .model:
            return "models"
        case .pull_list:
            return "pull_lists"
        case .installed_list:
            return "installed_lists"
        case .storage:
            return "storage"
        }
    }

    var documentDataType: Codable.Type {
        switch self {
        case .model:
            return Model.self
        case .pull_list, .installed_list, .storage:
            return RDList.self
        }
    }

    var orderByField: String {
        switch self {
        case .model:
            return "nameLowercased"
        case .pull_list, .installed_list, .storage:
            return "id"
        }
    }
}
