//
//  GenericRepository.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/24/26.
//

import Firebase

class GenericRepository<T: Codable> {
    let collectionRef: CollectionReference
    
    init(documentType: DocumentType, db: Firestore) {
        self.collectionRef = db.collection(documentType.collectionString)
    }
    
    // MARK: - Standalone async
    func set(_ model: T, id: String) async throws {
        try collectionRef.document(id).setData(from: model)
    }
    
    func delete(id: String) async throws {
        try await collectionRef.document(id).delete()
    }
    
    func get(id: String) async throws -> T {
        let snapshot = try await collectionRef.document(id).getDocument()
        return try snapshot.data(as: T.self)
    }
    
    func update(id: String, fields: [AnyHashable: Any]) async throws {
        let documentRef = collectionRef.document(id)
        try await documentRef.updateData(fields)
    }
    
    // MARK: - Batch participatory
    func set(_ model: T, id: String, inBatch batch: WriteBatch) throws {
        try batch.setData(
            from: model,
            forDocument: collectionRef.document(id)
        )
    }
    
    func delete(id: String, inBatch batch: WriteBatch) {
        batch.deleteDocument(collectionRef.document(id))
    }
    
    func update(id: String, fields: [AnyHashable: Any], inBatch batch: WriteBatch) {
        let documentRef = collectionRef.document(id)
        batch.updateData(fields, forDocument: documentRef)
    }
    
    // MARK: - Transaction participatory
    func get(id: String, in transaction: Transaction) throws -> T {
        let ref = collectionRef.document(id)
        let snapshot = try transaction.getDocument(ref)
        return try snapshot.data(as: T.self)
    }
    
    func set(_ model: T, id: String, in transaction: Transaction) throws {
        try transaction.setData(
            from: model,
            forDocument: collectionRef.document(id)
        )
    }
    
    func delete(id: String, in transaction: Transaction) {
        transaction.deleteDocument(
            collectionRef.document(id)
        )
    }
    
    func update(_ id: String, fields: [AnyHashable: Any], in transaction: Transaction) {
        let documentRef = collectionRef.document(id)
        transaction.updateData(fields, forDocument: documentRef)
    }
}
