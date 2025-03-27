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
                PullListInventoryView()
                    .tabItem {
                        Label("Pull Lists", systemImage: "list.bullet")
                    }
                InventoryView()
                    .tabItem {
                        Label("Inventory", systemImage: "square.stack.fill")
                    }
                InstalledListInventoryView()
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
