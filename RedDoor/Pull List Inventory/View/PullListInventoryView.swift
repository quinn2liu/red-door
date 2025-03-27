//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct PullListInventoryView: View {
    
    @State private var path: NavigationPath = NavigationPath()
    @State private var viewModel = DocumentsListViewModel(.pull_lists)
//    @State private var pullListArray: [RDList] = []
    
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.documentsArray.compactMap { $0 as? RDList }, id: \.self) { pullList in
                        NavigationLink(value: pullList) {
                            Text(pullList.id)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if pullList == viewModel.documentsArray.last as? RDList {
                                Task {
                                    if !isLoading {
                                        isLoading = true
                                        await fetchPullLists(initial: false, searchText: !searchText.isEmpty ? searchText : nil)
                                        isLoading = false
                                    }
                                }
                            }
                        }
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text("Pull Lists")
                        .font(.system(.title2, design: .default))
                        .bold()
                        .foregroundStyle(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolBarMenu()
                }
            }
            .onAppear {
                Task {
                    isLoading = true
                    await fetchPullLists(initial: true, searchText: nil)
                    isLoading = false
                }
            }
            .rootNavigationDestinations()
        }
        
    }
    
    @ViewBuilder private func ToolBarMenu() -> some View {
        Menu {
            NavigationLink(destination: CreatePullListView()) {
                Text("From Scratch")
                Image(systemName: "checklist")
            }
    
            NavigationLink(destination: InstalledToPullBrowseView()) {
                Text("From Installed List")
                Image(systemName: "document.on.document")
            }
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.red)
        }
        .padding(.horizontal)
    }
    
    private func fetchPullLists(initial isInitial: Bool, searchText: String?) async {
        var filters: [String: Any] = [:]

        if let searchText {
            filters.updateValue(searchText, forKey: "id")
        }
        
        if isInitial {
            await viewModel.fetchInitialDocuments(filters: filters)
        } else {
            await viewModel.fetchMoreDocuments(filters: filters)
        }
        
//
//        let pullLists: [RDList] = await viewModel.fetchDocuments(from: "pull_lists", matching: filters.isEmpty ? nil : filters, descending: false)
//        
//        if !pullLists.isEmpty {
//            viewModel.documentsArray.append(contentsOf: pullLists)
//        }
    }
    
//    private func loadInitialPullLists() async {
//        await viewModel.loadLists() { fetchedLists in
//            pullListArray = fetchedLists
//        }
//    }
        
}

#Preview {
    PullListInventoryView()
}
