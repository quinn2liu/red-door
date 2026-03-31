//
//  ModelService.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/27/26.
//

import Firebase
import Foundation

protocol AnyModelService {
    func createModel(from model: Model) async throws
    func getModel(modelId: String) async throws -> Model
    func updateModel(for model: Model) async throws
    func deleteModel(modelId: String) async throws
    func getModelItems(modelId: String) async throws -> [Item]
    func createModelItems(modelId: String, count: Int) async throws -> [String]
    func updateModelPrimaryImage(modelId: String, image: RDImage) async throws
}

class ModelService: AnyModelService {

    private let db: Firestore
    private let imageService: FirebaseImageService
    private let modelCollection: CollectionReference

    init(db: Firestore, imageService: FirebaseImageService) {
        self.db = db
        self.imageService = imageService
        self.modelCollection = db.collection("models")
    }

    func createModel(from model: Model) async throws {
        let modelReference = modelCollection.document(model.id)
        var modelToMake = Model(from: model)
        
        do {
            modelToMake.primaryImage.objectId = modelToMake.id
            let newPrimaryImage = try await imageService.updateImage(model.primaryImage, resultImageType: .model_primary)
            
            
        } catch {
            throw error
        }
    }

    func getModel(modelId: String) async throws -> Model {
        fatalError("not implemented")
    }

    func updateModel(for model: Model) async throws {

    }

    func deleteModel(modelId: String) async throws {

    }

    func getModelItems(modelId: String) async throws -> [Item] {
        fatalError("not implemented")
    }

    func createModelItems(modelId: String, count: Int) async throws -> [String] {
        fatalError("not implemented")
    }

    func updateModelPrimaryImage(modelId: String, image: RDImage) async throws {

    }

}
