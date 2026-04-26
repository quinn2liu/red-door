//
//  DocumentsListViewModelV2.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/25/26.
//

import FirebaseFirestore
import Foundation

@Observable
final class DocumentListViewModelV2<T: AnyRDDocument> {
    private let collectionRef: CollectionReference
    private let pageSize: Int
    private var lastDocument: DocumentSnapshot?
    private var isFetching = false
    
    var documentsArray: [T] = []
    var hasMoreData = true
    var isLoading = false
    
    init(
        pageSize: Int = 10,
        db: Firestore = Firestore.firestore()
    ) {
        self.pageSize = pageSize
        self.collectionRef = db.collection(T.collectionName)
    }
    
    @MainActor
    func loadInitialDocuments() async {
        documentsArray = []
        lastDocument = nil
        hasMoreData = true
        await loadPage(replacingExisting: true)
    }
    
    @MainActor
    func loadMoreDocuments() async {
        await loadPage(replacingExisting: false)
    }
    
    @MainActor
    private func loadPage(replacingExisting: Bool) async {
        guard hasMoreData, !isFetching else { return }
        
        isFetching = true
        isLoading = true
        defer {
            isFetching = false
            isLoading = false
        }
        
        do {
            var query = collectionRef
                .order(by: T.orderByField)
                .limit(to: pageSize)
            
            if !replacingExisting, let lastDocument {
                query = query.start(afterDocument: lastDocument)
            }
            
            let snapshot = try await query.getDocuments()
            lastDocument = snapshot.documents.last
            hasMoreData = snapshot.documents.count == pageSize
            
            let page = snapshot.documents.compactMap { document -> T? in
                do {
                    return try document.data(as: T.self)
                } catch {
                    print("DocumentsListViewModelV2 decode failed: \(error)")
                    return nil
                }
            }
            
            if replacingExisting {
                documentsArray = page
            } else {
                documentsArray.append(contentsOf: page)
            }
        } catch {
            print("DocumentsListViewModelV2 load failed: \(error)")
        }
    }
}
