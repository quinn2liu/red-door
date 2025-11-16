//
//  ContentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        TabView {
            Group {
                ModelInventoryView()
                    .tabItem {
                        Label("Inventory", systemImage: "square.stack.fill")
                    }

                PullListDocumentView()
                    .tabItem {
                        Label("Pull Lists", systemImage: "list.bullet")
                    }
                InstalledListDocumentView()
                    .tabItem {
                        Label("Installed Lists", systemImage: "list.bullet.clipboard")
                    }
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
