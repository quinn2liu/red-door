//
//  PullListDocumentViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/29/25.
//

import Foundation
import FirebaseFirestore

@Observable
class PullListDocumentViewModel {
    // MARK: - Data Properties
    
    var stagingLists: [RDList] = []
    var planningLists: [RDList] = []
    var searchResults: [RDList] = []
    
    // MARK: - Loading States
    
    var isLoadingStaging = false
    var isLoadingPlanning = false
    var isLoadingSearch = false
    
    // MARK: - Error Handling
    
    var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let planningListViewModel: DocumentsListViewModel
    
    // MARK: - Initialization
    
    init() {
        self.planningListViewModel = DocumentsListViewModel(.pull_list)
    }
    
    // MARK: - Public Methods
    
    /// Fetch both staging and planning lists in parallel
    @MainActor
    func fetchInitialData() async {
        async let stagingTask: Void = fetchStagingLists()
        async let planningTask: Void = fetchPlanningLists(initial: true)
        
        _ = await (stagingTask, planningTask)
    }
    
    /// Fetch all staging lists (no pagination)
    @MainActor
    func fetchStagingLists() async {
        isLoadingStaging = true
        errorMessage = nil
        
        defer { isLoadingStaging = false }
        
        let filters: [String: Any] = ["status": InstallationStatus.staging.rawValue]
        let documents = await planningListViewModel.fetchAllDocuments(filters: filters)
        stagingLists = documents.compactMap { $0 as? RDList }
    }
    
    /// Fetch planning lists with pagination
    @MainActor
    func fetchPlanningLists(initial isInitial: Bool) async {
        isLoadingPlanning = true
        errorMessage = nil
        
        defer { isLoadingPlanning = false }
        
        let filters: [String: Any] = ["status": InstallationStatus.planning.rawValue]
        
        if isInitial {
            await planningListViewModel.fetchInitialDocuments(filters: filters)
        } else {
            await planningListViewModel.fetchMoreDocuments(filters: filters)
        }
        
        // Update planningLists from the viewModel's documentsArray
        planningLists = planningListViewModel.documentsArray.compactMap { $0 as? RDList }
    }
    
    /// Fetch search results combining staging and planning lists
    @MainActor
    func fetchSearchResults(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoadingSearch = true
        errorMessage = nil
        
        defer { isLoadingSearch = false }
        
        let stagingFilters: [String: Any] = [
            "status": InstallationStatus.staging.rawValue,
            "id": query
        ]
        let planningFilters: [String: Any] = [
            "status": InstallationStatus.planning.rawValue,
            "id": query
        ]
        
        async let stagingDocs = planningListViewModel.fetchAllDocuments(filters: stagingFilters)
        async let planningDocs = planningListViewModel.fetchAllDocuments(filters: planningFilters)
        
        let (stagingResults, planningResults) = await (stagingDocs, planningDocs)
        
        let stagingLists = stagingResults.compactMap { $0 as? RDList }
        let planningLists = planningResults.compactMap { $0 as? RDList }
        
        // Combine and sort: staging first, then planning, both sorted by date
        searchResults = (stagingLists + planningLists).sortedByStatusThenDate()
    }
    
    /// Clear search results
    func clearSearchResults() {
        searchResults = []
    }
}

// MARK: - Helper Extensions

extension Array where Element == RDList {
    func sortedByStatusThenDate() -> [RDList] {
        let staging = self.filter { $0.status == .staging }
            .sorted { $0.createdDate > $1.createdDate }
        let planning = self.filter { $0.status == .planning }
            .sorted { $0.createdDate > $1.createdDate }
        return staging + planning
    }
}

