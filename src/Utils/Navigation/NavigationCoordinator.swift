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
        case options = 3
    }

    var selectedTab: Tab = .inventory
    var inventoryPath: NavigationPath = NavigationPath()
    var pullListPath: NavigationPath = NavigationPath()
    var installedListPath: NavigationPath = NavigationPath()
    var optionsPath: NavigationPath = NavigationPath()

    var selectedPath: NavigationPath {
        switch selectedTab {
        case .inventory:
            return inventoryPath
        case .pullList:
            return pullListPath
        case .installedList:
            return installedListPath
        case .options:
            return optionsPath
        }
    }

    func setSelectedTab(to tab: Tab) {
        selectedTab = tab
    }

    func appendToSelectedPath(_ item: any Hashable) {
        switch selectedTab {
        case .inventory:
            inventoryPath.append(item)
        case .pullList:
            pullListPath.append(item)
        case .installedList:
            installedListPath.append(item)
        case .options:
            optionsPath.append(item)
        }
    }

    func resetSelectedPath() {
        switch selectedTab {
        case .inventory:
            inventoryPath = NavigationPath()
        case .pullList:
            pullListPath = NavigationPath()
        case .installedList:
            installedListPath = NavigationPath()
        case .options:
            optionsPath = NavigationPath()
        }
    }
}