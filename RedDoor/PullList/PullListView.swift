//
//  InventoryView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct PullListView: View {
    
    @State private var viewModel = ViewModel()
    @State private var pullListArray: [PullList] = []
    @State private var isEditing = false
    @State private var path: NavigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                HStack {
                    ZStack {
                        Menu {
                            NavigationLink(destination: CreatePullListView(path: $path)) {
                                Text("From Scratch")
                                Image(systemName: "checklist")
                            }
                    
                            NavigationLink(destination: InstalledToPullBrowseView()) {
                                Text("From Installed List")
                                Image(systemName: "document.on.document")
                            }
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                        .frame(maxWidth: .infinity,  alignment: .topTrailing)
                        .padding(.horizontal)
                        
                        
                        Text("Pull Lists")
                            .font(.system(.title2, design: .default))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom)
                
                List {
                    ForEach(pullListArray) { pullList in
                        NavigationLink(value: pullList) {
                            PullListListView(pullList)
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .padding(.bottom)
            }
            .onAppear {
                isEditing = false
                Task {
                    await loadInitialPullLists()
                }
            }
            .onDisappear {
    //            viewModel.stopListening()
            }
            .navigationDestination(for: PullList.self) { pullList in
                 PullListDetailsView(path: $path, pullList: pullList, isEditing: $isEditing)
            }
        }
        
    }
    
    private func loadInitialPullLists() async {
        await viewModel.loadPullLists() { fetchedLists in
            pullListArray = fetchedLists
        }
    }
        
}

//#Preview {
//    PullListView()
//}
