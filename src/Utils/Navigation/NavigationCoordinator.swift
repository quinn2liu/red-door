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
        case pullList = 0
        case installedList = 1
        case inventory = 2
        case options = 3
    }

    var selectedTab: Tab = .pullList
    var inventoryPath: NavigationPath = NavigationPath()
    var pullListPath: NavigationPath = NavigationPath()
    var installedListPath: NavigationPath = NavigationPath()
    var optionsPath: NavigationPath = NavigationPath()

    var selectedPath: NavigationPath {
        switch selectedTab {
        case .pullList:
            return pullListPath
        case .installedList:
            return installedListPath
        case .inventory:
            return inventoryPath
        case .options:
            return optionsPath
        }
    }

    func setSelectedTab(to tab: Tab) {
        selectedTab = tab
    }

    func appendToSelectedPath(_ item: any Hashable) {
        switch selectedTab {
        case .pullList:
            pullListPath.append(item)
        case .installedList:
            installedListPath.append(item)
        case .inventory:
            inventoryPath.append(item)
        case .options:
            optionsPath.append(item)
        }
    }

    func resetSelectedPath() {
        switch selectedTab {
        case .pullList:
            pullListPath = NavigationPath()
        case .installedList:
            installedListPath = NavigationPath()
        case .inventory:
            inventoryPath = NavigationPath()
        case .options:
            optionsPath = NavigationPath()
        }
    }
}