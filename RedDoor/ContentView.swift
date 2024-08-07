//
//  ContentView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "square.stack.fill")
                }
            PullListView()
                .tabItem {
                    Label("PullList", systemImage: "list.bullet")
                }
            InstalledListView()
                .tabItem {
                    Label("InstalledList", systemImage: "list.bullet.clipboard")
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
