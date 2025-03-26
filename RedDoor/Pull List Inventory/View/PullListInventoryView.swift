//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct PullListInventoryView: View {
    
    @State private var viewModel = ListInventoryViewModel()
    @State private var pullListArray: [RDList] = []
    @State private var path: NavigationPath = NavigationPath()
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            LazyVStack(spacing: 0) {
//                List {
                ForEach(pullListArray) { pullList in
                    NavigationLink(value: pullList) {
                        PullListListView(pullList)
                    }
                }
//                }
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
                    await loadInitialPullLists()
                }
            }
            .onDisappear {
    //            viewModel.stopListening()
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
    
    private func loadInitialPullLists() async {
        await viewModel.loadLists() { fetchedLists in
            pullListArray = fetchedLists
        }
    }
        
}

//#Preview {
//    PullListView()
//}
