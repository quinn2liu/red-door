//
//  NavigationDestinationModifier.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/16/25.
//

import Foundation

import SwiftUI

struct NavigationDestinationsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Model.self) { model in
                ModelView(model: model)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: PullList.self) { pullList in
                PullListDetailsView(pullList: pullList)
            }
            .navigationDestination(for: RoomMetadata.self) { roomData in
                RoomView(roomData: roomData)
            }
//            .navigationDestination(for: InstalledList.self) { installedList in
//                InstalledListView()
//            } not used yet
            .navigationDestination(for: String.self) { string in
                Group {
                    if string == "might be useful" {
                        
                    }
                }
            }
    }
}

extension View {
    func rootNavigationDestinations() -> some View {
        modifier(NavigationDestinationsModifier())
    }
}
