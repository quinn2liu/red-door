//
//  StagingPullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/10/25.
//

import SwiftUI

struct StagingPullListView: View {
    @State private var viewModel: PullListViewModel
    @Binding var path: NavigationPath

    init(pullList: RDList, path: Binding<NavigationPath>) {
        viewModel = PullListViewModel(selectedList: pullList)
        _path = path
    }

    var body: some View {
        Text("Staging Pull List")
        Button {
            viewModel.selectedList.status = .planning
            viewModel.updateSelectedList()
            Task { @MainActor in
                path = NavigationPath()
                try? await Task.sleep(for: .milliseconds(100))
                path.append(viewModel.selectedList)
            }
        } label: {
            Text("Change to planning")
        }
    }
}