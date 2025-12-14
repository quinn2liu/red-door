//
//  PullListDocumentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct PullListDocumentView: View {
    @Binding var path: NavigationPath
    @State private var viewModel = PullListDocumentViewModel()

    @State private var searchText: String = ""
    @State private var showFromInstalledCover: Bool = false
    @State private var showStagingLists: Bool = false
    @State private var searchFocused: Bool = false
    @FocusState private var searchTextFocused: Bool
    
    private var isSearching: Bool {
        !searchText.isEmpty
    }

    // MARK: Body

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                if !searchTextFocused {
                    TopBar()
                }

                if searchFocused {
                    SearchBar()
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
                Text("Pull Lists")
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
                                await viewModel.fetchSearchResults(query: searchText)
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

    @ViewBuilder private func ToolBarMenu() -> some View {
        Menu {
            NavigationLink(destination: CreatePullListView()) {
                Text("From Scratch")
                Image(systemName: "checklist")
            }
            // TODO: add functionatliy to this
            Button {
                showFromInstalledCover = true
            } label: {
                Text("From Installed List")
                Image(systemName: "document.on.document")
            }
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.red)
        }
    }


    // MARK: Normal Mode List (staging section + planning section)
    
    @ViewBuilder
    private func NormalModeList() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                StagingListSection()
                PlanningListSection()
            }
        }
        .refreshable {
            await viewModel.fetchStagingLists()
            await viewModel.fetchPlanningLists(initial: true)
        }
    }
    
    // MARK: Staging Lists Section
    
    @ViewBuilder
    private func StagingListSection() -> some View {
        VStack(spacing: 8) {
            Button {
                withAnimation {
                    showStagingLists.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Staging")
                        .font(.headline)
                        .foregroundColor(.red)

                    Image(systemName: "hammer.fill")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    Text("(\(viewModel.stagingLists.count))")
                        .foregroundColor(.secondary)

                    Image(systemName: showStagingLists ? "chevron.up" : "chevron.down")
                }
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            }
            .disabled(viewModel.stagingLists.isEmpty)

            if showStagingLists {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if viewModel.stagingLists.isEmpty {
                        Text("No lists are currently in staging.")
                    } else {
                        ForEach(viewModel.stagingLists, id: \.self) { pullList in
                            NavigationLink(value: pullList) {
                                Text(pullList.id) // TODO: make a PL list item
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    if viewModel.isLoadingStaging {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
        }
    }
    
    // MARK: Planning Lists Section
    
    @ViewBuilder
    private func PlanningListSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 8) {
                Text("Planning")
                    .font(.headline)
                    .foregroundColor(.primary)

                Image(systemName: "pencil.and.list.clipboard")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(6)
            .frame(maxWidth: .infinity)
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.planningLists, id: \.self) { pullList in
                    NavigationLink(value: pullList) {
                        Text(pullList.id) // TODO: make a PL list item
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if pullList == viewModel.planningLists.last {
                            Task {
                                if !viewModel.isLoadingPlanning {
                                    await viewModel.fetchPlanningLists(initial: false)
                                }
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingPlanning {
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
                ForEach(viewModel.searchResults, id: \.self) { pullList in
                    NavigationLink(value: pullList) {
                        HStack {
                            Text(pullList.id) // TODO: make a PL list item
                            Spacer()
                            Text(pullList.status.rawValue.capitalized)
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
    PullListDocumentView(path: .constant(.init()))
}
