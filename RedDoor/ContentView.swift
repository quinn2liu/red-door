//
//  ContentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var isEditing: Bool = false
    @State private var inventorySearch = ""
    @State private var pullListSearch = ""

    var body: some View {
//        NavigationStack(path: $path) {
            TabView {
                InventoryView(isEditing: $isEditing, searchText: $inventorySearch)
                    .tabItem {
                        Label("Inventory", systemImage: "square.stack.fill")
                        
                    }
                PullListView()
                    .searchable(text: $pullListSearch, prompt: "Search Pull Lists")
                    .tabItem {
                        Label("Pull Lists", systemImage: "list.bullet")
                    }
                InstalledListView()
                    .tabItem {
                        Label("Installed Lists", systemImage: "list.bullet.clipboard")
                    }
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person")
                    }
            }
//            .navigationDestination(for: Model.self) { model in
//                ItemView(path: $path, model: model, isEditing: $isEditing)
//            }
//            .navigationDestination(for: PullList.self) { model in
//                // PullListDetailsView(path: $path, model: model, isEditing: $isEditing)
//            }
            .background(Color.white)
            .accentColor(.red)
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
