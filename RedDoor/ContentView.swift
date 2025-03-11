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
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "square.stack.fill")
                }.tint(.blue)
            PullListInventoryView()
                .tabItem {
                    Label("Pull Lists", systemImage: "list.bullet")
                }.tint(.blue)
            InstalledListInventoryView()
                .tabItem {
                    Label("Installed Lists", systemImage: "list.bullet.clipboard")
                }.tint(.blue)
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }.tint(.blue)
        }
        .tint(.red)
    }
}

#Preview {
    ContentView()
}
