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
            Tab("Inventory", systemImage: "square.stack.fill", value: NavigationCoordinator.Tab.inventory) {
            ModelInventoryView(path: $coordinator.inventoryPath)
                    .environment(coordinator)
            }

            Tab("Pull Lists", systemImage: "list.bullet", value: NavigationCoordinator.Tab.pullList) {
                PullListDocumentView(path: $coordinator.pullListPath)
                    .environment(coordinator)
            }

            Tab("Installed Lists", systemImage: "list.bullet.clipboard", value: NavigationCoordinator.Tab.installedList) {
                InstalledListDocumentView(path: $coordinator.installedListPath)
                    .environment(coordinator)
            }

            Tab("Account", systemImage: "person", value: NavigationCoordinator.Tab.account) {
                AccountView()
            }
        }.tint(.red)
    }
}

#Preview {
    ContentView()
}
