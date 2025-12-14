//
//  InstalledListDocumentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct InstalledListDocumentView: View {
    @Binding var path: NavigationPath
    @State private var viewModel = RDListDocumentViewModel(
        documentType: .installed_list,
        primaryStatus: .installed,
        secondaryStatus: .unstaged
    )

    @State private var searchText: String = ""
    @State private var showInstalledLists: Bool = false
    @State private var searchFocused: Bool = false
    @FocusState private var searchTextFocused: Bool
    
    private var isSearching: Bool {
        !searchText.isEmpty
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                if searchFocused {
                    SearchBar()
                } else {
                    TopBar()
                }

                if isSearching {
                    SearchResultsList()
                } else {
                    NormalModeList()
                }
            }
            .task {
                await viewModel.fetchInitialData()
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

    @ViewBuilder 
    private func SearchBar() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")

                TextField("", text: $searchText, prompt: Text("Search..."))
                    .submitLabel(.search)
                    .focused($searchTextFocused)
                    .onSubmit {
                        if !searchText.isEmpty {
                            Task {
                                await viewModel.fetchSearchResults(query: searchText.lowercased())
                            }
                        }
                    }
            }
            .padding(8)
            .clipShape(.rect(cornerRadius: 8))

            if searchFocused {
                Button("Cancel") {
                    searchText = ""
                    viewModel.clearSearchResults()
                    searchTextFocused = false
                    searchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.25), value: searchTextFocused)
    }

    // MARK: Tool Bar Menu

    @ViewBuilder 
    private func ToolBarMenu() -> some View {
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

    // MARK: Normal Mode List (installed section + unstaged section)
    
    @ViewBuilder
    private func NormalModeList() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                InstalledListSection()
                UnstagedListSection()
            }
        }
        .refreshable {
            await viewModel.fetchPrimaryLists()
            await viewModel.fetchSecondaryLists(initial: true)
        }
    }
    
    // MARK: Installed Lists Section
    
    @ViewBuilder
    private func InstalledListSection() -> some View {
        VStack(spacing: 8) {
            Button {
                withAnimation {
                    showInstalledLists.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Installed")
                        .font(.headline)
                        .foregroundColor(.red)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    Text("(\(viewModel.primaryLists.count))")
                        .foregroundColor(.secondary)

                    Image(systemName: showInstalledLists ? "chevron.up" : "chevron.down")
                }
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            }
            .disabled(viewModel.primaryLists.isEmpty)

            if showInstalledLists {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if viewModel.primaryLists.isEmpty {
                        Text("No lists are currently installed.")
                    } else {
                        ForEach(viewModel.primaryLists, id: \.self) { installedList in
                            NavigationLink(value: installedList) {
                                Text(installedList.address.getStreetAddress() ?? "") // TODO: make a InstalledListView
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    if viewModel.isLoadingPrimary {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
        }
    }
    
    // MARK: Unstaged Lists Section
    
    @ViewBuilder
    private func UnstagedListSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Unstaged")
                    .font(.headline)
                    .foregroundColor(.primary)

                Image(systemName: "arrow.uturn.backward")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(6)
            .frame(maxWidth: .infinity)
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.secondaryLists, id: \.self) { unstagedList in
                    NavigationLink(value: unstagedList) {
                        Text(unstagedList.address.getStreetAddress() ?? "") // TODO: make a InstalledListView
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if unstagedList == viewModel.secondaryLists.last {
                            Task {
                                if !viewModel.isLoadingSecondary {
                                    await viewModel.fetchSecondaryLists(initial: false)
                                }
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingSecondary {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
    
    // MARK: Search Results List
    
    @ViewBuilder
    private func SearchResultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.searchResults, id: \.self) { installedList in
                    NavigationLink(value: installedList) {
                        HStack {
                            Text(installedList.address.getStreetAddress() ?? "") // TODO: make a InstalledListView
                            Spacer()
                            Text(installedList.status.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if viewModel.isLoadingSearch {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.fetchSearchResults(query: searchText)
        }
    }
}

#Preview {
    InstalledListDocumentView(path: .constant(.init()))
}
