//
//  ContentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false

    var body: some View {
            TabView {
                InventoryView()
                    .tabItem {
                        Label("Inventory", systemImage: "square.stack.fill")
                    }

                PullListView()
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
    }
    
    
    
}

#Preview {
    ContentView()
}
