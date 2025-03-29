//
//  InstalledListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InstalledListDocumentView: View {
    
    @State private var path: NavigationPath = NavigationPath()
    @State private var viewModel = DocumentsListViewModel(.installed_lists)
    
    @State private var searchText: String = ""
    
    // MARK: View Modifier Variables
    @State private var isLoadingLists: Bool = false
    @State private var searchFocused: Bool = false
    @FocusState private var searchTextFocused: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            
            VStack(spacing: 16) {
                if !searchTextFocused {
                    TopBar()
                }
                
                if searchFocused {
                    SearchBar()
                }
                
                InstalledListList()
                
            }
            .onAppear {
                Task {
                    await fetchInstalledLists(initial: true, searchText: nil)
                }
            }
            .frameTop()
            .frameHorizontalPadding()
            .rootNavigationDestinations(path: $path)
        }
        
    }
    
    // MARK: Top Bar
    @ViewBuilder private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: {
                Text("Installed Lists")
                    .font(.system(.title2, design: .default))
                    .bold()
                    .foregroundStyle(.red)
            },
            header: {
                EmptyView()
            },
            trailingIcon: {
                HStack(spacing: 12) {
                    if !searchFocused {
                        Button {
                            searchTextFocused = true
                            searchFocused = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    
                    ToolBarMenu()
                }
            }
        ).tint(.red)
    }
    
    // MARK: Search Bar
    @ViewBuilder private func SearchBar() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("", text: $searchText, prompt: Text("Search..."))
                    .submitLabel(.search)
                    .focused($searchTextFocused)
                    .onSubmit {
                        if !searchText.isEmpty {
                            Task {
                                await fetchInstalledLists(initial: true, searchText: searchText)
                            }
                        }
                        searchTextFocused = false
                        searchFocused = false
                    }
            }
            .padding(8)
            .clipShape(.rect(cornerRadius: 8))
            
            if searchTextFocused {
                Button("Cancel") {
                    searchText = ""
                    searchTextFocused = false
                    searchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.bouncy(duration: 0.5), value: searchTextFocused)
    }
    
    // MARK: Tool Bar Menu
    @ViewBuilder private func ToolBarMenu() -> some View {
        Menu {
            NavigationLink(destination: CreatePullListView()) {
                Text("From Scratch")
                Image(systemName: "checklist")
            }
            
            NavigationLink(destination: InstalledToPullBrowseView()) {
                Text("From Pull List")
                Image(systemName: "document.on.document")
            }
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.red)
        }
    }
    
    @ViewBuilder private func InstalledListList() -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.documentsArray.compactMap { $0 as? RDList }, id: \.self) { pullList in
                    NavigationLink(value: pullList) {
                        Text(pullList.id) // TODO: make a PL list item
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if pullList == viewModel.documentsArray.last as? RDList {
                            Task {
                                if !isLoadingLists {
                                    await fetchInstalledLists(initial: false, searchText: !searchText.isEmpty ? searchText : nil)
                                }
                            }
                        }
                    }
                }
                
                if isLoadingLists {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
    
    private func fetchInstalledLists(initial isInitial: Bool, searchText: String?) async {
        var filters: [String: Any] = [:]
        
        if let searchText {
            filters.updateValue(searchText, forKey: "id")
        }
        DispatchQueue.main.async {
            isLoadingLists = true
        }

        if isInitial {
            await viewModel.fetchInitialDocuments(filters: filters)
        } else {
            await viewModel.fetchMoreDocuments(filters: filters)
        }

        DispatchQueue.main.async {
            isLoadingLists = false
        }
    }
}

#Preview {
    InstalledListDocumentView()
}
