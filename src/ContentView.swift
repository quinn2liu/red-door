//
//  ContentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var coordinator: NavigationCoordinator = NavigationCoordinator()

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Group {
                ModelInventoryView(path: $coordinator.inventoryPath)
                    .tabItem {
                        Label("Inventory", systemImage: "square.stack.fill")
                    }
                    .tag(NavigationCoordinator.Tab.inventory)
                    .environment(coordinator)

                PullListDocumentView(path: $coordinator.pullListPath)
                    .tabItem {
                        Label("Pull Lists", systemImage: "list.bullet")
                    }
                    .tag(NavigationCoordinator.Tab.pullList)
                    .environment(coordinator)

                InstalledListDocumentView(path: $coordinator.installedListPath)
                    .tabItem {
                        Label("Installed Lists", systemImage: "list.bullet.clipboard")
                    }
                    .tag(NavigationCoordinator.Tab.installedList)
                    .environment(coordinator)

                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person")
                    }
            }.tint(.blue)
        }.tint(.red)
    }
}

#Preview {
    ContentView()
}
