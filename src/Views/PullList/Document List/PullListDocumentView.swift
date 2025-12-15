//
//  PullListDocumentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct PullListDocumentView: View {
    @Binding var path: NavigationPath
    @State private var viewModel = RDListDocumentViewModel(
        documentType: .pull_list,
        primaryStatus: .staging,
        secondaryStatus: .planning
    )

    @State private var searchText: String = ""
    @State private var showFromInstalledCover: Bool = false
    @State private var showStagingLists: Bool = true
    @State private var searchFocused: Bool = false
    @FocusState private var searchTextFocused: Bool
    
    private var isSearching: Bool {
        !searchText.isEmpty
    }

    // MARK: Body

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

                    Button {
                        Task {
                            await viewModel.fetchPrimaryLists()
                            await viewModel.fetchSecondaryLists(initial: true)
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }

                    ToolBarMenu()
                }
            }
        ).tint(.red)
    }

    // MARK: Search Bar

    @ViewBuilder private func SearchBar() -> some View {
        SearchBarComponent(
            searchText: $searchText,
            searchFocused: $searchFocused,
            searchTextFocused: $searchTextFocused,
            onSubmit: {
                Task {
                    await viewModel.fetchSearchResults(query: searchText.lowercased())
                }
            },
            onCancel: {
                viewModel.clearSearchResults()
            }
        )
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
        VStack(spacing: 16) {
            StagingListSection()
            PlanningListSection()
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

                    Image(systemName: "truck.box.badge.clock.fill")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    Text("(\(viewModel.primaryLists.count))")
                        .foregroundColor(.secondary)

                    Image(systemName: showStagingLists ? "chevron.up" : "chevron.down")
                }
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            }
            .disabled(viewModel.primaryLists.isEmpty)

            if !viewModel.primaryLists.isEmpty && showStagingLists {
                if viewModel.isLoadingPrimary {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.primaryLists, id: \.self) { pullList in
                            NavigationLink(value: pullList) {
                                Text(pullList.address.getStreetAddress() ?? "") // TODO: make a PL list item
                            }
                            .buttonStyle(PlainButtonStyle())
                        } 
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

            ScrollView {
                if viewModel.isLoadingSecondary {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.secondaryLists, id: \.self) { pullList in
                            NavigationLink(value: pullList) {
                                Text(pullList.address.getStreetAddress() ?? "") // TODO: make a PL list item
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                if pullList == viewModel.secondaryLists.last {
                                    Task {
                                        if !viewModel.isLoadingSecondary {
                                            await viewModel.fetchSecondaryLists(initial: false)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.fetchPrimaryLists()
                await viewModel.fetchSecondaryLists(initial: true)
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
                            Text(pullList.address.getStreetAddress() ?? "") // TODO: make a PL list item
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
