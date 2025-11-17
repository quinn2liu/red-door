//
//  NavigationCoordinator.swift
//  RedDoor
//
//  Created by Quinn Liu on 11/16/25.
//

import SwiftUI

@Observable
class NavigationCoordinator {

    enum Tab: Int {
        case inventory = 0
        case pullList = 1
        case installedList = 2
        case account = 3
    }

    var selectedTab: Tab = .inventory
    var inventoryPath: NavigationPath = .init()
    var pullListPath: NavigationPath = .init()
    var installedListPath: NavigationPath = .init()
}